;每个单词改写为大写字母
;改进版,利用栈完成数据的操作
assume cs:code, ds:data, ss:stack

data segment
	db 'ibm             '
	db 'dec             '
	db 'dos             '
	db 'vax             '
data ends

stack segment
	dw 0,0,0,0,0,0,0,0
stack ends

code segment
		  ;数据段处理
	start:mov ax,data
		  mov ds,ax
		  mov bx,0
		  
		  ;栈段处理
		  mov ax,stack
		  mov ss,ax
		  mov sp,16
		  
		  mov cx,4	;外层循环处理四次
		  
	   s0:push cx	;将外层循环次数压栈，以临时存储
		  mov si,0
		  ;内层循环处理每行的每个字母
		  mov cx,3	; // cx设置为内存循环次数
		s:mov al,[bx+si]
		  and al,11011111B
		  mov [bx+si],al
		  inc si
		  loop s
		  
		  add bx,16	;处理下一个字的数据
		  pop cx	;恢复cx值
		  loop s0	;外层循环将cx计数减1
		  
		  mov ax,4c00h
		  int 21h
code ends
end start