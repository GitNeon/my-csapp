mov ax,0xb800
mov ds,ax

mov byte [0x00], 'L'
mov byte [0x02], 'a'
mov byte [0x04], 'b'
mov byte [0x06], 'e'
mov byte [0x08], 'l'
mov byte [0x0a], ' '
mov byte [0x0c], 'o'
mov byte [0x0e], 'f'
mov byte [0x10], 'f'
mov byte [0x12], 's'
mov byte [0x14], 'e'
mov byte [0x16], 't'
mov byte [0x18], ':'

jmp $

; 填充空白字节
times 510-($-$$) db 0
dw 0aa55H
