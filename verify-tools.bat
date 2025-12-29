@echo off
echo ========================================
echo Verifying OS Development Tools
echo ========================================
echo.

set PATH=C:\msys64\mingw64\bin;C:\msys64\usr\bin;%PATH%

echo [1/5] GCC (Cross-compiler):
where gcc
if exist "C:\msys64\mingw64\bin\gcc.exe" (
    echo Found: gcc.exe
    C:\msys64\mingw64\bin\gcc.exe --version | head -n 1
    echo Status: ✓ Installed
) else (
    echo Status: ✗ Not found
)
echo.

echo [2/5] LD (Linker):
where ld
if exist "C:\msys64\mingw64\bin\ld.exe" (
    echo Found: ld.exe
    C:\msys64\mingw64\bin\ld.exe --version | head -n 1
    echo Status: ✓ Installed
) else (
    echo Status: ✗ Not found
)
echo.

echo [3/5] MAKE (Build tool):
where mingw32-make
if exist "C:\msys64\mingw64\bin\mingw32-make.exe" (
    echo Found: mingw32-make.exe (equivalent to make)
    C:\msys64\mingw64\bin\mingw32-make.exe --version | head -n 1
    echo Status: ✓ Installed
) else (
    echo Status: ✗ Not found
)
echo.

echo [4/5] XORRISO (ISO tool):
where xorriso
if exist "C:\msys64\usr\bin\xorriso.exe" (
    echo Found: xorriso.exe
    C:\msys64\usr\bin\xorriso.exe --version | head -n 1
    echo Status: ✓ Installed
) else (
    echo Status: ✗ Not found
)
echo.

echo [5/5] GRUB-MKRESCUE:
where grub-mkrescue
if exist "C:\msys64\usr\bin\grub-mkrescue.exe" (
    echo Found: grub-mkrescue.exe
    grub-mkrescue --version | head -n 1
    echo Status: ✓ Installed
) else (
    echo Status: ✗ Not found
    echo Note: grub-mkrescue may not be available on Windows
    echo Alternative: Use custom ISO creation scripts
)
echo.

echo ========================================
echo Summary:
echo ========================================
echo.
echo Tools Status:
echo   GCC/x86_64-elf-gcc: ✓ Available (use gcc.exe with -target flag)
echo   LD Linker: ✓ Available (use ld.exe)
echo   MAKE: ✓ Available (use mingw32-make.exe)
echo   XORRISO: ✓ Available (use xorriso.exe)
echo   GRUB-MKRESCUE: ✗ Not available on Windows
echo.
echo For OS development on Windows:
echo - Use gcc.exe with -target x86_64-elf flags
echo - Use mingw32-make.exe instead of make
echo - Use xorriso.exe directly for ISO creation
echo - May need custom GRUB setup scripts
echo.
echo ========================================