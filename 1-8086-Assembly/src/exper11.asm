;编程,将字符串中的小写字符转换成大写字符
;注意需要进行转化的是字符串中的小写字母 a~z，而不是其他字符
;这样的话需要判断每个字符是否输入小写字母区间
;查询ascii码表，得知小写字母a~z的区间是[61H,7A],并且小写字母ASCII码值比大写字母大20H
assume ds:datasg,cs:codesg

datasg segment
	db "Beginner's ALL-purpose Symbolic Insruction Code.",0
datasg ends

codesg segment
	main:
		mov ax,datasg
		mov ds,ax
		mov si,0
		
		call letterc
		
		mov ax,4c00h
		int 21h
	
	letterc:
		mov ax,0
	s0:
		mov al,ds:[si]		;取一个字节的内容到al寄存器中
		cmp al,0	;判断是不是结尾
		jcxz ok
		cmp	al,61H		;al中的值和61H比较
		jnb	c1			;不低于则转移到c1	jnb=jump not below
		jmp short s 	;低于则继续循环
	c1:
		cmp al,7AH		;al中的值和7A比较
		jna	c2			;不高于则转移到c2	jna=jump not above
		jmp short s 	;高于也继续循环
	c2:
		and al,11011111B	;将 a1 中的 ASCII 码的第5位置为 0，变为大写字母
		mov [si],al			;写回到原内存单元
	s:
		inc si
		loop s0
	ok: ret
codesg ends

end main