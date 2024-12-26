;显示彩色的Label offset:
jmp near start

showText db 'L','a','b','e','l',' ','o','f','f','s','e','t',':'

start:	mov ax,0xb800
		mov es,ax			;显示缓冲区所在段地址

		mov bx,0x7c00		;主引导程序是在内存0x0000:0x7c00处开始加载的,因此一定不要忘记加上这个地址

		mov cx,start - showText			;获得循环次数
		mov si,showText
		mov di,0

loopstr:mov byte al, [bx+si]		;先取得原有字符
		mov byte ah, 0x17			;设置颜色格式,蓝底白字
		mov [es:di],ax				;复制单个字符到显示缓冲区
		inc si
		add di,2
		loop loopstr

	
jmp near $

times 510-($-$$) db 0
db 0x55,0xaa