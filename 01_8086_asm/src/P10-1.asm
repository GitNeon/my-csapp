;王爽-汇编语言，实验10-1
;提供一个子程序，使调用者能够决定显示的位置(行、列、颜色、内容)
;向B800:0000H - B800:FFFFH处写入数据，可显示彩色数据

;ah高位字节存储字符属性
;al低位字节存储字符本身

;显示器一屏可以显示25行，每行80个字符(一个字符占2个字节)
;由此可以算出第一个字符的偏移地址应该是(80*行数*2 + 列数*2)
assume cs:code,ds:data,ss:stack

data segment
	db 'Welcome to masm!',0
data ends

stack segment
	db 16 dup(0)
stack ends

code segment
	main:
		mov dh,8	;第8行
		mov dl,3	;第3列
		mov cl,2	;颜色
		
		mov ax,data
		mov ds,ax
		mov si,0	;数据空间
		
		mov ax,stack
		mov ss,ax	;栈空间
	
		call show_str
		
		mov ax,4c00H
		int 21H
	show_str:
		push cx						;用栈保存外部cx中的值
		mov ax,0B800H
		mov es,ax
		mov di,0	;要写入的目标地址空间
		
		mov ax,00A0h
		mul dh		;计算首字母要显示的偏移量,A0=160,一行160字节,mul dh --> (ax) = (al)*(dh) = 160*8
		mov dh,0	;高位置为0，此时dx=0003
		add ax,dx
		add ax,dx	;3列，也就是3个字符*2(1个字符占2字节)
		mov bx,ax
		
		mov ah,cl			;字符属性
	change_str:
		mov cl,[si]
		mov ch,0					;用于判断是否为字符串末尾
		jcxz ok
		mov al,ds:[si]				;当前内存单元对应的字符
		mov word ptr es:[di+bx],ax		;存储完整的一个字
		inc si
		add di,2
		jmp short change_str
	ok: pop cx
		ret
code ends

end main