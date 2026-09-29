ASM=nasm

BOOT=boot/boot.asm
ENTRY=kernel/entry.asm

BUILD=build

all: os-image

$(BUILD):
	mkdir -p $(BUILD)


$(BUILD)/boot.bin: $(BOOT) | $(BUILD)
	$(ASM) -f bin $< -o $@


$(BUILD)/entry.bin: $(ENTRY) | $(BUILD)
	$(ASM) -f bin $< -o $@


os-image: $(BUILD)/boot.bin $(BUILD)/entry.bin
	cat $(BUILD)/boot.bin $(BUILD)/entry.bin > disk.img


run: os-image
	qemu-system-x86_64 \
		-drive format=raw,file=disk.img


clean:
	rm -rf $(BUILD)
	rm -f disk.img
