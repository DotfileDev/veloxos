bits    16
org     0x7C00

%include "bootsector.asm"

load_kernel:
        call    enable_a20

        cli
        
        lgdt    [gdt32_descriptor]

        ; Set PM (Protected Mode) bit in CR0.
        mov     eax,    cr0
        or      eax,    1
        mov     cr0,    eax

        jmp     0x08:enter_protected_mode

align   4
bits    32
enter_protected_mode:
        mov     ax,     0x0010
        mov     ds,     ax
        mov     es,     ax
        mov     fs,     ax
        mov     gs,     ax
        mov     ss,     ax

        mov     esp,    0x7C00

        lgdt    [gdt64_descriptor]

        call    setup_paging

        lea     eax,    [0xB8000]
        mov     [eax],  dword 0x0F420F42

        jmp     0x08:enter_long_mode

align   8
bits    64
enter_long_mode:
        lea     rax,    [0xB8000]
        mov     rbx,    0x0F410F410F410F41
        mov     [rax],  rbx
        jmp     $
        ; Here we'll jump to kernel someday :)

NULL                    equ     0x00

KERNEL_ADDRESS          equ     0x00100000

%include "enable_a20.asm"
%include "global_descriptor_table.asm"
%include "paging.asm"

align   512,    db      0x00
load_kernel_end:
