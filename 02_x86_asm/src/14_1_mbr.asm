;存储器的保护
;硬盘主引导程序

	;设置栈段
	mov eax,cs
	mov ss,eax
	mov sp,0x7c00

	;GDT物理内存地址转换成逻辑段地址
	mov eax,[cs:0x7c00 + pgdt + 0x02]
	sub edx,edx								;32位除法，edx:eax存放被除数，ebx存放除数
	mov ebx,16
	div ebx									;EAX=商=段地址，EDX=余数=偏移地址。由于是在实模式下，所以仅低16位有效
	mov ds,eax			;DS寄存器指向该段
	mov ebx,edx			;ebx存放段内起始偏移地址

	;以下安装多个段描述
	;安装索引为0的描述符
	mov dword [ebx+0x00],0x00000000
	mov dword [ebx+0x04],0x00000000

	;安装索引为1的描述符，类型：数据段，基址：0x00000000，界限：0xFFFFF，粒度：4KB
	mov dword [ebx+0x08],0x0000ffff		;描述符低32位
	mov dword [ebx+0x0c],0x00cf9200		;描述符高32位，二进制为0000_0000_1100_1111_1001_0010_0000_0000，参考书中图12-4

	;安装索引为2的描述符，类型；代码段，基址：0x00007c00，界限：0x001FF，粒度：字节
	mov dword [ebx+0x10],0x7c0001ff
	mov dword [ebx+0x14],0x00409800

	;描述符#3，类型：数据段，基址：0x00007c00，界限：0x001FF，粒度：字节
	;别名描述符；指向同一个段
	mov dword [ebx+0x18],0x7c0001ff
	mov dword [ebx+0x1c],0x00409200

	;描述符#4，类型：栈段，基址：0x00007c00，界限：FFFFE，粒度：4KB
	mov dword [ebx+0x20],0x7c00fffe
	mov dword [ebx+0x24],0x00cf9600

	;写入GDT的界限值
	;5个描述符 × 每个描述符8字节 = 40， 即0~39
	mov word [cs:pgdt+0x7c00],39

	;载入全局描述符表，此时GDTR中保存的就是全局描述符表的界限和基址
	lgdt [cs:pgdt+0x7c00]

	;打开A20
	;打开 A20 地址线后，CPU 可以正常使用 20 位及以上的地址线进行寻址，从而突破 1MB 的内存限制，访问更大的内存空间
	in al,0x92
	or al,0000_0010B
	out 0x92,al

	;关中断
	cli
	
	;设置PE为
	mov eax,cr0
	or eax,1
	mov cr0,eax
	
	 ;以下进入保护模式... ...
	jmp 0x0010:dword flush             ;16位的描述符选择子：32位偏移

	[bits 32]                          
flush:                                     
	mov eax,0x0018                      
	mov ds,eax

	mov eax,0x0008                     ;加载数据段(0..4GB)选择子
	mov es,eax
	mov fs,eax
	mov gs,eax

	mov eax,0x0020                     ;0000 0000 0010 0000
	mov ss,eax
	xor esp,esp                        ;ESP <- 0

	mov dword [es:0x0b8000],0x072e0750 ;字符'P'、'.'及其显示属性
	mov dword [es:0x0b8004],0x072e074d ;字符'M'、'.'及其显示属性
	mov dword [es:0x0b8008],0x07200720 ;两个空白字符及其显示属性
	mov dword [es:0x0b800c],0x076b076f ;字符'o'、'k'及其显示属性

	;开始冒泡排序 
	mov ecx,pgdt-string-1              ;遍历次数=串长度-1 
@@1:
	push ecx                           ;32位模式下的loop使用ecx 
	xor bx,bx                          ;32位模式下，偏移量可以是16位，也可以 
@@2:                                      ;是后面的32位 
	mov ax,[string+bx] 
	cmp ah,al                          ;ah中存放的是源字的高字节 
	jge @@3 
	xchg al,ah 
	mov [string+bx],ax 
@@3:
	inc bx 
	loop @@2 
	pop ecx 
	loop @@1

	mov ecx,pgdt-string
	xor ebx,ebx                        ;偏移地址是32位的情况 
@@4:                                      ;32位的偏移具有更大的灵活性
	mov ah,0x07
	mov al,[string+ebx]
	mov [es:0xb80a0+ebx*2],ax          ;演示0~4GB寻址。
	inc ebx
	loop @@4

	hlt 


string	db 's0ke4or92xap3fv8giuzjcy5l1m7hd6bnqtw'
pgdt	dw 0
		dd 0x00007e00
		
times 510-($-$$)	db 0
					dw 0xaa55