# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# romdump_dsprate.s -- the DSP probe's pass 8 (OPT_DSPRATE): at what rate does the effects DSP run its frames?
# Included by romdump.s only when it is assembled with -D DSPRATE (Makefile: build/dsprate/KN7APP.BIN), so every
# other build keeps its bytes. README.md, "Pass 8: the frame rate"; the decoder is check_dsp_probe.py.
#
# What pass 6 left open. Every firmware data-port access clears G17ICR's request and waits for the DSP to raise
# it again (893 0x4840AE77), so the accesses come at the DSP's pace: 24.15 us each, 41.4 per ms. MSGR2, the
# kernel's ring-3 pointer I3, stepped 22.5 times per ms. Either the frames run at about 22.5 kHz with FLAG3
# always high and nearly two handshakes per frame, or one handshake per frame at 41.4 kHz or more, FLAG3 high
# on about half the frames. Pass 6's clock (the firmware's millisecond counter) is too coarse to tell.
#
# The fine clock. The firmware's 1 kHz tick is the MN10300's 16-bit timer 4 (893 0x484D707F, 941 0x484D728C:
# TM4BR = 0x7D0, TM4MD = 0x81), whose counter TM4BC counts down at 2 MHz. A stamp is (ms - base) << 16 | TM4BC,
# read race-free: ms, BC, ms again, until ms holds. The probe only reads the timer (TM4BR, TM4MD and TM4BC),
# never writes it; the decoder turns stamps into time.
#
# DSPRATE.BIN, four 32 KB chunks; each chunk is measured in its own converter call (about 1 s at most), then
# written by the dumper's own file writer (DumpStep):
#   chunk 0 (0x8000): the header (0x100); the calibration (CAL_N stamps, CAL_SPIN delay-loop turns apart, no
#     DSP access); the access timing (AT_N pairs: re-latch MSGR2 with the firmware's index write, a stamp, the
#     firmware's data read (low half), a stamp, the data read (high half)); the phase check (PH_N samples, after
#     a delay of (k & 31) * PH_SPIN turns: a stamp, CR0A, a stamp, IIR0A, through the firmware's register read).
#   chunks 1-3: one segment of the I3 series each: I3_N samples, one per millisecond tick: a stamp, MSGR2
#     (the firmware's register read), a stamp.
# It writes nothing to the DSP but what the firmware's routines write for any access (the index latch
# 0x98000000, and 1 to G17ICR before each wait). It never calls the handshake wait itself: only the data read,
# which waits and then reads. The dead flag is checked before every block, every pair and every sample; once it
# is set, or a wait for the millisecond counter times out, nothing more is read, in this chunk or the later ones.

.equ TM4MD,         0x34001080      # MN10300 timer 4: mode (8 bits; the firmware writes 0x81)
.equ TM4BR,         0x34001090      #   reload (16 bits; the firmware writes 0x7D0)
.equ TM4BC,         0x340010A0      #   counter (16 bits, read only)
.equ R_MSGR2,       0x0A            # IOP registers read: MSGR2 (the kernel copies I3 there)
.equ R_IIR0A,       0x60            #   the SPORT0 receive A DMA index
.equ R_CR0A,        0x62            #   and its count
.equ RT_CHUNK,      0x8000          # a chunk: what one converter call measures and the writer writes
.equ RT_SEGS,       3               # chunks 1-3: the I3 series
.equ RT_LEN,        RT_CHUNK*(1+RT_SEGS)
.equ CAL_N,         1024            # calibration stamps
.equ CAL_SPIN,      64              #   delay-loop turns between them
.equ AT_N,          2048            # access timing pairs
.equ PH_N,          240             # phase samples
.equ PH_SPIN,       24              #   delay before sample k: (k & 31) * PH_SPIN + 1 turns (0 to about 50 us)
.equ I3_N,          1000            # I3 samples per segment, one per millisecond tick
.equ STAMP_TRIES,   8               # a stamp reads ms, BC, ms at most this often
.equ RT_CAL,        0x100           # chunk 0: the calibration, 4 bytes per stamp
.equ RT_AT,         RT_CAL+CAL_N*4  #   the access timing, 12 bytes per pair: s1, s2, low half, high half
.equ RT_PH,         RT_AT+AT_N*12   #   the phase check, 16 bytes per sample: s1, CR0A, s2, IIR0A
.equ RT_END0,       RT_PH+PH_N*16   #   = RT_CHUNK
.equ RS_DATA,       0x40            # chunks 1-3: the samples, 12 bytes each: s1, MSGR2, s2

