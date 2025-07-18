; hello_asm.asm - 16位汇编程序，通过直接写显存显示"Hello world"
[org 0x7c00]      ; 程序加载到 0x7c00
xor ax, ax        ; AX = 0
mov ds, ax        ; DS = 0（数据段）
mov ax, 0xb800    ; 显存段
mov es, ax        ; ES = 0xb800
mov si, message   ; SI -> 字符串
mov di, 0         ; DI -> 显存位置
mov cx, message_end - message  ; CX = 字符串长度

print_loop:
    mov al, [si]      ; 字符 -> AL
    mov ah, 0x07      ; 属性（黑底白字）-> AH
    mov [es:di], ax   ; 写入显存（ES:DI）
    add si, 1         ; SI++
    add di, 2         ; DI += 2
    loop print_loop

done:
    jmp $             ; 无限循环

message:
    db 'Hello world'
message_end:

times 510-($-$$) db 0
dw 0xAA55           ; 引导扇区签名