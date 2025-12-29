#ifndef KERNEL_H
#define KERNEL_H

#include <stddef.h>
#include <stdint.h>

// VGA text mode constants
#define VGA_WIDTH  80
#define VGA_HEIGHT 25
#define VGA_MEMORY 0xB8000

// VGA colors
typedef enum {
    VGA_COLOR_BLACK = 0,
    VGA_COLOR_BLUE = 1,
    VGA_COLOR_GREEN = 2,
    VGA_COLOR_CYAN = 3,
    VGA_COLOR_RED = 4,
    VGA_COLOR_MAGENTA = 5,
    VGA_COLOR_BROWN = 6,
    VGA_COLOR_LIGHT_GREY = 7,
    VGA_COLOR_DARK_GREY = 8,
    VGA_COLOR_LIGHT_BLUE = 9,
    VGA_COLOR_LIGHT_GREEN = 10,
    VGA_COLOR_LIGHT_CYAN = 11,
    VGA_COLOR_LIGHT_RED = 12,
    VGA_COLOR_LIGHT_MAGENTA = 13,
    VGA_COLOR_LIGHT_BROWN = 14,
    VGA_COLOR_WHITE = 15,
} vga_color;

// VGA entry structure
static inline uint16_t vga_entry(char c, vga_color color) {
    return (uint16_t) c | (uint16_t) color << 8;
}

// Terminal functions
void terminal_initialize(void);
void terminal_setcolor(vga_color color);
void terminal_putentryat(char c, vga_color color, size_t x, size_t y);
void terminal_putchar(char c);
void terminal_write(const char* data);
void terminal_writestring(const char* data);

// System functions
void kmain(void);
void panic(const char* message);

// Memory management
#include "memory.h"

// Interrupt handling
#include "interrupts.h"

// Keyboard input
#include "keyboard.h"

#endif