;加载器所要加载的用户程序

SECTION header vstart=0				;用户程序加载头部

SECTION code_1 align=16 vstart=0	;定义为代码段1

SECTION code_2 align=16 vstart=0	;定义为代码段2

SECTION data_1 align=16 vstart=0	;定义为数据段1

SECTION data_2 align=16 vstart=0	;定义为数据段2

SECTION stack align=16 vstart=0		;定义为栈段

program_end:						;空标记,程序结束位置