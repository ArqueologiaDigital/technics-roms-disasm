# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# romdump_dsp.s -- the effects-DSP probe (OPT_DSP, OPT_DSPMEM), included by romdump.s. README.md, "The DSP probe".
#
# The KN7000's ADSP-21065L (IC306) is host-booted by the main CPU through a 16-bit register-indirect port: the
# IOP register address is written to 0x98000000, its contents move through 0x9C000000, two 16-bit halves per
# 32-bit register, low half first (notes: kn7000_mame/notes/dsp-host-interface.md). Nothing here drives that
# port itself. DspFind finds the firmware's own routines by masked signatures, as the loader finds its file
# routines, and the probe calls them: the register read and write, the index write, the 16-bit data read. They
# keep the firmware's lock, its handshake wait (INTC group 0x17) and its "DSP dead" guard.
#
# Phase 1 (OPT_DSP) only reads: the host side (DSPHOST.BIN), every IOP register whose read has no side effect
# (DSPIOP.BIN), and a time series of the timers and SPORT DMA counts (DSPTIME.BIN).
# Phase 2 (OPT_DSPMEM) reads DSP memory back through external-port DMA channel 8 run in transmit direction
# (internal memory -> EPB0 -> host): it writes DMAC0, IIEP0, IMEP0 and CEP0, and writes them back afterwards.
#
# Each file starts with a header of u32 words (magic, status DS_* bits, time stamps, what was found); the
# PC-side decoder is check_dsp_probe.py.

.equ IOP_NREAD,     102             # the bits set in IopMask (check_dsp_probe.py --mask-asm prints both)
.equ ICR17,         0x3400015C      # INTC G17ICR: the firmware's DSP handshake group (read only, here)
.equ ICR_BASE,      0x34000100      # G0ICR; 64 groups of 4 bytes
.equ HOSTRAM_LEN,   0x500           # the firmware's DSP variables: the 256-byte page of the dead flag, one before,
                                    # three after (893: 0x50006500-0x500069FF, the 146-entry table at 0x500066DC)
.equ SLOW_N,        200             # DSPTIME: samples, SLOW_MS apart
.equ SLOW_MS,       5
.equ SLOW_W,        21              #   words per sample: ms at start, ms at end, the 19 SlowRegs
.equ BURST_N,       256             #   then back-to-back samples
.equ BURST_W,       5               #   words per burst sample: ms, the 4 BurstRegs
.equ WAIT_SPINS,    2000000         # most calls to MsNow while waiting SLOW_MS (far more than 5 ms takes)
.equ DELAY_5MS,     77000           # without a ms counter: a delay loop of about 5 ms (loader.s HOLD_SPIN)
.equ FS_POLLS,      1000            # phase 2: most DMAC0 reads waiting for EPB0 to hold a word
.equ DMAC_FLSH,     0x2000          # DMAC0 bits (TRM Table E-16): FLSH flushes EPB0 and the packing state
.equ DMAC_PM,       0xA5            #   DEN | TRAN | DTYPE (48-bit instructions) | PMODE 10 (16 <-> 48)
.equ DMAC_DM,       0x45            #   DEN | TRAN | PMODE 01 (16 <-> 32); MSWF 0: LSW first; slave mode
.equ DMAC_KEEP,     0x1FE4          #   what is written back: not DEN, CHEN, the read-only PS/FS, not FLSH

# ================================================================================================
# FindSig and CountSig, as in loader.s: FindSig(a0 = signature, d0 = start, d1 = end) -> d0 = first address in
# [start, end) where it matches, or 0. Elements are 16-bit: 0x00nn = byte nn, 0x0100 = any byte, 0xFFFF = end.
CountSig:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a0, a2
    mov     d1, d3
    clr     d2
    mov     d2, (V_LASTHIT)
dcs_next:
    mov     a2, a0
    mov     d3, d1
    call    FindSig, 0, 0
    cmp     0, d0
    beq     dcs_done
    cmp     0, d2
    bne     dcs_more
    mov     d0, (V_LASTHIT)
dcs_more:
    inc     d2
    inc     d0
    bra     dcs_next
dcs_done:
    mov     d2, d0
    ret     [d2,d3,a2,a3], 0x30

FindSig:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a0, a2
    movhu   (a2), d3
    mov     d0, a3
    mov     d1, (0x14, sp)
dfs_loop:
    mov     (0x14, sp), d0
    cmp     d0, a3
    bcc     dfs_none
    movbu   (a3), d2
    cmp     d3, d2
    bne     dfs_next
    mov     a2, a0
    mov     a3, a1
dfs_cmp:
    movhu   (a0), d2
    mov     0xFFFF, d0
    cmp     d0, d2
    beq     dfs_hit
    btst    0x100, d2
    bne     dfs_any
    movbu   (a1), d1
    cmp     d2, d1
    bne     dfs_next
dfs_any:
    add     2, a0
    inc     a1
    bra     dfs_cmp
dfs_next:
    inc     a3
    bra     dfs_loop
dfs_hit:
    mov     a3, d0
    bra     dfs_ret
dfs_none:
    clr     d0
dfs_ret:
    ret     [d2,d3,a2,a3], 0x30

# CallTarget (leaf): a0 = address of a "call d16, regs, imm8" (cd lo hi regs imm) -> d0 = its target, d1 = its imm8
# (the frame it allocates); d0 = 0 when a0 holds no such instruction.
CallTarget:
    movbu   (a0), d0
    cmp     0xCD, d0
    bne     dct_none
    movbu   (2, a0), d0
    asl     8, d0
    movbu   (1, a0), d1
    or      d1, d0
    exth    d0
    mov     a0, d1
    add     d1, d0
    movbu   (4, a0), d1
    rets
dct_none:
    clr     d0
    rets

# CheckEntry (leaf): d0 = a function body, d1 = the frame its callers allocate -> d0 = the entry `calls` needs,
# body - 3, which must be "add -frame, sp" (f8 fe -frame); or 0.
CheckEntry:
    mov     d0, a0
    add     -3, a0
    movbu   (a0), d0
    cmp     0xF8, d0
    bne     dce_no
    movbu   (1, a0), d0
    cmp     0xFE, d0
    bne     dce_no
    movbu   (2, a0), d0
    add     d1, d0
    and     0xFF, d0
    bne     dce_no
    mov     a0, d0
    rets
dce_no:
    clr     d0
    rets

# ================================================================================================
# DspFind: the firmware's DSP host-port routines (941 / 893 addresses):
#   sig_dspwait  the handshake wait (0x48404D25 / 0x4840AE77): its operands are the "kernel downloaded" flag
#                (+0x0F; 0x500066CD / 0x500066D9) and the "DSP dead" flag (+0x36; 0x500066CC / 0x500066D8);
#   sig_dspregs  the 2x16 register write and read, back to back with their bus-timing twins (0x484052DD /
#                0x4840B3F5; the read at +0x3E, 0x4840531B / 0x4840B433).
# The read's own calls lead to the index write (body + 6) and the guarded data read (body + 0xE). Each must
# start with the "add -frame, sp" its caller's call allocates, and the data read must test the same dead flag.
# Each signature must match exactly once in 0x48400000-0x487FFFFF. Only when all of it holds is V_DSPOK set;
# otherwise the probe does not touch the DSP at all.
DspFind:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    clr     d2
    clr     d0
    mov     d0, (V_DSPOK)
    mov     d0, (V_DWAIT)
    mov     d0, (V_DREGWR)
    mov     d0, (V_DREGRD)
    mov     d0, (V_DIDXWR)
    mov     d0, (V_DDATARD)
    mov     d0, (V_DDEAD)
    mov     d0, (V_DDOWN)
    mov     sig_dspwait, a0
    mov     0x48400000, d0
    mov     0x48800000, d1
    call    CountSig, 0, 0
    cmp     1, d0
    bne     dfd_regs
    or      DF_WAIT, d2
    mov     (V_LASTHIT), a2
    mov     a2, (V_DWAIT)
    mov     a2, a0
    add     0x0F, a0
    call    Read32U, 0, 0           # movbu (downloaded), d0
    mov     d0, (V_DDOWN)
    mov     a2, a0
    add     0x36, a0
    call    Read32U, 0, 0           # movbu d0, (dead)
    mov     d0, (V_DDEAD)
dfd_regs:
    mov     sig_dspregs, a0
    mov     0x48400000, d0
    mov     0x48800000, d1
    call    CountSig, 0, 0
    cmp     1, d0
    bne     dfd_end
    or      DF_REGS, d2
    mov     (V_LASTHIT), a2
    mov     a2, (V_DREGWR)
    mov     a2, a0
    add     0x3E, a0
    mov     a0, (V_DREGRD)
    add     9, a0                   # the read's body + 6: call DspAddrWrite
    call    CallTarget, 0, 0
    cmp     0, d0
    beq     dfd_data
    call    CheckEntry, 0, 0
    cmp     0, d0
    beq     dfd_data
    mov     d0, (V_DIDXWR)
    or      DF_IDX, d2
dfd_data:
    mov     (V_DREGRD), a0
    add     0x11, a0                # the read's body + 0xE: call the guarded data read
    call    CallTarget, 0, 0
    cmp     0, d0
    beq     dfd_end
    mov     d0, a3                  # its body: movbu (dead), d0 = fc a8 <dead>
    call    CheckEntry, 0, 0
    cmp     0, d0
    beq     dfd_end
    mov     d0, (V_DDATARD)
    movbu   (a3), d0
    cmp     0xFC, d0
    bne     dfd_end
    movbu   (1, a3), d0
    cmp     0xA8, d0
    bne     dfd_end
    mov     a3, a0
    add     2, a0
    call    Read32U, 0, 0
    mov     (V_DDEAD), d1
    cmp     d1, d0
    bne     dfd_end
    or      DF_DATA, d2
dfd_end:
    mov     d2, (V_DFOUND)
    cmp     DF_WAIT|DF_REGS|DF_IDX|DF_DATA, d2
    bne     dfd_ret
    mov     1, d0
    mov     d0, (V_DSPOK)
dfd_ret:
    ret     [d2,d3,a2,a3], 0x30

# ================================================================================================
# Calls into the firmware (each makes a frame: the firmware's routines store into 4..0x10(sp) of their caller).
# DspRead(d0 = IOP register) -> d0 = its 32 bits. The firmware's read returns (high << 16) + the low half
# sign-extended; when the low half's bit 15 is set that is 0x10000 short, which is added back here.
DspRead:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     (V_DREGRD), a0
    calls   (a0)
    btst    0x8000, d0
    beq     drd_ret
    mov     0x10000, d1
    add     d1, d0
drd_ret:
    ret     [d2,d3,a2,a3], 0x30

# DspWrite(d0 = IOP register, d1 = 32-bit value): the firmware's 2x16 register write, low half first.
DspWrite:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     d1, d2
    and     0xFFFF, d2
    mov     d2, (0x10, sp)          # its third argument: the low half
    lsr     16, d1                  # d1: the high half
    mov     (V_DREGWR), a0
    calls   (a0)
    ret     [d2,d3,a2,a3], 0x30

DspIndex:                           # d0 = the index to latch at 0x98000000 (the firmware's guarded write)
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     (V_DIDXWR), a0
    calls   (a0)
    ret     [d2,d3,a2,a3], 0x30

DspData:                            # -> d0 = one 16-bit read of 0x9C000000 (0xFFFF once the DSP is "dead")
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     (V_DDATARD), a0
    calls   (a0)
    exthu   d0
    ret     [d2,d3,a2,a3], 0x30

DeadFlag:                           # leaf -> d0 = the firmware's dead flag byte (0 when not found)
    mov     (V_DDEAD), a0
    clr     d0
    cmp     0, a0
    beq     dfl_ret
    movbu   (a0), d0
dfl_ret:
    rets

DownFlag:                           # leaf -> d0 = the "kernel downloaded" flag byte (0 when not found)
    mov     (V_DDOWN), a0
    clr     d0
    cmp     0, a0
    beq     ddl_ret
    movbu   (a0), d0
ddl_ret:
    rets

MsNow:                              # leaf -> d0 = the kernel's millisecond counter, or 0 without it
    mov     (SVC+SV_MSCOUNT), a0
    clr     d0
    cmp     0, a0
    beq     dms_ret
    mov     (a0), d0
dms_ret:
    rets

Icr17:                              # leaf -> d0 = G17ICR, the handshake group's interrupt control register
    movhu   (ICR17), d0
    rets

SetStat:                            # leaf: V_DSTAT |= d0
    mov     (V_DSTAT), d1
    or      d1, d0
    mov     d0, (V_DSTAT)
    rets

# ================================================================================================
# DspFill(a0 = the file's record): builds the whole file in BUF (R_LEN bytes, at most one chunk).
DspFill:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a0, a2
    mov     BUF, a0                 # zero it: what is not read stays 0
    mov     (R_LEN, a2), d1
    lsr     2, d1
    clr     d0
dfi_zero:
    mov     d0, (a0)
    add     4, a0
    add     -1, d1
    bne     dfi_zero
    mov     d0, (V_DSTAT)
    mov     d0, (V_DPOLLS)
    mov     d0, (V_DPOLLMAX)
    mov     d0, (V_DWORDS)
    mov     (V_DSPOK), d0
    cmp     0, d0
    beq     dfi_kind
    mov     DS_FOUND, d0
    call    SetStat, 0, 0
dfi_kind:
    mov     (R_KIND, a2), d0
    cmp     K_DSPHOST, d0
    bne     dfi_1
    call    DspHost, 0, 0
    bra     dfi_ret
dfi_1:
    cmp     K_DSPIOP, d0
    bne     dfi_2
    call    DspIop, 0, 0
    bra     dfi_ret
dfi_2:
    cmp     K_DSPTIME, d0
    bne     dfi_3
    call    DspTime, 0, 0
    bra     dfi_ret
dfi_3:
    cmp     K_DSPPM, d0
    bne     dfi_4
    call    DspPm, 0, 0
    bra     dfi_ret
dfi_4:
    call    DspDm, 0, 0
dfi_ret:
    ret     [d2,d3,a2,a3], 0x30

# DspHeadFound: BUF+0x30.. = what DspFind found (leaf). Every header has these at 0x30-0x4F.
DspHeadFound:
    mov     BUF, a0
    mov     (V_DFOUND), d0
    mov     d0, (0x30, a0)
    mov     (V_DWAIT), d0
    mov     d0, (0x34, a0)
    mov     (V_DREGWR), d0
    mov     d0, (0x38, a0)
    mov     (V_DREGRD), d0
    mov     d0, (0x3C, a0)
    mov     (V_DIDXWR), d0
    mov     d0, (0x40, a0)
    mov     (V_DDATARD), d0
    mov     d0, (0x44, a0)
    mov     (V_DDEAD), d0
    mov     d0, (0x48, a0)
    mov     (V_DDOWN), d0
    mov     d0, (0x4C, a0)
    rets

# ---- DSPHOST.BIN (0x650 bytes): the main CPU's side, plain reads, no DSP access ---------------------
#   0x00 "DSPHOST1", 0x08 status, 0x0C ms, 0x10 dead flag, 0x14 downloaded flag (their values, bytes),
#   0x18 G17ICR, 0x1C RAM base, 0x20 RAM length, 0x30-0x4F what DspFind found;
#   0x50 G0ICR-G63ICR (0x34000100 + 4n, 16 bits each in a u32 word); 0x150 the firmware's DSP variables,
#   HOSTRAM_LEN bytes from the dead flag's 256-byte page minus 0x100 (0x50006500 when not found).
DspHost:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     BUF, a2
    mov     0x48505344, d0          # "DSPH"
    mov     d0, (a2)
    mov     0x3154534F, d0          # "OST1"
    mov     d0, (4, a2)
    call    MsNow, 0, 0
    mov     d0, (0x0C, a2)
    call    DeadFlag, 0, 0
    mov     d0, (0x10, a2)
    call    DownFlag, 0, 0
    mov     d0, (0x14, a2)
    call    Icr17, 0, 0
    mov     d0, (0x18, a2)
    call    DspHeadFound, 0, 0
    mov     0x50006500, d3
    mov     (V_DDEAD), d0
    cmp     0, d0
    beq     dh_base
    mov     0xFFFFFF00, d1
    and     d1, d0
    mov     0x100, d1
    sub     d1, d0
    mov     d0, d3
dh_base:
    mov     d3, (0x1C, a2)
    mov     HOSTRAM_LEN, d0
    mov     d0, (0x20, a2)
    mov     ICR_BASE, a0
    mov     BUF+0x50, a1
    mov     64, d1
dh_icr:
    movhu   (a0), d0
    mov     d0, (a1)
    add     4, a0
    add     4, a1
    add     -1, d1
    bne     dh_icr
    mov     d3, a0
    mov     BUF+0x150, a1
    mov     HOSTRAM_LEN/4, d1
