#include "terminal/terminal.h"
#include "keyboard/keyboard.h"
#include "interrupts/interrupts.h"

void kmain(void){
    terminal_init();

    terminal_set_color(0x0A);
    terminal_write("HexOS booted successfully!\n");

    terminal_set_color(0x07);
    terminal_write("\n> ");

    interrupts_init();
    keyboard_init();

    for (;;){
        __asm__ volatile("hlt");
    }
}
