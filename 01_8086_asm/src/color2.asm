;实验9-实现屏幕中间显示三行welcome to wasm,并且颜色不同!
;向B800:0000H - B800:FFFFH处写入数据，可显示彩色数据
;第一行显示绿色
;第二行显示绿底红色
;第三行显示白底蓝色
assume cs:code,ds:data,ss:stack

data segment
	db 'welcome to wasm!'
	db 00001010B,00101100B,011100001B
data ends 

stack segment
	dw 0
stack ends

code segment
	start:	mov ax,data
			mov ds,ax
			
			mov si,0	;列索引
			mov bx,0	;行索引
			mov bp,0
			
			mov ax,0B800H
			mov es,ax		;保存彩色空间地址
			mov di,0720H 	;目标索引 80*11*2+32*2
			
			;外循环控制写几次字符串
			mov cx,3
		s0: push cx		;压栈保存外循环次数
			
			;内循环控制逐个读取字符
			mov cx,16
			mov ah,[bp+16]	;高位字节存储字符属性
		s1:	mov al,ds:[bx+si]	;低位字节存储字符本身
			mov word ptr es:[di],ax	;存储完整的一个字
			inc si
			add di,2
			loop s1
		
			pop cx		;外层循环出栈
			mov bx,0
			mov si,0	;重置索引
			inc bp
			
			add di,128	; 160也就是2行 - 16*2(每个字符占2个字节)
			loop s0
			
			mov ax,4c00H
			int 21H
code ends

end start