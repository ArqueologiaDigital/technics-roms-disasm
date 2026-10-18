# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# sdraw_probe.s -- can a style converter on program 941 read and write raw SD sectors, find a folder's
# directory sector, and put VFAT long-name entries in it that survive the firmware's own FAT library?
#
#  1. SetExtMode(1); sdfmmkdir("C:\SDRAWDIR"); fmmopen("SDRAWDIR\FILE1.BIN", "wb"), write 16 bytes,
#     close.
#  2. Copy the SD volume record (0x50149730, 0x40 bytes) and the 10 FAT-library cache-buffer headers
#     (0x50149850 + i*0x21C, 0x1C bytes each) to the result area.
#  3. SdRawRead(root dir start, root dir sectors) into ROOTBUF; find "SDRAWDIR   " (attr 0x10); its
#     first cluster -> LBA = data start + (cluster - 2) * sectors per cluster.
#  4. SdRawRead(LBA, 1) into DIRBUF. If entry 2 is "FILE1   BIN", build NEWBUF = ".", "..", three
#     long-name entries for kn7000_program_even_v1.6_b941.ic17, FILE1's own 8.3 entry; SdRawWrite it.
#  5. Cache headers again; fmmopen("SDRAWDIR\FILE2.BIN", "wb"), write, close (the library now
#     edits the sector we wrote); cache headers again; SdRawRead(LBA, 1) into AFTERBUF.
#  6. ResetExtMode, end the conversion (request 0xFE).
#
# Results at RES (0x502E0000), one word each:
#   +00 mkdir   +04 open1   +08 write1  +0C close1  +10 rawread(root)  +14 cluster  +18 LBA
#   +1C rawread(dir)  +20 entry 2 is FILE1 (1/0)  +24 rawwrite  +28 open2  +2C write2  +30 close2
#   +34 rawread(dir, after)  +38 byte 0x50092504 at entry  +3C root index of SDRAWDIR
#   +100 volume record   +200/+400/+600 cache headers (10 x 0x20 apart) after close1/rawwrite/close2
#   +7FC 0x600DF00D once the probe has finished
.mnbase 0x502B8000
.equ SetExtMode,   0x48532346
.equ ResetExtMode, 0x48532355
.equ fmmopen,      0x48532390
.equ fmmclose,     0x485323BC
.equ fmmwrite,     0x4853248F
.equ sdfmmkdir,    0x48565D45
.equ SdRawRead,    0x48470348
.equ SdRawWrite,   0x4847037B
.equ MAILBOX,      0x5031BC00
.equ VOL,          0x50149730
.equ CACHE,        0x50149850
.equ RES,          0x502E0000
.equ ROOTBUF,      0x502E1000
.equ DIRBUF,       0x502E6000
.equ NEWBUF,       0x502E6200
.equ AFTERBUF,     0x502E6400
Entry:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     RES, a2
    clr     d0
    mov     d0, (0x7FC, a2)
    mov     -1, d0
    mov     d0, (0x14, a2)
    mov     d0, (0x3C, a2)
    clr     d0
    mov     d0, (0x20, a2)
    mov     0x50092504, a0
    movbu   (a0), d0
    mov     d0, (0x38, a2)
    mov     1, d0
    mov     SetExtMode, a0
    calls   (a0)
    mov     dirname, a0
    mov     sdfmmkdir, a3
    calls   (a3)
    mov     d0, (0, a2)
    mov     name1, a0
    mov     mode_w, a1
    mov     fmmopen, a3
    calls   (a3)
    mov     d0, (4, a2)
    mov     marker1, a0
    mov     16, d0
    mov     fmmwrite, a3
    calls   (a3)
    mov     d0, (8, a2)
    mov     fmmclose, a3
    calls   (a3)
    mov     d0, (0xC, a2)
    mov     VOL, a0
    mov     RES + 0x100, a1
    mov     0x40, d0
    calls   Copy
    mov     RES + 0x200, a1
    calls   SnapCache
# --- 3. root directory, raw
    mov     (VOL + 0x1C), d0
    movhu   (VOL + 0x2E), d1
    mov     ROOTBUF, a1
    mov     SdRawRead, a3
    calls   (a3)
    mov     d0, (0x10, a2)
    cmp     0, d0
    bne     done
    mov     ROOTBUF, a0
    movhu   (VOL + 0x2C), d2
    clr     d3
scan:
    mov     (a0), d0
    cmp     0x41524453, d0
    bne     next
    mov     (4, a0), d0
    cmp     0x52494457, d0
    bne     next
    movbu   (11, a0), d0
    btst    0x10, d0
    beq     next
    movhu   (0x1A, a0), d0
    mov     d0, (0x14, a2)
    mov     d3, (0x3C, a2)
    bra     found
