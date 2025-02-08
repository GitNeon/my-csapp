;王爽汇编-实验7
assume cs:code,ss:stack,es:table,ds:data

data segment
	db '1975','1976','1977','1978','1979','1980','1981','1982','1983','1984'
	db '1985','1986','1987','1988','1989','1990','1991','1992','1993','1994','1995'
	
	dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
	dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
	
	dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
	dw 11542,14430,15257,17800
data ends

stack segment
	db 0
stack ends

table segment
	db 21 dup ('year summ ne ??')
table ends

code segment
	start:
		;设置数据段
		mov ax,data
		mov ds,ax
		
		;设置栈段
		mov ax,stack
		mov ss,ax
		mov sp,10H	;当栈为空时，栈顶=栈底，且指针指向下一个内存单元
		
		;设置附加段
		add ax,01H
		mov es,ax
		
		mov bx,0	;表示行号，每处理一行数据，应当+10H(一行16个字节数据)
		mov di,0	;目标地址索引，这个是累加的
		mov cx,21	;外层循环
		
		mov si,0	;每次循环的索引(0，1，2，3，对应年份长度)		
		s1:
			push cx		;保存外层循环次数
			mov cx,4	;内存循环4次

			s2:
				mov al,ds:[di]
				mov es:[bx+si],al
				inc si
				inc di
				loop s2
			add bx,10H
			pop cx
			loop s1

		mov ax,4c00H
		int 21H
code ends

end start