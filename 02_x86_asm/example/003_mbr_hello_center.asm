[org 0x7c00]
xor ax, ax
mov ds, ax          ; DS = 0（数据段）
mov es, ax          ; ES 临时用

; 计算屏幕中间位置：12行40列
; 位置 = 12 * 80 + 40 = 1000
mov cx, 1000      ; CX存储起始位置值

; 计算字符串长度并加到起始位置上
mov si, message   ; SI指向消息的起始地址
add cx, message_end - message  ; 起始位置 + 字符串长度 = 结束位置

; 设置光标位置到字符串末尾的下一个位置
mov dx, 0x3D4     ; 索引端口
mov al, 0x0E      ; 选择光标位置高位寄存器
out dx, al
mov dx, 0x3D5     ; 数据端口
mov al, ch        ; 获取CX的高8位
out dx, al

mov dx, 0x3D4     ; 索引端口
mov al, 0x0F      ; 选择光标位置低位寄存器
out dx, al
mov dx, 0x3D5     ; 数据端口
mov al, cl        ; 获取CX的低8位
out dx, al

; 设置 ES:DI 指向显存 (0xB800:2000)
mov ax, 0xB800
mov es, ax
mov di, 2000        ; 1000 * 2 = 2000

; 打印字符串
mov cx, message_end - message
mov ah, 0x07        ; 黑底白字

print_loop:
    mov al, [si]    ; 字符
    mov [es:di], ax ; 写入字符+属性
    add si, 1       ; SI++
    add di, 2       ; DI += 2
    loop print_loop

done:
    jmp $

message:
    db 'Hello world'
message_end:

times 510-($-$$) db 0
dw 0xAA55           ; 引导扇区签名