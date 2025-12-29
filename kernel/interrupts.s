[bits 32]

; Macro for creating interrupt handlers without error codes
%macro ISR_NOERR 1
global isr%1
isr%1:
    push 0
    push %1
    jmp isr_common
%endmacro

; Macro for creating interrupt handlers with error codes
%macro ISR_ERR 1
global isr%1
isr%1:
    push %1
    jmp isr_common
%endmacro

; Macro for creating IRQ handlers
%macro IRQ 2
global irq%1
irq%1:
    push 0
    push %1
    jmp irq_common
%endmacro

; Exception handlers (some have error codes)
ISR_NOERR 0
ISR_NOERR 1
ISR_NOERR 2
ISR_NOERR 3
ISR_NOERR 4
ISR_NOERR 5
ISR_NOERR 6
ISR_NOERR 7
ISR_ERR   8
ISR_NOERR 9
ISR_ERR   10
ISR_ERR   11
ISR_ERR   12
ISR_ERR   13
ISR_ERR   14
ISR_NOERR 15
ISR_NOERR 16
ISR_ERR   17
ISR_NOERR 18
ISR_NOERR 19

; IRQ handlers
IRQ 0
IRQ 1
IRQ 2
IRQ 3
IRQ 4
IRQ 5
IRQ 6
IRQ 7
IRQ 8
IRQ 9
IRQ 10
IRQ 11
IRQ 12
IRQ 13
IRQ 14
IRQ 15

; Common interrupt handler for exceptions
isr_common:
    pusha
    push ds
    push es
    push fs
    push gs
    
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    call interrupt_handler
    
    pop gs
    pop fs
    pop es
    pop ds
    popa
    
    add esp, 8
    iret

; Common interrupt handler for IRQs
irq_common:
    pusha
    push ds
    push es
    push fs
    push gs
    
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    call interrupt_handler
    
    pop gs
    pop fs
    pop es
    pop ds
    popa
    
    add esp, 8
    iret

extern interrupt_handler