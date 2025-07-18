[org 0x7C00]
[bits 16]

; 主引导记录入口
start:
    jmp 0x0000:real_mode_init  ; 确保CS=0

real_mode_init:
    ; 初始化段寄存器
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; 打印实模式提示
    mov si, msg_real_mode
    call print_16

    ; 加载GDT并切换到保护模式
    lgdt [gdtr]
    mov si, msg_gdt_loaded
    call print_16

    ; 关闭中断
    cli

    ; 启用保护模式
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    mov si, msg_protected_mode
    call print_16

    ; 远跳转清空流水线
    jmp 0x08:protected_mode_entry

; 16位实模式打印函数
print_16:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_16
.done:
    ret

[bits 32]
protected_mode_entry:
    ; 设置保护模式段寄存器
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x7C00

    ; 打印保护模式提示
    mov esi, msg_32bit_mode
    call print_32

    ; 检查是否支持长模式
    mov eax, 0x80000001
    cpuid
    test edx, (1 << 29)
    jz no_long_mode

    ; 初始化页表
    call setup_paging
    mov esi, msg_paging_ready
    call print_32

    ; 启用PAE
    mov eax, cr4
    or eax, (1 << 5)
    mov cr4, eax
    mov esi, msg_pae_enabled
    call print_32

    ; 设置EFER.LME
    mov ecx, 0xC0000080
    rdmsr
    or eax, (1 << 8)
    wrmsr
    mov esi, msg_lme_enabled
    call print_32

    ; 启用分页
    mov eax, cr0
    or eax, (1 << 31)
    mov cr0, eax
    mov esi, msg_paging_enabled
    call print_32

    ; 跳转到64位模式
    jmp 0x08:long_mode_entry

; 32位保护模式打印函数
print_32:
    mov edx, 0xB8000  ; 文本模式显存地址
.loop:
    lodsb
    or al, al
    jz .done
    mov [edx], al
    add edx, 2
    jmp .loop
.done:
    ret

; 页表初始化（恒等映射低1GB + 高端映射）
setup_paging:
    ; 清零页表区域（0x1000-0x6000）
    mov edi, 0x1000
    mov ecx, (0x6000 - 0x1000) / 4
    xor eax, eax
    rep stosd

    ; 设置PML4（0x1000）
    mov edi, 0x1000
    lea eax, [edi + 0x1000]  ; 指向PDP
    or eax, 0b11             ; Present + Writable
    mov [edi], eax           ; PML4[0]
    mov [edi + 256 * 8], eax ; PML4[256]（映射到0xFFFF800000000000）

    ; 设置PDP（0x2000）
    mov edi, 0x2000
    lea eax, [edi + 0x1000]  ; 指向PD
    or eax, 0b11
    mov [edi], eax

    ; 设置PD（0x3000，2MB大页）
    mov edi, 0x3000
    mov eax, 0x00000083      ; Present + Writable + 2MB页
    mov ecx, 512             ; 映射1GB
.fill_pd:
    mov [edi], eax
    add eax, 0x200000
    add edi, 8
    loop .fill_pd

    ; 设置CR3
    mov eax, 0x1000
    mov cr3, eax
    ret

[bits 64]
long_mode_entry:
    ; 设置64位段寄存器
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov rsp, 0x7C00

    ; 打印64位模式提示
    mov rsi, msg_64bit_mode
    call print_64

    ; 在此添加内核加载代码...
    jmp $

; 64位模式打印函数
print_64:
    mov rbx, 0xB8000
.loop:
    lodsb
    or al, al
    jz .done
    mov [rbx], al
    add rbx, 2
    jmp .loop
.done:
    ret

no_long_mode:
    mov esi, msg_no_long_mode
    call print_32
    jmp $

; 数据区
msg_real_mode        db "[16-bit] Real Mode", 0
msg_gdt_loaded       db "[16-bit] GDT Loaded", 0
msg_protected_mode   db "[16-bit] Protected Mode Enabled", 0
msg_32bit_mode       db "[32-bit] Protected Mode Active", 0
msg_paging_ready     db "[32-bit] 4-Level Paging Ready", 0
msg_pae_enabled      db "[32-bit] PAE Enabled", 0
msg_lme_enabled      db "[32-bit] EFER.LME Set", 0
msg_paging_enabled   db "[32-bit] Paging Enabled", 0
msg_64bit_mode       db "[64-bit] Long Mode Active", 0
msg_no_long_mode     db "[ERROR] CPU不支持长模式", 0

; GDT定义
align 8
gdtr:
    dw gdt_end - gdt - 1
    dd gdt

gdt:
    dq 0x0000000000000000  ; 空描述符
    dq 0x00CF9A000000FFFF  ; 代码段（32/64位）
    dq 0x00CF92000000FFFF  ; 数据段
gdt_end:

; 填充MBR
times 510 - ($ - $$) db 0
dw 0xAA55