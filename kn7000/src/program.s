# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# KN7000 "Program" flash image (kn7000_program.rom) - byte-exact.
# Panasonic MN10300, mapped at CPU 0x48400000. Code region 1 is split at
# the 443 recovered functions; functions listed in tools/gen_program_s.py
# CONVERT are emitted as real MN10300 assembly (verified byte-exact by the
# mn10300_asm encoder), the rest remain raw .incbin_range. Regenerate with
# tools/gen_program_s.py. make verify guarantees byte-identity.

.equ PROGRAM_ROM_BASE, 0x48400000
.mnbase 0x48400000   # CPU address of output offset 0 (for PC-relative ops)
.include "src/symbols.inc"

# ---- boot header (0x0..0x80) ----
_reset:
    .byte 0xDC, 0x7E, 0xFF, 0x00, 0x00      # jmp  0x4840FF7E   (reset entry)
    .byte 0xCB, 0xCB, 0xCB, 0xCB, 0xCB      # nop x5
_vector_0a:
    .byte 0xDC, 0xC5, 0x77, 0x0D, 0x00      # jmp  0x484D77CF
_rom_marker:
    .byte 0x16                              # ROM-present marker (cmp vs 0xFF)
    .space 0x80 - 0x10, 0xFF
    .org 0x000080

# ============================================================================
# Code region 1 -- organised by recovered function.
# ============================================================================
# 32 synthetic labels for internal helpers called by converted code
.equ func_48414A4F, 0x48414A4F
.equ func_48414A77, 0x48414A77
.equ func_48414AFD, 0x48414AFD
.equ func_48414B90, 0x48414B90
.equ func_48414BAA, 0x48414BAA
.equ func_484156A0, 0x484156A0
.equ func_4841584C, 0x4841584C
.equ func_48415AAB, 0x48415AAB
.equ func_4841662A, 0x4841662A
.equ func_484166DE, 0x484166DE
.equ func_4841C37C, 0x4841C37C
.equ func_484218FF, 0x484218FF
.equ func_48421A27, 0x48421A27
.equ func_48421A5E, 0x48421A5E
.equ func_48421AB1, 0x48421AB1
.equ func_48428555, 0x48428555
.equ func_484285E4, 0x484285E4
.equ func_48428792, 0x48428792
.equ func_484288B1, 0x484288B1
.equ func_48428C43, 0x48428C43
.equ func_48429569, 0x48429569
.equ func_484298A0, 0x484298A0
.equ func_48429906, 0x48429906
.equ func_4842B30C, 0x4842B30C
.equ func_484483B7, 0x484483B7
.equ func_48453170, 0x48453170
.equ func_4849BC1A, 0x4849BC1A
.equ func_4852FDCD, 0x4852FDCD
.equ func_48530216, 0x48530216
.equ func_48532395, 0x48532395
.equ func_485323BF, 0x485323BF
.equ func_48532494, 0x48532494

.incbin_range "baserom/kn7000_program.rom", 0x000080, 0x014a74
# UserBitmapCheck  (CPU 0x48414a74)
.incbin_range "baserom/kn7000_program.rom", 0x014a74, 0x014afa
# MainTrSwControl  (CPU 0x48414afa)
.incbin_range "baserom/kn7000_program.rom", 0x014afa, 0x014b8d
# DeleteEvent  (CPU 0x48414b8d)
.incbin_range "baserom/kn7000_program.rom", 0x014b8d, 0x014ba7
# SleepMainTask  (CPU 0x48414ba7)
    add     -0x14, sp
    clr     d0
    mov     d0, (0x10, sp)
    mov     0x00020009, d0
    mov     0x0006009e, d1
    call    func_48414A77, 0, 0x14
    ret     0, 0x14
# WakeUpMainTask  (CPU 0x48414bc1)
    add     -0x14, sp
    clr     d0
    mov     d0, (0x10, sp)
    mov     0x00020009, d0
    mov     0x0006009f, d1
    call    func_48414AFD, 0, 0x14
    ret     0, 0x14
# SleepApTask  (CPU 0x48414bdb)
    add     -0x14, sp
    clr     d0
    mov     d0, (0x10, sp)
    mov     0x00020009, d0
    mov     0x000600a0, d1
    call    func_48414AFD, 0, 0x14
    ret     0, 0x14
# WakeUpApTask  (CPU 0x48414bf5)
    add     -0x14, sp
    clr     d0
    mov     d0, (0x50021fd8)
    mov     d0, (0x50021fdc)
    mov     d0, (0x50021fe0)
    mov     -1, d0
    mov     0x00050006, d1
    call    func_48429906, [d2], 0x18
    mov     -1, d0
    mov     0x00050005, d1
    call    func_48429906, [d2], 0x18
    mov     -1, d0
    mov     0x00050007, d1
    call    func_48429906, [d2], 0x18
    mov     -1, d0
    mov     0x00050017, d1
    call    func_48429906, [d2], 0x18
    mov     -1, d0
    mov     0x00050014, d1
    call    func_48429906, [d2], 0x18
    mov     -1, d0
    mov     0x0005000c, d1
    call    func_48429906, [d2], 0x18
    mov     -1, d0
    mov     0x0005000d, d1
    call    func_48429906, [d2], 0x18
    mov     -1, d0
    mov     0x0005000e, d1
    call    func_48429906, [d2], 0x18
    clr     d0
    mov     d0, (0x10, sp)
    mov     -1, d0
    mov     0x000600a1, d1
    call    func_484298A0, [d2], 0x1c
    ret     0, 0x14
# LcdOn  (CPU 0x48414c98)
.incbin_range "baserom/kn7000_program.rom", 0x014c98, 0x01567d
# GetJpegSize  (CPU 0x4841567d)
    add     -8, sp
    call    CheckColorLcd, 0, 0
    exthu   d0
    cmp     2, d0
    beq     0x48415693
    call    func_484156A0, [d2,d3,a2,a3], 0x84
    bra     0x48415698
    call    func_4841584C, [d2,d3,a2,a3], 0xd4
    ret     0, 8
    movm    [d2,d3,a2,a3], (sp)
    add     -0x74, sp
    mov     sp, a2
    add     0x1c, a2
    mov     a2, (8, sp)
    mov     0x4859e2e4, d0
    mov     d0, (0xc, sp)
    mov     (0x50021fc8), a1
    mov     a1, (0x10, sp)
    call    0x4c001a48, [a2], 0x20
    mov     (0x50021fc8), d0
    inc     d0
    mov     d0, (0x50021fc8)
    call    func_4852FDCD, 0, 8
    call    func_48530216, [d2,d3,a2,a3], 0x10
    mov     a2, a0
    mov     0x4859e2f4, a1
    call    func_48532395, [a2,a3], 0x24
    exth    d0
    cmp     0, d0
    beq     0x484156ee
    clr     d0
    ret     [d2,d3,a2,a3], 0x84
    mov     sp, a3
    add     0x2c, a3
    mov     a3, a0
    mov     0x4859e2f8, a1
    call    0x4c003051, [a2], 4
    mov     4, d2
    add     a3, d2
    mov     0x00070836, d0
    mov     d2, a0
    mov     d0, (a0)
    clr     d0
    movhu   d0, (0x34, sp)
    movhu   d0, (0x36, sp)
    mov     0x36, d0
    mov     d0, (0x38, sp)
    mov     sp, a2
    add     0x3c, a2
    mov     a2, a0
    mov     2, d0
    mov     a3, a1
    call    0x4c003039, [a2,a3], 8
    mov     2, a0
    add     a2, a0
    mov     d2, a1
    mov     0xc, d0
    call    0x4c003039, [a2,a3], 8
    mov     0xe, d0
    mov     a2, a0
    call    func_48532494, [d2,a2], 0x24
    cmp     0xe, d0
    beq     0x4841574d
    call    func_485323BF, 0, 0x14
    clr     d0
    ret     [d2,d3,a2,a3], 0x84
    mov     0x28, d0
    mov     d0, (0x4c, sp)
    mov     0x280, d0
    mov     d0, (0x50, sp)
    mov     0xf0, d0
    mov     d0, (0x54, sp)
    mov     1, d0
    movhu   d0, (0x58, sp)
    mov     0x18, d0
    movhu   d0, (0x5a, sp)
    clr     d0
    mov     d0, (0x5c, sp)
    mov     0x00070800, d0
    mov     d0, (0x60, sp)
    clr     d0
    mov     d0, (0x64, sp)
    mov     d0, (0x68, sp)
    mov     d0, (0x6c, sp)
    mov     d0, (0x70, sp)
    mov     sp, a0
    add     0x4c, a0
    mov     0x28, d0
    call    func_48532494, [d2,a2], 0x24
    cmp     0x28, d0
    beq     0x48415794
    call    func_485323BF, 0, 0x14
    clr     d0
    ret     [d2,d3,a2,a3], 0x84
    mov     0x3c00, d0
    call    func_4841662A, [d2,a2,a3], 0x28
    mov     a0, a3
    cmp     0, a3
    bne     0x484157a4
    jmp     0x4841583a
    clr     d0
    mov     d0, (0x14, sp)
    clr     d2
    mov     0, a2
    mov     0xef, d1
    sub     d0, d1
    mov     d1, (0x18, sp)
    mov     (0x18, sp), d0
    mov     0x280, d1
    sub     a2, d0
    inc     d0
    nop
    nop
    mul     d1, d0
    add     d0, d0
    mov     d0, a0
    add     0x9ce00000, a0
    mov     0, a1
    setlb
    movhu   (a0), d3
    exth    d2
    exthu   d3
    mov     0x1f, d1
    and     d3, d1
    asl     3, d1
    .byte 0xF4   # movbu d1, (d2, a3)
    mov     (0x48, sp), d3
    mov     d2, d0
    exth    d0
    mov     0x7e0, d1
    and     d3, d1
    asr     3, d1
    .byte 0xF4   # movbu d1, (d0, a3)
    inc4    a3
    exth    d2
    inc     d2
    mov     d2, d0
    exth    d0
    and     0xf800, d3
    asr     8, d3
    .byte 0xF4   # movbu d3, (d0, a3)
    mov     (a3), d0
    exth    d2
    inc     d2
    add     2, a0
    mov     a1, d0
    inc     d0
    exth    d0
    mov     d0, a1
    cmp     0x280, d0
    llt
    mov     a2, d0
    inc     d0
    exth    d0
    mov     d0, a2
    cmp     8, d0
    blt     0x484157b1
    mov     a3, a0
    mov     0x3c00, d0
    call    func_48532494, [d2,a2], 0x24
    cmp     0x3c00, d0
    beq     0x48415824
    call    func_485323BF, 0, 0x14
    clr     d0
    bra     0x48415843
    mov     (0x14, sp), d0
    add     8, d0
    exth    d0
    mov     d0, (0x14, sp)
    cmp     0xf0, d0
    bge     0x48415834
    jmp     0x484157a7
    mov     a3, a0
    call    func_484166DE, [d2,d3,a2,a3], 0x2c
    call    func_485323BF, 0, 0x14
    mov     1, d0
    ret     [d2,d3,a2,a3], 0x84
    movm    [d2,d3,a2,a3], (sp)
    add     -0xc4, sp
    mov     sp, a2
    add     0x2c, a2
    mov     a2, (8, sp)
    mov     0x4859e31c, d0
    mov     d0, (0xc, sp)
    mov     (0x50021fcc), a1
    mov     a1, (0x10, sp)
    call    0x4c001a48, [a2], 0x20
    mov     (0x50021fcc), d0
    inc     d0
    mov     d0, (0x50021fcc)
    call    func_4852FDCD, 0, 8
    call    func_48530216, [d2,d3,a2,a3], 0x10
    mov     a2, a0
    mov     0x4859e32c, a1
    call    func_48532395, [a2,a3], 0x24
    exth    d0
    cmp     0, d0
    beq     0x4841589a
    clr     d0
    ret     [d2,d3,a2,a3], 0xd4
    mov     sp, a3
    add     0x3c, a3
    mov     a3, a0
    mov     0x4859e330, a1
    call    0x4c003051, [a2], 4
    mov     4, d2
    add     a3, d2
    mov     0x00012c36, d0
    mov     d2, a0
    mov     d0, (a0)
    clr     d0
    movhu   d0, (0x44, sp)
    movhu   d0, (0x46, sp)
    mov     0x76, d0
    mov     d0, (0x48, sp)
    mov     sp, a2
    add     0x4c, a2
    mov     a2, a0
    mov     2, d0
    mov     a3, a1
    call    0x4c003039, [a2,a3], 8
    mov     2, a0
    add     a2, a0
    mov     d2, a1
    mov     0xc, d0
    call    0x4c003039, [a2,a3], 8
    mov     0xe, d0
    mov     a2, a0
    call    func_48532494, [d2,a2], 0x24
    cmp     0xe, d0
    beq     0x484158f9
    call    func_485323BF, 0, 0x14
    clr     d0
    ret     [d2,d3,a2,a3], 0xd4
    mov     0x28, d0
    mov     d0, (0x5c, sp)
    mov     0x280, d0
    mov     d0, (0x60, sp)
    mov     0xf0, d0
    mov     d0, (0x64, sp)
    mov     1, d0
    movhu   d0, (0x68, sp)
    mov     4, d0
    movhu   d0, (0x6a, sp)
    clr     d0
    mov     d0, (0x6c, sp)
    mov     0x00012c00, d0
    mov     d0, (0x70, sp)
    clr     d0
    mov     d0, (0x74, sp)
    mov     d0, (0x78, sp)
    mov     d0, (0x7c, sp)
    mov     d0, (0x80, sp)
    mov     sp, a0
    add     0x5c, a0
    mov     0x28, d0
    call    func_48532494, [d2,a2], 0x24
    cmp     0x28, d0
    beq     0x48415940
    call    func_485323BF, 0, 0x14
    clr     d0
    ret     [d2,d3,a2,a3], 0xd4
    clr     d3
    mov     0x4859e2fc, a3
    mov     sp, a2
    add     0x84, a2
    mov     d3, d0
    add     d0, d0
    .byte 0xF4   # movhu (d0, a3), d0
    mov     d0, d3
    mov     0xff, d2
    exth    d0
    cmp     0xf9, d0
    beq     0x4841596b
    mov     d3, a0
    add     a0, a0
    mov     a0, d0
    .byte 0xF4   # movhu (d0, a3), d0
    mov     d0, d3
    exth    d0
    call    GetBitmapSize, 0, 0
    mov     d0, d2
    mov     d3, d1
    asl2    d1
    mov     d2, d0
    and     0x00ff0000, d0
    lsr     16, d0
    .byte 0xF4   # movbu d0, (d1, a2)
    mov     d1, (0x8d, sp)
    asl2    d1
    add     a2, d1
    mov     0x0000ff00, d0
    and     d2, d0
    lsr     8, d0
    mov     d1, a0
    movbu   d0, (1, a0)
    mov     d3, d0
    asl2    d0
    add     a2, d0
    and     0xff, d2
    mov     d0, a0
    movbu   d2, (2, a0)
    mov     d3, d0
    asl2    d0
    mov     d0, a0
    add     a2, a0
    clr     d0
    movbu   d0, (3, a0)
    inc     d3
    exth    d3
    cmp     0x10, d3
    blt     0x4841594c
    mov     sp, a0
    add     0x84, a0
    mov     0x40, d0
    call    func_48532494, [d2,a2], 0x24
    cmp     0x40, d0
    beq     0x484159c6
    call    func_485323BF, 0, 0x14
    clr     d0
    ret     [d2,d3,a2,a3], 0xd4
    mov     0xa00, d0
    call    func_4841662A, [d2,a2,a3], 0x28
    mov     a0, (0x20, sp)
    cmp     0, a0
    bne     0x484159d7
    jmp     0x48415a7b
    clr     d0
    mov     d0, (0x1c, sp)
    clr     d0
    movhu   d0, (0x28, sp)
    mov     d0, (0x18, sp)
    mov     (0x1c, sp), d0
    mov     0xf0, d1
    sub     d0, d1
    mov     d1, (0x24, sp)
    mov     (0x24, sp), d0
    mov     (0x18, sp), d1
    mov     0xfffffd80, a2
    sub     d1, d0
    mov     0x280, d1
    nop
    nop
    mul     d1, d0
    add     0x500d4080, d0
    add     d0, a2
    mov     a2, a3
    inc     a3
    clr     d0
    mov     d0, (0x14, sp)
    movbu   (a2), d0
    add     2, a2
    exth    d0
    call    ApDeleteEventMmm, 0, 0
    mov     d0, d3
    movbu   (a3), d0
    asl     4, d3
    exth    d0
    call    ApDeleteEventMmm, 0, 0
    movhu   (0x28, sp), d1
    mov     (0x20, sp), a0
    exth    d1
    add     d3, d0
    .byte 0xF4   # movbu d0, (d1, a0)
    inc     d1
    inc     d1
    movhu   d1, (0x28, sp)
    mov     (0x14, sp), d0
    add     2, a3
    inc     d0
    exth    d0
    mov     d0, (0x14, sp)
    cmp     0x140, d0
    blt     0x48415a09
    mov     (0x18, sp), d0
    inc     d0
    exth    d0
    mov     d0, (0x18, sp)
    cmp     8, d0
    blt     0x484159e9
    mov     (0x20, sp), a0
    mov     0xa00, d0
    call    func_48532494, [d2,a2], 0x24
    cmp     0xa00, d0
    beq     0x48415a64
    call    func_485323BF, 0, 0x14
    clr     d0
    bra     0x48415a84
    mov     (0x1c, sp), d0
    add     8, d0
    exth    d0
    mov     d0, (0x1c, sp)
    cmp     0xf0, d0
    bge     0x48415a74
    jmp     0x484159da
    mov     (0x20, sp), a0
    call    func_484166DE, [d2,d3,a2,a3], 0x2c
    call    func_485323BF, 0, 0x14
    mov     1, d0
    ret     [d2,d3,a2,a3], 0xd4
# CaptureLcd  (CPU 0x48415a87)
    movm    [a2], (sp)
    add     -0xc, sp
    mov     a0, a2
    call    CheckColorLcd, 0, 0
    exthu   d0
    cmp     2, d0
    beq     0x48415aa1
    mov     a2, a0
    call    func_48415AAB, [d2,d3,a2,a3], 0x94
    bra     0x48415aa2
    clr     d0
    ret     [a2], 0x10
    movm    [d2,d3,a2,a3], (sp)
    add     -0x84, sp
    mov     sp, a2
    add     0x24, a2
    mov     a2, (8, sp)
    mov     0x4859e334, d0
    mov     d0, (0xc, sp)
    mov     (0x50021fd0), a1
    mov     a0, a3
    mov     a1, (0x10, sp)
    call    0x4c001a48, [a2], 0x20
    mov     (0x50021fd0), d0
    inc     d0
    mov     d0, (0x50021fd0)
    call    func_4852FDCD, 0, 8
    call    func_48530216, [d2,d3,a2,a3], 0x10
    mov     a2, a0
    mov     0x4859e344, a1
    call    func_48532395, [a2,a3], 0x24
    exth    d0
    cmp     0, d0
    beq     0x48415afa
    clr     d0
    ret     [d2,d3,a2,a3], 0x94
    mov     4, d0
    add     a3, d0
    mov     d0, (0x14, sp)
    mov     d0, a0
    movhu   (a0), d2
    movhu   (a3), d1
    mov     6, d3
    add     a3, d3
    mov     d3, a0
    movhu   (a0), d0
    mov     2, a2
    add     a3, a2
    exth    d2
    exth    d1
    sub     d1, d2
    movhu   (a2), d1
    inc     d2
    exth    d0
    exth    d1
    exth    d2
    mov     d2, (0x18, sp)
    sub     d1, d0
    inc     d0
    exth    d0
    mov     d0, (0x1c, sp)
    mov     (0x18, sp), a0
    mov     4, d1
    nop
    nop
    mul     d0, d2
    mov     a0, d0
    asl2    d0
    sub     a0, d0
    add     3, d0
    call    0x4c0019d5, 0, 0
    asl2    d0
    mov     d0, (0x20, sp)
    movhu   (a2), d0
    mov     sp, a2
    movhu   d0, (0x36, sp)
    movhu   (a3), d0
    movhu   d0, (0x34, sp)
    mov     (0x14, sp), a0
    movhu   (a0), d0
    mov     d3, a0
    movhu   d0, (0x38, sp)
    movhu   (a0), d0
    mov     sp, a3
    movhu   d0, (0x3a, sp)
    add     0x3c, a3
    mov     a3, a0
    mov     d2, d0
    asl2    d0
    mov     d0, d3
    sub     d2, d3
    mov     0x4859e348, a1
    call    0x4c003051, [a2], 4
    add     0x4c, a2
    mov     a3, a1
    mov     4, d2
    add     a3, d2
    mov     d2, a0
    mov     0x36, d0
    add     d3, d0
    mov     d0, (a0)
    mov     a2, a0
    clr     d0
    movhu   d0, (0x44, sp)
    movhu   d0, (0x46, sp)
    mov     0x36, d0
    mov     d0, (0x48, sp)
    mov     2, d0
    call    0x4c003039, [a2,a3], 8
    mov     d2, a1
    mov     2, a0
    add     a2, a0
    mov     0xc, d0
    call    0x4c003039, [a2,a3], 8
    mov     a2, a0
    mov     0xe, d0
    call    func_48532494, [d2,a2], 0x24
    cmp     0xe, d0
    beq     0x48415bb6
    call    func_485323BF, 0, 0x14
    clr     d0
    ret     [d2,d3,a2,a3], 0x94
    mov     0x28, d0
    mov     d0, (0x5c, sp)
    mov     (0x18, sp), d0
    mov     sp, a0
    mov     d0, (0x60, sp)
    mov     (0x1c, sp), d0
    add     0x5c, a0
    mov     d0, (0x64, sp)
    mov     1, d0
    movhu   d0, (0x68, sp)
    mov     0x18, d0
    movhu   d0, (0x6a, sp)
    clr     d0
    mov     d0, (0x6c, sp)
    mov     d3, (0x70, sp)
    mov     d0, (0x74, sp)
    mov     d0, (0x78, sp)
    mov     d0, (0x7c, sp)
    mov     d0, (0x80, sp)
    mov     0x28, d0
    call    func_48532494, [d2,a2], 0x24
    cmp     0x28, d0
    beq     0x48415bf4
    call    func_485323BF, 0, 0x14
    clr     d0
    ret     [d2,d3,a2,a3], 0x94
    mov     (0x20, sp), d0
    call    func_4841662A, [d2,a2,a3], 0x28
    mov     a0, (0x14, sp)
    cmp     0, a0
    bne     0x48415c04
    jmp     0x48415cc9
    clr     d0
    mov     d0, (0x18, sp)
    mov     (0x1c, sp), d0
    cmp     0, d0
    bgt     0x48415c10
    jmp     0x48415cc2
    clr     d1
    mov     0, a3
    mov     (0x1c, sp), d3
    movhu   (0x36, sp), d0
    movhu   (0x34, sp), d2
    exth    d0
    exth    d2
    add     d3, d0
    mov     (0x18, sp), d3
    add     -1, d0
    sub     d3, d0
    sub     a3, d0
    mov     0x280, d3
    nop
    nop
    mul     d3, d0
    add     d2, d0
    add     d0, d0
    add     0x9ce00000, d0
    mov     0x500, a2
    add     d0, a2
    movhu   (0x34, sp), d0
    exth    d0
    mov     d0, a1
    movhu   (0x38, sp), d0
    exth    d0
    cmp     d0, a1
    bgt     0x48415c89
    setlb
    movhu   (a2), d3
    mov     (0x14, sp), a0
    mov     d1, d2
    exth    d2
    exthu   d3
    mov     0x1f, d0
    and     d3, d0
    asl     3, d0
    .byte 0xF4   # movbu d0, (d2, a0)
    inc     d2
    mov     (0x14, sp), a0
    inc     d2
    mov     d2, d1
    exth    d1
    mov     0x7e0, d0
    and     d3, d0
    asr     3, d0
    .byte 0xF4   # movbu d0, (d1, a0)
    inc     d1
    mov     (0x14, sp), a0
    exth    d2
    inc     d2
    mov     d2, d1
    exth    d1
    and     0xf800, d3
    asr     8, d3
    .byte 0xF4   # movbu d3, (d1, a0)
    mov     (a0), d1
    exth    d2
    mov     a1, d0
    inc     d0
    exth    d0
    mov     d0, a1
    movhu   (0x38, sp), d0
    mov     d2, d1
    inc     d1
    add     2, a2
    exth    d0
    cmp     d0, a1
    lle
    mov     a3, d0
    inc     d0
    exth    d0
    mov     d0, a3
    cmp     1, d0
    blt     0x48415c13
    mov     (0x14, sp), a0
    mov     (0x20, sp), d0
    call    func_48532494, [d2,a2], 0x24
    mov     (0x20, sp), d1
    cmp     d1, d0
    beq     0x48415cb4
    call    func_485323BF, 0, 0x14
    mov     (0x14, sp), a0
    call    func_484166DE, [d2,d3,a2,a3], 0x2c
    clr     d0
    bra     0x48415cd2
    mov     (0x18, sp), d0
    mov     (0x1c, sp), d1
    inc     d0
    exth    d0
    mov     d0, (0x18, sp)
    cmp     d1, d0
    bge     0x48415cc2
    jmp     0x48415c10
    mov     (0x14, sp), a0
    call    func_484166DE, [d2,d3,a2,a3], 0x2c
    call    func_485323BF, 0, 0x14
    mov     1, d0
    ret     [d2,d3,a2,a3], 0x94
# MainMmmControl  (CPU 0x48415cd5)
.incbin_range "baserom/kn7000_program.rom", 0x015cd5, 0x015ce3
# MainBitControl  (CPU 0x48415ce3)
.incbin_range "baserom/kn7000_program.rom", 0x015ce3, 0x015ed2
# MainGetPmemName  (CPU 0x48415ed2)
.incbin_range "baserom/kn7000_program.rom", 0x015ed2, 0x015fdc
# MainAutoFree  (CPU 0x48415fdc)
.incbin_range "baserom/kn7000_program.rom", 0x015fdc, 0x016148
# VwBitmapFileProc  (CPU 0x48416148)
.incbin_range "baserom/kn7000_program.rom", 0x016148, 0x016204
# MainGetSoundName  (CPU 0x48416204)
.incbin_range "baserom/kn7000_program.rom", 0x016204, 0x01622e
# MainGetRhythmName  (CPU 0x4841622e)
.incbin_range "baserom/kn7000_program.rom", 0x01622e, 0x0162ff
# MainTaskControl  (CPU 0x484162ff)
.incbin_range "baserom/kn7000_program.rom", 0x0162ff, 0x016334
# MainRamControl  (CPU 0x48416334)
.incbin_range "baserom/kn7000_program.rom", 0x016334, 0x01633c
# MainTitleControl  (CPU 0x4841633c)
.incbin_range "baserom/kn7000_program.rom", 0x01633c, 0x01648c
# AcLanguageTextProc  (CPU 0x4841648c)
.incbin_range "baserom/kn7000_program.rom", 0x01648c, 0x0164a8
# SetModeLed  (CPU 0x484164a8)
.incbin_range "baserom/kn7000_program.rom", 0x0164a8, 0x0164f4
# InterruptTitleEZ  (CPU 0x484164f4)
.incbin_range "baserom/kn7000_program.rom", 0x0164f4, 0x016512
# SetOtherPartLed  (CPU 0x48416512)
.incbin_range "baserom/kn7000_program.rom", 0x016512, 0x016536
# SetHoldLed  (CPU 0x48416536)
.incbin_range "baserom/kn7000_program.rom", 0x016536, 0x01655a
# TitleFuncCall  (CPU 0x4841655a)
.incbin_range "baserom/kn7000_program.rom", 0x01655a, 0x016563
# GetMode2Sw  (CPU 0x48416563)
.incbin_range "baserom/kn7000_program.rom", 0x016563, 0x016587
# InitializeTaskTimer  (CPU 0x48416587)
.incbin_range "baserom/kn7000_program.rom", 0x016587, 0x016590
# SetDialLed  (CPU 0x48416590)
.incbin_range "baserom/kn7000_program.rom", 0x016590, 0x0167e0
# DrawWallPreview  (CPU 0x484167e0)
.incbin_range "baserom/kn7000_program.rom", 0x0167e0, 0x01688b
# IvPR604Proc  (CPU 0x4841688b)
.incbin_range "baserom/kn7000_program.rom", 0x01688b, 0x0168d2
# ShiftBox  (CPU 0x484168d2)
.incbin_range "baserom/kn7000_program.rom", 0x0168d2, 0x016908
# VwEditSwLineProc  (CPU 0x48416908)
.incbin_range "baserom/kn7000_program.rom", 0x016908, 0x016986
# VwTextBoxProc  (CPU 0x48416986)
.incbin_range "baserom/kn7000_program.rom", 0x016986, 0x016ae2
# SetBox  (CPU 0x48416ae2)
.incbin_range "baserom/kn7000_program.rom", 0x016ae2, 0x016af7
# GetClientBox  (CPU 0x48416af7)
.incbin_range "baserom/kn7000_program.rom", 0x016af7, 0x016def
# GetViewInstance  (CPU 0x48416def)
.incbin_range "baserom/kn7000_program.rom", 0x016def, 0x016e04
# GetBox  (CPU 0x48416e04)
.incbin_range "baserom/kn7000_program.rom", 0x016e04, 0x016e2e
# DrawStringReverse  (CPU 0x48416e2e)
.incbin_range "baserom/kn7000_program.rom", 0x016e2e, 0x016e6d
# DrawDesignBox  (CPU 0x48416e6d)
    add     -8, sp
    call    SetLcdMode, 0, 0
    mov     d0, d1
    exthu   d1
    mov     0xff, d0
    cmp     1, d1
    beq     0x48416e87
    mov     7, d0
    cmp     2, d1
    beq     0x48416e87
    clr     d0
    ret     0, 8
# GetFrameColor  (CPU 0x48416e8a)
.incbin_range "baserom/kn7000_program.rom", 0x016e8a, 0x016eac
# BoxLeftCheck  (CPU 0x48416eac)
.incbin_range "baserom/kn7000_program.rom", 0x016eac, 0x016ece
# MainRamGet  (CPU 0x48416ece)
.incbin_range "baserom/kn7000_program.rom", 0x016ece, 0x017600
# IvSpecWinProc  (CPU 0x48417600)
.incbin_range "baserom/kn7000_program.rom", 0x017600, 0x017609
# CheckProgDial  (CPU 0x48417609)
.incbin_range "baserom/kn7000_program.rom", 0x017609, 0x017612
# IvMainEditSwProc  (CPU 0x48417612)
.incbin_range "baserom/kn7000_program.rom", 0x017612, 0x01768d
# IvCatchEventProc  (CPU 0x4841768d)
.incbin_range "baserom/kn7000_program.rom", 0x01768d, 0x0176cc
# SetDialFocus  (CPU 0x484176cc)
    mov     (0x5000070c), d0
    retf    0, 0
# SetDialEnable  (CPU 0x484176d5)
.incbin_range "baserom/kn7000_program.rom", 0x0176d5, 0x0176f4
# SetDialUp  (CPU 0x484176f4)
.incbin_range "baserom/kn7000_program.rom", 0x0176f4, 0x017713
# GetRootParam  (CPU 0x48417713)
.incbin_range "baserom/kn7000_program.rom", 0x017713, 0x01773b
# SetAutoIncDefault  (CPU 0x4841773b)
.incbin_range "baserom/kn7000_program.rom", 0x01773b, 0x017810
# BoxRightCheck  (CPU 0x48417810)
.incbin_range "baserom/kn7000_program.rom", 0x017810, 0x017b24
# ScreenProc  (CPU 0x48417b24)
    add     -0x10, sp
    exthu   d0
    call    SetProgDial, 0, 0
    ret     0, 0x10
# SetProgDial  (CPU 0x48417b30)
.incbin_range "baserom/kn7000_program.rom", 0x017b30, 0x017b80
# VwUserBitmapProc  (CPU 0x48417b80)
.incbin_range "baserom/kn7000_program.rom", 0x017b80, 0x017ba5
# DrawDesignFrame  (CPU 0x48417ba5)
.incbin_range "baserom/kn7000_program.rom", 0x017ba5, 0x017dda
# AcIndexPushSwProc  (CPU 0x48417dda)
.incbin_range "baserom/kn7000_program.rom", 0x017dda, 0x017def
# SetTempoObject  (CPU 0x48417def)
.incbin_range "baserom/kn7000_program.rom", 0x017def, 0x017e04
# TtlScreenProc  (CPU 0x48417e04)
.incbin_range "baserom/kn7000_program.rom", 0x017e04, 0x017e6d
# DrawTitleBar  (CPU 0x48417e6d)
.incbin_range "baserom/kn7000_program.rom", 0x017e6d, 0x0180a1
# GroupBoxProc  (CPU 0x484180a1)
.incbin_range "baserom/kn7000_program.rom", 0x0180a1, 0x01846e
# GetSoundDev  (CPU 0x4841846e)
.incbin_range "baserom/kn7000_program.rom", 0x01846e, 0x018473
# WindowProc  (CPU 0x48418473)
.incbin_range "baserom/kn7000_program.rom", 0x018473, 0x0184cf
# VwStrBoxProc  (CPU 0x484184cf)
.incbin_range "baserom/kn7000_program.rom", 0x0184cf, 0x0185b2
# ConvPaletteMono4  (CPU 0x484185b2)
    add     -0x14, sp
    cmp     0x600ee, d1
    bne     0x484185c9
    call    GetLinkView, 0, 0
    movhu   (0x24, a0), d0
    bra     0x484185d4
    mov     (0x24, sp), a0
    mov     a0, (0x10, sp)
    call    func_48429569, [d2,d3,a2,a3], 0x28
    ret     0, 0x14
# VwLabelProc  (CPU 0x484185d7)
.incbin_range "baserom/kn7000_program.rom", 0x0185d7, 0x018625
# DrawBitmapSP  (CPU 0x48418625)
.incbin_range "baserom/kn7000_program.rom", 0x018625, 0x018764
# LanguageCheck  (CPU 0x48418764)
.incbin_range "baserom/kn7000_program.rom", 0x018764, 0x0187ac
# ApDeliveryEvent  (CPU 0x484187ac)
.incbin_range "baserom/kn7000_program.rom", 0x0187ac, 0x01880e
# SetColorMode  (CPU 0x4841880e)
.incbin_range "baserom/kn7000_program.rom", 0x01880e, 0x0189c2
# JpegFileCheck  (CPU 0x484189c2)
.incbin_range "baserom/kn7000_program.rom", 0x0189c2, 0x0189ec
# VwBitmapProc  (CPU 0x484189ec)
.incbin_range "baserom/kn7000_program.rom", 0x0189ec, 0x018a7d
# VwIconProc  (CPU 0x48418a7d)
.incbin_range "baserom/kn7000_program.rom", 0x018a7d, 0x018b81
# VwEditSwLabelProc  (CPU 0x48418b81)
    add     -0x14, sp
    cmp     0x600ee, d1
    bne     0x48418b98
    call    GetLinkView, 0, 0
    movhu   (0x1c, a0), d0
    bra     0x48418ba3
    mov     (0x24, sp), a0
    mov     a0, (0x10, sp)
    call    func_48429569, [d2,d3,a2,a3], 0x28
    ret     0, 0x14
# GetEditSwPoint  (CPU 0x48418ba6)
.incbin_range "baserom/kn7000_program.rom", 0x018ba6, 0x018c2f
# VwFrameProc  (CPU 0x48418c2f)
.incbin_range "baserom/kn7000_program.rom", 0x018c2f, 0x018c63
# GetClientFrame  (CPU 0x48418c63)
.incbin_range "baserom/kn7000_program.rom", 0x018c63, 0x018cb7
# GetClientFrame2  (CPU 0x48418cb7)
.incbin_range "baserom/kn7000_program.rom", 0x018cb7, 0x018d19
# SetZeroPoint  (CPU 0x48418d19)
.incbin_range "baserom/kn7000_program.rom", 0x018d19, 0x018f52
# EasySetControl  (CPU 0x48418f52)
.incbin_range "baserom/kn7000_program.rom", 0x018f52, 0x018f66
# VwBoxProc  (CPU 0x48418f66)
.incbin_range "baserom/kn7000_program.rom", 0x018f66, 0x01908d
# PsCursorBoxProc  (CPU 0x4841908d)
.incbin_range "baserom/kn7000_program.rom", 0x01908d, 0x0191d0
# AcIndexToggleProc  (CPU 0x484191d0)
.incbin_range "baserom/kn7000_program.rom", 0x0191d0, 0x0192ff
# AcMmmBoxProc  (CPU 0x484192ff)
.incbin_range "baserom/kn7000_program.rom", 0x0192ff, 0x0194a2
# AcRamBoxProc  (CPU 0x484194a2)
.incbin_range "baserom/kn7000_program.rom", 0x0194a2, 0x019883
# PsRadioBoxProc  (CPU 0x48419883)
.incbin_range "baserom/kn7000_program.rom", 0x019883, 0x0198b4
# GetDialFocus  (CPU 0x484198b4)
.incbin_range "baserom/kn7000_program.rom", 0x0198b4, 0x019e34
# PsGridBoxProc  (CPU 0x48419e34)
.incbin_range "baserom/kn7000_program.rom", 0x019e34, 0x01a07d
# PsListBoxProc  (CPU 0x4841a07d)
.incbin_range "baserom/kn7000_program.rom", 0x01a07d, 0x01ae18
# AcListBoxProc  (CPU 0x4841ae18)
.incbin_range "baserom/kn7000_program.rom", 0x01ae18, 0x01b132
# DefaultClassProc  (CPU 0x4841b132)
.incbin_range "baserom/kn7000_program.rom", 0x01b132, 0x01b1d1
# AcTempoBoxProc  (CPU 0x4841b1d1)
.incbin_range "baserom/kn7000_program.rom", 0x01b1d1, 0x01b8e3
# PsEditBoxProc  (CPU 0x4841b8e3)
.incbin_range "baserom/kn7000_program.rom", 0x01b8e3, 0x01b96d
# PsNumEditBoxProc  (CPU 0x4841b96d)
.incbin_range "baserom/kn7000_program.rom", 0x01b96d, 0x01b9c6
# RamEditCheck  (CPU 0x4841b9c6)
.incbin_range "baserom/kn7000_program.rom", 0x01b9c6, 0x01b9eb
# PsTblEditBoxProc  (CPU 0x4841b9eb)
.incbin_range "baserom/kn7000_program.rom", 0x01b9eb, 0x01bb45
# AcOnOffBoxProc  (CPU 0x4841bb45)
.incbin_range "baserom/kn7000_program.rom", 0x01bb45, 0x01be8e
# AcNumEditBoxProc  (CPU 0x4841be8e)
.incbin_range "baserom/kn7000_program.rom", 0x01be8e, 0x01c29b
# DefaultFunction  (CPU 0x4841c29b)
.incbin_range "baserom/kn7000_program.rom", 0x01c29b, 0x01c32f
# ProcCall  (CPU 0x4841c32f)
.incbin_range "baserom/kn7000_program.rom", 0x01c32f, 0x01c377
# MainGetM3Em  (CPU 0x4841c377)
.incbin_range "baserom/kn7000_program.rom", 0x01c377, 0x01c3bf
# MainPutM3Em  (CPU 0x4841c3bf)
.incbin_range "baserom/kn7000_program.rom", 0x01c3bf, 0x01c40a
# AcTransposeBoxProc  (CPU 0x4841c40a)
.incbin_range "baserom/kn7000_program.rom", 0x01c40a, 0x01c43a
# AcMmmEditBoxProc  (CPU 0x4841c43a)
.incbin_range "baserom/kn7000_program.rom", 0x01c43a, 0x01c802
# MmmEditCheck  (CPU 0x4841c802)
.incbin_range "baserom/kn7000_program.rom", 0x01c802, 0x01c88b
# DrawEditSw  (CPU 0x4841c88b)
.incbin_range "baserom/kn7000_program.rom", 0x01c88b, 0x01c8d0
# MainRamPut  (CPU 0x4841c8d0)
.incbin_range "baserom/kn7000_program.rom", 0x01c8d0, 0x01c915
# MainRamAdd  (CPU 0x4841c915)
.incbin_range "baserom/kn7000_program.rom", 0x01c915, 0x01c963
# VwEditSwBoxProc  (CPU 0x4841c963)
.incbin_range "baserom/kn7000_program.rom", 0x01c963, 0x01cbdd
# PasTableCheck  (CPU 0x4841cbdd)
.incbin_range "baserom/kn7000_program.rom", 0x01cbdd, 0x01cc3b
# AcBitEditBoxProc  (CPU 0x4841cc3b)
.incbin_range "baserom/kn7000_program.rom", 0x01cc3b, 0x01cc80
# MainBitPut  (CPU 0x4841cc80)
.incbin_range "baserom/kn7000_program.rom", 0x01cc80, 0x01ccc8
# AcRamEditBoxProc  (CPU 0x4841ccc8)
.incbin_range "baserom/kn7000_program.rom", 0x01ccc8, 0x01d0ec
# PsMenuBoxProc  (CPU 0x4841d0ec)
.incbin_range "baserom/kn7000_program.rom", 0x01d0ec, 0x01d24b
# AcMixerVolProc  (CPU 0x4841d24b)
.incbin_range "baserom/kn7000_program.rom", 0x01d24b, 0x01d2bb
# AcTitleMenuProc  (CPU 0x4841d2bb)
.incbin_range "baserom/kn7000_program.rom", 0x01d2bb, 0x01d81b
# DrawTitleBarOW  (CPU 0x4841d81b)
.incbin_range "baserom/kn7000_program.rom", 0x01d81b, 0x01d952
# PsEditSwBoxProc  (CPU 0x4841d952)
.incbin_range "baserom/kn7000_program.rom", 0x01d952, 0x01d9b2
# PsWideESBoxProc  (CPU 0x4841d9b2)
.incbin_range "baserom/kn7000_program.rom", 0x01d9b2, 0x01dbbf
# AcIndexEditSwProc  (CPU 0x4841dbbf)
.incbin_range "baserom/kn7000_program.rom", 0x01dbbf, 0x01dcc1
# VwMenuBoxProc  (CPU 0x4841dcc1)
.incbin_range "baserom/kn7000_program.rom", 0x01dcc1, 0x01dd90
# PassEvent  (CPU 0x4841dd90)
.incbin_range "baserom/kn7000_program.rom", 0x01dd90, 0x01df23
# AcFuncEditSwProc  (CPU 0x4841df23)
.incbin_range "baserom/kn7000_program.rom", 0x01df23, 0x01e0ce
# PsPageBoxProc  (CPU 0x4841e0ce)
.incbin_range "baserom/kn7000_program.rom", 0x01e0ce, 0x01e1cd
# AcWindowPageProc  (CPU 0x4841e1cd)
.incbin_range "baserom/kn7000_program.rom", 0x01e1cd, 0x01e5c5
# MainBitGet  (CPU 0x4841e5c5)
.incbin_range "baserom/kn7000_program.rom", 0x01e5c5, 0x01e637
# IvFixWinProc  (CPU 0x4841e637)
.incbin_range "baserom/kn7000_program.rom", 0x01e637, 0x01e894
# AcFuncToggleProc  (CPU 0x4841e894)
.incbin_range "baserom/kn7000_program.rom", 0x01e894, 0x01e8f4
# PsToggleBoxProc  (CPU 0x4841e8f4)
.incbin_range "baserom/kn7000_program.rom", 0x01e8f4, 0x01e92c
# PsInvisibleBoxProc  (CPU 0x4841e92c)
.incbin_range "baserom/kn7000_program.rom", 0x01e92c, 0x01e9eb
# IvPageControlProc  (CPU 0x4841e9eb)
.incbin_range "baserom/kn7000_program.rom", 0x01e9eb, 0x01eae3
# GetFocusParam  (CPU 0x4841eae3)
.incbin_range "baserom/kn7000_program.rom", 0x01eae3, 0x01eb4f
# IvExitProc  (CPU 0x4841eb4f)
.incbin_range "baserom/kn7000_program.rom", 0x01eb4f, 0x01ec0b
# IvExitModeProc  (CPU 0x4841ec0b)
.incbin_range "baserom/kn7000_program.rom", 0x01ec0b, 0x01ec82
# IvTrackSwitchProc  (CPU 0x4841ec82)
.incbin_range "baserom/kn7000_program.rom", 0x01ec82, 0x01ed01
# GetBoxCenter  (CPU 0x4841ed01)
.incbin_range "baserom/kn7000_program.rom", 0x01ed01, 0x01ed7b
# InitializeResource  (CPU 0x4841ed7b)
.incbin_range "baserom/kn7000_program.rom", 0x01ed7b, 0x01edf5
# IvOthJpnWinProc  (CPU 0x4841edf5)
.incbin_range "baserom/kn7000_program.rom", 0x01edf5, 0x01ef41
# DrawFuncParam  (CPU 0x4841ef41)
.incbin_range "baserom/kn7000_program.rom", 0x01ef41, 0x01efc0
# AcTrackSwitchProc  (CPU 0x4841efc0)
.incbin_range "baserom/kn7000_program.rom", 0x01efc0, 0x01f018
# AcStrRadioBoxProc  (CPU 0x4841f018)
.incbin_range "baserom/kn7000_program.rom", 0x01f018, 0x01f08b
# BitEditCheck  (CPU 0x4841f08b)
.incbin_range "baserom/kn7000_program.rom", 0x01f08b, 0x01f0d9
# SetNotDrawFlag  (CPU 0x4841f0d9)
.incbin_range "baserom/kn7000_program.rom", 0x01f0d9, 0x01f160
# SetDialDown  (CPU 0x4841f160)
.incbin_range "baserom/kn7000_program.rom", 0x01f160, 0x01f3a0
# AcSoundNameProc  (CPU 0x4841f3a0)
.incbin_range "baserom/kn7000_program.rom", 0x01f3a0, 0x01f455
# AcRhythmNameProc  (CPU 0x4841f455)
.incbin_range "baserom/kn7000_program.rom", 0x01f455, 0x01f5c9
# AcPmemNameProc  (CPU 0x4841f5c9)
.incbin_range "baserom/kn7000_program.rom", 0x01f5c9, 0x01fdda
# SetPageObject  (CPU 0x4841fdda)
.incbin_range "baserom/kn7000_program.rom", 0x01fdda, 0x01fe6a
# PsParaBoxProc  (CPU 0x4841fe6a)
.incbin_range "baserom/kn7000_program.rom", 0x01fe6a, 0x02012f
# AcGridBoxProc  (CPU 0x4842012f)
.incbin_range "baserom/kn7000_program.rom", 0x02012f, 0x0205b8
# PsTrackSwitchProc  (CPU 0x484205b8)
.incbin_range "baserom/kn7000_program.rom", 0x0205b8, 0x020652
# IvShowHideProc  (CPU 0x48420652)
.incbin_range "baserom/kn7000_program.rom", 0x020652, 0x020869
# VwLineProc  (CPU 0x48420869)
.incbin_range "baserom/kn7000_program.rom", 0x020869, 0x0208ba
# PsTextBoxProc  (CPU 0x484208ba)
.incbin_range "baserom/kn7000_program.rom", 0x0208ba, 0x0209b7
# GridCheck  (CPU 0x484209b7)
.incbin_range "baserom/kn7000_program.rom", 0x0209b7, 0x0209e7
# ApTaskControl  (CPU 0x484209e7)
.incbin_range "baserom/kn7000_program.rom", 0x0209e7, 0x020a2c
# KisyuCheck  (CPU 0x48420a2c)
.incbin_range "baserom/kn7000_program.rom", 0x020a2c, 0x020a71
# SpecCheck  (CPU 0x48420a71)
.incbin_range "baserom/kn7000_program.rom", 0x020a71, 0x020ab6
# DrawBitmapSPFast16  (CPU 0x48420ab6)
.incbin_range "baserom/kn7000_program.rom", 0x020ab6, 0x020def
# ApDeleteSpecificEvent  (CPU 0x48420def)
.incbin_range "baserom/kn7000_program.rom", 0x020def, 0x0210b7
# PsVariSelectProc  (CPU 0x484210b7)
.incbin_range "baserom/kn7000_program.rom", 0x0210b7, 0x0212b1
# DrawJpegFile  (CPU 0x484212b1)
.incbin_range "baserom/kn7000_program.rom", 0x0212b1, 0x02168a
# AcChordBoxProc  (CPU 0x4842168a)
.incbin_range "baserom/kn7000_program.rom", 0x02168a, 0x02179b
# GetChordString  (CPU 0x4842179b)
.incbin_range "baserom/kn7000_program.rom", 0x02179b, 0x021804
# InitializeBlock31  (CPU 0x48421804)
.incbin_range "baserom/kn7000_program.rom", 0x021804, 0x0218ef
# RefreshSwEvent  (CPU 0x484218ef)
    add     -8, sp
    call    func_484218FF, [a2], 0x20
    ret     0, 8
    movm    [a2], (sp)
    add     -0x1c, sp
    movhu   (0x500d3c64), d0
    mov     0x5000757c, a2
    exth    d0
    mov     a2, a0
    mov     0x38, d1
    nop
    nop
    mul     d1, d0
    add     d0, a0
    movhu   (8, a0), d0
    mov     sp, a0
    exth    d0
    add     0x18, a0
    mov     1, d1
    mov     d1, (0x14, sp)
    call    0x4c03c5af, 0, 0
    call    func_48421A27, 0, 0
    movhu   (0x500d3c64), d0
    mov     0x38, d1
    exth    d0
    nop
    nop
    mul     d1, d0
    add     d0, a2
    movhu   (8, a2), d0
    mov     1, d1
    exth    d0
    call    0x4c03cd7f, 0, 0
    ret     [a2], 0x20
    movm    [a2,a3], (sp)
    add     -0x1c, sp
    movhu   (0x500d3c64), d0
    mov     0x5000757c, a3
    exth    d0
    mov     0x38, d1
    nop
    nop
    mul     d0, d1
    mov     d1, a0
    add     a3, a0
    movhu   (8, a0), d0
    mov     sp, a0
    exth    d0
    add     0x18, a0
    mov     1, d1
    mov     d1, (0x14, sp)
    call    0x4c03c5af, 0, 0
    call    func_48421A5E, 0, 0
    movhu   (0x500d3c64), d0
    mov     0x38, d1
    exth    d0
    nop
    nop
    mul     d1, d0
    add     d0, a3
    movhu   (8, a3), d0
    mov     a0, a2
    exth    d0
    mov     1, d1
    call    0x4c03cd7f, 0, 0
    mov     a2, a0
    ret     [a2,a3], 0x24
    movm    [d2,a2,a3], (sp)
    add     -0x1c, sp
    mov     a0, (0x30, sp)
    mov     sp, a3
    add     0x18, a3
    mov     0x5000757c, d2
    movhu   (0x500d3c64), d0
    mov     0x38, d1
    exth    d0
    nop
    nop
    mul     d0, d1
    mov     d1, a0
    add     d2, a0
    movhu   (8, a0), d0
    mov     a3, a0
    exth    d0
    mov     1, d1
    mov     d1, (0x14, sp)
    call    0x4c03c5af, 0, 0
    mov     (0x30, sp), a0
    call    func_48421AB1, [a2], 4
    movhu   (0x500d3c64), d0
    mov     0x38, d1
    exth    d0
    nop
    nop
    mul     d1, d0
    add     d2, d0
    mov     1, d1
    mov     a0, a2
    mov     d0, a0
    movhu   (8, a0), d0
    exth    d0
    call    0x4c03cd7f, 0, 0
    movhu   (0x500d3c64), d0
    mov     0x38, d1
    exth    d0
    nop
    nop
    mul     d1, d0
    add     d2, d0
    mov     d0, a0
    movhu   (6, a0), d0
    mov     1, d1
    exth    d0
    call    0x4c03cd7f, 0, 0
    cmp     0, a2
    bne     0x48421a1f
    clr     d0
    mov     d0, d1
    call    0x4c03c0e4, 0, 0
    cmp     0, a2
    beq     0x484219af
    mov     a2, a0
    ret     [d2,a2,a3], 0x28
    clr     d0
    movhu   d0, (0x5011f880)
    movhu   d0, (0x5011f882)
    movhu   d0, (0x5011f884)
    movhu   d0, (0x5011f886)
    mov     0x1ff, d0
    movhu   d0, (0x5011f888)
    mov     0x5002a034, a0
    mov     a0, (0x5002c034)
    mov     a0, (0x5002c038)
    retf    0, 0
    movhu   (0x5011f882), d1
    movhu   (0x5011f886), d0
    exth    d1
    exth    d0
    cmp     d0, d1
    mov     0, a0
    beq     0x48421aac
    movhu   (0x5011f882), d0
    mov     0x5011f88c, a0
    exth    d0
    asl2    d0
    mov     (d0, a0), a0
    movhu   (0x5011f882), d0
    exth    d0
    inc     d0
    movhu   d0, (0x5011f882)
    exth    d0
    cmp     0x80, d0
    blt     0x48421a9d
    clr     d0
    movhu   d0, (0x5011f882)
    movhu   (0x5011f888), d0
    exth    d0
    add     4, d0
    movhu   d0, (0x5011f888)
    retf    0, 0
    movm    [a2], (sp)
    movhu   (0x5011f888), d0
    mov     a0, a2
    exth    d0
    cmp     4, d0
    mov     0, a0
    bcs     0x48421b06
    movhu   (0x5011f886), d0
    mov     0x5011f88c, a0
    exth    d0
    asl2    d0
    mov     a2, (d0, a0)
    movhu   (0x5011f886), d0
    exth    d0
    asl2    d0
    add     d0, a0
    movhu   (0x5011f886), d0
    exth    d0
    inc     d0
    movhu   d0, (0x5011f886)
    exth    d0
    cmp     0x80, d0
    blt     0x48421af5
    clr     d0
    movhu   d0, (0x5011f886)
    movhu   (0x5011f888), d0
    mov     4, d1
    exth    d0
    sub     d1, d0
    movhu   d0, (0x5011f888)
    retf    [a2], 4
    movhu   (0x5011f882), d0
    movhu   d0, (0x5011f880)
    retf    0, 0
    movhu   (0x5011f880), d1
    movhu   (0x5011f886), d0
    exth    d1
    exth    d0
    cmp     d0, d1
    mov     0, a0
    beq     0x48421b57
    movhu   (0x5011f880), d0
    mov     0x5011f88c, a0
    exth    d0
    asl2    d0
    mov     (d0, a0), a0
    movhu   (0x5011f880), d0
    exth    d0
    inc     d0
    movhu   d0, (0x5011f880)
    exth    d0
    cmp     0x80, d0
    blt     0x48421b57
    clr     d0
    movhu   d0, (0x5011f880)
    retf    0, 0
    movm    [d2], (sp)
    add     3, d0
    mov     d0, d2
    lsr     2, d2
    asl2    d2
    mov     (0x5002c038), a0
    mov     0x5002a034, d0
    mov     a0, d1
    sub     d0, d1
    add     d2, d1
    cmp     0x2000, d1
    bcc     0x48421b85
    mov     a0, d0
    add     d2, d0
    mov     d0, (0x5002c038)
    bra     0x48421b8e
    mov     d0, a0
    add     d2, d0
    mov     d0, (0x5002c038)
    retf    [d2], 4
    retf    0, 0
    add     -0x10, sp
    mov     sp, a0
    add     0xc, a0
    call    0x4c03dc38, [d2,d3,a2], 0x1c
    movhu   (0xc, sp), d1
    movhu   (0x500d3c64), d0
    exth    d1
    exth    d0
    cmp     d0, d1
    bne     0x48421bb3
    mov     1, d0
    bra     0x48421bb4
    clr     d0
    ret     0, 0x10
# SetRootParam  (CPU 0x48421bb7)
.incbin_range "baserom/kn7000_program.rom", 0x021bb7, 0x021c59
# ShiftSize  (CPU 0x48421c59)
.incbin_range "baserom/kn7000_program.rom", 0x021c59, 0x021d4c
# SetLcdMode  (CPU 0x48421d4c)
    movhu   (0x50007578), d0
    retf    0, 0
# GetColorMode  (CPU 0x48421d55)
.incbin_range "baserom/kn7000_program.rom", 0x021d55, 0x021d5e
# CheckColorLcd  (CPU 0x48421d5e)
    movhu   (0x5000757a), d0
    retf    0, 0
# Check2BitLcd  (CPU 0x48421d67)
.incbin_range "baserom/kn7000_program.rom", 0x021d67, 0x021d70
# DrawBitmapSP2  (CPU 0x48421d70)
.incbin_range "baserom/kn7000_program.rom", 0x021d70, 0x021d82
# Draw2BpFile  (CPU 0x48421d82)
.incbin_range "baserom/kn7000_program.rom", 0x021d82, 0x021d94
# DrawBitmapFileEx  (CPU 0x48421d94)
.incbin_range "baserom/kn7000_program.rom", 0x021d94, 0x021dbe
# BfFile2Struct  (CPU 0x48421dbe)
.incbin_range "baserom/kn7000_program.rom", 0x021dbe, 0x021de1
# BfStruct2File  (CPU 0x48421de1)
.incbin_range "baserom/kn7000_program.rom", 0x021de1, 0x021e88
# DrawJpegFileR  (CPU 0x48421e88)
.incbin_range "baserom/kn7000_program.rom", 0x021e88, 0x02246a
# LcdOff  (CPU 0x4842246a)
.incbin_range "baserom/kn7000_program.rom", 0x02246a, 0x0224b3
# DrawBitmapFile  (CPU 0x484224b3)
.incbin_range "baserom/kn7000_program.rom", 0x0224b3, 0x0224fb
# InitializeGraphics  (CPU 0x484224fb)
.incbin_range "baserom/kn7000_program.rom", 0x0224fb, 0x0225d5
# UpdateScreen  (CPU 0x484225d5)
.incbin_range "baserom/kn7000_program.rom", 0x0225d5, 0x022630
# SetNeedUpdate  (CPU 0x48422630)
    mov     1, d0
    mov     d0, (0x5002a030)
    movhu   (0x5002a02a), d1
    mov     2, a1
    add     a0, a1
    movhu   (a1), d0
    exth    d1
    exth    d0
    cmp     d0, d1
    ble     0x48422651
    movhu   (a1), d0
    movhu   d0, (0x5002a02a)
    movhu   (a0), d0
    movhu   (0x5002a028), d1
    exth    d0
    exth    d1
    cmp     d0, d1
    ble     0x48422666
    movhu   (a0), d0
    movhu   d0, (0x5002a028)
    mov     a0, a1
    inc4    a1
    movhu   (a1), d0
    movhu   (0x5002a02c), d1
    exth    d0
    exth    d1
    cmp     d0, d1
    bge     0x4842267d
    movhu   (a1), d0
    movhu   d0, (0x5002a02c)
    add     6, a0
    movhu   (a0), d0
    movhu   (0x5002a02e), d1
    exth    d0
    exth    d1
    cmp     d0, d1
    bge     0x48422694
    movhu   (a0), d0
    movhu   d0, (0x5002a02e)
    retf    0, 0
# SetChangeRect  (CPU 0x48422697)
.incbin_range "baserom/kn7000_program.rom", 0x022697, 0x0226c4
# ReadPixel  (CPU 0x484226c4)
.incbin_range "baserom/kn7000_program.rom", 0x0226c4, 0x02271a
# ModifyPixel  (CPU 0x4842271a)
.incbin_range "baserom/kn7000_program.rom", 0x02271a, 0x022894
# ModifyPixelEx  (CPU 0x48422894)
.incbin_range "baserom/kn7000_program.rom", 0x022894, 0x022c8d
# DrawLine  (CPU 0x48422c8d)
.incbin_range "baserom/kn7000_program.rom", 0x022c8d, 0x02302c
# DrawDottedLine  (CPU 0x4842302c)
.incbin_range "baserom/kn7000_program.rom", 0x02302c, 0x02319f
# DrawBox  (CPU 0x4842319f)
.incbin_range "baserom/kn7000_program.rom", 0x02319f, 0x0235d5
# DrawFrame  (CPU 0x484235d5)
.incbin_range "baserom/kn7000_program.rom", 0x0235d5, 0x0238cb
# DrawFrameEx  (CPU 0x484238cb)
.incbin_range "baserom/kn7000_program.rom", 0x0238cb, 0x023a00
# DrawCircle  (CPU 0x48423a00)
.incbin_range "baserom/kn7000_program.rom", 0x023a00, 0x023b56
# DrawWall  (CPU 0x48423b56)
.incbin_range "baserom/kn7000_program.rom", 0x023b56, 0x023c88
# DrawBitmapSPFast  (CPU 0x48423c88)
.incbin_range "baserom/kn7000_program.rom", 0x023c88, 0x023dcd
# DrawBitmap  (CPU 0x48423dcd)
.incbin_range "baserom/kn7000_program.rom", 0x023dcd, 0x023efb
# DrawIcons  (CPU 0x48423efb)
.incbin_range "baserom/kn7000_program.rom", 0x023efb, 0x0240a4
# GetPartSelect  (CPU 0x484240a4)
.incbin_range "baserom/kn7000_program.rom", 0x0240a4, 0x02429e
# IvScreenProc  (CPU 0x4842429e)
.incbin_range "baserom/kn7000_program.rom", 0x02429e, 0x0243cd
# CaptureLcdArea  (CPU 0x484243cd)
.incbin_range "baserom/kn7000_program.rom", 0x0243cd, 0x0245bc
# GetTitleFlag  (CPU 0x484245bc)
.incbin_range "baserom/kn7000_program.rom", 0x0245bc, 0x024784
# AcMixerVolWideProc  (CPU 0x48424784)
.incbin_range "baserom/kn7000_program.rom", 0x024784, 0x0248de
# MainDeleteEvent  (CPU 0x484248de)
.incbin_range "baserom/kn7000_program.rom", 0x0248de, 0x024a9f
# VwUserBitmapByNameProc  (CPU 0x48424a9f)
.incbin_range "baserom/kn7000_program.rom", 0x024a9f, 0x024cc8
# InterruptTitleDirect  (CPU 0x48424cc8)
.incbin_range "baserom/kn7000_program.rom", 0x024cc8, 0x024ebd
# CheckHoldLED  (CPU 0x48424ebd)
.incbin_range "baserom/kn7000_program.rom", 0x024ebd, 0x024f7d
# GetBitmapInfo  (CPU 0x48424f7d)
.incbin_range "baserom/kn7000_program.rom", 0x024f7d, 0x025265
# VwJpegFileProc  (CPU 0x48425265)
.incbin_range "baserom/kn7000_program.rom", 0x025265, 0x025393
# DrawFrameSP  (CPU 0x48425393)
.incbin_range "baserom/kn7000_program.rom", 0x025393, 0x025896
# DrawString  (CPU 0x48425896)
.incbin_range "baserom/kn7000_program.rom", 0x025896, 0x02597a
# DrawStringCentered  (CPU 0x4842597a)
.incbin_range "baserom/kn7000_program.rom", 0x02597a, 0x0259f3
# DrawStringLeftJustify  (CPU 0x484259f3)
.incbin_range "baserom/kn7000_program.rom", 0x0259f3, 0x025abf
# DrawStringRightJustify  (CPU 0x48425abf)
.incbin_range "baserom/kn7000_program.rom", 0x025abf, 0x025b18
# IvExitScreenProc  (CPU 0x48425b18)
.incbin_range "baserom/kn7000_program.rom", 0x025b18, 0x025cee
# MovePixels  (CPU 0x48425cee)
.incbin_range "baserom/kn7000_program.rom", 0x025cee, 0x025ee2
# DrawLineEx  (CPU 0x48425ee2)
.incbin_range "baserom/kn7000_program.rom", 0x025ee2, 0x0261a1
# GetClientBox2  (CPU 0x484261a1)
.incbin_range "baserom/kn7000_program.rom", 0x0261a1, 0x027da1
# ConvertBitmapFile  (CPU 0x48427da1)
.incbin_range "baserom/kn7000_program.rom", 0x027da1, 0x027fff
# AcWallPreviewProc  (CPU 0x48427fff)
.incbin_range "baserom/kn7000_program.rom", 0x027fff, 0x02829f
# GetPaletteRGB4  (CPU 0x4842829f)
.incbin_range "baserom/kn7000_program.rom", 0x02829f, 0x0284b4
# CheckViewObject  (CPU 0x484284b4)
.incbin_range "baserom/kn7000_program.rom", 0x0284b4, 0x028d79
# SetPresetWall  (CPU 0x48428d79)
.incbin_range "baserom/kn7000_program.rom", 0x028d79, 0x02936f
# InitializeEventQueue  (CPU 0x4842936f)
    add     -0x10, sp
    mov     sp, a0
    add     0xc, a0
    call    func_48414A4F, [a2], 4
    movhu   (0xc, sp), d0
    exth    d0
    call    func_48428C43, [d2,d3,a2,a3], 0x44
    ret     0, 0x10
# DispatchEvent  (CPU 0x48429388)
    movm    [d2,d3], (sp)
    add     -0x1c, sp
    mov     sp, a0
    add     0x18, a0
    mov     d1, d3
    mov     d0, d2
    call    func_48414A4F, [a2], 4
    mov     (0x34, sp), a0
    mov     d2, d0
    mov     a0, (0x10, sp)
    movhu   (0x18, sp), d1
    exth    d1
    mov     d1, (0x14, sp)
    mov     d3, d1
    call    func_48428555, [d2,d3,a2,a3], 0x28
    ret     [d2,d3], 0x24
# SendEvent  (CPU 0x484293ad)
    movm    [d2,d3], (sp)
    add     -0x1c, sp
    mov     sp, a0
    add     0x18, a0
    mov     d1, d3
    mov     d0, d2
    call    func_48414A4F, [a2], 4
    mov     (0x34, sp), a0
    mov     d2, d0
    mov     a0, (0x10, sp)
    movhu   (0x18, sp), d1
    exth    d1
    mov     d1, (0x14, sp)
    mov     d3, d1
    call    func_484285E4, [d2,d3,a2,a3], 0x38
    ret     [d2,d3], 0x24
# PostEvent  (CPU 0x484293d2)
    movm    [d2,a2,a3], (sp)
    add     -0x1c, sp
    mov     d0, d2
    mov     a1, a3
    mov     a0, a2
    mov     sp, a0
    add     0x18, a0
    call    func_48414A4F, [a2], 4
    movhu   (0x18, sp), d0
    mov     d2, d1
    exth    d0
    mov     a3, a1
    mov     a2, a0
    call    func_48428792, [d2,d3,a2,a3], 0x2c
    mov     1, d0
    ret     [d2,a2,a3], 0x28
# DeleteSpecificEvent  (CPU 0x484293f5)
    movm    [d2,d3], (sp)
    add     -0x18, sp
    mov     sp, a0
    add     0x14, a0
    mov     d1, d3
    mov     d0, d2
    call    func_48414A4F, [a2], 4
    movhu   (0x14, sp), d1
    mov     d2, d0
    exth    d1
    mov     d1, (0x10, sp)
    mov     d3, d1
    call    func_484288B1, [d2,d3,a2,a3], 0x54
    ret     [d2,d3], 0x20
# FuncCall  (CPU 0x48429416)
.incbin_range "baserom/kn7000_program.rom", 0x029416, 0x02943b
# GetEvent  (CPU 0x4842943b)
    add     -0x10, sp
    mov     sp, a0
    add     0xc, a0
    call    func_48414A4F, [a2], 4
    movhu   (0xc, sp), d0
    mov     0x38, d1
    exth    d0
    nop
    nop
    mul     d1, d0
    add     0x5000757c, d0
    mov     d0, a0
    mov     (0x10, a0), d0
    ret     0, 0x10
# GetCurrentTarget  (CPU 0x48429460)
    movm    [d3], (sp)
    add     -0x10, sp
    mov     d0, d3
    cmp     -1, d3
    beq     0x48429489
    mov     sp, a0
    add     0xc, a0
    call    func_48414A4F, [a2], 4
    movhu   (0xc, sp), d0
    mov     0x38, d1
    exth    d0
    nop
    nop
    mul     d1, d0
    add     0x5000757c, d0
    mov     d0, a0
    mov     d3, (0x10, a0)
    ret     [d3], 0x14
# SetFocusParam  (CPU 0x4842948c)
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     d0, d3
    mov     d1, (0x3c, sp)
    mov     sp, a0
    add     0x18, a0
    call    func_48414A4F, [a2], 4
    mov     d3, d0
    lsr     16, d0
    exthu   d0
    asl     4, d0
    add     0x5011faac, d0
    mov     d0, a0
    mov     (4, a0), a2
    cmp     0, a2
    bne     0x484294b9
    clr     d0
    ret     [d2,d3,a2,a3], 0x30
    movhu   (0x18, sp), d1
    mov     0x5000757c, d2
    exth    d1
    mov     0x38, d0
    nop
    nop
    mul     d1, d0
    add     d2, d0
    mov     d0, a0
    mov     d3, (0x20, a0)
    mov     (0x3c, sp), a0
    mov     0x38, d0
    nop
    nop
    mul     d1, d0
    add     d2, d0
    mov     d0, a1
    mov     a0, (0x24, a1)
    mov     (0x40, sp), a3
    mov     0x38, d0
    nop
    nop
    mul     d1, d0
    mov     d0, a1
    add     d2, a1
    mov     a3, (0x28, a1)
    mov     0x38, d0
    nop
    nop
    mul     d1, d0
    mov     d0, a0
    add     d2, a0
    mov     (0xc, a0), d0
    mov     0x00060000, d1
    mov     d0, (0x14, sp)
    clr     d0
    mov     d0, (0x10, sp)
    mov     d3, d0
    calls   (a2)
    movhu   (0x18, sp), d1
    mov     d3, (0x1c, sp)
    exth    d1
    mov     0x38, d3
    nop
    nop
    mul     d1, d3
    mov     d3, a0
    add     d2, a0
    mov     d0, (0xc, a0)
    lsr     16, d0
    exthu   d0
    asl     4, d0
    mov     0x38, d3
    nop
    nop
    mul     d1, d3
    mov     d3, a0
    add     d2, a0
    mov     (0xc, a0), d1
    mov     d0, a0
    add     0x5011faac, a0
    mov     (0xc, a0), a0
    exthu   d1
    mov     0x18, d0
    nop
    nop
    mulu    d0, d1
    mov     (d1, a0), a1
    clr     d0
    cmp     0, a1
    beq     0x4842954f
    mov     a3, (0x10, sp)
    mov     (0x3c, sp), d1
    mov     (0x1c, sp), d0
    calls   (a1)
    movhu   (0x18, sp), d1
    mov     0x38, d3
    exth    d1
    nop
    nop
    mul     d3, d1
    add     d1, d2
    mov     (0x14, sp), d1
    mov     d2, a0
    mov     d1, (0xc, a0)
    ret     [d2,d3,a2,a3], 0x30
# ObjectProc  (CPU 0x48429564)
.incbin_range "baserom/kn7000_program.rom", 0x029564, 0x02960c
# KillApTimer  (CPU 0x4842960c)
    add     -0x10, sp
    mov     sp, a0
    add     0xc, a0
    call    func_48414A4F, [a2], 4
    movhu   (0xc, sp), d0
    mov     0x38, d1
    exth    d0
    nop
    nop
    mul     d1, d0
    add     0x5000757c, d0
    mov     d0, a0
    mov     (0x14, a0), d0
    ret     0, 0x10
# GetRootObject  (CPU 0x48429631)
    add     -0x10, sp
    mov     sp, a0
    add     0xc, a0
    call    func_48414A4F, [a2], 4
    movhu   (0xc, sp), d0
    mov     0x38, d1
    exth    d0
    nop
    nop
    mul     d1, d0
    add     0x5000757c, d0
    mov     d0, a0
    mov     (0x18, a0), d0
    ret     0, 0x10
# GetRootEvent  (CPU 0x48429656)
    add     -0x10, sp
    mov     sp, a0
    add     0xc, a0
    call    func_48414A4F, [a2], 4
    movhu   (0xc, sp), d0
    mov     0x38, d1
    exth    d0
    nop
    nop
    mul     d1, d0
    add     0x5000757c, d0
    mov     d0, a0
    mov     (0x1c, a0), d0
    ret     0, 0x10
# SetAutoInc  (CPU 0x4842967b)
    movm    [d3], (sp)
    add     -0x10, sp
    mov     sp, a0
    add     0xc, a0
    mov     d0, d3
    call    func_48414A4F, [a2], 4
    movhu   (0xc, sp), d0
    mov     0x38, d1
    exth    d0
    nop
    nop
    mul     d1, d0
    add     0x5000757c, d0
    mov     d0, a0
    mov     d3, (0x14, a0)
    ret     [d3], 0x14
# InitDrawTask  (CPU 0x484296a3)
.incbin_range "baserom/kn7000_program.rom", 0x0296a3, 0x0296cb
# SetRootEvent  (CPU 0x484296cb)
.incbin_range "baserom/kn7000_program.rom", 0x0296cb, 0x0296f3
# SetRootObject  (CPU 0x484296f3)
.incbin_range "baserom/kn7000_program.rom", 0x0296f3, 0x029718
# GetFocusObject  (CPU 0x48429718)
.incbin_range "baserom/kn7000_program.rom", 0x029718, 0x02973d
# GetFocusEvent  (CPU 0x4842973d)
.incbin_range "baserom/kn7000_program.rom", 0x02973d, 0x029762
# GetPaletteRGB  (CPU 0x48429762)
.incbin_range "baserom/kn7000_program.rom", 0x029762, 0x02978a
# SetFocusObject  (CPU 0x4842978a)
.incbin_range "baserom/kn7000_program.rom", 0x02978a, 0x0297b2
# SetFocusEvent  (CPU 0x484297b2)
.incbin_range "baserom/kn7000_program.rom", 0x0297b2, 0x0297da
# SetCurrentTarget  (CPU 0x484297da)
.incbin_range "baserom/kn7000_program.rom", 0x0297da, 0x0297ec
# MainDispatchEvent  (CPU 0x484297ec)
.incbin_range "baserom/kn7000_program.rom", 0x0297ec, 0x029808
# MainSendEvent  (CPU 0x48429808)
.incbin_range "baserom/kn7000_program.rom", 0x029808, 0x029824
# MainPostEvent  (CPU 0x48429824)
.incbin_range "baserom/kn7000_program.rom", 0x029824, 0x029839
# MainDeleteSpecificEvent  (CPU 0x48429839)
.incbin_range "baserom/kn7000_program.rom", 0x029839, 0x029851
# DrawFunc  (CPU 0x48429851)
.incbin_range "baserom/kn7000_program.rom", 0x029851, 0x02986d
# MainAddM3Em  (CPU 0x4842986d)
.incbin_range "baserom/kn7000_program.rom", 0x02986d, 0x02987f
# ApDispatchEvent  (CPU 0x4842987f)
.incbin_range "baserom/kn7000_program.rom", 0x02987f, 0x02989b
# MainGetEvent  (CPU 0x4842989b)
.incbin_range "baserom/kn7000_program.rom", 0x02989b, 0x0298b7
# RefreshApTask  (CPU 0x484298b7)
    movm    [d2,d3,a2], (sp)
    add     -0x14, sp
    mov     d1, d3
    mov     d0, d2
    cmp     -1, d2
    bne     0x484298cd
    mov     (0x30, sp), a0
    mov     a0, (0x10, sp)
    call    func_484298A0, [d2], 0x1c
    bra     0x484298fe
    mov     0xc, d0
    call    func_4841662A, [d2,a2,a3], 0x28
    mov     a0, a2
    mov     d2, (a2)
    mov     d3, (4, a2)
    mov     (0x30, sp), a1
    mov     -1, d0
    mov     a1, (8, a2)
    mov     a0, (0x10, sp)
    mov     0x0005002f, d1
    call    func_484298A0, [d2], 0x1c
    mov     a2, (0x10, sp)
    mov     -1, d0
    mov     0x00060023, d1
    call    func_484298A0, [d2], 0x1c
    ret     [d2,d3,a2], 0x20
# ApSendEvent  (CPU 0x48429901)
.incbin_range "baserom/kn7000_program.rom", 0x029901, 0x029919
# ApDeleteEvent  (CPU 0x48429919)
.incbin_range "baserom/kn7000_program.rom", 0x029919, 0x029935
# PsWideToggleProc  (CPU 0x48429935)
.incbin_range "baserom/kn7000_program.rom", 0x029935, 0x02994c
# SetMmmFilter  (CPU 0x4842994c)
.incbin_range "baserom/kn7000_program.rom", 0x02994c, 0x0299f1
# InitializeTimer  (CPU 0x484299f1)
.incbin_range "baserom/kn7000_program.rom", 0x0299f1, 0x029c95
# ApTimer  (CPU 0x48429c95)
.incbin_range "baserom/kn7000_program.rom", 0x029c95, 0x029f9d
# SetApTimer  (CPU 0x48429f9d)
.incbin_range "baserom/kn7000_program.rom", 0x029f9d, 0x029fd0
# ResetApTimer  (CPU 0x48429fd0)
.incbin_range "baserom/kn7000_program.rom", 0x029fd0, 0x02a208
# DrawStringAlignment  (CPU 0x4842a208)
.incbin_range "baserom/kn7000_program.rom", 0x02a208, 0x02a4e5
# InheritedProc  (CPU 0x4842a4e5)
.incbin_range "baserom/kn7000_program.rom", 0x02a4e5, 0x02a6c5
# UnRegisterObject  (CPU 0x4842a6c5)
.incbin_range "baserom/kn7000_program.rom", 0x02a6c5, 0x02a6ed
# CountObject  (CPU 0x4842a6ed)
.incbin_range "baserom/kn7000_program.rom", 0x02a6ed, 0x02a717
# InitializeObjectTable  (CPU 0x4842a717)
.incbin_range "baserom/kn7000_program.rom", 0x02a717, 0x02a737
# RegisterObjectTable  (CPU 0x4842a737)
.incbin_range "baserom/kn7000_program.rom", 0x02a737, 0x02a7b2
# RegisterObject  (CPU 0x4842a7b2)
.incbin_range "baserom/kn7000_program.rom", 0x02a7b2, 0x02a802
# WordwrapStrings  (CPU 0x4842a802)
.incbin_range "baserom/kn7000_program.rom", 0x02a802, 0x02aaf0
# ClassProc  (CPU 0x4842aaf0)
.incbin_range "baserom/kn7000_program.rom", 0x02aaf0, 0x02ab7d
# TrackIDProc  (CPU 0x4842ab7d)
.incbin_range "baserom/kn7000_program.rom", 0x02ab7d, 0x02ac0c
# InitPaletteRGB  (CPU 0x4842ac0c)
.incbin_range "baserom/kn7000_program.rom", 0x02ac0c, 0x02ac35
# FunctionProc  (CPU 0x4842ac35)
.incbin_range "baserom/kn7000_program.rom", 0x02ac35, 0x02ac7b
# MainFunctionProc  (CPU 0x4842ac7b)
.incbin_range "baserom/kn7000_program.rom", 0x02ac7b, 0x02acfa
# ApFunctionProc  (CPU 0x4842acfa)
.incbin_range "baserom/kn7000_program.rom", 0x02acfa, 0x02ad40
# ApFuncCall  (CPU 0x4842ad40)
.incbin_range "baserom/kn7000_program.rom", 0x02ad40, 0x02adc3
# MethodProc  (CPU 0x4842adc3)
.incbin_range "baserom/kn7000_program.rom", 0x02adc3, 0x02ae30
# MainFuncCall  (CPU 0x4842ae30)
.incbin_range "baserom/kn7000_program.rom", 0x02ae30, 0x02b309
# UnregisteredMode  (CPU 0x4842b309)
.incbin_range "baserom/kn7000_program.rom", 0x02b309, 0x02b326
# GetModeNow  (CPU 0x4842b326)
.incbin_range "baserom/kn7000_program.rom", 0x02b326, 0x02b343
# SwInEasySet  (CPU 0x4842b343)
.incbin_range "baserom/kn7000_program.rom", 0x02b343, 0x02b371
# ChangeMode  (CPU 0x4842b371)
.incbin_range "baserom/kn7000_program.rom", 0x02b371, 0x02b3af
# DrawBitmapSPFast4  (CPU 0x4842b3af)
.incbin_range "baserom/kn7000_program.rom", 0x02b3af, 0x02b3ef
# ChangeModeEZ  (CPU 0x4842b3ef)
.incbin_range "baserom/kn7000_program.rom", 0x02b3ef, 0x02b41d
# ChangeTitle  (CPU 0x4842b41d)
.incbin_range "baserom/kn7000_program.rom", 0x02b41d, 0x02b45b
# ChangeModeDirect  (CPU 0x4842b45b)
.incbin_range "baserom/kn7000_program.rom", 0x02b45b, 0x02b49b
# ChangeTitleEZ  (CPU 0x4842b49b)
.incbin_range "baserom/kn7000_program.rom", 0x02b49b, 0x02b4c9
# InterruptTitle  (CPU 0x4842b4c9)
.incbin_range "baserom/kn7000_program.rom", 0x02b4c9, 0x02b507
# ChangeTitleDirect  (CPU 0x4842b507)
.incbin_range "baserom/kn7000_program.rom", 0x02b507, 0x02b547
# SuffixCheck  (CPU 0x4842b547)
.incbin_range "baserom/kn7000_program.rom", 0x02b547, 0x02b670
# DefMainFunction  (CPU 0x4842b670)
.incbin_range "baserom/kn7000_program.rom", 0x02b670, 0x02b9ec
# DrawBitmapSPFast256  (CPU 0x4842b9ec)
.incbin_range "baserom/kn7000_program.rom", 0x02b9ec, 0x02ba04
# ModeFuncCall  (CPU 0x4842ba04)
.incbin_range "baserom/kn7000_program.rom", 0x02ba04, 0x02ba1c
# GetModeOld  (CPU 0x4842ba1c)
.incbin_range "baserom/kn7000_program.rom", 0x02ba1c, 0x02c982
# UnregisteredTitle  (CPU 0x4842c982)
.incbin_range "baserom/kn7000_program.rom", 0x02c982, 0x02c99f
# GetTitleNow  (CPU 0x4842c99f)
.incbin_range "baserom/kn7000_program.rom", 0x02c99f, 0x02c9bc
# IntTimeIDProc  (CPU 0x4842c9bc)
.incbin_range "baserom/kn7000_program.rom", 0x02c9bc, 0x02c9ce
# CheckNotDrawFlag  (CPU 0x4842c9ce)
.incbin_range "baserom/kn7000_program.rom", 0x02c9ce, 0x02c9e8
# GetInterruptTime  (CPU 0x4842c9e8)
.incbin_range "baserom/kn7000_program.rom", 0x02c9e8, 0x02ca0d
# ConvertStringsEx  (CPU 0x4842ca0d)
.incbin_range "baserom/kn7000_program.rom", 0x02ca0d, 0x02cae0
# KinsokuStrings  (CPU 0x4842cae0)
.incbin_range "baserom/kn7000_program.rom", 0x02cae0, 0x02cb02
# ApPostEvent  (CPU 0x4842cb02)
.incbin_range "baserom/kn7000_program.rom", 0x02cb02, 0x02cb4a
# EventProc  (CPU 0x4842cb4a)
.incbin_range "baserom/kn7000_program.rom", 0x02cb4a, 0x02cb92
# RegisterOTBlock  (CPU 0x4842cb92)
.incbin_range "baserom/kn7000_program.rom", 0x02cb92, 0x02d244
# GetIntTimeID  (CPU 0x4842d244)
.incbin_range "baserom/kn7000_program.rom", 0x02d244, 0x02d361
# GetConst  (CPU 0x4842d361)
.incbin_range "baserom/kn7000_program.rom", 0x02d361, 0x02d388
# SetChange  (CPU 0x4842d388)
    add     -0xc, sp
    call    GetLinkView, 0, 0
    movhu   (0xc, a0), d0
    btst    0x04, d0
    beq     0x4842d39c
    mov     1, d0
    bra     0x4842d39d
    clr     d0
    ret     0, 0xc
# ViewableProc  (CPU 0x4842d3a0)
.incbin_range "baserom/kn7000_program.rom", 0x02d3a0, 0x02d3c7
# SetConst  (CPU 0x4842d3c7)
    add     -0xc, sp
    call    GetLinkView, 0, 0
    movhu   (0xc, a0), d0
    btst    0x08, d0
    beq     0x4842d3db
    mov     1, d0
    bra     0x4842d3dc
    clr     d0
    ret     0, 0xc
# GetChange  (CPU 0x4842d3df)
.incbin_range "baserom/kn7000_program.rom", 0x02d3df, 0x02d406
# SetVisible  (CPU 0x4842d406)
    add     -0xc, sp
    call    GetLinkView, 0, 0
    movhu   (0xc, a0), d1
    clr     d0
    btst    0x01, d1
    bne     0x4842d419
    mov     1, d0
    ret     0, 0xc
# GetVisible  (CPU 0x4842d41c)
.incbin_range "baserom/kn7000_program.rom", 0x02d41c, 0x02d443
# SetMovable  (CPU 0x4842d443)
    add     -0xc, sp
    call    GetLinkView, 0, 0
    movhu   (0xc, a0), d1
    clr     d0
    btst    0x02, d1
    bne     0x4842d456
    mov     1, d0
    ret     0, 0xc
# GetMovable  (CPU 0x4842d459)
.incbin_range "baserom/kn7000_program.rom", 0x02d459, 0x02d483
# NextView  (CPU 0x4842d483)
.incbin_range "baserom/kn7000_program.rom", 0x02d483, 0x02d4ad
# PrevView  (CPU 0x4842d4ad)
.incbin_range "baserom/kn7000_program.rom", 0x02d4ad, 0x02d4d6
# SuperView  (CPU 0x4842d4d6)
.incbin_range "baserom/kn7000_program.rom", 0x02d4d6, 0x02d500
# SubView  (CPU 0x4842d500)
.incbin_range "baserom/kn7000_program.rom", 0x02d500, 0x02d5db
# Link  (CPU 0x4842d5db)
.incbin_range "baserom/kn7000_program.rom", 0x02d5db, 0x02d721
# Unlink  (CPU 0x4842d721)
.incbin_range "baserom/kn7000_program.rom", 0x02d721, 0x02d7d3
# SetSuperView  (CPU 0x4842d7d3)
.incbin_range "baserom/kn7000_program.rom", 0x02d7d3, 0x02d91a
# GetLinkView  (CPU 0x4842d91a)
.incbin_range "baserom/kn7000_program.rom", 0x02d91a, 0x02d934
# ResStringProc  (CPU 0x4842d934)
.incbin_range "baserom/kn7000_program.rom", 0x02d934, 0x02d953
# OTBlockProc  (CPU 0x4842d953)
.incbin_range "baserom/kn7000_program.rom", 0x02d953, 0x02d962
# ResourceProc  (CPU 0x4842d962)
.incbin_range "baserom/kn7000_program.rom", 0x02d962, 0x02d971
# ResBitmapProc  (CPU 0x4842d971)
.incbin_range "baserom/kn7000_program.rom", 0x02d971, 0x02d980
# ResFrameProc  (CPU 0x4842d980)
.incbin_range "baserom/kn7000_program.rom", 0x02d980, 0x02d98f
# ResIconProc  (CPU 0x4842d98f)
.incbin_range "baserom/kn7000_program.rom", 0x02d98f, 0x02d99e
# ResFontProc  (CPU 0x4842d99e)
.incbin_range "baserom/kn7000_program.rom", 0x02d99e, 0x02d9ad
# SetPaletteRGB  (CPU 0x4842d9ad)
.incbin_range "baserom/kn7000_program.rom", 0x02d9ad, 0x02d9f1
# DrawBitmapFast  (CPU 0x4842d9f1)
.incbin_range "baserom/kn7000_program.rom", 0x02d9f1, 0x02db23
# GetBitmapSize  (CPU 0x4842db23)
    exth    d0
    asl2    d0
    mov     0x50031490, a0
    mov     (d0, a0), d0
    retf    0, 0
# ApDeleteEventMmm  (CPU 0x4842db30)
.incbin_range "baserom/kn7000_program.rom", 0x02db30, 0x02dc88
# InitializeBlock47  (CPU 0x4842dc88)
.incbin_range "baserom/kn7000_program.rom", 0x02dc88, 0x02dcec
# GetLcdMode  (CPU 0x4842dcec)
.incbin_range "baserom/kn7000_program.rom", 0x02dcec, 0x02dd6f
# GetEditSwPointInit  (CPU 0x4842dd6f)
.incbin_range "baserom/kn7000_program.rom", 0x02dd6f, 0x02de2d
# u2d  (CPU 0x4842de2d)
.incbin_range "baserom/kn7000_program.rom", 0x02de2d, 0x02dedc
# InitSptClassTable  (CPU 0x4842dedc)
.incbin_range "baserom/kn7000_program.rom", 0x02dedc, 0x02dee5
# GetBitmapCount  (CPU 0x4842dee5)
.incbin_range "baserom/kn7000_program.rom", 0x02dee5, 0x02deee
# GetFontNameTable  (CPU 0x4842deee)
.incbin_range "baserom/kn7000_program.rom", 0x02deee, 0x02df0f
# GetIconNameTable  (CPU 0x4842df0f)
.incbin_range "baserom/kn7000_program.rom", 0x02df0f, 0x02df18
# GetFrameCount  (CPU 0x4842df18)
.incbin_range "baserom/kn7000_program.rom", 0x02df18, 0x02df21
# ResNameProc  (CPU 0x4842df21)
.incbin_range "baserom/kn7000_program.rom", 0x02df21, 0x02df3c
# GetBitmapNameTable  (CPU 0x4842df3c)
.incbin_range "baserom/kn7000_program.rom", 0x02df3c, 0x02df45
# GetIconCount  (CPU 0x4842df45)
.incbin_range "baserom/kn7000_program.rom", 0x02df45, 0x02df4e
# GetFrameNameTable  (CPU 0x4842df4e)
.incbin_range "baserom/kn7000_program.rom", 0x02df4e, 0x02df57
# GetFontCount  (CPU 0x4842df57)
.incbin_range "baserom/kn7000_program.rom", 0x02df57, 0x02df60
# GetFrameSPSize  (CPU 0x4842df60)
    mov     (0x50122db8), a0
    mov     0x14, d1
    nop
    nop
    mul     d1, d0
    add     d0, a0
    movhu   (2, a0), d0
    rets
# GetCharHeight  (CPU 0x4842df73)
    mov     (0x50122db8), a0
    mov     0x14, d1
    nop
    nop
    mul     d1, d0
    add     d0, a0
    movhu   (4, a0), d0
    rets
# GetCharDescent  (CPU 0x4842df86)
    cmp     0, d0
    beq     0x4842df9c
    cmp     5, d0
    beq     0x4842df9c
    cmp     7, d0
    beq     0x4842df9c
    cmp     0xb, d0
    beq     0x4842dfa0
    cmp     0xa, d0
    beq     0x4842dfa0
    bra     0x4842dfa4
    mov     -1, d0
    bra     0x4842dfa5
    mov     -3, d0
    bra     0x4842dfa5
    clr     d0
    retf    0, 0
# GetCenteredDelta  (CPU 0x4842dfa8)
.incbin_range "baserom/kn7000_program.rom", 0x02dfa8, 0x02e051
# SetVariFlag  (CPU 0x4842e051)
.incbin_range "baserom/kn7000_program.rom", 0x02e051, 0x02e0bb
# ConvertStrings  (CPU 0x4842e0bb)
.incbin_range "baserom/kn7000_program.rom", 0x02e0bb, 0x02e16c
# CalcTotalWidth  (CPU 0x4842e16c)
.incbin_range "baserom/kn7000_program.rom", 0x02e16c, 0x02e25f
# d2u  (CPU 0x4842e25f)
.incbin_range "baserom/kn7000_program.rom", 0x02e25f, 0x02e5dc
# InitModeTitleTable  (CPU 0x4842e5dc)
.incbin_range "baserom/kn7000_program.rom", 0x02e5dc, 0x02e609
# SupportClassProc  (CPU 0x4842e609)
.incbin_range "baserom/kn7000_program.rom", 0x02e609, 0x02e664
# swordProc  (CPU 0x4842e664)
.incbin_range "baserom/kn7000_program.rom", 0x02e664, 0x02e6be
# uwordProc  (CPU 0x4842e6be)
.incbin_range "baserom/kn7000_program.rom", 0x02e6be, 0x02e718
# ucharProc  (CPU 0x4842e718)
.incbin_range "baserom/kn7000_program.rom", 0x02e718, 0x02e773
# scharProc  (CPU 0x4842e773)
.incbin_range "baserom/kn7000_program.rom", 0x02e773, 0x02e7cb
# slongProc  (CPU 0x4842e7cb)
.incbin_range "baserom/kn7000_program.rom", 0x02e7cb, 0x02e823
# ulongProc  (CPU 0x4842e823)
.incbin_range "baserom/kn7000_program.rom", 0x02e823, 0x02e87b
# boolProc  (CPU 0x4842e87b)
.incbin_range "baserom/kn7000_program.rom", 0x02e87b, 0x02e99f
# pBoolProc  (CPU 0x4842e99f)
.incbin_range "baserom/kn7000_program.rom", 0x02e99f, 0x02eac8
# pSwordProc  (CPU 0x4842eac8)
.incbin_range "baserom/kn7000_program.rom", 0x02eac8, 0x02ebf0
# pUwordProc  (CPU 0x4842ebf0)
.incbin_range "baserom/kn7000_program.rom", 0x02ebf0, 0x02ed19
# pScharProc  (CPU 0x4842ed19)
.incbin_range "baserom/kn7000_program.rom", 0x02ed19, 0x02ee41
# pUcharProc  (CPU 0x4842ee41)
.incbin_range "baserom/kn7000_program.rom", 0x02ee41, 0x02ef65
# pSlongProc  (CPU 0x4842ef65)
.incbin_range "baserom/kn7000_program.rom", 0x02ef65, 0x02f089
# EventIDProc  (CPU 0x4842f089)
.incbin_range "baserom/kn7000_program.rom", 0x02f089, 0x02f0f7
# RECTWProc  (CPU 0x4842f0f7)
.incbin_range "baserom/kn7000_program.rom", 0x02f0f7, 0x02f1c6
# RectX1Proc  (CPU 0x4842f1c6)
.incbin_range "baserom/kn7000_program.rom", 0x02f1c6, 0x02f26d
# RectY1Proc  (CPU 0x4842f26d)
.incbin_range "baserom/kn7000_program.rom", 0x02f26d, 0x02f31b
# RectX2Proc  (CPU 0x4842f31b)
.incbin_range "baserom/kn7000_program.rom", 0x02f31b, 0x02f3ee
# RectY2Proc  (CPU 0x4842f3ee)
.incbin_range "baserom/kn7000_program.rom", 0x02f3ee, 0x02f44c
# POINTWProc  (CPU 0x4842f44c)
.incbin_range "baserom/kn7000_program.rom", 0x02f44c, 0x02f50c
# PointXProc  (CPU 0x4842f50c)
.incbin_range "baserom/kn7000_program.rom", 0x02f50c, 0x02f5a7
# pStringProc  (CPU 0x4842f5a7)
.incbin_range "baserom/kn7000_program.rom", 0x02f5a7, 0x02f747
# ViewIDProc  (CPU 0x4842f747)
.incbin_range "baserom/kn7000_program.rom", 0x02f747, 0x02f7a1
# ViewFlagProc  (CPU 0x4842f7a1)
.incbin_range "baserom/kn7000_program.rom", 0x02f7a1, 0x02f7fc
# ColorIDProc  (CPU 0x4842f7fc)
.incbin_range "baserom/kn7000_program.rom", 0x02f7fc, 0x02f857
# FontIDProc  (CPU 0x4842f857)
.incbin_range "baserom/kn7000_program.rom", 0x02f857, 0x02f8b1
# EditSwIDProc  (CPU 0x4842f8b1)
.incbin_range "baserom/kn7000_program.rom", 0x02f8b1, 0x02f90b
# AlignmentIDProc  (CPU 0x4842f90b)
.incbin_range "baserom/kn7000_program.rom", 0x02f90b, 0x02f9a0
# EditSwStyleIDProc  (CPU 0x4842f9a0)
.incbin_range "baserom/kn7000_program.rom", 0x02f9a0, 0x02f9fa
# LineModeIDProc  (CPU 0x4842f9fa)
.incbin_range "baserom/kn7000_program.rom", 0x02f9fa, 0x02fa54
# MainFuncIDProc  (CPU 0x4842fa54)
.incbin_range "baserom/kn7000_program.rom", 0x02fa54, 0x02faae
# PartIDProc  (CPU 0x4842faae)
.incbin_range "baserom/kn7000_program.rom", 0x02faae, 0x02fb08
# IvExitWindowProc  (CPU 0x4842fb08)
.incbin_range "baserom/kn7000_program.rom", 0x02fb08, 0x02fb62
# PointYProc  (CPU 0x4842fb62)
.incbin_range "baserom/kn7000_program.rom", 0x02fb62, 0x02fc88
# IconIDProc  (CPU 0x4842fc88)
.incbin_range "baserom/kn7000_program.rom", 0x02fc88, 0x02fd89
# TitleIDProc  (CPU 0x4842fd89)
.incbin_range "baserom/kn7000_program.rom", 0x02fd89, 0x02fe8a
# FrameIDProc  (CPU 0x4842fe8a)
.incbin_range "baserom/kn7000_program.rom", 0x02fe8a, 0x02ff8b
# BitmapIDProc  (CPU 0x4842ff8b)
.incbin_range "baserom/kn7000_program.rom", 0x02ff8b, 0x03012b
# ApFuncIDProc  (CPU 0x4843012b)
.incbin_range "baserom/kn7000_program.rom", 0x03012b, 0x0302cb
# ConstFlagProc  (CPU 0x484302cb)
.incbin_range "baserom/kn7000_program.rom", 0x0302cb, 0x030575
# ClassIDProc  (CPU 0x48430575)
.incbin_range "baserom/kn7000_program.rom", 0x030575, 0x030889
# ScreenIDProc  (CPU 0x48430889)
.incbin_range "baserom/kn7000_program.rom", 0x030889, 0x030b9d
# BorderIDProc  (CPU 0x48430b9d)
.incbin_range "baserom/kn7000_program.rom", 0x030b9d, 0x030dde
# OTBlockIDProc  (CPU 0x48430dde)
.incbin_range "baserom/kn7000_program.rom", 0x030dde, 0x03101f
# ModeIDProc  (CPU 0x4843101f)
.incbin_range "baserom/kn7000_program.rom", 0x03101f, 0x031260
# StringProc  (CPU 0x48431260)
.incbin_range "baserom/kn7000_program.rom", 0x031260, 0x03131c
# NameProc  (CPU 0x4843131c)
.incbin_range "baserom/kn7000_program.rom", 0x03131c, 0x0313da
# pUlongProc  (CPU 0x484313da)
.incbin_range "baserom/kn7000_program.rom", 0x0313da, 0x0313e9
# ObjectIDProc  (CPU 0x484313e9)
.incbin_range "baserom/kn7000_program.rom", 0x0313e9, 0x0313f8
# pFuncProc  (CPU 0x484313f8)
.incbin_range "baserom/kn7000_program.rom", 0x0313f8, 0x031407
# pProcProc  (CPU 0x48431407)
.incbin_range "baserom/kn7000_program.rom", 0x031407, 0x031416
# pPropProc  (CPU 0x48431416)
.incbin_range "baserom/kn7000_program.rom", 0x031416, 0x031425
# WindowIDProc  (CPU 0x48431425)
.incbin_range "baserom/kn7000_program.rom", 0x031425, 0x031676
# BlinkHoldLed  (CPU 0x48431676)
.incbin_range "baserom/kn7000_program.rom", 0x031676, 0x031683
# GetSw2Mode  (CPU 0x48431683)
.incbin_range "baserom/kn7000_program.rom", 0x031683, 0x031690
# VwIconListProc  (CPU 0x48431690)
.incbin_range "baserom/kn7000_program.rom", 0x031690, 0x0317d1
# GetTitleOld  (CPU 0x484317d1)
.incbin_range "baserom/kn7000_program.rom", 0x0317d1, 0x0317ec
# ModeProc  (CPU 0x484317ec)
.incbin_range "baserom/kn7000_program.rom", 0x0317ec, 0x03180a
# RegisterMode  (CPU 0x4843180a)
.incbin_range "baserom/kn7000_program.rom", 0x03180a, 0x031836
# TitleProc  (CPU 0x48431836)
.incbin_range "baserom/kn7000_program.rom", 0x031836, 0x031862
# RegisterTitle  (CPU 0x48431862)
.incbin_range "baserom/kn7000_program.rom", 0x031862, 0x0318ad
# CheckDialLED  (CPU 0x484318ad)
.incbin_range "baserom/kn7000_program.rom", 0x0318ad, 0x0318e9
# RegisterEasySet  (CPU 0x484318e9)
.incbin_range "baserom/kn7000_program.rom", 0x0318e9, 0x031963
# ApTitleControl  (CPU 0x48431963)
.incbin_range "baserom/kn7000_program.rom", 0x031963, 0x031cb6
# InitializeBlock29  (CPU 0x48431cb6)
.incbin_range "baserom/kn7000_program.rom", 0x031cb6, 0x031cb9
# InitializeBlock30  (CPU 0x48431cb9)
.incbin_range "baserom/kn7000_program.rom", 0x031cb9, 0x031cbc
# InitializeBlock35  (CPU 0x48431cbc)
.incbin_range "baserom/kn7000_program.rom", 0x031cbc, 0x031cbf
# InitializeBlock36  (CPU 0x48431cbf)
.incbin_range "baserom/kn7000_program.rom", 0x031cbf, 0x031cc2
# InitializeBlock37  (CPU 0x48431cc2)
.incbin_range "baserom/kn7000_program.rom", 0x031cc2, 0x031cc5
# InitializeBlock38  (CPU 0x48431cc5)
.incbin_range "baserom/kn7000_program.rom", 0x031cc5, 0x031cc8
# InitializeBlock41  (CPU 0x48431cc8)
.incbin_range "baserom/kn7000_program.rom", 0x031cc8, 0x031ccb
# InitializeBlock42  (CPU 0x48431ccb)
.incbin_range "baserom/kn7000_program.rom", 0x031ccb, 0x031cce
# InitializeBlock43  (CPU 0x48431cce)
.incbin_range "baserom/kn7000_program.rom", 0x031cce, 0x031cd1
# InitializeBlock44  (CPU 0x48431cd1)
.incbin_range "baserom/kn7000_program.rom", 0x031cd1, 0x031cd4
# InitializeBlock45  (CPU 0x48431cd4)
.incbin_range "baserom/kn7000_program.rom", 0x031cd4, 0x031cd7
# InitializeBlock46  (CPU 0x48431cd7)
.incbin_range "baserom/kn7000_program.rom", 0x031cd7, 0x078d26
# StylCnvTxtTtlFunc  (CPU 0x48478d26)
.incbin_range "baserom/kn7000_program.rom", 0x078d26, 0x07915b
# StylCnvWaitTtlFunc  (CPU 0x4847915b)
.incbin_range "baserom/kn7000_program.rom", 0x07915b, 0x0791c4
# StylCnvModlTtlFunc  (CPU 0x484791c4)
.incbin_range "baserom/kn7000_program.rom", 0x0791c4, 0x079444
# StylCnvCnvtTtlFunc  (CPU 0x48479444)
.incbin_range "baserom/kn7000_program.rom", 0x079444, 0x0795ce
# StylCnvContTtlFunc  (CPU 0x484795ce)
.incbin_range "baserom/kn7000_program.rom", 0x0795ce, 0x07960d
# StylCnvSelTtlFunc  (CPU 0x4847960d)
.incbin_range "baserom/kn7000_program.rom", 0x07960d, 0x0796fd
# StylCnvStorTtlFunc  (CPU 0x484796fd)
.incbin_range "baserom/kn7000_program.rom", 0x0796fd, 0x07ac2f
# MainStylCnvFunc  (CPU 0x4847ac2f)
.incbin_range "baserom/kn7000_program.rom", 0x07ac2f, 0x07acbf
# InitializeBlock20  (CPU 0x4847acbf)
.incbin_range "baserom/kn7000_program.rom", 0x07acbf, 0x07afb9
# MusicStylistJpgData  (CPU 0x4847afb9)
    add     -0x14, sp
    cmp     0x600af, d1
    bne     0x4847afcf
    call    GetLinkView, 0, 0
    mov     2, d0
    bra     0x4847afda
    mov     (0x24, sp), a0
    mov     a0, (0x10, sp)
    call    func_48429569, [d2,d3,a2,a3], 0x28
    ret     0, 0x14
# AcOtpRamBoxProc  (CPU 0x4847afdd)
.incbin_range "baserom/kn7000_program.rom", 0x07afdd, 0x07b2ae
# AcStyleNameProc  (CPU 0x4847b2ae)
.incbin_range "baserom/kn7000_program.rom", 0x07b2ae, 0x07b6b2
# AcCategoryListBoxProc  (CPU 0x4847b6b2)
.incbin_range "baserom/kn7000_program.rom", 0x07b6b2, 0x07bcca
# AcSubCategoryListBoxProc  (CPU 0x4847bcca)
.incbin_range "baserom/kn7000_program.rom", 0x07bcca, 0x07c5e3
# AcEraStyleListBoxProc  (CPU 0x4847c5e3)
.incbin_range "baserom/kn7000_program.rom", 0x07c5e3, 0x07cb28
# AcAlphabetListBoxProc  (CPU 0x4847cb28)
.incbin_range "baserom/kn7000_program.rom", 0x07cb28, 0x07d2a9
# AcCtgStyleListBoxProc  (CPU 0x4847d2a9)
.incbin_range "baserom/kn7000_program.rom", 0x07d2a9, 0x07d95a
# AcEraTitleMenuProc  (CPU 0x4847d95a)
.incbin_range "baserom/kn7000_program.rom", 0x07d95a, 0x07d9e9
# AcEraListBoxProc  (CPU 0x4847d9e9)
.incbin_range "baserom/kn7000_program.rom", 0x07d9e9, 0x07e26d
# AcAlpStyleListBoxProc  (CPU 0x4847e26d)
.incbin_range "baserom/kn7000_program.rom", 0x07e26d, 0x07e7bc
# AcCustomListBoxProc  (CPU 0x4847e7bc)
.incbin_range "baserom/kn7000_program.rom", 0x07e7bc, 0x07eff8
# AcCustomStyleListBoxProc  (CPU 0x4847eff8)
.incbin_range "baserom/kn7000_program.rom", 0x07eff8, 0x07f0ee
# IvEditSwForEraPageProc  (CPU 0x4847f0ee)
.incbin_range "baserom/kn7000_program.rom", 0x07f0ee, 0x07f24b
# MssNameFunc  (CPU 0x4847f24b)
.incbin_range "baserom/kn7000_program.rom", 0x07f24b, 0x087420
# InitializeBlock00  (CPU 0x48487420)
.incbin_range "baserom/kn7000_program.rom", 0x087420, 0x0878ac
# DbMemoProc  (CPU 0x484878ac)
.incbin_range "baserom/kn7000_program.rom", 0x0878ac, 0x087ffc
# DbMemoryDumpProc  (CPU 0x48487ffc)
.incbin_range "baserom/kn7000_program.rom", 0x087ffc, 0x0880c7
# DbColorListProc  (CPU 0x484880c7)
.incbin_range "baserom/kn7000_program.rom", 0x0880c7, 0x08831d
# DbColorRGBProc  (CPU 0x4848831d)
.incbin_range "baserom/kn7000_program.rom", 0x08831d, 0x0884da
# DbModeEditBoxProc  (CPU 0x484884da)
.incbin_range "baserom/kn7000_program.rom", 0x0884da, 0x0886da
# DbBitmapFileProc  (CPU 0x484886da)
.incbin_range "baserom/kn7000_program.rom", 0x0886da, 0x0887cb
# DbBitmapLoadProc  (CPU 0x484887cb)
.incbin_range "baserom/kn7000_program.rom", 0x0887cb, 0x088897
# IvMpVerWinProc  (CPU 0x48488897)
.incbin_range "baserom/kn7000_program.rom", 0x088897, 0x0888fb
# AcProgVerBoxProc  (CPU 0x484888fb)
.incbin_range "baserom/kn7000_program.rom", 0x0888fb, 0x08895f
# AcTableVerBoxProc  (CPU 0x4848895f)
.incbin_range "baserom/kn7000_program.rom", 0x08895f, 0x088a0b
# AcRhythmVerBoxProc  (CPU 0x48488a0b)
.incbin_range "baserom/kn7000_program.rom", 0x088a0b, 0x088aac
# DbVariableMenuProc  (CPU 0x48488aac)
.incbin_range "baserom/kn7000_program.rom", 0x088aac, 0x088ab5
# AcAromVerBoxProc  (CPU 0x48488ab5)
.incbin_range "baserom/kn7000_program.rom", 0x088ab5, 0x088cde
# InitializeBlock01  (CPU 0x48488cde)
.incbin_range "baserom/kn7000_program.rom", 0x088cde, 0x089cb3
# InitializeBlock04  (CPU 0x48489cb3)
.incbin_range "baserom/kn7000_program.rom", 0x089cb3, 0x08a27d
# CheckLanguage  (CPU 0x4848a27d)
.incbin_range "baserom/kn7000_program.rom", 0x08a27d, 0x08a368
# CheckMessage  (CPU 0x4848a368)
.incbin_range "baserom/kn7000_program.rom", 0x08a368, 0x08a3e1
# MessageText  (CPU 0x4848a3e1)
.incbin_range "baserom/kn7000_program.rom", 0x08a3e1, 0x08a4d8
# InitializeBlock03  (CPU 0x4848a4d8)
.incbin_range "baserom/kn7000_program.rom", 0x08a4d8, 0x08a9b8
# InitializeBlock06  (CPU 0x4848a9b8)
.incbin_range "baserom/kn7000_program.rom", 0x08a9b8, 0x08ae37
# IvSdpartProc  (CPU 0x4848ae37)
.incbin_range "baserom/kn7000_program.rom", 0x08ae37, 0x08ae8d
# AcKsclShiftProc  (CPU 0x4848ae8d)
.incbin_range "baserom/kn7000_program.rom", 0x08ae8d, 0x08c043
# TtSdpart  (CPU 0x4848c043)
.incbin_range "baserom/kn7000_program.rom", 0x08c043, 0x08cbc4
# AcTechniChordProc  (CPU 0x4848cbc4)
.incbin_range "baserom/kn7000_program.rom", 0x08cbc4, 0x08ccd4
# TtSqmixer  (CPU 0x4848ccd4)
.incbin_range "baserom/kn7000_program.rom", 0x08ccd4, 0x08cd01
# AcTcdImageProc  (CPU 0x4848cd01)
.incbin_range "baserom/kn7000_program.rom", 0x08cd01, 0x08d103
# AcResetPageProc  (CPU 0x4848d103)
.incbin_range "baserom/kn7000_program.rom", 0x08d103, 0x08d18b
# AcSpsPartProc  (CPU 0x4848d18b)
.incbin_range "baserom/kn7000_program.rom", 0x08d18b, 0x08d2d7
# AcSpsSoundNameProc  (CPU 0x4848d2d7)
.incbin_range "baserom/kn7000_program.rom", 0x08d2d7, 0x08d969
# AcSpsMmmEditProc  (CPU 0x4848d969)
.incbin_range "baserom/kn7000_program.rom", 0x08d969, 0x08dbc3
# AcSpsVolEditProc  (CPU 0x4848dbc3)
.incbin_range "baserom/kn7000_program.rom", 0x08dbc3, 0x08ddfd
# TtSdkeyscl  (CPU 0x4848ddfd)
.incbin_range "baserom/kn7000_program.rom", 0x08ddfd, 0x08de63
# TtSdmixer  (CPU 0x4848de63)
.incbin_range "baserom/kn7000_program.rom", 0x08de63, 0x08dfa7
# IvExitMixerProc  (CPU 0x4848dfa7)
.incbin_range "baserom/kn7000_program.rom", 0x08dfa7, 0x08e6bf
# IvOtherPartProc  (CPU 0x4848e6bf)
.incbin_range "baserom/kn7000_program.rom", 0x08e6bf, 0x08e716
# IvSdmixerProc  (CPU 0x4848e716)
.incbin_range "baserom/kn7000_program.rom", 0x08e716, 0x08eab6
# AcMixerProc  (CPU 0x4848eab6)
.incbin_range "baserom/kn7000_program.rom", 0x08eab6, 0x08ef2b
# AcMixPageProc  (CPU 0x4848ef2b)
.incbin_range "baserom/kn7000_program.rom", 0x08ef2b, 0x08ef8b
# AcMixerExMenuProc  (CPU 0x4848ef8b)
.incbin_range "baserom/kn7000_program.rom", 0x08ef8b, 0x08f0ae
# IvMixPageCtrlProc  (CPU 0x4848f0ae)
.incbin_range "baserom/kn7000_program.rom", 0x08f0ae, 0x08f1d5
# AcMixPartSoundProc  (CPU 0x4848f1d5)
.incbin_range "baserom/kn7000_program.rom", 0x08f1d5, 0x08f367
# AcMixerCaseProc  (CPU 0x4848f367)
.incbin_range "baserom/kn7000_program.rom", 0x08f367, 0x08f5a6
# AcMixerScreenProc  (CPU 0x4848f5a6)
.incbin_range "baserom/kn7000_program.rom", 0x08f5a6, 0x090ae6
# TtSdtecd  (CPU 0x48490ae6)
.incbin_range "baserom/kn7000_program.rom", 0x090ae6, 0x090bb9
# AcSpsPanProc  (CPU 0x48490bb9)
.incbin_range "baserom/kn7000_program.rom", 0x090bb9, 0x090bef
# AcSpsKsclEditProc  (CPU 0x48490bef)
.incbin_range "baserom/kn7000_program.rom", 0x090bef, 0x090fc0
# AcSpsKsclPartProc  (CPU 0x48490fc0)
.incbin_range "baserom/kn7000_program.rom", 0x090fc0, 0x09109a
# IvSdkeysclProc  (CPU 0x4849109a)
.incbin_range "baserom/kn7000_program.rom", 0x09109a, 0x09125d
# AcKsclTypeEditProc  (CPU 0x4849125d)
.incbin_range "baserom/kn7000_program.rom", 0x09125d, 0x091438
# AcKsclCopyEditProc  (CPU 0x48491438)
.incbin_range "baserom/kn7000_program.rom", 0x091438, 0x0914a1
# AcKsclShiftEditProc  (CPU 0x484914a1)
.incbin_range "baserom/kn7000_program.rom", 0x0914a1, 0x0918c7
# IvMixOtherPartProc  (CPU 0x484918c7)
.incbin_range "baserom/kn7000_program.rom", 0x0918c7, 0x0923e3
# MainSoundAdd  (CPU 0x484923e3)
.incbin_range "baserom/kn7000_program.rom", 0x0923e3, 0x09327b
# InitializeBlock02  (CPU 0x4849327b)
.incbin_range "baserom/kn7000_program.rom", 0x09327b, 0x0936d5
# AcEffectTypeProc  (CPU 0x484936d5)
.incbin_range "baserom/kn7000_program.rom", 0x0936d5, 0x0939cf
# AcMonRcvProc  (CPU 0x484939cf)
.incbin_range "baserom/kn7000_program.rom", 0x0939cf, 0x093ace
# MdNormal  (CPU 0x48493ace)
.incbin_range "baserom/kn7000_program.rom", 0x093ace, 0x093c30
# IvRstOtherPartProc  (CPU 0x48493c30)
.incbin_range "baserom/kn7000_program.rom", 0x093c30, 0x093d33
# AcRhyRunProc  (CPU 0x48493d33)
.incbin_range "baserom/kn7000_program.rom", 0x093d33, 0x093db8
# IvCustomizeHpProc  (CPU 0x48493db8)
.incbin_range "baserom/kn7000_program.rom", 0x093db8, 0x093dc9
# IvCustomizeBaseProc  (CPU 0x48493dc9)
.incbin_range "baserom/kn7000_program.rom", 0x093dc9, 0x093fa9
# IvPageControlOWProc  (CPU 0x48493fa9)
.incbin_range "baserom/kn7000_program.rom", 0x093fa9, 0x0940dd
# AcSplitBoxProc  (CPU 0x484940dd)
.incbin_range "baserom/kn7000_program.rom", 0x0940dd, 0x09430b
# AcFadeBoxProc  (CPU 0x4849430b)
.incbin_range "baserom/kn7000_program.rom", 0x09430b, 0x094491
# TtNormal  (CPU 0x48494491)
.incbin_range "baserom/kn7000_program.rom", 0x094491, 0x09464b
# AcPadRunProc  (CPU 0x4849464b)
.incbin_range "baserom/kn7000_program.rom", 0x09464b, 0x094797
# MainPadRun  (CPU 0x48494797)
.incbin_range "baserom/kn7000_program.rom", 0x094797, 0x0947ea
# AcTrackVolProc  (CPU 0x484947ea)
.incbin_range "baserom/kn7000_program.rom", 0x0947ea, 0x0948bc
# TtCtHomepage  (CPU 0x484948bc)
.incbin_range "baserom/kn7000_program.rom", 0x0948bc, 0x094985
# AcSeqRunProc  (CPU 0x48494985)
.incbin_range "baserom/kn7000_program.rom", 0x094985, 0x094a1b
# AcSeqCurSngNameProc  (CPU 0x48494a1b)
.incbin_range "baserom/kn7000_program.rom", 0x094a1b, 0x094a90
# AcFavBankNameProc  (CPU 0x48494a90)
.incbin_range "baserom/kn7000_program.rom", 0x094a90, 0x094bc0
# AcRightOctProc  (CPU 0x48494bc0)
.incbin_range "baserom/kn7000_program.rom", 0x094bc0, 0x094d5d
# AcSndCtrlXProc  (CPU 0x48494d5d)
.incbin_range "baserom/kn7000_program.rom", 0x094d5d, 0x094d99
# AcSndCtrlYProc  (CPU 0x48494d99)
.incbin_range "baserom/kn7000_program.rom", 0x094d99, 0x094e82
# AcPmemBankNameProc  (CPU 0x48494e82)
.incbin_range "baserom/kn7000_program.rom", 0x094e82, 0x094fa4
# AcUserHpMenuProc  (CPU 0x48494fa4)
.incbin_range "baserom/kn7000_program.rom", 0x094fa4, 0x09510e
# AcFootSwProc  (CPU 0x4849510e)
.incbin_range "baserom/kn7000_program.rom", 0x09510e, 0x095217
# AcPadBankProc  (CPU 0x48495217)
.incbin_range "baserom/kn7000_program.rom", 0x095217, 0x095361
# AcPadNameProc  (CPU 0x48495361)
.incbin_range "baserom/kn7000_program.rom", 0x095361, 0x095477
# AcSndLdOptProc  (CPU 0x48495477)
.incbin_range "baserom/kn7000_program.rom", 0x095477, 0x095547
# AcSndDspAllocProc  (CPU 0x48495547)
.incbin_range "baserom/kn7000_program.rom", 0x095547, 0x0956c6
# AdMovableProc  (CPU 0x484956c6)
.incbin_range "baserom/kn7000_program.rom", 0x0956c6, 0x0956e2
# AcHpBmpProc  (CPU 0x484956e2)
.incbin_range "baserom/kn7000_program.rom", 0x0956e2, 0x0958d5
# AcHpPartsSetProc  (CPU 0x484958d5)
.incbin_range "baserom/kn7000_program.rom", 0x0958d5, 0x0959ed
# AcHpScreenProc  (CPU 0x484959ed)
.incbin_range "baserom/kn7000_program.rom", 0x0959ed, 0x095ac0
# AcMonitorOnProc  (CPU 0x48495ac0)
.incbin_range "baserom/kn7000_program.rom", 0x095ac0, 0x095b9b
# AcRcVolumeProc  (CPU 0x48495b9b)
.incbin_range "baserom/kn7000_program.rom", 0x095b9b, 0x095baa
# MainRhyRun  (CPU 0x48495baa)
.incbin_range "baserom/kn7000_program.rom", 0x095baa, 0x095cb1
# AcMixerVolSProc  (CPU 0x48495cb1)
.incbin_range "baserom/kn7000_program.rom", 0x095cb1, 0x095ecf
# AcHpTypeEditProc  (CPU 0x48495ecf)
.incbin_range "baserom/kn7000_program.rom", 0x095ecf, 0x096238
# AcHpPreviewProc  (CPU 0x48496238)
.incbin_range "baserom/kn7000_program.rom", 0x096238, 0x0967b2
# AcHpPartsListProc  (CPU 0x484967b2)
.incbin_range "baserom/kn7000_program.rom", 0x0967b2, 0x09681e
# AcPmemXNameProc  (CPU 0x4849681e)
.incbin_range "baserom/kn7000_program.rom", 0x09681e, 0x0971f1
# InitializeBlock05  (CPU 0x484971f1)
.incbin_range "baserom/kn7000_program.rom", 0x0971f1, 0x097900
# AcRvariScreenProc  (CPU 0x48497900)
.incbin_range "baserom/kn7000_program.rom", 0x097900, 0x097c33
# AcRhyVariProc  (CPU 0x48497c33)
.incbin_range "baserom/kn7000_program.rom", 0x097c33, 0x097da8
# AcRhyPageProc  (CPU 0x48497da8)
.incbin_range "baserom/kn7000_program.rom", 0x097da8, 0x097e00
# AcRhyGroupProc  (CPU 0x48497e00)
.incbin_range "baserom/kn7000_program.rom", 0x097e00, 0x097ed5
# AcRhyCmpVariProc  (CPU 0x48497ed5)
.incbin_range "baserom/kn7000_program.rom", 0x097ed5, 0x098b01
# AcRhyImageProc  (CPU 0x48498b01)
.incbin_range "baserom/kn7000_program.rom", 0x098b01, 0x098f09
# AcSvariScreenProc  (CPU 0x48498f09)
.incbin_range "baserom/kn7000_program.rom", 0x098f09, 0x0992d0
# AcSndVariProc  (CPU 0x484992d0)
.incbin_range "baserom/kn7000_program.rom", 0x0992d0, 0x09941d
# AcSndPageProc  (CPU 0x4849941d)
.incbin_range "baserom/kn7000_program.rom", 0x09941d, 0x099513
# AcSndGroupProc  (CPU 0x48499513)
.incbin_range "baserom/kn7000_program.rom", 0x099513, 0x099693
# AcSndImageProc  (CPU 0x48499693)
.incbin_range "baserom/kn7000_program.rom", 0x099693, 0x09975c
# AcPartSelectProc  (CPU 0x4849975c)
.incbin_range "baserom/kn7000_program.rom", 0x09975c, 0x09989c
# AcAcdnTypeSwProc  (CPU 0x4849989c)
.incbin_range "baserom/kn7000_program.rom", 0x09989c, 0x099d36
# AcAcdnTabProc  (CPU 0x48499d36)
.incbin_range "baserom/kn7000_program.rom", 0x099d36, 0x099e24
# AcDrawbarScreenProc  (CPU 0x48499e24)
.incbin_range "baserom/kn7000_program.rom", 0x099e24, 0x09a15f
# AcDrawbarProc  (CPU 0x4849a15f)
.incbin_range "baserom/kn7000_program.rom", 0x09a15f, 0x09a26e
# AcTremoloProc  (CPU 0x4849a26e)
.incbin_range "baserom/kn7000_program.rom", 0x09a26e, 0x09a422
# AcPerc223Proc  (CPU 0x4849a422)
.incbin_range "baserom/kn7000_program.rom", 0x09a422, 0x09a573
# AcPerc4Proc  (CPU 0x4849a573)
.incbin_range "baserom/kn7000_program.rom", 0x09a573, 0x09a863
# PsDrawEditProc  (CPU 0x4849a863)
.incbin_range "baserom/kn7000_program.rom", 0x09a863, 0x09a896
# AcDrawAttackProc  (CPU 0x4849a896)
.incbin_range "baserom/kn7000_program.rom", 0x09a896, 0x09a8c9
# AcDrawReleaseProc  (CPU 0x4849a8c9)
.incbin_range "baserom/kn7000_program.rom", 0x09a8c9, 0x09a8fc
# AcPercDecayProc  (CPU 0x4849a8fc)
.incbin_range "baserom/kn7000_program.rom", 0x09a8fc, 0x09a92f
# AcPercLevelProc  (CPU 0x4849a92f)
.incbin_range "baserom/kn7000_program.rom", 0x09a92f, 0x09ab8f
# AcDrawVariProc  (CPU 0x4849ab8f)
.incbin_range "baserom/kn7000_program.rom", 0x09ab8f, 0x09b0f6
# AcSndExpGroupProc  (CPU 0x4849b0f6)
.incbin_range "baserom/kn7000_program.rom", 0x09b0f6, 0x09b248
# AcSndExpVariProc  (CPU 0x4849b248)
.incbin_range "baserom/kn7000_program.rom", 0x09b248, 0x09b558
# AcExpToggleProc  (CPU 0x4849b558)
.incbin_range "baserom/kn7000_program.rom", 0x09b558, 0x09b5ce
# AcSndExpWideESProc  (CPU 0x4849b5ce)
.incbin_range "baserom/kn7000_program.rom", 0x09b5ce, 0x09b6b6
# AcAcdnTypeProc  (CPU 0x4849b6b6)
.incbin_range "baserom/kn7000_program.rom", 0x09b6b6, 0x09bc72
# AcAbcToggleProc  (CPU 0x4849bc72)
.incbin_range "baserom/kn7000_program.rom", 0x09bc72, 0x09bf30
# AcOrganSelectProc  (CPU 0x4849bf30)
.incbin_range "baserom/kn7000_program.rom", 0x09bf30, 0x09c0e4
# AcTabPerc223Proc  (CPU 0x4849c0e4)
.incbin_range "baserom/kn7000_program.rom", 0x09c0e4, 0x09c235
# AcTabPerc4Proc  (CPU 0x4849c235)
.incbin_range "baserom/kn7000_program.rom", 0x09c235, 0x09c386
# AcTabVibratoProc  (CPU 0x4849c386)
.incbin_range "baserom/kn7000_program.rom", 0x09c386, 0x09c515
# AcTabTremulantProc  (CPU 0x4849c515)
.incbin_range "baserom/kn7000_program.rom", 0x09c515, 0x09c777
# PsUsrBmpToggleProc  (CPU 0x4849c777)
    movm    [d2,a2], (sp)
    add     -0x14, sp
    cmp     0x600bc, d1
    beq     0x4849c78f
    cmp     0x60092, d1
    beq     0x4849c7a4
    jmp     0x4849c834
    call    GetLinkView, 0, 0
    movhu   (0x20, a0), d1
    mov     0x002000b0, d0
    exth    d1
    add     d1, d0
    ret     [d2,a2], 0x1c
    call    GetLinkView, 0, 0
    mov     a0, a2
    call    func_4849BC1A, [d2], 0x18
    exth    d0
    cmp     0, d0
    beq     0x4849c7bc
    cmp     1, d0
    beq     0x4849c7de
    bra     0x4849c800
    mov     (0x2c, sp), a1
    cmp     0, a1
    beq     0x4849c7d0
    movhu   (0x20, a2), d0
    mov     0x48601ce8, a0
    exth    d0
    .byte 0xF4   # movbu (d0, a0), d2
    add     -0x36, a0
    inc4    a2
    movhu   (0x20, a2), d0
    mov     0x48601cf5, a0
    exth    d0
    .byte 0xF4   # movbu (d0, a0), d2
    add     -0x36, a0
    inc     d1
    mov     (0x2c, sp), a0
    cmp     0, a0
    beq     0x4849c7f2
    movhu   (0x20, a2), d0
    mov     0x48601d02, a0
    exth    d0
    .byte 0xF4   # movbu (d0, a0), d2
    add     -0x36, a0
    mov     (0x62f8), d0
    add     -4, a0
    jmp     0x90a9e505
    exth    d0
    .byte 0xF4   # movbu (d0, a0), d2
    add     -0x36, a0
    add     0x5c, a2
    mov     0xb0, d0
    beq     0x4849c814
    movhu   (0x20, a2), d0
    mov     0x48601d1c, a0
    exth    d0
    .byte 0xF4   # movbu (d0, a0), d2
    add     -0x36, a0
    movbu   d3, (0x62f8)
    add     -4, a0
    jmp     0x90a9e541
    exth    d0
    .byte 0xF4   # movbu (d0, a0), d2
    add     -4, a0
    cmp     0x20, d1
    mov     d0, (0x4800)
    asl2    d2
    add     0x48000000, d1
    mov     d1, a0
    mov     (d2, a0), d0
    add     d1, d0
    bra     0x4849c83f
    mov     (0x2c, sp), a0
    mov     a0, (0x10, sp)
    call    func_48429569, [d2,d3,a2,a3], 0x28
    ret     [d2,a2], 0x1c
    movm    [d2,d3,a2,a3], (sp)
    add     -0x18, sp
    mov     (0x5006b808), d0
    cmp     8, d0
    beq     0x4849c885
    movhu   (0x5006b7ee), d0
    exth    d0
    cmp     0x10, d0
    bne     0x4849c885
    movhu   (0x5006b7ec), d0
    mov     sp, a0
    movbu   d0, (0x10, sp)
    movbu   (0x10, sp), d0
    add     0x14, a0
    call    func_484483B7, [d2,d3,a2,a3], 0x50
    movhu   (0x14, sp), d0
    movhu   d0, (0x5006b86a)
    mov     1, d0
    movhu   d0, (0x5006b86c)
    bra     0x4849c8da
    movhu   (0x5006b7ec), d0
    mov     0x002000b0, a2
    asl     24, d0
    mov     d0, a3
    mov     a2, d3
    clr     d0
    movhu   d0, (0x5006b86a)
    mov     d3, d0
    mov     a3, d1
    call    0x4c0149fa, 0, 0x10
    and     0xff, d0
    extbu   d0
    cmp     0, d0
    beq     0x4849c8ca
    movhu   (0x5006b86a), d2
    mov     d3, d0
    sub     a2, d0
    mov     0x00008000, d1
    asr     d0, d1
    or      d1, d2
    movhu   d2, (0x5006b86a)
    inc     d3
    cmp     0x2000bf, d3
    bls     0x4849c89f
    clr     d0
    movhu   d0, (0x5006b86c)
    ret     [d2,d3,a2,a3], 0x28
    movm    [d2,a2], (sp)
    add     -0x10, sp
    mov     a0, a2
    mov     d0, d2
    call    func_4842B30C, 0, 0x10
    cmp     0xe000e, d0
    bne     0x4849c8fd
    movhu   (0x5006b86c), d0
    cmp     0, d0
    bne     0x4849c908
    mov     a2, a0
    mov     d2, d0
    call    0x4c014948, [d2,d3,a2], 0x24
    bra     0x4849c946
    mov     0x002000b0, a1
    cmp     a1, d2
    bcs     0x4849c93d
    cmp     0x2000bf, d2
    bhi     0x4849c93d
    mov     (a2), d0
    sub     a1, d2
    and     0xff000000, d0
    mov     d0, (a2)
    movhu   (0x5006b86a), d1
    mov     0x00008000, d0
    asr     d2, d0
    and     d0, d1
    beq     0x4849c946
    mov     (a2), d0
    or      0x01, d0
    mov     d0, (a2)
    bra     0x4849c946
    mov     a2, a0
    mov     d2, d0
    call    0x4c014948, [d2,d3,a2], 0x24
    clr     d0
    ret     [d2,a2], 0x18
    movm    [d2,d3,a2,a3], (sp)
    add     -0x14, sp
    mov     d1, a3
    mov     d0, a2
    call    func_4842B30C, 0, 0x10
    cmp     0xe000e, d0
    bne     0x4849c96c
    movhu   (0x5006b86c), d0
    cmp     0, d0
    bne     0x4849c97a
    mov     a2, d0
    mov     a3, d1
    call    func_4841C37C, [d2,d3,a2], 0x20
    jmp     0x4849ca59
    mov     0x002000b0, d1
    cmp     d1, a2
    bcc     0x4849c987
    jmp     0x4849ca4e
    cmp     0x2000bf, a2
    bls     0x4849c992
    jmp     0x4849ca4e
    movhu   (0x5006b86a), d3
    mov     a2, a0
    sub     d1, a0
    mov     0x00008000, d0
    mov     a0, d1
    asr     d1, d0
    mov     d0, d1
    and     d3, d1
    beq     0x4849c9c7
    mov     a3, d2
    and     0xff, d2
    mov     d2, d1
    extbu   d1
    cmp     0, d1
    beq     0x4849c9b9
    clr     d0
    ret     [d2,d3,a2,a3], 0x24
    xor     0xffff, d0
    and     d0, d3
    movhu   d3, (0x5006b86a)
    bra     0x4849c9de
    mov     a3, d2
    and     0xff, d2
    mov     d2, d1
    extbu   d1
    cmp     0, d1
    bne     0x4849c9d6
    clr     d0
    ret     [d2,d3,a2,a3], 0x24
    or      d0, d3
    movhu   d3, (0x5006b86a)
    mov     a3, d0
    and     0xff000000, d0
    mov     d0, d3
    lsr     24, d3
    extbu   d2
    mov     d2, (0x10, sp)
    mov     d3, d0
    extbu   d0
    mov     0xd2, d1
    add     a0, d1
    extbu   d1
    call    0x4c029844, [d2], 0x18
    call    func_48414B90, 0, 0x14
    extbu   d3
    mov     d3, d0
    exthu   d0
    call    func_48453170, [d2,d3,a2,a3], 0x54
    call    func_48414BAA, 0, 0x14
    mov     0x10, d0
    call    func_4841662A, [d2,a2,a3], 0x28
    mov     a2, d0
    and     0x00ffffff, d0
    mov     d0, (a0)
    mov     a3, (4, a0)
    mov     a0, a2
    mov     a2, (0x10, sp)
    mov     -1, d0
    mov     0x00050014, d1
    call    func_484298A0, [d2], 0x1c
    mov     a2, (0x10, sp)
    mov     -1, d0
    mov     0x00060023, d1
    call    func_484298A0, [d2], 0x1c
    bra     0x4849ca59
    mov     a2, d0
    mov     a3, d1
    call    func_4841C37C, [d2,d3,a2], 0x20
    clr     d0
    ret     [d2,d3,a2,a3], 0x24
    cmp     0x6003b, d1
    bne     0x4849ca6d
    mov     0xa, d0
    mov     d0, (0x5006b808)
    clr     d0
    retf    0, 0
# AcOrganTabProc  (CPU 0x4849ca71)
.incbin_range "baserom/kn7000_program.rom", 0x09ca71, 0x09cb19
# InitializeBlock07  (CPU 0x4849cb19)
.incbin_range "baserom/kn7000_program.rom", 0x09cb19, 0x09d101
# AcFavoriteProc  (CPU 0x4849d101)
.incbin_range "baserom/kn7000_program.rom", 0x09d101, 0x09e4c5
# AcFavItemProc  (CPU 0x4849e4c5)
.incbin_range "baserom/kn7000_program.rom", 0x09e4c5, 0x09e75a
# AcFavBankProc  (CPU 0x4849e75a)
.incbin_range "baserom/kn7000_program.rom", 0x09e75a, 0x09ea59
# AcFavCategoryProc  (CPU 0x4849ea59)
.incbin_range "baserom/kn7000_program.rom", 0x09ea59, 0x09eea0
# InitializeBlock21  (CPU 0x4849eea0)
.incbin_range "baserom/kn7000_program.rom", 0x09eea0, 0x09f16f
# StylCnvLangCheck  (CPU 0x4849f16f)
.incbin_range "baserom/kn7000_program.rom", 0x09f16f, 0x09f1f0
# StylCnvStorBnkSel  (CPU 0x4849f1f0)
.incbin_range "baserom/kn7000_program.rom", 0x09f1f0, 0x09f21a
# PsSCTxtBox2Proc  (CPU 0x4849f21a)
.incbin_range "baserom/kn7000_program.rom", 0x09f21a, 0x09f2b0
# StylCnvStorOkFunc  (CPU 0x4849f2b0)
.incbin_range "baserom/kn7000_program.rom", 0x09f2b0, 0x09f73f
# PsParaListBoxProc  (CPU 0x4849f73f)
.incbin_range "baserom/kn7000_program.rom", 0x09f73f, 0x09f7c5
# PsSCTxtBoxProc  (CPU 0x4849f7c5)
.incbin_range "baserom/kn7000_program.rom", 0x09f7c5, 0x09f85b
# InitializeBlock15  (CPU 0x4849f85b)
.incbin_range "baserom/kn7000_program.rom", 0x09f85b, 0x0a0165
# RomTestRunFunc  (CPU 0x484a0165)
.incbin_range "baserom/kn7000_program.rom", 0x0a0165, 0x0a018e
# MainRomTestFunc  (CPU 0x484a018e)
.incbin_range "baserom/kn7000_program.rom", 0x0a018e, 0x0a03a3
# AllOKNGParaBoxProc  (CPU 0x484a03a3)
.incbin_range "baserom/kn7000_program.rom", 0x0a03a3, 0x0a0622
# DspTestFunc  (CPU 0x484a0622)
.incbin_range "baserom/kn7000_program.rom", 0x0a0622, 0x0a0626
# OthDeviceTestRunFunc  (CPU 0x484a0626)
.incbin_range "baserom/kn7000_program.rom", 0x0a0626, 0x0a062a
# MainDeviceTestFunc  (CPU 0x484a062a)
.incbin_range "baserom/kn7000_program.rom", 0x0a062a, 0x0a062e
# RamTestRunFunc  (CPU 0x484a062e)
.incbin_range "baserom/kn7000_program.rom", 0x0a062e, 0x0a0657
# MainRamTestFunc  (CPU 0x484a0657)
.incbin_range "baserom/kn7000_program.rom", 0x0a0657, 0x0a09e0
# DspShowHideFunc  (CPU 0x484a09e0)
.incbin_range "baserom/kn7000_program.rom", 0x0a09e0, 0x0a0a09
# FdTestRunFunc  (CPU 0x484a0a09)
.incbin_range "baserom/kn7000_program.rom", 0x0a0a09, 0x0a0a32
# MainDspCheck  (CPU 0x484a0a32)
.incbin_range "baserom/kn7000_program.rom", 0x0a0a32, 0x0a0a95
# FdTestStopFunc  (CPU 0x484a0a95)
.incbin_range "baserom/kn7000_program.rom", 0x0a0a95, 0x0a11f7
# FdIoFunc  (CPU 0x484a11f7)
.incbin_range "baserom/kn7000_program.rom", 0x0a11f7, 0x0a1396
# InOutTestFilter  (CPU 0x484a1396)
.incbin_range "baserom/kn7000_program.rom", 0x0a1396, 0x0a13e1
# TestModeFunc  (CPU 0x484a13e1)
.incbin_range "baserom/kn7000_program.rom", 0x0a13e1, 0x0a148d
# CpRamEditCheck  (CPU 0x484a148d)
.incbin_range "baserom/kn7000_program.rom", 0x0a148d, 0x0a14b6
# TestDiskFunc  (CPU 0x484a14b6)
.incbin_range "baserom/kn7000_program.rom", 0x0a14b6, 0x0a16dd
# TestRgbwbRunFunc  (CPU 0x484a16dd)
.incbin_range "baserom/kn7000_program.rom", 0x0a16dd, 0x0a170d
# TestRgbwbFunc  (CPU 0x484a170d)
.incbin_range "baserom/kn7000_program.rom", 0x0a170d, 0x0a173d
# TestCrosstarlRunFunc  (CPU 0x484a173d)
.incbin_range "baserom/kn7000_program.rom", 0x0a173d, 0x0a1766
# TestCrosstalkFunc  (CPU 0x484a1766)
.incbin_range "baserom/kn7000_program.rom", 0x0a1766, 0x0a1805
# TestSampleRunFunc  (CPU 0x484a1805)
.incbin_range "baserom/kn7000_program.rom", 0x0a1805, 0x0a1835
# TestSampleFunc  (CPU 0x484a1835)
.incbin_range "baserom/kn7000_program.rom", 0x0a1835, 0x0a1865
# TestContrastRunFunc  (CPU 0x484a1865)
.incbin_range "baserom/kn7000_program.rom", 0x0a1865, 0x0a1895
# TestContrastFunc  (CPU 0x484a1895)
.incbin_range "baserom/kn7000_program.rom", 0x0a1895, 0x0a18fa
# TestVideoOutRunFunc  (CPU 0x484a18fa)
.incbin_range "baserom/kn7000_program.rom", 0x0a18fa, 0x0a19a6
# SineWaveWindowProc  (CPU 0x484a19a6)
.incbin_range "baserom/kn7000_program.rom", 0x0a19a6, 0x0a1aad
# SineWaveFilter  (CPU 0x484a1aad)
.incbin_range "baserom/kn7000_program.rom", 0x0a1aad, 0x0a26df
# TestVideoOutFunc  (CPU 0x484a26df)
.incbin_range "baserom/kn7000_program.rom", 0x0a26df, 0x0a2cb1
# TestVideoOutCatch  (CPU 0x484a2cb1)
.incbin_range "baserom/kn7000_program.rom", 0x0a2cb1, 0x0a2d5f
# BassPedalSw  (CPU 0x484a2d5f)
.incbin_range "baserom/kn7000_program.rom", 0x0a2d5f, 0x0a2e11
# MidiIoCatch  (CPU 0x484a2e11)
.incbin_range "baserom/kn7000_program.rom", 0x0a2e11, 0x0a2e3a
# TestMICFunc  (CPU 0x484a2e3a)
.incbin_range "baserom/kn7000_program.rom", 0x0a2e3a, 0x0a2fea
# FDCstopBitmapCheck  (CPU 0x484a2fea)
.incbin_range "baserom/kn7000_program.rom", 0x0a2fea, 0x0a302f
# StestWindowProc  (CPU 0x484a302f)
.incbin_range "baserom/kn7000_program.rom", 0x0a302f, 0x0a3605
# BoardTestFunc  (CPU 0x484a3605)
.incbin_range "baserom/kn7000_program.rom", 0x0a3605, 0x0a3640
# MainWaveRomTestFunc  (CPU 0x484a3640)
.incbin_range "baserom/kn7000_program.rom", 0x0a3640, 0x0a36e0
# MainSvariIni  (CPU 0x484a36e0)
.incbin_range "baserom/kn7000_program.rom", 0x0a36e0, 0x0a3a62
# SdCover  (CPU 0x484a3a62)
.incbin_range "baserom/kn7000_program.rom", 0x0a3a62, 0x0a3b4a
# BoardRomTestRunFunc  (CPU 0x484a3b4a)
.incbin_range "baserom/kn7000_program.rom", 0x0a3b4a, 0x0a3b8a
# SDTestStartFunc  (CPU 0x484a3b8a)
.incbin_range "baserom/kn7000_program.rom", 0x0a3b8a, 0x0a3bb3
# SDTestStopFunc  (CPU 0x484a3bb3)
.incbin_range "baserom/kn7000_program.rom", 0x0a3bb3, 0x0a3c5f
# SineSweepTestRunFunc  (CPU 0x484a3c5f)
.incbin_range "baserom/kn7000_program.rom", 0x0a3c5f, 0x0a3d0a
# TestSDAudioCatch  (CPU 0x484a3d0a)
.incbin_range "baserom/kn7000_program.rom", 0x0a3d0a, 0x0a3e39
# AcTestMenuPageProc  (CPU 0x484a3e39)
.incbin_range "baserom/kn7000_program.rom", 0x0a3e39, 0x0a401e
# LEDHideOffFunc  (CPU 0x484a401e)
.incbin_range "baserom/kn7000_program.rom", 0x0a401e, 0x0a40f8
# MainCpCheck  (CPU 0x484a40f8)
.incbin_range "baserom/kn7000_program.rom", 0x0a40f8, 0x0a497b
# Test7Func  (CPU 0x484a497b)
.incbin_range "baserom/kn7000_program.rom", 0x0a497b, 0x0a4a2b
# InOutTestWindowProc  (CPU 0x484a4a2b)
.incbin_range "baserom/kn7000_program.rom", 0x0a4a2b, 0x0a4a82
# BoardTestWindowProc  (CPU 0x484a4a82)
.incbin_range "baserom/kn7000_program.rom", 0x0a4a82, 0x0a4ba1
# OKNGParaBoxProc  (CPU 0x484a4ba1)
.incbin_range "baserom/kn7000_program.rom", 0x0a4ba1, 0x0a4bfc
# AcItimatuWindowProc  (CPU 0x484a4bfc)
.incbin_range "baserom/kn7000_program.rom", 0x0a4bfc, 0x0a5548
# MainSvariSet  (CPU 0x484a5548)
.incbin_range "baserom/kn7000_program.rom", 0x0a5548, 0x0a55f0
# Test2Func  (CPU 0x484a55f0)
.incbin_range "baserom/kn7000_program.rom", 0x0a55f0, 0x0a56e1
# Test3Func  (CPU 0x484a56e1)
.incbin_range "baserom/kn7000_program.rom", 0x0a56e1, 0x0a5742
# Test4Func  (CPU 0x484a5742)
.incbin_range "baserom/kn7000_program.rom", 0x0a5742, 0x0a5791
# Test5Func  (CPU 0x484a5791)
.incbin_range "baserom/kn7000_program.rom", 0x0a5791, 0x0a582d
# Test6Func  (CPU 0x484a582d)
.incbin_range "baserom/kn7000_program.rom", 0x0a582d, 0x0a58f6
# WaveRomTestRunFunc  (CPU 0x484a58f6)
.incbin_range "baserom/kn7000_program.rom", 0x0a58f6, 0x0a5e36
# InitializeBlock17  (CPU 0x484a5e36)
.incbin_range "baserom/kn7000_program.rom", 0x0a5e36, 0x0a612c
# CustomPanelFlashFunc  (CPU 0x484a612c)
.incbin_range "baserom/kn7000_program.rom", 0x0a612c, 0x0a6c14
# CustRhyStopFunc  (CPU 0x484a6c14)
.incbin_range "baserom/kn7000_program.rom", 0x0a6c14, 0x0a6c50
# DispTimeSetGridCheck  (CPU 0x484a6c50)
.incbin_range "baserom/kn7000_program.rom", 0x0a6c50, 0x0a6c84
# DispTimeSetOKFunc  (CPU 0x484a6c84)
.incbin_range "baserom/kn7000_program.rom", 0x0a6c84, 0x0a6d4c
# WallHomeEditCheck  (CPU 0x484a6d4c)
.incbin_range "baserom/kn7000_program.rom", 0x0a6d4c, 0x0a6e14
# WallMenuEditCheck  (CPU 0x484a6e14)
.incbin_range "baserom/kn7000_program.rom", 0x0a6e14, 0x0a6edc
# WallOthEditCheck  (CPU 0x484a6edc)
.incbin_range "baserom/kn7000_program.rom", 0x0a6edc, 0x0a6f10
# WallSetOKFunc  (CPU 0x484a6f10)
.incbin_range "baserom/kn7000_program.rom", 0x0a6f10, 0x0a70a9
# MainTimeFlashFunc  (CPU 0x484a70a9)
.incbin_range "baserom/kn7000_program.rom", 0x0a70a9, 0x0a7146
# WallPresetCheck  (CPU 0x484a7146)
.incbin_range "baserom/kn7000_program.rom", 0x0a7146, 0x0a718e
# CusMemOKFunc  (CPU 0x484a718e)
.incbin_range "baserom/kn7000_program.rom", 0x0a718e, 0x0a7201
# AcDispTimeSetGridBoxProc  (CPU 0x484a7201)
.incbin_range "baserom/kn7000_program.rom", 0x0a7201, 0x0a7540
# WallSetBitmapCheck  (CPU 0x484a7540)
.incbin_range "baserom/kn7000_program.rom", 0x0a7540, 0x0a79d9
# ParaLoadOptGridCheck  (CPU 0x484a79d9)
.incbin_range "baserom/kn7000_program.rom", 0x0a79d9, 0x0a7a0d
# MainWallSetFlashFunc  (CPU 0x484a7a0d)
.incbin_range "baserom/kn7000_program.rom", 0x0a7a0d, 0x0a7a49
# ParaLoadOptOKFunc  (CPU 0x484a7a49)
.incbin_range "baserom/kn7000_program.rom", 0x0a7a49, 0x0a81d6
# DataProtectGridCheck  (CPU 0x484a81d6)
.incbin_range "baserom/kn7000_program.rom", 0x0a81d6, 0x0a820a
# MainFlashFunc  (CPU 0x484a820a)
.incbin_range "baserom/kn7000_program.rom", 0x0a820a, 0x0a8246
# WallSetHideFunc  (CPU 0x484a8246)
.incbin_range "baserom/kn7000_program.rom", 0x0a8246, 0x0a82b9
# LangSetOKFunc  (CPU 0x484a82b9)
.incbin_range "baserom/kn7000_program.rom", 0x0a82b9, 0x0a82db
# MainDtPrtFlashFunc  (CPU 0x484a82db)
.incbin_range "baserom/kn7000_program.rom", 0x0a82db, 0x0a8317
# LangSetFlashFunc  (CPU 0x484a8317)
.incbin_range "baserom/kn7000_program.rom", 0x0a8317, 0x0a831b
# LangSetMenuCheck  (CPU 0x484a831b)
.incbin_range "baserom/kn7000_program.rom", 0x0a831b, 0x0a8374
# DataProtectOKFunc  (CPU 0x484a8374)
.incbin_range "baserom/kn7000_program.rom", 0x0a8374, 0x0a83a8
# DataPrtHideFunc  (CPU 0x484a83a8)
.incbin_range "baserom/kn7000_program.rom", 0x0a83a8, 0x0a842c
# AcParaLoadOptGridBoxProc  (CPU 0x484a842c)
.incbin_range "baserom/kn7000_program.rom", 0x0a842c, 0x0a867c
# AcIndexWideToggleProc  (CPU 0x484a867c)
.incbin_range "baserom/kn7000_program.rom", 0x0a867c, 0x0a888d
# LangSetChkMain  (CPU 0x484a888d)
.incbin_range "baserom/kn7000_program.rom", 0x0a888d, 0x0a88c9
# AcIndexWideToggleFunc  (CPU 0x484a88c9)
.incbin_range "baserom/kn7000_program.rom", 0x0a88c9, 0x0a88fd
# LangSetHideFunc  (CPU 0x484a88fd)
.incbin_range "baserom/kn7000_program.rom", 0x0a88fd, 0x0a8970
# InitializeBlock16  (CPU 0x484a8970)
.incbin_range "baserom/kn7000_program.rom", 0x0a8970, 0x0a8e14
# CtrlRhyStopFunc  (CPU 0x484a8e14)
.incbin_range "baserom/kn7000_program.rom", 0x0a8e14, 0x0a90e1
# AcFadeSetGridBoxProc  (CPU 0x484a90e1)
.incbin_range "baserom/kn7000_program.rom", 0x0a90e1, 0x0aa5a7
# FadeInOutTitleFunc  (CPU 0x484aa5a7)
.incbin_range "baserom/kn7000_program.rom", 0x0aa5a7, 0x0aa5df
# PmemModeBoxProc  (CPU 0x484aa5df)
.incbin_range "baserom/kn7000_program.rom", 0x0aa5df, 0x0aa8c1
# MSATitleFunc  (CPU 0x484aa8c1)
.incbin_range "baserom/kn7000_program.rom", 0x0aa8c1, 0x0aa93d
# MSAModeBoxProc  (CPU 0x484aa93d)
.incbin_range "baserom/kn7000_program.rom", 0x0aa93d, 0x0aacaa
# AcFSWAssGridBoxProc  (CPU 0x484aacaa)
.incbin_range "baserom/kn7000_program.rom", 0x0aacaa, 0x0ab426
# MainSysControl  (CPU 0x484ab426)
.incbin_range "baserom/kn7000_program.rom", 0x0ab426, 0x0ab480
# AcPmExpFilterGridBoxProc  (CPU 0x484ab480)
.incbin_range "baserom/kn7000_program.rom", 0x0ab480, 0x0cef78
# InitializeBlock23  (CPU 0x484cef78)
.incbin_range "baserom/kn7000_program.rom", 0x0cef78, 0x0d0426
# AcMidiPartGridBoxProc  (CPU 0x484d0426)
.incbin_range "baserom/kn7000_program.rom", 0x0d0426, 0x0d131e
# AcMidiControlGridBoxProc  (CPU 0x484d131e)
.incbin_range "baserom/kn7000_program.rom", 0x0d131e, 0x0d20fc
# AcMidiInputGridBoxProc  (CPU 0x484d20fc)
.incbin_range "baserom/kn7000_program.rom", 0x0d20fc, 0x0d259a
# IvMpstPageControlProc  (CPU 0x484d259a)
.incbin_range "baserom/kn7000_program.rom", 0x0d259a, 0x0d2c77
# AcMidiPcgOutGridBoxProc  (CPU 0x484d2c77)
.incbin_range "baserom/kn7000_program.rom", 0x0d2c77, 0x0d2e59
# AcTGModeSelProc  (CPU 0x484d2e59)
.incbin_range "baserom/kn7000_program.rom", 0x0d2e59, 0x0d39f8
# AcMidiPcgOutSendEditSwProc  (CPU 0x484d39f8)
.incbin_range "baserom/kn7000_program.rom", 0x0d39f8, 0x0d3db8
# AcMidiPmemOutLGridBoxProc  (CPU 0x484d3db8)
.incbin_range "baserom/kn7000_program.rom", 0x0d3db8, 0x0d544e
# InitializeBlock24  (CPU 0x484d544e)
.incbin_range "baserom/kn7000_program.rom", 0x0d544e, 0x0d5b3b
# PmemBankView  (CPU 0x484d5b3b)
.incbin_range "baserom/kn7000_program.rom", 0x0d5b3b, 0x0d5b7a
# PmemBankNaming  (CPU 0x484d5b7a)
.incbin_range "baserom/kn7000_program.rom", 0x0d5b7a, 0x0d5bc3
# PmemNaming  (CPU 0x484d5bc3)
.incbin_range "baserom/kn7000_program.rom", 0x0d5bc3, 0x0d5f18
# InitializeBlock25  (CPU 0x484d5f18)
.incbin_range "baserom/kn7000_program.rom", 0x0d5f18, 0x0d7bbd
# InitializeBlock26  (CPU 0x484d7bbd)
.incbin_range "baserom/kn7000_program.rom", 0x0d7bbd, 0x0d83ac
# AcResetPageSeProc  (CPU 0x484d83ac)
.incbin_range "baserom/kn7000_program.rom", 0x0d83ac, 0x0d83f6
# IvExitWriteSeProc  (CPU 0x484d83f6)
.incbin_range "baserom/kn7000_program.rom", 0x0d83f6, 0x0d845c
# AcTitleMenuView1SeProc  (CPU 0x484d845c)
.incbin_range "baserom/kn7000_program.rom", 0x0d845c, 0x0d84c2
# AcTitleMenuView2SeProc  (CPU 0x484d84c2)
.incbin_range "baserom/kn7000_program.rom", 0x0d84c2, 0x0d8528
# AcTitleMenuView3SeProc  (CPU 0x484d8528)
.incbin_range "baserom/kn7000_program.rom", 0x0d8528, 0x0d858e
# AcLfoPageSeProc  (CPU 0x484d858e)
.incbin_range "baserom/kn7000_program.rom", 0x0d858e, 0x0d8675
# AcSoloToggleSeProc  (CPU 0x484d8675)
.incbin_range "baserom/kn7000_program.rom", 0x0d8675, 0x0d87ec
# AcFuncBoxSeProc  (CPU 0x484d87ec)
.incbin_range "baserom/kn7000_program.rom", 0x0d87ec, 0x0d885f
# VwSnameSeProc  (CPU 0x484d885f)
.incbin_range "baserom/kn7000_program.rom", 0x0d885f, 0x0d88d2
# VwDottedLineSeProc  (CPU 0x484d88d2)
.incbin_range "baserom/kn7000_program.rom", 0x0d88d2, 0x0d897a
# AcDrumGridBoxSe2Proc  (CPU 0x484d897a)
.incbin_range "baserom/kn7000_program.rom", 0x0d897a, 0x0d8b1d
# Ed4thOnSe  (CPU 0x484d8b1d)
.incbin_range "baserom/kn7000_program.rom", 0x0d8b1d, 0x0d8bf4
# EzBrillSe  (CPU 0x484d8bf4)
.incbin_range "baserom/kn7000_program.rom", 0x0d8bf4, 0x0d8cea
# EzVibDepSe  (CPU 0x484d8cea)
.incbin_range "baserom/kn7000_program.rom", 0x0d8cea, 0x0d8dc6
# EzVibSpdSe  (CPU 0x484d8dc6)
.incbin_range "baserom/kn7000_program.rom", 0x0d8dc6, 0x0d8ea2
# EzVibDlySe  (CPU 0x484d8ea2)
.incbin_range "baserom/kn7000_program.rom", 0x0d8ea2, 0x0d8f7e
# EzAtkSe  (CPU 0x484d8f7e)
.incbin_range "baserom/kn7000_program.rom", 0x0d8f7e, 0x0d905a
# EzRlsSe  (CPU 0x484d905a)
.incbin_range "baserom/kn7000_program.rom", 0x0d905a, 0x0d93b2
# Ed1stOnSe  (CPU 0x484d93b2)
.incbin_range "baserom/kn7000_program.rom", 0x0d93b2, 0x0d9445
# Ed2ndOnSe  (CPU 0x484d9445)
.incbin_range "baserom/kn7000_program.rom", 0x0d9445, 0x0d94d9
# Ed3rdOnSe  (CPU 0x484d94d9)
.incbin_range "baserom/kn7000_program.rom", 0x0d94d9, 0x0d956d
# DrumCtrlGridSe  (CPU 0x484d956d)
.incbin_range "baserom/kn7000_program.rom", 0x0d956d, 0x0d9624
# GlideEditSe  (CPU 0x484d9624)
.incbin_range "baserom/kn7000_program.rom", 0x0d9624, 0x0d979d
# OctShiftSe  (CPU 0x484d979d)
.incbin_range "baserom/kn7000_program.rom", 0x0d979d, 0x0d9919
# RightSplitSe  (CPU 0x484d9919)
.incbin_range "baserom/kn7000_program.rom", 0x0d9919, 0x0d9a92
# DrumTsetGridSe  (CPU 0x484d9a92)
.incbin_range "baserom/kn7000_program.rom", 0x0d9a92, 0x0d9c03
# MonoPolySe  (CPU 0x484d9c03)
.incbin_range "baserom/kn7000_program.rom", 0x0d9c03, 0x0d9d22
# PortamentOnSe  (CPU 0x484d9d22)
.incbin_range "baserom/kn7000_program.rom", 0x0d9d22, 0x0d9e2f
# LfoGridSe4  (CPU 0x484d9e2f)
.incbin_range "baserom/kn7000_program.rom", 0x0d9e2f, 0x0d9f73
# DspDptSe  (CPU 0x484d9f73)
.incbin_range "baserom/kn7000_program.rom", 0x0d9f73, 0x0da0b7
# DspOnSe  (CPU 0x484da0b7)
.incbin_range "baserom/kn7000_program.rom", 0x0da0b7, 0x0da1cb
# DspTenSe  (CPU 0x484da1cb)
.incbin_range "baserom/kn7000_program.rom", 0x0da1cb, 0x0da2df
# DspSufSe  (CPU 0x484da2df)
.incbin_range "baserom/kn7000_program.rom", 0x0da2df, 0x0da515
# DrumDspOnSe  (CPU 0x484da515)
.incbin_range "baserom/kn7000_program.rom", 0x0da515, 0x0da74b
# DspGroupSe  (CPU 0x484da74b)
.incbin_range "baserom/kn7000_program.rom", 0x0da74b, 0x0da991
# DrumDspGroupSe  (CPU 0x484da991)
.incbin_range "baserom/kn7000_program.rom", 0x0da991, 0x0dabd7
# DspVariSe  (CPU 0x484dabd7)
.incbin_range "baserom/kn7000_program.rom", 0x0dabd7, 0x0dad8c
# DrumDspVariSe  (CPU 0x484dad8c)
.incbin_range "baserom/kn7000_program.rom", 0x0dad8c, 0x0daf41
# DspVOnSe  (CPU 0x484daf41)
.incbin_range "baserom/kn7000_program.rom", 0x0daf41, 0x0db027
# DrumDspVOnSe  (CPU 0x484db027)
.incbin_range "baserom/kn7000_program.rom", 0x0db027, 0x0db10d
# DeffVal7SwSe  (CPU 0x484db10d)
.incbin_range "baserom/kn7000_program.rom", 0x0db10d, 0x0db251
# ChoOnSe  (CPU 0x484db251)
.incbin_range "baserom/kn7000_program.rom", 0x0db251, 0x0db337
# ChoDptSe  (CPU 0x484db337)
.incbin_range "baserom/kn7000_program.rom", 0x0db337, 0x0db3d3
# DrumDspDptSe  (CPU 0x484db3d3)
.incbin_range "baserom/kn7000_program.rom", 0x0db3d3, 0x0db510
# DeffOnSe  (CPU 0x484db510)
.incbin_range "baserom/kn7000_program.rom", 0x0db510, 0x0db5c7
# DeffStereoSe  (CPU 0x484db5c7)
.incbin_range "baserom/kn7000_program.rom", 0x0db5c7, 0x0db7c2
# DrumNamingFixSe  (CPU 0x484db7c2)
.incbin_range "baserom/kn7000_program.rom", 0x0db7c2, 0x0db85b
# DrumKeyNameSe  (CPU 0x484db85b)
.incbin_range "baserom/kn7000_program.rom", 0x0db85b, 0x0db92d
# DrumRevAdjSe  (CPU 0x484db92d)
.incbin_range "baserom/kn7000_program.rom", 0x0db92d, 0x0db9f9
# DrumPrioritySe  (CPU 0x484db9f9)
.incbin_range "baserom/kn7000_program.rom", 0x0db9f9, 0x0dbae4
# DrumGDumpOnSe  (CPU 0x484dbae4)
.incbin_range "baserom/kn7000_program.rom", 0x0dbae4, 0x0dbbac
# DrumFilterGridSe  (CPU 0x484dbbac)
.incbin_range "baserom/kn7000_program.rom", 0x0dbbac, 0x0dbcbb
# DrumGraphKeyOffXSe  (CPU 0x484dbcbb)
.incbin_range "baserom/kn7000_program.rom", 0x0dbcbb, 0x0dbde1
# CopyFromSe  (CPU 0x484dbde1)
.incbin_range "baserom/kn7000_program.rom", 0x0dbde1, 0x0dbf07
# CopyToSe  (CPU 0x484dbf07)
.incbin_range "baserom/kn7000_program.rom", 0x0dbf07, 0x0dbff7
# AcEditBoxSeProc  (CPU 0x484dbff7)
.incbin_range "baserom/kn7000_program.rom", 0x0dbff7, 0x0dc1a8
# Ac1stEditBoxSeProc  (CPU 0x484dc1a8)
.incbin_range "baserom/kn7000_program.rom", 0x0dc1a8, 0x0dc35d
# Ac2ndEditBoxSeProc  (CPU 0x484dc35d)
.incbin_range "baserom/kn7000_program.rom", 0x0dc35d, 0x0dc513
# Ac3rdEditBoxSeProc  (CPU 0x484dc513)
.incbin_range "baserom/kn7000_program.rom", 0x0dc513, 0x0dc6c9
# Ac4thEditBoxSeProc  (CPU 0x484dc6c9)
.incbin_range "baserom/kn7000_program.rom", 0x0dc6c9, 0x0dc87a
# DrumAc1stEditBoxSeProc  (CPU 0x484dc87a)
.incbin_range "baserom/kn7000_program.rom", 0x0dc87a, 0x0dca2f
# DrumAc2ndEditBoxSeProc  (CPU 0x484dca2f)
.incbin_range "baserom/kn7000_program.rom", 0x0dca2f, 0x0dcb91
# DeffTypeSe  (CPU 0x484dcb91)
.incbin_range "baserom/kn7000_program.rom", 0x0dcb91, 0x0dceba
# DeffVal0SwSe  (CPU 0x484dceba)
.incbin_range "baserom/kn7000_program.rom", 0x0dceba, 0x0dd226
# DeffVal1SwSe  (CPU 0x484dd226)
.incbin_range "baserom/kn7000_program.rom", 0x0dd226, 0x0dd6e6
# DeffVal2SwSe  (CPU 0x484dd6e6)
.incbin_range "baserom/kn7000_program.rom", 0x0dd6e6, 0x0dd9fa
# DeffVal3SwSe  (CPU 0x484dd9fa)
.incbin_range "baserom/kn7000_program.rom", 0x0dd9fa, 0x0ddc4b
# DeffVal4SwSe  (CPU 0x484ddc4b)
.incbin_range "baserom/kn7000_program.rom", 0x0ddc4b, 0x0dde53
# DeffVal5SwSe  (CPU 0x484dde53)
.incbin_range "baserom/kn7000_program.rom", 0x0dde53, 0x0de0ac
# DeffVal6SwSe  (CPU 0x484de0ac)
.incbin_range "baserom/kn7000_program.rom", 0x0de0ac, 0x0de22e
# DrumMainGridSe  (CPU 0x484de22e)
.incbin_range "baserom/kn7000_program.rom", 0x0de22e, 0x0de324
# AcChEditBoxSeProc  (CPU 0x484de324)
.incbin_range "baserom/kn7000_program.rom", 0x0de324, 0x0de3b2
# DeffVal0Se  (CPU 0x484de3b2)
.incbin_range "baserom/kn7000_program.rom", 0x0de3b2, 0x0de49a
# DeffVal1Se  (CPU 0x484de49a)
.incbin_range "baserom/kn7000_program.rom", 0x0de49a, 0x0de582
# DeffVal2Se  (CPU 0x484de582)
.incbin_range "baserom/kn7000_program.rom", 0x0de582, 0x0de66a
# DeffVal3Se  (CPU 0x484de66a)
.incbin_range "baserom/kn7000_program.rom", 0x0de66a, 0x0de752
# DeffVal4Se  (CPU 0x484de752)
.incbin_range "baserom/kn7000_program.rom", 0x0de752, 0x0de7de
# DeffVal5Se  (CPU 0x484de7de)
.incbin_range "baserom/kn7000_program.rom", 0x0de7de, 0x0de86a
# DeffVal6Se  (CPU 0x484de86a)
.incbin_range "baserom/kn7000_program.rom", 0x0de86a, 0x0de8f6
# DeffVal7Se  (CPU 0x484de8f6)
.incbin_range "baserom/kn7000_program.rom", 0x0de8f6, 0x0de955
# DrumGraphEqSe  (CPU 0x484de955)
.incbin_range "baserom/kn7000_program.rom", 0x0de955, 0x0de9dc
# EnvKfGraphTitleSe  (CPU 0x484de9dc)
.incbin_range "baserom/kn7000_program.rom", 0x0de9dc, 0x0deaf5
# FltGraphTitleSe  (CPU 0x484deaf5)
.incbin_range "baserom/kn7000_program.rom", 0x0deaf5, 0x0deb59
# EqGraphTitleSe  (CPU 0x484deb59)
.incbin_range "baserom/kn7000_program.rom", 0x0deb59, 0x0debbd
# EqGraphXSe  (CPU 0x484debbd)
.incbin_range "baserom/kn7000_program.rom", 0x0debbd, 0x0decd6
# DrumFltGraphTitleSe  (CPU 0x484decd6)
.incbin_range "baserom/kn7000_program.rom", 0x0decd6, 0x0ded3a
# DrumEqGraphTitleSe  (CPU 0x484ded3a)
.incbin_range "baserom/kn7000_program.rom", 0x0ded3a, 0x0ded9e
# DrumKeyOffSe  (CPU 0x484ded9e)
.incbin_range "baserom/kn7000_program.rom", 0x0ded9e, 0x0dee0f
# AcTitleMenuView4SeProc  (CPU 0x484dee0f)
.incbin_range "baserom/kn7000_program.rom", 0x0dee0f, 0x0deed5
# MemoryBankSe  (CPU 0x484deed5)
.incbin_range "baserom/kn7000_program.rom", 0x0deed5, 0x0def54
# MemoryWriteSe  (CPU 0x484def54)
.incbin_range "baserom/kn7000_program.rom", 0x0def54, 0x0defde
# CopyOptSe  (CPU 0x484defde)
.incbin_range "baserom/kn7000_program.rom", 0x0defde, 0x0df02c
# LeftSplitSe  (CPU 0x484df02c)
.incbin_range "baserom/kn7000_program.rom", 0x0df02c, 0x0df090
# NamingSe  (CPU 0x484df090)
.incbin_range "baserom/kn7000_program.rom", 0x0df090, 0x0df0ef
# NamingFixSe  (CPU 0x484df0ef)
.incbin_range "baserom/kn7000_program.rom", 0x0df0ef, 0x0df167
# DrumNamingSe  (CPU 0x484df167)
.incbin_range "baserom/kn7000_program.rom", 0x0df167, 0x0df1db
# AcCompareToggleSeProc  (CPU 0x484df1db)
.incbin_range "baserom/kn7000_program.rom", 0x0df1db, 0x0df735
# EzDeffSe  (CPU 0x484df735)
.incbin_range "baserom/kn7000_program.rom", 0x0df735, 0x0e02ff
# ToneSelGridSe  (CPU 0x484e02ff)
.incbin_range "baserom/kn7000_program.rom", 0x0e02ff, 0x0e0882
# PortamentTimeSe  (CPU 0x484e0882)
.incbin_range "baserom/kn7000_program.rom", 0x0e0882, 0x0e0e50
# LayerGridSe1  (CPU 0x484e0e50)
.incbin_range "baserom/kn7000_program.rom", 0x0e0e50, 0x0e140a
# GraphVelLay4Se  (CPU 0x484e140a)
.incbin_range "baserom/kn7000_program.rom", 0x0e140a, 0x0e171b
# PitchGridSe  (CPU 0x484e171b)
.incbin_range "baserom/kn7000_program.rom", 0x0e171b, 0x0e1def
# PitchGridSe2  (CPU 0x484e1def)
.incbin_range "baserom/kn7000_program.rom", 0x0e1def, 0x0e22f6
# PitchGridSe3  (CPU 0x484e22f6)
.incbin_range "baserom/kn7000_program.rom", 0x0e22f6, 0x0e294d
# AmpGridSe1  (CPU 0x484e294d)
.incbin_range "baserom/kn7000_program.rom", 0x0e294d, 0x0e2f16
# AmpGridSe2  (CPU 0x484e2f16)
.incbin_range "baserom/kn7000_program.rom", 0x0e2f16, 0x0e354a
# AmpGridSe3  (CPU 0x484e354a)
.incbin_range "baserom/kn7000_program.rom", 0x0e354a, 0x0e4037
# FilterGridSe1  (CPU 0x484e4037)
.incbin_range "baserom/kn7000_program.rom", 0x0e4037, 0x0e45e9
# FilterGridSe2  (CPU 0x484e45e9)
.incbin_range "baserom/kn7000_program.rom", 0x0e45e9, 0x0e4cbd
# FilterGridSe3  (CPU 0x484e4cbd)
.incbin_range "baserom/kn7000_program.rom", 0x0e4cbd, 0x0e51c4
# FilterGridSe4  (CPU 0x484e51c4)
.incbin_range "baserom/kn7000_program.rom", 0x0e51c4, 0x0e5caf
# LfoGridSe1  (CPU 0x484e5caf)
.incbin_range "baserom/kn7000_program.rom", 0x0e5caf, 0x0e67a6
# LfoGridSe2  (CPU 0x484e67a6)
.incbin_range "baserom/kn7000_program.rom", 0x0e67a6, 0x0e729d
# LfoGridSe3  (CPU 0x484e729d)
.incbin_range "baserom/kn7000_program.rom", 0x0e729d, 0x0e7d94
# AcGridBoxSeProc  (CPU 0x484e7d94)
.incbin_range "baserom/kn7000_program.rom", 0x0e7d94, 0x0e8141
# ToneGridSe1  (CPU 0x484e8141)
.incbin_range "baserom/kn7000_program.rom", 0x0e8141, 0x0e89fc
# AcGridBoxScrlSeProc  (CPU 0x484e89fc)
.incbin_range "baserom/kn7000_program.rom", 0x0e89fc, 0x0e8e83
# RevAdjSe  (CPU 0x484e8e83)
.incbin_range "baserom/kn7000_program.rom", 0x0e8e83, 0x0ea377
# AcCtrlGridBoxSeProc  (CPU 0x484ea377)
.incbin_range "baserom/kn7000_program.rom", 0x0ea377, 0x0ea6f0
# CtrlGridSe1  (CPU 0x484ea6f0)
.incbin_range "baserom/kn7000_program.rom", 0x0ea6f0, 0x0eac80
# DrumAcCtrlGridBoxSeProc  (CPU 0x484eac80)
.incbin_range "baserom/kn7000_program.rom", 0x0eac80, 0x0eb01d
# ToneGridSe2  (CPU 0x484eb01d)
.incbin_range "baserom/kn7000_program.rom", 0x0eb01d, 0x0ebc65
# TsetGridSe  (CPU 0x484ebc65)
.incbin_range "baserom/kn7000_program.rom", 0x0ebc65, 0x0ec94f
# AcGridBoxSe2Proc  (CPU 0x484ec94f)
.incbin_range "baserom/kn7000_program.rom", 0x0ec94f, 0x0ecd6b
# CopyExeSe  (CPU 0x484ecd6b)
.incbin_range "baserom/kn7000_program.rom", 0x0ecd6b, 0x0edbdd
# GraphLayerSeProc  (CPU 0x484edbdd)
.incbin_range "baserom/kn7000_program.rom", 0x0edbdd, 0x0edc46
# BitmapKenbanSe  (CPU 0x484edc46)
.incbin_range "baserom/kn7000_program.rom", 0x0edc46, 0x0ee24e
# GraphLvlKfSe  (CPU 0x484ee24e)
.incbin_range "baserom/kn7000_program.rom", 0x0ee24e, 0x0ee8a7
# GraphLenvKfSe  (CPU 0x484ee8a7)
.incbin_range "baserom/kn7000_program.rom", 0x0ee8a7, 0x0eeeaf
# GraphFltKfSe  (CPU 0x484eeeaf)
.incbin_range "baserom/kn7000_program.rom", 0x0eeeaf, 0x0ef4bf
# GraphPenvKfSe  (CPU 0x484ef4bf)
.incbin_range "baserom/kn7000_program.rom", 0x0ef4bf, 0x0efacf
# GraphFenvKfSe  (CPU 0x484efacf)
.incbin_range "baserom/kn7000_program.rom", 0x0efacf, 0x0efeed
# GraphAmpEnvSe  (CPU 0x484efeed)
.incbin_range "baserom/kn7000_program.rom", 0x0efeed, 0x0f0532
# DrumGraphAmpEnvSe  (CPU 0x484f0532)
.incbin_range "baserom/kn7000_program.rom", 0x0f0532, 0x0f0c60
# GraphPitEnvSe  (CPU 0x484f0c60)
.incbin_range "baserom/kn7000_program.rom", 0x0f0c60, 0x0f14ef
# GraphFltEnvSe  (CPU 0x484f14ef)
.incbin_range "baserom/kn7000_program.rom", 0x0f14ef, 0x0f1b9b
# GraphFltSe  (CPU 0x484f1b9b)
.incbin_range "baserom/kn7000_program.rom", 0x0f1b9b, 0x0f1e3e
# GraphEqSe  (CPU 0x484f1e3e)
.incbin_range "baserom/kn7000_program.rom", 0x0f1e3e, 0x0f2553
# DrumGraphFltSe  (CPU 0x484f2553)
.incbin_range "baserom/kn7000_program.rom", 0x0f2553, 0x0f2828
# VwMnameSeProc  (CPU 0x484f2828)
.incbin_range "baserom/kn7000_program.rom", 0x0f2828, 0x0f287f
# LayerGridSe2  (CPU 0x484f287f)
.incbin_range "baserom/kn7000_program.rom", 0x0f287f, 0x0f2c01
# GraphKeyLay1Se  (CPU 0x484f2c01)
.incbin_range "baserom/kn7000_program.rom", 0x0f2c01, 0x0f2f87
# GraphKeyLay2Se  (CPU 0x484f2f87)
.incbin_range "baserom/kn7000_program.rom", 0x0f2f87, 0x0f330d
# GraphKeyLay3Se  (CPU 0x484f330d)
.incbin_range "baserom/kn7000_program.rom", 0x0f330d, 0x0f3693
# GraphKeyLay4Se  (CPU 0x484f3693)
.incbin_range "baserom/kn7000_program.rom", 0x0f3693, 0x0f3999
# GraphVelLay1Se  (CPU 0x484f3999)
.incbin_range "baserom/kn7000_program.rom", 0x0f3999, 0x0f3ca3
# GraphVelLay2Se  (CPU 0x484f3ca3)
.incbin_range "baserom/kn7000_program.rom", 0x0f3ca3, 0x0f3fad
# GraphVelLay3Se  (CPU 0x484f3fad)
.incbin_range "baserom/kn7000_program.rom", 0x0f3fad, 0x0f42b7
# AcTsetGridBoxSeProc  (CPU 0x484f42b7)
.incbin_range "baserom/kn7000_program.rom", 0x0f42b7, 0x0f46d2
# DrumEqGraphXSe  (CPU 0x484f46d2)
.incbin_range "baserom/kn7000_program.rom", 0x0f46d2, 0x0f5509
# DrumLfoGridSe  (CPU 0x484f5509)
.incbin_range "baserom/kn7000_program.rom", 0x0f5509, 0x0f6478
# AcDrumGridBoxSeProc  (CPU 0x484f6478)
.incbin_range "baserom/kn7000_program.rom", 0x0f6478, 0x0f6893
# DrumGDumpGroupSe  (CPU 0x484f6893)
.incbin_range "baserom/kn7000_program.rom", 0x0f6893, 0x0f7070
# DrumAmpGridSe  (CPU 0x484f7070)
.incbin_range "baserom/kn7000_program.rom", 0x0f7070, 0x0f971b
# GraphBoxSeProc  (CPU 0x484f971b)
.incbin_range "baserom/kn7000_program.rom", 0x0f971b, 0x0f9793
# DrawArrowProc  (CPU 0x484f9793)
.incbin_range "baserom/kn7000_program.rom", 0x0f9793, 0x0f984c
# DrumMemoryWriteSe  (CPU 0x484f984c)
.incbin_range "baserom/kn7000_program.rom", 0x0f984c, 0x0f9897
# InitializeBlock18  (CPU 0x484f9897)
.incbin_range "baserom/kn7000_program.rom", 0x0f9897, 0x0f9cea
# AcPDFileNoBoxProc  (CPU 0x484f9cea)
.incbin_range "baserom/kn7000_program.rom", 0x0f9cea, 0x0f9ddc
# DPPauseDspCheck  (CPU 0x484f9ddc)
.incbin_range "baserom/kn7000_program.rom", 0x0f9ddc, 0x0f9ee3
# NameGetFuncCall  (CPU 0x484f9ee3)
.incbin_range "baserom/kn7000_program.rom", 0x0f9ee3, 0x0f9eef
# MainDP_CallMuteOp  (CPU 0x484f9eef)
.incbin_range "baserom/kn7000_program.rom", 0x0f9eef, 0x0f9f4b
# AcCurSongNameBoxProc  (CPU 0x484f9f4b)
.incbin_range "baserom/kn7000_program.rom", 0x0f9f4b, 0x0fa9ab
# LyricsLyricsBoxProc  (CPU 0x484fa9ab)
.incbin_range "baserom/kn7000_program.rom", 0x0fa9ab, 0x0fac6c
# LyricsBoxProc  (CPU 0x484fac6c)
.incbin_range "baserom/kn7000_program.rom", 0x0fac6c, 0x0fad63
# SongNameBoxProc  (CPU 0x484fad63)
.incbin_range "baserom/kn7000_program.rom", 0x0fad63, 0x0fae5a
# ComporserNameBoxProc  (CPU 0x484fae5a)
.incbin_range "baserom/kn7000_program.rom", 0x0fae5a, 0x0faf23
# LyricsMusicBoxProc  (CPU 0x484faf23)
.incbin_range "baserom/kn7000_program.rom", 0x0faf23, 0x0fafec
# AcIntTitleMenuDPProc  (CPU 0x484fafec)
.incbin_range "baserom/kn7000_program.rom", 0x0fafec, 0x0fb0c1
# AcMuteToggleBoxProc  (CPU 0x484fb0c1)
.incbin_range "baserom/kn7000_program.rom", 0x0fb0c1, 0x0fb196
# AcDiskFileNameBoxProc  (CPU 0x484fb196)
.incbin_range "baserom/kn7000_program.rom", 0x0fb196, 0x0fb26b
# AcSmfFileNameBoxProc  (CPU 0x484fb26b)
.incbin_range "baserom/kn7000_program.rom", 0x0fb26b, 0x0fb340
# AppSEQ_InitSmfLyricsFunc  (CPU 0x484fb340)
.incbin_range "baserom/kn7000_program.rom", 0x0fb340, 0x0fb415
# DPPlayDspCheck  (CPU 0x484fb415)
.incbin_range "baserom/kn7000_program.rom", 0x0fb415, 0x0fb4b6
# AcSmfSongNameBoxProc  (CPU 0x484fb4b6)
.incbin_range "baserom/kn7000_program.rom", 0x0fb4b6, 0x0fb58b
# AcDocSongNameBoxProc  (CPU 0x484fb58b)
.incbin_range "baserom/kn7000_program.rom", 0x0fb58b, 0x0fb660
# AcDocFileNoBoxProc  (CPU 0x484fb660)
.incbin_range "baserom/kn7000_program.rom", 0x0fb660, 0x0fb735
# AcPDSongNameBoxProc  (CPU 0x484fb735)
.incbin_range "baserom/kn7000_program.rom", 0x0fb735, 0x0fbe8b
# DpMdlyPdTtlFunc  (CPU 0x484fbe8b)
.incbin_range "baserom/kn7000_program.rom", 0x0fbe8b, 0x0fc7d4
# MainDP_LyricsCharaReq  (CPU 0x484fc7d4)
.incbin_range "baserom/kn7000_program.rom", 0x0fc7d4, 0x0fcb7c
# DpSmfTtlFunc  (CPU 0x484fcb7c)
.incbin_range "baserom/kn7000_program.rom", 0x0fcb7c, 0x0fcef9
# DpDocTtlFunc  (CPU 0x484fcef9)
.incbin_range "baserom/kn7000_program.rom", 0x0fcef9, 0x0fd062
# DpPdTtlFunc  (CPU 0x484fd062)
.incbin_range "baserom/kn7000_program.rom", 0x0fd062, 0x0fd0f8
# DpSmfLyrTtlFunc  (CPU 0x484fd0f8)
.incbin_range "baserom/kn7000_program.rom", 0x0fd0f8, 0x0fd1ed
# DpMdlySmfTtlFunc  (CPU 0x484fd1ed)
.incbin_range "baserom/kn7000_program.rom", 0x0fd1ed, 0x0fd256
# DpMdlyDocTtlFunc  (CPU 0x484fd256)
.incbin_range "baserom/kn7000_program.rom", 0x0fd256, 0x0fdadf
# DpMdlySmfLyrTtlFunc  (CPU 0x484fdadf)
.incbin_range "baserom/kn7000_program.rom", 0x0fdadf, 0x0fdc08
# SeqLyricsShowHide  (CPU 0x484fdc08)
.incbin_range "baserom/kn7000_program.rom", 0x0fdc08, 0x0fdc4d
# AppSEQ_InitSmfLyrics  (CPU 0x484fdc4d)
.incbin_range "baserom/kn7000_program.rom", 0x0fdc4d, 0x0fdc59
# InitializeBlock22  (CPU 0x484fdc59)
.incbin_range "baserom/kn7000_program.rom", 0x0fdc59, 0x0fde2c
# AcSeqInfo7_SRProc  (CPU 0x484fde2c)
.incbin_range "baserom/kn7000_program.rom", 0x0fde2c, 0x0fde35
# GetCmpMspStepScreenID  (CPU 0x484fde35)
.incbin_range "baserom/kn7000_program.rom", 0x0fde35, 0x0fde3e
# GetMspChdStepScreenID  (CPU 0x484fde3e)
.incbin_range "baserom/kn7000_program.rom", 0x0fde3e, 0x0fdf18
# AcFuncMenuProc  (CPU 0x484fdf18)
.incbin_range "baserom/kn7000_program.rom", 0x0fdf18, 0x0fe14d
# AcFuncEditBoxProc  (CPU 0x484fe14d)
.incbin_range "baserom/kn7000_program.rom", 0x0fe14d, 0x0fe2ab
# AcCmpPatternBoxProc  (CPU 0x484fe2ab)
.incbin_range "baserom/kn7000_program.rom", 0x0fe2ab, 0x0fe318
# AcFuncESOnOffProc  (CPU 0x484fe318)
.incbin_range "baserom/kn7000_program.rom", 0x0fe318, 0x0fe469
# AcCmpRecMuteBoxProc  (CPU 0x484fe469)
.incbin_range "baserom/kn7000_program.rom", 0x0fe469, 0x0feaef
# PaintArrowProc  (CPU 0x484feaef)
.incbin_range "baserom/kn7000_program.rom", 0x0feaef, 0x0feb46
# AcSeqSongNameBoxProc  (CPU 0x484feb46)
.incbin_range "baserom/kn7000_program.rom", 0x0feb46, 0x0fedd4
# AcGridBoxDeluxProc  (CPU 0x484fedd4)
.incbin_range "baserom/kn7000_program.rom", 0x0fedd4, 0x0feecc
# AcSureWindowMenuProc  (CPU 0x484feecc)
.incbin_range "baserom/kn7000_program.rom", 0x0feecc, 0x0ff084
# AcCmpMemNameBoxProc  (CPU 0x484ff084)
.incbin_range "baserom/kn7000_program.rom", 0x0ff084, 0x0ff0da
# PsParaDrawBoxProc  (CPU 0x484ff0da)
.incbin_range "baserom/kn7000_program.rom", 0x0ff0da, 0x0ff13a
# IvSetDialFocusProc  (CPU 0x484ff13a)
.incbin_range "baserom/kn7000_program.rom", 0x0ff13a, 0x0ff311
# AcCmpStepIndexEditSwProc  (CPU 0x484ff311)
.incbin_range "baserom/kn7000_program.rom", 0x0ff311, 0x0ff427
# AcParaDrawBoxProc  (CPU 0x484ff427)
.incbin_range "baserom/kn7000_program.rom", 0x0ff427, 0x0ff494
# AcNoteDrawBoxProc  (CPU 0x484ff494)
.incbin_range "baserom/kn7000_program.rom", 0x0ff494, 0x0ff5ae
# AcChdModGrpDrawBoxProc  (CPU 0x484ff5ae)
.incbin_range "baserom/kn7000_program.rom", 0x0ff5ae, 0x0ff6ec
# AcChdModTypDrawBoxProc  (CPU 0x484ff6ec)
.incbin_range "baserom/kn7000_program.rom", 0x0ff6ec, 0x0ff7ef
# AcStepPhraseBoxProc  (CPU 0x484ff7ef)
.incbin_range "baserom/kn7000_program.rom", 0x0ff7ef, 0x100027
# AcStepBoxProc  (CPU 0x48500027)
.incbin_range "baserom/kn7000_program.rom", 0x100027, 0x100215
# AcCmpBarBoxProc  (CPU 0x48500215)
.incbin_range "baserom/kn7000_program.rom", 0x100215, 0x1002f0
# IvMultiExitProc  (CPU 0x485002f0)
.incbin_range "baserom/kn7000_program.rom", 0x1002f0, 0x10039e
# AcCmpPartBoxProc  (CPU 0x4850039e)
.incbin_range "baserom/kn7000_program.rom", 0x10039e, 0x10045d
# IvMainCallFromAppProc  (CPU 0x4850045d)
.incbin_range "baserom/kn7000_program.rom", 0x10045d, 0x1004b8
# AcIntTitleMenuProc  (CPU 0x485004b8)
.incbin_range "baserom/kn7000_program.rom", 0x1004b8, 0x100779
# AcTimeSigBoxProc  (CPU 0x48500779)
.incbin_range "baserom/kn7000_program.rom", 0x100779, 0x100953
# AcSeqInfo_NEProc  (CPU 0x48500953)
.incbin_range "baserom/kn7000_program.rom", 0x100953, 0x100a0e
# AcSeqInfo_DEProc  (CPU 0x48500a0e)
.incbin_range "baserom/kn7000_program.rom", 0x100a0e, 0x100aad
# AcSeqInfo1_SRProc  (CPU 0x48500aad)
.incbin_range "baserom/kn7000_program.rom", 0x100aad, 0x100b48
# AcSeqInfo4_SRProc  (CPU 0x48500b48)
.incbin_range "baserom/kn7000_program.rom", 0x100b48, 0x102862
# AcSeqInfo5_SRProc  (CPU 0x48502862)
.incbin_range "baserom/kn7000_program.rom", 0x102862, 0x102b78
# AcSeqInfo2_SRProc  (CPU 0x48502b78)
.incbin_range "baserom/kn7000_program.rom", 0x102b78, 0x102c72
# AcSeqInfo3_SRProc  (CPU 0x48502c72)
.incbin_range "baserom/kn7000_program.rom", 0x102c72, 0x102d33
# AcSeqInfo6_SRProc  (CPU 0x48502d33)
.incbin_range "baserom/kn7000_program.rom", 0x102d33, 0x102e12
# TtMspPartSet  (CPU 0x48502e12)
.incbin_range "baserom/kn7000_program.rom", 0x102e12, 0x102eba
# MainSEQ_SongNameParaDraw  (CPU 0x48502eba)
.incbin_range "baserom/kn7000_program.rom", 0x102eba, 0x102ed0
# MainSNDARG_SwFlagCheck  (CPU 0x48502ed0)
.incbin_range "baserom/kn7000_program.rom", 0x102ed0, 0x102eec
# MainCOMP_SetMidimFilter  (CPU 0x48502eec)
.incbin_range "baserom/kn7000_program.rom", 0x102eec, 0x103047
# MainCOMP_RtcControl  (CPU 0x48503047)
.incbin_range "baserom/kn7000_program.rom", 0x103047, 0x10305b
# MdMsp  (CPU 0x4850305b)
.incbin_range "baserom/kn7000_program.rom", 0x10305b, 0x103240
# TtMspMenu  (CPU 0x48503240)
.incbin_range "baserom/kn7000_program.rom", 0x103240, 0x103578
# MainCMP_InterruptTitle  (CPU 0x48503578)
.incbin_range "baserom/kn7000_program.rom", 0x103578, 0x10358d
# MainCMP_StepDialogCommand  (CPU 0x4850358d)
.incbin_range "baserom/kn7000_program.rom", 0x10358d, 0x10362b
# MainCMP_SetCmpRecPart  (CPU 0x4850362b)
.incbin_range "baserom/kn7000_program.rom", 0x10362b, 0x103ccc
# MainPAD_SetUserPadRecPart  (CPU 0x48503ccc)
.incbin_range "baserom/kn7000_program.rom", 0x103ccc, 0x103ea8
# TtCmStep  (CPU 0x48503ea8)
.incbin_range "baserom/kn7000_program.rom", 0x103ea8, 0x103f1b
# TtMspStep  (CPU 0x48503f1b)
.incbin_range "baserom/kn7000_program.rom", 0x103f1b, 0x10419b
# MainCOMP_StepUpdate  (CPU 0x4850419b)
.incbin_range "baserom/kn7000_program.rom", 0x10419b, 0x106b62
# InitializeBlock10  (CPU 0x48506b62)
.incbin_range "baserom/kn7000_program.rom", 0x106b62, 0x107177
# MainSNDARG_PtselPut  (CPU 0x48507177)
.incbin_range "baserom/kn7000_program.rom", 0x107177, 0x1071a2
# MainSNDARG_SetSndaParaCur  (CPU 0x485071a2)
.incbin_range "baserom/kn7000_program.rom", 0x1071a2, 0x1071e9
# MdSndArg  (CPU 0x485071e9)
.incbin_range "baserom/kn7000_program.rom", 0x1071e9, 0x10747d
# InitializeBlock08  (CPU 0x4850747d)
.incbin_range "baserom/kn7000_program.rom", 0x10747d, 0x107c52
# CmpRecMemSelFunc  (CPU 0x48507c52)
.incbin_range "baserom/kn7000_program.rom", 0x107c52, 0x107c86
# CmpMemClrYes  (CPU 0x48507c86)
.incbin_range "baserom/kn7000_program.rom", 0x107c86, 0x107e09
# CmBkslShowHideFunc  (CPU 0x48507e09)
.incbin_range "baserom/kn7000_program.rom", 0x107e09, 0x107f96
# CmpPatSelOK  (CPU 0x48507f96)
.incbin_range "baserom/kn7000_program.rom", 0x107f96, 0x10807b
# FE_CmpRecMeas  (CPU 0x4850807b)
.incbin_range "baserom/kn7000_program.rom", 0x10807b, 0x108229
# FE_CmpRecTS  (CPU 0x48508229)
.incbin_range "baserom/kn7000_program.rom", 0x108229, 0x10839c
# CmpMeasTSOK  (CPU 0x4850839c)
.incbin_range "baserom/kn7000_program.rom", 0x10839c, 0x108415
# CmpMeasTSYes  (CPU 0x48508415)
.incbin_range "baserom/kn7000_program.rom", 0x108415, 0x10853c
# CmpPartSel  (CPU 0x4850853c)
.incbin_range "baserom/kn7000_program.rom", 0x10853c, 0x108570
# CmpPtnClrYes  (CPU 0x48508570)
.incbin_range "baserom/kn7000_program.rom", 0x108570, 0x1085dd
# CmpBkslSShowHideFunc  (CPU 0x485085dd)
.incbin_range "baserom/kn7000_program.rom", 0x1085dd, 0x108614
# CmpMemNmChk  (CPU 0x48508614)
.incbin_range "baserom/kn7000_program.rom", 0x108614, 0x108693
# CmpMemNmOk  (CPU 0x48508693)
.incbin_range "baserom/kn7000_program.rom", 0x108693, 0x108738
# CmpVari1NmOk  (CPU 0x48508738)
.incbin_range "baserom/kn7000_program.rom", 0x108738, 0x108770
# CmpVari1NmChk  (CPU 0x48508770)
.incbin_range "baserom/kn7000_program.rom", 0x108770, 0x1087a9
# CmpVari2NmChk  (CPU 0x485087a9)
.incbin_range "baserom/kn7000_program.rom", 0x1087a9, 0x1087e2
# CmpVari3NmChk  (CPU 0x485087e2)
.incbin_range "baserom/kn7000_program.rom", 0x1087e2, 0x10881b
# CmpVari4NmChk  (CPU 0x4850881b)
.incbin_range "baserom/kn7000_program.rom", 0x10881b, 0x10894d
# FE_CmpRecSetKey  (CPU 0x4850894d)
.incbin_range "baserom/kn7000_program.rom", 0x10894d, 0x108aa1
# FE_CmpRecSetChord  (CPU 0x48508aa1)
.incbin_range "baserom/kn7000_program.rom", 0x108aa1, 0x108af0
# CmpRecSoloFunc  (CPU 0x48508af0)
.incbin_range "baserom/kn7000_program.rom", 0x108af0, 0x108d3e
# FE_CmpRecQtz  (CPU 0x48508d3e)
.incbin_range "baserom/kn7000_program.rom", 0x108d3e, 0x108d72
# CmpPartClrOk  (CPU 0x48508d72)
.incbin_range "baserom/kn7000_program.rom", 0x108d72, 0x108dc5
# CmpInstClrOnOff  (CPU 0x48508dc5)
.incbin_range "baserom/kn7000_program.rom", 0x108dc5, 0x108e18
# CmpAllEraseOnOff  (CPU 0x48508e18)
.incbin_range "baserom/kn7000_program.rom", 0x108e18, 0x10903c
# CmPnCpOK  (CPU 0x4850903c)
.incbin_range "baserom/kn7000_program.rom", 0x10903c, 0x1090a8
# CmpPnCpEditFunc  (CPU 0x485090a8)
.incbin_range "baserom/kn7000_program.rom", 0x1090a8, 0x1091ad
# FuncEdit_rhyDstName  (CPU 0x485091ad)
.incbin_range "baserom/kn7000_program.rom", 0x1091ad, 0x109403
# FuncEdit_rhyDstPattern  (CPU 0x48509403)
.incbin_range "baserom/kn7000_program.rom", 0x109403, 0x109519
# FuncEdit_rhyYN  (CPU 0x48509519)
.incbin_range "baserom/kn7000_program.rom", 0x109519, 0x10972e
# FuncEdit_rhyName  (CPU 0x4850972e)
.incbin_range "baserom/kn7000_program.rom", 0x10972e, 0x1099af
# FuncEdit_rhyPattern  (CPU 0x485099af)
.incbin_range "baserom/kn7000_program.rom", 0x1099af, 0x109d23
# FuncEdit_rhyGroup  (CPU 0x48509d23)
.incbin_range "baserom/kn7000_program.rom", 0x109d23, 0x10a241
# CmpPartCopyGrid  (CPU 0x4850a241)
.incbin_range "baserom/kn7000_program.rom", 0x10a241, 0x10a3c9
# CmpPrtCpyStsGrid  (CPU 0x4850a3c9)
.incbin_range "baserom/kn7000_program.rom", 0x10a3c9, 0x10a437
# CmpPrtCpyEditFunc  (CPU 0x4850a437)
.incbin_range "baserom/kn7000_program.rom", 0x10a437, 0x10a69e
# FE_CompPartCopyMem  (CPU 0x4850a69e)
.incbin_range "baserom/kn7000_program.rom", 0x10a69e, 0x10a742
# CmpPrtCpyPart  (CPU 0x4850a742)
.incbin_range "baserom/kn7000_program.rom", 0x10a742, 0x10a953
# CmpPartCopyOk  (CPU 0x4850a953)
.incbin_range "baserom/kn7000_program.rom", 0x10a953, 0x10a9b2
# CmPnCpYes  (CPU 0x4850a9b2)
.incbin_range "baserom/kn7000_program.rom", 0x10a9b2, 0x10a9d4
# AttCompPtnCpy1  (CPU 0x4850a9d4)
.incbin_range "baserom/kn7000_program.rom", 0x10a9d4, 0x10a9f6
# AttCompPtnCpy2  (CPU 0x4850a9f6)
.incbin_range "baserom/kn7000_program.rom", 0x10a9f6, 0x10aa18
# AttSeqToCompCopy  (CPU 0x4850aa18)
.incbin_range "baserom/kn7000_program.rom", 0x10aa18, 0x10ab8b
# SeqToCmpCopyGrid  (CPU 0x4850ab8b)
.incbin_range "baserom/kn7000_program.rom", 0x10ab8b, 0x10ac5e
# FE_SeqToCmpFstMeas  (CPU 0x4850ac5e)
.incbin_range "baserom/kn7000_program.rom", 0x10ac5e, 0x10b01a
# FE_SeqToCmpLstMeas  (CPU 0x4850b01a)
.incbin_range "baserom/kn7000_program.rom", 0x10b01a, 0x10b10a
# FE_SeqToCmpTrans  (CPU 0x4850b10a)
.incbin_range "baserom/kn7000_program.rom", 0x10b10a, 0x10b208
# FE_SeqToCmpMemory  (CPU 0x4850b208)
.incbin_range "baserom/kn7000_program.rom", 0x10b208, 0x10b317
# FE_SeqToCmpPattern  (CPU 0x4850b317)
.incbin_range "baserom/kn7000_program.rom", 0x10b317, 0x10b342
# SeqToCmpOK  (CPU 0x4850b342)
.incbin_range "baserom/kn7000_program.rom", 0x10b342, 0x10b3cb
# Seq2CmpCpEditFunc  (CPU 0x4850b3cb)
.incbin_range "baserom/kn7000_program.rom", 0x10b3cb, 0x10b407
# SeqToCmpYes  (CPU 0x4850b407)
.incbin_range "baserom/kn7000_program.rom", 0x10b407, 0x10b693
# EasyCompGrid  (CPU 0x4850b693)
.incbin_range "baserom/kn7000_program.rom", 0x10b693, 0x10b7c9
# FE_EasyCompMem  (CPU 0x4850b7c9)
.incbin_range "baserom/kn7000_program.rom", 0x10b7c9, 0x10b829
# CmpEasyCompSet  (CPU 0x4850b829)
.incbin_range "baserom/kn7000_program.rom", 0x10b829, 0x10b897
# CmpEasyCompEditFunc  (CPU 0x4850b897)
.incbin_range "baserom/kn7000_program.rom", 0x10b897, 0x10bcbc
# CmpRecPtChdGrid  (CPU 0x4850bcbc)
.incbin_range "baserom/kn7000_program.rom", 0x10bcbc, 0x10bd46
# CmpPtChdOK  (CPU 0x4850bd46)
.incbin_range "baserom/kn7000_program.rom", 0x10bd46, 0x10c263
# CmpDspSetGrid  (CPU 0x4850c263)
.incbin_range "baserom/kn7000_program.rom", 0x10c263, 0x10c2ae
# CmpDspSetTglFunc  (CPU 0x4850c2ae)
.incbin_range "baserom/kn7000_program.rom", 0x10c2ae, 0x10c329
# AttCompDspSet  (CPU 0x4850c329)
.incbin_range "baserom/kn7000_program.rom", 0x10c329, 0x10c34b
# AttCompPartSet  (CPU 0x4850c34b)
.incbin_range "baserom/kn7000_program.rom", 0x10c34b, 0x10c561
# FE_CmpCstmCpy  (CPU 0x4850c561)
.incbin_range "baserom/kn7000_program.rom", 0x10c561, 0x10c61a
# CmpCstmCpyOK  (CPU 0x4850c61a)
.incbin_range "baserom/kn7000_program.rom", 0x10c61a, 0x10c6e4
# CmpCstmCpyDirec  (CPU 0x4850c6e4)
.incbin_range "baserom/kn7000_program.rom", 0x10c6e4, 0x10c748
# CustomCopySure1  (CPU 0x4850c748)
.incbin_range "baserom/kn7000_program.rom", 0x10c748, 0x10c921
# CustomCopySure2  (CPU 0x4850c921)
.incbin_range "baserom/kn7000_program.rom", 0x10c921, 0x10c943
# CustomCopySure3  (CPU 0x4850c943)
.incbin_range "baserom/kn7000_program.rom", 0x10c943, 0x10c98c
# CmpCstmCpySure  (CPU 0x4850c98c)
.incbin_range "baserom/kn7000_program.rom", 0x10c98c, 0x10ca35
# CmpCstmCpyExe  (CPU 0x4850ca35)
.incbin_range "baserom/kn7000_program.rom", 0x10ca35, 0x10d04a
# CmpPartSetGrid1  (CPU 0x4850d04a)
.incbin_range "baserom/kn7000_program.rom", 0x10d04a, 0x10daa5
# CmpPartSetGrid2  (CPU 0x4850daa5)
.incbin_range "baserom/kn7000_program.rom", 0x10daa5, 0x10db79
# FE_CmpMCopySPart  (CPU 0x4850db79)
.incbin_range "baserom/kn7000_program.rom", 0x10db79, 0x10dc53
# FE_CmpMCopyFstMeas  (CPU 0x4850dc53)
.incbin_range "baserom/kn7000_program.rom", 0x10dc53, 0x10dd26
# FE_CmpMCopyLstMeas  (CPU 0x4850dd26)
.incbin_range "baserom/kn7000_program.rom", 0x10dd26, 0x10ddfa
# FE_CmpMCopyDPart  (CPU 0x4850ddfa)
.incbin_range "baserom/kn7000_program.rom", 0x10ddfa, 0x10decd
# FE_CmpMCopySrtMeas  (CPU 0x4850decd)
.incbin_range "baserom/kn7000_program.rom", 0x10decd, 0x10def8
# CmpMCopyOK  (CPU 0x4850def8)
.incbin_range "baserom/kn7000_program.rom", 0x10def8, 0x10e43f
# CmpMCopyYes  (CPU 0x4850e43f)
.incbin_range "baserom/kn7000_program.rom", 0x10e43f, 0x10e519
# FE_CmpMDelFstMeas  (CPU 0x4850e519)
.incbin_range "baserom/kn7000_program.rom", 0x10e519, 0x10e5ec
# FE_CmpMDelLstMeas  (CPU 0x4850e5ec)
.incbin_range "baserom/kn7000_program.rom", 0x10e5ec, 0x10e976
# CmpMDelOK  (CPU 0x4850e976)
.incbin_range "baserom/kn7000_program.rom", 0x10e976, 0x10e9b2
# CmpMDelYes  (CPU 0x4850e9b2)
.incbin_range "baserom/kn7000_program.rom", 0x10e9b2, 0x10e9d4
# AttCompMeasDel  (CPU 0x4850e9d4)
.incbin_range "baserom/kn7000_program.rom", 0x10e9d4, 0x10eaa8
# FE_CmpMErsSPart  (CPU 0x4850eaa8)
.incbin_range "baserom/kn7000_program.rom", 0x10eaa8, 0x10eb82
# FE_CmpMErsFstMeas  (CPU 0x4850eb82)
.incbin_range "baserom/kn7000_program.rom", 0x10eb82, 0x10ec55
# FE_CmpMErsLstMeas  (CPU 0x4850ec55)
.incbin_range "baserom/kn7000_program.rom", 0x10ec55, 0x10ee91
# CmpMErsYes  (CPU 0x4850ee91)
.incbin_range "baserom/kn7000_program.rom", 0x10ee91, 0x10ef6b
# FE_CmpMInsFstMeas  (CPU 0x4850ef6b)
.incbin_range "baserom/kn7000_program.rom", 0x10ef6b, 0x10f03e
# FE_CmpMInsMeasNum  (CPU 0x4850f03e)
.incbin_range "baserom/kn7000_program.rom", 0x10f03e, 0x10f07a
# CmpMInsYes  (CPU 0x4850f07a)
.incbin_range "baserom/kn7000_program.rom", 0x10f07a, 0x10f2b4
# CmpMInsOK  (CPU 0x4850f2b4)
.incbin_range "baserom/kn7000_program.rom", 0x10f2b4, 0x10f2d6
# AttCompRec1  (CPU 0x4850f2d6)
.incbin_range "baserom/kn7000_program.rom", 0x10f2d6, 0x10f55e
# FE_CmpRecChdModGrp  (CPU 0x4850f55e)
.incbin_range "baserom/kn7000_program.rom", 0x10f55e, 0x10f996
# MdCmp  (CPU 0x4850f996)
.incbin_range "baserom/kn7000_program.rom", 0x10f996, 0x10fa13
# TtCmpDspSet  (CPU 0x4850fa13)
.incbin_range "baserom/kn7000_program.rom", 0x10fa13, 0x10fbb8
# TtCmMenu  (CPU 0x4850fbb8)
.incbin_range "baserom/kn7000_program.rom", 0x10fbb8, 0x10fca7
# TtCmBksl  (CPU 0x4850fca7)
.incbin_range "baserom/kn7000_program.rom", 0x10fca7, 0x10fd55
# TtCmBksl_s  (CPU 0x4850fd55)
.incbin_range "baserom/kn7000_program.rom", 0x10fd55, 0x10fdff
# TtCmReal  (CPU 0x4850fdff)
.incbin_range "baserom/kn7000_program.rom", 0x10fdff, 0x10fe12
# TtCmBal  (CPU 0x4850fe12)
.incbin_range "baserom/kn7000_program.rom", 0x10fe12, 0x110004
# TtCmPnCp  (CPU 0x48510004)
.incbin_range "baserom/kn7000_program.rom", 0x110004, 0x110194
# TtCmEasy  (CPU 0x48510194)
.incbin_range "baserom/kn7000_program.rom", 0x110194, 0x1101eb
# TtCmPtChd  (CPU 0x485101eb)
.incbin_range "baserom/kn7000_program.rom", 0x1101eb, 0x11025e
# TtCmPartSet  (CPU 0x4851025e)
.incbin_range "baserom/kn7000_program.rom", 0x11025e, 0x110360
# MainCMP_CmpPatternClear  (CPU 0x48510360)
.incbin_range "baserom/kn7000_program.rom", 0x110360, 0x1103b8
# MainCMP_SetCmpMsrTmSigAftClr  (CPU 0x485103b8)
.incbin_range "baserom/kn7000_program.rom", 0x1103b8, 0x110412
# MainCMP_SetCmpMeasure  (CPU 0x48510412)
.incbin_range "baserom/kn7000_program.rom", 0x110412, 0x110462
# MainCMP_CmpSectionClear  (CPU 0x48510462)
.incbin_range "baserom/kn7000_program.rom", 0x110462, 0x110477
# MainCMP_SetCmpPtnName  (CPU 0x48510477)
.incbin_range "baserom/kn7000_program.rom", 0x110477, 0x11048e
# MainCMP_SetCmpVariName  (CPU 0x4851048e)
.incbin_range "baserom/kn7000_program.rom", 0x11048e, 0x1104ac
# MainCMP_SetCmpRecordChord  (CPU 0x485104ac)
.incbin_range "baserom/kn7000_program.rom", 0x1104ac, 0x1104eb
# MainCMP_SetCmpRecSolo  (CPU 0x485104eb)
.incbin_range "baserom/kn7000_program.rom", 0x1104eb, 0x110501
# MainCMP_SetCmpRecordArrange  (CPU 0x48510501)
.incbin_range "baserom/kn7000_program.rom", 0x110501, 0x110517
# MainCMP_SetCmpRecQt  (CPU 0x48510517)
.incbin_range "baserom/kn7000_program.rom", 0x110517, 0x11053e
# MainCMP_CmpPartClear  (CPU 0x4851053e)
.incbin_range "baserom/kn7000_program.rom", 0x11053e, 0x110566
# MainCMP_SetCmpNoteClear  (CPU 0x48510566)
.incbin_range "baserom/kn7000_program.rom", 0x110566, 0x1106e3
# MainCMP_SetCmpAllErase  (CPU 0x485106e3)
.incbin_range "baserom/kn7000_program.rom", 0x1106e3, 0x110757
# MainCOMP_CmpPatternCopy  (CPU 0x48510757)
.incbin_range "baserom/kn7000_program.rom", 0x110757, 0x110774
# MainCOMP_PutM3Em  (CPU 0x48510774)
.incbin_range "baserom/kn7000_program.rom", 0x110774, 0x11085d
# MainCMP_CmpCompileCopy  (CPU 0x4851085d)
.incbin_range "baserom/kn7000_program.rom", 0x11085d, 0x1108b2
# MainCOMP_CmpCopyFromSeq  (CPU 0x485108b2)
.incbin_range "baserom/kn7000_program.rom", 0x1108b2, 0x110930
# MainCMP_CmpEasyCopy  (CPU 0x48510930)
.incbin_range "baserom/kn7000_program.rom", 0x110930, 0x11094e
# MainCMP_SetCmpRecArrAll  (CPU 0x4851094e)
.incbin_range "baserom/kn7000_program.rom", 0x11094e, 0x11096c
# MainCMP_SetCmpEffectType  (CPU 0x4851096c)
.incbin_range "baserom/kn7000_program.rom", 0x11096c, 0x1109bf
# MainCMP_SetCmpEffect1Total  (CPU 0x485109bf)
.incbin_range "baserom/kn7000_program.rom", 0x1109bf, 0x110a15
# MainCMP_CstmCpyNameDraw  (CPU 0x48510a15)
.incbin_range "baserom/kn7000_program.rom", 0x110a15, 0x110a89
# MainCMP_CstmCpyRhyNameDraw  (CPU 0x48510a89)
.incbin_range "baserom/kn7000_program.rom", 0x110a89, 0x110b71
# MainCMP_CustomCopy  (CPU 0x48510b71)
.incbin_range "baserom/kn7000_program.rom", 0x110b71, 0x110be0
# MainCMP_CustomToPerformance  (CPU 0x48510be0)
.incbin_range "baserom/kn7000_program.rom", 0x110be0, 0x110c05
# MainCMP_SetCmpPartSetting  (CPU 0x48510c05)
.incbin_range "baserom/kn7000_program.rom", 0x110c05, 0x110c1b
# MainCMP_SetCmpEffectPart  (CPU 0x48510c1b)
.incbin_range "baserom/kn7000_program.rom", 0x110c1b, 0x110c85
# MainCMP_CmpMeasureCopy  (CPU 0x48510c85)
.incbin_range "baserom/kn7000_program.rom", 0x110c85, 0x110cdf
# MainCMP_CmpMeasureDelete  (CPU 0x48510cdf)
.incbin_range "baserom/kn7000_program.rom", 0x110cdf, 0x110d3f
# MainCMP_CmpMeasureErase  (CPU 0x48510d3f)
.incbin_range "baserom/kn7000_program.rom", 0x110d3f, 0x110daa
# InitializeBlock09  (CPU 0x48510daa)
.incbin_range "baserom/kn7000_program.rom", 0x110daa, 0x111463
# AcPadBankSelProc  (CPU 0x48511463)
.incbin_range "baserom/kn7000_program.rom", 0x111463, 0x1114fc
# AcPadNameBoxProc  (CPU 0x485114fc)
.incbin_range "baserom/kn7000_program.rom", 0x1114fc, 0x1115fc
# AcPadBarBoxProc  (CPU 0x485115fc)
.incbin_range "baserom/kn7000_program.rom", 0x1115fc, 0x11169f
# AcPadCapaBoxProc  (CPU 0x4851169f)
.incbin_range "baserom/kn7000_program.rom", 0x11169f, 0x1118bb
# AcMspCompileGridBoxProc  (CPU 0x485118bb)
.incbin_range "baserom/kn7000_program.rom", 0x1118bb, 0x111a59
# PadRecBankSelFunc  (CPU 0x48511a59)
.incbin_range "baserom/kn7000_program.rom", 0x111a59, 0x111c39
# MspBnkShow  (CPU 0x48511c39)
.incbin_range "baserom/kn7000_program.rom", 0x111c39, 0x111cf4
# PadPartSel  (CPU 0x48511cf4)
.incbin_range "baserom/kn7000_program.rom", 0x111cf4, 0x111d43
# PadRecSoloFunc  (CPU 0x48511d43)
.incbin_range "baserom/kn7000_program.rom", 0x111d43, 0x111ea8
# FE_PadRecQtz  (CPU 0x48511ea8)
.incbin_range "baserom/kn7000_program.rom", 0x111ea8, 0x1120c6
# FE_PadRecChdModGrp  (CPU 0x485120c6)
.incbin_range "baserom/kn7000_program.rom", 0x1120c6, 0x1123e9
# FE_PadRecChdModTyp  (CPU 0x485123e9)
.incbin_range "baserom/kn7000_program.rom", 0x1123e9, 0x11243c
# PadInstClrOnOff  (CPU 0x4851243c)
.incbin_range "baserom/kn7000_program.rom", 0x11243c, 0x11248f
# PadAllEraseOnOff  (CPU 0x4851248f)
.incbin_range "baserom/kn7000_program.rom", 0x11248f, 0x1124c3
# PadPartClrOk  (CPU 0x485124c3)
.incbin_range "baserom/kn7000_program.rom", 0x1124c3, 0x11253c
# MspPadRecShowHideFunc  (CPU 0x4851253c)
.incbin_range "baserom/kn7000_program.rom", 0x11253c, 0x11257a
# MspMemNmChk  (CPU 0x4851257a)
.incbin_range "baserom/kn7000_program.rom", 0x11257a, 0x112600
# MspMemNmOk  (CPU 0x48512600)
.incbin_range "baserom/kn7000_program.rom", 0x112600, 0x1129ba
# MspCompileSetGridCheck  (CPU 0x485129ba)
.incbin_range "baserom/kn7000_program.rom", 0x1129ba, 0x112a3f
# MspRGrpSetBnkFunc  (CPU 0x48512a3f)
.incbin_range "baserom/kn7000_program.rom", 0x112a3f, 0x112a6f
# MspRgpShowHideFunc  (CPU 0x48512a6f)
.incbin_range "baserom/kn7000_program.rom", 0x112a6f, 0x112ba1
# FE_PadRecSetKey  (CPU 0x48512ba1)
.incbin_range "baserom/kn7000_program.rom", 0x112ba1, 0x112cc3
# FE_PadRecSetChord  (CPU 0x48512cc3)
.incbin_range "baserom/kn7000_program.rom", 0x112cc3, 0x112d5c
# MspPadNmOk  (CPU 0x48512d5c)
.incbin_range "baserom/kn7000_program.rom", 0x112d5c, 0x112da7
# MspPadNmChk  (CPU 0x48512da7)
.incbin_range "baserom/kn7000_program.rom", 0x112da7, 0x112ddb
# AcMspCompileBnkNmBoxProc  (CPU 0x48512ddb)
.incbin_range "baserom/kn7000_program.rom", 0x112ddb, 0x112e45
# PadMemClrYes  (CPU 0x48512e45)
.incbin_range "baserom/kn7000_program.rom", 0x112e45, 0x112e9d
# PadPatSelOK  (CPU 0x48512e9d)
.incbin_range "baserom/kn7000_program.rom", 0x112e9d, 0x11309e
# FuncEdit_srcPadBank  (CPU 0x4851309e)
.incbin_range "baserom/kn7000_program.rom", 0x11309e, 0x113253
# FuncEdit_srcPad  (CPU 0x48513253)
.incbin_range "baserom/kn7000_program.rom", 0x113253, 0x113369
# FuncEdit_dstPadBank  (CPU 0x48513369)
.incbin_range "baserom/kn7000_program.rom", 0x113369, 0x11351e
# FuncEdit_dstPad  (CPU 0x4851351e)
.incbin_range "baserom/kn7000_program.rom", 0x11351e, 0x113652
# MspPnCpOK  (CPU 0x48513652)
.incbin_range "baserom/kn7000_program.rom", 0x113652, 0x1136bf
# PadPnCpEditFunc  (CPU 0x485136bf)
.incbin_range "baserom/kn7000_program.rom", 0x1136bf, 0x113aab
# PadRecPtChdGrid  (CPU 0x48513aab)
.incbin_range "baserom/kn7000_program.rom", 0x113aab, 0x113b26
# PadPtChdOK  (CPU 0x48513b26)
.incbin_range "baserom/kn7000_program.rom", 0x113b26, 0x113bd2
# FE_PadPlaySetSynchro  (CPU 0x48513bd2)
.incbin_range "baserom/kn7000_program.rom", 0x113bd2, 0x113c7e
# FE_PadPlaySetLoop  (CPU 0x48513c7e)
.incbin_range "baserom/kn7000_program.rom", 0x113c7e, 0x1142a7
# PadPartSetGrid1  (CPU 0x485142a7)
.incbin_range "baserom/kn7000_program.rom", 0x1142a7, 0x1147fa
# PadPartSetGrid2  (CPU 0x485147fa)
.incbin_range "baserom/kn7000_program.rom", 0x1147fa, 0x11483f
# MspGrpNmChk  (CPU 0x4851483f)
.incbin_range "baserom/kn7000_program.rom", 0x11483f, 0x1148cc
# MspGrpNmOk  (CPU 0x485148cc)
.incbin_range "baserom/kn7000_program.rom", 0x1148cc, 0x114900
# PadPtnClrYes  (CPU 0x48514900)
.incbin_range "baserom/kn7000_program.rom", 0x114900, 0x1149e5
# FE_PadRecMeas  (CPU 0x485149e5)
.incbin_range "baserom/kn7000_program.rom", 0x1149e5, 0x114b4a
# FE_PadRecTS  (CPU 0x48514b4a)
.incbin_range "baserom/kn7000_program.rom", 0x114b4a, 0x114c38
# PadMeasTSOK  (CPU 0x48514c38)
.incbin_range "baserom/kn7000_program.rom", 0x114c38, 0x114cb1
# MspPadSelSShowHideFunc  (CPU 0x48514cb1)
.incbin_range "baserom/kn7000_program.rom", 0x114cb1, 0x114d2a
# PadMeasTSYes  (CPU 0x48514d2a)
.incbin_range "baserom/kn7000_program.rom", 0x114d2a, 0x11505f
# SeqToPadCopyGrid  (CPU 0x4851505f)
.incbin_range "baserom/kn7000_program.rom", 0x11505f, 0x115132
# FE_SeqToPadFstMeas  (CPU 0x48515132)
.incbin_range "baserom/kn7000_program.rom", 0x115132, 0x115205
# FE_SeqToPadLstMeas  (CPU 0x48515205)
.incbin_range "baserom/kn7000_program.rom", 0x115205, 0x1152f5
# FE_SeqToPadTrans  (CPU 0x485152f5)
.incbin_range "baserom/kn7000_program.rom", 0x1152f5, 0x1153f3
# FE_SeqToPadMemory  (CPU 0x485153f3)
.incbin_range "baserom/kn7000_program.rom", 0x1153f3, 0x11553a
# FE_SeqToPadPattern  (CPU 0x4851553a)
.incbin_range "baserom/kn7000_program.rom", 0x11553a, 0x115576
# SeqToPadYes  (CPU 0x48515576)
.incbin_range "baserom/kn7000_program.rom", 0x115576, 0x1159ee
# TtMspReal  (CPU 0x485159ee)
.incbin_range "baserom/kn7000_program.rom", 0x1159ee, 0x115a95
# TtPadBankSel  (CPU 0x48515a95)
.incbin_range "baserom/kn7000_program.rom", 0x115a95, 0x115b3f
# TtMspPadSel  (CPU 0x48515b3f)
.incbin_range "baserom/kn7000_program.rom", 0x115b3f, 0x115bec
# TtMspPtChd  (CPU 0x48515bec)
.incbin_range "baserom/kn7000_program.rom", 0x115bec, 0x115c60
# TtMspChdStep  (CPU 0x48515c60)
.incbin_range "baserom/kn7000_program.rom", 0x115c60, 0x115ce1
# MainPAD_GetPadBankName  (CPU 0x48515ce1)
.incbin_range "baserom/kn7000_program.rom", 0x115ce1, 0x115d7f
# MainPAD_GetPadName  (CPU 0x48515d7f)
.incbin_range "baserom/kn7000_program.rom", 0x115d7f, 0x115dbe
# MainPAD_SetUserPadRecSolo  (CPU 0x48515dbe)
.incbin_range "baserom/kn7000_program.rom", 0x115dbe, 0x115dd4
# MainPAD_SetUserPadRecQt  (CPU 0x48515dd4)
.incbin_range "baserom/kn7000_program.rom", 0x115dd4, 0x115dea
# MainPAD_SetUserPadRecordArrange  (CPU 0x48515dea)
.incbin_range "baserom/kn7000_program.rom", 0x115dea, 0x115e12
# MainPAD_SetUserPadNoteClear  (CPU 0x48515e12)
.incbin_range "baserom/kn7000_program.rom", 0x115e12, 0x115e3a
# MainPAD_SetUserPadAllErase  (CPU 0x48515e3a)
.incbin_range "baserom/kn7000_program.rom", 0x115e3a, 0x115f63
# MainPAD_UserPadPartClear  (CPU 0x48515f63)
.incbin_range "baserom/kn7000_program.rom", 0x115f63, 0x115f7a
# MainPAD_SetPadBankName  (CPU 0x48515f7a)
.incbin_range "baserom/kn7000_program.rom", 0x115f7a, 0x115fc4
# MainPAD_SetCompilePad  (CPU 0x48515fc4)
.incbin_range "baserom/kn7000_program.rom", 0x115fc4, 0x115fe2
# MainPAD_SetUserPadRecordChord  (CPU 0x48515fe2)
.incbin_range "baserom/kn7000_program.rom", 0x115fe2, 0x115ff8
# MainPAD_SetUserPadName  (CPU 0x48515ff8)
.incbin_range "baserom/kn7000_program.rom", 0x115ff8, 0x116083
# MainPAD_UserPadBankClear  (CPU 0x48516083)
.incbin_range "baserom/kn7000_program.rom", 0x116083, 0x116104
# TtMspPnCp  (CPU 0x48516104)
.incbin_range "baserom/kn7000_program.rom", 0x116104, 0x116156
# MainPAD_PadPhraseCopy  (CPU 0x48516156)
.incbin_range "baserom/kn7000_program.rom", 0x116156, 0x116174
# MainPAD_SetUserPadRecArrAll  (CPU 0x48516174)
.incbin_range "baserom/kn7000_program.rom", 0x116174, 0x11618a
# MainPAD_SetUserPadSync  (CPU 0x4851618a)
.incbin_range "baserom/kn7000_program.rom", 0x11618a, 0x1161a0
# MainPAD_SetUserPadLoop  (CPU 0x485161a0)
.incbin_range "baserom/kn7000_program.rom", 0x1161a0, 0x1161c5
# MainPAD_SetUserPadPartSetting  (CPU 0x485161c5)
.incbin_range "baserom/kn7000_program.rom", 0x1161c5, 0x116215
# MainPAD_UserPadClear  (CPU 0x48516215)
.incbin_range "baserom/kn7000_program.rom", 0x116215, 0x11626f
# MainPAD_SetUserPadMeasure  (CPU 0x4851626f)
.incbin_range "baserom/kn7000_program.rom", 0x11626f, 0x1162c7
# MainPAD_SetUserPadMsrTmSigAftClr  (CPU 0x485162c7)
.incbin_range "baserom/kn7000_program.rom", 0x1162c7, 0x11630f
# TtMspPadSel_s  (CPU 0x4851630f)
.incbin_range "baserom/kn7000_program.rom", 0x11630f, 0x116370
# TtMspSeqCp  (CPU 0x48516370)
.incbin_range "baserom/kn7000_program.rom", 0x116370, 0x1164fe
# InitializeBlock28  (CPU 0x485164fe)
.incbin_range "baserom/kn7000_program.rom", 0x1164fe, 0x116866
# InitializeBlock19  (CPU 0x48516866)
.incbin_range "baserom/kn7000_program.rom", 0x116866, 0x118481
# PsFileNameBoxProc  (CPU 0x48518481)
.incbin_range "baserom/kn7000_program.rom", 0x118481, 0x1188f6
# PsFileNmTwoBoxProc  (CPU 0x485188f6)
.incbin_range "baserom/kn7000_program.rom", 0x1188f6, 0x118d37
# PsOptionTwoBoxProc  (CPU 0x48518d37)
.incbin_range "baserom/kn7000_program.rom", 0x118d37, 0x1192fa
# PsWindowToggleProc  (CPU 0x485192fa)
.incbin_range "baserom/kn7000_program.rom", 0x1192fa, 0x119352
# AcTtlJgBoxProc  (CPU 0x48519352)
.incbin_range "baserom/kn7000_program.rom", 0x119352, 0x11943e
# IvWaitWinCtlProc  (CPU 0x4851943e)
.incbin_range "baserom/kn7000_program.rom", 0x11943e, 0x11958c
# PsPlayFileNameBoxProc  (CPU 0x4851958c)
.incbin_range "baserom/kn7000_program.rom", 0x11958c, 0x11978a
# AcParaStrBoxProc  (CPU 0x4851978a)
.incbin_range "baserom/kn7000_program.rom", 0x11978a, 0x119a52
# AcFileSfxBoxProc  (CPU 0x48519a52)
.incbin_range "baserom/kn7000_program.rom", 0x119a52, 0x119b44
# AcMonoIndexToggleProc  (CPU 0x48519b44)
.incbin_range "baserom/kn7000_program.rom", 0x119b44, 0x119c9d
# AcOptionToggleProc  (CPU 0x48519c9d)
.incbin_range "baserom/kn7000_program.rom", 0x119c9d, 0x119d7c
# IvOneShotTimerProc  (CPU 0x48519d7c)
.incbin_range "baserom/kn7000_program.rom", 0x119d7c, 0x119dd8
# VwScreenTitleProc  (CPU 0x48519dd8)
.incbin_range "baserom/kn7000_program.rom", 0x119dd8, 0x11a339
# VwOwScreenTitleProc  (CPU 0x4851a339)
.incbin_range "baserom/kn7000_program.rom", 0x11a339, 0x11a3b1
# ArrowProc  (CPU 0x4851a3b1)
.incbin_range "baserom/kn7000_program.rom", 0x11a3b1, 0x11a5da
# PsIndexParaStrBoxProc  (CPU 0x4851a5da)
.incbin_range "baserom/kn7000_program.rom", 0x11a5da, 0x11a617
# IvIndexSwCtrlProc  (CPU 0x4851a617)
.incbin_range "baserom/kn7000_program.rom", 0x11a617, 0x11a7cc
# AcRotStrBoxProc  (CPU 0x4851a7cc)
.incbin_range "baserom/kn7000_program.rom", 0x11a7cc, 0x11a901
# IvIndexSwDelayProc  (CPU 0x4851a901)
.incbin_range "baserom/kn7000_program.rom", 0x11a901, 0x11a9ad
# IvMainEditIndexProc  (CPU 0x4851a9ad)
.incbin_range "baserom/kn7000_program.rom", 0x11a9ad, 0x11b2d9
# CmpSnglLdOptionFunc  (CPU 0x4851b2d9)
.incbin_range "baserom/kn7000_program.rom", 0x11b2d9, 0x11b651
# FmmFileNameFunc  (CPU 0x4851b651)
.incbin_range "baserom/kn7000_program.rom", 0x11b651, 0x11b681
# SongNameFunc  (CPU 0x4851b681)
.incbin_range "baserom/kn7000_program.rom", 0x11b681, 0x11b6af
# SaveTtlJgFunc  (CPU 0x4851b6af)
.incbin_range "baserom/kn7000_program.rom", 0x11b6af, 0x11b6dd
# LoadTtlJgFunc  (CPU 0x4851b6dd)
.incbin_range "baserom/kn7000_program.rom", 0x11b6dd, 0x11b70b
# RenameCstScreenJgFunc  (CPU 0x4851b70b)
.incbin_range "baserom/kn7000_program.rom", 0x11b70b, 0x11b737
# DirectPlayTtlJgFunc  (CPU 0x4851b737)
.incbin_range "baserom/kn7000_program.rom", 0x11b737, 0x11b76b
# DocToSmfCngFunc  (CPU 0x4851b76b)
.incbin_range "baserom/kn7000_program.rom", 0x11b76b, 0x11b784
# FmmCstLSTitleFunc  (CPU 0x4851b784)
.incbin_range "baserom/kn7000_program.rom", 0x11b784, 0x11b798
# RenameScreenJgFunc  (CPU 0x4851b798)
.incbin_range "baserom/kn7000_program.rom", 0x11b798, 0x11b7ac
# RenameSmfScreenJgFunc  (CPU 0x4851b7ac)
.incbin_range "baserom/kn7000_program.rom", 0x11b7ac, 0x11b7c0
# FmmIntMedleyFunc  (CPU 0x4851b7c0)
.incbin_range "baserom/kn7000_program.rom", 0x11b7c0, 0x11b807
# SetupFlashFunc  (CPU 0x4851b807)
.incbin_range "baserom/kn7000_program.rom", 0x11b807, 0x11bad3
# FmmSmfUtilityTitleFunc  (CPU 0x4851bad3)
.incbin_range "baserom/kn7000_program.rom", 0x11bad3, 0x11bd9f
# FmmUtilityTitleFunc  (CPU 0x4851bd9f)
.incbin_range "baserom/kn7000_program.rom", 0x11bd9f, 0x11c072
# FmmCstUtilityTitleFunc  (CPU 0x4851c072)
.incbin_range "baserom/kn7000_program.rom", 0x11c072, 0x11c0aa
# FmmSmfMedleyFunc  (CPU 0x4851c0aa)
.incbin_range "baserom/kn7000_program.rom", 0x11c0aa, 0x11c41c
# FmmPdFileNameFunc  (CPU 0x4851c41c)
.incbin_range "baserom/kn7000_program.rom", 0x11c41c, 0x11c57e
# FileRenameFunc  (CPU 0x4851c57e)
.incbin_range "baserom/kn7000_program.rom", 0x11c57e, 0x11c6df
# FileRenameSmfFunc  (CPU 0x4851c6df)
.incbin_range "baserom/kn7000_program.rom", 0x11c6df, 0x11c840
# FileCopyFunc  (CPU 0x4851c840)
.incbin_range "baserom/kn7000_program.rom", 0x11c840, 0x11cdfd
# FmmCstFileNameFunc  (CPU 0x4851cdfd)
.incbin_range "baserom/kn7000_program.rom", 0x11cdfd, 0x11ce31
# SingleLoadModeFunc  (CPU 0x4851ce31)
.incbin_range "baserom/kn7000_program.rom", 0x11ce31, 0x11d280
# SmfPlayAsFunc  (CPU 0x4851d280)
.incbin_range "baserom/kn7000_program.rom", 0x11d280, 0x11d4af
# UtilityTtlJgFunc  (CPU 0x4851d4af)
.incbin_range "baserom/kn7000_program.rom", 0x11d4af, 0x11d659
# DiskNameFunc  (CPU 0x4851d659)
.incbin_range "baserom/kn7000_program.rom", 0x11d659, 0x11d79c
# FmmSaveTitleFunc  (CPU 0x4851d79c)
.incbin_range "baserom/kn7000_program.rom", 0x11d79c, 0x11d81e
# SaveFileNameFunc  (CPU 0x4851d81e)
.incbin_range "baserom/kn7000_program.rom", 0x11d81e, 0x11d87e
# SaveSmfTtlJgFunc  (CPU 0x4851d87e)
.incbin_range "baserom/kn7000_program.rom", 0x11d87e, 0x11d954
# FmmLoadTitleFunc  (CPU 0x4851d954)
.incbin_range "baserom/kn7000_program.rom", 0x11d954, 0x11d9b6
# FileRenameCstFunc  (CPU 0x4851d9b6)
.incbin_range "baserom/kn7000_program.rom", 0x11d9b6, 0x11e920
# FmmDiskModeFunc  (CPU 0x4851e920)
.incbin_range "baserom/kn7000_program.rom", 0x11e920, 0x11ef20
# CurFileNameFunc  (CPU 0x4851ef20)
.incbin_range "baserom/kn7000_program.rom", 0x11ef20, 0x11f1b9
# SaveFileNameNumFunc  (CPU 0x4851f1b9)
.incbin_range "baserom/kn7000_program.rom", 0x11f1b9, 0x11f746
# FmmSmfSaveTitleFunc  (CPU 0x4851f746)
.incbin_range "baserom/kn7000_program.rom", 0x11f746, 0x11f998
# SendIndexSingleLoadFunc  (CPU 0x4851f998)
.incbin_range "baserom/kn7000_program.rom", 0x11f998, 0x11fd67
# FmmPasswordFunc  (CPU 0x4851fd67)
.incbin_range "baserom/kn7000_program.rom", 0x11fd67, 0x120604
# FmmSmfFileNameFunc  (CPU 0x48520604)
.incbin_range "baserom/kn7000_program.rom", 0x120604, 0x1208e8
# FmmSmfLoadTitleFunc  (CPU 0x485208e8)
.incbin_range "baserom/kn7000_program.rom", 0x1208e8, 0x120a25
# FmmSeqSongNameFunc  (CPU 0x48520a25)
.incbin_range "baserom/kn7000_program.rom", 0x120a25, 0x120b22
# SaveFileNameSmfFunc  (CPU 0x48520b22)
.incbin_range "baserom/kn7000_program.rom", 0x120b22, 0x120c1f
# SmfSeqFromSongNumFunc  (CPU 0x48520c1f)
.incbin_range "baserom/kn7000_program.rom", 0x120c1f, 0x120c74
# SaveFileNameCstFunc  (CPU 0x48520c74)
.incbin_range "baserom/kn7000_program.rom", 0x120c74, 0x120cc9
# SmfSeqToSongNumFunc  (CPU 0x48520cc9)
.incbin_range "baserom/kn7000_program.rom", 0x120cc9, 0x120d3b
# FmmLoadFilterFunc  (CPU 0x48520d3b)
.incbin_range "baserom/kn7000_program.rom", 0x120d3b, 0x120d71
# SmfLoadAsFunc  (CPU 0x48520d71)
.incbin_range "baserom/kn7000_program.rom", 0x120d71, 0x120da7
# SmfSaveAsFunc  (CPU 0x48520da7)
.incbin_range "baserom/kn7000_program.rom", 0x120da7, 0x120f3f
# SmfSeqSongNameFunc  (CPU 0x48520f3f)
.incbin_range "baserom/kn7000_program.rom", 0x120f3f, 0x121b13
# FmmPreferenceTitleFunc  (CPU 0x48521b13)
.incbin_range "baserom/kn7000_program.rom", 0x121b13, 0x122011
# DiskInfoFunc  (CPU 0x48522011)
.incbin_range "baserom/kn7000_program.rom", 0x122011, 0x122690
# FmmWallpaperLoadFunc  (CPU 0x48522690)
.incbin_range "baserom/kn7000_program.rom", 0x122690, 0x122cdd
# SendIndexCustomSaveFunc  (CPU 0x48522cdd)
.incbin_range "baserom/kn7000_program.rom", 0x122cdd, 0x122d26
# SmfToDocCngFunc  (CPU 0x48522d26)
.incbin_range "baserom/kn7000_program.rom", 0x122d26, 0x12377b
# SingleLoadSrcDstFunc  (CPU 0x4852377b)
.incbin_range "baserom/kn7000_program.rom", 0x12377b, 0x1260df
# CusLoadSaveSrcDstFunc  (CPU 0x485260df)
.incbin_range "baserom/kn7000_program.rom", 0x1260df, 0x12626d
# FmmComposerLoadFunc  (CPU 0x4852626d)
.incbin_range "baserom/kn7000_program.rom", 0x12626d, 0x1262dd
# CustomTtlJgFunc  (CPU 0x485262dd)
.incbin_range "baserom/kn7000_program.rom", 0x1262dd, 0x126b18
# CmpSingleLoadFileFunc  (CPU 0x48526b18)
.incbin_range "baserom/kn7000_program.rom", 0x126b18, 0x126e81
# FmmCmpSingleLoadFunc  (CPU 0x48526e81)
.incbin_range "baserom/kn7000_program.rom", 0x126e81, 0x1270bc
# FmmFormatFunc  (CPU 0x485270bc)
.incbin_range "baserom/kn7000_program.rom", 0x1270bc, 0x1273f3
# FmmSaveFilterFunc  (CPU 0x485273f3)
.incbin_range "baserom/kn7000_program.rom", 0x1273f3, 0x127970
# CmpSingleLoadSrcDstFunc  (CPU 0x48527970)
.incbin_range "baserom/kn7000_program.rom", 0x127970, 0x12831d
# SongMedleyTtlJgFunc  (CPU 0x4852831d)
.incbin_range "baserom/kn7000_program.rom", 0x12831d, 0x129423
# FmmDiskMedleySelectFunc  (CPU 0x48529423)
.incbin_range "baserom/kn7000_program.rom", 0x129423, 0x12a0f7
# DocDiskNameFunc  (CPU 0x4852a0f7)
.incbin_range "baserom/kn7000_program.rom", 0x12a0f7, 0x12a9e7
# FmmDocFileNameFunc  (CPU 0x4852a9e7)
.incbin_range "baserom/kn7000_program.rom", 0x12a9e7, 0x12ab8b
# FmmPictureLoadFunc  (CPU 0x4852ab8b)
.incbin_range "baserom/kn7000_program.rom", 0x12ab8b, 0x134200
# InitializeBlock13  (CPU 0x48534200)
.incbin_range "baserom/kn7000_program.rom", 0x134200, 0x134dd7
# FE_SeqCycRecEnd  (CPU 0x48534dd7)
.incbin_range "baserom/kn7000_program.rom", 0x134dd7, 0x134ed9
# AcSeqPlayRecBoxProc  (CPU 0x48534ed9)
.incbin_range "baserom/kn7000_program.rom", 0x134ed9, 0x13504b
# AcSeqTrackNumBoxProc  (CPU 0x4853504b)
.incbin_range "baserom/kn7000_program.rom", 0x13504b, 0x135173
# AcSeqTrackPartBoxProc  (CPU 0x48535173)
.incbin_range "baserom/kn7000_program.rom", 0x135173, 0x13526e
# SeqTrackSel  (CPU 0x4853526e)
.incbin_range "baserom/kn7000_program.rom", 0x13526e, 0x1353ef
# SeqMeasUpDown  (CPU 0x485353ef)
.incbin_range "baserom/kn7000_program.rom", 0x1353ef, 0x135421
# FE_SeqMenuSongSel  (CPU 0x48535421)
.incbin_range "baserom/kn7000_program.rom", 0x135421, 0x1354fb
# FE_SeqPlaySongSel  (CPU 0x485354fb)
.incbin_range "baserom/kn7000_program.rom", 0x1354fb, 0x1355d9
# FE_SeqCycPlySrt  (CPU 0x485355d9)
.incbin_range "baserom/kn7000_program.rom", 0x1355d9, 0x135796
# AcSeqMeasBoxProc  (CPU 0x48535796)
.incbin_range "baserom/kn7000_program.rom", 0x135796, 0x13586b
# AppSEQ_InitSmfLyricsSeqFunc  (CPU 0x4853586b)
.incbin_range "baserom/kn7000_program.rom", 0x13586b, 0x13589f
# SeqEasyRecOk  (CPU 0x4853589f)
.incbin_range "baserom/kn7000_program.rom", 0x13589f, 0x1358c1
# StsEasyRec1Check  (CPU 0x485358c1)
.incbin_range "baserom/kn7000_program.rom", 0x1358c1, 0x1358e3
# AcCurSongNameSeqBoxProc  (CPU 0x485358e3)
.incbin_range "baserom/kn7000_program.rom", 0x1358e3, 0x135989
# StsEasyRec2Check  (CPU 0x48535989)
.incbin_range "baserom/kn7000_program.rom", 0x135989, 0x1359bd
# SeqRecMetTglFunc  (CPU 0x485359bd)
.incbin_range "baserom/kn7000_program.rom", 0x1359bd, 0x1359f1
# SeqCycRecTglFunc  (CPU 0x485359f1)
.incbin_range "baserom/kn7000_program.rom", 0x1359f1, 0x135a25
# FE_SeqCycPlyEnd  (CPU 0x48535a25)
.incbin_range "baserom/kn7000_program.rom", 0x135a25, 0x135b03
# FE_SeqCycRecSrt  (CPU 0x48535b03)
.incbin_range "baserom/kn7000_program.rom", 0x135b03, 0x135c93
# SeqRecStopExec  (CPU 0x48535c93)
.incbin_range "baserom/kn7000_program.rom", 0x135c93, 0x135cc7
# SeqLyricsTrueShow  (CPU 0x48535cc7)
.incbin_range "baserom/kn7000_program.rom", 0x135cc7, 0x135d21
# SeqCycClrSwFunc  (CPU 0x48535d21)
.incbin_range "baserom/kn7000_program.rom", 0x135d21, 0x135d44
# SeqLyricsFalseShow  (CPU 0x48535d44)
.incbin_range "baserom/kn7000_program.rom", 0x135d44, 0x135d68
# SeqLyrShowHide  (CPU 0x48535d68)
.incbin_range "baserom/kn7000_program.rom", 0x135d68, 0x135db3
# SeqSongNmChk  (CPU 0x48535db3)
.incbin_range "baserom/kn7000_program.rom", 0x135db3, 0x135e34
# SeqSongNmOk  (CPU 0x48535e34)
.incbin_range "baserom/kn7000_program.rom", 0x135e34, 0x135e9a
# SeqPanelWrite  (CPU 0x48535e9a)
.incbin_range "baserom/kn7000_program.rom", 0x135e9a, 0x135ebc
# StsPnlWrtCheck  (CPU 0x48535ebc)
.incbin_range "baserom/kn7000_program.rom", 0x135ebc, 0x135fd0
# FE_SeqSongClearSel  (CPU 0x48535fd0)
.incbin_range "baserom/kn7000_program.rom", 0x135fd0, 0x136062
# SeqSongClrYes  (CPU 0x48536062)
.incbin_range "baserom/kn7000_program.rom", 0x136062, 0x136084
# LyricsLyricsSeqBoxProc  (CPU 0x48536084)
.incbin_range "baserom/kn7000_program.rom", 0x136084, 0x13663f
# AttSongClrCheck  (CPU 0x4853663f)
.incbin_range "baserom/kn7000_program.rom", 0x13663f, 0x13668b
# SeqTrackClr  (CPU 0x4853668b)
.incbin_range "baserom/kn7000_program.rom", 0x13668b, 0x1366ad
# AttTrkClrCheck  (CPU 0x485366ad)
.incbin_range "baserom/kn7000_program.rom", 0x1366ad, 0x1366cf
# StsTrkClr1Check  (CPU 0x485366cf)
.incbin_range "baserom/kn7000_program.rom", 0x1366cf, 0x1366f1
# AcSongSelBoxProc  (CPU 0x485366f1)
.incbin_range "baserom/kn7000_program.rom", 0x1366f1, 0x136752
# StsTrkClr2Check  (CPU 0x48536752)
.incbin_range "baserom/kn7000_program.rom", 0x136752, 0x136786
# SeqAutoPunchTglFunc  (CPU 0x48536786)
.incbin_range "baserom/kn7000_program.rom", 0x136786, 0x1367ba
# SeqPunchInTglFunc  (CPU 0x485367ba)
.incbin_range "baserom/kn7000_program.rom", 0x1367ba, 0x136898
# FE_SeqAutoPunchSrt  (CPU 0x48536898)
.incbin_range "baserom/kn7000_program.rom", 0x136898, 0x136976
# FE_SeqAutoPunchEnd  (CPU 0x48536976)
.incbin_range "baserom/kn7000_program.rom", 0x136976, 0x136a54
# FE_SeqAutoPunchCIn  (CPU 0x48536a54)
.incbin_range "baserom/kn7000_program.rom", 0x136a54, 0x136bb2
# StsAtPunchCheck  (CPU 0x48536bb2)
.incbin_range "baserom/kn7000_program.rom", 0x136bb2, 0x136c9b
# FE_SeqQtzTrack  (CPU 0x48536c9b)
.incbin_range "baserom/kn7000_program.rom", 0x136c9b, 0x136d6e
# FE_SeqQtzFstMeas  (CPU 0x48536d6e)
.incbin_range "baserom/kn7000_program.rom", 0x136d6e, 0x136e41
# FE_SeqQtzLstMeas  (CPU 0x48536e41)
.incbin_range "baserom/kn7000_program.rom", 0x136e41, 0x136fa8
# FE_SeqQtzValue  (CPU 0x48536fa8)
.incbin_range "baserom/kn7000_program.rom", 0x136fa8, 0x137080
# FE_SeqQtzStrength  (CPU 0x48537080)
.incbin_range "baserom/kn7000_program.rom", 0x137080, 0x137170
# FE_SeqQtzWindow  (CPU 0x48537170)
.incbin_range "baserom/kn7000_program.rom", 0x137170, 0x137381
# SeqQtzYes  (CPU 0x48537381)
.incbin_range "baserom/kn7000_program.rom", 0x137381, 0x137a41
# SeqTrAsGridCheck  (CPU 0x48537a41)
.incbin_range "baserom/kn7000_program.rom", 0x137a41, 0x137bd2
# SeqTrasOK  (CPU 0x48537bd2)
.incbin_range "baserom/kn7000_program.rom", 0x137bd2, 0x137cb3
# TrAsSureLangCheck  (CPU 0x48537cb3)
.incbin_range "baserom/kn7000_program.rom", 0x137cb3, 0x137cfe
# SeqTrasYes  (CPU 0x48537cfe)
.incbin_range "baserom/kn7000_program.rom", 0x137cfe, 0x137e42
# FE_SeqTrAsPSongSel  (CPU 0x48537e42)
.incbin_range "baserom/kn7000_program.rom", 0x137e42, 0x137f23
# SeqTrAsPSongOK  (CPU 0x48537f23)
.incbin_range "baserom/kn7000_program.rom", 0x137f23, 0x137f45
# TrAsPreLangCheck  (CPU 0x48537f45)
.incbin_range "baserom/kn7000_program.rom", 0x137f45, 0x138071
# FE_SeqAfterTouchSet  (CPU 0x48538071)
.incbin_range "baserom/kn7000_program.rom", 0x138071, 0x138093
# AfterLangCheck  (CPU 0x48538093)
.incbin_range "baserom/kn7000_program.rom", 0x138093, 0x1380cd
# AcFuncToggleNeglectProc  (CPU 0x485380cd)
.incbin_range "baserom/kn7000_program.rom", 0x1380cd, 0x1381a2
# AcDiskFileNameSeqBoxProc  (CPU 0x485381a2)
.incbin_range "baserom/kn7000_program.rom", 0x1381a2, 0x138277
# SeqMdlySkipFunc  (CPU 0x48538277)
.incbin_range "baserom/kn7000_program.rom", 0x138277, 0x1382b1
# SeqDkMdlySkipFunc  (CPU 0x485382b1)
.incbin_range "baserom/kn7000_program.rom", 0x1382b1, 0x13839a
# FE_SeqTrackCopyFTrack  (CPU 0x4853839a)
.incbin_range "baserom/kn7000_program.rom", 0x13839a, 0x138483
# FE_SeqTrackCopyTTrack  (CPU 0x48538483)
.incbin_range "baserom/kn7000_program.rom", 0x138483, 0x138557
# FE_SeqTrackCopyFSong  (CPU 0x48538557)
.incbin_range "baserom/kn7000_program.rom", 0x138557, 0x13862b
# FE_SeqTrackCopyTSong  (CPU 0x4853862b)
.incbin_range "baserom/kn7000_program.rom", 0x13862b, 0x138820
# SeqTrackCopyYes  (CPU 0x48538820)
.incbin_range "baserom/kn7000_program.rom", 0x138820, 0x1388f4
# FE_SeqSongCopyFSong  (CPU 0x485388f4)
.incbin_range "baserom/kn7000_program.rom", 0x1388f4, 0x1389c8
# FE_SeqSongCopyTSong  (CPU 0x485389c8)
.incbin_range "baserom/kn7000_program.rom", 0x1389c8, 0x138acc
# SeqSongCopyYes  (CPU 0x48538acc)
.incbin_range "baserom/kn7000_program.rom", 0x138acc, 0x138bf8
# FE_SeqTrkMrgTrack  (CPU 0x48538bf8)
.incbin_range "baserom/kn7000_program.rom", 0x138bf8, 0x138d41
# SeqTrkMrgYes  (CPU 0x48538d41)
.incbin_range "baserom/kn7000_program.rom", 0x138d41, 0x138e2a
# FE_SeqMsCpFLstMeas  (CPU 0x48538e2a)
.incbin_range "baserom/kn7000_program.rom", 0x138e2a, 0x138f13
# FE_SeqMsCpFTrack  (CPU 0x48538f13)
.incbin_range "baserom/kn7000_program.rom", 0x138f13, 0x138fe6
# FE_SeqMsCpFFstMeas  (CPU 0x48538fe6)
.incbin_range "baserom/kn7000_program.rom", 0x138fe6, 0x1390b9
# FE_SeqMsCpTTrack  (CPU 0x485390b9)
.incbin_range "baserom/kn7000_program.rom", 0x1390b9, 0x13918c
# FE_SeqMsCpTSrtMeas  (CPU 0x4853918c)
.incbin_range "baserom/kn7000_program.rom", 0x13918c, 0x13925f
# FE_SeqMsCpTRep  (CPU 0x4853925f)
.incbin_range "baserom/kn7000_program.rom", 0x13925f, 0x139503
# SeqMsCpYes  (CPU 0x48539503)
.incbin_range "baserom/kn7000_program.rom", 0x139503, 0x1395ec
# FE_SeqMsErsTrack  (CPU 0x485395ec)
.incbin_range "baserom/kn7000_program.rom", 0x1395ec, 0x1396bf
# FE_SeqMsErsFstMeas  (CPU 0x485396bf)
.incbin_range "baserom/kn7000_program.rom", 0x1396bf, 0x139792
# FE_SeqMsErsLstMeas  (CPU 0x48539792)
.incbin_range "baserom/kn7000_program.rom", 0x139792, 0x139894
# FE_SeqMsErsData  (CPU 0x48539894)
.incbin_range "baserom/kn7000_program.rom", 0x139894, 0x139a40
# SeqMsErsYes  (CPU 0x48539a40)
.incbin_range "baserom/kn7000_program.rom", 0x139a40, 0x139b29
# FE_SeqMsDelTrack  (CPU 0x48539b29)
.incbin_range "baserom/kn7000_program.rom", 0x139b29, 0x139bfc
# FE_SeqMsDelFstMeas  (CPU 0x48539bfc)
.incbin_range "baserom/kn7000_program.rom", 0x139bfc, 0x139ccf
# FE_SeqMsDelLstMeas  (CPU 0x48539ccf)
.incbin_range "baserom/kn7000_program.rom", 0x139ccf, 0x139e4b
# SeqMsDelYes  (CPU 0x48539e4b)
.incbin_range "baserom/kn7000_program.rom", 0x139e4b, 0x139f34
# FE_SeqMsInsFLstMeas  (CPU 0x48539f34)
.incbin_range "baserom/kn7000_program.rom", 0x139f34, 0x13a01d
# FE_SeqMsInsFTrack  (CPU 0x4853a01d)
.incbin_range "baserom/kn7000_program.rom", 0x13a01d, 0x13a0f0
# FE_SeqMsInsFFstMeas  (CPU 0x4853a0f0)
.incbin_range "baserom/kn7000_program.rom", 0x13a0f0, 0x13a1c3
# FE_SeqMsInsTTrack  (CPU 0x4853a1c3)
.incbin_range "baserom/kn7000_program.rom", 0x13a1c3, 0x13a296
# FE_SeqMsInsTSrtMeas  (CPU 0x4853a296)
.incbin_range "baserom/kn7000_program.rom", 0x13a296, 0x13a369
# FE_SeqMsInsTRep  (CPU 0x4853a369)
.incbin_range "baserom/kn7000_program.rom", 0x13a369, 0x13a60d
# SeqMsInsYes  (CPU 0x4853a60d)
.incbin_range "baserom/kn7000_program.rom", 0x13a60d, 0x13a921
# ApcToSMFConvGrid  (CPU 0x4853a921)
.incbin_range "baserom/kn7000_program.rom", 0x13a921, 0x13a9bb
# ApcToSMFConvConv  (CPU 0x4853a9bb)
.incbin_range "baserom/kn7000_program.rom", 0x13a9bb, 0x13aa53
# ApcToSMFConvGo  (CPU 0x4853aa53)
.incbin_range "baserom/kn7000_program.rom", 0x13aa53, 0x13aac1
# ApcToSMFConvAbort  (CPU 0x4853aac1)
.incbin_range "baserom/kn7000_program.rom", 0x13aac1, 0x13aae3
# AttSeqToSmfConv1  (CPU 0x4853aae3)
.incbin_range "baserom/kn7000_program.rom", 0x13aae3, 0x13ab05
# AttSeqToSmfConv2  (CPU 0x4853ab05)
.incbin_range "baserom/kn7000_program.rom", 0x13ab05, 0x13ab27
# AttSeqToSmfConv3  (CPU 0x4853ab27)
.incbin_range "baserom/kn7000_program.rom", 0x13ab27, 0x13ac10
# FE_SeqNoteChangeTrack  (CPU 0x4853ac10)
.incbin_range "baserom/kn7000_program.rom", 0x13ac10, 0x13ace3
# FE_SeqNoteChangeFstMeas  (CPU 0x4853ace3)
.incbin_range "baserom/kn7000_program.rom", 0x13ace3, 0x13adb6
# FE_SeqNoteChangeLstMeas  (CPU 0x4853adb6)
.incbin_range "baserom/kn7000_program.rom", 0x13adb6, 0x13ae98
# FE_SeqNoteChangeSrcNt  (CPU 0x4853ae98)
.incbin_range "baserom/kn7000_program.rom", 0x13ae98, 0x13af7a
# FE_SeqNoteChangeDstNt  (CPU 0x4853af7a)
.incbin_range "baserom/kn7000_program.rom", 0x13af7a, 0x13b158
# SeqNoteChangeYes  (CPU 0x4853b158)
.incbin_range "baserom/kn7000_program.rom", 0x13b158, 0x13b241
# FE_SeqVeloCngTrack  (CPU 0x4853b241)
.incbin_range "baserom/kn7000_program.rom", 0x13b241, 0x13b314
# FE_SeqVeloCngFstMeas  (CPU 0x4853b314)
.incbin_range "baserom/kn7000_program.rom", 0x13b314, 0x13b3e7
# FE_SeqVeloCngLstMeas  (CPU 0x4853b3e7)
.incbin_range "baserom/kn7000_program.rom", 0x13b3e7, 0x13b4d7
# FE_SeqVeloCngVelo  (CPU 0x4853b4d7)
.incbin_range "baserom/kn7000_program.rom", 0x13b4d7, 0x13b683
# SeqVeloCngYes  (CPU 0x4853b683)
.incbin_range "baserom/kn7000_program.rom", 0x13b683, 0x13b76c
# FE_SeqTransTrack  (CPU 0x4853b76c)
.incbin_range "baserom/kn7000_program.rom", 0x13b76c, 0x13b83f
# FE_SeqTransFstMeas  (CPU 0x4853b83f)
.incbin_range "baserom/kn7000_program.rom", 0x13b83f, 0x13b912
# FE_SeqTransLstMeas  (CPU 0x4853b912)
.incbin_range "baserom/kn7000_program.rom", 0x13b912, 0x13ba02
# FE_SeqTransTrans  (CPU 0x4853ba02)
.incbin_range "baserom/kn7000_program.rom", 0x13ba02, 0x13bbae
# SeqTransYes  (CPU 0x4853bbae)
.incbin_range "baserom/kn7000_program.rom", 0x13bbae, 0x13bc97
# FE_SeqAdvDlyTrack  (CPU 0x4853bc97)
.incbin_range "baserom/kn7000_program.rom", 0x13bc97, 0x13bd6a
# FE_SeqAdvDlyFstMeas  (CPU 0x4853bd6a)
.incbin_range "baserom/kn7000_program.rom", 0x13bd6a, 0x13be3d
# FE_SeqAdvDlyLstMeas  (CPU 0x4853be3d)
.incbin_range "baserom/kn7000_program.rom", 0x13be3d, 0x13bf2d
# FE_SeqAdvDlyAdvDly  (CPU 0x4853bf2d)
.incbin_range "baserom/kn7000_program.rom", 0x13bf2d, 0x13c0d9
# SeqAdvDlyYes  (CPU 0x4853c0d9)
.incbin_range "baserom/kn7000_program.rom", 0x13c0d9, 0x13c0fb
# AcDiskFileNoSeqBoxProc  (CPU 0x4853c0fb)
.incbin_range "baserom/kn7000_program.rom", 0x13c0fb, 0x13cfa5
# AcNoteEditBoxProc  (CPU 0x4853cfa5)
.incbin_range "baserom/kn7000_program.rom", 0x13cfa5, 0x13d008
# StsNtDrEditCheck  (CPU 0x4853d008)
.incbin_range "baserom/kn7000_program.rom", 0x13d008, 0x13d03a
# AcSeqTrackBoxProc  (CPU 0x4853d03a)
.incbin_range "baserom/kn7000_program.rom", 0x13d03a, 0x13dd17
# SeqNoteDrumCycleTgl  (CPU 0x4853dd17)
.incbin_range "baserom/kn7000_program.rom", 0x13dd17, 0x13dd39
# AcDrumEditBoxProc  (CPU 0x4853dd39)
.incbin_range "baserom/kn7000_program.rom", 0x13dd39, 0x13eb46
# AcStepRecBoxProc  (CPU 0x4853eb46)
.incbin_range "baserom/kn7000_program.rom", 0x13eb46, 0x13ec11
# AcSeqStepTrkBoxProc  (CPU 0x4853ec11)
.incbin_range "baserom/kn7000_program.rom", 0x13ec11, 0x13ecfc
# IvSendIndexProc  (CPU 0x4853ecfc)
.incbin_range "baserom/kn7000_program.rom", 0x13ecfc, 0x13edc6
# PartSelLangCheck  (CPU 0x4853edc6)
.incbin_range "baserom/kn7000_program.rom", 0x13edc6, 0x13edfc
# SeqIndex20Send  (CPU 0x4853edfc)
.incbin_range "baserom/kn7000_program.rom", 0x13edfc, 0x13ee8e
# FE_SeqPlaylistSetting  (CPU 0x4853ee8e)
.incbin_range "baserom/kn7000_program.rom", 0x13ee8e, 0x13f009
# SeqStepPage7ShowHide  (CPU 0x4853f009)
.incbin_range "baserom/kn7000_program.rom", 0x13f009, 0x13f0ba
# SeqStepPicSwShowHide  (CPU 0x4853f0ba)
.incbin_range "baserom/kn7000_program.rom", 0x13f0ba, 0x13f1d1
# MdSeqErec  (CPU 0x4853f1d1)
.incbin_range "baserom/kn7000_program.rom", 0x13f1d1, 0x13f22d
# TtSeqStep  (CPU 0x4853f22d)
.incbin_range "baserom/kn7000_program.rom", 0x13f22d, 0x13f3eb
# MainSEQ_SeqCurSongChange_NoPlay  (CPU 0x4853f3eb)
.incbin_range "baserom/kn7000_program.rom", 0x13f3eb, 0x13f451
# MainSEQ_StepRecGo  (CPU 0x4853f451)
.incbin_range "baserom/kn7000_program.rom", 0x13f451, 0x13f47e
# MainSEQ_NoteEditGo  (CPU 0x4853f47e)
.incbin_range "baserom/kn7000_program.rom", 0x13f47e, 0x13f4ab
# MainSEQ_DrumEditGo  (CPU 0x4853f4ab)
.incbin_range "baserom/kn7000_program.rom", 0x13f4ab, 0x13f54e
# MainSEQ_SwInTrackSwSeq  (CPU 0x4853f54e)
.incbin_range "baserom/kn7000_program.rom", 0x13f54e, 0x13f56e
# MainSEQ_SwInMeasSeq  (CPU 0x4853f56e)
.incbin_range "baserom/kn7000_program.rom", 0x13f56e, 0x13f687
# MainSEQ_SwInCycPlyMeas  (CPU 0x4853f687)
.incbin_range "baserom/kn7000_program.rom", 0x13f687, 0x13f696
# MainSEQ_SeqCurSongChange_Play  (CPU 0x4853f696)
.incbin_range "baserom/kn7000_program.rom", 0x13f696, 0x13f77b
# MainSEQ_SeqCurSongChange_PlayLyr  (CPU 0x4853f77b)
.incbin_range "baserom/kn7000_program.rom", 0x13f77b, 0x13f787
# MainSEQ_SwInCycPlySwSeq  (CPU 0x4853f787)
.incbin_range "baserom/kn7000_program.rom", 0x13f787, 0x13f79f
# MainSEQ_SetLyricsFlag  (CPU 0x4853f79f)
.incbin_range "baserom/kn7000_program.rom", 0x13f79f, 0x13f83f
# TtSeqPlay  (CPU 0x4853f83f)
.incbin_range "baserom/kn7000_program.rom", 0x13f83f, 0x13f8d8
# MdSeq  (CPU 0x4853f8d8)
.incbin_range "baserom/kn7000_program.rom", 0x13f8d8, 0x13f935
# TtSeqTitle  (CPU 0x4853f935)
.incbin_range "baserom/kn7000_program.rom", 0x13f935, 0x13fa8d
# MainSEQ_SeqCycPly_Reload  (CPU 0x4853fa8d)
.incbin_range "baserom/kn7000_program.rom", 0x13fa8d, 0x13faa4
# MdSeqPlay  (CPU 0x4853faa4)
.incbin_range "baserom/kn7000_program.rom", 0x13faa4, 0x13fafb
# MainSEQ_SwInEasyRecOk  (CPU 0x4853fafb)
.incbin_range "baserom/kn7000_program.rom", 0x13fafb, 0x13fbf9
# MainSEQ_SwInMetroSwSeq  (CPU 0x4853fbf9)
.incbin_range "baserom/kn7000_program.rom", 0x13fbf9, 0x13fcdb
# MainSEQ_SwInCycRecSwSeq  (CPU 0x4853fcdb)
.incbin_range "baserom/kn7000_program.rom", 0x13fcdb, 0x13fcfc
# MainSEQ_SeqRecStopProc  (CPU 0x4853fcfc)
.incbin_range "baserom/kn7000_program.rom", 0x13fcfc, 0x13fd14
# MainSEQ_SwInCycRecMeas  (CPU 0x4853fd14)
.incbin_range "baserom/kn7000_program.rom", 0x13fd14, 0x13fd68
# MainSEQ_SeqCycRec_Reload  (CPU 0x4853fd68)
.incbin_range "baserom/kn7000_program.rom", 0x13fd68, 0x13fd7d
# TtSeqCycPly  (CPU 0x4853fd7d)
.incbin_range "baserom/kn7000_program.rom", 0x13fd7d, 0x13fe57
# TtSeqRealRec  (CPU 0x4853fe57)
.incbin_range "baserom/kn7000_program.rom", 0x13fe57, 0x13ff3f
# TtSeqCycRec  (CPU 0x4853ff3f)
.incbin_range "baserom/kn7000_program.rom", 0x13ff3f, 0x13ff96
# NameGetFuncCallSeq  (CPU 0x4853ff96)
.incbin_range "baserom/kn7000_program.rom", 0x13ff96, 0x140031
# MainSEQ_SongNamingGet  (CPU 0x48540031)
.incbin_range "baserom/kn7000_program.rom", 0x140031, 0x140054
# MainSEQ_SeqSongNameSet  (CPU 0x48540054)
.incbin_range "baserom/kn7000_program.rom", 0x140054, 0x140078
# MainSEQ_PanelWrite_SE  (CPU 0x48540078)
.incbin_range "baserom/kn7000_program.rom", 0x140078, 0x140161
# MainSEQ_SongClrNameParaDraw  (CPU 0x48540161)
.incbin_range "baserom/kn7000_program.rom", 0x140161, 0x140188
# TtSeqRecEdit  (CPU 0x48540188)
.incbin_range "baserom/kn7000_program.rom", 0x140188, 0x1402ad
# MainSEQ_SongClear_SE  (CPU 0x485402ad)
.incbin_range "baserom/kn7000_program.rom", 0x1402ad, 0x140350
# MainSEQ_SongSelBoxSetString  (CPU 0x48540350)
.incbin_range "baserom/kn7000_program.rom", 0x140350, 0x1403c1
# MainSEQ_CurSongSet_NoPlayDisp  (CPU 0x485403c1)
.incbin_range "baserom/kn7000_program.rom", 0x1403c1, 0x14043d
# TtSeqSngClr  (CPU 0x4854043d)
.incbin_range "baserom/kn7000_program.rom", 0x14043d, 0x140494
# MainSEQ_TrackClear_SE  (CPU 0x48540494)
.incbin_range "baserom/kn7000_program.rom", 0x140494, 0x140549
# MainSEQ_SwInAutoPunchSwSeq  (CPU 0x48540549)
.incbin_range "baserom/kn7000_program.rom", 0x140549, 0x1405b0
# MainSEQ_SwInPunchInSeq  (CPU 0x485405b0)
.incbin_range "baserom/kn7000_program.rom", 0x1405b0, 0x1405d3
# MainSEQ_SwInAutoPunchMeas  (CPU 0x485405d3)
.incbin_range "baserom/kn7000_program.rom", 0x1405d3, 0x140695
# TtSeqTrkClr  (CPU 0x48540695)
.incbin_range "baserom/kn7000_program.rom", 0x140695, 0x1407c3
# TtSeqPunch  (CPU 0x485407c3)
.incbin_range "baserom/kn7000_program.rom", 0x1407c3, 0x14085c
# MainSEQ_SeqAutoPunch_Reload  (CPU 0x4854085c)
.incbin_range "baserom/kn7000_program.rom", 0x14085c, 0x140923
# MainSEQ_Quantize_SE  (CPU 0x48540923)
.incbin_range "baserom/kn7000_program.rom", 0x140923, 0x140a20
# MainSEQ_TrasUpdate  (CPU 0x48540a20)
.incbin_range "baserom/kn7000_program.rom", 0x140a20, 0x140a6a
# MainSEQ_JudgeTrkAsgnOk  (CPU 0x48540a6a)
.incbin_range "baserom/kn7000_program.rom", 0x140a6a, 0x140a82
# MainSEQ_SetLocalCtrlBitSeq  (CPU 0x48540a82)
.incbin_range "baserom/kn7000_program.rom", 0x140a82, 0x140a9a
# MainSEQ_SetMidiOutBitSeq  (CPU 0x48540a9a)
.incbin_range "baserom/kn7000_program.rom", 0x140a9a, 0x140b0b
# MainSEQ_GridDrawLocalCtrlSeq  (CPU 0x48540b0b)
.incbin_range "baserom/kn7000_program.rom", 0x140b0b, 0x140b7c
# TtSeqPunchMeas  (CPU 0x48540b7c)
.incbin_range "baserom/kn7000_program.rom", 0x140b7c, 0x140c04
# MainSEQ_GridDrawMidiOutSeq  (CPU 0x48540c04)
.incbin_range "baserom/kn7000_program.rom", 0x140c04, 0x140c6e
# TtSeqTrAs  (CPU 0x48540c6e)
.incbin_range "baserom/kn7000_program.rom", 0x140c6e, 0x140d79
# TtSeqMdlyPly  (CPU 0x48540d79)
.incbin_range "baserom/kn7000_program.rom", 0x140d79, 0x140e84
# MainSEQ_SwInTrkAsgnPresetOk  (CPU 0x48540e84)
.incbin_range "baserom/kn7000_program.rom", 0x140e84, 0x140eff
# MainSEQ_TrackCopySongParaDraw  (CPU 0x48540eff)
.incbin_range "baserom/kn7000_program.rom", 0x140eff, 0x140fc4
# MainSEQ_SongTrackCopy_SE  (CPU 0x48540fc4)
.incbin_range "baserom/kn7000_program.rom", 0x140fc4, 0x141082
# MainSEQ_TrackMerge_SE  (CPU 0x48541082)
.incbin_range "baserom/kn7000_program.rom", 0x141082, 0x141149
# MainSEQ_MeasureCopy_SE  (CPU 0x48541149)
.incbin_range "baserom/kn7000_program.rom", 0x141149, 0x141cc6
# MainSEQ_MeasureErase_SE  (CPU 0x48541cc6)
.incbin_range "baserom/kn7000_program.rom", 0x141cc6, 0x141d1d
# MainSEQ_StepChangePage  (CPU 0x48541d1d)
.incbin_range "baserom/kn7000_program.rom", 0x141d1d, 0x141deb
# MainSEQ_MeasureDelete_SE  (CPU 0x48541deb)
.incbin_range "baserom/kn7000_program.rom", 0x141deb, 0x141eb2
# MainSEQ_MeasureInsert_SE  (CPU 0x48541eb2)
.incbin_range "baserom/kn7000_program.rom", 0x141eb2, 0x141f6d
# TtDkMdlyPly  (CPU 0x48541f6d)
.incbin_range "baserom/kn7000_program.rom", 0x141f6d, 0x141fd0
# MainSEQ_ApcToSmfCnv_SE  (CPU 0x48541fd0)
.incbin_range "baserom/kn7000_program.rom", 0x141fd0, 0x142097
# MainSEQ_NoteChange_SE  (CPU 0x48542097)
.incbin_range "baserom/kn7000_program.rom", 0x142097, 0x142157
# MainSEQ_VelocityChange_SE  (CPU 0x48542157)
.incbin_range "baserom/kn7000_program.rom", 0x142157, 0x14221e
# MainSEQ_Transpose_SE  (CPU 0x4854221e)
.incbin_range "baserom/kn7000_program.rom", 0x14221e, 0x1422e5
# MainSEQ_AdvanceDelay_SE  (CPU 0x485422e5)
.incbin_range "baserom/kn7000_program.rom", 0x1422e5, 0x1426b3
# MainSEQ_NoteEditRedraw  (CPU 0x485426b3)
.incbin_range "baserom/kn7000_program.rom", 0x1426b3, 0x1426dc
# MainSEQ_SwInMeas_NE  (CPU 0x485426dc)
.incbin_range "baserom/kn7000_program.rom", 0x1426dc, 0x142700
# MainSEQ_SwInPos_NE  (CPU 0x48542700)
.incbin_range "baserom/kn7000_program.rom", 0x142700, 0x142724
# MainSEQ_SwInNote_NE  (CPU 0x48542724)
.incbin_range "baserom/kn7000_program.rom", 0x142724, 0x142748
# MainSEQ_SwInVel_NE  (CPU 0x48542748)
.incbin_range "baserom/kn7000_program.rom", 0x142748, 0x14276c
# MainSEQ_SwInLen_NE  (CPU 0x4854276c)
.incbin_range "baserom/kn7000_program.rom", 0x14276c, 0x142790
# MainSEQ_SwInInc_NE  (CPU 0x48542790)
.incbin_range "baserom/kn7000_program.rom", 0x142790, 0x1427b4
# MainSEQ_SwInCursor_NE  (CPU 0x485427b4)
.incbin_range "baserom/kn7000_program.rom", 0x1427b4, 0x1427d3
# MainSEQ_SwInErs_NE  (CPU 0x485427d3)
.incbin_range "baserom/kn7000_program.rom", 0x1427d3, 0x14283e
# MainSEQ_SwInGraph_NE  (CPU 0x4854283e)
.incbin_range "baserom/kn7000_program.rom", 0x14283e, 0x14285b
# TtSeqApcRemix  (CPU 0x4854285b)
.incbin_range "baserom/kn7000_program.rom", 0x14285b, 0x1428e8
# TtSeqNoteSel  (CPU 0x485428e8)
.incbin_range "baserom/kn7000_program.rom", 0x1428e8, 0x142995
# MainSEQ_NEUpdate  (CPU 0x48542995)
.incbin_range "baserom/kn7000_program.rom", 0x142995, 0x142a14
# TtSeqNoteEdt  (CPU 0x48542a14)
.incbin_range "baserom/kn7000_program.rom", 0x142a14, 0x142add
# MainSEQ_SwInEnter_DE  (CPU 0x48542add)
.incbin_range "baserom/kn7000_program.rom", 0x142add, 0x142b01
# MainSEQ_SwInSolo_NE  (CPU 0x48542b01)
.incbin_range "baserom/kn7000_program.rom", 0x142b01, 0x142b20
# MainSEQ_SwInSound_DE  (CPU 0x48542b20)
.incbin_range "baserom/kn7000_program.rom", 0x142b20, 0x142b3d
# TtSeqNoteDrumCycp  (CPU 0x48542b3d)
.incbin_range "baserom/kn7000_program.rom", 0x142b3d, 0x142bea
# MainSEQ_StepRecRedraw  (CPU 0x48542bea)
.incbin_range "baserom/kn7000_program.rom", 0x142bea, 0x142c1e
# MainSEQ_SwInMeas_SR  (CPU 0x48542c1e)
.incbin_range "baserom/kn7000_program.rom", 0x142c1e, 0x142c42
# MainSEQ_SwInNote_SR  (CPU 0x48542c42)
.incbin_range "baserom/kn7000_program.rom", 0x142c42, 0x142c66
# MainSEQ_SwInVel_SR  (CPU 0x48542c66)
.incbin_range "baserom/kn7000_program.rom", 0x142c66, 0x142c8a
# MainSEQ_SwInLen_SR  (CPU 0x48542c8a)
.incbin_range "baserom/kn7000_program.rom", 0x142c8a, 0x142cae
# MainSEQ_SwInLeftLength_SR  (CPU 0x48542cae)
.incbin_range "baserom/kn7000_program.rom", 0x142cae, 0x142cd2
# MainSEQ_SwInRightLength_SR  (CPU 0x48542cd2)
.incbin_range "baserom/kn7000_program.rom", 0x142cd2, 0x142cf6
# MainSEQ_SwInPhrs_SR  (CPU 0x48542cf6)
.incbin_range "baserom/kn7000_program.rom", 0x142cf6, 0x142d44
# MainSEQ_SwInCursor_SR  (CPU 0x48542d44)
.incbin_range "baserom/kn7000_program.rom", 0x142d44, 0x142d63
# MainSEQ_SwInBal_SR  (CPU 0x48542d63)
.incbin_range "baserom/kn7000_program.rom", 0x142d63, 0x142d71
# MainSEQ_SwInErs_SR  (CPU 0x48542d71)
.incbin_range "baserom/kn7000_program.rom", 0x142d71, 0x142d90
# MainSEQ_SwInRest_SR  (CPU 0x48542d90)
.incbin_range "baserom/kn7000_program.rom", 0x142d90, 0x142db4
# MainSEQ_SwInVolume_SR  (CPU 0x48542db4)
.incbin_range "baserom/kn7000_program.rom", 0x142db4, 0x142dd8
# MainSEQ_SwInCtlSts_SR  (CPU 0x48542dd8)
.incbin_range "baserom/kn7000_program.rom", 0x142dd8, 0x142dfc
# MainSEQ_SwInCtlVal_SR  (CPU 0x48542dfc)
.incbin_range "baserom/kn7000_program.rom", 0x142dfc, 0x142e2d
# MainSEQ_SwInCtlYes_SR  (CPU 0x48542e2d)
.incbin_range "baserom/kn7000_program.rom", 0x142e2d, 0x142e5e
# MainSEQ_SwInYes_SR  (CPU 0x48542e5e)
.incbin_range "baserom/kn7000_program.rom", 0x142e5e, 0x142e82
# MainSEQ_SwInCtl_SR  (CPU 0x48542e82)
.incbin_range "baserom/kn7000_program.rom", 0x142e82, 0x142ea9
# MainSEQ_StepChangePageForce  (CPU 0x48542ea9)
.incbin_range "baserom/kn7000_program.rom", 0x142ea9, 0x142eda
# MainSEQ_SwInCueYes_SR  (CPU 0x48542eda)
.incbin_range "baserom/kn7000_program.rom", 0x142eda, 0x142efe
# MainSEQ_SwInCue_SR  (CPU 0x48542efe)
.incbin_range "baserom/kn7000_program.rom", 0x142efe, 0x142f22
# MainSEQ_SwInCueVal_SR  (CPU 0x48542f22)
.incbin_range "baserom/kn7000_program.rom", 0x142f22, 0x142f2a
# MainSEQ_SwInCueStl_SR  (CPU 0x48542f2a)
.incbin_range "baserom/kn7000_program.rom", 0x142f2a, 0x142f4e
# MainSEQ_SwInCueEdit_SR  (CPU 0x48542f4e)
.incbin_range "baserom/kn7000_program.rom", 0x142f4e, 0x142f72
# MainSEQ_DEUpdate  (CPU 0x48542f72)
.incbin_range "baserom/kn7000_program.rom", 0x142f72, 0x143cc2
# MainSEQ_SwInValue_SR  (CPU 0x48543cc2)
.incbin_range "baserom/kn7000_program.rom", 0x143cc2, 0x143ce1
# MainSEQ_SwInRep_SR  (CPU 0x48543ce1)
.incbin_range "baserom/kn7000_program.rom", 0x143ce1, 0x143d00
# MainSEQ_SwInEnd_SR  (CPU 0x48543d00)
.incbin_range "baserom/kn7000_program.rom", 0x143d00, 0x143eb8
# MainSEQ_SwInTrkClr_SR  (CPU 0x48543eb8)
.incbin_range "baserom/kn7000_program.rom", 0x143eb8, 0x143ed5
# TtSeqDrumEdt  (CPU 0x48543ed5)
.incbin_range "baserom/kn7000_program.rom", 0x143ed5, 0x143fca
# MainSEQ_SRUpdate  (CPU 0x48543fca)
.incbin_range "baserom/kn7000_program.rom", 0x143fca, 0x144024
# MainSEQ_SwInCueStlEdit_SR  (CPU 0x48544024)
.incbin_range "baserom/kn7000_program.rom", 0x144024, 0x1440e6
# MainSEQ_PlaylistSetting  (CPU 0x485440e6)
.incbin_range "baserom/kn7000_program.rom", 0x1440e6, 0x1441af
# AppSEQ_InitSmfLyricsSeq  (CPU 0x485441af)
.incbin_range "baserom/kn7000_program.rom", 0x1441af, 0x1441bb
# AcSeqCapaBoxProc  (CPU 0x485441bb)
.incbin_range "baserom/kn7000_program.rom", 0x1441bb, 0x144968
# SeqLyricsSong  (CPU 0x48544968)
.incbin_range "baserom/kn7000_program.rom", 0x144968, 0x1449a0
# SeqLyricsBoxFuncProc  (CPU 0x485449a0)
.incbin_range "baserom/kn7000_program.rom", 0x1449a0, 0x144f10
# SeqLyricsBoxProc  (CPU 0x48544f10)
.incbin_range "baserom/kn7000_program.rom", 0x144f10, 0x145007
# MainSEQ_Read_1EventLyricsSeq  (CPU 0x48545007)
.incbin_range "baserom/kn7000_program.rom", 0x145007, 0x145210
# ComporserSeqNameBoxProc  (CPU 0x48545210)
.incbin_range "baserom/kn7000_program.rom", 0x145210, 0x145307
# SongNameSeqBoxProc  (CPU 0x48545307)
.incbin_range "baserom/kn7000_program.rom", 0x145307, 0x1453d0
# LyricsMusicSeqBoxProc  (CPU 0x485453d0)
.incbin_range "baserom/kn7000_program.rom", 0x1453d0, 0x145d3b
# MainSEQ_SwInCycRecClr  (CPU 0x48545d3b)
.incbin_range "baserom/kn7000_program.rom", 0x145d3b, 0x145dec
# SeqPlayCycleTgl  (CPU 0x48545dec)
.incbin_range "baserom/kn7000_program.rom", 0x145dec, 0x14d8ab
# InitializeBlock27  (CPU 0x4854d8ab)
.incbin_range "baserom/kn7000_program.rom", 0x14d8ab, 0x14dd10
# AcDemoImageProc  (CPU 0x4854dd10)
.incbin_range "baserom/kn7000_program.rom", 0x14dd10, 0x14de17
# AcDemoSelectProc  (CPU 0x4854de17)
.incbin_range "baserom/kn7000_program.rom", 0x14de17, 0x14dfaf
# AcDemoScreenProc  (CPU 0x4854dfaf)
.incbin_range "baserom/kn7000_program.rom", 0x14dfaf, 0x14e3fc
# GetDefaultWindowID  (CPU 0x4854e3fc)
.incbin_range "baserom/kn7000_program.rom", 0x14e3fc, 0x14ea2c
# InitializeBlock32  (CPU 0x4854ea2c)
.incbin_range "baserom/kn7000_program.rom", 0x14ea2c, 0x1506b6
# PsFolderFileListBoxProc  (CPU 0x485506b6)
.incbin_range "baserom/kn7000_program.rom", 0x1506b6, 0x150988
# AcFavoriteSongProc  (CPU 0x48550988)
.incbin_range "baserom/kn7000_program.rom", 0x150988, 0x1509db
# IvExit2MainProc  (CPU 0x485509db)
.incbin_range "baserom/kn7000_program.rom", 0x1509db, 0x150a9c
# AcFavSongScreenProc  (CPU 0x48550a9c)
.incbin_range "baserom/kn7000_program.rom", 0x150a9c, 0x150c4d
# IvPageCtrMultiWinProc  (CPU 0x48550c4d)
.incbin_range "baserom/kn7000_program.rom", 0x150c4d, 0x150c91
# AcPlistStrBoxProc  (CPU 0x48550c91)
.incbin_range "baserom/kn7000_program.rom", 0x150c91, 0x150f84
# VwSdFolderImageProc  (CPU 0x48550f84)
.incbin_range "baserom/kn7000_program.rom", 0x150f84, 0x152418
# SdcFmmSaveFilterFunc  (CPU 0x48552418)
.incbin_range "baserom/kn7000_program.rom", 0x152418, 0x15254c
# SdcLoadTtlJgFunc  (CPU 0x4855254c)
.incbin_range "baserom/kn7000_program.rom", 0x15254c, 0x15266c
# SdcUtilityTtlJgFunc  (CPU 0x4855266c)
.incbin_range "baserom/kn7000_program.rom", 0x15266c, 0x1526e4
# SdcSaveTtlJgFunc  (CPU 0x485526e4)
.incbin_range "baserom/kn7000_program.rom", 0x1526e4, 0x15275c
# SdcSaveSmfTtlJgFunc  (CPU 0x4855275c)
.incbin_range "baserom/kn7000_program.rom", 0x15275c, 0x1527d4
# SdcMedleyTtlJgFunc  (CPU 0x485527d4)
.incbin_range "baserom/kn7000_program.rom", 0x1527d4, 0x15284c
# SdcCustomTtlJgFunc  (CPU 0x4855284c)
.incbin_range "baserom/kn7000_program.rom", 0x15284c, 0x1528c4
# SdcFavoriteTtlJgFunc  (CPU 0x485528c4)
.incbin_range "baserom/kn7000_program.rom", 0x1528c4, 0x1528de
# SdcAudioTtlJgFunc  (CPU 0x485528de)
.incbin_range "baserom/kn7000_program.rom", 0x1528de, 0x1528f8
# SdcSoundTtlJgFunc  (CPU 0x485528f8)
.incbin_range "baserom/kn7000_program.rom", 0x1528f8, 0x152921
# SdcRenameTechScreenJudge  (CPU 0x48552921)
.incbin_range "baserom/kn7000_program.rom", 0x152921, 0x15293e
# SdcRenameSmfScreenJudge  (CPU 0x4855293e)
.incbin_range "baserom/kn7000_program.rom", 0x15293e, 0x15295b
# SdcFdCopySmfScreenJudge  (CPU 0x4855295b)
.incbin_range "baserom/kn7000_program.rom", 0x15295b, 0x152978
# SdcPlaylistNameScreenJudge  (CPU 0x48552978)
.incbin_range "baserom/kn7000_program.rom", 0x152978, 0x152995
# SdcRenameCstScreenJudge  (CPU 0x48552995)
.incbin_range "baserom/kn7000_program.rom", 0x152995, 0x152a94
# SdcFdCopyTechScreenJudge  (CPU 0x48552a94)
.incbin_range "baserom/kn7000_program.rom", 0x152a94, 0x152c14
# SdcFmmModeFunc  (CPU 0x48552c14)
.incbin_range "baserom/kn7000_program.rom", 0x152c14, 0x152e87
# SdcFmmFavSetTitleFunc  (CPU 0x48552e87)
.incbin_range "baserom/kn7000_program.rom", 0x152e87, 0x1530d3
# SdcFmmNumberLoadFunc  (CPU 0x485530d3)
.incbin_range "baserom/kn7000_program.rom", 0x1530d3, 0x1532b7
# SdcFmmSmfImportTitleFunc  (CPU 0x485532b7)
.incbin_range "baserom/kn7000_program.rom", 0x1532b7, 0x153436
# SdcFmmSaveTitleFunc  (CPU 0x48553436)
.incbin_range "baserom/kn7000_program.rom", 0x153436, 0x1535df
# SdcFmmSmfLoadTitleFunc  (CPU 0x485535df)
.incbin_range "baserom/kn7000_program.rom", 0x1535df, 0x1537f1
# SdcFmmUtilityTitleFunc  (CPU 0x485537f1)
.incbin_range "baserom/kn7000_program.rom", 0x1537f1, 0x153a53
# SdcFmmSmfUtilityTitleFunc  (CPU 0x48553a53)
.incbin_range "baserom/kn7000_program.rom", 0x153a53, 0x153b8d
# SdcFmmCstUtilityTitleFunc  (CPU 0x48553b8d)
.incbin_range "baserom/kn7000_program.rom", 0x153b8d, 0x153cba
# SdcFmmSmfExportTitleFunc  (CPU 0x48553cba)
.incbin_range "baserom/kn7000_program.rom", 0x153cba, 0x153dee
# SdcFmmMedleyEditTitleFunc  (CPU 0x48553dee)
.incbin_range "baserom/kn7000_program.rom", 0x153dee, 0x15403d
# SdcFmmLoadTitleFunc  (CPU 0x4855403d)
.incbin_range "baserom/kn7000_program.rom", 0x15403d, 0x1541dd
# SdcFmmFavSongTitleFunc  (CPU 0x485541dd)
.incbin_range "baserom/kn7000_program.rom", 0x1541dd, 0x154573
# SdcCmpSnglLdOptionFunc  (CPU 0x48554573)
.incbin_range "baserom/kn7000_program.rom", 0x154573, 0x1545ba
# SdcPlaylistNameScreenJudge2  (CPU 0x485545ba)
.incbin_range "baserom/kn7000_program.rom", 0x1545ba, 0x15518c
# SdcFmmLoadFilterFunc  (CPU 0x4855518c)
.incbin_range "baserom/kn7000_program.rom", 0x15518c, 0x155957
# SDCardInfoFunc  (CPU 0x48555957)
.incbin_range "baserom/kn7000_program.rom", 0x155957, 0x1559ee
# SdcFavBankNameFunc  (CPU 0x485559ee)
.incbin_range "baserom/kn7000_program.rom", 0x1559ee, 0x155b64
# SdcFolderRenameFunc  (CPU 0x48555b64)
.incbin_range "baserom/kn7000_program.rom", 0x155b64, 0x155ce9
# SdcCurFolderNameFunc  (CPU 0x48555ce9)
.incbin_range "baserom/kn7000_program.rom", 0x155ce9, 0x155d8c
# SdcFmmFdSmfFileViewFunc  (CPU 0x48555d8c)
.incbin_range "baserom/kn7000_program.rom", 0x155d8c, 0x155e94
# SdcFmmFolderNameFunc  (CPU 0x48555e94)
.incbin_range "baserom/kn7000_program.rom", 0x155e94, 0x1564cb
# SdcCurFileNameFunc  (CPU 0x485564cb)
.incbin_range "baserom/kn7000_program.rom", 0x1564cb, 0x1565e2
# SdcFmmSmfSaveTitleFunc  (CPU 0x485565e2)
.incbin_range "baserom/kn7000_program.rom", 0x1565e2, 0x156811
# SdcFormatFunc  (CPU 0x48556811)
.incbin_range "baserom/kn7000_program.rom", 0x156811, 0x156fe2
# SdcTechFileCopyFunc  (CPU 0x48556fe2)
.incbin_range "baserom/kn7000_program.rom", 0x156fe2, 0x157654
# SdcFdFileViewFunc  (CPU 0x48557654)
.incbin_range "baserom/kn7000_program.rom", 0x157654, 0x157971
# SdcFmmSongMedleyFunc  (CPU 0x48557971)
.incbin_range "baserom/kn7000_program.rom", 0x157971, 0x157f0e
# SdcFmmMedleyListFunc  (CPU 0x48557f0e)
.incbin_range "baserom/kn7000_program.rom", 0x157f0e, 0x158907
# SdcFmmCusLdSvTitleFunc  (CPU 0x48558907)
.incbin_range "baserom/kn7000_program.rom", 0x158907, 0x158e7d
# SdcFmmSongMedleyListViewFunc  (CPU 0x48558e7d)
.incbin_range "baserom/kn7000_program.rom", 0x158e7d, 0x1598a9
# SdcFmmPasswordFunc  (CPU 0x485598a9)
.incbin_range "baserom/kn7000_program.rom", 0x1598a9, 0x1598d9
# SdcSmfTrkNumAndNameFunc  (CPU 0x485598d9)
.incbin_range "baserom/kn7000_program.rom", 0x1598d9, 0x1599dc
# SdcSmfSeqSongNameFunc  (CPU 0x485599dc)
.incbin_range "baserom/kn7000_program.rom", 0x1599dc, 0x159e9d
# SdcSmfSongRenameFunc  (CPU 0x48559e9d)
.incbin_range "baserom/kn7000_program.rom", 0x159e9d, 0x159ff1
# SdcSmfSaveSongNameFunc  (CPU 0x48559ff1)
.incbin_range "baserom/kn7000_program.rom", 0x159ff1, 0x15ae2a
# SdcSmfSaveAsFunc  (CPU 0x4855ae2a)
.incbin_range "baserom/kn7000_program.rom", 0x15ae2a, 0x15ae81
# SdcFmmSmfCurPlaylistFunc  (CPU 0x4855ae81)
.incbin_range "baserom/kn7000_program.rom", 0x15ae81, 0x15aeb7
# SdcSaveFileNameFunc  (CPU 0x4855aeb7)
.incbin_range "baserom/kn7000_program.rom", 0x15aeb7, 0x15af54
# SdcSmfSeqToSongNumFunc  (CPU 0x4855af54)
.incbin_range "baserom/kn7000_program.rom", 0x15af54, 0x15afab
# SdcSmfSeqFromSongNumFunc  (CPU 0x4855afab)
.incbin_range "baserom/kn7000_program.rom", 0x15afab, 0x15b029
# SdcSmfLoadAsFunc  (CPU 0x4855b029)
.incbin_range "baserom/kn7000_program.rom", 0x15b029, 0x15b05f
# SdcCstSongRenameFunc  (CPU 0x4855b05f)
.incbin_range "baserom/kn7000_program.rom", 0x15b05f, 0x15b357
# SdcNewPlaylistInfoFunc  (CPU 0x4855b357)
.incbin_range "baserom/kn7000_program.rom", 0x15b357, 0x15b631
# SdcFmmSmfPlaylistNameFunc  (CPU 0x4855b631)
.incbin_range "baserom/kn7000_program.rom", 0x15b631, 0x15b6e5
# SdcFmmPrivateSmfFileNameFunc  (CPU 0x4855b6e5)
.incbin_range "baserom/kn7000_program.rom", 0x15b6e5, 0x15b998
# SdcSongRenameFunc  (CPU 0x4855b998)
.incbin_range "baserom/kn7000_program.rom", 0x15b998, 0x15bac5
# SdcPlistNamingFunc  (CPU 0x4855bac5)
.incbin_range "baserom/kn7000_program.rom", 0x15bac5, 0x15bb06
# SdcFmmSmfFileNameFunc  (CPU 0x4855bb06)
.incbin_range "baserom/kn7000_program.rom", 0x15bb06, 0x15bba3
# SdcFmmCstFileNameFunc  (CPU 0x4855bba3)
.incbin_range "baserom/kn7000_program.rom", 0x15bba3, 0x15c207
# SdcFmmPrivateSmfFileViewFunc  (CPU 0x4855c207)
.incbin_range "baserom/kn7000_program.rom", 0x15c207, 0x15c863
# SdcFavoriteSongsBankFunc  (CPU 0x4855c863)
.incbin_range "baserom/kn7000_program.rom", 0x15c863, 0x15cad0
# SdcFavoriteStrFunc  (CPU 0x4855cad0)
.incbin_range "baserom/kn7000_program.rom", 0x15cad0, 0x15cb0b
# SdcCusLoadSaveSrcDstFunc  (CPU 0x4855cb0b)
.incbin_range "baserom/kn7000_program.rom", 0x15cb0b, 0x15cce6
# SdcFavoriteStrPreviewFunc  (CPU 0x4855cce6)
.incbin_range "baserom/kn7000_program.rom", 0x15cce6, 0x15cfb0
# SdcFmmPictureLoadFunc  (CPU 0x4855cfb0)
.incbin_range "baserom/kn7000_program.rom", 0x15cfb0, 0x15d0cb
# SdcSetupFlashFunc  (CPU 0x4855d0cb)
.incbin_range "baserom/kn7000_program.rom", 0x15d0cb, 0x15d901
# SDCardNameFunc  (CPU 0x4855d901)
.incbin_range "baserom/kn7000_program.rom", 0x15d901, 0x15daa8
# SdcFmmSortNameFunc  (CPU 0x4855daa8)
.incbin_range "baserom/kn7000_program.rom", 0x15daa8, 0x15dc61
# SdcSaveFileNameCstFunc  (CPU 0x4855dc61)
.incbin_range "baserom/kn7000_program.rom", 0x15dc61, 0x15dd47
# SdcSingleLoadModeFunc  (CPU 0x4855dd47)
.incbin_range "baserom/kn7000_program.rom", 0x15dd47, 0x15e06c
# SdcSingleLoadSrcDstFunc  (CPU 0x4855e06c)
.incbin_range "baserom/kn7000_program.rom", 0x15e06c, 0x15e132
# SdcFmmPictureDirectryFunc  (CPU 0x4855e132)
.incbin_range "baserom/kn7000_program.rom", 0x15e132, 0x15e574
# SdcFmmSeqSongNameFunc  (CPU 0x4855e574)
.incbin_range "baserom/kn7000_program.rom", 0x15e574, 0x1661a0
# InitializeBlock11  (CPU 0x485661a0)
.incbin_range "baserom/kn7000_program.rom", 0x1661a0, 0x166652
# DspUnitNumCheck  (CPU 0x48566652)
.incbin_range "baserom/kn7000_program.rom", 0x166652, 0x1666e6
# DSPSELTitleFunc  (CPU 0x485666e6)
.incbin_range "baserom/kn7000_program.rom", 0x1666e6, 0x166791
# EditExitCatchFunc  (CPU 0x48566791)
.incbin_range "baserom/kn7000_program.rom", 0x166791, 0x1667e6
# REVSELTitleFunc  (CPU 0x485667e6)
.incbin_range "baserom/kn7000_program.rom", 0x1667e6, 0x16687f
# CHOSELTitleFunc  (CPU 0x4856687f)
.incbin_range "baserom/kn7000_program.rom", 0x16687f, 0x1669d6
# RevDepEditFunc  (CPU 0x485669d6)
.incbin_range "baserom/kn7000_program.rom", 0x1669d6, 0x166af7
# DspUnitNumSel  (CPU 0x48566af7)
.incbin_range "baserom/kn7000_program.rom", 0x166af7, 0x166c03
# EffectWrite  (CPU 0x48566c03)
.incbin_range "baserom/kn7000_program.rom", 0x166c03, 0x166d80
# EffNamingTitleFunc  (CPU 0x48566d80)
.incbin_range "baserom/kn7000_program.rom", 0x166d80, 0x167061
# AcEffExpGroupProc  (CPU 0x48567061)
.incbin_range "baserom/kn7000_program.rom", 0x167061, 0x16744d
# AcEffPageProc  (CPU 0x4856744d)
.incbin_range "baserom/kn7000_program.rom", 0x16744d, 0x167860
# AcEffVariProc  (CPU 0x48567860)
.incbin_range "baserom/kn7000_program.rom", 0x167860, 0x167c50
# EqFuncSel  (CPU 0x48567c50)
.incbin_range "baserom/kn7000_program.rom", 0x167c50, 0x167f94
# EffEditGrid  (CPU 0x48567f94)
.incbin_range "baserom/kn7000_program.rom", 0x167f94, 0x168243
# MulSelExitCatchFunc  (CPU 0x48568243)
.incbin_range "baserom/kn7000_program.rom", 0x168243, 0x168247
# EffAlocGrid  (CPU 0x48568247)
.incbin_range "baserom/kn7000_program.rom", 0x168247, 0x16832f
# AcEffEditGridBoxProc  (CPU 0x4856832f)
.incbin_range "baserom/kn7000_program.rom", 0x16832f, 0x16857a
# EffNamingCheck  (CPU 0x4856857a)
.incbin_range "baserom/kn7000_program.rom", 0x16857a, 0x1685c6
# EffEditTitleFunc  (CPU 0x485685c6)
.incbin_range "baserom/kn7000_program.rom", 0x1685c6, 0x168636
# EQSELTitleFunc  (CPU 0x48568636)
.incbin_range "baserom/kn7000_program.rom", 0x168636, 0x1686a0
# EffEditGrid2  (CPU 0x485686a0)
.incbin_range "baserom/kn7000_program.rom", 0x1686a0, 0x16876a
# AcEffExpUsrProc  (CPU 0x4856876a)
.incbin_range "baserom/kn7000_program.rom", 0x16876a, 0x1688f9
# AcEffOnOffBoxProc  (CPU 0x485688f9)
.incbin_range "baserom/kn7000_program.rom", 0x1688f9, 0x16898e
# AcEffNameProc  (CPU 0x4856898e)
.incbin_range "baserom/kn7000_program.rom", 0x16898e, 0x168b25
# DspDepEditFunc  (CPU 0x48568b25)
.incbin_range "baserom/kn7000_program.rom", 0x168b25, 0x168d3d
# MainChangeReqEQ  (CPU 0x48568d3d)
.incbin_range "baserom/kn7000_program.rom", 0x168d3d, 0x168d41
# EffFilterGrid  (CPU 0x48568d41)
.incbin_range "baserom/kn7000_program.rom", 0x168d41, 0x168d62
# AlocModeToggleFunc  (CPU 0x48568d62)
.incbin_range "baserom/kn7000_program.rom", 0x168d62, 0x169301
# TEffFilter  (CPU 0x48569301)
.incbin_range "baserom/kn7000_program.rom", 0x169301, 0x169357
# FilterTtlScreenProc  (CPU 0x48569357)
.incbin_range "baserom/kn7000_program.rom", 0x169357, 0x169608
# EffDispCatch  (CPU 0x48569608)
.incbin_range "baserom/kn7000_program.rom", 0x169608, 0x16a78b
# AcUnitNameProc  (CPU 0x4856a78b)
.incbin_range "baserom/kn7000_program.rom", 0x16a78b, 0x16a829
# EffAlocCatch  (CPU 0x4856a829)
.incbin_range "baserom/kn7000_program.rom", 0x16a829, 0x16a8eb
# EffDispGrid  (CPU 0x4856a8eb)
.incbin_range "baserom/kn7000_program.rom", 0x16a8eb, 0x16a90d
# EffSysSw  (CPU 0x4856a90d)
.incbin_range "baserom/kn7000_program.rom", 0x16a90d, 0x16a92f
# EffApcSw  (CPU 0x4856a92f)
.incbin_range "baserom/kn7000_program.rom", 0x16a92f, 0x16a986
# VCLSELTitleFunc  (CPU 0x4856a986)
.incbin_range "baserom/kn7000_program.rom", 0x16a986, 0x16abc4
# EffDebugCatch  (CPU 0x4856abc4)
.incbin_range "baserom/kn7000_program.rom", 0x16abc4, 0x16aea8
# AcEffDispGridBoxProc  (CPU 0x4856aea8)
.incbin_range "baserom/kn7000_program.rom", 0x16aea8, 0x16af80
# EffEditUnitName  (CPU 0x4856af80)
.incbin_range "baserom/kn7000_program.rom", 0x16af80, 0x16b107
# EQGainEditCheck  (CPU 0x4856b107)
.incbin_range "baserom/kn7000_program.rom", 0x16b107, 0x16b28e
# EQFcEditCheck  (CPU 0x4856b28e)
.incbin_range "baserom/kn7000_program.rom", 0x16b28e, 0x16b3ca
# AcEQEditBoxProc  (CPU 0x4856b3ca)
.incbin_range "baserom/kn7000_program.rom", 0x16b3ca, 0x16b4fe
# EQQEditCheck  (CPU 0x4856b4fe)
.incbin_range "baserom/kn7000_program.rom", 0x16b4fe, 0x16b586
# MainEffControl  (CPU 0x4856b586)
.incbin_range "baserom/kn7000_program.rom", 0x16b586, 0x16b5ad
# EQFunc  (CPU 0x4856b5ad)
.incbin_range "baserom/kn7000_program.rom", 0x16b5ad, 0x16b5e4
# EQSelFunc  (CPU 0x4856b5e4)
.incbin_range "baserom/kn7000_program.rom", 0x16b5e4, 0x16b8a0
# EQToggleFunc  (CPU 0x4856b8a0)
.incbin_range "baserom/kn7000_program.rom", 0x16b8a0, 0x16b99e
# MULSELTitleFunc  (CPU 0x4856b99e)
.incbin_range "baserom/kn7000_program.rom", 0x16b99e, 0x16c066
# EQOrigFunc  (CPU 0x4856c066)
.incbin_range "baserom/kn7000_program.rom", 0x16c066, 0x16c1c1
# MicSelFuncPage1  (CPU 0x4856c1c1)
.incbin_range "baserom/kn7000_program.rom", 0x16c1c1, 0x16c31d
# MicSelFuncPage2  (CPU 0x4856c31d)
.incbin_range "baserom/kn7000_program.rom", 0x16c31d, 0x16c33d
# MicSelFunc  (CPU 0x4856c33d)
.incbin_range "baserom/kn7000_program.rom", 0x16c33d, 0x16c37a
# TEffAloc  (CPU 0x4856c37a)
.incbin_range "baserom/kn7000_program.rom", 0x16c37a, 0x16c4f9
# MicPresetSelFunc  (CPU 0x4856c4f9)
.incbin_range "baserom/kn7000_program.rom", 0x16c4f9, 0x16c59d
# MicEffEditCheck  (CPU 0x4856c59d)
.incbin_range "baserom/kn7000_program.rom", 0x16c59d, 0x16c641
# MicRevEditCheck  (CPU 0x4856c641)
.incbin_range "baserom/kn7000_program.rom", 0x16c641, 0x16c678
# MicEffToggleFunc  (CPU 0x4856c678)
.incbin_range "baserom/kn7000_program.rom", 0x16c678, 0x16c6af
# MicRevToggleFunc  (CPU 0x4856c6af)
.incbin_range "baserom/kn7000_program.rom", 0x16c6af, 0x16c739
# HarmPartEditCheck  (CPU 0x4856c739)
.incbin_range "baserom/kn7000_program.rom", 0x16c739, 0x16c7f6
# MicEffMuteToggleFunc  (CPU 0x4856c7f6)
.incbin_range "baserom/kn7000_program.rom", 0x16c7f6, 0x16c887
# AcGainBoxProc  (CPU 0x4856c887)
.incbin_range "baserom/kn7000_program.rom", 0x16c887, 0x16cc2a
# AcEffTitleMenuProc  (CPU 0x4856cc2a)
.incbin_range "baserom/kn7000_program.rom", 0x16cc2a, 0x16cd64
# EffEditScreenProc  (CPU 0x4856cd64)
.incbin_range "baserom/kn7000_program.rom", 0x16cd64, 0x16ce98
# EffTtlScreenProc  (CPU 0x4856ce98)
.incbin_range "baserom/kn7000_program.rom", 0x16ce98, 0x16cf25
# EffNameScreenProc  (CPU 0x4856cf25)
.incbin_range "baserom/kn7000_program.rom", 0x16cf25, 0x16d087
# InitializeBlock12  (CPU 0x4856d087)
.incbin_range "baserom/kn7000_program.rom", 0x16d087, 0x16d2c9
# TR12Octave  (CPU 0x4856d2c9)
.incbin_range "baserom/kn7000_program.rom", 0x16d2c9, 0x16d407
# TtChordFinder  (CPU 0x4856d407)
.incbin_range "baserom/kn7000_program.rom", 0x16d407, 0x16d5ad
# TSplitSel  (CPU 0x4856d5ad)
.incbin_range "baserom/kn7000_program.rom", 0x16d5ad, 0x16d5da
# R12OctaveFunc  (CPU 0x4856d5da)
.incbin_range "baserom/kn7000_program.rom", 0x16d5da, 0x16d5fb
# MemoryToggleFunc  (CPU 0x4856d5fb)
.incbin_range "baserom/kn7000_program.rom", 0x16d5fb, 0x16d61c
# OnbassToggleFunc  (CPU 0x4856d61c)
.incbin_range "baserom/kn7000_program.rom", 0x16d61c, 0x16d63d
# IntroToggleFunc  (CPU 0x4856d63d)
.incbin_range "baserom/kn7000_program.rom", 0x16d63d, 0x16d690
# LeftholdToggleFunc  (CPU 0x4856d690)
.incbin_range "baserom/kn7000_program.rom", 0x16d690, 0x16d6b1
# TApcSel  (CPU 0x4856d6b1)
.incbin_range "baserom/kn7000_program.rom", 0x16d6b1, 0x16d6f2
# AcAPCRadioBoxProc  (CPU 0x4856d6f2)
.incbin_range "baserom/kn7000_program.rom", 0x16d6f2, 0x16d98e
# SplitPoint  (CPU 0x4856d98e)
.incbin_range "baserom/kn7000_program.rom", 0x16d98e, 0x16d9a2
# ApcSelFunc  (CPU 0x4856d9a2)
.incbin_range "baserom/kn7000_program.rom", 0x16d9a2, 0x16db86
# StsSplitCheck  (CPU 0x4856db86)
.incbin_range "baserom/kn7000_program.rom", 0x16db86, 0x16dd8a
# APCselect  (CPU 0x4856dd8a)
.incbin_range "baserom/kn7000_program.rom", 0x16dd8a, 0x16de4f
# ChordFinderListen  (CPU 0x4856de4f)
.incbin_range "baserom/kn7000_program.rom", 0x16de4f, 0x16e303
# BitmapKenban  (CPU 0x4856e303)
.incbin_range "baserom/kn7000_program.rom", 0x16e303, 0x16e39f
# ChordFinderROOT  (CPU 0x4856e39f)
.incbin_range "baserom/kn7000_program.rom", 0x16e39f, 0x16e435
# INVERSION  (CPU 0x4856e435)
.incbin_range "baserom/kn7000_program.rom", 0x16e435, 0x16e7bd
# AcChordFinderBoxProc  (CPU 0x4856e7bd)
.incbin_range "baserom/kn7000_program.rom", 0x16e7bd, 0x16e894
# ChordFinderTYPE  (CPU 0x4856e894)
.incbin_range "baserom/kn7000_program.rom", 0x16e894, 0x16e980
# AcRamEditInvBoxProc  (CPU 0x4856e980)
.incbin_range "baserom/kn7000_program.rom", 0x16e980, 0x16eff6
# AcRamEditRoopBoxProc  (CPU 0x4856eff6)
.incbin_range "baserom/kn7000_program.rom", 0x16eff6, 0x16f162
# PsCFInvisibleBoxProc  (CPU 0x4856f162)
.incbin_range "baserom/kn7000_program.rom", 0x16f162, 0x16f1c2
# AcKenbanBitmapProc  (CPU 0x4856f1c2)
.incbin_range "baserom/kn7000_program.rom", 0x16f1c2, 0x16f70a
# ChordFinderStartFunc  (CPU 0x4856f70a)
.incbin_range "baserom/kn7000_program.rom", 0x16f70a, 0x16f798
# OffWaitEditCheck  (CPU 0x4856f798)
.incbin_range "baserom/kn7000_program.rom", 0x16f798, 0x16f826
# On1WaitEditCheck  (CPU 0x4856f826)
.incbin_range "baserom/kn7000_program.rom", 0x16f826, 0x16f8b4
# On2WaitEditCheck  (CPU 0x4856f8b4)
.incbin_range "baserom/kn7000_program.rom", 0x16f8b4, 0x16f942
# On3WaitEditCheck  (CPU 0x4856f942)
.incbin_range "baserom/kn7000_program.rom", 0x16f942, 0x172f46
# InitializeBlock33  (CPU 0x48572f46)
.incbin_range "baserom/kn7000_program.rom", 0x172f46, 0x173712
# AcIntTitleMenuSDProc  (CPU 0x48573712)
.incbin_range "baserom/kn7000_program.rom", 0x173712, 0x1737fa
# AcSDFuncStrBoxProc  (CPU 0x485737fa)
.incbin_range "baserom/kn7000_program.rom", 0x1737fa, 0x173b21
# AcSDFuncListBoxProc  (CPU 0x48573b21)
.incbin_range "baserom/kn7000_program.rom", 0x173b21, 0x173b5f
# SDLyricsBoxProc  (CPU 0x48573b5f)
.incbin_range "baserom/kn7000_program.rom", 0x173b5f, 0x173c3f
# IvSDPlayTimerProc  (CPU 0x48573c3f)
.incbin_range "baserom/kn7000_program.rom", 0x173c3f, 0x173f82
# AcSDTimeStrBoxProc  (CPU 0x48573f82)
.incbin_range "baserom/kn7000_program.rom", 0x173f82, 0x173fae
# AcSDMuteListBoxProc  (CPU 0x48573fae)
.incbin_range "baserom/kn7000_program.rom", 0x173fae, 0x174005
# AcSDStoreArrowProc  (CPU 0x48574005)
.incbin_range "baserom/kn7000_program.rom", 0x174005, 0x174072
# AcFuncOnOffWideESProc  (CPU 0x48574072)
.incbin_range "baserom/kn7000_program.rom", 0x174072, 0x174daf
# SDSoundLyricsTtlFunc  (CPU 0x48574daf)
.incbin_range "baserom/kn7000_program.rom", 0x174daf, 0x174dfe
# GetSDVolumeStrFunc  (CPU 0x48574dfe)
.incbin_range "baserom/kn7000_program.rom", 0x174dfe, 0x174e83
# GetSDAudPlayListNameFunc  (CPU 0x48574e83)
.incbin_range "baserom/kn7000_program.rom", 0x174e83, 0x174f07
# GetSDAudPlaySongNameFunc  (CPU 0x48574f07)
.incbin_range "baserom/kn7000_program.rom", 0x174f07, 0x174f79
# GetSDAudPlayPlayTimeFunc  (CPU 0x48574f79)
.incbin_range "baserom/kn7000_program.rom", 0x174f79, 0x175084
# GetSDAudPlaySongListFunc  (CPU 0x48575084)
.incbin_range "baserom/kn7000_program.rom", 0x175084, 0x1750ff
# GetSDAudPlay_PLAYPAUSEFunc  (CPU 0x485750ff)
.incbin_range "baserom/kn7000_program.rom", 0x1750ff, 0x175191
# GetSDAudPlay_PlayModeFunc  (CPU 0x48575191)
.incbin_range "baserom/kn7000_program.rom", 0x175191, 0x1752b3
# GetSDAudSelListListFunc  (CPU 0x485752b3)
.incbin_range "baserom/kn7000_program.rom", 0x1752b3, 0x1753aa
# GetSDAudSelSongListFunc  (CPU 0x485753aa)
.incbin_range "baserom/kn7000_program.rom", 0x1753aa, 0x17542f
# GetSDSndPlayListNameFunc  (CPU 0x4857542f)
.incbin_range "baserom/kn7000_program.rom", 0x17542f, 0x1754b3
# GetSDSndPlaySongNameFunc  (CPU 0x485754b3)
.incbin_range "baserom/kn7000_program.rom", 0x1754b3, 0x175518
# GetSDSndPlayPlayTimeFunc  (CPU 0x48575518)
.incbin_range "baserom/kn7000_program.rom", 0x175518, 0x175624
# GetSDSndPlay_PlayAsFunc  (CPU 0x48575624)
.incbin_range "baserom/kn7000_program.rom", 0x175624, 0x1756e7
# GetSDSndPlaySongListFunc  (CPU 0x485756e7)
.incbin_range "baserom/kn7000_program.rom", 0x1756e7, 0x175762
# GetSDSndPlay_PLAYPAUSEFunc  (CPU 0x48575762)
.incbin_range "baserom/kn7000_program.rom", 0x175762, 0x1757f4
# GetSDSndPlay_PlayModeFunc  (CPU 0x485757f4)
.incbin_range "baserom/kn7000_program.rom", 0x1757f4, 0x175883
# GetSDSndPlayMuteListFunc  (CPU 0x48575883)
.incbin_range "baserom/kn7000_program.rom", 0x175883, 0x17597a
# GetSDSndSelListListFunc  (CPU 0x4857597a)
.incbin_range "baserom/kn7000_program.rom", 0x17597a, 0x175a47
# GetSDSndEditSrcListNameFunc  (CPU 0x48575a47)
.incbin_range "baserom/kn7000_program.rom", 0x175a47, 0x175a90
# GetSDSndSelSongListFunc  (CPU 0x48575a90)
.incbin_range "baserom/kn7000_program.rom", 0x175a90, 0x175ae0
# GetSDSndEditListNameFunc  (CPU 0x48575ae0)
.incbin_range "baserom/kn7000_program.rom", 0x175ae0, 0x175bc0
# GetSDSndEditDefListFunc  (CPU 0x48575bc0)
.incbin_range "baserom/kn7000_program.rom", 0x175bc0, 0x175ca1
# GetSDSndEditCurListFunc  (CPU 0x48575ca1)
.incbin_range "baserom/kn7000_program.rom", 0x175ca1, 0x175cf6
# GetSDSndLyrSongNameFunc  (CPU 0x48575cf6)
.incbin_range "baserom/kn7000_program.rom", 0x175cf6, 0x175d4b
# GetSDSndLyrLyrNameFunc  (CPU 0x48575d4b)
.incbin_range "baserom/kn7000_program.rom", 0x175d4b, 0x175d9b
# GetSDSndLyrCompNameFunc  (CPU 0x48575d9b)
.incbin_range "baserom/kn7000_program.rom", 0x175d9b, 0x175dfe
# ApSDSndListName_OkSW  (CPU 0x48575dfe)
.incbin_range "baserom/kn7000_program.rom", 0x175dfe, 0x175e12
# SDAreYouSureFunc  (CPU 0x48575e12)
.incbin_range "baserom/kn7000_program.rom", 0x175e12, 0x175e26
# SDAttentionFunc  (CPU 0x48575e26)
.incbin_range "baserom/kn7000_program.rom", 0x175e26, 0x175e3a
# SDEditListChangeTextFunc  (CPU 0x48575e3a)
.incbin_range "baserom/kn7000_program.rom", 0x175e3a, 0x175f66
# SDAudioPlayTtlFunc  (CPU 0x48575f66)
.incbin_range "baserom/kn7000_program.rom", 0x175f66, 0x17601c
# SDAudioListSelTtlFunc  (CPU 0x4857601c)
.incbin_range "baserom/kn7000_program.rom", 0x17601c, 0x176252
# SDSoundPlayTtlFunc  (CPU 0x48576252)
.incbin_range "baserom/kn7000_program.rom", 0x176252, 0x1763c3
# SDSoundListSelTtlFunc  (CPU 0x485763c3)
.incbin_range "baserom/kn7000_program.rom", 0x1763c3, 0x1765d1
# SDSoundListEditTtlFunc  (CPU 0x485765d1)
.incbin_range "baserom/kn7000_program.rom", 0x1765d1, 0x176694
# SDSoundListNameTtlFunc  (CPU 0x48576694)
.incbin_range "baserom/kn7000_program.rom", 0x176694, 0x1767cf
# ApSD_VolumeSW  (CPU 0x485767cf)
.incbin_range "baserom/kn7000_program.rom", 0x1767cf, 0x1767ea
# ApSDAudPlay_PlaySW  (CPU 0x485767ea)
.incbin_range "baserom/kn7000_program.rom", 0x1767ea, 0x176805
# ApSDAudPlay_StopSW  (CPU 0x48576805)
.incbin_range "baserom/kn7000_program.rom", 0x176805, 0x17684a
# ApSDAudPlay_FwdSW  (CPU 0x4857684a)
.incbin_range "baserom/kn7000_program.rom", 0x17684a, 0x176891
# ApSDAudPlay_RewSW  (CPU 0x48576891)
.incbin_range "baserom/kn7000_program.rom", 0x176891, 0x1768a9
# ApSDAudPlay_ModeSW  (CPU 0x485768a9)
.incbin_range "baserom/kn7000_program.rom", 0x1768a9, 0x1768ad
# ApSDAudPlay_SyncSW  (CPU 0x485768ad)
.incbin_range "baserom/kn7000_program.rom", 0x1768ad, 0x1768c5
# ApSDAudListSel_ListSW  (CPU 0x485768c5)
.incbin_range "baserom/kn7000_program.rom", 0x1768c5, 0x1768dd
# ApSDAudListSel_PrevSW  (CPU 0x485768dd)
.incbin_range "baserom/kn7000_program.rom", 0x1768dd, 0x1768f5
# ApSDAudListSel_NextSW  (CPU 0x485768f5)
.incbin_range "baserom/kn7000_program.rom", 0x1768f5, 0x17690d
# ApSDAudListSel_MoreSW  (CPU 0x4857690d)
.incbin_range "baserom/kn7000_program.rom", 0x17690d, 0x176925
# ApSDAudListSel_OkSW  (CPU 0x48576925)
.incbin_range "baserom/kn7000_program.rom", 0x176925, 0x17693d
# ApSDSndPlay_PlaySW  (CPU 0x4857693d)
.incbin_range "baserom/kn7000_program.rom", 0x17693d, 0x176955
# ApSDSndPlay_StopSW  (CPU 0x48576955)
.incbin_range "baserom/kn7000_program.rom", 0x176955, 0x17699c
# ApSDSndPlay_FwdSW  (CPU 0x4857699c)
.incbin_range "baserom/kn7000_program.rom", 0x17699c, 0x1769e3
# ApSDSndPlay_MuteSelSW  (CPU 0x485769e3)
.incbin_range "baserom/kn7000_program.rom", 0x1769e3, 0x1769fb
# ApSDSndPlay_ModeSW  (CPU 0x485769fb)
.incbin_range "baserom/kn7000_program.rom", 0x1769fb, 0x176a13
# ApSDSndPlay_RewSW  (CPU 0x48576a13)
.incbin_range "baserom/kn7000_program.rom", 0x176a13, 0x176a3e
# ApSDSndPlay_ChSelSW  (CPU 0x48576a3e)
.incbin_range "baserom/kn7000_program.rom", 0x176a3e, 0x176a56
# ApSDSndPlay_PlayAsSW  (CPU 0x48576a56)
.incbin_range "baserom/kn7000_program.rom", 0x176a56, 0x176a81
# ApSDSndListSel_ListSW  (CPU 0x48576a81)
.incbin_range "baserom/kn7000_program.rom", 0x176a81, 0x176a99
# ApSDSndListSel_PrevSW  (CPU 0x48576a99)
.incbin_range "baserom/kn7000_program.rom", 0x176a99, 0x176ab1
# ApSDSndListSel_NextSW  (CPU 0x48576ab1)
.incbin_range "baserom/kn7000_program.rom", 0x176ab1, 0x176adc
# ApSDSndListSel_MoreSW  (CPU 0x48576adc)
.incbin_range "baserom/kn7000_program.rom", 0x176adc, 0x176af4
# ApSDSndListEdit_DefLsUpDownSW  (CPU 0x48576af4)
.incbin_range "baserom/kn7000_program.rom", 0x176af4, 0x176b1f
# ApSDSndListEdit_PrevSW  (CPU 0x48576b1f)
.incbin_range "baserom/kn7000_program.rom", 0x176b1f, 0x176b4a
# ApSDSndListSel_OkSW  (CPU 0x48576b4a)
.incbin_range "baserom/kn7000_program.rom", 0x176b4a, 0x176b75
# ApSDSndListEdit_NextSW  (CPU 0x48576b75)
.incbin_range "baserom/kn7000_program.rom", 0x176b75, 0x176ba0
# ApSDSndListEdit_DefUpDownSW  (CPU 0x48576ba0)
.incbin_range "baserom/kn7000_program.rom", 0x176ba0, 0x176bb8
# ApSDSndListEdit_StoreSW  (CPU 0x48576bb8)
.incbin_range "baserom/kn7000_program.rom", 0x176bb8, 0x176be3
# ApSDSndListEdit_CurLsUpDownSW  (CPU 0x48576be3)
.incbin_range "baserom/kn7000_program.rom", 0x176be3, 0x176c0e
# ApSDSndListEdit_CurUpDownSW  (CPU 0x48576c0e)
.incbin_range "baserom/kn7000_program.rom", 0x176c0e, 0x176c39
# ApSDSndListEdit_MoveUpDownSW  (CPU 0x48576c39)
.incbin_range "baserom/kn7000_program.rom", 0x176c39, 0x176c51
# ApSDSndListEdit_DelSW  (CPU 0x48576c51)
.incbin_range "baserom/kn7000_program.rom", 0x176c51, 0x176c69
# ApSDSndListEdit_OkSW  (CPU 0x48576c69)
.incbin_range "baserom/kn7000_program.rom", 0x176c69, 0x176c81
# ApSDSndListEdit_NameSW  (CPU 0x48576c81)
.incbin_range "baserom/kn7000_program.rom", 0x176c81, 0x176c99
# ApSDSndListEdit_NewSW  (CPU 0x48576c99)
.incbin_range "baserom/kn7000_program.rom", 0x176c99, 0x176cb1
# ApSDSndListEdit_LsDelSW  (CPU 0x48576cb1)
.incbin_range "baserom/kn7000_program.rom", 0x176cb1, 0x176ce3
# ApSDSndListEdit_DelWinYesSW  (CPU 0x48576ce3)
.incbin_range "baserom/kn7000_program.rom", 0x176ce3, 0x176d27
# ApSDSndListEdit_DelWinNoSW  (CPU 0x48576d27)
.incbin_range "baserom/kn7000_program.rom", 0x176d27, 0x176d59
# ApSDSndListEdit_SureWinYesSW  (CPU 0x48576d59)
.incbin_range "baserom/kn7000_program.rom", 0x176d59, 0x176d9d
# ApSDSndListEdit_SureWinNoSW  (CPU 0x48576d9d)
.incbin_range "baserom/kn7000_program.rom", 0x176d9d, 0x176dcf
# ApSDSndListEdit_SureWin2YesSW  (CPU 0x48576dcf)
.incbin_range "baserom/kn7000_program.rom", 0x176dcf, 0x176e13
# ApSDSndListEdit_SureWin2NoSW  (CPU 0x48576e13)
.incbin_range "baserom/kn7000_program.rom", 0x176e13, 0x176e4e
# ApSDSndListName_IvNaming  (CPU 0x48576e4e)
.incbin_range "baserom/kn7000_program.rom", 0x176e4e, 0x176e84
# GetSDSndLyrArtNameFunc  (CPU 0x48576e84)
.incbin_range "baserom/kn7000_program.rom", 0x176e84, 0x176eab
# MainSD_VolumeSW  (CPU 0x48576eab)
.incbin_range "baserom/kn7000_program.rom", 0x176eab, 0x176f08
# MainSDAudPlay_PlaySW  (CPU 0x48576f08)
.incbin_range "baserom/kn7000_program.rom", 0x176f08, 0x176f65
# MainSDAudPlay_StopSW  (CPU 0x48576f65)
.incbin_range "baserom/kn7000_program.rom", 0x176f65, 0x17701b
# MainSDAudPlay_FwdSW  (CPU 0x4857701b)
.incbin_range "baserom/kn7000_program.rom", 0x17701b, 0x1770d1
# MainSDAudPlay_RewSW  (CPU 0x485770d1)
.incbin_range "baserom/kn7000_program.rom", 0x1770d1, 0x1770f7
# MainSDAudPlay_ModeSW  (CPU 0x485770f7)
.incbin_range "baserom/kn7000_program.rom", 0x1770f7, 0x17716e
# MainSDAudListSel_ListSW  (CPU 0x4857716e)
.incbin_range "baserom/kn7000_program.rom", 0x17716e, 0x1771e8
# MainSDAudListSel_PrevSW  (CPU 0x485771e8)
.incbin_range "baserom/kn7000_program.rom", 0x1771e8, 0x177280
# MainSDAudListSel_NextSW  (CPU 0x48577280)
.incbin_range "baserom/kn7000_program.rom", 0x177280, 0x1772d0
# MainSDAudListSel_MoreSW  (CPU 0x485772d0)
.incbin_range "baserom/kn7000_program.rom", 0x1772d0, 0x1772f2
# MainSDAudListSel_OkSW  (CPU 0x485772f2)
.incbin_range "baserom/kn7000_program.rom", 0x1772f2, 0x177337
# MainSDSndPlay_PlaySW  (CPU 0x48577337)
.incbin_range "baserom/kn7000_program.rom", 0x177337, 0x177399
# MainSDSndPlay_StopSW  (CPU 0x48577399)
.incbin_range "baserom/kn7000_program.rom", 0x177399, 0x177461
# MainSDSndPlay_FwdSW  (CPU 0x48577461)
.incbin_range "baserom/kn7000_program.rom", 0x177461, 0x177529
# MainSDSndPlay_MuteSelSW  (CPU 0x48577529)
.incbin_range "baserom/kn7000_program.rom", 0x177529, 0x177548
# MainSDSndPlay_ModeSW  (CPU 0x48577548)
.incbin_range "baserom/kn7000_program.rom", 0x177548, 0x177567
# MainSDSndPlay_RewSW  (CPU 0x48577567)
.incbin_range "baserom/kn7000_program.rom", 0x177567, 0x17759f
# MainSDSndPlay_ChSelSW  (CPU 0x4857759f)
.incbin_range "baserom/kn7000_program.rom", 0x17759f, 0x1775df
# MainSDSndPlay_PlayAsSW  (CPU 0x485775df)
.incbin_range "baserom/kn7000_program.rom", 0x1775df, 0x17766c
# MainSDSndListSel_ListSW  (CPU 0x4857766c)
.incbin_range "baserom/kn7000_program.rom", 0x17766c, 0x1776f9
# MainSDSndListSel_PrevSW  (CPU 0x485776f9)
.incbin_range "baserom/kn7000_program.rom", 0x1776f9, 0x1777a6
# MainSDSndListSel_NextSW  (CPU 0x485777a6)
.incbin_range "baserom/kn7000_program.rom", 0x1777a6, 0x1777eb
# MainSDSndListSel_MoreSW  (CPU 0x485777eb)
.incbin_range "baserom/kn7000_program.rom", 0x1777eb, 0x17780d
# MainSDSndListEdit_DefLsUpDownSW  (CPU 0x4857780d)
.incbin_range "baserom/kn7000_program.rom", 0x17780d, 0x177848
# MainSDSndListEdit_PrevSW  (CPU 0x48577848)
.incbin_range "baserom/kn7000_program.rom", 0x177848, 0x17788d
# MainSDSndListSel_OkSW  (CPU 0x4857788d)
.incbin_range "baserom/kn7000_program.rom", 0x17788d, 0x1778f3
# MainSDSndListEdit_NextSW  (CPU 0x485778f3)
.incbin_range "baserom/kn7000_program.rom", 0x1778f3, 0x177939
# MainSDSndListEdit_DefUpDownSW  (CPU 0x48577939)
.incbin_range "baserom/kn7000_program.rom", 0x177939, 0x177980
# MainSDSndListEdit_StoreSW  (CPU 0x48577980)
.incbin_range "baserom/kn7000_program.rom", 0x177980, 0x177a34
# MainSDSndListEdit_CurLsUpDownSW  (CPU 0x48577a34)
.incbin_range "baserom/kn7000_program.rom", 0x177a34, 0x177a7f
# MainSDSndListEdit_CurUpDownSW  (CPU 0x48577a7f)
.incbin_range "baserom/kn7000_program.rom", 0x177a7f, 0x177ace
# MainSDSndListEdit_MoveUpDownSW  (CPU 0x48577ace)
.incbin_range "baserom/kn7000_program.rom", 0x177ace, 0x177b24
# MainSDSndListEdit_DelSW  (CPU 0x48577b24)
.incbin_range "baserom/kn7000_program.rom", 0x177b24, 0x177c0e
# MainSDSndListEdit_OkSW  (CPU 0x48577c0e)
.incbin_range "baserom/kn7000_program.rom", 0x177c0e, 0x177c12
# MainSDSndListEdit_NameSW  (CPU 0x48577c12)
.incbin_range "baserom/kn7000_program.rom", 0x177c12, 0x177c78
# MainSDSndListEdit_NewSW  (CPU 0x48577c78)
.incbin_range "baserom/kn7000_program.rom", 0x177c78, 0x177c95
# MainSDSndListEdit_LsDelSW  (CPU 0x48577c95)
.incbin_range "baserom/kn7000_program.rom", 0x177c95, 0x177d6a
# MainSDSndListEdit_DelWinYesSW  (CPU 0x48577d6a)
.incbin_range "baserom/kn7000_program.rom", 0x177d6a, 0x177d6e
# MainSDSndListEdit_DelWinNoSW  (CPU 0x48577d6e)
.incbin_range "baserom/kn7000_program.rom", 0x177d6e, 0x177db4
# MainSDSndListEdit_SureWinYesSW  (CPU 0x48577db4)
.incbin_range "baserom/kn7000_program.rom", 0x177db4, 0x177db8
# MainSDSndListEdit_SureWinNoSW  (CPU 0x48577db8)
.incbin_range "baserom/kn7000_program.rom", 0x177db8, 0x177df2
# MainSDSndListEdit_SureWin2YesSW  (CPU 0x48577df2)
.incbin_range "baserom/kn7000_program.rom", 0x177df2, 0x177df6
# MainSDSndListEdit_SureWin2NoSW  (CPU 0x48577df6)
.incbin_range "baserom/kn7000_program.rom", 0x177df6, 0x177e2d
# MainSDSndListName_IvNaming  (CPU 0x48577e2d)
.incbin_range "baserom/kn7000_program.rom", 0x177e2d, 0x177e54
# MainSDSndListName_OkSW  (CPU 0x48577e54)
.incbin_range "baserom/kn7000_program.rom", 0x177e54, 0x177e60
# MainSD_LyricsCharaReq  (CPU 0x48577e60)
.incbin_range "baserom/kn7000_program.rom", 0x177e60, 0x17dd90
# InitializeBlock34  (CPU 0x4857dd90)
.incbin_range "baserom/kn7000_program.rom", 0x17dd90, 0x17e852
# AcSswScreenProc  (CPU 0x4857e852)
.incbin_range "baserom/kn7000_program.rom", 0x17e852, 0x17e8d4
# AcSswMemBoxProc  (CPU 0x4857e8d4)
.incbin_range "baserom/kn7000_program.rom", 0x17e8d4, 0x17e942
# AcSswImgLoadProc  (CPU 0x4857e942)
.incbin_range "baserom/kn7000_program.rom", 0x17e942, 0x17e987
# AcSswImgRenameProc  (CPU 0x4857e987)
.incbin_range "baserom/kn7000_program.rom", 0x17e987, 0x181ec1
# InitializeBlock14  (CPU 0x48581ec1)
.incbin_range "baserom/kn7000_program.rom", 0x181ec1, 0x1822da
# AcHelpWindowPageProc  (CPU 0x485822da)
.incbin_range "baserom/kn7000_program.rom", 0x1822da, 0x18239d
# AcIndexWideToggleProc2  (CPU 0x4858239d)
.incbin_range "baserom/kn7000_program.rom", 0x18239d, 0x1824c1
# LangSetFlashFunc2  (CPU 0x485824c1)
.incbin_range "baserom/kn7000_program.rom", 0x1824c1, 0x182506
# HelpAPCMENUTitleFunc  (CPU 0x48582506)
.incbin_range "baserom/kn7000_program.rom", 0x182506, 0x182544
# HelpTitleFunc  (CPU 0x48582544)
.incbin_range "baserom/kn7000_program.rom", 0x182544, 0x182582
# HelpPRGMENUTitleFunc  (CPU 0x48582582)
.incbin_range "baserom/kn7000_program.rom", 0x182582, 0x18275c
# AcHelpTitleBoxProc  (CPU 0x4858275c)
.incbin_range "baserom/kn7000_program.rom", 0x18275c, 0x1829cb
# LangSetChkMain2  (CPU 0x485829cb)
.incbin_range "baserom/kn7000_program.rom", 0x1829cb, 0x182a07
# RhyStopFunc  (CPU 0x48582a07)
.incbin_range "baserom/kn7000_program.rom", 0x182a07, 0x183606
# InitializeBlock39  (CPU 0x48583606)
.incbin_range "baserom/kn7000_program.rom", 0x183606, 0x1844eb
# InitializeBlock40  (CPU 0x485844eb)
.incbin_range "baserom/kn7000_program.rom", 0x1844eb, 0x186000

# ---- data / resources region ----
.incbin_range "baserom/kn7000_program.rom", 0x186000, 0x32573C

# ---- display palette (256-entry 0x00RRGGBB CLUT + a themed sub-range) ----
display_palette:
    .long 0x00000000, 0x00000080, 0x00008000, 0x00008080, 0x00800000, 0x00800080, 0x00808000, 0x00808080   # idx   0
    .long 0x00303030, 0x000080FF, 0x000048FF, 0x00004080, 0x0038FF68, 0x00000000, 0x00C8C8C8, 0x00808080   # idx   8
    .long 0x000048FF, 0x000048FF, 0x00000000, 0x0060FFFF, 0x00FFFF90, 0x00FF90FF, 0x0060FF60, 0x00800000   # idx  16
    .long 0x00808080, 0x0000FFFF, 0x000048FF, 0x0000FFFF, 0x000048FF, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx  24
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx  32
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx  40
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx  48
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx  56
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx  64
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx  72
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx  80
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx  88
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx  96
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 104
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 112
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 120
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 128
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 136
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 144
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 152
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 160
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 168
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 176
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 184
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 192
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 200
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 208
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 216
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 224
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80   # idx 232
    .long 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x0080FF80, 0x00808080, 0x00000000, 0x00C0FFC0, 0x00408040   # idx 240
    .long 0x00585858, 0x000000FF, 0x0000FF00, 0x0000FFFF, 0x00FF0000, 0x00FF00FF, 0x00FFFF00, 0x00C8C8C8   # idx 248
    .long 0x00FF0000, 0x00FF6060, 0x00FF6060, 0x00FF6060, 0x00FFA0A0, 0x00FF6060, 0x00FF6060, 0x00FFA0A0   # idx 256
    .long 0x00FF0000, 0x00FF6060, 0x00FF6060, 0x00FF6060, 0x00FF0000, 0x00FFFFFF, 0x00FF0000, 0x00FF0000   # idx 264
    .long 0x00FFFFFF, 0x00FF0000, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FF0000   # idx 272
    .long 0x00FFA0A0, 0x00FFFFFF, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 280
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 288
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 296
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 304
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 312
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 320
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 328
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 336
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 344
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 352
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 360
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 368
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 376
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 384
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 392
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 400
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 408
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 416
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 424
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 432
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 440
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 448
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 456
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 464
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 472
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 480
    .long 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0, 0x00FFA0A0   # idx 488
    .long 0x00FF6060, 0x00FF6060, 0x00FF6060, 0x00FF6060, 0x00FF6060, 0x00FF0000, 0x00FF0000, 0x00FF0000   # idx 496
    .long 0x00FF6060, 0x00FF6060, 0x00FFA0A0, 0x00FFA0A0, 0x00FF6060, 0x00FF6060, 0x00FF6060, 0x00FFFFFF   # idx 504
.org 0x325F3C
.incbin_range "baserom/kn7000_program.rom", 0x32573C + 0x800, 0x3B8000

# ---- code region 2 (MILK MN10300 kernel + zlib 1.0.4) ----
.incbin_range "baserom/kn7000_program.rom", 0x3B8000, 0x3F6F01

.org 0x3F6F01   # end of image
