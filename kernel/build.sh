#!/bin/bash

# LaptopOS kernel build script
set -e

echo "Building LaptopOS kernel..."

# Check if we have a kernel source
if [ ! -d "linux" ]; then
    echo "Downloading Linux kernel source..."
    wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.6.tar.xz
    tar -xf linux-6.6.tar.xz
    mv linux-6.6 linux
    rm linux-6.6.tar.xz
fi

cd linux

# Copy our config
cp ../kernel/laptopos.config .config

# Build kernel
make ARCH=x86_64 -j$(nproc)
make ARCH=x86_64 modules_install INSTALL_MOD_PATH=../build/modules

# Copy kernel to build directory
cp arch/x86_64/boot/bzImage ../build/vmlinuz

cd ..
echo "Kernel build complete!"