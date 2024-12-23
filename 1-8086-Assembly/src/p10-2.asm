assume cs:code,ss:stack,ds:data

data segment
	dd 1000000
	dw 10
data ends

stack segment
	db 16 dup(0)
stack ends

code segment
	main:
		mov ax,data
		mov ds,ax
code ends

end main