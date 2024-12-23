;编程，计算 data 段中第一组数据的 3 次方，结果保存在后面一组 dword 单元中
assume cs:code,ds:data

data segment
	dw 1,2,3,4,5,6,7,8
	dd 0,0,0,0,0,0,0,0
data ends

code segment
	main:
		mov ax,data
		mov ds,ax
		
		mov si,0	;ds:[si]指向第一组word单元
		mov di,16	;ds:[di]指向第二组dword单元
		
		mov cx,8
	forEach:
		mov bx,[si]
		call cube
		mov [di],ax		;放低16位
		mov [di+2],dx	;放高16位
		add si,2
		add di,4
		loop forEach
		
		mov ax,4c00h
		int 21h
		
	cube:
		mov ax,bx
		mul bx
		mul bx
		ret
code ends

end main