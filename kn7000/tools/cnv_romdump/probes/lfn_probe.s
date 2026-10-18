# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# lfn_probe.s -- can a style converter on program 941 create a file on the SD card, and does the
# firmware's FAT library keep a long file name? Switches the fmm layer to SD (SetExtMode(1)), creates
# NAME1 (a MAME ROM name, 34 characters) and NAME2 (8.3) with fmmopen "w", writes a marker into each,
# closes them, switches back to floppy (ResetExtMode) and ends the conversion (request 0xFE).
# Results at 0x502E0000: +0 open1, +4 write1, +8 close1, +0xC open2, +0x10 write2, +0x14 close2.
.mnbase 0x502B8000
.equ SetExtMode,   0x48532346
.equ ResetExtMode, 0x48532355
.equ fmmopen,      0x48532390
.equ fmmclose,     0x485323BC
.equ fmmwrite,     0x4853248F
.equ MAILBOX,      0x5031BC00
.equ RES,          0x502E0000
Entry:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     RES, a2
    mov     1, d0
    mov     SetExtMode, a0
    calls   (a0)
    mov     name1, a0
    mov     mode_w, a1
    mov     fmmopen, a3
    calls   (a3)
    mov     d0, (0, a2)
    mov     marker1, a0
    mov     16, d0
    mov     fmmwrite, a3
    calls   (a3)
    mov     d0, (4, a2)
    mov     fmmclose, a3
    calls   (a3)
    mov     d0, (8, a2)
    mov     name2, a0
    mov     mode_w, a1
    mov     fmmopen, a3
    calls   (a3)
    mov     d0, (0xC, a2)
    mov     marker2, a0
    mov     16, d0
    mov     fmmwrite, a3
    calls   (a3)
    mov     d0, (0x10, a2)
    mov     fmmclose, a3
    calls   (a3)
    mov     d0, (0x14, a2)
    mov     ResetExtMode, a3
    calls   (a3)
    mov     MAILBOX, a0
    mov     0xFE, d0
    movbu   d0, (a0)
    ret     [d2,d3,a2,a3], 0x30
name1:
    .asciz  "kn7000_program_even_v1.6_b941.ic17"
name2:
    .asciz  "SHORT.BIN"
mode_w:
    .asciz  "wb"
    .align  4
marker1:
    .ascii  "LONG NAME PROBE!"
marker2:
    .ascii  "SHORT NAME PROBE"
