;主引导扇区程序
;负责加载内核
;初始化代码清单15-1

;常数定义
core_base_address equ 0x00040000   ;常数，内核加载的起始内存地址
core_start_sector equ 0x00000001   ;常数，内核的起始逻辑扇区号

;---------- 保护模式准备 --------
	mov ax,cs                          ;设置堆栈段和栈指针
	mov ss,ax
	mov sp,0x7c00

	;计算GDT所在的逻辑段地址
	mov eax,[cs:pgdt+0x7c00+0x02]      ;GDT的32位物理地址 
	xor edx,edx
	mov ebx,16
	div ebx                            ;分解成16位逻辑地址 

	mov ds,eax                         ;令DS指向该段以进行操作
	mov ebx,edx                        ;段内起始偏移地址 

	;跳过0#号描述符的槽位 
	;创建1#描述符，这是一个数据段，对应0~4GB的线性地址空间
	mov dword [ebx+0x08],0x0000ffff    ;基地址为0，段界限为0xFFFFF
	mov dword [ebx+0x0c],0x00cf9200    ;粒度为4KB，存储器段描述符 

	;创建保护模式下初始代码段描述符
	mov dword [ebx+0x10],0x7c0001ff    ;基地址为0x00007c00，界限0x1FF 
	mov dword [ebx+0x14],0x00409800    ;粒度为1个字节，代码段描述符 

	;建立保护模式下的堆栈段描述符      ;基地址为0x00007C00，界限0xFFFFE 
	mov dword [ebx+0x18],0x7c00fffe    ;粒度为4KB 
	mov dword [ebx+0x1c],0x00cf9600

	;建立保护模式下的显示缓冲区描述符   
	mov dword [ebx+0x20],0x80007fff    ;基地址为0x000B8000，界限0x07FFF 
	mov dword [ebx+0x24],0x0040920b    ;粒度为字节

	;初始化描述符表寄存器GDTR
	mov word [cs: pgdt+0x7c00],39      ;描述符表的界限   

	lgdt [cs: pgdt+0x7c00]

	in al,0x92                         ;南桥芯片内的端口 
	or al,0000_0010B
	out 0x92,al                        ;打开A20

	cli                                ;中断机制尚未工作

	mov eax,cr0
	or eax,1
	mov cr0,eax                        ;设置PE位

	;以下进入保护模式... ...
	jmp 0x0010:flush                   ;16位的描述符选择子：32位偏移
									   ;清流水线并串行化处理器
;---------- 保护模式准备结束 --------

;以下使用32位指令编码
;进入32位保护模式
[bits 32]
flush:
	;设置数据段访问范围
	mov eax,0x0008
	mov ds,eax			;DS指向4GB内存空间
	
	;设置栈段访问范围
	mov eax,0x0018
	mov ss,eax
	sub esp,esp	;esp=0，指针向下递减，0xffffffff开始往下递减
	
	;先读取一个扇区，获得程序头部内容和部分其他指令或数据
	mov edi,core_base_address
	mov ebx,edi						;内核在内存中的位置
	mov eax,core_start_sector		;内核逻辑扇区号
	call read_logical_sector

	;计算占用扇区数量
	;64位除法，EDX:EAX(被除数) / ECX(除数)  = EAX(内核所占扇区数量)......EDX(根据是否有余数情况进行不同的处理)
	sub edx,edx		;高32位没有用到，所以为0
	mov eax,[edi]	;低32位，DS目前指向的是0~4GB数据段，edi作为偏移量访问内存
					;这里取得的是内核程序总长度
	mov ecx,512
	div ecx			;EAX=内核所占扇区数量，EDX=根据余数情况判断是否扇区数需要+1
	
	;检查余数是否为0
	cmp edx,0
	je @no_remainder		;如果为0，则不需要额外读取一个扇区

	;有余数需要额外读取一个扇区
	inc eax
	
@no_remainder:
	dec eax			;减去已经预读的扇区
	
	;如果eax=0, 说明用户程序小于等于512字节(扇区数为0)，直接进入主流程
	cmp eax,0
	jz setup
	
	;否则根据已有扇区数循环读取数据，调read_logical_sector过程，把内核程序都放到内存中
	mov ecx,eax		;需要循环读取的扇区数
	mov eax,core_start_sector
	inc eax			;从下一个逻辑扇区接着读
	
@loop_read:
	call read_logical_sector
	inc eax
	loop @loop_read

