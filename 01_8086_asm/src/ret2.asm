assume cs:code,ss:stack

stack segment
	db 16 dup(0)
stack ends

code segment
	mov ax,4c00h
	int 21h
	
	start:mov ax,stack
		  mov ss,ax
		  mov sp,16	;指向栈顶
		  
		  mov ax,0
		  push cs
		  push ax
		  mov bx,0
		  retf	;(IP)=[(ss)*16+(sp)] (CS)=[(ss)*16+(sp)]
code ends

end start