[BITS 16]
[ORG 0x7C00]

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov si, msg
    call serial_print_string

    mov si, msg
    call print_loop

    jmp $

serial_print_char:
    push ax
    mov ah, al
.wait:
    mov dx, 0x3FD
    in al, dx
    test al, 0x20
    jz .wait

    mov al, ah
    mov dx, 0x3F8
    out dx, al
    pop ax
    ret

serial_print_string:
.loop:
    mov al, [si]
    cmp al, 0
    je .done
    call serial_print_char
    inc si
    jmp .loop
.done:
    ret

print_loop:
    mov ah, 0x0E
    xor bh, bh
.loop:
    mov al, [si]
    cmp al, 0
    je .done
    int 0x10
    inc si
    jmp .loop
.done:
    ret

msg db "Hello, HexOS", 0

times 510 - ($ - $$) db 0
dw 0xAA55
