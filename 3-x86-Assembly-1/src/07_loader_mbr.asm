;加载器程序
;包含通过端口从硬盘读写数据、加载用户程序等功能

app_logic_start equ 100 	;用户程序所在起始逻辑扇区号

SECTION MBR align=16 vstart=0x7c00		;定义一个段，因为主引导扇区的程序会被加载到内存中的0x7c00处，所以这里vstart=0x7c00
	;设置栈段、栈指针起始位置 SS:SP = 0x0000:0x0000
	;根据可用的内存00000~0FFFF处的地址为加载器和栈的势力范围
	mov ax,0
	mov ss,ax
	mov sp,ax
	
	;将物理地址转换成处理器支持的 段地址:偏移地址 形式 
	; DX:AX / BX = AX(段地址)...DX(偏移地址)
	; AX=0x1000 DX=0x0000
	mov ax,[cs:mem_start_addr]
	mov dx,[cs:mem_start_addr + 0x02]	;start_addr位于代码段内，因此需要显式指明段前缀为CS
	mov bx,16
	div bx
	mov ds,ax	
	mov es,ax	;将数据段寄存器、附加段寄存器也指向0x1000处
	
	
	;调用过程读取一个逻辑扇区
	;app_logic_start逻辑扇区号为28位的，需要将逻辑扇区号拆分为低16位和高12位
	;DI:SI = 28位逻辑扇区编号
	;SI = 0000_0000_0110_0100 低16位
	;DI = 0000_0000_0000_0000 高12位
	mov di,0
	mov si,app_logic_start
	sub bx,bx				;读的数据放到DS:[BX]处,BX从0处开始
	call read_logic_sector	;以上3条指令设置完参数后调用read_logic_sector过程
	
read_logic_sector:		;从硬盘读取一个逻辑扇区
	
	;保存用到的寄存器
	push ax
	push bx
	push cx
	push dx
	
	;设置要读取的扇区数量
	mov dx,0x1f2		;0x1f2端口保存的是要读取的扇区数量
	mov al,0x01
	out dx,al
	
	;设置起始LBA扇区号,28位扇区号太长，分别放在0x1f3、0x1f4、0x1f5、0x1f6处
	mov dx,0x1f3		;0x1f3
	mov ax,si
	out dx,al			;LBA地址0~7位
	
	inc dx				;0x1f4
	mov al,ah
	out dx,al			;LBA地址8~15位
	
	inc dx				;0x1f5
	mov al,di
	out dx,al			;LBA地址16~23位;
	
	inc dx				;0x1f6
	mov al,0xe0			;0xe0 = 1110_0000B
	out dx,al			;al中的信息包含设置LBA模式，主硬盘，LBA地址24~27位
	
	;发出读命令
	inc dx				;0x1f7
	mov al,0x20
	out dx,al

	;等待硬盘空闲且硬盘已准备好数据传输 
	waits:
		in al,dx		;获得硬盘返回结果
		and al,0x88		;10001000B
		cmp al,0x08		;00001000B，比较是否硬盘准备好数据
		jnz waits		;没准备就一直等
		

	;读取512字节，也就是一个扇区,循环256次就是按字读
	mov cx,256
	mov dx,0x1f0	;从这个端口读数据

	
	;准备好后开始读取数据
	read_data:
		in ax,dx		;从端口获得数据
		mov [bx],ax 	;读取的数据存放到由段寄存器DS指定的数据段,偏移地址由寄存器BX指定
		add bx,2
		loop read_data
		
	
	;寄存器恢复
	pop dx
	pop cx
	pop bx
	pop ax
	


mem_start_addr  dd 0x10000	;用户程序被加载到内存中的物理起始地址

times 510-($-$$) db 0
                 dw 0xaa55	;填充主引导程序并以0xAA55结尾