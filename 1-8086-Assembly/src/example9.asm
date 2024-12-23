; 将 datasg 段中每个单词的头一个字母改为大写字母
assume cs:code,ds:data

data segment
	db '1. file         '
	db '2. edit         '
	db '3. search       '
	db '4. view         '
	db '5. options      '
	db '6. help         '
data ends

code segment
	start:mov ax,data
		  mov ds,ax
		  
		  mov cx,6	;需要循环处理6次
		  mov bx,0
		s:mov al,[bx+3]	;取出当前内存单元的数据，对应第一个英文字母
		  and al,11011111B	;
		  mov [bx+3],al	;将改变后的值放入原来内存单元位置
		  add bx,16	;处理下一个字
		  loop s
		  
		  mov ax,4c00h
		  int 21h
code ends
end start