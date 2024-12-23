;每个单词改写为大写字母
;这段汇编的难点在于如何利用已学习的知识完成双重循环
assume cs:code, ds:data

data segment
	db 'ibm             '
	db 'dec             '
	db 'dos             '
	db 'vax             '
data ends

code segment
	start:mov ax,data
		  mov ds,ax
		  
		  mov bx,0	;偏移地址
		  mov cx,4	;外层循环处理四次
		  
	   s0:mov dx,cx  ;将外层计数保存在另一个寄存器中
		  mov si,0
		  
		  mov cx,3	; // cx设置为内存循环次数
		s:mov al,[bx+si]
		  and al,11011111B
		  mov [bx+si],al
		  inc si
		  loop s
		  
		  add bx,16	;处理下一个字的数据
		  mov cx,dx ;循环前恢复外层计数
		  loop s0	;外层循环将cx计数减1
		  
		  mov ax,4c00h
		  int 21h
code ends
end start