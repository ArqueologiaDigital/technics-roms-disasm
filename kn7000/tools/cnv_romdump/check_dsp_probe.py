#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# check_dsp_probe.py DIR [--program P1DIR] -- what did the DSP probe (cnv_romdump, KN7APP.BIN built with OPT_DSP,
# OPT_DSPMEM or OPT_DSPRATE; romdump_dsp.s, romdump_dsprate.s) read from the KN7000's effects DSP, an ADSP-21065L?
# DIR is what came off the SD card: DUMPLIST.TXT and DSPHOST.BIN, DSPIOP.BIN, DSPTIME.BIN (phase 1), DSPPM.BIN,
# DSPDM.BIN (phase 2) and/or DSPRATE.BIN (pass 8).
#   * every file whole: size, CRC-32 and byte sum as the instrument computed them (check_real_dump.load_dir);
#   * DSPHOST.BIN, the main CPU's side: which firmware routines the probe found and used, the handshake group's
#     interrupt control register G17ICR (0x3400015C), the firmware's "DSP dead" and "kernel downloaded" flags,
#     and its 146-entry effect pointer table;
#   * DSPIOP.BIN, the IOP registers (ADSP-21065L Technical Reference, Table E-15), named, both passes, with the
#     bits that matter decoded: SYSCON (host bus packing), WAIT, DMACx, DMASTAT, the SPORT control registers
#     STCTLx/SRCTLx (Tables E-23/E-24 bit positions), the divisors (xCLKDIV = 2 fCLKIN / fSCLK - 1,
#     xFSDIV = fSCLK / fFS - 1, page E-80), the DMA chain pointers (the TCB addresses);
#   * DSPTIME.BIN, the time series: how fast the timer counters and the SPORT DMA counts move, against the
#     firmware's millisecond counter, and what that means for the DSP's clock and its sample rate;
#   * DSPPM.BIN / DSPDM.BIN, the memory readback: what came back, and, with --program (a folder with PRGEVEN.BIN
#     and PRGODD.BIN, e.g. pass1-run1, or one joined program image), how it compares with the kernel the firmware
#     uploads (its download record: blocks of 12-byte headers, id 0x2004, PM entries 3 BE u16, DM entries 5 bytes);
#   * DSPRATE.BIN, the frame rate (pass 8): the fine clock (timer 4) checked, the intervals between the firmware's
#     data-port accesses as a histogram, the lattice of DSP events the stamps lie on (its period, with its uncertainty,
#     and whether one or two kinds of event), the I3 rate over 3 s, FLAG3's share of the frames, and a verdict on
#     the two readings pass 6 left open: (a) about 22.5 kHz frames with two handshakes each, (b) one handshake per
#     frame at 41.4 kHz or more.
# Exit status 1 when a file is damaged or missing, or a header is not what the probe writes.
#   python3 -I check_dsp_probe.py pass6-run1                 # phase 1
#   python3 -I check_dsp_probe.py pass7-run1 --program pass1-run1
#   python3 -I check_dsp_probe.py pass8-run1                 # pass 8
#   python3 -I check_dsp_probe.py --self-test                # the decoders on made-up files (pass 8: simulated runs)
#   python3 -I check_dsp_probe.py --mask-asm                 # the read mask, as romdump_dsp.s carries it
import os
import re
import struct
import sys
import zlib

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# ---- Table E-15: the IOP registers (address -> name) ----------------------------------------------------
IOP = {0x00: 'SYSCON', 0x01: 'VIRPT', 0x02: 'WAIT', 0x03: 'SYSTAT', 0x04: 'EPB0', 0x05: 'EPB1',
       0x18: 'BMAX', 0x19: 'BCNT', 0x1C: 'DMAC0', 0x1D: 'DMAC1', 0x20: 'SDRDIV',
       0x28: 'TPERIOD0', 0x29: 'TPWIDTH0', 0x2A: 'TCOUNT0', 0x2B: 'TPERIOD1', 0x2C: 'TPWIDTH1', 0x2D: 'TCOUNT1',
       0x2E: 'IOCTL', 0x2F: 'IOSTAT', 0x37: 'DMASTAT'}
IOP.update({0x08 + i: f'MSGR{i}' for i in range(8)})
for base, ch in ((0x30, 'R0B'), (0x38, 'R1B'), (0x50, 'T0B'), (0x58, 'T1B'), (0x60, 'R0A'), (0x68, 'R1A'),
                 (0x70, 'T0A'), (0x78, 'T1A')):
    for k, p in enumerate(('II', 'IM', 'C', 'CP', 'GP')):
        IOP[base + k] = p + ch
for base, ch in ((0x40, 'EP0'), (0x48, 'EP1')):
    for k, p in enumerate(('II', 'IM', 'C', 'CP', 'GP', 'EI', 'EM', 'EC')):
        IOP[base + k] = p + ch
for base, n in ((0xE0, 0), (0xF0, 1)):
    for k, p in ((0, 'STCTL'), (1, 'SRCTL'), (2, 'TX_A'), (3, 'RX_A'), (4, 'TDIV'), (6, 'RDIV'), (8, 'MTCS'),
                 (9, 'MRCS'), (0xA, 'MTCCS'), (0xB, 'MRCCS'), (0xC, 'KEYWD'), (0xD, 'IMASK'), (0xE, 'TX_B'),
                 (0xF, 'RX_B')):
        IOP[base + k] = p.replace('_', f'{n}_') if '_' in p else p + str(n)
# not read: the reads that change something (Table E-12: EPBx are the external port FIFOs, a read pops a word;
# Table E-13: TXx/RXx are the SPORT data buffers, a read of RX takes the received word away), and every
# address Table E-15 lists as reserved (not in IOP)
SIDE_EFFECT = {0x04: 'EPB0: external port FIFO, a read pops it (Table E-12)', 0x05: 'EPB1: the same',
               0xE2: 'TX0_A: SPORT data buffer (Table E-13)', 0xE3: 'RX0_A: a read takes the received word',
               0xEE: 'TX0_B', 0xEF: 'RX0_B', 0xF2: 'TX1_A', 0xF3: 'RX1_A', 0xFE: 'TX1_B', 0xFF: 'RX1_B'}
READ = sorted(a for a in IOP if a not in SIDE_EFFECT)


def mask_bytes():
    m = bytearray(32)
    for a in READ:
        m[a >> 3] |= 1 << (a & 7)
    return bytes(m)


def asm_mask():
    m = mask_bytes()
    lines = ['IopMask:    # bit n: IOP register n is read (check_dsp_probe.py READ: Table E-15 less SIDE_EFFECT)']
    for i in range(0, 32, 16):
        lines.append('    .byte   ' + ', '.join(f'0x{b:02x}' for b in m[i:i + 16]))
    lines.append(f'.equ IOP_NREAD,     {len(READ)}')
    return '\n'.join(lines)


# ---- bit decoders ------------------------------------------------------------------------------------------
def bits(v, lo, n=1):
    return v >> lo & ((1 << n) - 1)


def d_syscon(v):        # Table E-25
    return (f"HBW {['32-bit', '16-bit', '8-bit', 'reserved'][bits(v, 4, 2)]} host bus, "
            f"{'MSW' if bits(v, 6) else 'LSW'} first, IMDW0 {40 if bits(v, 8) else 32}-bit, "
            f"IMDW1 {40 if bits(v, 9) else 32}-bit, ADREDY {bits(v, 10)}, BHD {bits(v, 11)} "
            f"({'buffer hang off' if bits(v, 11) else 'a read of an empty EPB holds the host'}), BSO {bits(v, 1)}, "
            f"IIVT {bits(v, 2)}")


def d_dmac(v):          # Table E-16
    return (f"DEN {bits(v, 0)} CHEN {bits(v, 1)} TRAN {bits(v, 2)} ({'transmit' if bits(v, 2) else 'receive'}) "
            f"PS {bits(v, 3, 2)} DTYPE {bits(v, 5)} PMODE {['none', '16/32', '16/48', '32/48'][bits(v, 6, 2)]} "
            f"MSWF {bits(v, 8)} MASTER {bits(v, 9)} HSHAKE {bits(v, 10)} INTIO {bits(v, 11)} EXTERN {bits(v, 12)} "
            f"FS {['empty', 'reserved', 'partly full', 'full'][bits(v, 14, 2)]}")


DMASTAT_CH = ['RX0_A', 'RX1_A', 'TX0_A', 'TX1_A', 'RX0_B', 'RX1_B', 'EPB0', 'EPB1', 'TX0_B', 'TX1_B',      # 0-9
              'chain RX0_A', 'chain RX1_A', 'chain TX0_A', 'chain TX1_A', 'chain RX0_B', 'chain RX1_B',   # 10-15
              'chain EPB0', 'chain EPB1', 'chain TX0_B', 'chain TX1_B']                                   # 16-19


def d_dmastat(v):       # Table E-18
    on = [n for i, n in enumerate(DMASTAT_CH) if bits(v, i)]
    return 'active: ' + (', '.join(on) if on else 'none')


def d_sctl(v, tx):      # Tables E-23 (SRCTLx) and E-24 (STCTLx), standard mode
    dtype = ['right-justify, zero-fill', 'right-justify, sign-extend', 'mu-law', 'A-law'][bits(v, 1, 2)]
    f = [f"SPEN_A {bits(v, 0)}", f"SPEN_B {bits(v, 24)}", f"DTYPE {dtype}", f"SLEN {bits(v, 4, 5) + 1}",
         f"{'LSB' if bits(v, 3) else 'MSB'} first", f"PACK {bits(v, 9)}", f"ICLK {bits(v, 10)} (clock "
         f"{'internal' if bits(v, 10) else 'external'})", f"OPMODE {'I2S' if bits(v, 11) else 'standard'}",
         f"CKRE {bits(v, 12)}", f"{'TFSR' if tx else 'RFSR'} {bits(v, 13)}",
         f"{'ITFS' if tx else 'IRFS'} {bits(v, 14)} (frame sync {'internal' if bits(v, 14) else 'external'})",
         f"SDEN_A {bits(v, 18)} SCHEN_A {bits(v, 19)} SDEN_B {bits(v, 20)} SCHEN_B {bits(v, 21)}"]
    if not tx:
        f.append(f"MCE {bits(v, 23)}")
    f.append(f"status {'TX' if tx else 'RX'}S_A {bits(v, 30, 2)} {'TUVF' if tx else 'ROVF'}_A {bits(v, 29)} "
             f"{'TX' if tx else 'RX'}S_B {bits(v, 27, 2)}")
    return ', '.join(f)


def d_div(v):           # page E-80
    return f"CLKDIV {v & 0xFFFF}, FSDIV {v >> 16}"


def d_icr(v):           # MN10300 GxICR: 14-12 level, 11-8 enable, 7-4 request, 3-0 detect
    return f"level {bits(v, 12, 3)}, enable {bits(v, 8, 4):04b}, request {bits(v, 4, 4):04b}, detect {bits(v, 0, 4):04b}"


def u32s(b, off, n):
    return list(struct.unpack_from(f'<{n}I', b, off))


def head_found(b):
    f = u32s(b, 0x30, 8)
    names = ('found bits', 'handshake wait', 'register write', 'register read', 'index write', 'data read',
             'dead flag', 'downloaded flag')
    return dict(zip(names, f))


STATUS = [(1, 'routines found'), (2, 'DSP marked dead before: nothing read'), (4, 'DSP marked dead during'),
          (8, 'no millisecond counter'), (0x10, 'a millisecond wait timed out'), (0x20, 'pre-check failed: nothing'
          ' written'), (0x40, 'EPB0 stayed empty: stopped'), (0x80, 'channel 8 registers written back'),
          (0x100, 'an earlier block stopped: nothing read')]


def d_status(s):
    return ', '.join(t for m, t in STATUS if s & m) or 'nothing (the routines were not found: the DSP was not touched)'


def print_found(b):
    f = head_found(b)
    print('   found: ' + ', '.join(f'{k} {v:#010x}' for k, v in f.items()) +
          f"  ({'all' if f['found bits'] == 15 else 'NOT all'} of: wait 1, registers 2, index 4, data 8)")


def table(head, rows):
    w = [max(len(str(r[i])) for r in [head] + rows) for i in range(len(head))]
    print('| ' + ' | '.join(str(h).ljust(w[i]) for i, h in enumerate(head)) + ' |')
    print('|' + '|'.join('-' * (x + 2) for x in w) + '|')
    for r in rows:
        print('| ' + ' | '.join(str(c).ljust(w[i]) for i, c in enumerate(r)) + ' |')


# ---- DSPHOST.BIN ------------------------------------------------------------------------------------------
EFFECT_TABLE = {893: 0x500066DC, 941: 0x500066E0, 942: 0x500066E0, 935: 0x500066E0}   # kn7000_bios_addresses.py


def host(b, build):
    bad = 0
    if b[:8] != b'DSPHOST1' or len(b) != 0x650:
        print('DSPHOST.BIN: not the probe\'s format'); return 1
    st, ms, dead, down, icr, base, n = u32s(b, 8, 7)
    print(f'DSPHOST.BIN (the main CPU side, read at ms {ms}): {d_status(st)}')
    print_found(b)
    f = head_found(b)
    print(f'   dead flag {f["dead flag"]:#010x} = {dead:#04x} ({"DEAD: the firmware sends the DSP nothing" if dead else "alive"}); '
          f'downloaded flag {f["downloaded flag"]:#010x} = {down:#04x} ({"kernel downloaded" if down else "not downloaded"})')
    print(f'   G17ICR (0x3400015C, the DSP handshake group) = {icr:#06x}: {d_icr(icr)}')
    icrs = u32s(b, 0x50, 64)
    nz = [(g, v) for g, v in enumerate(icrs) if v]
    print('   INTC groups not zero: ' + ', '.join(f'G{g:02X}ICR {v:#06x}' for g, v in nz))
    if icrs[0x17] != icr:
        print(f'   (G17ICR in the block reads {icrs[0x17]:#06x}: it changed between the two reads)')
    ram = b[0x150:0x150 + n]
    for name, a in (('dead flag', f['dead flag']), ('downloaded flag', f['downloaded flag'])):
        if base <= a < base + n:
            print(f'   {name} in the RAM block: {ram[a - base]:#04x}')
    t = EFFECT_TABLE.get(build)
    if t and base <= t and t + 146 * 4 <= base + n:
        ptrs = u32s(ram, t - base, 146)
        used = [(i, p) for i, p in enumerate(ptrs) if p]
        print(f'   effect pointer table {t:#010x} (146 entries; program {build}): {len(used)} set' +
              (': ' + ', '.join(f'[{i}] {p:#010x}' for i, p in used[:12]) + (' ...' if len(used) > 12 else '')
               if used else ''))
    return bad


# ---- DSPIOP.BIN -------------------------------------------------------------------------------------------
def fix32(v):
    return v


def iop(b):
    if b[:8] != b'DSPIOP01' or len(b) != 0x870:
        print('DSPIOP.BIN: not the probe\'s format'); return 1, None
    st, ms0, ms1, dead0, dead1, down0, down1, icr0, icr1, nread = u32s(b, 8, 10)
    print(f'DSPIOP.BIN (IOP registers, ms {ms0} to {ms1}): {d_status(st)}; dead flag {dead0:#x} -> {dead1:#x}, '
          f'downloaded {down0:#x} -> {down1:#x}, G17ICR {icr0:#06x} -> {icr1:#06x}')
    print_found(b)
    bad = 0
    m = b[0x50:0x70]
    if m != mask_bytes() or nread != len(READ):
        print('   the read mask in the file is NOT this checker\'s (Table E-15 less SIDE_EFFECT)'); bad += 1
    a = u32s(b, 0x70, 256)
    p = u32s(b, 0x470, 256)
    rows = []
    for r in READ:
        note = ''
        name = IOP[r]
        if name == 'SYSCON':
            note = d_syscon(a[r])
        elif name.startswith('DMAC'):
            note = d_dmac(a[r])
        elif name == 'DMASTAT':
            note = d_dmastat(a[r])
        elif name.startswith('STCTL'):
            note = d_sctl(a[r], True)
        elif name.startswith('SRCTL'):
            note = d_sctl(a[r], False)
        elif name.startswith(('TDIV', 'RDIV')):
            note = d_div(a[r])
        elif name.startswith('CP') and a[r]:
            note = f"TCB at {0x8000 | a[r] & 0x7FFF:#06x} (taken as 0x8000 | CP & 0x7FFF)"
        rows.append((f'{r:#04x}', name, f'{a[r]:#010x}', 'same' if a[r] == p[r] else f'{p[r]:#010x}', note))
    table(('reg', 'name', 'pass A', 'pass B', 'decoded (pass A)'), rows)
    if any(IOP.get(r) for r in READ if a[r] != p[r]):
        print(f'   moved between the passes: {", ".join(IOP[r] for r in READ if a[r] != p[r])}')
    print(f'   not read: {", ".join(f"{k:#04x} {v}" for k, v in sorted(SIDE_EFFECT.items()))}; and every reserved address')
    if st & 1 and not st & 6:
        expect = a[0] & 0x70 == 0x10
        print(f"   SYSCON host packing: {'16-bit, LSW first, as the firmware set it (0x410)' if expect else 'NOT the firmware value 0x410'}")
        for n in (0, 1):
            t, rdv, s, r = a[0xE4 + 0x10 * n], a[0xE6 + 0x10 * n], a[0xE0 + 0x10 * n], a[0xE1 + 0x10 * n]
            for nm, ctl, div in (('transmit', s, t), ('receive', r, rdv)):
                if ctl & 1 or ctl >> 24 & 1:
                    if bits(ctl, 10) and bits(ctl, 14):
                        clk = div & 0xFFFF
                        fs = div >> 16
                        for fclkin in (30e6, 33e6):
                            print(f'   SPORT{n} {nm}: internal clock and frame sync: frame rate = 2 fCLKIN / ((CLKDIV + 1)'
                                  f' (FSDIV + 1)) = {2 * fclkin / ((clk + 1) * (fs + 1)):.1f} Hz if fCLKIN = {fclkin / 1e6:g} MHz')
                    else:
                        print(f'   SPORT{n} {nm}: clock {"internal" if bits(ctl, 10) else "external"}, frame sync '
                              f'{"internal" if bits(ctl, 14) else "external"}: the rate comes from outside the DSP'
                              ' (the tone generator); DSPTIME.BIN measures it')
    return bad, (a, p, ms0, ms1)


# ---- DSPTIME.BIN ------------------------------------------------------------------------------------------
SLOW = ['TCOUNT0', 'TCOUNT1', 'DMASTAT', 'CR0A', 'CR0B', 'CR1A', 'CR1B', 'CT0A', 'CT0B', 'CT1A', 'CT1B',
        'CPR0A', 'CPR0B', 'CPR1A', 'CPR1B', 'CPT0A', 'CPT0B', 'CPT1A', 'CPT1B']
BURST = ['TCOUNT0', 'TCOUNT1', 'CT0A', 'CR0A']
PERIOD = {'TCOUNT0': 0x28, 'TCOUNT1': 0x2B}
# The kernel's ring 3 (rec04, 0x8D11/0x8D21): B3 0x656F0, L3 0x4650, in the external SDRAM. Its pointer I3 steps by
# M3 = -1 once per main-loop frame while the FLAG3 input pin is high (0x8098); the kernel's init (0x8D92) and effects
# 58-61 at their entry (0x8403) copy I3 into MSGR2 (IOP 0x0A).
RING3 = (0x656F0, 0x4650)
SPORT_DMA = 0x033F          # DMASTAT bits 0-5, 8, 9: the eight SPORT DMA channels (Table E-18)


def rate(ts, vs, period=None):
    """(t ms, v) pairs -> (counts per ms, direction, pairs used, pairs skipped). A pair whose change is not
    plausibly one-way (a reload) is skipped, unless the period is known."""
    up = down = 0
    num = den = 0
    used = skip = 0
    for (t0, v0), (t1, v1) in zip(zip(ts, vs), zip(ts[1:], vs[1:])):
        dt = (t1 - t0) & 0xFFFFFFFF
        if dt == 0 or dt > 0x10000:
            skip += 1; continue
        if v1 == v0:
            num += 0; den += dt; used += 1; continue
        d_dn = (v0 - v1) % period if period else (v0 - v1) & 0xFFFFFFFF
        d_up = (v1 - v0) % period if period else (v1 - v0) & 0xFFFFFFFF
        if d_dn < d_up:
            down += 1; num += d_dn
        else:
            up += 1; num += d_up
        den += dt; used += 1
    return (num / den if den else 0.0), ('down' if down > up else 'up' if up else 'none'), used, skip


