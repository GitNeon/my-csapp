assume cs:code, ds:data,ss:stack

data segment
	dw 0123H,0456H,0789H,0abcH,0defH,0fedH,0cbaH,0987H	;定义8个字的数据，一个字2个字节，共16字节
data ends

stack segment
	dw 0,0,0,0,0,0,0,0 ;定义8个字的空间，方便后续使用
stack ends

code segment
	start: mov ax,stack
		   mov ss,ax
		   mov sp,16	;初始化栈段寄存器段地址，以及栈顶指针位置(因为已经用了16个单元的位置，所以从16开始)
		   
		   mov ax,data
		   mov ds,ax	;初始化数据段寄存器初始位置
		   
		   push ds:[0]	;将ds:[0]处数据入栈
		   push ds:[2]	;将ds:[2]处数据入栈
		   pop 	ds:[2]	;相反，进行出栈
		   pop 	ds:[0]
		   
		   mov ax,4c00h
		   int 21h
code ends
end start