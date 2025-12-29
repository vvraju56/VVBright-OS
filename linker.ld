ENTRY(start)

SECTIONS
{
    . = 1M;  /* Load at 1MB */

    .text :
    {
        *(.multiboot_header)
        *(.text)
    }

    .data :
    {
        *(.data)
    }

    .bss :
    {
        *(.bss)
    }
}