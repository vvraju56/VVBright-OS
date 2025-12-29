#include "../include/framebuffer.h"

uint32_t* fb = (uint32_t*)0xE0000000;   // GRUB framebuffer addr
uint32_t fb_width = 800;
uint32_t fb_height = 600;

void put_pixel(uint32_t x, uint32_t y, uint32_t color) {
    fb[y * fb_width + x] = color;
}