#pragma once
#include <stdint.h>

extern uint32_t* fb;
extern uint32_t fb_width;
extern uint32_t fb_height;

void put_pixel(uint32_t x, uint32_t y, uint32_t color);