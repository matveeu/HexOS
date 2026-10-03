#include "terminal.h"

static volatile unsigned short *video = (unsigned short*)0xB8000;

static int cursor_x = 0;
static int cursor_y = 0;
static unsigned char terminal_color = 0x07;

static int get_offset(void){
    return (cursor_y * 80 + cursor_x);
}

void terminal_set_color(unsigned char color){
    terminal_color = color;
}

static void terminal_scroll(void){
    for (int y = 1; y < 25; ++y){
        for (int x = 0; x < 80; ++x){
            video[(y-1) * 80 + x] = video[y * 80 + x];
        }
    }

    for (int x = 0; x < 80; ++x){
        video[80 * 24 + x] = (terminal_color << 8) | ' ';
    }
}

static void terminal_newline(void){
    cursor_x = 0;
    ++cursor_y;

    if (cursor_y >= 25){
        terminal_scroll();
        cursor_y = 24;
    }

    terminal_update_cursor();
}

void terminal_putc(char c){
    if (cursor_x >=80){
        terminal_newline();
    }

    terminal_update_cursor();

    if (c == '\b'){
        if (cursor_x > 0){
            --cursor_x;

            int offset = get_offset();
            video[offset] = (terminal_color << 8) | ' ';
        } else if (cursor_y > 0){
            --cursor_y;
            cursor_x = 79;

            int offset = get_offset();
            video[offset] = (terminal_color << 8) | ' ';
        }

        terminal_update_cursor();
        return;
    }

    if (c == '\t'){
        int spaces = 4 -(cursor_x % 4);

        for (int i = 0; i <spaces; ++i){
            terminal_putc(' ');
        }

        return;
    }
    if (c == '\n'){
        terminal_newline();
        return;
    }

    int offset = get_offset();

    video[offset] = (terminal_color << 8) | c;
    ++cursor_x;

    terminal_update_cursor();
}

void terminal_write(const char *str){
    while (*str){
        terminal_putc(*str);
        ++str;
    }
}

void terminal_clear_line_at(int y){
    for (int x = 0; x < 80; ++x){
        video[y * 80 + x] = (terminal_color << 8) | ' ';
    }
}

static inline void outb(unsigned short port, unsigned char value){
    __asm__ volatile ("outb %0, %1"::"a"(value), "Nd"(port));
}

void terminal_update_cursor(void){
    unsigned short position = cursor_y * 80 + cursor_x;

    outb(0x3D4, 0x0F);
    outb(0x3D5, position & 0xFF);

    outb(0x3D4, 0x0E);
    outb(0x3D5, (position >> 8) & 0xFF);
}

void terminal_set_cursor(int x, int y){
    cursor_x = x;
    cursor_y = y;

    terminal_update_cursor();
}

void terminal_init(void){
    cursor_x = 0;
    cursor_y = 0;

    for (int i = 0; i < 80*25; ++i){
        video[i] = (terminal_color << 8) | ' ';
    }

    terminal_update_cursor();
}
