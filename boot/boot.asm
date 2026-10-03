[BITS 16]
[ORG 0x7C00]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x9000

    mov [boot_drive], dl

    ; sector 1 - boot
    ; sector 2 - kernel

    mov ax, 0x1000
    mov es, ax
    xor bx, bx

    mov ah, 0x02 ; BIOS read sectors
    mov al, 0x05 ; 5 sectors
    mov ch, 0x00 ; cylinder 0
    mov dh, 0x00 ; head 0
    mov cl, 0x02 ; 2nd sector
    mov dl, [boot_drive]
    int 0x13

    jc disk_error

    ; enter protected mode

    cli
    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 0x08:protected_mode
disk_error:
    mov si, error_msg
.print:
    lodsb
    test al, al
    jz .hang

    mov ah, 0x0E
    int 0x10

    jmp .print
.hang:
    cli
    hlt
    jmp .hang

; 32-bit protected mode
[BITS 32]

protected_mode:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esp, 0x90000

    cld

    jmp 0x08:0x10000

; GDT
gdt_start:
    dq 0

gdt_code:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x9A
    db 0xCF
    db 0x00

gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x92
    db 0xCF
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

boot_drive db 0
error_msg db "Disk error!", 0

times 510-($-$$) db 0
dw 0xAA55
