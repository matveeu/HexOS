#include "terminal/terminal.h"

void kmain(void) {
    terminal_init();

    terminal_write("HexOS booted successfully!\n");
    terminal_write("\n>\n");

    for (;;){}
}