dh_ram:
    mov     (a0), d0
    mov     d0, (a1)
    add     4, a0
    add     4, a1
    add     -1, d1
    bne     dh_ram
    mov     (V_DSTAT), d0
    mov     d0, (8, a2)
    ret     [d2,d3,a2,a3], 0x30

# ---- DSPIOP.BIN (0x870 bytes): the IOP registers, read-only, twice -------------------------------------
#   0x00 "DSPIOP01", 0x08 status, 0x0C ms at start, 0x10 ms at end, 0x14/0x18 dead flag before/after,
#   0x1C/0x20 downloaded flag before/after, 0x24/0x28 G17ICR before/after, 0x2C registers read per pass,
#   0x30-0x4F what DspFind found; 0x50 IopMask (32 bytes, bit n = register n is read); 0x70 pass A, 0x470 pass B:
#   256 u32 each, register n at 4n (0 where not read).
DspIop:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     BUF, a2
    mov     0x49505344, d0          # "DSPI"
    mov     d0, (a2)
    mov     0x3130504F, d0          # "OP01"
    mov     d0, (4, a2)
    call    DspHeadFound, 0, 0
    mov     IOP_NREAD, d0
    mov     d0, (0x2C, a2)
    mov     IopMask, a0
    mov     BUF+0x50, a1
    mov     8, d1
di_mask:
    mov     (a0), d0
    mov     d0, (a1)
    add     4, a0
    add     4, a1
    add     -1, d1
    bne     di_mask
    call    MsNow, 0, 0
    mov     d0, (0x0C, a2)
    call    DeadFlag, 0, 0
    mov     d0, (0x14, a2)
    call    DownFlag, 0, 0
    mov     d0, (0x1C, a2)
    call    Icr17, 0, 0
    mov     d0, (0x24, a2)
    mov     (V_DSPOK), d0
    cmp     0, d0
    beq     di_end
    call    DeadFlag, 0, 0
    cmp     0, d0
    beq     di_go
    mov     DS_DEADBEFORE, d0
    call    SetStat, 0, 0
    bra     di_end
di_go:
    clr     d2                      # pass
di_pass:
    clr     d3                      # register
di_reg:
    mov     d3, d0
    lsr     3, d0
    mov     IopMask, a0
    add     d0, a0
    movbu   (a0), d0
    mov     d3, d1
    and     7, d1
    lsr     d1, d0
    btst    1, d0
    beq     di_next
    call    DeadFlag, 0, 0
    cmp     0, d0
    beq     di_read
    mov     DS_DEADDURING, d0
    call    SetStat, 0, 0
    bra     di_end
di_read:
    mov     d3, d0
    call    DspRead, 0, 0
    mov     BUF+0x70, a0
    mov     d2, d1
    asl     10, d1
    add     d1, a0
    mov     d3, d1
    asl     2, d1
    add     d1, a0
    mov     d0, (a0)
di_next:
    inc     d3
    cmp     256, d3
    bne     di_reg
    inc     d2
    cmp     2, d2
    bne     di_pass
di_end:
    call    MsNow, 0, 0
    mov     d0, (0x10, a2)
    call    DeadFlag, 0, 0
    mov     d0, (0x18, a2)
    call    DownFlag, 0, 0
    mov     d0, (0x20, a2)
    call    Icr17, 0, 0
    mov     d0, (0x28, a2)
    mov     (V_DSTAT), d0
    mov     d0, (8, a2)
    ret     [d2,d3,a2,a3], 0x30

# ---- DSPTIME.BIN (0x55F0 bytes): what moves, over time ------------------------------------------------
#   0x00 "DSPTIME1", 0x08 status, 0x0C SLOW_N, 0x10 SLOW_MS, 0x14 BURST_N, 0x18 ms at start, 0x1C ms at end,
#   0x20/0x24 dead flag before/after, 0x28 SLOW_W, 0x2C BURST_W, 0x30-0x4F what DspFind found;
#   0x50 SLOW_N samples of SLOW_W u32: ms at start, ms at end, then SlowRegs in that order;
#   0x41F0 BURST_N samples of BURST_W u32: ms, then BurstRegs. Samples not taken stay 0.
.equ DT_SLOW,       0x50
.equ DT_BURST,      0x50+SLOW_N*SLOW_W*4
DspTime:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     BUF, a2
    mov     0x54505344, d0          # "DSPT"
    mov     d0, (a2)
    mov     0x31454D49, d0          # "IME1"
    mov     d0, (4, a2)
    mov     SLOW_N, d0
    mov     d0, (0x0C, a2)
    mov     SLOW_MS, d0
    mov     d0, (0x10, a2)
    mov     BURST_N, d0
    mov     d0, (0x14, a2)
    mov     SLOW_W, d0
    mov     d0, (0x28, a2)
    mov     BURST_W, d0
    mov     d0, (0x2C, a2)
    call    DspHeadFound, 0, 0
    call    DeadFlag, 0, 0
    mov     d0, (0x20, a2)
    mov     (SVC+SV_MSCOUNT), d0
    cmp     0, d0
    bne     dt_clock
    mov     DS_NOCLOCK, d0
    call    SetStat, 0, 0
dt_clock:
    call    MsNow, 0, 0
    mov     d0, (0x18, a2)
    mov     d0, (0x14, sp)          # t0
    mov     (V_DSPOK), d0
    cmp     0, d0
    beq     dt_end
    call    DeadFlag, 0, 0
    cmp     0, d0
    beq     dt_go
    mov     DS_DEADBEFORE, d0
    call    SetStat, 0, 0
    bra     dt_end
dt_go:
    clr     d2                      # sample
    mov     BUF+DT_SLOW, a3
dt_sample:
    mov     (V_DSTAT), d0           # wait for t0 + SLOW_MS * sample (a delay loop without the counter)
    btst    DS_NOCLOCK, d0
    beq     dt_waitms
    mov     DELAY_5MS, d0
