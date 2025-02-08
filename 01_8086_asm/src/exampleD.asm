assume cs:code,ds:data

data segment
	dd 100001
	dw 100
	dw 0
data ends

code segment
	start:mov ax,data
		  mov ds,ax
		  mov ax,ds:[0]	;低16位放入ax中
		  mov dx,ds:[2]	;高16位放入dx中
		  div word ptr ds:[4] ;除以这个内存单元中的字数据 [(dx)*10000H + (ax)] / [(ds)*16 + 4]
		  mov ds:[6],ax
		  
		  mov ax,4c00H
		  int 21H
code ends

end start