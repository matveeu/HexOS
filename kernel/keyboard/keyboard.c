#include "keyboard.h"
#include "../terminal/terminal.h"
#define KEYBOARD_BUFFER_SIZE 128

static const char keyboard_map[128] = {
    0,
    0x1B, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
    '-', '=', '\b',
    '\t',
    'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p',
    '[', ']', '\n',
    0,
    'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l',
    ';', '\'', '`',
    0,
    '\\',
    'z', 'x', 'c', 'v', 'b', 'n', 'm',
    ',', '.', '/',
    0,
    '*',
    0,
    ' ',
};

static int lshift = 0;
static int rshift = 0;
static int caps_lock = 0;
static int extended_scancode = 0;

static char keyboard_buffer[KEYBOARD_BUFFER_SIZE];
static int keyboard_buffer_length = 0;
static int keyboard_cursor = 0;

static int shift_pressed(void){
    return lshift || rshift;
}

static inline unsigned char inb(unsigned short port){
    unsigned char value;

    __asm__ volatile ("inb %1, %0":"=a"(value):"Nd"(port));

    return value;
}

static inline void outb(unsigned short port, unsigned char value){
    __asm__ volatile ("outb %0, %1"::"a"(value), "Nd"(port));
}

static char apply_modifiers(unsigned char scancode, char c){
    int uppercase = shift_pressed() ^ caps_lock;


    if (c >= 'a' && c <= 'z') if(uppercase) return c - 'a' + 'A';

    if (!shift_pressed()) return c;

    switch (scancode){
        case 0x02: return '!';
        case 0x03: return '@';
        case 0x04: return '#';
        case 0x05: return '$';
        case 0x06: return '%';
        case 0x07: return '^';
        case 0x08: return '&';
        case 0x09: return '*';
        case 0x0A: return '(';
        case 0x0B: return ')';

        case 0x0C: return '_';
        case 0x0D: return '+';

        case 0x1A: return '{';
        case 0x1B: return '}';

        case 0x27: return ':';
        case 0x28: return '"';
        case 0x29: return '~';

        case 0x2B: return '|';

        case 0x33: return '<';
        case 0x34: return '>';
        case 0x35: return '?';
    }

    return c;
}

void keyboard_handler(void){
    unsigned char scancode = inb(0x60);

    if (scancode == 0xE0){
        extended_scancode = 1;
        goto done;
    }

    if (scancode == 0x2A){
        lshift = 1;
        goto done;
    }

    if (scancode == 0x36){
        rshift = 1;
        goto done;
    }

    if (scancode == 0xAA){
        lshift = 0;
        goto done;
    }

    if (scancode == 0xB6){
        rshift = 0;
        goto done;
    }

    if (scancode == 0x3A){
        caps_lock = !caps_lock;
        goto done;
    }

    if (scancode & 0x80){
        goto done;
    }

    char c = keyboard_map[scancode];

    if (c){
        c = apply_modifiers(scancode, c);
        terminal_putc(c);
    }

done:
    outb(0x20, 0x20);
}

void keyboard_init(void){

}