next:
    add     32, a0
    inc     d3
    cmp     d2, d3
    bne     scan
    bra     done
found:
    add     -2, d0
    mov     (VOL + 0x20), d1
    mulu    d1, d0
    mov     (VOL + 0x14), d1
    add     d1, d0
    mov     d0, (0x18, a2)
# --- 4. the folder's first directory sector, raw
    mov     1, d1
    mov     DIRBUF, a1
    mov     SdRawRead, a3
    calls   (a3)
    mov     d0, (0x1C, a2)
    cmp     0, d0
    bne     done
    mov     DIRBUF + 64, a0
    mov     (a0), d0
    cmp     0x454C4946, d0
    bne     done
    mov     (4, a0), d0
    cmp     0x20202031, d0
    bne     done
    mov     (8, a0), d0
    and     0xFFFFFF, d0
    cmp     0x4E4942, d0
    bne     done
    mov     1, d0
    mov     d0, (0x20, a2)
    mov     NEWBUF, a0
    mov     128, d1
    clr     d0
zero:
    mov     d0, (a0)
    add     4, a0
    add     -1, d1
    bne     zero
    mov     DIRBUF, a0
    mov     NEWBUF, a1
    mov     64, d0
    calls   Copy
    mov     lfn1, a0
    mov     NEWBUF + 64, a1
    mov     96, d0
    calls   Copy
    mov     DIRBUF + 64, a0
    mov     NEWBUF + 160, a1
    mov     32, d0
    calls   Copy
    mov     (0x18, a2), d0
    mov     1, d1
    mov     NEWBUF, a1
    mov     SdRawWrite, a3
    calls   (a3)
    mov     d0, (0x24, a2)
    mov     RES + 0x400, a1
    calls   SnapCache
# --- 5. the library edits the same folder after the raw write
    mov     name2, a0
    mov     mode_w, a1
    mov     fmmopen, a3
    calls   (a3)
    mov     d0, (0x28, a2)
    mov     marker2, a0
    mov     16, d0
    mov     fmmwrite, a3
    calls   (a3)
    mov     d0, (0x2C, a2)
    mov     fmmclose, a3
    calls   (a3)
    mov     d0, (0x30, a2)
    mov     RES + 0x600, a1
    calls   SnapCache
    mov     (0x18, a2), d0
    mov     1, d1
    mov     AFTERBUF, a1
    mov     SdRawRead, a3
    calls   (a3)
    mov     d0, (0x34, a2)
done:
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

# SnapCache(a1 = destination): the 10 cache-buffer headers, 0x1C bytes each, 0x20 apart.
SnapCache:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a1, a3
    mov     CACHE, a2
    mov     10, d2
snap_lp:
    mov     a2, a0
    mov     a3, a1
    mov     0x1C, d0
    calls   Copy
    add     0x21C, a2
    add     0x20, a3
    add     -1, d2
    bne     snap_lp
    ret     [d2,d3,a2,a3], 0x30

dirname:
    .asciz  "C:\SDRAWDIR"
name1:
    .asciz  "SDRAWDIR\FILE1.BIN"
name2:
    .asciz  "SDRAWDIR\FILE2.BIN"
mode_w:
    .asciz  "wb"
    .align  4
marker1:
    .ascii  "RAW SECTOR FILE1"
marker2:
    .ascii  "RAW SECTOR FILE2"
# lfn_bytes.py "FILE1   BIN" kn7000_program_even_v1.6_b941.ic17 -> 3 entries, checksum 0xdb
lfn1:
    .byte   0x43, 0x39, 0x00, 0x34, 0x00, 0x31, 0x00, 0x2e, 0x00, 0x69, 0x00, 0x0f, 0x00, 0xdb, 0x63, 0x00
    .byte   0x31, 0x00, 0x37, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff
    .byte   0x02, 0x6d, 0x00, 0x5f, 0x00, 0x65, 0x00, 0x76, 0x00, 0x65, 0x00, 0x0f, 0x00, 0xdb, 0x6e, 0x00
    .byte   0x5f, 0x00, 0x76, 0x00, 0x31, 0x00, 0x2e, 0x00, 0x36, 0x00, 0x00, 0x00, 0x5f, 0x00, 0x62, 0x00
    .byte   0x01, 0x6b, 0x00, 0x6e, 0x00, 0x37, 0x00, 0x30, 0x00, 0x30, 0x00, 0x0f, 0x00, 0xdb, 0x30, 0x00
    .byte   0x5f, 0x00, 0x70, 0x00, 0x72, 0x00, 0x6f, 0x00, 0x67, 0x00, 0x00, 0x00, 0x72, 0x00, 0x61, 0x00
