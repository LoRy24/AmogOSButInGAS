ENTRY(_kernel_entry)
OUTPUT_FORMAT(binary)

SECTIONS {
    . = 1M;

    .text : ALIGN(4096) {
        *(.text)
        FILL(0x00)
    }

    .rodata : ALIGN(4096) {
        *(.rodata)
        FILL(0x00)
    }

    .data : ALIGN(4096) {
        *(.data)
        FILL(0x00)
    }

    .bss : ALIGN(4096) {
        *(COMMON)
        *(.bss)
        FILL(0x00)
    }

    .asm : ALIGN(4096) {
        *(.asm)
        FILL(0x00)
    }
}