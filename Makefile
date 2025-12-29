ARCH=x86_64
CC=x86_64-elf-gcc
LD=x86_64-elf-ld
CFLAGS=-ffreestanding -O2 -Wall -Wextra -Ikernel/include
LDFLAGS=-T kernel/linker.ld -nostdlib

KERNEL_DIR = kernel
KERNEL_VIDEO_DIR = $(KERNEL_DIR)/video
KERNEL_INCLUDE_DIR = $(KERNEL_DIR)/include

KERNEL_C_SRCS = \
	$(KERNEL_DIR)/kernel.c \
	$(KERNEL_VIDEO_DIR)/framebuffer.c \
	$(KERNEL_VIDEO_DIR)/draw.c

KERNEL_OBJS = $(patsubst %.c, %.o, $(KERNEL_C_SRCS))

KERNEL_BIN = iso/boot/vmlinuz

all: $(KERNEL_BIN)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(KERNEL_BIN): $(KERNEL_OBJS) $(KERNEL_DIR)/linker.ld
	$(LD) $(LDFLAGS) $(KERNEL_OBJS) -o $(KERNEL_BIN)

iso: all
	grub-mkrescue -o vvbright.iso iso/

clean:
	rm -f $(KERNEL_OBJS) $(KERNEL_BIN) vvbright.iso
