;描述：用户程序清单
;作者：fanx
;日期：2025.02.11

;程序头部段
SECTION header vstart=0
	program_length	dd program_end							;[0x00] 程序总长度
	program_entry	dw start								;[0x04] 程序入口，偏移地址
					dd section.code_seg_1.start				;[0x06] 段地址
	seg_table_len	dw (header_end - code_seg_1_item)/4		;[0x0a] 段重定位表项数量
	
	;段重定位表
	code_seg_1_item dd section.code_seg_1.start				;[0x0c] 代码段1的段地址
	code_seg_2_item dd section.code_seg_2.start				;[0x10] 代码段2的段地址
	data_seg_1_item dd section.data_seg_1.start				;[0x14] 数据段1的段地址
	data_seg_2_item dd section.data_seg_2.start				;[0x18] 数据段2的段地址
	stack_seg_item	dd section.stack_seg.start				;[0x1c] 栈段段地址
header_end:

;代码段1
SECTION code_seg_1 align=16 vstart=0

	;过程：显示字符串
	;输入: DS:BX=字符串的段地址:偏移地址
	;循环调用get_char过程获取单个字符，判断是否为0，为0则终止
	display_string:
		mov cl,[bx]			;从ds:bx地址处获得单个字符，由于一个字符占1个字节，所以用8位寄存器
		or cl,cl			;影响标志寄存器中的ZF位，ZF=0说明取到了字符串0终止
		jz .exit_string
		
		call put_char
		inc bx
		jmp display_string
		
		.exit_string:
			ret
	
	;过程：显示单个字符
	;输入：cl=单个字符ascii码
	put_char:
		push ax
        push bx
        push cx
        push dx
        push ds
        push es			;保护现场，相关寄存器压栈保护
		
		;获取光标当前位置
		;这段获取的是光标高8位
		mov dx,0x3d4		;索引寄存器端口号为0x3d4
		mov al,0x0e			;光标寄存器高8位，索引值是14(0x0e)
		out dx,al			;向该端口写入值，表示访问光标寄存器(该光标寄存器存储着光标值的高8位)
		mov dx,0x3d5		;数据端口为0x3d5
		in al,dx			;从这个端口读入1字节数据存放到al寄存器中
		mov ah,al			;放到高8位
		;这段获取的是光标低8位
		mov dx,0x3d4
		mov al,0x0f			;光标寄存器低8位，索引值是15
		out dx,al			;访问光标寄存器低8位
		mov dx,0x3d5
		in al,dx			;低8位
		mov bx,ax			;BX=光标位置16位数
		
		;判断是否为回车字符
		 
		pop es
        pop ds
        pop dx
        pop cx
        pop bx
        pop ax

        ret
	
	start:
		mov ax,[stack_seg_item]			;设置自己的栈段
		mov ss,ax
		mov sp,stack_seg_end			;栈指针地址为256
		
		mov ax,[data_seg_1_item]		;设置自己的数据段
		mov ds,ax
		
		mov bx,msg0
		call put_string					;调用过程显示第一段信息
		
code_seg_1_end:

;代码段2
SECTION code_seg_2 align=16 vstart=0

code_seg_2_end:

;数据段1
SECTION data_seg_1 align=16 vstart=0
	;屏幕上需要显示的信息
	;0x0d-回车，0x0a-换行
    msg0 db '  This is NASM - the famous Netwide Assembler. '
         db 'Back at SourceForge and in intensive development! '
         db 'Get the current versions from http://www.nasm.us/.'
         db 0x0d,0x0a,0x0d,0x0a
         db '  Example code for calculate 1+2+...+1000:',0x0d,0x0a,0x0d,0x0a
         db '     xor dx,dx',0x0d,0x0a
         db '     xor ax,ax',0x0d,0x0a
         db '     xor cx,cx',0x0d,0x0a
         db '  @@:',0x0d,0x0a
         db '     inc cx',0x0d,0x0a
         db '     add ax,cx',0x0d,0x0a
         db '     adc dx,0',0x0d,0x0a
         db '     inc cx',0x0d,0x0a
         db '     cmp cx,1000',0x0d,0x0a
         db '     jle @@',0x0d,0x0a
         db '     ... ...(Some other codes)',0x0d,0x0a,0x0d,0x0a
         db 0	;标志字符串结束，0终止的字符串
data_seg_1_end:

;数据段2
SECTION data_seg_2 align=16 vstart=0

data_seg_2_end:

;栈段
SECTION stack_seg align=16 vstart=0
	resb 256	;从当前位置开始保留指定数量的字节，但不初始化它们的值
				;汇编地址范围0~255
stack_seg_end:	;此处地址则为256

;程序尾部，用于获得程序整体长度
SECTION tail align=16
program_end: