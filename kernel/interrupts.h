#ifndef INTERRUPTS_H
#define INTERRUPTS_H

#include <stdint.h>

// Interrupt descriptor table entry
typedef struct {
    uint16_t offset_low;
    uint16_t selector;
    uint8_t  zero;
    uint8_t  type_attr;
    uint16_t offset_high;
} __attribute__((packed)) idt_entry_t;

// IDT pointer
typedef struct {
    uint16_t limit;
    uint32_t base;
} __attribute__((packed)) idt_ptr_t;

// Interrupt handler function type
typedef void (*interrupt_handler_t)(void);

// CPU exception numbers
#define EXC_DIVIDE_BY_ZERO      0
#define EXC_DEBUG              1
#define EXC_NMI                2
#define EXC_BREAKPOINT         3
#define EXC_OVERFLOW           4
#define EXC_BOUND_RANGE        5
#define EXC_INVALID_OPCODE     6
#define EXC_DEVICE_NOT_AVAIL   7
#define EXC_DOUBLE_FAULT       8
#define EXC_INVALID_TSS        10
#define EXC_SEGMENT_NOT_PRESENT 11
#define EXC_STACK_FAULT        12
#define EXC_GENERAL_PROTECTION 13
#define EXC_PAGE_FAULT         14
#define EXC_X87_FPU_ERROR      16
#define EXC_ALIGNMENT_CHECK    17
#define EXC_MACHINE_CHECK      18
#define EXC_SIMD_FP_EXCEPTION  19

// Hardware interrupt numbers
#define IRQ_TIMER              0
#define IRQ_KEYBOARD           1
#define IRQ_CASCADE            2
#define IRQ_COM2               3
#define IRQ_COM1               4
#define IRQ_LPT2               5
#define IRQ_FLOPPY             6
#define IRQ_LPT1               7
#define IRQ_RTC                8
#define IRQ_MOUSE              12
#define IRQ_FPU                13
#define IRQ_ATA_PRIMARY        14
#define IRQ_ATA_SECONDARY      15

// System call interrupt
#define SYSCALL_INT            0x80

// Functions
void interrupts_init(void);
void idt_set_gate(uint8_t num, uint32_t base, uint16_t sel, uint8_t flags);
void register_interrupt_handler(uint8_t interrupt, interrupt_handler_t handler);
void irq_install_handler(uint8_t irq, interrupt_handler_t handler);
void irq_remove_handler(uint8_t irq);

// Port I/O functions
static inline void outb(uint16_t port, uint8_t value) {
    __asm__ volatile("outb %0, %1" : : "a"(value), "Nd"(port));
}

static inline uint8_t inb(uint16_t port) {
    uint8_t value;
    __asm__ volatile("inb %1, %0" : "=a"(value) : "Nd"(port));
    return value;
}

static inline void outw(uint16_t port, uint16_t value) {
    __asm__ volatile("outw %0, %1" : : "a"(value), "Nd"(port));
}

static inline uint16_t inw(uint16_t port) {
    uint16_t value;
    __asm__ volatile("inw %1, %0" : "=a"(value) : "Nd"(port));
    return value;
}

// Enable/disable interrupts
static inline void enable_interrupts(void) {
    __asm__ volatile("sti");
}

static inline void disable_interrupts(void) {
    __asm__ volatile("cli");
}

#endif