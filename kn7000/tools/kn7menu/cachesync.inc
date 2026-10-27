# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# cachesync.inc -- CacheSync, included by menu.s and tramp.s: the data cache written back to RAM and invalidated, and
# the instruction cache invalidated, as program 893 does it (its routines at 0x48407B..: an instruction cache off with
# CHCTR (0x20000070) bit 0, waited for on bit 2, invalidated with bit 4, on again; and func_48407C39: the data cache off
# with bit 1, waited for on bit 3, each line of both ways written back by reading the purge window 0x28400000 and
# 0x28401000 at 16-byte steps (unless it writes through, bit 6, or a way is locked, bits 12 and 13), invalidated with
# bit 5, on again), with interrupts off: while the data cache is off, a handler would read RAM that its dirty lines
# have not reached. It replaces the sled of nops run twice after 64 KB of program flash were read, which on the
# owner's unit once left a line of the Pinball port's sled in the data cache, and the CPU fetched what RAM held
# there before (Pinball notes/session-2026-10-27, "The caches").

CacheSync:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     psw, d0
    mov     d0, a3                  # a3 = the PSW, interrupts as they were
    and     0xf7ff, psw
    nop
    nop
    mov     0x20000070, a2
    movhu   (a2), d2                # d2 = CHCTR
    btst    0x02, d2
    beq     csy_i
    mov     d2, d3
    and     0xfffd, d3              # the data cache off
    mov     d3, (a2)
    mov     100000, d1
csy_dw:
    movhu   (a2), d0
    btst    0x08, d0
    beq     csy_dp
    add     -1, d1
    bne     csy_dw
csy_dp:
    btst    0x40, d2
    bne     csy_dinv
    btst    0x1000, d2
    bne     csy_w1
    mov     0x28400000, a0          # way 0 written back
    mov     0x80, d1
csy_p0:
    mov     (a0), d0
    add     16, a0
    add     -1, d1
    bne     csy_p0
csy_w1:
    btst    0x2000, d2
    bne     csy_dinv
    mov     0x28401000, a0          # way 1
    mov     0x80, d1
csy_p1:
    mov     (a0), d0
    add     16, a0
    add     -1, d1
    bne     csy_p1
csy_dinv:
    or      0x20, d3                # invalidated, on
    mov     d3, (a2)
    or      0x02, d3
    movhu   d3, (a2)
csy_i:
    movhu   (a2), d2
    btst    0x01, d2
    beq     csy_done
    mov     d2, d3
    and     0xfffe, d3              # the instruction cache off
    mov     d3, (a2)
    mov     100000, d1
csy_iw:
    movhu   (a2), d0
    btst    0x04, d0
    beq     csy_iinv
    add     -1, d1
    bne     csy_iw
csy_iinv:
    or      0x10, d3                # invalidated, on
    mov     d3, (a2)
    or      0x01, d3
    movhu   d3, (a2)
csy_done:
    mov     a3, d0
    mov     d0, psw
    nop
    nop
    ret     [d2,d3,a2,a3], 0x30
