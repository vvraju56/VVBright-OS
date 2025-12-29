#!/bin/bash

# Main LaptopOS build script
set -e

echo "================================="
echo "  LaptopOS Build System"
echo "================================="
echo ""

# Check dependencies
echo "Checking dependencies..."
missing_deps=""

for cmd in gcc make gzip cpio; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        missing_deps="$missing_deps $cmd"
    fi
done

if [ -n "$missing_deps" ]; then
    echo "Error: Missing required dependencies:$missing_deps"
    echo "Please install these packages and try again."
    exit 1
fi

# Create build directory
mkdir -p build
cd build

echo ""
echo "Phase 1: Building Kernel..."
cd ../kernel
chmod +x build.sh
./build.sh

echo ""
echo "Phase 2: Building Initramfs..."
cd ../initramfs
chmod +x build.sh
./build.sh

echo ""
echo "Phase 3: Building Root Filesystem..."
cd ../rootfs
chmod +x build.sh
./build.sh

echo ""
echo "Phase 4: Creating ISO..."
cd ../tools
chmod +x create-iso.sh
./create-iso.sh

cd ..

echo ""
echo "================================="
echo "  Build Complete!"
echo "================================="
echo ""
echo "Output files:"
echo "  build/laptopos.iso   - Bootable ISO image"
echo "  build/vmlinuz        - Linux kernel"
echo "  build/initramfs.img  - Initial RAM filesystem"
echo "  build/rootfs.img     - Root filesystem"
echo ""
echo "Ready for USB flashing!"
echo "Run: sudo dd if=build/laptopos.iso of=/dev/sdX bs=4M status=progress"
echo ""