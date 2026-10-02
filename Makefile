CROSS = i686-elf

CC = $(CROSS)-gcc
LD = $(CROSS)-ld
OBJCOPY = $(CROSS)-objcopy

CFLAGS = -m32 \
         -ffreestanding \
         -fno-pie \
         -fno-stack-protector \
         -nostdlib \
         -nostartfiles \
         -nodefaultlibs

BUILD = build

all: $(BUILD)/disk.img

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/boot.bin: boot/boot.asm | $(BUILD)
	nasm -f bin boot/boot.asm -o $(BUILD)/boot.bin

$(BUILD)/kernel.o: kernel/kernel.c | $(BUILD)
	$(CC) $(CFLAGS) -c kernel/kernel.c -o $(BUILD)/kernel.o

$(BUILD)/terminal.o: kernel/terminal/terminal.c kernel/terminal/terminal.h | $(BUILD)
	$(CC) $(CFLAGS) -c kernel/terminal/terminal.c -o $(BUILD)/terminal.o

$(BUILD)/kernel.elf: $(BUILD)/kernel.o $(BUILD)/terminal.o linker.ld
	$(LD) -m elf_i386 -T linker.ld \
		-o $(BUILD)/kernel.elf \
		$(BUILD)/kernel.o \
		$(BUILD)/terminal.o

$(BUILD)/kernel.bin: $(BUILD)/kernel.elf
	$(OBJCOPY) -O binary \
		$(BUILD)/kernel.elf \
		$(BUILD)/kernel.bin

$(BUILD)/disk.img: $(BUILD)/boot.bin $(BUILD)/kernel.bin
	dd if=/dev/zero of=$(BUILD)/disk.img bs=512 count=2
	dd if=$(BUILD)/boot.bin of=$(BUILD)/disk.img conv=notrunc
	dd if=$(BUILD)/kernel.bin of=$(BUILD)/disk.img bs=512 seek=1 conv=notrunc

run: $(BUILD)/disk.img
	qemu-system-i386 \
		-drive format=raw,file=$(BUILD)/disk.img \
		-no-reboot \
		-no-shutdown

clean:
	rm -rf $(BUILD)

.PHONY: all run clean
