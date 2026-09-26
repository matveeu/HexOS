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

    ;mov si, msg
    ;call print_loop

    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 0x08:protected_mode

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

;print_loop:
;    mov ah, 0x0E
;    xor bh, bh
;.loop:
;    mov al, [si]
;    cmp al, 0
;    je .done
;    int 0x10
;    inc si
;    jmp .loop
;.done:
;    ret

; GDT
gdt_start:

gdt_null:
    dq 0

gdt_code:
    dw 0xFFFF
    dw 0
    db 0
    db 0x9A
    db 0xCF
    db 0

gdt_data:
    dw 0xFFFF
    dw 0
    db 0
    db 0x92
    db 0xCF
    db 0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start


; Protected Mode (32-bit)
[BITS 32]
protected_mode:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esp, 0x90000

    mov esi, msg_protected
    call print_string_32

    jmp $

print_string_32:
    mov edi, 0xB8000
.loop:
    mov al, [esi]
    cmp al, 0
    je .done
    mov [edi], al
    mov byte [edi+1], 0x07
    inc esi
    add edi, 2
    jmp .loop
.done:
    ret

msg db "Loading...", 0
msg_protected db "Protected mode!", 0

times 510 - ($ - $$) db 0
dw 0xAA55
