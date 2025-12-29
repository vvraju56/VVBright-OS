CC = gcc
AS = nasm
LD = ld

CFLAGS = -m32 -ffreestanding -fno-stack-protector -fno-pic -O2
ASFLAGS = -f elf32
LDFLAGS = -m elf_i386 -nostdlib -T linker.ld

KERNEL_DIR = kernel
BUILD_DIR = build

KERNEL_OBJS = $(BUILD_DIR)/boot.o $(BUILD_DIR)/interrupts.o $(BUILD_DIR)/kernel.o $(BUILD_DIR)/terminal.o $(BUILD_DIR)/memory.o $(BUILD_DIR)/keyboard.o

all: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/boot.o: $(KERNEL_DIR)/boot.s | $(BUILD_DIR)
	$(AS) $(ASFLAGS) $< -o $@

$(BUILD_DIR)/interrupts.o: $(KERNEL_DIR)/interrupts.s | $(BUILD_DIR)
	$(AS) $(ASFLAGS) $< -o $@

$(BUILD_DIR)/kernel.o: $(KERNEL_DIR)/kernel.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/terminal.o: $(KERNEL_DIR)/terminal.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/memory.o: $(KERNEL_DIR)/memory.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/keyboard.o: $(KERNEL_DIR)/keyboard.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/kernel.bin: $(KERNEL_OBJS) linker.ld
	$(LD) $(LDFLAGS) -o $@ $(KERNEL_OBJS)

iso: $(BUILD_DIR)/kernel.bin
	mkdir -p $(BUILD_DIR)/isofiles/boot/grub
	cp $(BUILD_DIR)/kernel.bin $(BUILD_DIR)/isofiles/boot/
	cp bootloader/grub.cfg $(BUILD_DIR)/isofiles/boot/grub/
	grub-mkrescue -o $(BUILD_DIR)/laptopos.iso $(BUILD_DIR)/isofiles

qemu: $(BUILD_DIR)/kernel.bin
	qemu-system-i386 -kernel $(BUILD_DIR)/kernel.bin

qemu-iso: iso
	qemu-system-i386 -cdrom $(BUILD_DIR)/laptopos.iso

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all iso qemu qemu-iso clean