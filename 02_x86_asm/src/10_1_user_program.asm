;用户程序
;中断过程的演示

SECTION header vstart=0
	program_length		dd program_end
	program_entry		dw start
						dd section.code_seg.start
	seg_table_len		dw (header_end - seg_table)/4
	
	seg_table:
	code_seg_item		dd section.code_seg.start
	data_seg_item		dd section.data_seg.start
	stack_seg_item		dd section.stack_seg.start
header_end:

;代码段
SECTION code_seg align=16 vstart=0	
	;过程：显示字符串
	;输入: DS:BX=字符串的段地址:偏移地址
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
	
	;过程：显示单个字符
	;输入：cl=单个字符ascii码
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

	;过程：获取光标位置
	;输出：BX=光标位置16位数
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

	;过程：处理字符
	;输入：CL=单个字符ASCII码，BX=光标位置
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

	;过程：滚屏
	;输入：BX=光标位置
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
		
	;过程：设置光标位置
	;输入：BX=光标位置
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
	
	;中断过程：intr_70
	intr_70:
		push ax
		push bx
		push cx
		push dx
		push es
		
		sub ax,ax
	.w0:
		mov al,0x0a		;将立即数 0x0a 加载到寄存器 AL 中
		or al,0x80		;0x80=1000_0000,关NMI中断，确保访问CMOS期间不会被打断
		out 0x70,al		;通过0x70端口写入要访问的寄存器地址，al=0x8a,表示要访问 CMOS 寄存器 0x0a，同时禁用 NMI
		in al,0x71		;通过数据端口0x71读取RTC寄存器A
		test al,0x80	;测试寄存器AL中的第7位是否为1，也是UIP状态位，
						;UIP=1表示访问CMOS RAM中的日期和时间是安全的
		jnz .w0			;继续等待RTC更新周期结束
		
		
		xor al,al		;al清零0
		or al,0x80		;关NMI中断
		out 0x70,al		;写入要访问的内存单元地址，0x80,访问0号单元，端口0x70的位7用于禁止或允许NMI
		in al,0x71		;读RTC当前时间(秒)
		push ax			;读出的数据压栈保存
		
		mov al,2		;访问CMOS RAM 2号内存单元，即内存偏移地址为0x02
		or al,0x80
		out 0x70,al
		in al,0x71		;读RTC当前时间(分)
		push ax
		
		mov al,4
		or al,0x80
		out 0x70,al
		in al,0x71		;读RTC当前时间(时)
		push ax
		
		mov al,0x0c
		out 0x70,al
		in al,0x71		;读一下RTC的寄存器C，使得所有中断标志复位
		
		mov ax,0xb800
		mov es,ax		;指向屏幕显示缓冲区
		
		
		pop ax					;第一次出栈的是 时
		call bcd_to_ascii		;调用过程处理成ascii码
		mov bx,12*160+36*2		;从屏幕上的12行36列开始显示
		mov [es:bx],ah
		mov [es:bx+2],al		;显示两位小时数字
		
		mov al,':'
		mov [es:bx+4],al		;显示分隔符:
		not byte [es:bx+5]      ;反转显示属性 
		
		pop ax					;分
		call bcd_to_ascii
		mov [es:bx+6],ah
		mov [es:bx+8],al
		
		mov al,':'
		mov [es:bx+10],al       ;显示分隔符':'
		not byte [es:bx+11]     ;反转显示属性		
		
		pop ax
		call bcd_to_ascii		;秒
		mov [es:bx+12],ah
		mov [es:bx+14],al

		mov al,0x20				;向8259中断芯片发送中断结束命令，中断结束命令的代码是0x20
		out 0xa0,al				;向从片发送
		out 0x20,al             ;向主片发送
		
		pop es
		pop dx
		pop cx
		pop bx
		pop ax
		
		iret			;interrupt return 中断返回指令，依次恢复IP、CS、FS
	
	;过程：BCD码转ASCII码
	;输入：AL=bcd码
	;输出：AX=ASCII码
	bcd_to_ascii:
		mov ah,al		;AL中的高4位和低4位分别是十位数字、个位数字，这里做拆分
		and al,0x0f		;仅保留低4位
		add al,0x30		;加上0x30,得到该数字对应的ASCII码
		
		shr ah,4		;然后处理高位，ah右移4位到低4位
		and ah,0x0f
		add ah,0x30
		
		ret
	
	;程序入口点
	start:
		mov ax,[stack_seg_item]
		mov ss,ax
		mov sp,stack_seg_end
		mov ax,[data_seg_item]
		mov ds,ax

		mov bx,init_msg                    ;显示初始信息 
		call display_string

		mov bx,inst_msg                    ;显示安装信息 
		call display_string

		;根据中断号计算出该中断的偏移地址
		;sub ax,ax		;ax寄存器清空
		mov al,0x70
		mov bl,4
		mul bl
		mov bx,ax			;BX=该中断在中断向量表中的偏移量

		cli				;IF=0，关中断

		;将70号中断处理程序安装到中断向量表中
		push es
		mov ax,0x0000
		mov es,ax 					;es指向中断向量表所在段的段地址
		mov word [es:bx],intr_70		;70中断程序的偏移地址
		mov word [es:bx+2],cs			;代码段段地址
		pop es

		;设置RTC工作状态，使它能够产生中断信号给8259中断控制器
		mov al,0x0b				;访问RTC中的寄存器B
		or al,0x80				;关NMI中断
		out 0x70,al				;通过0x70端口指定要访问的CMOS RAM内存单元
								;这里访问的就是寄存器B

		;BCD码为0001_0010
		;允许更新周期照常发生
		;禁止周期性中断，禁止闹钟功能，允许更新周期结束中断
		;使用24小时制，日期和时间采用BCD编码							
		mov al,0x12				
		out 0x71,al				;通过数据端口0x71写寄存器B

		;读取寄存器C，来检查中断原因
		mov al,0x0c				
		out 0x70,al				;访问RTC中的寄存器C，同时也打开了NMI
		in al,0x71				;通过数据端口0x71读取REG C中的内容，并自动清零

		;修改8259芯片中的IMR寄存器，允许RTC中断
		in al,0xa1			;通过0xal端口读取从片IMR寄存器
		and al,0xfe			;修改位0，位0对应IR0，0=允许中断，1=关中断
		out 0xa1,al			;再写回

		sti					;开中断

		mov bx,done_msg
		call display_string

		mov bx,tips_msg
		call display_string

		mov ax,0xb800
		mov ds,ax
		mov byte [12*160 + 33*2],'@'	;第12行33列显示字符@
	  
	.idle:
		hlt								;停机指令，进入低功耗状态，直到用中断唤醒
		not byte [12*160 + 33*2+1]      ;反转显示属性
		jmp .idle
	  
code_seg_end:

;数据段
SECTION data_seg align=16 vstart=0
    init_msg       db 'Starting...',0x0d,0x0a,0
    inst_msg       db 'Installing a new interrupt 70H...',0
    done_msg       db 'Done.',0x0d,0x0a,
    tips_msg       db 'Clock is now working.',0
data_seg_end:

;栈段
SECTION stack_seg align=16 vstart=0
	resb 256
stack_seg_end:

;追踪程序长度
SECTION program_trail
program_end:
