#!/bin/bash

# LaptopOS ISO creation script
set -e

BUILD_DIR="../build"
ISO_DIR="$BUILD_DIR/iso"

echo "Creating LaptopOS ISO..."

# Clean and create ISO directory
rm -rf "$ISO_DIR"
mkdir -p "$ISO_DIR"

# Create directory structure
mkdir -p "$ISO_DIR"/{boot/grub,EFI/BOOT}

# Copy kernel and initramfs
if [ -f "$BUILD_DIR/vmlinuz" ]; then
    cp "$BUILD_DIR/vmlinuz" "$ISO_DIR/boot/"
fi

if [ -f "$BUILD_DIR/initramfs.img" ]; then
    cp "$BUILD_DIR/initramfs.img" "$ISO_DIR/boot/"
fi

if [ -f "$BUILD_DIR/rootfs.img" ]; then
    cp "$BUILD_DIR/rootfs.img" "$ISO_DIR/"
fi

# Copy GRUB configuration
cp ../grub/grub.cfg "$ISO_DIR/boot/grub/"

# Create UEFI GRUB
if command -v grub-mkstandalone >/dev/null 2>&1; then
    grub-mkstandalone \
        --format=x86_64-efi \
        --output="$ISO_DIR/EFI/BOOT/BOOTX64.EFI" \
        --boot-info \
        --modules="part_gpt part_msdos fat ext2 normal chain boot configfile" \
        --locales="" \
        --fonts="" \
        "boot/grub/grub.cfg=/tmp/grub-efi.cfg"
    
    # Create EFI config
    cat > /tmp/grub-efi.cfg << 'EOF'
search --file --no-floppy --set=root /boot/grub/grub.cfg
set prefix=($root)/boot/grub
configfile $prefix/grub.cfg
EOF
fi

# Create BIOS GRUB image
if command -v grub-mkimage >/dev/null 2>&1; then
    grub-mkimage \
        --format=i386-pc \
        --output="$ISO_DIR/boot/grub/i386-pc/core.img" \
        --prefix="/boot/grub" \
        --modules="biosdisk part_msdos fat ext2 normal chain boot configfile" \
        "biosdisk" "part_msdos" "fat" "ext2" "normal" "chain" "boot" "configfile"
    
    # Create bootable image
    cat /usr/lib/grub/i386-pc/boot.img "$ISO_DIR/boot/grub/i386-pc/core.img" > "$ISO_DIR/boot/grub/i386-pc/combined.img"
fi

# Create ISO
if command -v grub-mkrescue >/dev/null 2>&1; then
    grub-mkrescue -o "$BUILD_DIR/laptopos.iso" "$ISO_DIR"
elif command -v xorriso >/dev/null 2>&1; then
    xorriso -as mkisofs \
        -iso-level 3 \
        -full-iso9660-filenames \
        -volid "LaptopOS" \
        -appid "LaptopOS" \
        -publisher "LaptopOS" \
        -preparer "LaptopOS Build System" \
        -eltorito-boot boot/grub/i386-pc/combined.img \
        -no-emul-boot -boot-load-size 4 -boot-info-table \
        -eltorito-alt-boot -e EFI/BOOT/BOOTX64.EFI -no-emul-boot \
        -output "$BUILD_DIR/laptopos.iso" \
        "$ISO_DIR"
else
    echo "Error: Neither grub-mkrescue nor xorriso found. Cannot create ISO."
    exit 1
fi

echo "ISO creation complete: $BUILD_DIR/laptopos.iso"

# Show USB flashing instructions
echo ""
echo "=== USB Flashing Instructions ==="
echo ""
echo "1. Insert USB pendrive (8GB+ recommended)"
echo "2. Identify USB device (e.g., /dev/sdb, /dev/sdc)"
echo "3. Run one of the following commands:"
echo ""
echo "   Using dd (Linux/macOS):"
echo "   sudo dd if=$BUILD_DIR/laptopos.iso of=/dev/sdX bs=4M status=progress"
echo ""
echo "   Using Rufus (Windows):"
echo "   - Download Rufus from https://rufus.ie/"
echo "   - Select laptopos.iso"
echo "   - Choose GPT partition scheme"
echo "   - Click Start"
echo ""
echo "   Using BalenaEtcher (Cross-platform):"
echo "   - Download from https://www.balena.io/etcher/"
echo "   - Select laptopos.iso"
echo "   - Choose USB drive"
echo "   - Click Flash!"
echo ""
echo "4. Boot from USB (may need to change boot order in BIOS/UEFI)"
echo ""