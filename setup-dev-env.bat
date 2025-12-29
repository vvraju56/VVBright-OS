@echo off
echo ========================================
echo OS Development Environment Setup
echo ========================================
echo.

echo [1/5] Installing MSYS2 (if not already installed)...
if not exist "C:\msys64\msys2.exe" (
    echo Downloading MSYS2 installer...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/msys2/msys2-installer/releases/download/2025-08-30/msys2-x86_64-20250830.exe' -OutFile 'msys2-installer.exe'"
    echo Installing MSYS2...
    start /wait msys2-installer.exe /S
    del msys2-installer.exe
) else (
    echo MSYS2 already installed.
)

echo.
echo [2/5] Updating MSYS2 package database...
C:\msys64\usr\bin\bash.exe -lc "pacman -Syu --noconfirm"

echo.
echo [3/5] Installing required packages...
C:\msys64\usr\bin\bash.exe -lc "pacman -S --noconfirm mingw-w64-x86_64-toolchain make grub xorriso mtools"

echo.
echo [4/5] Setting up environment...
REM Add MSYS2 MinGW64 to PATH for this session
set PATH=C:\msys64\mingw64\bin;C:\msys64\usr\bin;%PATH%

echo.
echo [5/5] Verifying installations...
echo.
echo Checking tools:
echo =================
echo.
echo GCC (x86_64-elf-gcc equivalent):
where gcc
if exist "C:\msys64\mingw64\bin\gcc.exe" (
    C:\msys64\mingw64\bin\gcc.exe --version | head -n 1
) else (
    echo GCC not found in expected location
)
echo.
echo Make:
where make
if exist "C:\msys64\mingw64\bin\make.exe" (
    make --version | head -n 1
) else (
    echo Make not found in expected location
)
echo.
echo GRUB tools:
where grub-mkrescue
if exist "C:\msys64\usr\bin\grub-mkrescue.exe" (
    grub-mkrescue --version | head -n 1
) else (
    echo grub-mkrescue not found in expected location
)
echo.
echo XORRISO:
where xorriso
if exist "C:\msys64\usr\bin\xorriso.exe" (
    xorriso --version | head -n 1
) else (
    echo xorriso not found in expected location
)

echo.
echo ========================================
echo Setup complete!
echo ========================================
echo.
echo To make these changes permanent, add these paths to your system environment variables:
echo   C:\msys64\mingw64\bin
echo   C:\msys64\usr\bin
echo.
echo For cross-compilation, use:
echo   gcc -target x86_64-elf [options]    # For x86_64-elf target
echo   clang -target x86_64-elf [options]  # Alternative with clang
echo.
echo Tools are now available in this session.
echo.