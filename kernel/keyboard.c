#include "keyboard.h"
#include "interrupts.h"
#include "kernel.h"

// Keyboard state
static keyboard_state_t keyboard_state;

// Scancode to character mapping (unshifted)
static const char scancode_table[128] = {
    0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b',
    '\t', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',
    0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`',
    0, '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0,
    '*', 0, ' ', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    '-', 0, 0, 0, '+', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

// Scancode to character mapping (shifted)
static const char scancode_shift_table[128] = {
    0, 0, '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', '\b',
    '\t', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}', '\n',
    0, 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', '"', '~',
    0, '|', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>', '?', 0,
    '*', 0, ' ', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    '-', 0, 0, 0, '+', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

void keyboard_init(void) {
    terminal_writestring("Initializing keyboard...\n");
    
    // Clear keyboard state
    keyboard_state.shift_pressed = 0;
    keyboard_state.ctrl_pressed = 0;
    keyboard_state.alt_pressed = 0;
    keyboard_state.caps_lock = 0;
    
    // Install keyboard handler
    irq_install_handler(IRQ_KEYBOARD, keyboard_handler);
    
    terminal_writestring("Keyboard ready\n");
}

void keyboard_handler(void) {
    uint8_t scancode = inb(0x60);
    
    // Handle key releases (high bit set)
    if (scancode & 0x80) {
        scancode &= 0x7F;
        
        switch (scancode) {
            case SCAN_LEFTSHIFT:
            case SCAN_RIGHTSHIFT:
                keyboard_state.shift_pressed = 0;
                break;
            case SCAN_LEFTCTRL:
                keyboard_state.ctrl_pressed = 0;
                break;
            case SCAN_LEFTALT:
                keyboard_state.alt_pressed = 0;
                break;
        }
    } else {
        // Handle key presses
        switch (scancode) {
            case SCAN_LEFTSHIFT:
            case SCAN_RIGHTSHIFT:
                keyboard_state.shift_pressed = 1;
                break;
            case SCAN_LEFTCTRL:
                keyboard_state.ctrl_pressed = 1;
                break;
            case SCAN_LEFTALT:
                keyboard_state.alt_pressed = 1;
                break;
            case SCAN_CAPSLOCK:
                keyboard_state.caps_lock = !keyboard_state.caps_lock;
                break;
            default: {
                // Convert to character and display
                char c = keyboard_scancode_to_char(scancode);
                if (c != 0) {
                    terminal_putchar(c);
                }
                break;
            }
        }
    }
    
    // Send EOI to PIC
    outb(0x20, 0x20);
}

char keyboard_scancode_to_char(uint8_t scancode) {
    if (scancode >= 128) {
        return 0;
    }
    
    char c = 0;
    const char* table = keyboard_state.shift_pressed ? scancode_shift_table : scancode_table;
    
    c = table[scancode];
    
    // Handle caps lock for letters
    if (c >= 'a' && c <= 'z' && keyboard_state.caps_lock) {
        c -= 'a' - 'A';
    } else if (c >= 'A' && c <= 'Z' && keyboard_state.caps_lock) {
        c += 'a' - 'A';
    }
    
    return c;
}

keyboard_state_t* keyboard_get_state(void) {
    return &keyboard_state;
}