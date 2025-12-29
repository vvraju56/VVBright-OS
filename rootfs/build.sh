#!/bin/bash

# LaptopOS root filesystem build script
set -e

ROOTFS_DIR="../build/rootfs"

echo "Building root filesystem..."

# Clean and create directories
rm -rf "$ROOTFS_DIR"
mkdir -p "$ROOTFS_DIR"

# Create directory structure
mkdir -p "$ROOTFS_DIR"/{bin,boot,dev,etc,home,lib,opt,proc,root,run,sbin,srv,sys,tmp,usr,var}
mkdir -p "$ROOTFS_DIR"/usr/{bin,lib,local,sbin,share}
mkdir -p "$ROOTFS_DIR"/var/{log,run,cache,lib,spool}
mkdir -p "$ROOTFS_DIR"/etc/{init.d,rc.d,systemd,udev,modprobe.d}

# Copy essential system binaries
if [ -f "/bin/bash" ]; then
    cp /bin/bash "$ROOTFS_DIR/bin/"
fi

if [ -f "/bin/sh" ]; then
    cp /bin/sh "$ROOTFS_DIR/bin/"
fi

# Create basic system files
cat > "$ROOTFS_DIR/etc/os-release" << 'EOF'
NAME=LaptopOS
VERSION="1.0"
ID=laptopos
ID_LIKE=ubuntu
PRETTY_NAME="LaptopOS 1.0"
VERSION_ID="1.0"
HOME_URL="https://laptopos.dev"
SUPPORT_URL="https://laptopos.dev/support"
EOF

cat > "$ROOTFS_DIR/etc/hostname" << 'EOF'
laptopos
EOF

cat > "$ROOTFS_DIR/etc/hosts" << 'EOF'
127.0.0.1 localhost
127.0.1.1 laptopos
::1 localhost
EOF

cat > "$ROOTFS_DIR/etc/fstab" << 'EOF'
# /etc/fstab: static file system information
proc            /proc           proc    defaults          0       0
/dev/sda1       /               ext4    errors=remount-ro 0       1
EOF

# Create init system
cat > "$ROOTFS_DIR/sbin/init" << 'EOF'
#!/bin/bash

# LaptopOS init system
echo "Starting LaptopOS init system..."

# Mount filesystems
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
mount -a

# Set hostname
hostname laptopos

# Start udev
udevd --daemon
udevadm trigger --action=add
udevadm settle

# Load kernel modules
modprobe ext4
modprobe vfat
modprobe usb-storage
modprobe ehci_hcd
modprobe uhci_hcd
modprobe xhci_hcd

# Start essential services
echo "Starting system services..."

# Display login prompt
clear
echo ""
echo "  ████████╗███████╗██████╗ ███╗   ███╗██╗███╗   ██╗ █████╗ ██╗     "
echo "  ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║████╗  ██║██╔══██╗██║     "
echo "     ██║   █████╗  ██████╔╝██╔████╔██║██║██╔██╗ ██║███████║██║     "
echo "     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║██║╚██╗██║██╔══██║██║     "
echo "     ██║   ███████╗██║  ██║██║ ╚═╝ ██║██║██║ ╚████║██║  ██║███████╗"
echo "     ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝"
echo ""
echo "  LaptopOS 1.0 - Ready"
echo ""
echo "  System Information:"
echo "  - Kernel: $(uname -r)"
echo "  - Memory: $(free -h | grep '^Mem:' | awk '{print $3}') / $(free -h | grep '^Mem:' | awk '{print $2}')"
echo "  - Disk: $(df -h / | tail -1 | awk '{print $3}') / $(df -h / | tail -1 | awk '{print $2}')"
echo ""
echo "  Type 'help' for available commands"
echo ""

# Start shell loop
while true; do
    echo -n "laptopos@$(hostname):~$ "
    read command
    case "$command" in
        "help")
            echo "Available commands:"
            echo "  help     - Show this help"
            echo "  clear    - Clear screen"
            echo "  ls       - List files"
            echo "  cat      - Display file contents"
            echo "  ps       - Show processes"
            echo "  df       - Show disk usage"
            echo "  free     - Show memory usage"
            echo "  dmesg    - Show kernel messages"
            echo "  reboot   - Reboot system"
            echo "  poweroff - Power off system"
            echo "  exit     - Exit shell"
            ;;
        "clear")
            clear
            ;;
        "ls")
            ls -la
            ;;
        "ps")
            ps aux
            ;;
        "df")
            df -h
            ;;
        "free")
            free -h
            ;;
        "dmesg")
            dmesg | tail -20
            ;;
        "reboot")
            echo "Rebooting..."
            reboot
            ;;
        "poweroff")
            echo "Powering off..."
            poweroff
            ;;
        "exit")
            echo "Exiting shell..."
            break
            ;;
        "")
            # Empty command, do nothing
            ;;
        *)
            if [[ "$command" == cat* ]]; then
                filename=$(echo "$command" | cut -d' ' -f2)
                if [ -n "$filename" ]; then
                    cat "$filename" 2>/dev/null || echo "File not found: $filename"
                else
                    echo "Usage: cat <filename>"
                fi
            else
                echo "Unknown command: $command"
                echo "Type 'help' for available commands"
            fi
            ;;
    esac
done

echo "Shutting down..."
sync
poweroff -f
EOF

chmod +x "$ROOTFS_DIR/sbin/init"

# Create filesystem image
dd if=/dev/zero of="../build/rootfs.img" bs=1M count=1024
mkfs.ext4 -F "../build/rootfs.img"
mkdir -p /tmp/rootfs
mount -o loop "../build/rootfs.img" /tmp/rootfs
cp -r "$ROOTFS_DIR"/* /tmp/rootfs/
umount /tmp/rootfs
rm -rf /tmp/rootfs

echo "Root filesystem build complete!"