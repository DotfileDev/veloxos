bits    16

gdt32_descriptor:
        dw      gdt32_end - gdt32_begin - 1
        dd      gdt32_begin

align   4
gdt32_begin:
        ; Null segment.
        dq      0x0000000000000000
        ; Code segment.
        dw      0xFFFF
        dw      0x0000
        db      0x00
        db      0b10011000
        db      0b11001111
        db      0x00
        ; Data segment.
        dw      0xFFFF
        dw      0x0000
        db      0x00
        db      0b10010010
        db      0b11001111
        db      0x00
        ; Null segment.
        dq      0x0000000000000000
gdt32_end:
