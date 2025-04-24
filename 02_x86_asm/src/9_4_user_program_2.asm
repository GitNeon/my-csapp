;9-4 用户程序的优化：
;思考：将代码段1中的子过程优化为通过call指令调用，类似于高级语言的函数调用，增强可阅读性

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

	; 过程：显示字符串
	; 输入: DS:BX=字符串的段地址:偏移地址
	display_string:
		push ax
		push bx
		push cx
	.display_loop:
		mov cl, [bx]  ; 从ds:bx地址处获得单个字符
		or cl, cl     ; 影响标志寄存器中的ZF位，ZF=0说明取到了字符串0终止
		jz .exit_string
		call put_char
		inc bx
		jmp .display_loop
	.exit_string:
		pop cx
		pop bx
		pop ax
		ret

	; 过程：显示单个字符
	; 输入：cl=单个字符ascii码
	put_char:
		push ax
		push bx
		push cx
		push dx
		push ds
		push es  ; 保护现场，相关寄存器压栈保护

		call get_cursor  ; 获取光标当前位置
		call handle_char ; 处理字符
		call set_cursor  ; 设置光标位置

		pop es
		pop ds
		pop dx
		pop cx
		pop bx
		pop ax
		ret

	; 过程：获取光标位置
	; 输出：BX=光标位置16位数
	get_cursor:
		; 这段获取的是光标高8位
		mov dx, 0x3d4  ; 索引寄存器端口号为0x3d4
		mov al, 0x0e   ; 光标寄存器高8位，索引值是14(0x0e)
		out dx, al     ; 向该端口写入值，表示访问光标寄存器(该光标寄存器存储着光标值的高8位)
		mov dx, 0x3d5  ; 数据端口为0x3d5
		in al, dx      ; 从这个端口读入1字节数据存放到al寄存器中
		mov ah, al     ; 放到高8位
		; 这段获取的是光标低8位
		mov dx, 0x3d4
		mov al, 0x0f   ; 光标寄存器低8位，索引值是15
		out dx, al     ; 访问光标寄存器低8位
		mov dx, 0x3d5
		in al, dx      ; 低8位
		mov bx, ax     ; BX=光标位置16位数
		ret

	; 过程：处理字符
	; 输入：CL=单个字符ASCII码，BX=光标位置
	handle_char:
		cmp cl, 0x0d    ; 是不是回车字符
		jz .handle_cr   ; 是回车字符，跳转到处理回车
		cmp cl, 0x0a    ; 是不是换行符
		jz .handle_lf   ; 是换行符，跳转到处理换行
		jmp .handle_other ; 正常显示可打印字符

	.handle_cr:
		mov ax, bx
		mov bl, 80
		div bl          ; 除以80得到行号,这是16位除法，商放在AL中
		mul bl          ; 此时，AX中存放的就是当前行首的光标值
		mov bx, ax
		jmp .end_handle

	.handle_lf:
		add bx, 80      ; 是换行符就+1行
		call roll_screen ; 如果光标原先就在屏幕最后一行，那么应该根据情况滚屏
		jmp .end_handle

	.handle_other:
		mov ax, 0xb800  ; 显存地址
		mov es, ax
		shl bx, 1       ; 左移一位相当于乘以2
		mov [es:bx], cl ; 写入所显示的字符
		shr bx, 1       ; 下一个字符位置，将字节偏移地址恢复为字符位置
		add bx, 1       ; 字符位置+1

	.end_handle:
		ret

	; 过程：滚屏
	; 输入：BX=光标位置
	roll_screen:
		cmp bx, 2000
		jl .end_roll    ; 如果光标小于2000，没有超出屏幕显示，反之，需要执行滚动屏幕内容
		push bx         ; 待会要用到bx寄存器，所以先压栈保存
		mov ax, 0xb800
		mov ds, ax
		mov es, ax
		cld             ; clear direction flag,清除方向标志位
		mov si, 0xa0    ; 源位置0xa0=160，从屏幕第2行第1列的位置开始
		mov di, 0x00    ; 目标位置从0x00处开始，屏幕第1行第1列
		mov cx, 1920    ; 1920=24行*每行80个字符*每个字符的占用字节数 / 字(2字节)
		rep movsw       ; rep=重复执行,movsw = mov string word, DS:SI -> ES:DI

		; 由于屏幕最后一行还保持的原来的内容，需要清除最后一行
		mov bx, 3840    ; 屏幕上第25行第1列在显存中的偏移位置
		mov cx, 80
	.cls:
		mov word [es:bx], 0x0720  ; 黑底白字的空白字符
		add bx, 2
		loop .cls

		pop bx
		sub bx, 80    ; 滚屏后，移动到最后一行的行首，因为之前判断是不是换行符已经加了80
	.end_roll:
		ret

	; 过程：设置光标位置
	; 输入：BX=光标位置
	set_cursor:
		mov dx, 0x3d4
		mov al, 0x0e
		out dx, al     ; 通过端口0x3d4访问索引寄存器，写入0x0e,表示访问光标寄存器高8位
		mov dx, 0x3d5
		mov al, bh
		out dx, al     ; 通过数据端口写入BX寄存器中高8位数值
		; 同样的写入低8位
		mov dx, 0x3d4
		mov al, 0x0f
		out dx, al
		mov dx, 0x3d5
		mov al, bl
		out dx, al
		ret

	start:
		mov ax,[stack_seg_item]			;设置自己的栈段
		mov ss,ax
		mov sp,stack_seg_end			;栈指针地址为256
		
		mov ax,[data_seg_1_item]		;设置自己的数据段
		mov ds,ax
		
		mov bx,msg0
		call display_string				;调用过程显示第一段信息
		
		;这里使用retf实现段间转移，ref不依赖于call far或者jmp far指令
		;retf指令依次从栈中弹出IP、CS
		push word [es:code_seg_2_item]	;压入代码段code_seg_2段地址
		mov ax,begin				
		push ax						;压入偏移地址
		retf						;转移到代码段2执行
	
	continue:
		mov ax,[es:data_seg_2_item]
		mov ds,ax					;切换到数据段2
		mov bx,msg1
		call display_string
		
		jmp $

code_seg_1_end:

;代码段2
SECTION code_seg_2 align=16 vstart=0

	begin:
		push word [es:code_seg_1_item]
		mov ax,continue
		push ax
		retf						;转移到代码段1继续执行
	
code_seg_2_end:

;数据段1
SECTION data_seg_1 align=16 vstart=0
	;屏幕上需要显示的信息
	;0x0d-回车，0x0a-换行
    msg0 db '  This user program is changed. '
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
    msg1 db '  The above contents is written by LeeChung. '
         db '2011-05-06'
         db 0
data_seg_2_end:

;栈段
SECTION stack_seg align=16 vstart=0
	resb 256	;从当前位置开始保留指定数量的字节，但不初始化它们的值
				;汇编地址范围0~255
stack_seg_end:	;此处地址则为256

;程序尾部，用于获得程序整体长度
SECTION tail align=16
program_end:
