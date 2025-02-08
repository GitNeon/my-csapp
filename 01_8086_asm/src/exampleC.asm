assume cs:code,ds:data

data segment
	db 'DEC'
	db 'Ken Olsen'
	db '37'
	db '40'
	db 'PDP'
data ends

code segment
	start:mov ax,data
		  mov ds,ax
		  mov bx,0
	
		  mov word ptr ds:[bx],30	;操作一个字，137改为38
	
	      mov ax,4c00h
	      int 21h
code ends

end start

