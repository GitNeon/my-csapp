;编程,统计 data 段中数值为8的字节的个数，用ax保存统计结果
;提示，用到cmp和je(或jne) je=jump equal jne=jump not equal
assume ds:data,cs:codesg

data segment
	db 8,11,8,1,8,5,63,38
data ends

codesg segment
	main:
		mov ax,data
		mov ds,ax
		
		mov ax,0	;初始化结果为0
		mov cx,8	;循环8次处理
		mov bx,0	;起始地址从0开始
	
	s:	
		cmp byte ptr [bx],8		;取一个字节的内存单元内容，和8比较
		je ok
		jmp short next
	
	ok:
		inc ax	;	相等ax+1
	
	next:
		inc bx
		loop s
codesg ends

end main