dt_spin:
    add     -1, d0
    bne     dt_spin
    bra     dt_take
dt_waitms:
    mov     d2, d3
    mov     SLOW_MS, d0
    mulu    d0, d3
    mov     (0x14, sp), d0
    add     d0, d3                  # the target
    mov     WAIT_SPINS, d0
    mov     d0, (0x18, sp)
dt_wait:
    call    MsNow, 0, 0
    sub     d3, d0
    cmp     0, d0
    bge     dt_take
    mov     (0x18, sp), d0
    add     -1, d0
    mov     d0, (0x18, sp)
    bne     dt_wait
    mov     DS_WAITOUT, d0
    call    SetStat, 0, 0
dt_take:
    call    DeadFlag, 0, 0
    cmp     0, d0
    beq     dt_alive
    mov     DS_DEADDURING, d0
    call    SetStat, 0, 0
    bra     dt_end
dt_alive:
    call    MsNow, 0, 0
    mov     d0, (a3)                # ms at start
    mov     a3, (0x1C, sp)
    add     8, a3
    clr     d3
dt_reg:
    mov     SlowRegs, a0
    add     d3, a0
    movbu   (a0), d0
    call    DspRead, 0, 0
    mov     d0, (a3)
    add     4, a3
    inc     d3
    cmp     SLOW_W-2, d3
    bne     dt_reg
    call    MsNow, 0, 0
    mov     (0x1C, sp), a0
    mov     d0, (4, a0)             # ms at end
    inc     d2
    cmp     SLOW_N, d2
    bne     dt_sample
    clr     d2                      # the burst: back to back
    mov     BUF+DT_BURST, a3
dt_burst:
    call    DeadFlag, 0, 0
    cmp     0, d0
    beq     dt_balive
    mov     DS_DEADDURING, d0
    call    SetStat, 0, 0
    bra     dt_end
dt_balive:
    call    MsNow, 0, 0
    mov     d0, (a3)
    add     4, a3
    clr     d3
dt_breg:
    mov     BurstRegs, a0
    add     d3, a0
    movbu   (a0), d0
    call    DspRead, 0, 0
    mov     d0, (a3)
    add     4, a3
    inc     d3
    cmp     BURST_W-1, d3
    bne     dt_breg
    inc     d2
    cmp     BURST_N, d2
    bne     dt_burst
dt_end:
    call    MsNow, 0, 0
    mov     d0, (0x1C, a2)
    call    DeadFlag, 0, 0
    mov     d0, (0x24, a2)
    mov     (V_DSTAT), d0
    mov     d0, (8, a2)
    ret     [d2,d3,a2,a3], 0x30

# ================================================================================================
# Phase 2. The header of DSPPM.BIN and DSPDM.BIN (0x80 bytes):
#   0x00 magic, 0x08 status, 0x0C ms at start, 0x10 ms at end, 0x14 SYSCON, 0x18-0x2C before: DMAC0, IIEP0,
#   IMEP0, CEP0, CPEP0, DMASTAT; 0x30-0x4F what DspFind found; 0x50-0x64 after: DMAC0, IIEP0, IMEP0, CEP0,
#   CPEP0, DMASTAT; 0x68 the DMAC0 value used, 0x6C words asked, 0x70 words read, 0x74 FS polls in all,
#   0x78 the most FS polls for one word, 0x7C dead flag at the end.
.equ V_DMODE,       VARS+0x9C       # the DMAC0 value of the readback: DMAC_PM or DMAC_DM
.equ V_DSAVE,       VARS+0xA0       # 6 words: DMAC0, IIEP0, IMEP0, CEP0, CPEP0, DMASTAT as found

# DspMemBegin -> d0 = 1 when the readback may go ahead. Reads SYSCON and the channel-8 registers into the
# header and V_DSAVE; requires: routines found, dead flag clear, SYSCON HBW = 16-bit and LSW first (what
# the firmware set, 0x410), DMAC0 DEN and CHEN clear, DMASTAT channel 8 neither active nor chaining.
DspMemBegin:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     BUF, a2
    clr     d2
    mov     (V_DSPOK), d0
    cmp     0, d0
    beq     dmb_ret
    call    DeadFlag, 0, 0
    cmp     0, d0
    beq     dmb_alive
    mov     DS_DEADBEFORE, d0
    call    SetStat, 0, 0
    bra     dmb_ret
dmb_alive:
    clr     d0
    call    DspRead, 0, 0
    mov     d0, (0x14, a2)
    mov     d0, d3                  # SYSCON
    clr     d2                      # the six channel-8 registers
    mov     V_DSAVE, a3
dmb_save:
    mov     DmaRegs, a0
    add     d2, a0
    movbu   (a0), d0
    call    DspRead, 0, 0
    mov     d0, (a3)
    mov     BUF+0x18, a0
    mov     d2, d1
    asl     2, d1
    add     d1, a0
    mov     d0, (a0)
    add     4, a3
    inc     d2
    cmp     6, d2
    bne     dmb_save
    clr     d2
    mov     d3, d0                  # SYSCON: HBW = 01, HMSWF = 0
    and     0x70, d0
    cmp     0x10, d0
    bne     dmb_bad
    mov     (V_DSAVE), d0           # DMAC0: DEN, CHEN clear
    and     3, d0
    bne     dmb_bad
    mov     (V_DSAVE+20), d0        # DMASTAT: bit 6 channel 8 active, bit 16 channel 8 chaining
    mov     0x10040, d1
    and     d1, d0
    bne     dmb_bad
    mov     1, d2
    bra     dmb_ret
dmb_bad:
    mov     DS_PRECHECK, d0
    call    SetStat, 0, 0
