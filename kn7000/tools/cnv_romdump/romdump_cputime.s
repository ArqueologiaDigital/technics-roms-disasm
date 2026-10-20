# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# romdump_cputime.s -- pass 9 (OPT_CPUTIME): how fast does the KN7000's MN10300 (an MN103002A, AM31 core) run, and
# how long does each kind of memory access take? Read only, apart from the probe's own scratch RAM and the LCD
# (the same value written back). Included by romdump.s only when it is assembled with -D CPUTIME (Makefile:
# build/cputime/KN7APP.BIN), so every other build keeps its bytes. README.md, "Pass 9"; the decoder is
# check_cpu_probe.py.
#
# The clock. The firmware's 1 kHz tick is timer 4 (TM4BR 0x7D0, TM4MD 0x81: README "Pass 8"); its counter TM4BC
# (0x340010A0) counts down from 2000 to 0 at 2 MHz. Each run of a test reads TM4BC, calls the test routine
# (`calls`), and reads TM4BC again; the counts between the two reads, modulo 2001, are its time. Every run is kept
# well under 1 ms (2001 counts), so at most one reload falls inside it. The millisecond counter is read just
# before and just after, for the decoder's sanity check.
#
# A test is a routine that repeats its body N times: K copies of what is measured, then `add -1, d0; bne`. The
# null test (a bare `rets`) gives the harness's own time and the empty loop the loop's; the decoder subtracts
# them (or the time of a reference test with the same body less what is measured). Each test runs CT_R times in a
# row; the decoder keeps the runs no interrupt fell into (the smallest ones) and the spread.
#
# CPUTIME.BIN, CT_CHUNKS chunks of 32 KB; each is one pass over every test, measured in a converter call of its
# own (well under a second), then written by the dumper's own file writer (DumpStep):
#   0x000 header (CT_H_*), 0x100 the register snapshot (address, width, value), 0x200 the test table as run
#   (CT_ENT bytes per test: tag, routine, N, a0, a1), CT_RES the runs (CT_RUN bytes each: TM4BC before, TM4BC
#   after, ms before, ms after, low 16 bits each).
#
# What it reads: bus controller and cache control registers, timer 4, G17ICR, the board strap at 0x98070000 (all
# read by the firmware itself), and memory every earlier pass read: work RAM (0x50xxxxxx and its uncached view
# 0x90xxxxxx), the program and table flash, IC18, the library RAM, IC21 (0x56800000 and 0x96800000), IC19, IC23
# through 0x84000000 and the LCD frame. What it writes: its own scratch (CT_SCR, 64 KB inside the converter area,
# through both views), the stack, and LCD pixels with the value they already hold. Nothing else: no IC23, no
# DSP/TG/FDC/SD/GPIO port, no flash, no timer or bus or cache register.
#
# The flash routine. The fetch tests call a firmware routine that only computes (registers in, registers out):
# 941 0x48471E64, 893 0x48471D35, a chain of compares on d0. CtFind finds it by its bytes, which are those of
# CtTwin, an assembled copy of it here (find_cpu.py checks every build); not found exactly once, the tests that
# call it are skipped (CT_NOLEAF).

.equ CT_CHUNKS,     4               # chunks: passes over the test table
.equ CT_LEN,        CT_CHUNKS*0x8000
.equ CT_R,          16              # runs of each test per chunk
.equ CT_RUN,        8               # bytes per run: u16 TM4BC before, after; u16 ms before, after
.equ CT_ENT,        20              # bytes per test entry: tag (4 ASCII), routine, N, a0, a1
.equ CT_TAB,        0x200           # the test table as run, in each chunk
.equ CT_MAXT,       128             # tests at most (CT_RES is placed for it)
.equ CT_RES,        CT_TAB+CT_MAXT*CT_ENT
.equ CT_CAP,        3000            # ms: a chunk that takes longer stops measuring (CT_CAPPED)
.equ CT_CLKSPIN,    2000            # delay-loop turns between the two reads of the clock check (about 250 us)
.equ CT_SETTLE,     40              # ms of pause at the start of a chunk (a frame-polling test rig arms its taps)
.equ CT_LEAF,       1               # a1 = CT_LEAF in a test entry: the firmware routine CtFind found
.equ CT_SCR,        0x502D0000      # 64 KB of the converter area nothing else uses: the stores' scratch
.equ CT_UNC,        0x40000000      # the uncached view of external memory is 0x40000000 higher
.equ CT_LCD,        FB+232*FB_STRIDE  # LCD row 232 (of 240): the LCD reads, and stores of the same value
.equ TM4MD,         0x34001080      # timer 4 (README "Pass 8"): mode, 8 bits
.equ TM4BR,         0x34001090      #   reload, 16 bits
.equ TM4BC,         0x340010A0      #   counter, 16 bits, read only
.equ CHCTR,         0x20000070      # the cache control register (the firmware: 0x30, then 3, then | 0x80 at boot)
.equ STRAP,         0x98070000      # the board strap: bits 1, 2 pick the bus set-up, bits 11:10 the hardware subtype
.equ CT_PATLEN,     CtTwinEnd-CtTwinPre

# status bits (header +0x08)
.equ CT_NOCLOCK,    1               # TM4BC did not move: nothing was timed
.equ CT_NOLEAF,     2               # the firmware routine was not found exactly once: its tests were skipped
.equ CT_CAPPED,     4               # the chunk ran past CT_CAP ms: the tests after that were skipped
.equ CT_NOMS,       8               # no millisecond counter: the runs' ms fields are 0

.equ V_CTENT,       VARS+0x220      # CtRun: the test entry
.equ V_CTOUT,       VARS+0x224      #   where its next run record goes
.equ V_CTRUN,       VARS+0x228      #   runs done
.equ V_CTMS0,       VARS+0x22C      #   ms before this run
.equ V_CTA1,        VARS+0x230      #   a1 for this test (CT_LEAF resolved)
.equ V_CTLEAF,      VARS+0x234      # CtFind: the firmware routine's entry, or 0
.equ V_CTHITS,      VARS+0x238      #   how often its bytes were found
.equ V_CTCNT,       VARS+0x23C      #   bytes left to compare
.equ V_CTSTAT,      VARS+0x240      # this chunk's status (CT_*)
.equ V_CTMSA,       VARS+0x244      # ms at the start of this chunk
.equ V_CTBUSY,      VARS+0x248      # 1 while a chunk is being measured (test/cpu_tap.lua checks writes then)
.equ V_CTDONE,      VARS+0x24C      # tests run in this chunk
.equ V_CTRES,       VARS+0x250      # where the next test's runs go

# ---- the harness -------------------------------------------------------------------------------------------
# CtRun(a2 = test entry): CT_R runs, recorded from V_CTRES on. The routine is entered with `calls` and d0 = N,
# a0 = the entry's a0, a1 = its a1; it may change d0-d2, a0-a3 and MDR, but not d3 (the first TM4BC read) or sp.
CtRun:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a2, (V_CTENT)
    mov     (V_CTRES), d0
    mov     d0, (V_CTOUT)
    mov     (16, a2), d0
    cmp     CT_LEAF, d0
    bne     ctr_a1
    mov     (V_CTLEAF), d0          # the firmware routine; not found: the test is skipped, its runs stay 0
    cmp     0, d0
    bne     ctr_a1
    mov     CT_NOLEAF, d0
    call    CtStat, 0, 0
    bra     ctr_ret
ctr_a1:
    mov     d0, (V_CTA1)
    clr     d0
    mov     d0, (V_CTRUN)
ctr_run:
    mov     (V_CTENT), a2
    call    MsNow, 0, 0
    mov     d0, (V_CTMS0)
    mov     (4, a2), a3
    mov     (8, a2), d0
    mov     (12, a2), a0
    mov     (V_CTA1), a1
    movhu   (TM4BC), d3             # the run: TM4BC, the routine, TM4BC
    calls   (a3)
    movhu   (TM4BC), d2
    call    MsNow, 0, 0
    mov     (V_CTOUT), a3
    movhu   d3, (a3)
    movhu   d2, (2, a3)
    movhu   d0, (6, a3)
    mov     (V_CTMS0), d0
    movhu   d0, (4, a3)
    add     CT_RUN, a3
    mov     a3, (V_CTOUT)
    mov     (V_CTRUN), d0
    inc     d0
    mov     d0, (V_CTRUN)
    cmp     CT_R, d0
    bcs     ctr_run
