;实验9-例子练习
;在0行0列处(B800:0000-009F)显示字符串ABCDEF,并设置黑底绿色
assume cs:code,ds:data

data segment
    db 'ABCDEF'
data ends

code segment
	start:mov ax,data
		  mov ds,ax
		  mov bx,0	;行号,不过这个需求处理第一行即可
		  mov si,0	;索引
		  mov di,0
		  
		  mov ax,0B800H
		  mov es,ax		;向此内存段写入数据，字符带有颜色
		  
		  mov ax,0
		  mov ah,00001010B	;高地址存放字符属性
		  mov cx,6
		s:mov al,ds:[bx+si] ;低地址存放字符本身
		  mov word ptr es:[di],ax
		  inc si
		  add di,2
		  loop s
		  
		  mov ax,4c00h
		  int 21h
code ends

end start