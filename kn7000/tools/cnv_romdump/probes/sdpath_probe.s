# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# sdpath_probe.s -- companion to sdraw_probe.s. On program 941, from a style converter:
#  a. can SdRawRead read the MBR and the boot sector before the converter has made any fmm call, so
#     that it could compute the volume geometry itself? Is the volume record 0x50149730 already
#     filled in at that point?
#  b. what does sdfmmkdir return for a folder that already exists?
#  c. does sdfmpath(folder) make fmmopen(name) create the file in that folder, and does sdfmpath(0)
#     clear the folder byte 0x50092504 again?
#
# Results at RES (0x502E0000), one word each:
#   +00 rawread(0, 1) = MBR   +04 partition LBA (MBR +0x1C6)   +08 rawread(LBA, 1) = boot sector
#   +0C sdfmmkdir #1   +10 sdfmmkdir #2 (same name)   +14 fmmopen   +18 fmmwrite   +1C fmmclose
#   +20 byte 0x50092504 at entry   +24 the same after sdfmpath(folder)   +28 the same after sdfmpath(0)
#   +100 volume record (0x50149730, 0x40 bytes) at entry, before any fmm call
#   +140 the same after the first sdfmmkdir
#   +7FC 0x600DF00D once the probe has finished
#   MBRBUF 0x502E1000 (512 bytes), BSBUF 0x502E1200 (512 bytes)
.mnbase 0x502B8000
.equ SetExtMode,   0x48532346
.equ ResetExtMode, 0x48532355
.equ fmmopen,      0x48532390
.equ fmmclose,     0x485323BC
.equ fmmwrite,     0x4853248F
.equ sdfmmkdir,    0x48565D45
.equ sdfmpath,     0x48565D84
.equ SdRawRead,    0x48470348
.equ MAILBOX,      0x5031BC00
.equ VOL,          0x50149730
.equ FOLDER,       0x50092504
.equ RES,          0x502E0000
.equ MBRBUF,       0x502E1000
.equ BSBUF,        0x502E1200
Entry:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     RES, a2
    clr     d0
    mov     d0, (0x7FC, a2)
    mov     FOLDER, a0
    movbu   (a0), d0
    mov     d0, (0x20, a2)
    mov     VOL, a0
    mov     RES + 0x100, a1
    mov     0x40, d0
    calls   Copy
    mov     1, d0
    mov     SetExtMode, a0
    calls   (a0)
# --- a. MBR and boot sector, raw, before any fmm call
    clr     d0
    mov     1, d1
    mov     MBRBUF, a1
    mov     SdRawRead, a3
    calls   (a3)
    mov     d0, (0, a2)
    mov     MBRBUF, a0
    movhu   (0x1C8, a0), d0
    asl     16, d0
    movhu   (0x1C6, a0), d1
    or      d1, d0
    mov     d0, (4, a2)
    mov     1, d1
    mov     BSBUF, a1
    mov     SdRawRead, a3
    calls   (a3)
    mov     d0, (8, a2)
# --- b. mkdir twice
    mov     dirname, a0
    mov     sdfmmkdir, a3
    calls   (a3)
    mov     d0, (0xC, a2)
    mov     VOL, a0
    mov     RES + 0x140, a1
    mov     0x40, d0
    calls   Copy
    mov     dirname, a0
    mov     sdfmmkdir, a3
    calls   (a3)
    mov     d0, (0x10, a2)
# --- c. sdfmpath(folder), create a bare name, sdfmpath(0)
    mov     dirname, a0
    mov     sdfmpath, a3
    calls   (a3)
    mov     FOLDER, a0
    movbu   (a0), d0
    mov     d0, (0x24, a2)
    mov     name3, a0
    mov     mode_w, a1
    mov     fmmopen, a3
    calls   (a3)
    mov     d0, (0x14, a2)
    mov     marker3, a0
    mov     16, d0
    mov     fmmwrite, a3
    calls   (a3)
    mov     d0, (0x18, a2)
    mov     fmmclose, a3
    calls   (a3)
    mov     d0, (0x1C, a2)
    mov     0, a0
    mov     sdfmpath, a3
    calls   (a3)
    mov     FOLDER, a0
    movbu   (a0), d0
    mov     d0, (0x28, a2)
    mov     ResetExtMode, a3
    calls   (a3)
    mov     0x600DF00D, d0
    mov     d0, (0x7FC, a2)
    mov     MAILBOX, a0
    mov     0xFE, d0
    movbu   d0, (a0)
    ret     [d2,d3,a2,a3], 0x30

# Copy(a0 = source, a1 = destination, d0 = bytes): leaf, entered with calls, uses d0/d1/a0/a1 only.
Copy:
    cmp     0, d0
    beq     copy_end
copy_lp:
    movbu   (a0), d1
    movbu   d1, (a1)
    inc     a0
    inc     a1
    add     -1, d0
    bne     copy_lp
copy_end:
    ret     0, 0

dirname:
    .asciz  "C:\SDRAWDIR"
name3:
    .asciz  "FILE3.BIN"
mode_w:
    .asciz  "wb"
    .align  4
marker3:
    .ascii  "SDFMPATH FILE3  "
