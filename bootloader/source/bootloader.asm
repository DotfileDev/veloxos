bits    16
org     0x7C00

; This is an entry point.
bootsector:
        ; Some BIOSes may set the address to 0x07C0:0x0000 instead 0x0000:0x7C00 - make a jump to fix it.
        jmp     .fix_code_segment

.fix_code_segment:
        ; Setup segment registers.
        mov     ax,     0x0000
        mov     ds,     ax
        mov     es,     ax
        mov     fs,     ax
        mov     gs,     ax

        ; Set the stack pointer.
        mov     ax,     0x07BF
        mov     ss,     ax
        xor     sp,     sp

        ; Some BIOSes may not expose extension functions if you don't explicitly ask for them first.
        mov     ah,     0x41
        mov     bx,     0x55AA
        int     0x13

        ; CF is clear if extension functions are available.
        jc      .extension_functions_not_available

        ; If extension functions are available, BH and BL are swapped.
        cmp     bx,     0xAA55
        jne     .extension_functions_not_available

        ; If bit 0 in CX is set then extended disk i/o functions are available.
        bt      cx,     0
        jnc     .extension_functions_not_available

        ; Load kernel loader.
        mov     ah,     0x42
        mov     si,     .kernel_loader_disk_address_packet
        int     0x13

        ; If data was loaded without problems, CF is clear.
        jc      .load_kernel_loader_failed

        jmp     load_kernel

.extension_functions_not_available:
        mov     si,     .EXTENSION_FUNCTIONS_NOT_AVAILABLE_MSG
        call    print_16bit
        jmp     $

.load_kernel_loader_failed:
        mov     si,     .LOAD_KERNEL_LOADER_FAIL_MSG
        call    print_16bit
        jmp     $

.kernel_loader_disk_address_packet:
        db      0x10                            ; Size of the packet.
        db      0x00                            ; Reserved.
        dw      KERNEL_LOADER_SIZE              ; Number of sectors to load.
        dd      KERNEL_LOADER_DEST_ADDRESS      ; Place to load the kernel loader.
        dq      KERNEL_LOADER_SECTOR            ; Absolute number of sector to start loading from.

.EXTENSION_FUNCTIONS_NOT_AVAILABLE_MSG   db      "Your BIOS doesn't support extension functions.", NULL
.LOAD_KERNEL_LOADER_FAIL_MSG             db      "Failed to load kernel loader.", NULL

%include "print_16bit.asm"

; BIOS requires special signature on the end of the bootsector, otherwise it won't be recongnized as a bootable disk.
.bios_signature:
        %if     ($ - $$) > 510
                %error  "Bootsector code exceed 512 bytes."
        %endif
        times   510 - ($ - $$) \
                db      0x00
        dw      0xAA55

load_kernel:
        mov     si,     TEMP_SUCCESS_MSG
        call    print_16bit
        jmp     $

        jmp     0x08:enter_protected_mode

; Let's start thinking about future :)
align   4
bits    32
enter_protected_mode:
        jmp     $

align   8
bits    64
enter_long_mode:
        jmp     $
        ; Here we'll jump to kernel someday :)

NULL                            equ     0x00

KERNEL_LOADER_SIZE              equ     (load_kernel_end - load_kernel + 511) / 512
KERNEL_LOADER_DEST_ADDRESS      equ     0x00007E00
KERNEL_LOADER_SECTOR            equ     0x01

KERNEL_ADDRESS                  equ     0x00100000

TEMP_SUCCESS_MSG                db      "Success!", NULL

align   512,    db      0x00
load_kernel_end:
