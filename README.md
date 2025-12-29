# VVBright OS - Linux-Based Custom Operating System

## Overview
VVBright OS is a modern, fast, dark-themed laptop operating system combining the simplicity of Linux with the polish of Windows. Built by VV.

## Architecture
- **Type**: Linux-kernel-based custom OS
- **Target**: x86_64 laptops (UEFI + BIOS)
- **Boot**: USB pendrive with GRUB
- **Theme**: Dark mode with neon glow accents (pink/violet/cyan)

## Features
- Live USB boot (no installation required)
- Modern desktop environment
- Laptop hardware support
- Persistent storage option

## Build Process
```bash
# Build kernel
make -C kernel ARCH=x86_64 CROSS_COMPILE=x86_64-linux-gnu-

# Create initramfs
cd initramfs && make && cd ..

# Build root filesystem
cd rootfs && make && cd ..

# Create ISO
make iso

# Write to USB
sudo dd if=laptopos.iso of=/dev/sdX bs=4M status=progress
```

## Directory Structure
```
├── kernel/          # Linux kernel source and config
├── initramfs/       # Initial RAM filesystem
├── grub/            # GRUB bootloader configuration
├── rootfs/          # Root filesystem layout
├── build/           # Build artifacts
└── tools/           # Build tools and scripts
```

## USB Boot Support
- FAT32 partition for EFI
- EXT4 partition for system
- GRUB bootloader
- UEFI + Legacy BIOS support