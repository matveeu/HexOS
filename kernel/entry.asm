[ORG 0x0000]

start:
    push cs
    pop ds

    call clear_screen

    mov ax, 0xb800
    mov es, ax

    mov si, msg1
    call print_string

    mov si, msg2
    call print_string

    jmp $

clear_screen:
    mov ax, 0xb800
    mov es, ax

    xor di, di
.loop:
    mov byte [es:di], ' '
    mov byte [es:di+1], 0x07

    add di, 2

    cmp di, 4000
    jl .loop

    mov word [cursor_x], 0
    mov word [cursor_y], 0

    ret

get_video_offset:
    mov ax, [cursor_y]
    mov bx, 80
    mul bx

    add ax, [cursor_x]

    shl ax, 1

    mov di, ax
    ret

print_char:
    push ax

    call get_video_offset

    pop ax

    mov [es:di], al
    mov byte [es:di+1], 0x07

    inc word [cursor_x]

    cmp word [cursor_x], 80
    jl .done

    call newline
.done:
    ret

newline:
    mov word [cursor_x], 0
    inc word [cursor_y]
    ret

print_string:
.next:
    lodsb

    cmp al, 0 ; end of string
    je .done

    cmp al, 10 ; \n - 0x0A = 10
    je .newline

    call print_char

    jmp .next

.newline:
    call newline
    jmp .next

.done:
    ret

msg1 db 'HexOS booting...', 10, '', 10, 0
msg2 db 'Memory: OK', 10, 'Disk: OK', 10, 0

cursor_x dw 0 ; 0-79
cursor_y dw 0 ; 0-24
