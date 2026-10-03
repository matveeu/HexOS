#ifndef TERMINAL_H
#define TERMINAL_H

void terminal_init(void);
void terminal_set_color (unsigned char color);
void terminal_putc(char c);
void terminal_write(const char *str);
void terminal_clear_line_at(int y);
//void terminal_write_at(int x, int y, const char *str);
void terminal_set_cursor(int x, int y);
void terminal_update_cursor(void);

#endif
