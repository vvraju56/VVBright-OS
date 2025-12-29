[bits 32]

section .multiboot_header
header_start:
    dd 0xe85250d6                ; magic number
    dd 0                         ; architecture 0 (protected mode i386)
    dd header_end - header_start ; header length
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start)) ; checksum
    
    ; End tags
    dw 0    ; type
    dw 0    ; flags
    dd 8    ; size
header_end:

section .text
extern kmain
global start

start:
    ; Stack setup
    mov esp, stack_space
    
    ; Call kernel main
    call kmain
    
    ; Halt if kernel returns
.halt:
    cli
    hlt
    jmp .halt

section .bss
resb 8192 ; 8KB stack space
stack_space: