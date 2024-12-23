;div溢出

assume cs:codesg

codesg segment
	mov ax,1000H
	mov bh,1
	div bh
	
	mov ax,4c00h
	int 21h
codesg ends

end