ctr_ret:
    ret     [d2,d3,a2,a3], 0x30

CtStat:                             # leaf: V_CTSTAT |= d0
    mov     (V_CTSTAT), d1
    or      d1, d0
    mov     d0, (V_CTSTAT)
    rets

# CtFind: the firmware routine the fetch tests call, by the bytes of CtTwinPre..CtTwinEnd (the end of the
# routine before it, and itself) in the program flash 0x48400000-0x487FFFFF: V_CTLEAF = its entry when they are
# there exactly once, else 0.
CtFind:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    clr     d0
    mov     d0, (V_CTLEAF)
    mov     d0, (V_CTHITS)
    mov     0x48400000, a2
    mov     0x48800000-CT_PATLEN, d2
    mov     CtTwinPre, a3
    movbu   (a3), d3
ctf_next:
    cmp     d2, a2
    bcc     ctf_done
    movbu   (a2), d0
    inc     a2
    cmp     d3, d0
    bne     ctf_next
    mov     a2, a0                  # the first byte matched at a2 - 1: the rest
    mov     a3, a1
    inc     a1
    mov     CT_PATLEN-1, d0
    mov     d0, (V_CTCNT)
ctf_cmp:
    movbu   (a0), d0
    movbu   (a1), d1
    cmp     d1, d0
    bne     ctf_next
    inc     a0
    inc     a1
    mov     (V_CTCNT), d0
    add     -1, d0
    mov     d0, (V_CTCNT)
    bne     ctf_cmp
    mov     (V_CTHITS), d0
    inc     d0
    mov     d0, (V_CTHITS)
    cmp     1, d0
    bne     ctf_next
    mov     a2, d0
    add     CtTwin-CtTwinPre-1, d0  # the entry: past the end of the routine before it
    mov     d0, (V_CTLEAF)
    bra     ctf_next
ctf_done:
    mov     (V_CTHITS), d0
    cmp     1, d0
    beq     ctf_ret
    clr     d0
    mov     d0, (V_CTLEAF)
ctf_ret:
    ret     [d2,d3,a2,a3], 0x30

# ---- one chunk ---------------------------------------------------------------------------------------------
# CpuTimeFill(a0 = the file's record): BUF = the chunk at V_POS, measured now.
#   0x00 "CPUTIME" + the chunk's digit, 0x08 status (CT_*), 0x0C ms at start, 0x10 ms at end, 0x14 the chunk,
#   0x18 tests in the table, 0x1C CT_R, 0x20 CT_RUN, 0x24 CT_TAB, 0x28 CT_RES, 0x2C CT_ENT, 0x30 CT_CHUNKS,
#   0x34/0x38 TM4BC before/after the clock check, 0x3C the ms counter's address, 0x40 the firmware routine's entry
#   (0 = not found), 0x44 how often its bytes were found, 0x48 CtTwin, 0x4C CtTests, 0x50 CT_SCR, 0x54 CT_LCD,
#   0x58 CT_CLKSPIN, 0x5C tests run, 0x60 CT_CAP, 0x64 sp in CpuTimeFill, 0x68 APP_OPTIONS, 0x6C PROGRAM build,
#   0x70 TABLE build, 0x74 what the loader found, 0x78 release byte, 0x7C CpuTimeFill.
#   0x100 the register snapshot (CtRegs), 0x200 the tests as run, CT_RES the runs.
CpuTimeFill:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     BUF, a0                 # zero it: what is not measured stays 0
    mov     CHUNK/4, d1
    clr     d0
cf_zero:
    mov     d0, (a0)
    add     4, a0
    add     -1, d1
    bne     cf_zero
    mov     d0, (V_CTSTAT)
    mov     d0, (V_CTDONE)
    mov     1, d0                   # measuring (test/cpu_tap.lua watches it)
    mov     d0, (V_CTBUSY)
    mov     BUF, a2
    mov     0x54555043, d0          # "CPUT"
    mov     d0, (a2)
    mov     (V_POS), d2
    lsr     15, d2                  # the chunk
    mov     d2, (0x14, a2)
    mov     d2, d0
    asl     24, d0
    mov     0x30454D49, d1          # "IME0" + the chunk
    add     d1, d0
    mov     d0, (4, a2)
    call    MsNow, 0, 0
    mov     d0, (0x0C, a2)
    mov     d0, (V_CTMSA)
    mov     (CtNTests), d0
    mov     d0, (0x18, a2)
    mov     CT_R, d0
    mov     d0, (0x1C, a2)
    mov     CT_RUN, d0
    mov     d0, (0x20, a2)
    mov     CT_TAB, d0
    mov     d0, (0x24, a2)
    mov     CT_RES, d0
    mov     d0, (0x28, a2)
    mov     CT_ENT, d0
    mov     d0, (0x2C, a2)
    mov     CT_CHUNKS, d0
    mov     d0, (0x30, a2)
    mov     (SVC+SV_MSCOUNT), d0
    mov     d0, (0x3C, a2)
    cmp     0, d0
    bne     cf_ms
    mov     CT_NOMS, d0
    call    CtStat, 0, 0
cf_ms:
    mov     (V_CTLEAF), d0
    mov     d0, (0x40, a2)
    mov     (V_CTHITS), d0
    mov     d0, (0x44, a2)
    mov     CtTwin, d0
    mov     d0, (0x48, a2)
    mov     CtTests, d0
    mov     d0, (0x4C, a2)
    mov     CT_SCR, d0
    mov     d0, (0x50, a2)
    mov     CT_LCD, d0
    mov     d0, (0x54, a2)
    mov     CT_CLKSPIN, d0
    mov     d0, (0x58, a2)
    mov     CT_CAP, d0
    mov     d0, (0x60, a2)
    mov     sp, a0
    mov     a0, (0x64, a2)
    mov     (APP_OPTIONS), d0
    mov     d0, (0x68, a2)
    mov     (SVC+SV_BUILD), d0
    mov     d0, (0x6C, a2)
    mov     (SVC+SV_TBUILD), d0
    mov     d0, (0x70, a2)
    mov     (SVC+SV_FOUND), d0
    mov     d0, (0x74, a2)
    mov     (SVC+SV_RELEASE), d0
    mov     d0, (0x78, a2)
    mov     CpuTimeFill, d0
    mov     d0, (0x7C, a2)
    call    CtRegs, 0, 0            # the register snapshot: plain reads
    mov     (SVC+SV_MSCOUNT), d0
    cmp     0, d0
    beq     cf_clock
    call    MsNow, 0, 0             # a pause of CT_SETTLE ms before the tests, so that a test rig polling once
    add     CT_SETTLE, d0           # per video frame (test/cpu_tap.lua) sees V_CTBUSY first; bounded
    mov     d0, d2
    mov     WAIT_SPINS, d3
cf_settle:
    call    MsNow, 0, 0
    sub     d2, d0
    cmp     0, d0
    bge     cf_clock
    add     -1, d3
    bne     cf_settle
cf_clock:
    movhu   (TM4BC), d0             # the clock check: does TM4BC move?
    mov     d0, (0x34, a2)
    mov     CT_CLKSPIN, d0
cf_spin:
    add     -1, d0
    bne     cf_spin
    movhu   (TM4BC), d0
    mov     d0, (0x38, a2)
    mov     (0x34, a2), d1
    cmp     d1, d0
    bne     cf_tests
    mov     CT_NOCLOCK, d0
    call    CtStat, 0, 0
    bra     cf_end
cf_tests:
    mov     BUF+CT_RES, d0
    mov     d0, (V_CTRES)
    mov     CtTests, a2             # the entry
    mov     BUF+CT_TAB, a3          # its copy in the chunk
    clr     d2                      # tests run
cf_test:
    mov     (a2), d0
    mov     d0, (a3)
    mov     (4, a2), d0
    mov     d0, (4, a3)
    mov     (8, a2), d0
    mov     d0, (8, a3)
    mov     (12, a2), d0
    mov     d0, (12, a3)
    mov     (16, a2), d0
    cmp     CT_LEAF, d0
    bne     cf_a1
    mov     (V_CTLEAF), d0
