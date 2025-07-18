[bits 16]                ; 16位实模式
[org 0x7C00]             ; BIOS 加载到 0x7C00

jmp start

; --------------------------
; GDT（全局描述符表）
; --------------------------
gdt_start:
    ; 第一个描述符必须是 NULL 描述符（GDT 规范）
    dd 0x00000000        ; 基址=0, 界限=0
    dd 0x00000000

    ; 代码段描述符（可执行、可读、32位）
gdt_code:
    dw 0xFFFF            ; 段界限 (0-15)
    dw 0x0000            ; 基址 (0-15)
    db 0x00              ; 基址 (16-23)
    db 0b10011010        ; P=1, DPL=0, S=1, Type=1010 (代码段，可读)
    db 0b11001111        ; G=1 (4KB粒度), D/B=1 (32位), AVL=0, 段界限 (16-19)
    db 0x00              ; 基址 (24-31)

    ; 数据段描述符（可读、可写、32位）
gdt_data:
    dw 0xFFFF            ; 段界限 (0-15)
    dw 0x0000            ; 基址 (0-15)
    db 0x00              ; 基址 (16-23)
    db 0b10010010        ; P=1, DPL=0, S=1, Type=0010 (数据段，可写)
    db 0b11001111        ; G=1, D/B=1, AVL=0, 段界限 (16-19)
    db 0x00              ; 基址 (24-31)

    ; 栈段描述符（可读、可写、32位）
gdt_stack:
    dw 0xFFFF            ; 段界限 (0-15)
    dw 0x0000            ; 基址 (0-15)
    db 0x00              ; 基址 (16-23)
    db 0b10010010        ; P=1, DPL=0, S=1, Type=0010 (数据段，可写)
    db 0b11001111        ; G=1, D/B=1, AVL=0, 段界限 (16-19)
    db 0x00              ; 基址 (24-31)

gdt_end:

; --------------------------
; GDT 描述符（用于 lgdt 指令）
; --------------------------
gdt_descriptor:
    dw gdt_end - gdt_start - 1    ; GDT 大小（16位）
    dd gdt_start                  ; GDT 基址（32位）

; 定义段选择子（Selector）
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
STACK_SEG equ gdt_stack - gdt_start

; --------------------------
; 主程序（从实模式切换到保护模式）
; --------------------------
start:
    ; 初始化段寄存器
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00      ; 栈指针初始化

    ; 1. 禁用中断（防止模式切换时发生中断）
    cli

    ; 2. 加载 GDT
    lgdt [gdt_descriptor]

    ; 3. 打开 A20 地址线（Fast A20 方法）
    in al, 0x92
    or al, 0x02
    out 0x92, al

    ; 4. 设置 CR0.PE 位，进入保护模式
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    ; 5. 远跳转（刷新流水线，更新 CS）
    jmp CODE_SEG:protected_mode

; --------------------------
; 32位保护模式代码
; --------------------------
[bits 32]
protected_mode:
    ; 初始化段寄存器
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x7C00      ; 32位栈指针

    ; 保护模式下打印消息（示例：向屏幕输出字符）
    mov esi, msg
    mov edi, 0xB8000     ; 显存地址（文本模式）
    mov ah, 0x0F         ; 白字黑底

.print_char:
    lodsb                ; 加载字符到 AL
    test al, al
    jz .done             ; 如果遇到 0，结束
    mov [edi], ax        ; 写入显存
    add edi, 2
    jmp .print_char

.done:
    cli
    hlt                  ; 停机

msg db "Hello, Protected Mode!", 0

; --------------------------
; 填充引导扇区
; --------------------------
times 510 - ($ - $$) db 0
dw 0xAA55                ; 引导扇区标志