assume cs:codeseg

codeseg segment

	mov ax,0
	mov ds,ax
	mov bx,200H
	
	mov cx,64
  s:mov [bx],ax
	inc bx
	inc ax
	loop s
	
	mov ax,4c00h
	int 21h
	
codeseg ends

end