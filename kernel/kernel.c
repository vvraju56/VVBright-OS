#include "kernel.h"

void panic(const char* message) {
    terminal_setcolor(VGA_COLOR_LIGHT_RED);
    terminal_writestring("PANIC: ");
    terminal_writestring(message);
    terminal_writestring("\nSystem halted.");
    
    disable_interrupts();
    while (1) {
        __asm__ volatile("hlt");
    }
}

void kmain(void) {
    // Initialize terminal
    terminal_initialize();
    
    // Display welcome message
    terminal_setcolor(VGA_COLOR_LIGHT_GREEN);
    terminal_writestring("LaptopOS v0.2\n");
    
    terminal_setcolor(VGA_COLOR_LIGHT_GREY);
    terminal_writestring("From-scratch laptop operating system\n");
    terminal_writestring("Target: x86_64 laptops\n");
    terminal_writestring("Architecture: Monolithic kernel\n\n");
    
    // Initialize core systems
    terminal_setcolor(VGA_COLOR_LIGHT_CYAN);
    terminal_writestring("Phase 2: Memory + Keyboard\n\n");
    
    // Initialize memory management
    memory_init();
    
    // Initialize interrupt system
    interrupts_init();
    
    // Initialize keyboard
    keyboard_init();
    
    // Enable interrupts
    enable_interrupts();
    
    terminal_setcolor(VGA_COLOR_LIGHT_GREEN);
    terminal_writestring("\nAll systems ready!\n");
    terminal_writestring("Type on keyboard to test input:\n");
    terminal_setcolor(VGA_COLOR_WHITE);
    
    // Main kernel loop
    while (1) {
        __asm__ volatile("hlt");
    }
}