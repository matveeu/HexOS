all: boot.bin

boot.bin: boot.asm
	nasm -f bin boot.asm -o boot.bin

run: boot.bin
	qemu-system-i386 -drive format=raw,file=boot.bin -serial stdio

clean:
	rm -f boot.bin

.PHONY: all run clean
