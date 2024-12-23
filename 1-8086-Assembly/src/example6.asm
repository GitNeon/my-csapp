assume cs:code,ds:a,ss:b

a segment
	dw 1,2,3,4,5,6,7,8,9,0aH,0bH,0cH,0dH,0eH,0fH,0ffH
a ends

b segment
	dw 0,0,0,0,0,0,0
b ends

code segment
	start: 
		mov ax,b
		mov ss,ax
		mov sp,10H	;由于逆序需要出栈，sp 最高位是 f ，栈底为 f+1
		
		mov ax,a
		mov ds,ax	;数据段的段地址放入ds寄存器中
		
		mov cx,8
		mov bx,0
	  s:push ds:[bx] ;特别需要注意的是，8086CPU push数据由高位向低位增长
		add bx,2	;push、pop指令一次操作一个字型数据，因此+2
		loop s
		
		
		mov ax,4c00h
		int 21h
code ends
end start