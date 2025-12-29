# OS Development Environment Setup Guide

## Required Tools

For OS development, you need these essential tools:

1. **x86_64-elf-gcc** - Cross-compiler for x86_64 architecture targeting ELF format
2. **make** - Build automation tool
3. **grub-mkrescue** - Creates bootable GRUB CD/DVD images
4. **xorriso** - ISO manipulation tool used by grub-mkrescue
5. **ld** - GNU linker (comes with GCC toolchain)

## Installation Methods

### Method 1: Automated Setup (Recommended)

Run the provided batch file:

```bash
./setup-dev-env.bat
```

This will:
- Install MSYS2 if not present
- Update package databases
- Install all required tools
- Set up your PATH
- Verify installations

### Method 2: Manual MSYS2 Installation

1. **Install MSYS2:**
   - Download from https://www.msys2.org/
   - Run the installer
   - Open MSYS2 MinGW64 terminal

2. **Update and Install Packages:**
   ```bash
   pacman -Syu
   pacman -S --noconfirm mingw-w64-x86_64-toolchain make grub xorriso mtools
   ```

3. **Add to PATH:**
   Add these directories to your system PATH:
   - `C:\msys64\mingw64\bin`
   - `C:\msys64\usr\bin`

### Method 3: Alternative with Chocolatey

If you have admin rights:

```powershell
# Install Chocolatey (if not already installed)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install tools
choco install msys2 make
```

## Cross-Compilation Usage

Since this is Windows, you'll use the MinGW64 cross-compiler:

```bash
# For x86_64 ELF targets (equivalent to x86_64-elf-gcc)
gcc -target x86_64-elf -ffreestanding -nostdlib -c kernel.c -o kernel.o

# Alternative: Use clang if installed
clang -target x86_64-elf -ffreestanding -nostdlib -c kernel.c -o kernel.o
```

## Building Your OS

After tools are installed, you can build your project:

```bash
cd V:\work\OS
make all
```

Or use the build scripts:
```bash
./build.sh
```

## Verification

To verify tools are working:

```bash
gcc --version
make --version  
grub-mkrescue --version
xorriso --version
```

## Common Issues

1. **Tools not found**: Ensure MSYS2 paths are added to your system PATH
2. **Permission errors**: Run setup script as administrator
3. **Missing packages**: Update MSYS2 with `pacman -Syu` before installing

## Additional Resources

- [OSDev Wiki](https://wiki.osdev.org/) - Comprehensive OS development guide
- [GCC Cross-Compiler](https://wiki.osdev.org/GCC_Cross-Compiler) - Building custom cross-compilers
- [GRUB Configuration](https://wiki.osdev.org/GRUB) - GRUB bootloader setup