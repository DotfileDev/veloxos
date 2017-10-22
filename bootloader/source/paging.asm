bits    32

section .bss

align   4096
pml4:
        resb    4096
pdp:
        resb    4096
pd:
        resb    4096

section .text

setup_paging:
        ; Map first PML4 entry to PDP.
        mov     eax,    pdp
        or      eax,    1 | (1 << 1)            ; Present + Writable.
        mov     [pml4], eax
        
        ; Map first PDP entry to PD.
        mov     eax,    pd
        or      eax,    1 | (1 << 1)            ; Present + Writable.
        mov     [pdp],  eax

        ; Map each PD entry to 2 MiB page.
        mov     ecx,    0

.map_next_pdp_entry:
        mov     eax,    0x200000                ; 2 MiB.
        mul     ecx                             ; Start address of ecx-th page.
        or      eax,    1 | (1 << 1) | (1 << 7) ; Present + Writable + Huge.
        mov     [pd + ecx * 8], eax             ; Map ecx-th entry.
        inc     ecx
        cmp     ecx,    512                     ; PD has 512 entries.
        jne     .map_next_pdp_entry             ; If not at the end, map next entry.

        ; Load PML4 to CR3.
        mov     eax,    pml4
        mov     cr3,    eax

        ; Set PAE (Physical Address Extension) bit in CR4.
        mov     eax,    cr4
        or      eax,    1 << 5
        mov     cr4,    eax

        ; Set LM (Long Mode) bit in EFER MSR.
        mov     ecx,    0xC0000080
        rdmsr
        or      eax,    1 << 8
        wrmsr

        ; Set PG (Paging) bit in CR0.
        mov     eax,    cr0
        or      eax,    1 << 31
        mov     cr0,    eax

        ret