dmb_ret:
    mov     d2, d0
    ret     [d2,d3,a2,a3], 0x30

# DspMemEnd: flush and disable channel 8, write back IIEP0, IMEP0, CEP0 and DMAC0's control bits as found,
# then read the six registers again into the header.
DspMemEnd:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     0x1C, d0
    mov     DMAC_FLSH, d1
    call    DspWrite, 0, 0
    mov     0x40, d0
    mov     (V_DSAVE+4), d1
    call    DspWrite, 0, 0
    mov     0x41, d0
    mov     (V_DSAVE+8), d1
    call    DspWrite, 0, 0
    mov     0x42, d0
    mov     (V_DSAVE+12), d1
    call    DspWrite, 0, 0
    mov     (V_DSAVE), d1
    mov     DMAC_KEEP, d0
    and     d0, d1
    mov     0x1C, d0
    call    DspWrite, 0, 0
    mov     DS_RESTORED, d0
    call    SetStat, 0, 0
    clr     d2
dme_read:
    mov     DmaRegs, a0
    add     d2, a0
    movbu   (a0), d0
    call    DspRead, 0, 0
    mov     BUF+0x50, a0
    mov     d2, d1
    asl     2, d1
    add     d1, a0
    mov     d0, (a0)
    inc     d2
    cmp     6, d2
    bne     dme_read
    ret     [d2,d3,a2,a3], 0x30

# DspReadback(d0 = first address, d1 = words, a0 = out) -> a0 = out after them. Channel 8, slave mode, transmit:
# flush; IIEP0 = address, IMEP0 = 1, CEP0 = words; DMAC0 = V_DMODE. Then per word: read DMAC0 until its FS bits
# say EPB0 holds data (FS_POLLS at most: a read of an empty EPB0 would hold the bus), latch index 4 (EPB0),
# read 3 (PM) or 2 (DM) 16-bit halves, LSW first. Then flush, which also clears DEN. Stops at a timeout or a
# dead flag (status bits); the words not read stay 0.
DspReadback:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     a0, a3
    mov     d0, (0x14, sp)
    mov     d1, (0x18, sp)
    mov     (V_DSTAT), d0           # an earlier range stopped: do nothing more
    mov     DS_FSTIMEOUT|DS_DEADDURING, d1
    and     d1, d0
    bne     drb_skip
    mov     0x1C, d0
    mov     DMAC_FLSH, d1
    call    DspWrite, 0, 0
    mov     0x40, d0
    mov     (0x14, sp), d1
    call    DspWrite, 0, 0
    mov     0x41, d0
    mov     1, d1
    call    DspWrite, 0, 0
    mov     0x42, d0
    mov     (0x18, sp), d1
    call    DspWrite, 0, 0
    mov     0x1C, d0
    mov     (V_DMODE), d1
    call    DspWrite, 0, 0
    clr     d2                      # words read
drb_word:
    mov     (0x18, sp), d0
    cmp     d0, d2
    bcc     drb_done
    clr     d3                      # polls
drb_poll:
    call    DeadFlag, 0, 0
    cmp     0, d0
    beq     drb_alive
    mov     DS_DEADDURING, d0
    call    SetStat, 0, 0
    bra     drb_done
drb_alive:
    mov     0x1C, d0
    call    DspRead, 0, 0
    mov     0xC000, d1              # FS: 00 empty, 10 partly full, 11 full
    and     d1, d0
    bne     drb_data
    inc     d3
    cmp     FS_POLLS, d3
    bcs     drb_poll
    mov     (V_DPOLLS), d0          # counted too: the file shows the timeout's polls
    add     d3, d0
    mov     d0, (V_DPOLLS)
    mov     d3, (V_DPOLLMAX)
    mov     DS_FSTIMEOUT, d0
    call    SetStat, 0, 0
    bra     drb_done
drb_data:
    mov     (V_DPOLLS), d0
    add     d3, d0
    mov     d0, (V_DPOLLS)
    mov     (V_DPOLLMAX), d0
    cmp     d0, d3
    bls     drb_idx
    mov     d3, (V_DPOLLMAX)
drb_idx:
    mov     4, d0
    call    DspIndex, 0, 0
    call    DspData, 0, 0
    movhu   d0, (a3)
    add     2, a3
    call    DspData, 0, 0
    movhu   d0, (a3)
    add     2, a3
    mov     (V_DMODE), d0
    btst    0x20, d0
    beq     drb_next
    call    DspData, 0, 0
    movhu   d0, (a3)
    add     2, a3
drb_next:
    inc     d2
    bra     drb_word
drb_done:
    mov     0x1C, d0
    mov     DMAC_FLSH, d1
    call    DspWrite, 0, 0
    mov     (V_DWORDS), d0
    add     d2, d0
    mov     d0, (V_DWORDS)
drb_skip:
    mov     a3, a0
    ret     [d2,d3,a2,a3], 0x30

DspMemTail:                         # the header's closing fields
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     BUF, a2
    call    MsNow, 0, 0
    mov     d0, (0x10, a2)
    mov     (V_DMODE), d0
    mov     d0, (0x68, a2)
    mov     (V_DWORDS), d0
    mov     d0, (0x70, a2)
    mov     (V_DPOLLS), d0
    mov     d0, (0x74, a2)
    mov     (V_DPOLLMAX), d0
    mov     d0, (0x78, a2)
    call    DeadFlag, 0, 0
    mov     d0, (0x7C, a2)
    mov     (V_DSTAT), d0
    mov     d0, (8, a2)
    ret     [d2,d3,a2,a3], 0x30