cf_a1:
    mov     d0, (16, a3)
    call    CtRun, 0, 0
    mov     (V_CTRES), d0
    add     CT_R*CT_RUN, d0
    mov     d0, (V_CTRES)
    add     CT_ENT, a2
    add     CT_ENT, a3
    inc     d2
    mov     d2, (V_CTDONE)
    call    MsNow, 0, 0             # the time cap
    mov     (V_CTMSA), d1
    sub     d1, d0
    cmp     CT_CAP, d0
    bcs     cf_more
    mov     CT_CAPPED, d0
    call    CtStat, 0, 0
    bra     cf_stop
cf_more:
    mov     (CtNTests), d0
    cmp     d0, d2
    bcs     cf_test
cf_stop:
cf_end:
    mov     BUF, a2
    call    MsNow, 0, 0
    mov     d0, (0x10, a2)
    mov     (V_CTDONE), d0
    mov     d0, (0x5C, a2)
    mov     (V_CTSTAT), d0
    mov     d0, (8, a2)
    clr     d0
    mov     d0, (V_CTBUSY)
    ret     [d2,d3,a2,a3], 0x30

# CtRegs (leaf): BUF+0x100.. = (address, width, value) for every CtRegTable entry, read with its width.
CtRegs:
    mov     CtRegTable, a0
    mov     BUF+0x100, a1
crg_next:
    mov     (a0), d0
    cmp     0, d0
    beq     crg_ret
    mov     d0, (a1)
    mov     (4, a0), d1
    mov     d1, (4, a1)
    mov     a0, (12, a1)            # (a scratch slot, overwritten below)
    mov     d0, a0
    cmp     1, d1
    bne     crg_16
    movbu   (a0), d0
    bra     crg_put
crg_16:
    cmp     2, d1
    bne     crg_32
    movhu   (a0), d0
    bra     crg_put
crg_32:
    mov     (a0), d0
crg_put:
    mov     (12, a1), a0
    mov     d0, (8, a1)
    clr     d0
    mov     d0, (12, a1)
    add     8, a0
    add     12, a1
    bra     crg_next
crg_ret:
    rets

# ---- the test routines -------------------------------------------------------------------------------------
# Each loop starts 8-aligned (the fetch unit reads 8-byte blocks, MN103S manual p.139/125); the NOPs padding up to
# it run once per run.
    .align  8, 0xCB
ct_null:                            # the harness alone
    rets

    .align  8, 0xCB
ct_loop:                            # the empty loop (LOOP)
    add     -1, d0
    bne     ct_loop
    rets

    .align  8, 0xCB
ct_loopw:                           # the walks' loop: a0 += 512 (LPW5)
    add     512, a0
    add     -1, d0
    bne     ct_loopw
    rets

    .align  8, 0xCB
ct_loops:                           # the sequential reads' loop: a0 += 64 (an imm8 add, as += 32 and += 16) (LPS6)
    add     64, a0
    add     -1, d0
    bne     ct_loops
    rets

    .align  8, 0xCB
ct_lbuf:                            # the loop buffer: setlb, then lne (LBUF)
    setlb
    add     -1, d0
    lne
    rets

    .align  8, 0xCB
ct_nop:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    add     -1, d0
    bne     ct_nop
    rets

    .align  8, 0xCB
ct_add:                             # add d1, d2 (1 byte)
    add     d1, d2
    add     d1, d2
    add     d1, d2
    add     d1, d2
    add     d1, d2
    add     d1, d2
    add     d1, d2
    add     d1, d2
    add     d1, d2
    add     d1, d2
    add     d1, d2
    add     d1, d2
    add     d1, d2
    add     d1, d2
    add     d1, d2
    add     d1, d2
    add     -1, d0
    bne     ct_add
    rets

    .align  8, 0xCB
ct_and:                             # and d1, d2 (2 bytes)
    and     d1, d2
    and     d1, d2
    and     d1, d2
    and     d1, d2
    and     d1, d2
    and     d1, d2
    and     d1, d2
    and     d1, d2
    and     d1, d2
    and     d1, d2
    and     d1, d2
    and     d1, d2
    and     d1, d2
    and     d1, d2
    and     d1, d2
    and     d1, d2
    add     -1, d0
    bne     ct_and
    rets

    .align  8, 0xCB
ct_movr:                            # mov d1, d2 (1 byte)
    mov     d1, d2
    mov     d1, d2
    mov     d1, d2
    mov     d1, d2
    mov     d1, d2
    mov     d1, d2
    mov     d1, d2
    mov     d1, d2
    mov     d1, d2
    mov     d1, d2
    mov     d1, d2
    mov     d1, d2
    mov     d1, d2
    mov     d1, d2
    mov     d1, d2
    mov     d1, d2
    add     -1, d0
    bne     ct_movr
    rets

    .align  8, 0xCB
ct_inc:                             # inc a1 (1 byte)
    inc     a1
    inc     a1
    inc     a1
    inc     a1
    inc     a1
    inc     a1
    inc     a1
    inc     a1
    inc     a1
    inc     a1
    inc     a1
    inc     a1
    inc     a1
    inc     a1
    inc     a1
    inc     a1
    add     -1, d0
    bne     ct_inc
    rets

    .align  8, 0xCB
ct_asl2:                            # asl2 d1 (1 byte)
    asl2    d1
    asl2    d1
    asl2    d1
    asl2    d1
    asl2    d1
    asl2    d1
    asl2    d1
    asl2    d1
    asl2    d1
    asl2    d1
    asl2    d1
    asl2    d1
    asl2    d1
    asl2    d1
    asl2    d1
    asl2    d1
    add     -1, d0
    bne     ct_asl2
    rets

    .align  8, 0xCB
ct_lsri:                            # lsr 3, d1 (3 bytes)
    lsr     3, d1
    lsr     3, d1
    lsr     3, d1
    lsr     3, d1
    lsr     3, d1
    lsr     3, d1
    lsr     3, d1
    lsr     3, d1
    lsr     3, d1
    lsr     3, d1
    lsr     3, d1
    lsr     3, d1
    lsr     3, d1
    lsr     3, d1
    lsr     3, d1
    lsr     3, d1
    add     -1, d0
    bne     ct_lsri
    rets

    .align  8, 0xCB
ct_extb:                            # extbu d1 (1 byte)
    extbu   d1
    extbu   d1
    extbu   d1
    extbu   d1
    extbu   d1
    extbu   d1
    extbu   d1
    extbu   d1
    extbu   d1
    extbu   d1
    extbu   d1
    extbu   d1
    extbu   d1
    extbu   d1
    extbu   d1
    extbu   d1
    add     -1, d0
    bne     ct_extb
    rets

    .align  8, 0xCB
ct_mi8:                             # mov imm8, d1 (2 bytes)
    mov     5, d1
    mov     5, d1
    mov     5, d1
    mov     5, d1
    mov     5, d1
    mov     5, d1
    mov     5, d1
    mov     5, d1
    mov     5, d1
    mov     5, d1
    mov     5, d1
    mov     5, d1
    mov     5, d1
    mov     5, d1
    mov     5, d1
    mov     5, d1
    add     -1, d0
    bne     ct_mi8
    rets

    .align  8, 0xCB
ct_mi16:                            # mov imm16, d1 (3 bytes)
    mov     0x1234, d1
    mov     0x1234, d1
    mov     0x1234, d1
    mov     0x1234, d1
    mov     0x1234, d1
    mov     0x1234, d1
    mov     0x1234, d1
    mov     0x1234, d1
    mov     0x1234, d1
    mov     0x1234, d1
    mov     0x1234, d1
    mov     0x1234, d1
    mov     0x1234, d1
    mov     0x1234, d1
    mov     0x1234, d1
    mov     0x1234, d1
    add     -1, d0
    bne     ct_mi16
    rets

    .align  8, 0xCB
ct_mi32:                            # mov imm32, d1 (6 bytes)
    mov     0x12345678, d1
    mov     0x12345678, d1
    mov     0x12345678, d1
    mov     0x12345678, d1
    mov     0x12345678, d1
    mov     0x12345678, d1
    mov     0x12345678, d1
    mov     0x12345678, d1
    mov     0x12345678, d1
    mov     0x12345678, d1
    mov     0x12345678, d1
    mov     0x12345678, d1
    mov     0x12345678, d1
    mov     0x12345678, d1
    mov     0x12345678, d1
    mov     0x12345678, d1
    add     -1, d0
    bne     ct_mi32
    rets

    .align  8, 0xCB
ct_bra:                             # bra to the next instruction (taken, 2 bytes)
    bra     .+2
    bra     .+2
    bra     .+2
    bra     .+2
    bra     .+2
    bra     .+2
    bra     .+2
    bra     .+2
    bra     .+2
    bra     .+2
    bra     .+2
    bra     .+2
    bra     .+2
    bra     .+2
    bra     .+2
    bra     .+2
    add     -1, d0
    bne     ct_bra
    rets

    .align  8, 0xCB
ct_bne:                             # bne, taken (Z clear: d0 > 0 here)
    cmp     0, d0
    .align  8, 0xCB
cbn_lp:
    bne     .+2
    bne     .+2
    bne     .+2
    bne     .+2
    bne     .+2
    bne     .+2
    bne     .+2
    bne     .+2
    bne     .+2
    bne     .+2
    bne     .+2
    bne     .+2
    bne     .+2
    bne     .+2
    bne     .+2
    bne     .+2
    add     -1, d0
    bne     cbn_lp
    rets

    .align  8, 0xCB
ct_beq:                             # beq, not taken
    cmp     0, d0
    .align  8, 0xCB
cbe_lp:
    beq     .+2
    beq     .+2
    beq     .+2
    beq     .+2
    beq     .+2
    beq     .+2
    beq     .+2
    beq     .+2
    beq     .+2
    beq     .+2
    beq     .+2
    beq     .+2
    beq     .+2
    beq     .+2
    beq     .+2
    beq     .+2
    add     -1, d0
    bne     cbe_lp
    rets

    .align  8, 0xCB
ct_jmp:                             # jmp d16 to the next instruction (3 bytes)
    jmp     .+3
    jmp     .+3
    jmp     .+3
    jmp     .+3
    jmp     .+3
    jmp     .+3
    jmp     .+3
    jmp     .+3
    jmp     .+3
    jmp     .+3
    jmp     .+3
    jmp     .+3
    jmp     .+3
    jmp     .+3
    jmp     .+3
    jmp     .+3
    add     -1, d0
    bne     ct_jmp
    rets

    .align  8, 0xCB
ct_ldsp:                            # mov (8, sp), d1: a load from the stack (the harness's frame)
    mov     (8, sp), d1
    mov     (8, sp), d1
    mov     (8, sp), d1
    mov     (8, sp), d1
    mov     (8, sp), d1
    mov     (8, sp), d1
    mov     (8, sp), d1
    mov     (8, sp), d1
    mov     (8, sp), d1
    mov     (8, sp), d1
    mov     (8, sp), d1
    mov     (8, sp), d1
    mov     (8, sp), d1
    mov     (8, sp), d1
    mov     (8, sp), d1
    mov     (8, sp), d1
    add     -1, d0
    bne     ct_ldsp
    rets

    .align  8, 0xCB
ct_stsp:                            # mov d1, (8, sp): a store to the stack (the harness's frame)
    mov     d1, (8, sp)
    mov     d1, (8, sp)
    mov     d1, (8, sp)
    mov     d1, (8, sp)
    mov     d1, (8, sp)
    mov     d1, (8, sp)
    mov     d1, (8, sp)
    mov     d1, (8, sp)
    mov     d1, (8, sp)
    mov     d1, (8, sp)
    mov     d1, (8, sp)
    mov     d1, (8, sp)
    mov     d1, (8, sp)
    mov     d1, (8, sp)
    mov     d1, (8, sp)
    mov     d1, (8, sp)
    add     -1, d0
    bne     ct_stsp
    rets

    .align  8, 0xCB
ct_ldab:                            # mov (abs32), d1 (6 bytes), from the scratch
    mov     (CT_SCR+0x20), d1
    mov     (CT_SCR+0x20), d1
    mov     (CT_SCR+0x20), d1
    mov     (CT_SCR+0x20), d1
    mov     (CT_SCR+0x20), d1
    mov     (CT_SCR+0x20), d1
    mov     (CT_SCR+0x20), d1
    mov     (CT_SCR+0x20), d1
    mov     (CT_SCR+0x20), d1
    mov     (CT_SCR+0x20), d1
    mov     (CT_SCR+0x20), d1
    mov     (CT_SCR+0x20), d1
    mov     (CT_SCR+0x20), d1
    mov     (CT_SCR+0x20), d1
    mov     (CT_SCR+0x20), d1
    mov     (CT_SCR+0x20), d1
    add     -1, d0
    bne     ct_ldab
    rets

    .align  8, 0xCB
ct_ludp:                            # a load and an add that uses it (load-use), 8 pairs
    mov     (a0), d1
    add     d1, d2
    mov     (a0), d1
    add     d1, d2
    mov     (a0), d1
    add     d1, d2
    mov     (a0), d1
    add     d1, d2
    mov     (a0), d1
    add     d1, d2
    mov     (a0), d1
    add     d1, d2
    mov     (a0), d1
    add     d1, d2
    mov     (a0), d1
    add     d1, d2
    add     -1, d0
    bne     ct_ludp
    rets

    .align  8, 0xCB
ct_luin:                            # a load and an add that does not use it, 8 pairs
    mov     (a0), d1
    add     d2, d2
    mov     (a0), d1
    add     d2, d2
    mov     (a0), d1
    add     d2, d2
    mov     (a0), d1
    add     d2, d2
    mov     (a0), d1
    add     d2, d2
    mov     (a0), d1
    add     d2, d2
    mov     (a0), d1
    add     d2, d2
    mov     (a0), d1
    add     d2, d2
    add     -1, d0
    bne     ct_luin
    rets

    .align  8, 0xCB
ct_mvm1:                            # movm push and pop of one register, 8 pairs
    movm    [d2], (sp)
    movm    (sp), [d2]
    movm    [d2], (sp)
    movm    (sp), [d2]
    movm    [d2], (sp)
    movm    (sp), [d2]
    movm    [d2], (sp)
    movm    (sp), [d2]
    movm    [d2], (sp)
    movm    (sp), [d2]
    movm    [d2], (sp)
    movm    (sp), [d2]
    movm    [d2], (sp)
    movm    (sp), [d2]
    movm    [d2], (sp)
    movm    (sp), [d2]
    add     -1, d0
    bne     ct_mvm1
    rets

    .align  8, 0xCB
ct_mvm4:                            # movm push and pop of four registers, 8 pairs
    movm    [d2,d3,a2,a3], (sp)
    movm    (sp), [d2,d3,a2,a3]
    movm    [d2,d3,a2,a3], (sp)
    movm    (sp), [d2,d3,a2,a3]
    movm    [d2,d3,a2,a3], (sp)
    movm    (sp), [d2,d3,a2,a3]
    movm    [d2,d3,a2,a3], (sp)
    movm    (sp), [d2,d3,a2,a3]
    movm    [d2,d3,a2,a3], (sp)
    movm    (sp), [d2,d3,a2,a3]
    movm    [d2,d3,a2,a3], (sp)
    movm    (sp), [d2,d3,a2,a3]
    movm    [d2,d3,a2,a3], (sp)
    movm    (sp), [d2,d3,a2,a3]
    movm    [d2,d3,a2,a3], (sp)
    movm    (sp), [d2,d3,a2,a3]
    add     -1, d0
    bne     ct_mvm4
    rets

    .align  8, 0xCB
ct_cal0:                            # call d16 and ret, no registers, 8 pairs
    add     -8, sp
    .align  8, 0xCB
cc0_lp:
    call    ct_r0, 0, 0
    call    ct_r0, 0, 0
    call    ct_r0, 0, 0
    call    ct_r0, 0, 0
    call    ct_r0, 0, 0
    call    ct_r0, 0, 0
    call    ct_r0, 0, 0
    call    ct_r0, 0, 0
    add     -1, d0
    bne     cc0_lp
    add     8, sp
    rets

    .align  8, 0xCB
