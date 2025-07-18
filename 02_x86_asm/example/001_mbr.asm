; 简单的主引导扇区(MBR)示例
; 编译命令: nasm -f bin mbr.asm -o mbr.bin

org 0x7C00                  ; BIOS将MBR加载到0x7C00处

start:
    ; 初始化段寄存器
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00          ; 设置堆栈指针

    ; 清屏
    mov ax, 0x0600          ; AH=06(滚动), AL=00(全窗口)
    mov bh, 0x07            ; 属性(黑底白字)
    mov cx, 0x0000          ; 左上角(0,0)
    mov dx, 0x184F          ; 右下角(24,79)
    int 0x10

    ; 设置光标位置
    mov ah, 0x02            ; AH=02(设置光标)
    mov bh, 0x00            ; 页号0
    mov dx, 0x0000          ; DH=行, DL=列
    int 0x10

    ; 显示消息
    mov si, msg
    call print_string

    ; 无限循环
    jmp $

; 打印字符串函数
; 输入: SI=字符串地址
print_string:
    lodsb                   ; 加载AL中的下一个字符
    or al, al               ; AL=0?
    jz .done                ; 如果是，则完成
    mov ah, 0x0E            ; BIOS tele-type输出
    mov bh, 0x00            ; 页号0
    int 0x10
    jmp print_string
.done:
    ret

; 数据
msg db "Hello from MBR!", 0x0D, 0x0A, 0

; 填充剩余空间并添加引导签名
times 510-($-$$) db 0
dw 0xAA55                   ; 引导扇区签名