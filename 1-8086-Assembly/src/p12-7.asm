;编写可以显示"overflow"的中断处理程序：do0Start

;思考步骤
;(1)编写中断处理程序
;(2)将do0Start送入到内存0000:0200处
;(3)将段地址0000和偏移地址0200保存到0号表项中(也就是do0Start程序的入口地址)

;有关内存的划分
;中断向量表范围: 0000:0000 - 0000:03FF, 03FF(H)=1023(D),也就是1KB大小
;每个表项占两个字，也就是4字节，高地址放段地址，低地址放偏移地址，因此1KB能放256个中断程序
;一段安全的空间范围为0000:0200-0000:02FF，DOS和其他程序一般不会使用该空间，因此可以在此处存放我们的中断程序

assume cs:codesg

codesg segment
	main:
		;(1)安装中断程序：首先考虑如何将do0Start程序复制到指定内存中去
		;方法：需要获得do0Start程序的长度，然后通过循环复制其内容
		mov ax,codesg
		mov ds,ax
		mov si,offset do0Start	;获取do0Start程序的起始地址
		
		mov ax,0
		mov es,ax
		mov di,0200H		;放入到指定的内存位置
		
		mov cx,offset do0End - offset do0Start	;设置循环次数，这里巧妙的通过标号自动计算循环次数
	s:
		mov ax,ds:[si]
		mov es:[di],ax
		inc si
		inc di
		loop s

		;(2)设置中断向量表：将中断程序的段地址和偏移地址放入到指定内存位置
		mov ax,0
		mov es,ax
		mov word ptr es:[0*4],200H
		mov word ptr es:[0*4+2],0
		
		;上面循环代码可以用更简洁的指令实现,
		;cld			cld、std指令用来操作方向标志位， cld让DF复位，cld->DF=0(内存地址增大), std->DF=1(内存地址减小)
		;rep movsb  相当于 s:movsb loop s, movsb -> (es)*16+di = (ds)*16+si, (si)=(si)+1, (di)=(di)+1
	
		mov ax,4c00H
		int 21H
	
	;(3)完善do0Start程序
	do0:
		jmp short do0Start
		db "overflow!"	;将数据放在此处，即用即取，防止被覆盖
	do0Start:
		mov ax,cs
		mov ds,ax
		mov si,202H		;指向overflow所在的字符串
		
		mov ax,0B800H
		mov es,ax
		mov di,12*160+36*2	;设置显存空间位置
		
		mov cx,9
	s2:
		mov al,[si]
		mov ah,00001010B
		mov word ptr es:[di],ax
		inc si
		add di,2
		loop s2
	
		mov ax,4c00H
		int 21H
	do0End: nop
codesg ends

end main