ct_cal4:                            # call d16 and ret saving four registers, 8 pairs
    add     -8, sp
    .align  8, 0xCB
cc4_lp:
    call    ct_r4, [d2,d3,a2,a3], 0x10
    call    ct_r4, [d2,d3,a2,a3], 0x10
    call    ct_r4, [d2,d3,a2,a3], 0x10
    call    ct_r4, [d2,d3,a2,a3], 0x10
    call    ct_r4, [d2,d3,a2,a3], 0x10
    call    ct_r4, [d2,d3,a2,a3], 0x10
    call    ct_r4, [d2,d3,a2,a3], 0x10
    call    ct_r4, [d2,d3,a2,a3], 0x10
    add     -1, d0
    bne     cc4_lp
    add     8, sp
    rets

    .align  8, 0xCB
ct_calf:                            # call d16 and retf, 8 pairs
    add     -8, sp
    .align  8, 0xCB
ccf_lp:
    call    ct_rf, 0, 0
    call    ct_rf, 0, 0
    call    ct_rf, 0, 0
    call    ct_rf, 0, 0
    call    ct_rf, 0, 0
    call    ct_rf, 0, 0
    call    ct_rf, 0, 0
    call    ct_rf, 0, 0
    add     -1, d0
    bne     ccf_lp
    add     8, sp
    rets

    .align  8, 0xCB
ct_cals:                            # calls (a1) and rets, 8 pairs (a1 = ct_rs; AM31 has no calls d16)
    add     -8, sp
    .align  8, 0xCB
ccs_lp:
    calls   (a1)
    calls   (a1)
    calls   (a1)
    calls   (a1)
    calls   (a1)
    calls   (a1)
    calls   (a1)
    calls   (a1)
    add     -1, d0
    bne     ccs_lp
    add     8, sp
    rets

ct_r0:
    ret     0, 0
ct_r4:
    ret     [d2,d3,a2,a3], 0x10
ct_rf:
    retf    0, 0
ct_rs:
    rets

    .align  8, 0xCB
ct_mref:                            # the multiplications' reference: mov a1, d2; nop; nop (as the firmware puts
    mov     a1, d2                  # two nops before every mul), 8 times
    nop
    nop
    mov     a1, d2
    nop
    nop
    mov     a1, d2
    nop
    nop
    mov     a1, d2
    nop
    nop
    mov     a1, d2
    nop
    nop
    mov     a1, d2
    nop
    nop
    mov     a1, d2
    nop
    nop
    mov     a1, d2
    nop
    nop
    add     -1, d0
    bne     ct_mref
    rets

    .align  8, 0xCB
ct_mul:                             # mul d1, d2 with d1 = a0, d2 = a1 (its cycles depend on d2's size)
    mov     a0, d1
    .align  8, 0xCB
cmu_lp:
    mov     a1, d2
    nop
    nop
    mul     d1, d2
    mov     a1, d2
    nop
    nop
    mul     d1, d2
    mov     a1, d2
    nop
    nop
    mul     d1, d2
    mov     a1, d2
    nop
    nop
    mul     d1, d2
    mov     a1, d2
    nop
    nop
    mul     d1, d2
    mov     a1, d2
    nop
    nop
    mul     d1, d2
    mov     a1, d2
    nop
    nop
    mul     d1, d2
    mov     a1, d2
    nop
    nop
    mul     d1, d2
    add     -1, d0
    bne     cmu_lp
    rets

    .align  8, 0xCB
ct_mulu:                            # mulu d1, d2, the same way
    mov     a0, d1
    .align  8, 0xCB
cmuu_lp:
    mov     a1, d2
    nop
    nop
    mulu    d1, d2
    mov     a1, d2
    nop
    nop
    mulu    d1, d2
    mov     a1, d2
    nop
    nop
    mulu    d1, d2
    mov     a1, d2
    nop
    nop
    mulu    d1, d2
    mov     a1, d2
    nop
    nop
    mulu    d1, d2
    mov     a1, d2
    nop
    nop
    mulu    d1, d2
    mov     a1, d2
    nop
    nop
    mulu    d1, d2
    mov     a1, d2
    nop
    nop
    mulu    d1, d2
    add     -1, d0
    bne     cmuu_lp
    rets

    .align  8, 0xCB
ct_dref:                            # the divisions' reference: mov a1, d2; ext d2 (MDR:d2 = a1), 8 times
    mov     a1, d2
    ext     d2
    mov     a1, d2
    ext     d2
    mov     a1, d2
    ext     d2
    mov     a1, d2
    ext     d2
    mov     a1, d2
    ext     d2
    mov     a1, d2
    ext     d2
    mov     a1, d2
    ext     d2
    mov     a1, d2
    ext     d2
    add     -1, d0
    bne     ct_dref
    rets

    .align  8, 0xCB
ct_div:                             # div d1, d2 with d1 = a0, MDR:d2 = a1 sign-extended (as the firmware: ext, div)
    mov     a0, d1
    .align  8, 0xCB
cdv_lp:
    mov     a1, d2
    ext     d2
    div     d1, d2
    mov     a1, d2
    ext     d2
    div     d1, d2
    mov     a1, d2
    ext     d2
    div     d1, d2
    mov     a1, d2
    ext     d2
    div     d1, d2
    mov     a1, d2
    ext     d2
    div     d1, d2
    mov     a1, d2
    ext     d2
    div     d1, d2
    mov     a1, d2
    ext     d2
    div     d1, d2
    mov     a1, d2
    ext     d2
    div     d1, d2
    add     -1, d0
    bne     cdv_lp
    rets

    .align  8, 0xCB
ct_divu:                            # divu d1, d2, the same way (a1 >= 0, so MDR = 0)
    mov     a0, d1
    .align  8, 0xCB
cdvu_lp:
    mov     a1, d2
    ext     d2
    divu    d1, d2
    mov     a1, d2
    ext     d2
    divu    d1, d2
    mov     a1, d2
    ext     d2
    divu    d1, d2
    mov     a1, d2
    ext     d2
    divu    d1, d2
    mov     a1, d2
    ext     d2
    divu    d1, d2
    mov     a1, d2
    ext     d2
    divu    d1, d2
    mov     a1, d2
    ext     d2
    divu    d1, d2
    mov     a1, d2
    ext     d2
    divu    d1, d2
    add     -1, d0
    bne     cdvu_lp
    rets

    .align  8, 0xCB
ct_fcall:                           # calls (a1) with d0 = a0, 4 times: the firmware routine (a1 = CT_LEAF), its copy
    add     -8, sp                  # CtTwin, or ct_rf (the bare call); they change d0 and d1 only
    mov     d0, d2
    .align  8, 0xCB
cfc_lp:
    mov     a0, d0
    calls   (a1)
    mov     a0, d0
    calls   (a1)
    mov     a0, d0
    calls   (a1)
    mov     a0, d0
    calls   (a1)
    add     -1, d2
    bne     cfc_lp
    add     8, sp
    rets

ct_fone:                            # one calls (a1) with d0 = a0: its first run is the one with a cold cache
    add     -8, sp
    mov     a0, d0
    calls   (a1)
    add     8, sp
    rets

# loads; a0 = the address
    .align  8, 0xCB
ct_ld4:                             # 16 word loads from (a0)
    mov     (a0), d1
    mov     (a0), d1
    mov     (a0), d1
    mov     (a0), d1
    mov     (a0), d1
    mov     (a0), d1
    mov     (a0), d1
    mov     (a0), d1
    mov     (a0), d1
    mov     (a0), d1
    mov     (a0), d1
    mov     (a0), d1
    mov     (a0), d1
    mov     (a0), d1
    mov     (a0), d1
    mov     (a0), d1
    add     -1, d0
    bne     ct_ld4
    rets

    .align  8, 0xCB
ct_ld2:                             # 16 halfword loads from (a0)
    movhu   (a0), d1
    movhu   (a0), d1
    movhu   (a0), d1
    movhu   (a0), d1
    movhu   (a0), d1
    movhu   (a0), d1
    movhu   (a0), d1
    movhu   (a0), d1
    movhu   (a0), d1
    movhu   (a0), d1
    movhu   (a0), d1
    movhu   (a0), d1
    movhu   (a0), d1
    movhu   (a0), d1
    movhu   (a0), d1
    movhu   (a0), d1
    add     -1, d0
    bne     ct_ld2
    rets

    .align  8, 0xCB
