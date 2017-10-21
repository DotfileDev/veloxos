bits    16

enable_a20:
        call    .is_a20_enabled
        jc      .enable_by_bios
        ret

.is_a20_enabled:
        push    ds

        ; Jump to the end of available memory.
        mov     ax,     0xFFFF

        ; Write a value under 0xFFFF0 + 0x510 = 0x100500. If A20 is disabled, the value will be written to 0x500.
        mov     [ds:0x510],     byte 0xFF

        pop     ds

        ; Check the value at 0x500. If it's equal to the written one, A20 is disabled.
        mov     al,     byte [0x0500]
        cmp     al,     0xFF
        jne     .is_a20_enabled_success

        sti
        ret

.is_a20_enabled_success:
        clc
        ret

.enable_by_bios:
        mov     ax,     0x2401
        int     0x15
        call    .is_a20_enabled
        jc      .enable_by_keyboard_controller
        ret

; TODO: Implement this procedure.
.enable_by_keyboard_controller:
        call    .is_a20_enabled
        jc      .enable_by_fast_gate
        ret

.enable_by_fast_gate:
        in      al,     0x92
        or      al,     1 << 1
        out     0x92,   al
        call    .is_a20_enabled
        jc      .enable_by_ee_port
        ret

; This method will only work of few systems, but is worth trying anyway.
.enable_by_ee_port:
        in      al,     0xEE
        call    .is_a20_enabled
        jc      .a20_error
        ret

.a20_error:
        mov     si,     A20_ERROR_MSG
        call    print_16bit
        jmp     $

A20_ERROR_MSG   db      "Failed to unlock A20 line.", NULL
