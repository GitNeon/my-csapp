;微型内核程序
;内核负责加载用户程序，并提供各种例程给用户程序调用

;段选择子，以常数形式给出，常数不占用汇编地址
core_code_seg_sel     equ  0x38    ;内核代码段选择子
core_data_seg_sel     equ  0x30    ;内核数据段选择子 
core_api_seg_sel      equ  0x28    ;系统公共例程代码段的选择子 
video_ram_seg_sel     equ  0x20    ;视频显示缓冲区的段选择子
core_stack_seg_sel    equ  0x18    ;内核堆栈段选择子
mem_0_4_gb_seg_sel    equ  0x08    ;整个0-4GB内存的段的选择子

;内核头部段
section core_header vstart=0
	core_length			dd core_trail_end				;[0x00] 内核总长度
	core_api_seg		dd section.core_api.start		;[0x04] 内核api例程代码段位置，起始汇编地址
	core_data_seg		dd section.core_data.start		;[0x08] 内核数据段位置
	core_code_seg		dd section.core_code.start		;[0x0c]	内核代码段位置
	core_entry			dd start						;[0x10] 内核入口，偏移地址
						dw core_code_seg_sel			;内核入口段选择子，通过它来找到段描述符中的段基址
core_header_end:

;公共API例程段，提供给用户程序调用
section core_api vstart=0
core_api_end:

;内核数据段
section core_data vstart=0
core_data_end:

;内核代码段
section core_code vstart=0
start:
	
core_code_end:

;尾部,用于计算内核长度
section core_trail
core_trail_end:
