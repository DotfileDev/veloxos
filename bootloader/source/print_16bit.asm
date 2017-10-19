bits    16

print_16bit:
        push    ax
        push    si

        mov     ah,     0x0E

.loop:
        lodsb
        cmp     al,     0x00
        je      .end
        int     0x10
        jmp     .loop

.end:
        pop     si
        pop     ax
        ret
