;用 si 和 di 实现将字符串'welcome to masm!'复制到它后面的数据区中
assume cs:code, ds:data

data segment
	db 'welcome to masm!'	;16位,2字节
	db '................'	;预留的占位空间
data ends

code segment
	start:mov ax,data
		  mov ds,ax
		  
		  mov si,0	;从0开始
		  mov di,16	;从16位置结束
		  
		  mov cx,8	;循环八次
		s:mov dx,[si]	;取出数据
		  mov [di],dx	;放入数据
		  add si,2
		  add di,2		;移动地址位置，依次处理， si,di为16位寄存器，一次复制2个字节
		  loop s
		  
		  mov ax,4c00h
		  int 21h
code ends
end start