ct_ld1:                             # 16 byte loads from (a0)
    movbu   (a0), d1
    movbu   (a0), d1
    movbu   (a0), d1
    movbu   (a0), d1
    movbu   (a0), d1
    movbu   (a0), d1
    movbu   (a0), d1
    movbu   (a0), d1
    movbu   (a0), d1
    movbu   (a0), d1
    movbu   (a0), d1
    movbu   (a0), d1
    movbu   (a0), d1
    movbu   (a0), d1
    movbu   (a0), d1
    movbu   (a0), d1
    add     -1, d0
    bne     ct_ld1
    rets

    .align  8, 0xCB
ct_lw4:                             # 8 word loads 64 bytes apart, then a0 += 512: every load a new cache line
    mov     (-0x1000, a0), d1       # (a0 = the start + 0x1000, so every offset takes the d16 form)
    mov     (-0x0FC0, a0), d1
    mov     (-0x0F80, a0), d1
    mov     (-0x0F40, a0), d1
    mov     (-0x0F00, a0), d1
    mov     (-0x0EC0, a0), d1
    mov     (-0x0E80, a0), d1
    mov     (-0x0E40, a0), d1
    add     512, a0
    add     -1, d0
    bne     ct_lw4
    rets

    .align  8, 0xCB
ct_ls4:                             # 16 word loads in sequence, then a0 += 64
    mov     (0, a0), d1
    mov     (4, a0), d1
    mov     (8, a0), d1
    mov     (12, a0), d1
    mov     (16, a0), d1
    mov     (20, a0), d1
    mov     (24, a0), d1
    mov     (28, a0), d1
    mov     (32, a0), d1
    mov     (36, a0), d1
    mov     (40, a0), d1
    mov     (44, a0), d1
    mov     (48, a0), d1
    mov     (52, a0), d1
    mov     (56, a0), d1
    mov     (60, a0), d1
    add     64, a0
    add     -1, d0
    bne     ct_ls4
    rets

    .align  8, 0xCB
ct_ls2:                             # 16 halfword loads in sequence, then a0 += 32
    movhu   (0, a0), d1
    movhu   (2, a0), d1
    movhu   (4, a0), d1
    movhu   (6, a0), d1
    movhu   (8, a0), d1
    movhu   (10, a0), d1
    movhu   (12, a0), d1
    movhu   (14, a0), d1
    movhu   (16, a0), d1
    movhu   (18, a0), d1
    movhu   (20, a0), d1
    movhu   (22, a0), d1
    movhu   (24, a0), d1
    movhu   (26, a0), d1
    movhu   (28, a0), d1
    movhu   (30, a0), d1
    add     32, a0
    add     -1, d0
    bne     ct_ls2
    rets

# stores; a0 = the address. The "same address" ones first read the value there and store only that.
ct_st4:                             # 16 word stores to (a0) of the word already there
    mov     (a0), d1
    .align  8, 0xCB
cs4_lp:
    mov     d1, (a0)
    mov     d1, (a0)
    mov     d1, (a0)
    mov     d1, (a0)
    mov     d1, (a0)
    mov     d1, (a0)
    mov     d1, (a0)
    mov     d1, (a0)
    mov     d1, (a0)
    mov     d1, (a0)
    mov     d1, (a0)
    mov     d1, (a0)
    mov     d1, (a0)
    mov     d1, (a0)
    mov     d1, (a0)
    mov     d1, (a0)
    add     -1, d0
    bne     cs4_lp
    rets

ct_st2:                             # 16 halfword stores to (a0) of the halfword already there
    movhu   (a0), d1
    .align  8, 0xCB
cs2_lp:
    movhu   d1, (a0)
    movhu   d1, (a0)
    movhu   d1, (a0)
    movhu   d1, (a0)
    movhu   d1, (a0)
    movhu   d1, (a0)
    movhu   d1, (a0)
    movhu   d1, (a0)
    movhu   d1, (a0)
    movhu   d1, (a0)
    movhu   d1, (a0)
    movhu   d1, (a0)
    movhu   d1, (a0)
    movhu   d1, (a0)
    movhu   d1, (a0)
    movhu   d1, (a0)
    add     -1, d0
    bne     cs2_lp
    rets

ct_st1:                             # 16 byte stores to (a0) of the byte already there
    movbu   (a0), d1
    .align  8, 0xCB
cs1_lp:
    movbu   d1, (a0)
    movbu   d1, (a0)
    movbu   d1, (a0)
    movbu   d1, (a0)
    movbu   d1, (a0)
    movbu   d1, (a0)
    movbu   d1, (a0)
    movbu   d1, (a0)
    movbu   d1, (a0)
    movbu   d1, (a0)
    movbu   d1, (a0)
    movbu   d1, (a0)
    movbu   d1, (a0)
    movbu   d1, (a0)
    movbu   d1, (a0)
    movbu   d1, (a0)
    add     -1, d0
    bne     cs1_lp
    rets

    .align  8, 0xCB
ct_sw4:                             # 8 word stores 64 bytes apart, then a0 += 512 (the scratch only: any value)
    mov     d1, (-0x1000, a0)
    mov     d1, (-0x0FC0, a0)
    mov     d1, (-0x0F80, a0)
    mov     d1, (-0x0F40, a0)
    mov     d1, (-0x0F00, a0)
    mov     d1, (-0x0EC0, a0)
    mov     d1, (-0x0E80, a0)
    mov     d1, (-0x0E40, a0)
    add     512, a0
    add     -1, d0
    bne     ct_sw4
    rets

    .align  8, 0xCB
ct_sq4:                             # 16 word stores in sequence, then a0 += 64 (the scratch only: any value)
    mov     d1, (0, a0)
    mov     d1, (4, a0)
    mov     d1, (8, a0)
    mov     d1, (12, a0)
    mov     d1, (16, a0)
    mov     d1, (20, a0)
    mov     d1, (24, a0)
    mov     d1, (28, a0)
    mov     d1, (32, a0)
    mov     d1, (36, a0)
    mov     d1, (40, a0)
    mov     d1, (44, a0)
    mov     d1, (48, a0)
    mov     d1, (52, a0)
    mov     d1, (56, a0)
    mov     d1, (60, a0)
    add     64, a0
    add     -1, d0
    bne     ct_sq4
    rets

    .align  8, 0xCB
ct_rmw2:                            # a halfword read and written back, 8 pairs (the LCD: the picture is unchanged)
    movhu   (a0), d1
    movhu   d1, (a0)
    movhu   (a0), d1
    movhu   d1, (a0)
    movhu   (a0), d1
    movhu   d1, (a0)
    movhu   (a0), d1
    movhu   d1, (a0)
    movhu   (a0), d1
    movhu   d1, (a0)
    movhu   (a0), d1
    movhu   d1, (a0)
    movhu   (a0), d1
    movhu   d1, (a0)
    movhu   (a0), d1
    movhu   d1, (a0)
    add     -1, d0
    bne     ct_rmw2
    rets

    .align  8, 0xCB
ct_rmw4:                            # a word read and written back, 8 pairs
    mov     (a0), d1
    mov     d1, (a0)
    mov     (a0), d1
    mov     d1, (a0)
    mov     (a0), d1
    mov     d1, (a0)
    mov     (a0), d1
    mov     d1, (a0)
    mov     (a0), d1
    mov     d1, (a0)
    mov     (a0), d1
    mov     d1, (a0)
    mov     (a0), d1
    mov     d1, (a0)
    mov     (a0), d1
    mov     d1, (a0)
    add     -1, d0
    bne     ct_rmw4
    rets

    .align  8, 0xCB
ct_rmq2:                            # 8 halfwords in sequence, each read and written back, then a0 += 16
    movhu   (0, a0), d1
    movhu   d1, (0, a0)
    movhu   (2, a0), d1
    movhu   d1, (2, a0)
    movhu   (4, a0), d1
    movhu   d1, (4, a0)
    movhu   (6, a0), d1
    movhu   d1, (6, a0)
    movhu   (8, a0), d1
    movhu   d1, (8, a0)
    movhu   (10, a0), d1
    movhu   d1, (10, a0)
    movhu   (12, a0), d1
    movhu   d1, (12, a0)
    movhu   (14, a0), d1
    movhu   d1, (14, a0)
    add     16, a0
    add     -1, d0
    bne     ct_rmq2
    rets