# ---- DSPPM.BIN (0x5480 bytes): the header, then PM 0x8000-0x8DFF, 6 bytes per 48-bit word (LSW first) ----
DspPm:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     BUF, a2
    mov     0x50505344, d0          # "DSPP"
    mov     d0, (a2)
    mov     0x3130304D, d0          # "M001"
    mov     d0, (4, a2)
    call    DspHeadFound, 0, 0
    call    MsNow, 0, 0
    mov     d0, (0x0C, a2)
    mov     DMAC_PM, d0
    mov     d0, (V_DMODE)
    mov     0xE00, d0
    mov     d0, (0x6C, a2)
    call    DspMemBegin, 0, 0
    cmp     0, d0
    beq     dpm_end
    mov     0x8000, d0
    mov     0xE00, d1
    mov     BUF+0x80, a0
    call    DspReadback, 0, 0
    call    DspMemEnd, 0, 0
dpm_end:
    call    DspMemTail, 0, 0
    ret     [d2,d3,a2,a3], 0x30

# ---- DSPDM.BIN (0x36A0 bytes): the header; DM 0x9800-0x9FFF (0x80), DM 0xC000-0xC4FF (0x2080), 4 bytes per
# word; then for each SPORT DMA chain pointer in CpRegs (0x3480): its value, and the 16 DM words around the TCB
# it points to, 17 words each. The TCB is taken to be at 0x8000 | (CP & 0x7FFF): internal memory starts at 0x8000,
# and the emulated kernel's pointers (0x4309 ...) are its DM 0xC309 ... less 0x8000; a full address maps the same.
# The window runs from 8 below to 7 above; zeros when it would leave 0x8000-0xFFFF. -------
DspDm:
    movm    [d2,d3,a2,a3], (sp)
    add     -0x20, sp
    mov     BUF, a2
    mov     0x44505344, d0          # "DSPD"
    mov     d0, (a2)
    mov     0x3130304D, d0          # "M001"
    mov     d0, (4, a2)
    call    DspHeadFound, 0, 0
    call    MsNow, 0, 0
    mov     d0, (0x0C, a2)
    mov     DMAC_DM, d0
    mov     d0, (V_DMODE)
    mov     0x800+0x500+8*16, d0
    mov     d0, (0x6C, a2)
    call    DspMemBegin, 0, 0
    cmp     0, d0
    beq     ddm_end
    mov     0x9800, d0
    mov     0x800, d1
    mov     BUF+0x80, a0
    call    DspReadback, 0, 0
    mov     0xC000, d0
    mov     0x500, d1
    mov     BUF+0x2080, a0
    call    DspReadback, 0, 0
    clr     d2                      # the chain pointers: record d2 at 0x3480 + 68 * d2
ddm_cp:
    mov     d2, d0
    mov     68, d1
    mulu    d1, d0
    mov     BUF+0x3480, a3
    add     d0, a3
    mov     CpRegs, a0
    add     d2, a0
    movbu   (a0), d0
    call    DspRead, 0, 0
    mov     d0, (a3)
    mov     0x7FFF, d1
    and     d1, d0
    cmp     8, d0
    bcs     ddm_next
    mov     0x7FF7, d1
    cmp     d1, d0
    bhi     ddm_next
    mov     0x8000, d1
    or      d1, d0
    add     -8, d0
    mov     16, d1
    mov     a3, a0
    add     4, a0
    call    DspReadback, 0, 0
ddm_next:
    inc     d2
    cmp     8, d2
    bne     ddm_cp
    call    DspMemEnd, 0, 0
ddm_end:
    call    DspMemTail, 0, 0
    ret     [d2,d3,a2,a3], 0x30

# ================================================================================================
# Register lists (IOP addresses, TRM Table E-15).
SlowRegs:   # DSPTIME samples: TCOUNT0, TCOUNT1, DMASTAT; SPORT DMA counts CR0A CR0B CR1A CR1B CT0A CT0B CT1A CT1B;
            # their chain pointers in the same order
    .byte   0x2A, 0x2D, 0x37, 0x62, 0x32, 0x6A, 0x3A, 0x72, 0x52, 0x7A, 0x5A
    .byte   0x63, 0x33, 0x6B, 0x3B, 0x73, 0x53, 0x7B, 0x5B
BurstRegs:  # TCOUNT0, TCOUNT1, CT0A, CR0A
    .byte   0x2A, 0x2D, 0x72, 0x62
DmaRegs:    # DMAC0, IIEP0, IMEP0, CEP0, CPEP0, DMASTAT
    .byte   0x1C, 0x40, 0x41, 0x42, 0x43, 0x37
CpRegs:     # CPR0A CPR0B CPR1A CPR1B CPT0A CPT0B CPT1A CPT1B
    .byte   0x63, 0x33, 0x6B, 0x3B, 0x73, 0x53, 0x7B, 0x5B
    .align  4
IopMask:    # bit n: IOP register n is read (check_dsp_probe.py READ: Table E-15 less SIDE_EFFECT)
    .byte   0x0f, 0xff, 0x00, 0x33, 0x01, 0xff, 0x9f, 0x1f, 0xff, 0xff, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x53, 0x3f, 0x53, 0x3f

sig_dspwait:    # the handshake wait (941 0x48404D25); masked: the downloaded and dead flag operands
    .word   0xcf, 0x80, 0xf8, 0xfe, 0xfc, 0xfc, 0xcc, 0xff, 0xff, 0x03, 0x00, 0x42, 0x00, 0xfc
    .word   0xa8, 0x100, 0x100, 0x100, 0x100, 0xa0, 0x00, 0xc9, 0x04, 0xca, 0x32, 0x80, 0x01, 0xfc
    .word   0x83, 0x5c, 0x01, 0x00, 0x34, 0xca, 0x1b, 0x58, 0x00, 0x8a, 0x01, 0x81, 0xf1, 0x09
    .word   0x46, 0x00, 0xa0, 0x00, 0xc8, 0x04, 0xca, 0x0c, 0x80, 0xff, 0xfc, 0x82, 0x100, 0x100
    .word   0x100, 0x100, 0xca, 0x0f, 0xfc, 0xac, 0x5c, 0x01, 0x00, 0x34, 0xf8, 0xec, 0x10, 0xc9
    .word   0x04, 0xca, 0xdc, 0xdf, 0x80, 0x08, 0xFFFF
