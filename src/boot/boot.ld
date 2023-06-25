ENTRY(_start)
OUTPUT_FORMAT(binary)

SECTIONS {
    . = 0x7c00;

    .text : {
        *(.text)
        *(.rodata)
        FILL(0x00)
    }

    .data : {
        *(.data)
        FILL(0x00)
    }

    .bss : {
        *(.bss)
        FILL(0x00)
    }

    .signature ALIGN(2) : AT(0x7DFE) {
        SHORT(0xAA55)
        *(.after_signature_text)
        *(.after_signature_data)
        FILL(0x00)
    }
}