# CtTwin: the firmware routine the fetch tests call (941 0x48471E64, 893 0x48471D35), assembled here from its
# instructions: d0 = f(d0), d1 changed, nothing read or written. CtTwinPre is the end of the routine before it
# (mov d1, d0; retf 0, 0); CtFind looks for CtTwinPre..CtTwinEnd in the flash. Its entry is placed 5 bytes into an
# 8-byte block, as 893's is (0x48471D35), so that the copy is fetched as the original is.
    .align  8, 0xCB
    nop
CtTwinPre:
    mov     d1, d0
    retf    0, 0
CtTwin:
    clr     d1
    asl     9, d0
    cmp     0x200000, d0
    bhi     ctw_1
    mov     0x10, d1
    bra     ctw_end
ctw_1:
    cmp     0x1000000, d0
    bhi     ctw_2
    mov     0x20, d1
    bra     ctw_end
ctw_2:
    cmp     0x2000000, d0
    bhi     ctw_3
    mov     0x20, d1
    bra     ctw_end
ctw_3:
    cmp     0x8000000, d0
    bhi     ctw_4
    mov     0x20, d1
    bra     ctw_end
ctw_4:
    cmp     0x10000000, d0
    bhi     ctw_5
    mov     0x20, d1
    bra     ctw_end
ctw_5:
    cmp     0x1F800000, d0
    bhi     ctw_6
    mov     0x3F, d1
    bra     ctw_end
ctw_6:
    cmp     0x3F000000, d0
    bhi     ctw_7
    mov     0x3F, d1
    bra     ctw_end
ctw_7:
    cmp     0x7E000000, d0
    bhi     ctw_8
    mov     0x3F, d1
    bra     ctw_end
ctw_8:
    sub     0x100000, d0
    cmp     0x7FF00000, d0
    bhi     ctw_end
    mov     0x3F, d1
ctw_end:
    mov     d1, d0
    retf    0, 0
CtTwinEnd:

# ---- tables ------------------------------------------------------------------------------------------------
    .align  4
# CtRegTable: the registers the snapshot reads (address, width in bytes); every one is one the firmware itself
# reads or writes (find_cpu.py lists where). 0x32000010, 0x32000040 and 0x32000042 it only writes.
CtRegTable:
    .long   0x32000010, 2           # bus controller: written 0x400 first thing in the bus set-up (941 0x484D7111)
    .long   0x32000020, 2           # MEMCTR0..7 (the firmware's bus set-up writes all eight)
    .long   0x32000022, 2
    .long   0x32000024, 2
    .long   0x32000026, 2           #   941's DSP data accessors bracket it with 0x924 / 0x0F00 (find_cpu.py)
    .long   0x32000028, 2
    .long   0x3200002A, 2
    .long   0x3200002C, 2
    .long   0x3200002E, 2
    .long   0x32000040, 2           # DRAM control? (0x497 at boot, then 0x287/0x3BF/0x297 by board)
    .long   0x32000042, 2           #   its refresh count? (0xEA6 at boot, then 0x7D0)
    .long   CHCTR, 4                # cache control (0x30, 3, then | 0x80 at boot)
    .long   TM4MD, 1                # timer 4
    .long   TM4BR, 2
    .long   STRAP, 2                # the board strap (bits 1, 2: bus set-up; bits 11:10: hardware subtype)
    .long   0x3400015C, 2           # G17ICR (pass 6)
    .long   0, 0

# CtTests: tag, routine, N, a0, a1. check_cpu_probe.py TESTS has the same list in the same order, with what each
# measures (K, the reference it is measured against). Regions: the address each test reads or writes.
CtNTests:
    .long   (CtTestsEnd-CtTests)/CT_ENT