sig_dspregs:    # 2x16 register write, its bus-timing twin, 2x16 read, its twin (941 0x484052DD); masked: call displacements
    .word   0xf8, 0xfe, 0xf0, 0xf8, 0x97, 0x1c, 0x42, 0x18, 0xf8, 0xbc, 0x18, 0x1c, 0xcd, 0x100
    .word   0x100, 0x00, 0x10, 0xf8, 0xbc, 0x1c, 0xf8, 0xbd, 0x20, 0xcd, 0x100, 0x100, 0x00, 0x10
    .word   0xdf, 0x00, 0x10, 0xf8, 0xfe, 0xf0, 0xf8, 0x97, 0x1c, 0x42, 0x18, 0xf8, 0xbc, 0x18
    .word   0x1c, 0xcd, 0x100, 0x100, 0x00, 0x10, 0xf8, 0xbc, 0x1c, 0xf8, 0xbd, 0x20, 0xcd, 0x100
    .word   0x100, 0x00, 0x10, 0xdf, 0x00, 0x10, 0xf8, 0xfe, 0xe8, 0x42, 0x20, 0xf8, 0xbc, 0x20
    .word   0x1c, 0xcd, 0x100, 0x100, 0x00, 0x10, 0x2c, 0xc4, 0x09, 0xcd, 0x100, 0x100, 0x00, 0x0c
    .word   0x18, 0x42, 0x0c, 0x2c, 0xc4, 0x09, 0xcd, 0x100, 0x100, 0x00, 0x0c, 0x18, 0x42, 0x10
    .word   0x58, 0x10, 0xf8, 0xc0, 0x10, 0x59, 0x0c, 0xe4, 0x42, 0x14, 0xdf, 0x00, 0x18, 0xf8
    .word   0xfe, 0xe8, 0x42, 0x20, 0xf8, 0xbc, 0x20, 0x1c, 0xcd, 0x100, 0x100, 0x00, 0x10, 0x2c
    .word   0xc4, 0x09, 0xcd, 0x100, 0x100, 0x00, 0x14, 0x18, 0x42, 0x0c, 0x2c, 0xc4, 0x09, 0xcd
    .word   0x100, 0x100, 0x00, 0x14, 0x18, 0x42, 0x10, 0x58, 0x10, 0xf8, 0xc0, 0x10, 0x59, 0x0c
    .word   0xe4, 0x42, 0x14, 0xdf, 0x00, 0x18, 0xFFFF
    .align  4

DspTable:
    .long   nm_dsphost, path_dsphost, K_DSPHOST, 0, 0x650, 0, 0, rg_dsphost, dir_dsphost
    .long   0, 0, 0, 0, 0, 0, 0
    .long   nm_dspiop, path_dspiop, K_DSPIOP, 0, 0x870, 0, 0, rg_dspiop, dir_dspiop
    .long   0, 0, 0, 0, 0, 0, 0
    .long   nm_dsptime, path_dsptime, K_DSPTIME, 0, DT_BURST+BURST_N*BURST_W*4, 0, 0, rg_dsptime, dir_dsptime
    .long   0, 0, 0, 0, 0, 0, 0
DspMemTable:
    .long   nm_dsppm, path_dsppm, K_DSPPM, 0, 0x5480, 0, 0, rg_dsppm, dir_dsppm
    .long   0, 0, 0, 0, 0, 0, 0
    .long   nm_dspdm, path_dspdm, K_DSPDM, 0, 0x36A0, 0, 0, rg_dspdm, dir_dspdm
    .long   0, 0, 0, 0, 0, 0, 0

str_title_dsp:  .asciz  "KN7000 DSP PROBE"
nm_dsphost:     .asciz  "dsp_host.bin"
path_dsphost:   .asciz  "KN7DUMP\DSPHOST.BIN"
dir_dsphost:    .ascii  "DSPHOST BIN"
rg_dsphost:     .asciz  "main CPU side: INTC 0x34000100-0x340001FF, the firmware's DSP variables"
nm_dspiop:      .asciz  "dsp_iop.bin"
path_dspiop:    .asciz  "KN7DUMP\DSPIOP.BIN"
dir_dspiop:     .ascii  "DSPIOP  BIN"
rg_dspiop:      .asciz  "DSP IOP registers 0x00-0xFF, twice; no FIFO or SPORT data buffer"
nm_dsptime:     .asciz  "dsp_time.bin"
path_dsptime:   .asciz  "KN7DUMP\DSPTIME.BIN"
dir_dsptime:    .ascii  "DSPTIME BIN"
rg_dsptime:     .asciz  "DSP timers, DMASTAT, SPORT DMA counts: 200 samples 5 ms apart, a burst"
nm_dsppm:       .asciz  "dsp_pm.bin"
path_dsppm:     .asciz  "KN7DUMP\DSPPM.BIN"
dir_dsppm:      .ascii  "DSPPM   BIN"
rg_dsppm:       .asciz  "DSP program memory 0x8000-0x8DFF through EPB0 (DMA channel 8, transmit)"
nm_dspdm:       .asciz  "dsp_dm.bin"
path_dspdm:     .asciz  "KN7DUMP\DSPDM.BIN"
dir_dspdm:      .ascii  "DSPDM   BIN"
rg_dspdm:       .asciz  "DSP data memory 0x9800-0x9FFF, 0xC000-0xC4FF, SPORT TCBs, through EPB0"
    .align  4