def series(b):
    if b[:8] != b'DSPTIME1' or len(b) != 0x55F0:
        print('DSPTIME.BIN: not the probe\'s format'); return 1, None
    st, n, per, nb, ms0, ms1, dead0, dead1, w, wb = u32s(b, 8, 10)
    print(f'DSPTIME.BIN ({n} samples {per} ms apart, then {nb} back to back; ms {ms0} to {ms1}): {d_status(st)}; '
          f'dead flag {dead0:#x} -> {dead1:#x}')
    print_found(b)
    slow = [u32s(b, 0x50 + 4 * w * i, w) for i in range(n)]
    slow = [s for s in slow if any(s)]
    burst = [u32s(b, 0x50 + 4 * w * n + 4 * wb * i, wb) for i in range(nb)]
    burst = [s for s in burst if any(s)]
    return 0, (slow, burst)


def access_time(burst):
    """us per data-port access: the least-squares slope of the burst's ms stamps over its samples, each sample
    being len(BURST) register reads, two data-port accesses each (the index write does not wait)."""
    t = [s[0] for s in burst]
    n = len(t)
    if n < 8:
        return None, None
    mx, my = (n - 1) / 2, sum(t) / n
    slope = sum((i - mx) * (y - my) for i, y in enumerate(t)) / sum((i - mx) ** 2 for i in range(n))
    return 1000 * slope / (2 * len(BURST)), 1000 * slope


