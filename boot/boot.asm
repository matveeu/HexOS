[BITS 16]
[ORG 0x7C00]

start:
    mov ax, 0x1000
    mov es, ax
    mov bx, 0x0000

    mov ah, 0x02
    mov al, 0x01

    mov ch, 0x00
    mov dh, 0x00
    mov cl, 0x02

    int 0x13

    jmp 0x1000:0x0000

times 510-($-$$) db 0
dw 0xAA55
