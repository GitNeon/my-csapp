;描述：程序加载器程序清单（位于主引导扇区）
;作者：fanx
;日期：2025.02.11

user_program_start equ 100	;用户程序所在扇区起始位置，声明常数不占用汇编地址

SECTION mbr align=16 vstart=0x7c00
		;设置栈段 栈寄存器SS  栈指针SP
		mov ax,0
		mov ss,ax
		mov sp,ax

		;需要将物理地址转换为段地址:偏移地址形式
		;由于地址是双字，需要两个寄存器来保存，DX放高位，AX放低位
		;除以16分别，商为段地址(AX)，余数为偏移地址(DX)
		mov ax,[cs:user_program_memory_address]
		mov dx,[cs:user_program_memory_address + 0x02]
		mov bx,16
		div bx
		mov ds,ax
		mov es,ax		;放入这两个寄存器后续使用

		;调用read_logical_sector先读取用户程序头部内容
		;也就是先读一个扇区(512字节)，包含头部信息和部分指令数据
		;然后根据头部信息计算出还要在读多少个扇区
		;准备该过程所需要的参数，也就是设置寄存器内容
		sub di,di					;寄存器DI清零0，保证高位数值正确
		mov si,user_program_start	;传入常量
		sub bx,bx					;BX清零，偏移地址存放在BX处
		call read_logical_sector


		;计算占用的逻辑扇区数
		;占用的逻辑扇区数 = 程序总长度 / 512字节
		;此段逻辑相对于书中给出的程序进行了优化
		mov dx,[0x02]		;高16位
		mov ax,[0x00]		;低16位，DX:AX获得程序总长度
		mov bx,512			;每个扇区512字节
		div bx				;AX=商（扇区数），DX=余数（扇区数需要+1）

		;判断是否需要额外读取一个扇区
		cmp dx,0			;检查余数是否为0
		je @no_remainder	;如果为0，则不需要额外读取一个扇区
							

		;有余数需要额外读取一个扇区
		inc ax

	@no_remainder:
		dec ax			;减去已经预读的扇区

		;如果ax=0, 说明用户程序小于等于512字节(扇区数为0)，直接进入主流程
		cmp ax,0
		jz main

		;否则根据已有扇区数循环读取数据，调read_logical_sector过程，把用户程序都放到内存中
		push ds			;以下要用到ds寄存器，所以先保存到栈中
		mov cx,ax		;需要循环读取的扇区数

	@loop_read:
		mov ax,ds		;|
		add ax,0x20		;| 紧挨着上一个数据段尾构造一个新的512字节段，这样做是避免用户程序太大而导致产生段内数据覆盖
		mov ds,ax		;|
		
		sub bx,bx		;每次偏移地址从0x0000开始
		inc si			;下一个逻辑扇区
		call read_logical_sector
		loop @loop_read

		pop ds			;恢复ds寄存器地址到用户头部段

	;主入口处理流程
	main:
		mov dx,[0x08]
		mov ax,[0x06]	;用户程序入口点段地址
		call calc_segment_base
		mov [0x06],ax	;将逻辑段基址存放到原来的位置中
		
		;处理所有的段重定位表
		mov cx,[0x0a]	;表项数量
		mov bx,0x0c		;表起始地址
		
	loop_relocation:
		mov dx,[bx+0x02]	;起始地址高16位
		mov ax,[bx]			;起始地址低16位
		call calc_segment_base
		mov [bx],ax			;回填基地址
		add bx,4			;下一个重定位表项，每个表项占4字节
		loop loop_relocation
		
		jmp far [0x04]		;转移到用户入口点

	;过程：读取逻辑扇区
	;输入：DI:SI=起始逻辑扇区号（28位），DI存放高12位(高12位左侧加0扩展到16位)，SI存放低16位
	;	   DS:BX=数据放置位置，DS指定的数据段，BX指定偏移地址
	read_logical_sector:
		push ax
		push bx
		push cx
		push dx	
		
		;(1)设置要读取的扇区数量
		mov dx,0x1f2
		mov al,0x01
		out dx,al
		
		;(2)设置LBA扇区号，28位的扇区号太长，需要将其分成4段，分别写入端口0x1f3、0x1f4、0x1f5和0x1f6
		; |0x1f6	   |0x1f5       |0x1f4       |0x1f3
		; 0000_0000    0000_0000    0000_0000    0000_0000
		; 位27~24      位23~16		位15~8		 位7~0
		
		;写入LBA地址7~0
		mov dx,0x1f3
		mov ax,si
		out dx,al
		
		;写入地址15~8
		inc dx
		mov al,ah
		out dx,al
		
		;写入地址23~16
		inc dx
		mov ax,di
		out dx,al
		
		;写入地址27~24，并设置为LBA模式
		inc dx
		mov al,0xe0
		or al,ah
		out dx,al
		
		;(3)请求硬盘读取数据
		mov dx,0x1f7
		mov al,0x20
		out dx,al
		
		;(4)等待读写操作完成
		mov dx,0x1f7
	waits:
		in al,dx
		and al,0x88
		cmp al,0x08
		jnz waits
			
		mov cx,256		;总共要读取的字数
		mov dx,0x1f0	;从这个数据端口读取数据
		
	readw:
		in ax,dx
		mov [bx],ax
		add bx,2
		loop readw

		pop dx
		pop cx
		pop bx
		pop ax
	  
		ret
	
	;过程：计算段基址
	;输入：DX:AX=32位物理地址
	;输出：AX=16位逻辑段地址
	;注意：尽管DX:AX中是32位的用户程序起始物理内存地址，理论上，
	;它只有20位是有效的，低16位在寄存器AX中，高4位在寄存器DX的低4位。
	calc_segment_base:
		push ds
		
		add ax,[cs:user_program_memory_address]
		adc dx,[cs:user_program_memory_address + 0x02]		;别忘了DX,AX中的内容还要基于加载的物理地址
		shr ax,4			;AX中内容右移4位，高位补0
		ror dx,4			;循环移位，把低四位移到高4位
		and dx,0xf000		;将寄存器低12位清零
		or ax,dx			;由于AX高4位为空，DX低四位有值，所以使用or指令合并这两个寄存器内容
							;现在AX中存放的就是16位逻辑地址
		pop ds
		
		ret
		
mbr_end:

user_program_memory_address	dd 0x10000	;用户程序所在内存加载的物理地址

;前面没使用部分用0填充，最后2字节代表主引导扇区结束标志
;$代表当前汇编地址
;$$代表当前汇编节（段）的起始汇编地址
times 510-($-$$) db 0
dw 0xAA55