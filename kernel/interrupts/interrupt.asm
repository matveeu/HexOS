[BITS 32]

global keyboard_irq_stub
extern keyboard_handler

keyboard_irq_stub:
    pusha

    call keyboard_handler

    popa
    iretd
