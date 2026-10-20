#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# check_dsp_probe.py DIR [--program P1DIR] -- what did the DSP probe (cnv_romdump, KN7APP.BIN built with OPT_DSP
# or OPT_DSPMEM; romdump_dsp.s) read from the KN7000's effects DSP, an ADSP-21065L? DIR is what came off the SD
# card: DUMPLIST.TXT and DSPHOST.BIN, DSPIOP.BIN, DSPTIME.BIN (phase 1) and/or DSPPM.BIN, DSPDM.BIN (phase 2).
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
#     uploads (its download record: blocks of 12-byte headers, id 0x2004, PM entries 3 BE u16, DM entries 5 bytes).
# Exit status 1 when a file is damaged or missing, or a header is not what the probe writes.
#   python3 -I check_dsp_probe.py pass6-run1                 # phase 1
#   python3 -I check_dsp_probe.py pass7-run1 --program pass1-run1
#   python3 -I check_dsp_probe.py --self-test                # the decoders on made-up files
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
          ' written'), (0x40, 'EPB0 stayed empty: stopped'), (0x80, 'channel 8 registers written back')]


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
    print('everything checks out' if bad == 0 else f'{bad} problem(s): see above')
    return bad


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
    print('self-test passed: SYSCON packing decoded, a 60 MHz timer and a 44.1 kHz SPORT count measured, the PM'
          ' and DM readback compared with a kernel record (one changed word found)')


if __name__ == '__main__':
    if sys.argv[1:] == ['--self-test']:
        self_test()
    elif sys.argv[1:] == ['--mask-asm']:
        print(asm_mask())
    else:
        sys.exit(1 if main(sys.argv[1:]) else 0)