.equ V_RMS0,        VARS+0x200      # the millisecond counter at the start of this chunk: its stamps count from it
.equ V_RSTOP,       VARS+0x204      # 1: something stopped the reads (not found, no clock, dead, a wait timed out)
.equ V_RRETRY,      VARS+0x208      # this chunk's stamps that needed a second read (ms changed under it)
.equ V_RFAIL,       VARS+0x20C      # this chunk's stamps where ms changed STAMP_TRIES times in a row

# Stamp -> d0 = (ms - V_RMS0) << 16 | TM4BC: ms, BC, ms again, until ms is the same twice (STAMP_TRIES at most;
# the last try is taken then). Calls nothing; keeps d2, d3. The caller makes sure the counter was found.
Stamp:
    movm    [d2,d3], (sp)
    mov     (SVC+SV_MSCOUNT), a0
    clr     d0
    cmp     0, a0
    beq     stp_bc
    mov     STAMP_TRIES, d3
stp_try:
    mov     (a0), d0
    movhu   (TM4BC), d1
    mov     (a0), d2
    cmp     d0, d2
    beq     stp_held
    add     -1, d3
    bne     stp_try
    mov     (V_RFAIL), d2
    inc     d2
    mov     d2, (V_RFAIL)
    bra     stp_make
stp_held:
    cmp     STAMP_TRIES, d3
    beq     stp_make
    mov     (V_RRETRY), d2
    inc     d2
    mov     d2, (V_RRETRY)
stp_make:
    mov     (V_RMS0), d2
    sub     d2, d0
    asl     16, d0
    or      d1, d0
    ret     [d2,d3], 8
stp_bc:
    movhu   (TM4BC), d1
    or      d1, d0
    ret     [d2,d3], 8

# DspRateFill(a0 = the file's record): BUF = the chunk at V_POS, measured now. Chunk 0: the header, the
# calibration, the access timing and the phase check; chunks 1-3: one segment of the I3 series each.
DspRateFill:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     BUF, a0                 # zero it: what is not read stays 0
    mov     RT_CHUNK/4, d1
    clr     d0
drf_zero:
    mov     d0, (a0)
    add     4, a0
    add     -1, d1
    bne     drf_zero
    mov     d0, (V_DSTAT)
    mov     d0, (V_RRETRY)
    mov     d0, (V_RFAIL)
    mov     (V_DSPOK), d0
    cmp     0, d0
    beq     drf_which
    mov     DS_FOUND, d0
    call    SetStat, 0, 0
drf_which:
    mov     (V_POS), d0
    lsr     15, d0                  # the chunk
    cmp     0, d0
    bne     drf_seg
    call    DrBlock0, 0, 0
    bra     drf_ret
drf_seg:
    call    DrSegment, 0, 0
drf_ret:
    ret     [d2,d3,a2,a3], 0x30

DrStop:                             # leaf: d0 = DS_* bits to add; V_RSTOP = 1
    mov     (V_DSTAT), d1
    or      d1, d0
    mov     d0, (V_DSTAT)
    mov     1, d0
    mov     d0, (V_RSTOP)
    rets

# ---- chunk 0 -------------------------------------------------------------------------------------------------
#   0x00 "DSPRATE1", 0x08 status (DS_*), 0x0C ms at start (the stamps' base), 0x10 ms at end, 0x14/0x18 dead flag
#   before/after, 0x1C downloaded flag, 0x20 TM4BR, 0x24 TM4MD, 0x28 TM4BC (one read at the start), 0x2C G17ICR
#   at the start, 0x30-0x4F what DspFind found, 0x50 CAL_N, 0x54 CAL_SPIN, 0x58 AT_N, 0x5C pairs done, 0x60 PH_N,
#   0x64 phase samples done, 0x68 PH_SPIN, 0x6C I3_N, 0x70 RT_SEGS, 0x74 stamps retried, 0x78 stamps failed,
#   0x7C the stamp after the last pair, 0x80 RT_CAL, 0x84 RT_AT, 0x88 RT_PH, 0x8C RS_DATA, 0x90 RT_CHUNK,
#   0x94 the registers (MSGR2 | IIR0A << 8 | CR0A << 16), 0x98 G17ICR at the end, 0x9C STAMP_TRIES.
DrBlock0:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     BUF, a2
    mov     0x52505344, d0          # "DSPR"
    mov     d0, (a2)
    mov     0x31455441, d0          # "ATE1"
    mov     d0, (4, a2)
    clr     d0
    mov     d0, (V_RSTOP)
    call    DspHeadFound, 0, 0
    call    MsNow, 0, 0
    mov     d0, (0x0C, a2)
    mov     d0, (V_RMS0)
    call    DeadFlag, 0, 0
    mov     d0, (0x14, a2)
    call    DownFlag, 0, 0
    mov     d0, (0x1C, a2)
    movhu   (TM4BR), d0             # the timer, read only
    mov     d0, (0x20, a2)
    movbu   (TM4MD), d0
    mov     d0, (0x24, a2)
    movhu   (TM4BC), d0
    mov     d0, (0x28, a2)
    call    Icr17, 0, 0
    mov     d0, (0x2C, a2)
    mov     CAL_N, d0
    mov     d0, (0x50, a2)
    mov     CAL_SPIN, d0
    mov     d0, (0x54, a2)
    mov     AT_N, d0
    mov     d0, (0x58, a2)
    mov     PH_N, d0
    mov     d0, (0x60, a2)
    mov     PH_SPIN, d0
    mov     d0, (0x68, a2)
    mov     I3_N, d0
    mov     d0, (0x6C, a2)
    mov     RT_SEGS, d0
    mov     d0, (0x70, a2)
    mov     RT_CAL, d0
    mov     d0, (0x80, a2)
    mov     RT_AT, d0
    mov     d0, (0x84, a2)
    mov     RT_PH, d0
    mov     d0, (0x88, a2)
    mov     RS_DATA, d0
    mov     d0, (0x8C, a2)
    mov     RT_CHUNK, d0
    mov     d0, (0x90, a2)
    mov     R_MSGR2|R_IIR0A<<8|R_CR0A<<16, d0
    mov     d0, (0x94, a2)
    mov     STAMP_TRIES, d0
    mov     d0, (0x9C, a2)
    mov     (V_DSPOK), d0           # nothing found: the DSP is not touched, now or in the later chunks
    cmp     0, d0
    bne     db_found
    clr     d0
    call    DrStop, 0, 0
    bra     db_end
