# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# sdmark.s -- a marker converter for the "can STYLE CONVERT load from the SD card?" probe
# (sd_cnv.sh). Linked at 0x502B8000, the address STYLE CONVERT loads a .CNV to. Each call counts
# itself at MARK+0, copies the fmm drive byte 0x5007125A (0 floppy, 1 SD, 2 third backend) to
# MARK+4 and a tag to MARK+8 that says which copy of the file ran (TAG is set per copy by
# sd_cnv.sh: 'FLOP', 'ROOT', 'KN7K', 'TFLD'), then answers request 5 (show text), which keeps the
# firmware calling back. A nonzero count proves the firmware loaded and called this file.
.mnbase 0x502B8000
.equ MAILBOX,   0x5031BC00
.equ DRIVE,     0x5007125A
.equ MARK,      0x502E0000          # inside the 0x30000 bytes the firmware zeroes before loading
Entry:
    movm    [d2,a2], (sp)
    add     -0x10, sp
    mov     MARK, a2
    mov     (a2), d0
    inc     d0
    mov     d0, (a2)
    movbu   (DRIVE), d0
    mov     d0, (4, a2)
    mov     (tag), d0
    mov     d0, (8, a2)
    mov     MAILBOX, a0
    mov     5, d0
    movbu   d0, (a0)
    mov     msg, a1
    inc     a0
cpy:
    movbu   (a1), d0
    movbu   d0, (a0)
    inc     a0
    inc     a1
    cmp     0, d0
    bne     cpy
    ret     [d2,a2], 0x18
    .align  4
tag:
    .ascii  "TAG?"
msg:
    .asciz  "SDMARK"
