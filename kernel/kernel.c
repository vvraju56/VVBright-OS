#include <stdint.h>
#include "include/framebuffer.h"
#include "include/draw.h"

// Dark Theme Colors
#define DARK_BG   0x202020
#define PANEL_BG  0x2A2A2A
#define ACCENT    0xFF79EE

static volatile uint16_t* vga = (uint16_t*)0xB8000;
static int pos = 0;

static void print(const char* s) {
    while (*s) {
        vga[pos++] = (uint16_t)(*s++) | 0x0F00;
    }
}

void kernel_main(void) {
    // background
    draw_rect(0, 0, fb_width, fb_height, DARK_BG);

    // taskbar
    draw_rect(0, fb_height - 40, fb_width, 40, PANEL_BG);

    // start button
    draw_rect(10, fb_height - 35, 80, 30, ACCENT);

    while (1)
        __asm__ volatile ("hlt");
}