def rates(data, iopv):
    slow, burst = data
    a, p, ms0, ms1 = iopv if iopv else (None, None, None, None)
    if len(slow) < 2:
        print('   too few samples to measure anything'); return
    span = (slow[-1][0] - slow[0][0]) & 0xFFFFFFFF
    crossed = sum(1 for s in slow if (s[1] - s[0]) & 0xFFFFFFFF)
    print(f'   {len(slow)} samples over {span} ms; {crossed} of them saw the ms counter change while they ran (each starts'
          ' just after a tick, so this is not their length: the burst below gives that)')
    rows = []
    for k, nm in enumerate(SLOW):
        vs = [s[2 + k] for s in slow]
        ts = [s[0] for s in slow]
        distinct = len(set(vs))
        per = None
        if a and nm in PERIOD and a[PERIOD[nm]]:
            per = a[PERIOD[nm]] + 1
        if distinct == 1:
            rows.append((nm, f'{vs[0]:#010x}', 'constant', '-', '-'))
            continue
        r, dirn, used, skip = rate(ts, vs, per)
        rows.append((nm, f'{min(vs):#x}..{max(vs):#x}', f'{distinct} values, counts {dirn}', f'{r:.1f}/ms',
                     f'{used} pairs' + (f', {skip} skipped' if skip else '') + (f', period {per}' if per else '')))
    table(('register', 'range', 'moves', 'rate (5 ms series)', 'from'), rows)
    still = {r[0] for r in rows if r[2] == 'constant'}
    dmastat = slow[0][2 + SLOW.index('DMASTAT')]
    if a and {'TCOUNT0', 'TCOUNT1'} <= still and not a[0x28] and not a[0x2B]:
        print('   * the timers: TPERIOD0 and TPERIOD1 are 0 and TCOUNT does not move: the kernel does not use them, so they')
        print('     cannot give the DSP clock.')
    counts = {n for n in SLOW if n[:2] in ('CR', 'CT')}
    if counts <= still and dmastat & SPORT_DMA:
        print(f'   * the SPORT DMA runs (DMASTAT {dmastat:#x}: {d_dmastat(dmastat & SPORT_DMA)}), yet every count reads the')
        print('     same: each firmware access waits for the DSP\'s handshake (G17), which comes at one point of its frame,')
        print('     so every read lands at the same place in the rings. The counts cannot give the frame rate this way.')
    elif len(still) == len(rows):
        print('   NOTHING MOVED over the series, and DMASTAT shows no SPORT DMA: on the instrument that means no audio')
        print('   frames. In MAME it is expected: the kn7000_mame overlay keeps the IOP registers but does not run the')
        print('   timers, the SPORT DMA or DMASTAT.')
    us, _ = access_time(burst)
    if us:
        print(f'   * the firmware\'s DSP accesses: {us:.2f} us each, {1000 / us:.1f} per ms (the burst\'s ms stamps, least')
        print(f'     squares over {len(burst)} samples of {2 * len(BURST)} data-port accesses). Each one first clears G17ICR\'s')
        print('     request and waits for the DSP to raise it again (893 0x4840AE77, 941 0x48404D25): so this is the')
        print('     rate at which the DSP answers, at most one access per handshake.')
    if a and a[0x0A] != p[0x0A] and all(RING3[0] <= v < RING3[0] + RING3[1] for v in (a[0x0A], p[0x0A])):
        moved = (a[0x0A] - p[0x0A]) % RING3[1]
        between = 2 * sum(1 for r in READ)
        dt = between * us / 1000 if us else (ms1 - ms0) / 2
        how = f'{between} data-port accesses at {us:.2f} us' if us else 'half of DSPIOP.BIN\'s span'
        print(f'   * MSGR2 is I3, the pointer into the kernel\'s ring 3 ({RING3[0]:#x}, {RING3[1]} words): {a[0x0A]:#x} in')
        print(f'     pass A, {p[0x0A]:#x} in pass B, {moved} words down in about {dt:.2f} ms ({how}):')
        print(f'     {moved / dt:.1f} steps per ms. I3 steps once per frame while the FLAG3 pin is high (kernel 0x8098).')
        if us:
            print(f'     Two readings fit: frames at about {moved / dt:.1f} kHz with FLAG3 always high and about')
            print(f'     {1000 / us / (moved / dt):.1f} handshakes per frame; or one handshake per frame, frames at')
            print(f'     {1000 / us:.1f} kHz or more, with FLAG3 high on {100 * (moved / dt) * us / 1000:.0f}% of them or fewer')
            print('     (44.1 kHz with FLAG3 high every other frame would fit).')
    if len(burst) >= 2:
        bspan = (burst[-1][0] - burst[0][0]) & 0xFFFFFFFF
        print(f'   burst: {len(burst)} back-to-back samples of {", ".join(BURST)} in {bspan} ms '
              f'({1000 * bspan / (len(burst) - 1):.0f} us per sample)')
        rows = []
        for k, nm in enumerate(BURST):
            vs = [s[1 + k] for s in burst]
            if len(set(vs)) == 1:
                rows.append((nm, 'constant', f'{vs[0]:#x}', '-')); continue
            steps = [(v0 - v1) & 0xFFFFFFFF for v0, v1 in zip(vs, vs[1:])]
            small = sorted(s for s in steps if s < 0x80000000)
            med = small[len(small) // 2] if small else 0
            per_ms = med * (len(burst) - 1) / bspan if bspan else 0
            rows.append((nm, f'{len(set(vs))} values', f'median step {med}', f'~{per_ms:.1f}/ms'))
        table(('register', 'values', 'between samples', 'rate'), rows)
    print('   reading the rates:')
    print('   * TCOUNTx: the TRM extract at hand (Technical Reference, appendix E) gives the timer registers but not')
    print('     what clocks them (that is the User\'s Manual, chapter 11). If TCOUNT moves once per core clock, the')
    print('     rate in counts/ms is the core clock in kHz: 60,000/ms = 60 MHz, 66,000/ms = 66 MHz; if once per')
    print('     CLKIN cycle, double it. A constant TCOUNT means the timer is not enabled (MODE2 TIMENx).')
    print('   * Cxxx (SPORT DMA counts) go down by one per word the channel moves; with one word per frame per')
    print('     channel (standard mode, no multichannel) the rate is the frame rate: 44.1/ms for 44.1 kHz. A count')
    print('     that reloads faster than the samples come (chained TCBs of a few words) aliases in the 5 ms series;')
    print('     the burst, a few hundred us apart, is the one to read then.')


# ---- DSPRATE.BIN (pass 8: the frame rate) ------------------------------------------------------------------------
# romdump_dsprate.s. Four 32 KB chunks, each measured in a converter call of its own. Chunk 0: the header, the
# calibration (stamps only), the access timing (AT_N pairs: re-latch MSGR2, a stamp, the firmware's data read of the
# low half, a stamp, the high half), the phase check (a stamp, CR0A, a stamp, IIR0A, after a delay that moves through
# the frame). Chunks 1-3: the I3 series, one sample per millisecond tick (a stamp, MSGR2, a stamp).
# A stamp is (ms - the chunk's base) << 16 | TM4BC. The MN10300's timer 4 counts TM4BC down from TM4BR to 0 at 2 MHz,
# and the firmware's millisecond counter steps each time it reloads (893 0x484D707F, 941 0x484D728C: TM4BR 0x7D0,
# TM4MD 0x81). So a stamp is ms * K + (TM4BR - BC) counts, K = TM4BR + 1 counts per tick, and a count is 1/K ms
# (the tick taken as the firmware's 1 ms; if the count clock is exactly 2 MHz instead, every rate here is K/2000 of
# what is printed, 0.05% more).
# Every firmware data-port access clears G17ICR's request and waits for the DSP to raise it again, so the stamp
# after an access sits a fixed time after the DSP event that released it: stamps of one kind lie on the lattice of
# those events. Two readings were open after pass 6 (README.md, "Pass 8"):
#   (a) frames at about 22.5 kHz, FLAG3 always high (I3 steps every frame), about 1.8 handshakes per frame: two
#       events per frame, unevenly spaced;
#   (b) one handshake per frame, frames at 41.4 kHz or more (44.1 kHz fits), FLAG3 high on about half the frames.
RATE_LEN = 0x20000
RATE_HEAD = ('status', 'ms0', 'ms1', 'dead0', 'dead1', 'down', 'br', 'md', 'bc', 'icr0')        # 0x08-0x2C
RATE_HEAD2 = ('cal_n', 'cal_spin', 'at_n', 'at_done', 'ph_n', 'ph_done', 'ph_spin', 'i3_n', 'segs', 'retried',
              'failed', 's_end', 'off_cal', 'off_at', 'off_ph', 'rs_data', 'chunk', 'regs', 'icr1', 'tries')
SEG_HEAD = ('status', 'ms0', 'ms1', 'dead0', 'dead1', 'n', 'taken', 'index', 'retried', 'failed', 'icr1')
FRAME_B = (20.0, 25.0)          # (b): one event per frame, 40-50 kHz
FRAME_A = (40.0, 50.0)          # (a): two events per frame, 20-25 kHz
SHARE_B = (0.25, 0.75)          # (b): FLAG3 high on about half the frames
SHARE_A = (0.85, 1.15)          # (a): FLAG3 always high, one I3 step per frame
TIGHT = 1.5                     # us: pairs of accesses this close to the commonest are one kind
ONE_SPREAD = 0.6                # us: the most a lattice's residuals may spread and still be one kind of event (a stamp
                                # is quantised to 0.5 us, sigma 0.14, and the poll loop adds about as much)
TWO_SPREAD = 1.0                # us: the most each of two clusters may spread


def rate_parse(b):
    """DSPRATE.BIN -> dict of its header, blocks and segments; None when it is not the probe's format"""
    if len(b) != RATE_LEN or b[:8] != b'DSPRATE1':
        return None
    h = dict(zip(RATE_HEAD, u32s(b, 8, 10)))
    h.update(zip(RATE_HEAD2, u32s(b, 0x50, 20)))
    if (h['chunk'], h['off_cal'], h['segs']) != (0x8000, 0x100, 3) or not h['off_cal'] + 4 * h['cal_n'] <= \
            h['off_at'] <= h['off_at'] + 12 * h['at_n'] <= h['off_ph'] <= h['off_ph'] + 16 * h['ph_n'] <= h['chunk']:
        return None
    h['found'] = head_found(b)
    h['cal'] = u32s(b, h['off_cal'], h['cal_n'])
    h['at'] = [struct.unpack_from('<IIHH', b, h['off_at'] + 12 * k) for k in range(min(h['at_done'], h['at_n']))]
    h['ph'] = [tuple(u32s(b, h['off_ph'] + 16 * k, 4)) for k in range(min(h['ph_done'], h['ph_n']))]
    h['seg'] = []
    for j in range(1, h['segs'] + 1):
        c = b[j * h['chunk']:(j + 1) * h['chunk']]
        s = dict(zip(SEG_HEAD, u32s(c, 8, 11)))
        s['magic'] = c[:8]
        s['samples'] = [tuple(u32s(c, h['rs_data'] + 12 * i, 3)) for i in range(min(s['taken'], s['n'], 2700))]
        h['seg'].append(s)
    return h


class Clock:
    """the stamps' time base: TM4BC counts down from TM4BR to 0, K = TM4BR + 1 counts per millisecond tick"""

    def __init__(self, br, md, down=True):
        self.br, self.md, self.down = br, md, down
        self.running = bool(md & 0x80) and br > 0
        self.K = br + 1 if self.running else 1

    def counts(self, base, s):
        ms = base + (s >> 16)
        if not self.running:
            return ms
        return ms * self.K + ((self.br - (s & 0xFFFF)) if self.down else (s & 0xFFFF))

    def us(self, c):
        return c * 1000.0 / self.K


def unstale(cs, K):
    """A stamp whose ms was read after TM4 reloaded but before the tick handler stepped the counter is one tick (K
    counts) early: a step back of up to K counts from the stamp before. -> (corrected list, how many)"""
    out, n = [], 0
    for c in cs:
        if out and out[-1] - K <= c < out[-1]:
            c += K
            n += 1
        out.append(c)
    return out, n


def lsq(xs, ys):
    """least squares y = a + b x -> (a, b, residuals, sigma of b)"""
    n = len(xs)
    mx, my = sum(xs) / n, sum(ys) / n
    sxx = sum((x - mx) ** 2 for x in xs)
    b = sum((x - mx) * (y - my) for x, y in zip(xs, ys)) / sxx if sxx else 0.0
    a = my - b * mx
    res = [y - a - b * x for x, y in zip(xs, ys)]
    s = (sum(r * r for r in res) / (n - 2)) ** 0.5 if n > 2 else 0.0
    return a, b, res, (s / sxx ** 0.5 if sxx else float('inf'))


def lattice(ts, T0, far=5000.0):
    """Event-locked stamps (us, in time order) on a lattice of period T: each gap rounded to whole periods of T0; before
    a gap longer than far (us), T refined by least squares over the stamps so far. -> (T, sigma_T, residuals, event
    numbers) or None"""
    if len(ts) < 8 or not T0 or T0 <= 0:
        return None
    n, T = [0], T0
    sx = sy = sxx = sxy = 0.0
    t0 = ts[0]
    cnt = 1
    for i in range(1, len(ts)):
        gap = ts[i] - ts[i - 1]
        if gap < 0:
            return None
        d = cnt * sxx - sx * sx
        if gap > far and cnt >= 8 and d > 0:
            T = (cnt * sxy - sx * sy) / d
        m = n[-1] + max(1, round(gap / T))
        n.append(m)
        x, y = float(m), ts[i] - t0
        cnt += 1
        sx += x; sy += y; sxx += x * x; sxy += x * y
    a, T, res, sT = lsq(n, [t - t0 for t in ts])
    return T, sT, res, n


def mad(xs):
    """robust spread (sigma for a normal distribution): 1.4826 x the median absolute deviation"""
    if not xs:
        return 0.0
    m = sorted(xs)[len(xs) // 2]
    d = sorted(abs(x - m) for x in xs)
    return 1.4826 * d[len(d) // 2]


def structure(res):
    """How the residuals from a lattice lie. 'two': two tight clusters, each with at least 5% of them, at least
    max(1 us, 5 sigma) apart (two kinds of event, the second off the lattice); 'one': one tight cluster; None: neither.
    Tight: 90% of the points within max(0.75 us, 3 sigma) of a centre, sigma the robust spread inside a cluster, at
    most ONE_SPREAD (one cluster) or TWO_SPREAD (each of two). -> (kind, centres, fractions, sigma)"""
    r = sorted(res)
    n = len(r)
    if n < 8:
        return None, (), (), 0.0
    q = r[n // 40:n - n // 40]                  # the split ignores the outermost 2.5% on each side (interrupted stamps)
    m = len(q)
    pre, pre2 = [0.0], [0.0]
    for x in q:
        pre.append(pre[-1] + x)
        pre2.append(pre2[-1] + x * x)
    best = None
    for i in range(max(2, m // 20), m - max(2, m // 20) + 1):
        v = (pre2[i] - pre[i] ** 2 / i) + (pre2[m] - pre2[i] - (pre[m] - pre[i]) ** 2 / (m - i))
        if best is None or v < best[0]:
            best = (v, i)
    if best:
        i = best[1]
        lo, hi = q[:i], q[i:]
        c1, c2 = sorted(lo)[len(lo) // 2], sorted(hi)[len(hi) // 2]
        sg = max(mad(lo), mad(hi))
        w = max(0.75, 3 * sg)
        on1 = sum(1 for x in r if abs(x - c1) <= w)
        on2 = sum(1 for x in r if abs(x - c2) <= w)
        if c2 - c1 >= max(1.0, 5 * sg) and on1 + on2 >= 0.9 * n and min(on1, on2) >= 0.05 * n and sg <= TWO_SPREAD:
            return 'two', (c1, c2), (on1 / n, on2 / n), sg
    med = r[n // 2]
    sg = mad(r)
    on = sum(1 for x in r if abs(x - med) <= max(0.75, 3 * sg))
    if on >= 0.9 * n and sg <= ONE_SPREAD:
        return 'one', (med,), (on / n,), sg
    return None, (), (), sg


def hist_rows(cols, width=1.0, cap=200.0):
    """aligned histogram rows: [bin, count per column]; empty runs folded into one row"""
    allv = [v for c in cols for v in c]
    if not allv:
        return []
    bins = {}
    over = [0] * len(cols)
    for k, c in enumerate(cols):
        for v in c:
            if v >= cap:
                over[k] += 1
                continue
            b = int(v // width) if v >= 0 else -1
            bins.setdefault(b, [0] * len(cols))[k] += 1
    rows, prev = [], None
    for b in sorted(bins):
        if prev is not None and b > prev + 1:
            rows.append(('...', *[''] * len(cols), f'({b - prev - 1} empty)'))
        tot = sum(bins[b])
        rows.append((f'{b * width:.0f}-{(b + 1) * width:.0f}' if b >= 0 else '< 0', *bins[b], '#' * min(60, max(1, tot * 60 // len(allv)))))
        prev = b
    if any(over):
        rows.append((f'>= {cap:.0f}', *over, ''))
    return rows


def best_fit(ts, P0):
    """The lattice that explains event-locked stamps ts, from the commonest pair of accesses P0 (us): first period
    P0 / 2 (each access waits for the next event); two kinds of event half a period apart are a lattice of P0 / 4;
    else P0, P0 / 3, P0 / 4. -> (T, sigma_T, kind, centres, fractions, rms) or None"""
    def fit(T0):
        f = lattice(ts, T0)
        if f is None:
            return None
        kind, cen, frac, rms = structure(f[2])
        return f[0], f[1], kind, cen, frac, rms
    f2 = fit(P0 / 2)
    if f2 and f2[2] == 'one':
        return f2
    if f2 and f2[2] == 'two':
        if abs(abs(f2[3][1] - f2[3][0]) - f2[0] / 2) > 1.0:
            return f2
        f4 = fit(P0 / 4)
        return f4 if f4 and f4[2] == 'one' else f2
    for T0 in (P0, P0 / 3, P0 / 4):
        f = fit(T0)
        if f and f[2] == 'one':
            return f
    return f2


def seq_us(clk, base, stamps, ref):
    """stamps of one chunk, in the order they were taken -> times in us from ref, stale ones put right"""
    cs = [clk.counts(base, x) for x in stamps]
    if clk.running:
        cs, _ = unstale(cs, clk.K)
    return [clk.us(c - ref) for c in cs]


def rate_i3(h, clk, ref):
    """the I3 series: (points [(t us, cumulative steps, segment)], rate steps/us, sigma, per-segment rows, bad values)"""
    B3, L3 = RING3
    pts, bad, rows = [], 0, []
    steps, prev, rate = 0, None, None
    for j, s in enumerate(h['seg'], 1):
        seg = []
        ts = seq_us(clk, s['ms0'], [x for s1, v, s2 in s['samples'] for x in (s1, s2)], ref)
        for k, (s1, v, s2) in enumerate(s['samples']):
            if not B3 <= v < B3 + L3:
                bad += 1
                continue
            t = (ts[2 * k] + ts[2 * k + 1]) / 2
            if prev is not None:
                d = (prev[1] - v) % L3
                if seg == [] and rate:                  # across a gap between chunks: the wrap the rate predicts
                    want = rate * (t - prev[0])
                    d += L3 * max(0, round((want - d) / L3))
                steps += d
            prev = (t, v)
            seg.append((t, steps))
        if len(seg) >= 3:
            _, r, _, sr = lsq([p[0] for p in seg], [p[1] for p in seg])
            rows.append((j, len(seg), f'{(seg[-1][0] - seg[0][0]) / 1000:.1f}', f'{1000 * r:.5f} +- {1000 * sr:.5f}'))
            pts += [(t, c, j) for t, c in seg]
            _, rate, _, _ = lsq([p[0] for p in pts], [p[1] for p in pts])
    if len(pts) < 3:
        return pts, None, None, rows, bad
    _, r, _, sr = lsq([p[0] for p in pts], [p[1] for p in pts])
    return pts, r, sr, rows, bad


def rate_report(b):
    """pass 8: everything DSPRATE.BIN says, and the verdict on (a) against (b). -> number of problems"""
    h = rate_parse(b)
    if h is None:
        print('DSPRATE.BIN: not the probe\'s format'); return 1
    last = h['seg'][-1]['ms1'] if h['seg'] else h['ms1']
    print(f'DSPRATE.BIN (pass 8, the frame rate; ms {h["ms0"]} to {last}): {d_status(h["status"])}; dead flag '
          f'{h["dead0"]:#x} -> {h["dead1"]:#x}, downloaded {h["down"]:#x}, G17ICR {h["icr0"]:#06x} -> {h["icr1"]:#06x}')
    print_found(b)
    bad = 0
    for s in h['seg']:
        ok = s['magic'] == b'DSPRSEG' + bytes([0x30 + s['index']])
        bad += not ok
        print(f'   segment {s["index"]} ({"" if ok else "BAD MAGIC "}ms {s["ms0"]} to {s["ms1"]}): {d_status(s["status"])}; '
              f'{s["taken"]} of {s["n"]} samples; dead flag {s["dead0"]:#x} -> {s["dead1"]:#x}; stamps retried {s["retried"]}'
              f', failed {s["failed"]}')
    regs = h['regs']
    print(f'   registers: {IOP.get(regs & 0xFF)} (access timing, I3), {IOP.get(regs >> 16 & 0xFF)} and '
          f'{IOP.get(regs >> 8 & 0xFF)} (phase check); {h["at_done"]} of {h["at_n"]} pairs, {h["ph_done"]} of {h["ph_n"]} '
          f'phase samples; stamps retried {h["retried"]}, failed {h["failed"]} (ms changed {h["tries"]} times running)')
    clk = Clock(h['br'], h['md'])
    # -- the clock ---------------------------------------------------------------------------------------------
    cal_ms = [s >> 16 for s in h['cal']]
    cal_bc = [s & 0xFFFF for s in h['cal']]
    print(f'   the clock: TM4BR {h["br"]:#06x} ({h["br"]}), TM4MD {h["md"]:#04x} (count enable {h["md"] >> 7 & 1}, '
          f'clock select {h["md"] & 7}), TM4BC {h["bc"]:#06x} at the start; the firmware writes 0x7d0 and 0x81')
    if not clk.running or len(set(cal_bc)) <= 1:
        print(f'   * TM4 DOES NOT RUN here (TM4BR {h["br"]:#x}, TM4MD {h["md"]:#x}, TM4BC always {cal_bc[0] if cal_bc else 0:#x}):'
              ' no fine clock. The stamps carry whole milliseconds; nothing shorter can be measured.')
        clk = Clock(0, 0)
    else:
        down = sum(1 for i in range(1, len(cal_bc)) if cal_ms[i] == cal_ms[i - 1] and cal_bc[i] < cal_bc[i - 1])
        up = sum(1 for i in range(1, len(cal_bc)) if cal_ms[i] == cal_ms[i - 1] and cal_bc[i] > cal_bc[i - 1])
        steps = [i for i in range(1, len(cal_bc)) if cal_ms[i] != cal_ms[i - 1]]
        wrap = sum(1 for i in steps if cal_bc[i] > cal_bc[i - 1])
        clk = Clock(h['br'], h['md'], down=down >= up)
        runs = [(steps[k], steps[k + 1]) for k in range(len(steps) - 1)]
        dec = sorted(cal_bc[i - 1] - cal_bc[i] for a, e in runs for i in range(a + 1, e) if cal_bc[i] < cal_bc[i - 1])
        per = dec[len(dec) // 2] if dec else 0
        lens = sorted(e - a for a, e in runs)
        mlen = lens[len(lens) // 2] if lens else 0
        cs, nfix = unstale([clk.counts(h['ms0'], x) for x in h['cal']], clk.K)
        back = sum(1 for i in range(1, len(cs)) if cs[i] < cs[i - 1])
        rows = [('samples', len(cal_bc), f'{h["cal_n"]}, {h["cal_spin"]} delay-loop turns apart'),
                ('BC within a tick', f'down {down}, up {up}', 'down: TM4 counts down (an up is a stale stamp)'),
                ('BC range', f'{min(cal_bc)}..{max(cal_bc)}', f'within 0..{h["br"]}'),
                ('ms steps', len(steps), f'BC jumps up at {wrap} of them (the reload; at the others a stale stamp came'
                                         ' before)'),
                ('stale stamps put right', nfix, 'ms read before the tick handler stepped it: one tick early'),
                ('steps back after that', back, '0: the stamps run forward'),
                ('BC change per sample', per, 'the delay loop\'s length in counts'),
                ('samples per tick', mlen, f'x {per} = {per * mlen} counts per tick (about {clk.K}: rough, the tick '
                                           'handler\'s own time is in it)')]
        table(('calibration', 'value', 'meaning'), rows)
        if not (0 <= min(cal_bc) and max(cal_bc) <= h['br'] and down > 10 * up and back == 0 and steps):
            print('   * the calibration does NOT look like TM4 counting down from TM4BR: the fine times below are suspect')
            bad += 1
        else:
            print(f'   * TM4 counts down from {h["br"]} to 0 and the millisecond counter steps at each reload: a stamp is '
                  f'ms x {clk.K} + ({h["br"]} - BC) counts, 1 count = {1000 / clk.K:.4f} us (1 tick = 1 ms).')
    ref = clk.counts(h['ms0'], 0)
    # -- the access timing -------------------------------------------------------------------------------------
    at = h['at']
    P0, P = None, []
    if len(at) >= 8:
        seq = [s for s1, s2, lo, hi in at for s in (s1, s2)] + [h['s_end']]
        cs, nfix = unstale([clk.counts(h['ms0'], s) for s in seq], clk.K) if clk.running else \
            ([clk.counts(h['ms0'], s) for s in seq], 0)
        t = [clk.us(c - ref) for c in cs]
        dlo = [t[2 * k + 1] - t[2 * k] for k in range(len(at))]
        dhi = [t[2 * k + 2] - t[2 * k + 1] for k in range(len(at))]
        P = [t[2 * k + 2] - t[2 * k] for k in range(len(at))]
        span = t[-1] - t[0]
        print(f'   access timing: {len(at)} pairs in {span / 1000:.2f} ms, {span / (2 * len(at)):.2f} us per data-port access'
              f' ({2000 * len(at) / span if span else 0:.1f} per ms); {nfix} stale stamps put right. Each pair: re-latch '
              'MSGR2, stamp, low half, stamp, high half.')
        if clk.running:
            print('   intervals between successive stamps, us ("after lo": stamp, low half, stamp; "after hi": the high half,'
                  ' the re-latch and the loop), and whole pairs (stamp to stamp, two accesses):')
            table(('us', 'after lo', 'after hi', 'pairs', ''), hist_rows([dlo, dhi, P]))
        if clk.running:
            ps = sorted(P)
            mode = max(set(round(p) for p in ps), key=lambda v: sum(1 for p in ps if abs(p - v) <= 1))
            main = [p for p in ps if abs(p - mode) <= TIGHT]
            P0 = sum(main) / len(main)
            print(f'   the commonest pair lasts {P0:.2f} us ({len(main)} of {len(P)} pairs within {TIGHT} us)')
    # -- the I3 series ---------------------------------------------------------------------------------------------
    pts, R3, sR3, rows, badv = rate_i3(h, clk, ref)
    if rows:
        print(f'   the I3 series (MSGR2 once per tick; ring 3 {RING3[0]:#x}, {RING3[1]} words, unwrapped):')
        table(('segment', 'samples', 'ms', 'I3 steps per ms'), rows)
    if badv:
        print(f'   {badv} MSGR2 values outside ring 3 left out')
    if R3 is not None:
        print(f'   * I3 steps {1000 * R3:.5f} +- {1000 * sR3:.5f} per ms over {(pts[-1][0] - pts[0][0]) / 1000:.0f} ms '
              f'(least squares, {len(pts)} samples; pass 6 said 22.5)')
    elif pts or h['seg']:
        print('   * I3: too few samples in the ring for a rate')
    if R3 is not None and abs(R3) < 1e-9:
        print('   * MSGR2 DOES NOT MOVE: no I3 rate (no effect 58-61 running, or an emulator)')
    # -- the event lattice -----------------------------------------------------------------------------------------
    verdict = None
    best = None
    if clk.running and P0:
        series = []
        i3s2 = [t for s in h['seg'] for t in seq_us(clk, s['ms0'], [x for s1, v, s2 in s['samples'] for x in (s1, s2)],
                                                     ref)[1::2]]
        series.append(('I3 series, after MSGR2', i3s2))
        if P:
            series.append(('access timing, after lo', [t[2 * k + 1] for k in range(len(at))]))
            series.append(('access timing, after hi', [t[2 * k + 2] for k in range(len(at))]))
        if h['ph']:
            series.append(('phase check, after CR0A', seq_us(clk, h['ms0'], [x for s1, cr, s2, ii in h['ph'] for x in (s1, s2)],
                                                             ref)[1::2]))
        rows = []
        if len(series) > 1:                     # the access timing first: dense, it pins the period down
            series = series[1:] + series[:1]
        for name, ts in series:
            pick = best_fit(ts, P0)
            if name == 'access timing, after lo' and pick and pick[2]:
                P0 = 2 * pick[0] if abs(2 * pick[0] - P0) < TIGHT else P0
            if pick is None:
                continue
            T, sT, kind, cen, frac, rms = pick
            desc = 'one kind of event' if kind == 'one' else \
                f'two kinds, {abs(cen[1] - cen[0]):.2f} us off each other' if kind == 'two' else 'no lattice'
            rows.append((name, len(ts), f'{T:.5f} +- {sT:.5f}', f'{rms:.2f}', desc))
            if name.startswith('I3'):
                best = pick
        table(('stamps (each a fixed time after a DSP event)', 'n', 'lattice period, us', 'spread, us', 'structure'), rows)
        print('   (the access timing\'s stamps follow one kind of event each while the loop keeps step with the frame;'
              ' the I3 series starts each sample at a tick, at any point of the frame, so it meets every kind)')
    if P and best and best[2] in ('one', 'two'):
        T = best[0]
        m = [round(p / T) for p in P]
        dist = {}
        for x in m:
            dist[x] = dist.get(x, 0) + 1
        two = [k for k, x in enumerate(m) if x == 2]
        R = T - sorted(dlo[k] for k in two)[len(two) // 2] if two else 0.0
        nlo = [max(1, round((d + R) / T)) for d in dlo]
        nacc = {}
        for k, x in enumerate(m):
            for v in (nlo[k], x - nlo[k]):
                nacc[v] = nacc.get(v, 0) + 1
        print(f'   events (lattice points, {T:.3f} us apart) per pair: ' + ', '.join(f'{k}: {v}' for k, v in sorted(dist.items())))
        print(f'   per access (taking the re-latch to cost {R:.2f} us): ' + ', '.join(
            f'{"single" if k == 1 else f"{k} events" if k > 0 else "none"} {v}' for k, v in sorted(nacc.items())) +
            f'; {100 * nacc.get(1, 0) / max(1, sum(nacc.values())):.1f}% single')
        i3 = [(hi << 16) | lo for s1, s2, lo, hi in at]
        if all(RING3[0] <= v < RING3[0] + RING3[1] for v in i3):
            dI = [(i3[k] - i3[k + 1]) % RING3[1] for k in range(len(i3) - 1)]
            per2 = {}
            for k in two:
                if k < len(dI):
                    per2[dI[k]] = per2.get(dI[k], 0) + 1
            ev = sum(m[:len(dI)])
            print(f'   I3 in the access timing: {sum(dI)} steps over {ev} events ({sum(dI) / ev if ev else 0:.4f} per event); '
                  'over a two-event pair it stepped ' + ', '.join(f'{k}: {v} times' for k, v in sorted(per2.items())))
    # -- the phase check ---------------------------------------------------------------------------------------------
    one_position = False                        # every phase sample found the ring at the same place (SPORT DMA running)
    if h['ph']:
        cr = {}
        ii = {}
        for s1, c, s2, i in h['ph']:
            cr[c] = cr.get(c, 0) + 1
            ii[i] = ii.get(i, 0) + 1
        print(f'   phase check ({len(h["ph"])} samples, started across the frame by a delay of 0 to {31 * h["ph_spin"] + 1} '
              'loop turns): CR0A ' + ', '.join(f'{k:#x} x{v}' for k, v in sorted(cr.items(), key=lambda kv: -kv[1])[:6]) +
              '; IIR0A ' + ', '.join(f'{k:#x} x{v}' for k, v in sorted(ii.items(), key=lambda kv: -kv[1])[:6]))
        if len(cr) == 1 and len(ii) == 1 and not (set(cr) | set(ii)) <= {0}:
            one_position = True
            print('   * every read saw the same ring position, whatever the delay before it: with the SPORT DMA running (pass 6:'
                  ' DMASTAT 0x33F), the handshake locks the reads to one point of the frame')
        elif (set(cr) | set(ii)) <= {0}:
            print('   * CR0A and IIR0A read 0: the SPORT DMA is not running here, or not modelled (the emulator)')
        else:
            print('   * the ring position moves between reads: the handshake does NOT lock the reads to one point of the frame')
    # -- the verdict ----------------------------------------------------------------------------------------------------
    held = []                                   # how long each I3 sample's register read took (index, two accesses)
    for sg_ in h['seg']:
        ts = seq_us(clk, sg_['ms0'], [x for s1, v, s2 in sg_['samples'] for x in (s1, s2)], ref)
        held += [ts[2 * k + 1] - ts[2 * k] for k in range(len(sg_['samples']))]
    if clk.running and held:
        hs = sorted(held)
        print(f'   I3 samples: a register read took {hs[len(hs) // 20]:.1f} to {hs[-len(hs) // 20 - 1]:.1f} us (5% to 95%), median'
              f' {hs[len(hs) // 2]:.1f}: it starts at a tick, at any point of the frame, and waits for two handshakes')
    print('   VERDICT:')
    if clk.running and held and mad(held) < 0.5 and sorted(held)[len(held) // 2] < 15:   # two handshakes take >= 20 us
        verdict = 'neither'
        print('   * NEITHER: the register reads take the same short time wherever they start: the accesses wait for nothing'
              ' (the DSP answers at once, as the emulator\'s self-ack does), so they carry no frame timing.')
    elif not clk.running:
        print('   * none possible: no fine clock (TM4 does not run), so no interval shorter than 1 ms can be measured.')
    elif best is None or best[2] not in ('one', 'two'):
        verdict = 'neither'
        print('   * NEITHER: the I3 series\' stamps lie on no lattice of DSP events (one or two kinds of event per period)' +
              (f'; the nearest, {best[0]:.4f} us, leaves them {best[5]:.2f} us apart' if best else '') +
              ': the handshakes do not come at one steady rate.')
    elif R3 is None or R3 <= 0:
        verdict = 'neither'
        print(f'   * NEITHER: the handshakes come every {best[0]:.3f} us ({best[2]} kind{"s" if best[2] == "two" else ""} of'
              ' event), but I3 does not move, so FLAG3\'s share cannot be told.')
    else:
        T, sT, kind = best[0], best[1], best[2]
        if kind == 'one':
            share = R3 * T
            sshare = share * ((sR3 / R3) ** 2 + (sT / T) ** 2) ** 0.5
            print(f'   * the handshakes come every {T:.5f} us +- {1000 * sT:.2f} ns, all alike: one per frame would make the frame '
                  f'rate {1e6 / T:.2f} +- {1e6 * sT / T ** 2:.2f} Hz; I3 steps on {share:.4f} +- {sshare:.4f} of them.')
            if FRAME_B[0] <= T <= FRAME_B[1] and SHARE_B[0] <= share <= SHARE_B[1]:
                verdict = 'b'
                print(f'   * (b): one handshake per frame, frames at {1e6 / T:.1f} Hz, FLAG3 high on {100 * share:.1f}% of them.')
                if abs(share - 0.5) < 0.01 and one_position:
                    print('     (exactly half: frames of two evenly spaced handshakes at half that rate, FLAG3 always high, would'
                          ' give the same stamps, but not the same phase check: the second handshake of each frame would find'
                          ' the 8-word rings half a frame on, at another position, and every read found one. So that form of'
                          ' (a) is ruled out too.)')
                elif abs(share - 0.5) < 0.01:
                    print('     (exactly half: frames of two evenly spaced handshakes at half that rate, FLAG3 always high, would'
                          ' give the same stamps; only that symmetric form of (a) is left: the phase check, which could tell'
                          ' them apart, did not find one ring position)')
            else:
                verdict = 'neither'
                print('   * NEITHER (a) nor (b): the period or FLAG3\'s share is outside both readings.')
        else:
            F = 2 * T
            d = abs(best[3][1] - best[3][0])
            share = R3 * F
            sshare = share * ((sR3 / R3) ** 2 + (sT / T) ** 2) ** 0.5
            print(f'   * the handshakes come in two kinds, {T - d:.2f} and {T + d:.2f} us apart in turn: frames of '
                  f'{F:.5f} us +- {2000 * sT:.2f} ns ({1e6 / F:.2f} +- {2e6 * sT / F ** 2:.2f} Hz) with two handshakes each; '
                  f'I3 steps {share:.4f} +- {sshare:.4f} times per frame.')
            if FRAME_A[0] <= F <= FRAME_A[1] and SHARE_A[0] <= share <= SHARE_A[1]:
                verdict = 'a'
                print(f'   * (a): frames at {1e6 / F:.1f} Hz, FLAG3 high on {100 * share:.1f}% of them, two handshakes per frame.')
            else:
                verdict = 'neither'
                print('   * NEITHER (a) nor (b): two kinds of handshake, but the frame or FLAG3\'s share is outside reading (a).')
    if verdict in ('a', 'b'):
        print(f'   (rates with the tick taken as 1 ms; were the count clock exactly 2 MHz, they would be {clk.K / 2000:.5f} times'
              ' these; the instrument\'s crystals\' tolerance aside)')
    print(f'   verdict: {verdict or "none"}')
    return bad


# ---- phase 2 ----------------------------------------------------------------------------------------------
def p2head(b, magic, n):
    if b[:8] != magic or len(b) != n:
        print(f'{magic[:5].decode()}: not the probe\'s format'); return None
    h = u32s(b, 0, 32)
    st = h[2]
    print(f'{magic.decode()[:5]}.BIN: {d_status(st)}; ms {h[3]} to {h[4]}; SYSCON {h[5]:#010x}')
    print_found(b)
    names = ('DMAC0', 'IIEP0', 'IMEP0', 'CEP0', 'CPEP0', 'DMASTAT')
    table(('register', 'before', 'after'), [(nm, f'{h[6 + i]:#010x}', f'{h[20 + i]:#010x}') for i, nm in enumerate(names)])
    print(f'   DMAC0 used {h[26]:#06x} ({d_dmac(h[26])}); words asked {h[27]}, read {h[28]}; FS polls {h[29]} in all, '
          f'at most {h[30]} for one word; dead flag at the end {h[31]:#x}')
    return h


def records(img, base=0x48400000):
    """every download block in a program image: (cpu address, mode, target, payload)"""
    out = []
    for m in re.finditer(rb'\x20\x04[\x00\x80]', img):
        o = m.start()
        if o + 12 > len(img):
            continue
        mode, tgt, ln = img[o + 2], int.from_bytes(img[o + 6:o + 8], 'big'), int.from_bytes(img[o + 10:o + 12], 'big')
        if 0x8000 <= tgt <= 0xFFFF and 0 < ln < 0x2000 and ln % (6 if mode == 0x80 else 5) == 0:
            out.append((base + o, mode, tgt, img[o + 12:o + 12 + ln]))
    return out


def pm_words(payload):
    return [int.from_bytes(payload[i:i + 6], 'big') for i in range(0, len(payload), 6)]


def dm_words(payload):
    return [int.from_bytes(payload[i:i + 4], 'big') for i in range(0, len(payload), 5)]


def kernel(img):
    """the record holding PM 0x8000: its PM and DM blocks, {target: words}"""
    recs = records(img)
    k = next((i for i, r in enumerate(recs) if r[1] == 0x80 and r[2] == 0x8000), None)
    if k is None:
        return None, None
    pm, dm = {}, {}
    # the blocks of that record are consecutive: walk back and forward while the headers chain
    first = k
    while first > 0 and recs[first - 1][0] + 12 + len(recs[first - 1][3]) == recs[first][0]:
        first -= 1
    i = first
    while i < len(recs):
        a, mode, tgt, pl = recs[i]
        (pm if mode == 0x80 else dm)[tgt] = pm_words(pl) if mode == 0x80 else dm_words(pl)
        if i + 1 < len(recs) and recs[i + 1][0] == a + 12 + len(pl):
            i += 1
        else:
            break
    return pm, dm


def compare(dump, start, blocks, width):
    rows = []
    for tgt, words in sorted(blocks.items()):
        if not start <= tgt < start + len(dump):
            continue
        n = min(len(words), start + len(dump) - tgt)
        same = sum(dump[tgt - start + i] == words[i] for i in range(n))
        diff = [tgt + i for i in range(n) if dump[tgt - start + i] != words[i]]
        rows.append((f'{tgt:#06x}', n, same, (', '.join(f'{x:#06x}' for x in diff[:6]) + (' ...' if len(diff) > 6 else ''))
                     if diff else '-'))
    if rows:
        table(('block', 'words', f'equal ({width}-bit)', 'first that differ'), rows)


def load_program(p):
    if os.path.isdir(p):
        import find_fw
        return find_fw.interleave(open(os.path.join(p, 'PRGEVEN.BIN'), 'rb').read(),
                                  open(os.path.join(p, 'PRGODD.BIN'), 'rb').read())
    return open(p, 'rb').read()


def pm(b, prog):
    h = p2head(b, b'DSPPM001', 0x5480)
    if h is None:
        return 1
    words = [int.from_bytes(b[0x80 + 6 * i:0x86 + 6 * i], 'little') for i in range(0xE00)]
    print(f'   PM 0x8000-0x8DFF: {sum(1 for w in words if w)} of {len(words)} words not zero; 0x8000-0x8007: ' +
          ' '.join(f'{w:012x}' for w in words[:8]))
    if prog and not h[28]:
        print('   nothing was read: no comparison with the kernel')
    elif prog:
        kp, _ = kernel(prog)
        if kp:
            print('   against the kernel the firmware uploads (its download record; 0x8400 is overwritten by the'
                  ' effect programs, the unit CALL slots 0x8080-0x80A0 are patched at run time):')
            compare(words, 0x8000, kp, 48)
        else:
            print('   no kernel record (a PM block for 0x8000) in that program image')
    return 0


def dm(b, prog):
    h = p2head(b, b'DSPDM001', 0x36A0)
    if h is None:
        return 1
    d1 = u32s(b, 0x80, 0x800)
    d2 = u32s(b, 0x2080, 0x500)
    print(f'   DM 0x9800-0x9FFF: {sum(1 for w in d1 if w)} of 2048 words not zero; DM 0xC000-0xC4FF: '
          f'{sum(1 for w in d2 if w)} of 1280')
    for k in range(8):
        rec = u32s(b, 0x3480 + 68 * k, 17)
        nm = ['CPR0A', 'CPR0B', 'CPR1A', 'CPR1B', 'CPT0A', 'CPT0B', 'CPT1A', 'CPT1B'][k]
        a = 0x8000 | rec[0] & 0x7FFF
        if 0x8008 <= a <= 0xFFF7:
            print(f'   {nm} = {rec[0]:#010x}: DM {a - 8:#06x}-{a + 7:#06x}: ' + ' '.join(f'{w:08x}' for w in rec[1:]))
        else:
            print(f'   {nm} = {rec[0]:#010x}: no TCB read (outside internal memory)')
    if prog and not h[28]:
        print('   nothing was read: no comparison with the kernel')
    elif prog:
        _, kd = kernel(prog)
        if kd:
            print('   against the kernel\'s DM blocks (variables and delay lines change at run time; constants should not):')
            compare(d1, 0x9800, kd, 32)
            compare(d2, 0xC000, kd, 32)
    return 0


def main(argv):
    from check_real_dump import load_dir
    args, pos = {}, []
    it = iter(argv)
    for a in it:
        if a == '--program':
            args['program'] = next(it)
        else:
            pos.append(a)
    d = pos[0]
    files, rows, header = load_dir(d)
    print('\n'.join(header))
    m = re.search(r'PROGRAM (\d+)', header[0])
    build = int(m.group(1)) if m else None
    bad, out, data = 0, [], {}
    for name, short, size, crc, bsum, why, golden in rows:
        b = files.get(short) or files.get(short.upper())
        if why or b is None:
            out.append((short, '-', why or 'NOT FOUND')); bad += 1; continue
        whole = len(b) == size and zlib.crc32(b) & 0xffffffff == crc and sum(b) & 0xffffffff == bsum
        bad += not whole
        out.append((short, len(b), 'whole (= DUMPLIST.TXT)' if whole else 'DAMAGED IN TRANSFER'))
        data[short.upper()] = b
    table(('file', 'bytes', 'copy off the card'), out)
    print()
    prog = load_program(args['program']) if args.get('program') else None
    iopv = None
    if 'DSPHOST.BIN' in data:
        bad += host(data['DSPHOST.BIN'], build); print()
    if 'DSPIOP.BIN' in data:
        n, iopv = iop(data['DSPIOP.BIN']); bad += n; print()
    if 'DSPTIME.BIN' in data:
        n, ser = series(data['DSPTIME.BIN']); bad += n
        if ser:
            rates(ser, iopv)
        print()
    if 'DSPPM.BIN' in data:
        bad += pm(data['DSPPM.BIN'], prog); print()
    if 'DSPDM.BIN' in data:
        bad += dm(data['DSPDM.BIN'], prog); print()
    if 'DSPRATE.BIN' in data:
        bad += rate_report(data['DSPRATE.BIN']); print()
    print('everything checks out' if bad == 0 else f'{bad} problem(s): see above')
    return bad


def rate_synth(model, seed=8):
    """A made-up DSPRATE.BIN: the probe's run (romdump_dsprate.s, step by step) simulated against a DSP of reading
    'a' (frames of 44.44 us, two handshakes 24.0 and 20.44 us apart, I3 steps every frame), 'b' (one handshake per
    frame of 22.676 us, I3 steps on every other frame), 'ack' (every access answered at once, I3 still: the
    emulator), or 'notm4' ('b' with timer 4 not running). The CPU side: TM4 at 2 MHz, BR 0x7D0; the tick handler
    steps the millisecond counter 1 us after each reload (stamps read in between are stale) and costs 6 us; each
    access takes about 2 us around the DSP's answer, the re-latch 0.6 us, a stamp 0.5 us."""
    import bisect
    import random
    r = random.Random(seed)
    BR = 0 if model == 'notm4' else 0x7D0
    K, CU = 0x7D1, 0.5
    c0 = r.randrange(K)
    ms_start = 7000000 + r.randrange(100000)
    end_us = 6.0e6
    reloads = [(j * K - c0) * CU for j in range(1, int(end_us / (K * CU)) + 2)]
    isr = [x + 1.0 for x in reloads]

    def msvis(t):
        return ms_start + bisect.bisect_right(isr, t)

    def bc(t):
        return 0 if model == 'notm4' else BR - (int(t / CU) + c0) % K

    def run(t, dt):
        end = t + dt
        i = bisect.bisect_left(isr, t)
        while i < len(isr) and isr[i] < end:
            end += 6.0
            i += 1
        return end

    e0 = r.uniform(0, 40)
    if model == 'a':
        F, A = 1e6 / 22500, 24.0
    else:
        F, A = 1e6 / 44100, None

    def next_event(t):
        if model == 'ack':
            return t
        m = max(0, int((t - e0) // F))
        while True:
            for e in ((e0 + m * F,) if A is None else (e0 + m * F, e0 + m * F + A)):
                if e >= t:
                    return e
            m += 1

    def i3(t):
        if model == 'ack':
            return 0x656F0
        frames = max(0, int((t - 5.0 - e0) // F) + 1)
        steps = frames if model == 'a' else (frames + 1) // 2
        return 0x656F0 + (0x2A11 - steps) % 0x4650

    def access(t):
        e = next_event(t + 0.9)
        rd = e + 0.4 + r.uniform(0, 0.3)
        return run(t, rd + 0.8 - t), rd

    st = {'retry': 0}

    def stamp(t, base):
        while True:
            m1, b_, m2 = msvis(t), bc(t + 0.15), msvis(t + 0.3)
            if m1 == m2:
                return ((m1 - base) & 0xFFFF) << 16 | b_, t + 0.5
            st['retry'] += 1
            t += 0.45

    def dspread(t, value):
        t = run(t, 0.6)
        t, rd = access(t)
        v = value(rd)
        t, _ = access(t)
        return run(t, 0.5), v

    out = bytearray(0x20000)
    t = 1000.0
    base = msvis(t)
    h = {'ms0': base}
    cal = []
    for k in range(1024):
        s, t = stamp(t, base)
        cal.append(s)
        t = run(t, 4.5)
    at = []
    for k in range(2048):
        t = run(t, 0.6)
        s1, t = stamp(t, base)
        t, rd = access(t)
        v = i3(rd)
        s2, t = stamp(t, base)
        t, _ = access(t)
        at.append((s1, s2, v & 0xFFFF, v >> 16))
        t = run(t, 0.4)
    s_end, t = stamp(t, base)
    ph = []
    for k in range(240):
        t = run(t, 1 + (k & 31) * 1.6)
        s1, t = stamp(t, base)
        t, cr = dspread(t, lambda x: 5)
        s2, t = stamp(t, base)
        t, ii = dspread(t, lambda x: 0xC365)
        ph.append((s1, cr, s2, ii))
    h['ms1'] = msvis(t)
    struct.pack_into('<8s10I', out, 0, b'DSPRATE1', 1, base, h['ms1'], 0, 0, 1, BR, 0 if model == 'notm4' else 0x81,
                     bc(1000.0), 0x11)
    out[0x30:0x50] = struct.pack('<8I', 15, 0x4840AE77, 0x4840B3F5, 0x4840B433, 0x4840B19B, 0x4840B090, 0x500066D8,
                                 0x500066D9)
    struct.pack_into('<20I', out, 0x50, 1024, 64, 2048, 2048, 240, 240, 24, 1000, 3, st['retry'], 0, s_end,
                     0x100, 0x1100, 0x7100, 0x40, 0x8000, 0x0A | 0x60 << 8 | 0x62 << 16, 0x11, 8)
    struct.pack_into('<1024I', out, 0x100, *cal)
    for k, (s1, s2, lo, hi) in enumerate(at):
        struct.pack_into('<IIHH', out, 0x1100 + 12 * k, s1, s2, lo, hi)
    for k, x in enumerate(ph):
        struct.pack_into('<4I', out, 0x7100 + 16 * k, *x)
    for j in (1, 2, 3):
        t = run(t, 150000.0)                    # the chunk before is written to the card
        st['retry'] = 0
        base = msvis(t)
        o = j * 0x8000
        target = base + 1
        for i in range(1000):
            while msvis(t) < target:
                t += 0.7
            t = run(t, 0.3)
            s1, t = stamp(t, base)
            t, v = dspread(t, i3)
            s2, t = stamp(t, base)
            struct.pack_into('<3I', out, o + 0x40 + 12 * i, s1, v, s2)
            target = msvis(t) + 1
        struct.pack_into('<8s11I', out, o, b'DSPRSEG' + bytes([0x30 + j]), 1, base, msvis(t), 0, 0, 1000, 1000, j,
                         st['retry'], 0, 0x11)
    return bytes(out)


def self_test():
    """Made-up phase 1 and 2 files in the probe's formats: a timer counting down 60,000 per ms, SPORT counts
    going down 44.1 per ms, SYSCON 0x410; PM and DM that equal a made-up kernel record."""
    import contextlib
    import io
    import random
    import tempfile
    r = random.Random(21065)
    found = struct.pack('<8I', 15, 0x4840AE77, 0x4840B3F5, 0x4840B433, 0x4840B19B, 0x4840B090, 0x500066D8, 0x500066D9)
    hostb = bytearray(0x650)
    hostb[:8] = b'DSPHOST1'
    struct.pack_into('<7I', hostb, 8, 1, 1000, 0, 1, 0x0011, 0x50006500, 0x500)
    hostb[0x30:0x50] = found
    struct.pack_into('<I', hostb, 0x50 + 4 * 0x17, 0x0011)
    hostb[0x150 + 0x1D9] = 1
    regs = {a: r.getrandbits(32) for a in READ}
    regs[0x00] = 0x410
    regs[0xE0] = (1 | 1 << 1 | 23 << 4 | 1 << 18)
    iopb = bytearray(0x870)
    iopb[:8] = b'DSPIOP01'
    struct.pack_into('<10I', iopb, 8, 1, 2000, 2010, 0, 0, 1, 1, 0x11, 0x11, len(READ))
    iopb[0x30:0x50] = found
    iopb[0x50:0x70] = mask_bytes()
    for a, v in regs.items():
        struct.pack_into('<I', iopb, 0x70 + 4 * a, v)
        struct.pack_into('<I', iopb, 0x470 + 4 * a, v)
    regs[0x28] = 0
    struct.pack_into('<I', iopb, 0x70 + 4 * 0x28, 0)
    struct.pack_into('<I', iopb, 0x470 + 4 * 0x28, 0)
    tb = bytearray(0x55F0)
    tb[:8] = b'DSPTIME1'
    struct.pack_into('<10I', tb, 8, 1, 200, 5, 256, 3000, 4100, 0, 0, 21, 5)
    tb[0x30:0x50] = found
    for i in range(200):
        t = 3000 + 5 * i
        vals = [(0xF0000000 - 60000 * (t - 3000)) & 0xFFFFFFFF, 7, 0x3F] + \
               [int(50000 - 44.1 * (t - 3000)) for _ in range(8)] + [0x9F00 + k for k in range(8)]
        struct.pack_into('<21I', tb, 0x50 + 84 * i, t, t + 1, *vals)
    for i in range(256):
        t = 4000 + i * 100 // 256
        struct.pack_into('<5I', tb, 0x50 + 84 * 200 + 20 * i, t, 0, 7, 0, 0)
    words = [r.getrandbits(48) for _ in range(258)]
    dmw = [r.getrandbits(32) for _ in range(80)]
    rec = b'\x20\x04\x00\x00\x00\x00\x98\x00\x00\x00' + (80 * 5).to_bytes(2, 'big') + \
        b''.join(w.to_bytes(4, 'big') + b'\x00' for w in dmw) + \
        b'\x20\x04\x80\x00\x00\x00\x80\x00\x00\x00' + (258 * 6).to_bytes(2, 'big') + \
        b''.join(w.to_bytes(6, 'big') for w in words) + bytes(12)
    prog = bytes(0x1000) + rec + bytes(0x1000)
    pmb = bytearray(0x5480)
    pmb[:8] = b'DSPPM001'
    struct.pack_into('<5I', pmb, 8, 0x81, 5000, 5400, 0x410, 0xA0)
    pmb[0x30:0x50] = found
    struct.pack_into('<7I', pmb, 0x68, 0xA5, 0xE00, 0xE00, 0xE00, 1, 0, 0)
    for i, w in enumerate(words):
        pmb[0x80 + 6 * i:0x86 + 6 * i] = w.to_bytes(6, 'little')
    pmb[0x80 + 6 * 5] ^= 1
    dmb = bytearray(0x36A0)
    dmb[:8] = b'DSPDM001'
    struct.pack_into('<5I', dmb, 8, 0x81, 6000, 6300, 0x410, 0xA0)
    dmb[0x30:0x50] = found
    struct.pack_into('<7I', dmb, 0x68, 0x45, 0xD80, 0xD80, 0xD80, 1, 0, 0)
    for i, w in enumerate(dmw):
        struct.pack_into('<I', dmb, 0x80 + 4 * i, w)
    struct.pack_into('<I', dmb, 0x3480, 0x9F03)
    with tempfile.TemporaryDirectory(prefix='check_dsp_probe_') as t:
        lines = ['KN7000 ROM DUMPER (KN7APP.BIN)  PROGRAM 893  TABLE 80  release byte 0x13  build options 0x00130000',
                 'loader found: 0x7F (self-test)']
        for n, b in (('DSPHOST.BIN', hostb), ('DSPIOP.BIN', iopb), ('DSPTIME.BIN', tb), ('DSPPM.BIN', pmb),
                     ('DSPDM.BIN', dmb)):
            open(os.path.join(t, n), 'wb').write(b)
            lines.append(f'dsp.bin  {n}  {len(b)} crc32 {zlib.crc32(b) & 0xffffffff:08X} bytesum {sum(b) & 0xffffffff:08X}  x')
        open(os.path.join(t, 'DUMPLIST.TXT'), 'w', newline='\r\n').write('\n'.join(lines) + '\n')
        open(os.path.join(t, 'prog.bin'), 'wb').write(prog)
        with contextlib.redirect_stdout(io.StringIO()) as out:
            n = main([t, '--program', os.path.join(t, 'prog.bin')])
        o = out.getvalue()
    assert n == 0 and 'everything checks out' in o, o
    assert 'HBW 16-bit host bus, LSW first' in o and '16-bit, LSW first, as the firmware set it' in o, o
    assert re.search(r'\| TCOUNT0 +\| [^|]+\| 200 values, counts down +\| 60000\.0/ms', o), o
    assert re.search(r'\| CT0A +\| [^|]+\| \d+ values, counts down +\| 44\.\d/ms', o), o
    assert 'G17ICR (0x3400015C, the DSP handshake group) = 0x0011' in o and 'kernel downloaded' in o, o
    assert re.search(r'\| 0x8000 \| 258 +\| 257 ', o) and re.search(r'\| 0x9800 \| 80 +\| 80 ', o), o
    assert 'CPT0A' not in o or 'CPR0A = 0x00009f03: DM 0x9efb-0x9f0a' in o, o
    # pass 8: made-up DSPRATE.BIN files, the probe's run simulated against each reading (rate_synth)
    got = {}
    for model in ('a', 'b', 'ack', 'notm4'):
        with contextlib.redirect_stdout(io.StringIO()) as out:
            n = rate_report(rate_synth(model))
        got[model] = out.getvalue()
        assert n == 0, got[model]
    o = got['b']
    assert 'verdict: b' in o and re.search(r'frames at 441\d\d\.\d Hz, FLAG3 high on 50\.0%', o), o
    assert 'So that form of (a) is ruled out too' in o, o
    assert '| I3 series, after MSGR2' in o and re.search(r'\| I3 series, after MSGR2 +\| 3000 \| 22\.66\d+ ', o), o
    assert 'stale stamps put right' in o and 'TM4 counts down from 2000 to 0' in o, o
    o = got['a']
    assert 'verdict: a' in o and re.search(r'frames at 225\d\d\.\d Hz, FLAG3 high on 100\.0%', o), o
    assert re.search(r'two kinds, 20\.4\d and 23\.9\d us apart', o), o
    assert 'verdict: neither' in got['ack'] and 'wait for nothing' in got['ack'], got['ack']
    assert 'verdict: none' in got['notm4'] and 'TM4 DOES NOT RUN' in got['notm4'], got['notm4']
    with tempfile.TemporaryDirectory(prefix='check_dsp_probe_') as t:
        b = rate_synth('b', 9)
        open(os.path.join(t, 'DSPRATE.BIN'), 'wb').write(b)
        open(os.path.join(t, 'DUMPLIST.TXT'), 'w', newline='\r\n').write(
            'KN7000 ROM DUMPER (KN7APP.BIN)  PROGRAM 893  TABLE 80  release byte 0x13  build options 0x00430000\n'
            'loader found: 0x7F (self-test)\n'
            f'dsp_rate.bin  DSPRATE.BIN  {len(b)} crc32 {zlib.crc32(b) & 0xffffffff:08X} bytesum {sum(b) & 0xffffffff:08X}  x\n')
        with contextlib.redirect_stdout(io.StringIO()) as out:
            n = main([t])
        o = out.getvalue()
    assert n == 0 and 'everything checks out' in o and 'verdict: b' in o, o
    print('self-test passed: SYSCON packing decoded, a 60 MHz timer and a 44.1 kHz SPORT count measured, the PM'
          ' and DM readback compared with a kernel record (one changed word found); pass 8: reading (a) (two handshakes'
          ' per 22.5 kHz frame), reading (b) (one per 44.1 kHz frame), a DSP that answers at once (neither) and a'
          ' stopped TM4 (none) each told apart from simulated runs')


if __name__ == '__main__':
    if sys.argv[1:] == ['--self-test']:
        self_test()
    elif sys.argv[1:] == ['--mask-asm']:
        print(asm_mask())
    else:
        sys.exit(1 if main(sys.argv[1:]) else 0)