;安装段描述符，要做的事情就是找到内存中的GDT，修改它并重新载入
setup:
	mov esi,[0x7c00+pgdt+0x02]		;获得GDT的基地址
	
	;建立内核api例程段描述符
	mov eax,[edi+0x04]				;内核core_api代码段起始汇编地址
	mov ebx,[edi+0x08]				;内核core_data数据段的汇编地址
	sub ebx,eax
	dec ebx							;内核api代码段的界限 = 内核数据段起始汇编地址 - 内核api段的起始汇编地址 - 1
	add eax,edi						;内核api段的基地址 = 内核加载地址 + 内核api段的起始汇编地址
	;准备参数：EAX存放基地址 EBX存放段界限 ECX存放各属性
	mov ecx,0x00409800				;段属性：P=1(段存在) D=1(32位操作) G=0(字节粒度) DPL=0(特权级0) S=1(代码段) TYPE=1000(只执行)
	call make_gdt_descriptor		;调用过程制作描述符
	;描述符紧接着之前的描述存放
	mov [esi+0x28],eax
	mov [esi+0x2c],edx
	
	;建立核心数据段描述符
	mov eax,[edi+0x08]                 ;核心数据段起始汇编地址
	mov ebx,[edi+0x0c]                 ;核心代码段汇编地址 
	sub ebx,eax
	dec ebx                            ;核心数据段界限
	add eax,edi                        ;核心数据段基地址
	mov ecx,0x00409200                 ;字节粒度的数据段描述符 
	call make_gdt_descriptor
	mov [esi+0x30],eax
	mov [esi+0x34],edx 

	;建立核心代码段描述符
	mov eax,[edi+0x0c]                 ;核心代码段起始汇编地址
	mov ebx,[edi+0x00]                 ;程序总长度
	sub ebx,eax
	dec ebx                            ;核心代码段界限
	add eax,edi                        ;核心代码段基地址
	mov ecx,0x00409800                 ;字节粒度的代码段描述符
	call make_gdt_descriptor
	mov [esi+0x38],eax
	mov [esi+0x3c],edx
	
	mov word [0x7c00+pgdt],63		;描述符表界限，现在有8个描述符
	
	lgdt [0x7c00+pgdt]				;重新载入描述符表
	
	jmp far [edi+0x10]				;跳转到内核程序入口点执行

;过程：读取一个逻辑扇区
;输入：EAX=逻辑扇区号，EAX是32位寄存器，可以一次性容纳28位逻辑扇区号
;	   DS:EBX=读取后的内容放置在内存中的位置，DS指定的数据段，EBX指定偏移地址
;	   每次读以512字节对齐，后续带来方便
read_logical_sector:
         push eax 
         push ecx
         push edx
         
		 push eax
         
		 mov dx,0x1f2
         mov al,1
         out dx,al                       ;读取的扇区数

         inc dx                          ;0x1f3
         pop eax
         out dx,al                       ;LBA地址7~0

         inc dx                          ;0x1f4
         mov cl,8
         shr eax,cl
         out dx,al                       ;LBA地址15~8

         inc dx                          ;0x1f5
         shr eax,cl
         out dx,al                       ;LBA地址23~16

         inc dx                          ;0x1f6
         shr eax,cl
         or al,0xe0                      ;第一硬盘  LBA地址27~24
         out dx,al

         inc dx                          ;0x1f7
         mov al,0x20                     ;读命令
         out dx,al

  .waits:
         in al,dx
         and al,0x88
         cmp al,0x08
         jnz .waits                      ;不忙，且硬盘已准备好数据传输 

         mov ecx,256                     ;总共要读取的字数
         mov dx,0x1f0
  .readw:
         in ax,dx
         mov [ebx],ax
         add ebx,2
         loop .readw

         pop edx
         pop ecx
         pop eax
      
         ret

;制作段描述符
;输入：	EAX=线性基地址
;		EBX=段界限，只用低20位，因为段界限在段描述符格式中占20位
;		ECX=各属性，与描述符格式保持一致，无关的位都清0
;返回： EDX:EAX=完整的描述符
make_gdt_descriptor:
		;构造低32位
		mov edx,eax			;线性基地址复制一份到edx中
		shl eax,16			;左移16位使得基地址放在低32位中的高16位
		or ax,bx			;低32位中的低16位存放段界限
		
		;清除基地址中无关的位
		;如果不使用rol、bswap,仅使用shl、shr、and、or指令则代码会变得复杂一些
		and edx,0xffff0000			;保留edx中高16位，如果 edx = 0x12345678，执行该指令后edx=0x12340000
		rol edx,8					;循环左移，最左边8位放在最右边, edx=34000012
		bswap edx					;字节交换指令[31:24] 与 [7:0] 交换；[23:16] 与 [15:8] 交换
		
		;装配段界限
		and ebx,0x000f0000
		or edx,ebx
		
		;装配属性
		or edx,ecx
		
		ret
;---------------------------------
;pgdt gdt的界限和起始物理地址
pgdt	dw 0
		dd 0x00007e00
;---------------------------------
times 510-($-$$) db 0
				 dw 0xAA55