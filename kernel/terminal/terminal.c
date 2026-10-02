//#include "terminal.h"
static volatile unsigned short *video = (unsigned short*)0xB8000;
static int cursor_x = 0;
static int cursor_y = 0;

void terminal_init(void) {
    cursor_x = 0;
    cursor_y = 0;

    for (int i = 0; i < 80*25*2; ++i){
        video[i] = (0x07 << 8) | ' ';
    }
}

static int get_offset(void){
    return (cursor_y * 80 + cursor_x);
}

static void terminal_newline(void){
    cursor_x = 0;
    ++cursor_y;
}

void terminal_putc(char c) {
    if (c == '\n'){
        terminal_newline();
        return;
    }

    int offset = get_offset();

    video[offset] = (0x07 << 8) | c;
    ++cursor_x;

    if (cursor_x >=80){
        terminal_newline();
    }
}

void terminal_write(const char *str) {
    while (*str){
        terminal_putc(*str);
        ++str;
    }
}