db_found:
    mov     (SVC+SV_MSCOUNT), d0    # no millisecond counter: no clock, nothing to measure
    cmp     0, d0
    bne     db_clock
    mov     DS_NOCLOCK, d0
    call    DrStop, 0, 0
    bra     db_end
db_clock:
    call    DeadFlag, 0, 0
    cmp     0, d0
    beq     db_cal
    mov     DS_DEADBEFORE, d0
    call    DrStop, 0, 0
    bra     db_end
db_cal:                             # the calibration: stamps only, no DSP access
    mov     BUF+RT_CAL, a3
    clr     d2
db_calloop:
    call    Stamp, 0, 0
    mov     d0, (a3)
    add     4, a3
    mov     CAL_SPIN, d0
db_calspin:
    add     -1, d0
    bne     db_calspin
    inc     d2
    cmp     CAL_N, d2
    bcs     db_calloop
    mov     BUF+RT_AT, a3           # the access timing
    clr     d2
db_at:
    call    DeadFlag, 0, 0
    cmp     0, d0
    bne     db_atdead
    mov     R_MSGR2, d0             # (re-)latch MSGR2: the firmware's index write, which does not wait
    call    DspIndex, 0, 0
    call    Stamp, 0, 0
    mov     d0, (a3)
    call    DspData, 0, 0           # the low half: the firmware's guarded data read (handshake, then the port)
    movhu   d0, (8, a3)
    call    Stamp, 0, 0
    mov     d0, (4, a3)
    call    DspData, 0, 0           # the high half
    movhu   d0, (10, a3)
    add     12, a3
    inc     d2
    mov     d2, (0x5C, a2)
    cmp     AT_N, d2
    bcs     db_at
    call    Stamp, 0, 0
    mov     d0, (0x7C, a2)
    bra     db_phase
db_atdead:
    call    Stamp, 0, 0
    mov     d0, (0x7C, a2)
    mov     DS_DEADDURING, d0
    call    DrStop, 0, 0
    bra     db_end
db_phase:                           # the phase check
    mov     BUF+RT_PH, a3
    clr     d2
db_ph:
    mov     d2, d0                  # a delay that moves the start through the frame
    and     31, d0
    mov     PH_SPIN, d1
    mulu    d1, d0
    add     1, d0
db_phspin:
    add     -1, d0
    bne     db_phspin
    call    DeadFlag, 0, 0
    cmp     0, d0
    beq     db_phgo
    mov     DS_DEADDURING, d0
    call    DrStop, 0, 0
    bra     db_end
db_phgo:
    call    Stamp, 0, 0
    mov     d0, (a3)
    mov     R_CR0A, d0
    call    DspRead, 0, 0
    mov     d0, (4, a3)
    call    Stamp, 0, 0
    mov     d0, (8, a3)
    mov     R_IIR0A, d0
    call    DspRead, 0, 0
    mov     d0, (12, a3)
    add     16, a3
    inc     d2
    mov     d2, (0x64, a2)
    cmp     PH_N, d2
    bcs     db_ph
