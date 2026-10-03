#include "interrupts.h"
#include "../keyboard/keyboard.h"
extern void keyboard_irq_stub(void);

struct idt_entry {
    unsigned short offset_low;
    unsigned short selector;
    unsigned char  zero;
    unsigned char  type_attr;
    unsigned short offset_high;
} __attribute__((packed));

struct idt_ptr {
    unsigned short limit;
    unsigned int base;
} __attribute__((packed));

static struct idt_entry idt[256];
static struct idt_ptr idt_descriptor;

static inline void outb(unsigned short port, unsigned char value){
    __asm__ volatile ("outb %0, %1"::"a"(value), "Nd"(port));
}

static void idt_set_gate (int number, unsigned int handler){
    idt[number].offset_low =
        handler & 0xFFFF;

    idt[number].selector = 0x08;

    idt[number].zero = 0;

    idt[number].type_attr = 0x8E;

    idt[number].offset_high =
        (handler >> 16) & 0xFFFF;
}

static void pic_remap(void){
    outb(0x20, 0x11);
    outb(0xA0, 0x11);

    outb(0x21, 0x20);
    outb(0xA1, 0x28);

    outb(0x21, 0x04);
    outb(0xA1, 0x02);

    outb(0x21, 0x01);
    outb(0xA1, 0x01);

    outb(0x21, 0xFD);
    outb(0xA1, 0xFF);
}

void interrupts_init(void){
    for (int i = 0; i < 256; ++i){
        idt[i].offset_low = 0;
        idt[i].selector = 0;
        idt[i].zero = 0;
        idt[i].type_attr = 0;
        idt[i].offset_high = 0;
    }

    idt_set_gate(0x21, (unsigned int)keyboard_irq_stub);

    idt_descriptor.limit = sizeof(idt) - 1;

    idt_descriptor.base = (unsigned int)&idt;

    pic_remap();

    __asm__ volatile ("lidt %0"::"m"(idt_descriptor));

    __asm__ volatile ("sti");
}
