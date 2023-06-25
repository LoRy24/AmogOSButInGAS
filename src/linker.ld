ENTRY(_kernel_entry)
OUTPUT_FORMAT(binary)

SECTIONS {
    . = 1M;

    .text : {
        *(.text)
        FILL(0x00)
    }

    .rodata : {
        *(.rodata)
        FILL(0x00)
    }

    .data : {
        *(.data)
        FILL(0x00)
    }

    .bss : {
        *(COMMON)
        *(.bss)
        FILL(0x00)
    }
}