CtTests:
    .ascii  "NULL"
    .long   ct_null, 1, 0, 0
    .ascii  "LOOP"
    .long   ct_loop, 1024, 0, 0
    .ascii  "LPW5"
    .long   ct_loopw, 256, 0, 0
    .ascii  "LPS6"
    .long   ct_loops, 256, 0, 0
    .ascii  "LBUF"
    .long   ct_lbuf, 1024, 0, 0
    .ascii  "NOP "
    .long   ct_nop, 256, 0, 0
    .ascii  "ADD "
    .long   ct_add, 256, 0, 0
    .ascii  "AND "
    .long   ct_and, 256, 0, 0
    .ascii  "MOVR"
    .long   ct_movr, 256, 0, 0
    .ascii  "INC "
    .long   ct_inc, 256, 0, 0
    .ascii  "ASL2"
    .long   ct_asl2, 256, 0, 0
    .ascii  "LSRI"
    .long   ct_lsri, 256, 0, 0
    .ascii  "EXTB"
    .long   ct_extb, 256, 0, 0
    .ascii  "MI8 "
    .long   ct_mi8, 256, 0, 0
    .ascii  "MI16"
    .long   ct_mi16, 256, 0, 0
    .ascii  "MI32"
    .long   ct_mi32, 256, 0, 0
    .ascii  "BRA "
    .long   ct_bra, 128, 0, 0
    .ascii  "BNE "
    .long   ct_bne, 128, 0, 0
    .ascii  "BEQ "
    .long   ct_beq, 256, 0, 0
    .ascii  "JMP "
    .long   ct_jmp, 128, 0, 0
    .ascii  "LDSP"
    .long   ct_ldsp, 256, 0, 0
    .ascii  "STSP"
    .long   ct_stsp, 256, 0, 0
    .ascii  "LDAB"
    .long   ct_ldab, 256, 0, 0
    .ascii  "LUDP"
    .long   ct_ludp, 256, CT_SCR, 0
    .ascii  "LUIN"
    .long   ct_luin, 256, CT_SCR, 0
    .ascii  "MVM1"
    .long   ct_mvm1, 64, 0, 0
    .ascii  "MVM4"
    .long   ct_mvm4, 64, 0, 0
    .ascii  "CAL0"
    .long   ct_cal0, 64, 0, 0
    .ascii  "CAL4"
    .long   ct_cal4, 64, 0, 0
    .ascii  "CALF"
    .long   ct_calf, 64, 0, 0
    .ascii  "CALS"
    .long   ct_cals, 64, 0, ct_rs
    .ascii  "MREF"
    .long   ct_mref, 64, 3, 0x7F
    .ascii  "MUL0"
    .long   ct_mul, 64, 3, 0
    .ascii  "MUL1"
    .long   ct_mul, 64, 3, 0x7F
    .ascii  "MUL2"
    .long   ct_mul, 64, 3, 0x7FFF
    .ascii  "MUL4"
    .long   ct_mul, 32, 3, 0x12345678
    .ascii  "MUU1"
    .long   ct_mulu, 64, 3, 0x7F
    .ascii  "MUU4"
    .long   ct_mulu, 32, 3, 0x12345678
    .ascii  "DREF"
    .long   ct_dref, 64, 7, 0x7F
    .ascii  "DIV1"
    .long   ct_div, 64, 7, 0x7F
    .ascii  "DIV4"
    .long   ct_div, 32, 7, 0x12345678
    .ascii  "DIVN"
    .long   ct_div, 32, 7, -0x12345678
    .ascii  "DVU1"
    .long   ct_divu, 64, 7, 0x7F
    .ascii  "DVU4"
    .long   ct_divu, 32, 7, 0x12345678
    .ascii  "CRET"                  # the bare call: calls (a1) to a retf, 4 per turn
    .long   ct_fcall, 128, 0, ct_rf
    .ascii  "FL1L"                  # one call, the long path, before any other call of it: run 0 of chunk 0 is
    .long   ct_fone, 1, 0x3FFFFF, CT_LEAF   # its first execution since the probe started (a cold I-cache)
    .ascii  "TW1L"
    .long   ct_fone, 1, 0x3FFFFF, CtTwin
    .ascii  "FLLG"                  # the firmware routine in flash, the long path (d0 = 0x3FFFFF: 24 instructions)
    .long   ct_fcall, 32, 0x3FFFFF, CT_LEAF
    .ascii  "TWLG"                  # its copy in RAM, the long path
    .long   ct_fcall, 32, 0x3FFFFF, CtTwin
    .ascii  "FLSH"                  # the firmware routine, the short path (d0 = 0: 8 instructions)
    .long   ct_fcall, 64, 0, CT_LEAF
    .ascii  "TWSH"
    .long   ct_fcall, 64, 0, CtTwin
    .ascii  "RAL4"                  # work RAM, cached view
    .long   ct_ld4, 128, CT_SCR, 0
    .ascii  "RAL2"
    .long   ct_ld2, 128, CT_SCR, 0
    .ascii  "RAL1"
    .long   ct_ld1, 128, CT_SCR, 0
    .ascii  "RAW4"
    .long   ct_lw4, 32, 0x50180000+0x1000, 0
    .ascii  "PRL4"                  # program flash
    .long   ct_ld4, 128, 0x48400000, 0
    .ascii  "PRL2"
    .long   ct_ld2, 128, 0x48400000, 0
    .ascii  "PRL1"
    .long   ct_ld1, 128, 0x48400000, 0
    .ascii  "PRW4"
    .long   ct_lw4, 32, 0x48600000+0x1000, 0
    .ascii  "TBL4"                  # table flash (the same chips, A22 low)
    .long   ct_ld4, 128, 0x48000000, 0
    .ascii  "TBL2"
    .long   ct_ld2, 128, 0x48000000, 0
    .ascii  "TBL1"
    .long   ct_ld1, 128, 0x48000000, 0
    .ascii  "TBW4"
    .long   ct_lw4, 32, 0x48010000+0x1000, 0
    .ascii  "BTL4"                  # IC18, the boot ROM and rhythm data (CS0)
    .long   ct_ld4, 128, 0x40000000, 0
    .ascii  "BTL2"
    .long   ct_ld2, 128, 0x40000000, 0
    .ascii  "BTL1"
    .long   ct_ld1, 128, 0x40000000, 0
    .ascii  "BTW4"
    .long   ct_lw4, 32, 0x40010000+0x1000, 0
    .ascii  "LBL4"                  # the library RAM (the firmware runs its library from here)
    .long   ct_ld4, 128, 0x4C000000, 0
    .ascii  "LBL2"
    .long   ct_ld2, 128, 0x4C000000, 0
    .ascii  "LBL1"
    .long   ct_ld1, 128, 0x4C000000, 0
    .ascii  "LBW4"
    .long   ct_lw4, 32, 0x4C010000+0x1000, 0
    .ascii  "C2L4"                  # IC21, the custom data flash, cached view
    .long   ct_ld4, 128, 0x56800000, 0
    .ascii  "C2L2"
    .long   ct_ld2, 128, 0x56800000, 0
    .ascii  "C2L1"
    .long   ct_ld1, 128, 0x56800000, 0
    .ascii  "C2W4"
    .long   ct_lw4, 32, 0x56810000+0x1000, 0
    .ascii  "PIL4"                  # IC19, the picture flash
    .long   ct_ld4, 128, 0x57800000, 0
    .ascii  "PIL2"
    .long   ct_ld2, 128, 0x57800000, 0
    .ascii  "PIL1"
    .long   ct_ld1, 128, 0x57800000, 0
    .ascii  "PIW4"
    .long   ct_lw4, 32, 0x57810000+0x1000, 0
    .ascii  "RUL4"                  # work RAM, uncached view
    .long   ct_ld4, 16, CT_SCR+CT_UNC, 0
    .ascii  "RUL2"
    .long   ct_ld2, 16, CT_SCR+CT_UNC, 0
    .ascii  "RUL1"
    .long   ct_ld1, 16, CT_SCR+CT_UNC, 0
    .ascii  "RUQ4"
    .long   ct_ls4, 16, 0x50180000+CT_UNC, 0
    .ascii  "RUQ2"
    .long   ct_ls2, 16, 0x50180000+CT_UNC, 0
    .ascii  "CUL4"                  # IC21, uncached view (where the firmware reads it)
    .long   ct_ld4, 16, 0x96800000, 0
    .ascii  "CUL2"
    .long   ct_ld2, 16, 0x96800000, 0
    .ascii  "CUL1"
    .long   ct_ld1, 16, 0x96800000, 0
    .ascii  "CUQ4"
    .long   ct_ls4, 16, 0x96810000, 0
    .ascii  "CUQ2"
    .long   ct_ls2, 16, 0x96810000, 0
    .ascii  "SRL4"                  # IC23, the battery-backed SRAM, through 0x84000000 (reads only)
    .long   ct_ld4, 16, 0x84000000, 0
    .ascii  "SRL2"
    .long   ct_ld2, 16, 0x84000000, 0
    .ascii  "SRL1"
    .long   ct_ld1, 16, 0x84000000, 0
    .ascii  "SRQ4"
    .long   ct_ls4, 16, 0x84010000, 0
    .ascii  "SRQ2"
    .long   ct_ls2, 16, 0x84010000, 0
    .ascii  "LCL4"                  # the LCD frame
    .long   ct_ld4, 16, CT_LCD, 0
    .ascii  "LCL2"
    .long   ct_ld2, 16, CT_LCD, 0
    .ascii  "LCL1"
    .long   ct_ld1, 16, CT_LCD, 0
    .ascii  "LCQ4"
    .long   ct_ls4, 16, CT_LCD, 0
    .ascii  "LCQ2"
    .long   ct_ls2, 16, CT_LCD, 0
    .ascii  "TMBC"                  # on-chip registers and the board strap
    .long   ct_ld2, 16, TM4BC, 0
    .ascii  "TMMD"
    .long   ct_ld1, 16, TM4MD, 0
    .ascii  "ICR "
    .long   ct_ld2, 16, 0x3400015C, 0
    .ascii  "MEM0"
    .long   ct_ld2, 16, 0x32000020, 0
    .ascii  "CHC "
    .long   ct_ld4, 16, CHCTR, 0
    .ascii  "STRP"
    .long   ct_ld2, 16, STRAP, 0
    .ascii  "RAS4"                  # stores: the scratch, cached view
    .long   ct_st4, 128, CT_SCR, 0
    .ascii  "RAS2"
    .long   ct_st2, 128, CT_SCR, 0
    .ascii  "RAS1"
    .long   ct_st1, 128, CT_SCR, 0
    .ascii  "RAX4"
    .long   ct_sw4, 32, CT_SCR+0x8000+0x1000, 0
    .ascii  "RAY4"
    .long   ct_sq4, 16, CT_SCR+0x100, 0
    .ascii  "RUS4"                  # the scratch, uncached view
    .long   ct_st4, 16, CT_SCR+CT_UNC+0x40, 0
    .ascii  "RUS2"
    .long   ct_st2, 16, CT_SCR+CT_UNC+0x40, 0
    .ascii  "RUS1"
    .long   ct_st1, 16, CT_SCR+CT_UNC+0x40, 0
    .ascii  "RUY4"
    .long   ct_sq4, 16, CT_SCR+CT_UNC+0x800, 0
    .ascii  "LCS4"                  # the LCD, the value already there
    .long   ct_st4, 16, CT_LCD, 0
    .ascii  "LCS2"
    .long   ct_st2, 16, CT_LCD, 0
    .ascii  "LCR4"
    .long   ct_rmw4, 16, CT_LCD, 0
    .ascii  "LCR2"
    .long   ct_rmw2, 16, CT_LCD, 0
    .ascii  "LCM2"
    .long   ct_rmq2, 16, CT_LCD+0x100, 0
CtTestsEnd:

CpuTimeTable:
    .long   nm_cputime, path_cputime, K_CPUTIME, 0, CT_LEN, 0, 0, rg_cputime, dir_cputime
    .long   0, 0, 0, 0, 0, 0, 0

str_title_cpu:  .asciz  "KN7000 CPU TIMING PROBE"
nm_cputime:     .asciz  "cpu_time.bin"
path_cputime:   .asciz  "KN7DUMP\CPUTIME.BIN"
dir_cputime:    .ascii  "CPUTIME BIN"
rg_cputime:     .asciz  "MN10300 timing by TM4: instruction classes, loads and stores per region"
    .align  4
