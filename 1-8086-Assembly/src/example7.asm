;将 datasg 中的第一个定义的字符串转化为大写;第二个定义的字符串转化为小写
assume cs:code,	ds:data

data segment
	db 'BaSiC'
	db 'iNfOrMaTiOn'
data ends

code segment
	start:mov ax,data
		  mov ds,ax
		  mov bx,0
		  
		  mov cx,5
		s:mov al,[bx] ;将ASCII码从ds:bx所指向的内存单元中取出
		  and al,11011111B	;利用and操作改变大小写
		  mov [bx],al	;再写回原内存单元
		  inc bx	;指向下一个字母
		  loop s
		  
		  mov cx,11
		  mov bx,5
	   s0:mov al,[bx]
		  or al,00100000B
		  mov [bx],al
		  inc bx
		  loop s0
		  
		  mov ax,4c00h
		  int 21h
code ends

end start