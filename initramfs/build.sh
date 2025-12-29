#!/bin/bash

# LaptopOS initramfs build script
set -e

INITRAMFS_DIR="../build/initramfs"
ROOTFS_DIR="../rootfs"

echo "Building initramfs..."

# Clean and create directories
rm -rf "$INITRAMFS_DIR"
mkdir -p "$INITRAMFS_DIR"

# Create basic directory structure
mkdir -p "$INITRAMFS_DIR"/{bin,dev,etc,lib,mnt,proc,root,sys,tmp,usr/bin,usr/lib}

# Copy essential binaries
cp /bin/busybox "$INITRAMFS_DIR/bin/"
cp /bin/sh "$INITRAMFS_DIR/bin/" 2>/dev/null || true

# Create busybox symlinks
cd "$INITRAMFS_DIR/bin"
for cmd in mount umount mkdir mknod echo cat ls ps dmesg insmod rmmod modprobe; do
    ln -sf busybox $cmd
done
cd - > /dev/null

# Copy essential libraries
ldd /bin/busybox | grep -o '/lib[^ ]*' | while read lib; do
    cp "$lib" "$INITRAMFS_DIR/lib/"
done

# Copy kernel modules
if [ -d "../build/modules/lib/modules" ]; then
    cp -r ../build/modules/lib/modules "$INITRAMFS_DIR/lib/"
fi

# Create device files
mknod "$INITRAMFS_DIR/dev/null" c 1 3
mknod "$INITRAMFS_DIR/dev/zero" c 1 5
mknod "$INITRAMFS_DIR/dev/console" c 5 1
mknod "$INITRAMFS_DIR/dev/tty" c 5 0
mknod "$INITRAMFS_DIR/dev/tty1" c 4 1
mknod "$INITRAMFS_DIR/dev/sda" b 8 0
mknod "$INITRAMFS_DIR/dev/sda1" b 8 1

# Create init script
cat > "$INITRAMFS_DIR/init" << 'EOF'
#!/bin/sh

# Mount essential filesystems
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

# Display boot message
echo ""
echo "  ████████╗███████╗██████╗ ███╗   ███╗██╗███╗   ██╗ █████╗ ██╗     "
echo "  ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║████╗  ██║██╔══██╗██║     "
echo "     ██║   █████╗  ██████╔╝██╔████╔██║██║██╔██╗ ██║███████║██║     "
echo "     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║██║╚██╗██║██╔══██║██║     "
echo "     ██║   ███████╗██║  ██║██║ ╚═╝ ██║██║██║ ╚████║██║  ██║███████╗"
echo "     ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝"
echo ""
echo "  LaptopOS - Modern Linux-based Operating System"
echo "  Booting from USB..."
echo ""

# Load essential modules
modprobe ext4 2>/dev/null || true
modprobe vfat 2>/dev/null || true
modprobe usb-storage 2>/dev/null || true

# Find and mount root filesystem
echo "Scanning for root filesystem..."
for device in /dev/sda* /dev/sdb* /dev/sdc*; do
    if [ -b "$device" ]; then
        echo "  Trying $device..."
        if mount -t ext4 "$device" /mnt 2>/dev/null; then
            if [ -f /mnt/sbin/init ]; then
                echo "  Found root filesystem on $device"
                break
            else
                umount /mnt
            fi
        elif mount -t vfat "$device" /mnt 2>/dev/null; then
            if [ -f /mnt/boot/vmlinuz ]; then
                echo "  Found live filesystem on $device"
                break
            else
                umount /mnt
            fi
        fi
    fi
done

# Switch to root filesystem
if [ -f /mnt/sbin/init ]; then
    echo "Switching to root filesystem..."
    exec switch_root /mnt /sbin/init
else
    echo "No root filesystem found! Dropping to emergency shell."
    exec /bin/sh
fi
EOF

chmod +x "$INITRAMFS_DIR/init"

# Create initramfs
cd "$INITRAMFS_DIR"
find . | cpio -H newc -o | gzip > ../build/initramfs.img
cd - > /dev/null

echo "Initramfs build complete!"