db_end:
    call    MsNow, 0, 0
    mov     d0, (0x10, a2)
    call    DeadFlag, 0, 0
    mov     d0, (0x18, a2)
    call    Icr17, 0, 0
    mov     d0, (0x98, a2)
    mov     (V_RRETRY), d0
    mov     d0, (0x74, a2)
    mov     (V_RFAIL), d0
    mov     d0, (0x78, a2)
    mov     (V_DSTAT), d0
    mov     d0, (8, a2)
    ret     [d2,d3,a2,a3], 0x30

# ---- chunks 1-3: the I3 series -------------------------------------------------------------------------------
# DrSegment(d0 = the chunk, 1-3). 0x00 "DSPRSEGn" (n = the chunk), 0x08 status, 0x0C ms at start (the stamps'
#   base), 0x10 ms at end, 0x14/0x18 dead flag before/after, 0x1C I3_N, 0x20 samples taken, 0x24 the chunk,
#   0x28 stamps retried, 0x2C stamps failed, 0x30 G17ICR at the end; RS_DATA: the samples, one per tick: a stamp,
#   MSGR2 (the firmware's register read, its low half's sign put right), a stamp.
DrSegment:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     BUF, a2
    mov     d0, (0x24, a2)
    mov     0x52505344, d1          # "DSPR"
    mov     d1, (a2)
    asl     24, d0
    mov     0x30474553, d1          # "SEG0" + the chunk
    add     d1, d0
    mov     d0, (4, a2)
    mov     I3_N, d0
    mov     d0, (0x1C, a2)
    call    MsNow, 0, 0
    mov     d0, (0x0C, a2)
    mov     d0, (V_RMS0)
    call    DeadFlag, 0, 0
    mov     d0, (0x14, a2)
    mov     (V_RSTOP), d0           # an earlier block stopped: read nothing
    cmp     0, d0
    beq     ds3_go
    mov     DS_SKIPPED, d0
    call    SetStat, 0, 0
    bra     ds3_end
ds3_go:
    call    DeadFlag, 0, 0
    cmp     0, d0
    beq     ds3_alive
    mov     DS_DEADBEFORE, d0
    call    DrStop, 0, 0
    bra     ds3_end
ds3_alive:
    mov     BUF+RS_DATA, a3
    clr     d2                      # samples
    call    MsNow, 0, 0
    add     1, d0
    mov     d0, d3                  # wait for the next tick
ds3_sample:
    mov     WAIT_SPINS, d0
    mov     d0, (0x14, sp)
ds3_wait:
    call    MsNow, 0, 0
    sub     d3, d0
    cmp     0, d0
    bge     ds3_take
    mov     (0x14, sp), d0
    add     -1, d0
    mov     d0, (0x14, sp)
    bne     ds3_wait
    mov     DS_WAITOUT, d0          # the counter stopped: read nothing more
    call    DrStop, 0, 0
    bra     ds3_end
ds3_take:
    call    DeadFlag, 0, 0
    cmp     0, d0
    beq     ds3_read
    mov     DS_DEADDURING, d0
    call    DrStop, 0, 0
    bra     ds3_end
ds3_read:
    call    Stamp, 0, 0
    mov     d0, (a3)
    mov     R_MSGR2, d0
    call    DspRead, 0, 0
    mov     d0, (4, a3)
    call    Stamp, 0, 0
    mov     d0, (8, a3)
    add     12, a3
    inc     d2
    mov     d2, (0x20, a2)
    call    MsNow, 0, 0
    add     1, d0
    mov     d0, d3                  # the next tick
    cmp     I3_N, d2
    bcs     ds3_sample
ds3_end:
    call    MsNow, 0, 0
    mov     d0, (0x10, a2)
    call    DeadFlag, 0, 0
    mov     d0, (0x18, a2)
    call    Icr17, 0, 0
    mov     d0, (0x30, a2)
    mov     (V_RRETRY), d0
    mov     d0, (0x28, a2)
    mov     (V_RFAIL), d0
    mov     d0, (0x2C, a2)
    mov     (V_DSTAT), d0
    mov     d0, (8, a2)
    ret     [d2,d3,a2,a3], 0x30

    .align  4
DspRateTable:
    .long   nm_dsprate, path_dsprate, K_DSPRATE, 0, RT_LEN, 0, 0, rg_dsprate, dir_dsprate
    .long   0, 0, 0, 0, 0, 0, 0

nm_dsprate:     .asciz  "dsp_rate.bin"
path_dsprate:   .asciz  "KN7DUMP\DSPRATE.BIN"
dir_dsprate:    .ascii  "DSPRATE BIN"
rg_dsprate:     .asciz  "DSP frame rate: TM4 clock, MSGR2 access times, CR0A/IIR0A, I3 over 3 s"
    .align  4
