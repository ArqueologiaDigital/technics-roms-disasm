#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# check_cpu_probe.py DIR|CPUTIME.BIN [--json OUT] [--self-test] -- decodes pass 9, the CPU timing probe
# (romdump_cputime.s, build/cputime/KN7APP.BIN): how fast the KN7000's MN10300 (MN103002A, AM31 core) runs each
# class of instruction and each kind of memory access, in ns and in cycles, and what the bus and cache registers
# hold.
#
# The file: CT_CHUNKS chunks of 32 KB, each one pass over the same test table. A test runs CT_R times per chunk;
# a run is TM4BC read, `calls` the test routine, TM4BC read (and the ms counter just before and after). TM4 counts
# down from TM4BR (2000) at 2 MHz (IOCLK/8), so the time of a run is (BC before - BC after) mod (TM4BR + 1) counts
# of 500 ns; every run is shorter than one period (the ms counter checks it). Pass 8 measured the effects DSP's
# frames at 44,087 Hz with that period taken as 1 ms, so the count is 500 ns to about 0.05%.
#
# What it computes, per test (TESTS below, the same list as CtTests in romdump_cputime.s):
#   * the runs no interrupt fell into: within one count of the shortest. Their mean is the run's time; since a
#     run starts at a random phase of the 2 MHz count, the mean resolves below one count (the spread is reported);
#   * per turn of its loop: (run - the null test's run) / N; per operation: (that - the reference's per turn) / K,
#     where the reference is the empty loop (LOOP, or LPW5/LPS6 for the loops that also advance a0) or a test with
#     the same body less what is measured (MREF for the multiplications, DREF for the divisions, CRET for calls);
#   * ns, and cycles at the core clock this file implies (from ADD, 16 `add d1, d2` per turn, taken as 1 cycle each,
#     MN103S manual p.174/160) and at the nominal 32 MHz; for memory, the cycles over a cache hit.
# The manual's cycle counts (MN1030/MN103S Instruction Manual, AM31 core: README.md "Pass 9") are printed beside.
#
# --json OUT writes every estimate (for the emulator's timing model). --self-test simulates the probe on a machine
# with known costs (TM4, interrupts in some runs, a random phase) and checks that the decoder gets them back, then
# a stopped TM4 and a firmware routine not found.
import json
import os
import random
import struct
import sys

COUNT_NS = 500.0
NOMINAL_MHZ = 32.0
CHUNK = 0x8000

# tag: (K, reference, group, what, the manual's cycles per operation (AM31), region key or None)
# K = operations per turn of the loop (0: the null test; 1 with no reference: the loop itself)
TESTS = [
    ('NULL', 0, None, 'harness', 'the harness: TM4BC, calls, rets, TM4BC', None, None),
    ('LOOP', 1, None, 'loop', 'add -1, d0; bne (one turn)', 4, None),
    ('LPW5', 1, None, 'loop', 'add 512, a0; add -1, d0; bne', 5, None),
    ('LPS6', 1, None, 'loop', 'add 64, a0; add -1, d0; bne', 5, None),
    ('LBUF', 1, None, 'loop', 'setlb loop: add -1, d0; lne (one turn)', 2, None),
    ('NOP ', 16, 'LOOP', 'alu', 'nop', 1, None),
    ('ADD ', 16, 'LOOP', 'alu', 'add d1, d2 (1 byte)', 1, None),
    ('AND ', 16, 'LOOP', 'alu', 'and d1, d2 (2 bytes)', 1, None),
    ('MOVR', 16, 'LOOP', 'alu', 'mov d1, d2', 1, None),
    ('INC ', 16, 'LOOP', 'alu', 'inc a1', 1, None),
    ('ASL2', 16, 'LOOP', 'alu', 'asl2 d1', 1, None),
    ('LSRI', 16, 'LOOP', 'alu', 'lsr 3, d1 (3 bytes)', 1, None),
    ('EXTB', 16, 'LOOP', 'alu', 'extbu d1', 1, None),
    ('MI8 ', 16, 'LOOP', 'alu', 'mov imm8, d1 (2 bytes)', 1, None),
    ('MI16', 16, 'LOOP', 'alu', 'mov imm16, d1 (3 bytes)', 1, None),
    ('MI32', 16, 'LOOP', 'alu', 'mov imm32, d1 (6 bytes)', 2, None),
    ('BRA ', 16, 'LOOP', 'branch', 'bra (taken)', 3, None),
    ('BNE ', 16, 'LOOP', 'branch', 'bne, taken', 3, None),
    ('BEQ ', 16, 'LOOP', 'branch', 'beq, not taken', 1, None),
    ('JMP ', 16, 'LOOP', 'branch', 'jmp d16 (taken)', 2, None),
    ('LDSP', 16, 'LOOP', 'stack', 'mov (8, sp), d1', 1, None),
    ('STSP', 16, 'LOOP', 'stack', 'mov d1, (8, sp)', 1, None),
    ('LDAB', 16, 'LOOP', 'stack', 'mov (abs32), d1 (6 bytes, work RAM)', 2, None),
    ('LUDP', 8, 'LOOP', 'stack', 'mov (a0), d1 + add d1, d2 (uses the load): per pair', 4, None),
    ('LUIN', 8, 'LOOP', 'stack', 'mov (a0), d1 + add d2, d2 (independent): per pair', 2, None),
    ('MVM1', 8, 'LOOP', 'call', 'movm [d2], (sp) + movm (sp), [d2]: per pair', 3, None),
    ('MVM4', 8, 'LOOP', 'call', 'movm push + pop of 4 registers: per pair', 9, None),
    ('CAL0', 8, 'LOOP', 'call', 'call d16, 0, 0 + ret 0, 0: per pair', 7, None),
    ('CAL4', 8, 'LOOP', 'call', 'call d16 + ret saving [d2,d3,a2,a3]: per pair', 11, None),
    ('CALF', 8, 'LOOP', 'call', 'call d16, 0, 0 + retf 0, 0: per pair', 4, None),
    ('CALS', 8, 'LOOP', 'call', 'calls (a1) + rets: per pair', 8, None),
    ('MREF', 8, 'LOOP', 'muldiv', 'reference: mov a1, d2; nop; nop', 3, None),
    ('MUL0', 8, 'MREF', 'muldiv', 'mul, multiplicand 0', 3, None),
    ('MUL1', 8, 'MREF', 'muldiv', 'mul, multiplicand 0x7F (1 byte)', 13, None),
    ('MUL2', 8, 'MREF', 'muldiv', 'mul, multiplicand 0x7FFF (2 bytes)', 21, None),
    ('MUL4', 8, 'MREF', 'muldiv', 'mul, multiplicand 0x12345678 (4 bytes)', 34, None),
    ('MUU1', 8, 'MREF', 'muldiv', 'mulu, 0x7F', 13, None),
    ('MUU4', 8, 'MREF', 'muldiv', 'mulu, 0x12345678', 34, None),
    ('DREF', 8, 'LOOP', 'muldiv', 'reference: mov a1, d2; ext d2', 2, None),
    ('DIV1', 8, 'DREF', 'muldiv', 'div by 7, dividend 0x7F', 14, None),
    ('DIV4', 8, 'DREF', 'muldiv', 'div by 7, dividend 0x12345678', 38, None),
    ('DIVN', 8, 'DREF', 'muldiv', 'div by 7, dividend -0x12345678 (MDR = -1)', 38, None),
    ('DVU1', 8, 'DREF', 'muldiv', 'divu by 7, dividend 0x7F', 14, None),
    ('DVU4', 8, 'DREF', 'muldiv', 'divu by 7, dividend 0x12345678', 38, None),
    ('CRET', 4, 'LOOP', 'fetch', 'mov a0, d0 + calls (a1) to a bare retf: per call', 6, None),
    ('FL1L', 1, None, 'single', 'one call of the FLASH routine, long path (whole run less the null test)', None, None),
    ('TW1L', 1, None, 'single', 'one call of the RAM copy, long path', None, None),
    ('FLLG', 4, 'CRET', 'fetch', 'the firmware routine in FLASH, long path (24 instructions): per call, less a bare call',
     None, None),
    ('TWLG', 4, 'CRET', 'fetch', 'its copy in work RAM, long path: per call, less a bare call', None, None),
    ('FLSH', 4, 'CRET', 'fetch', 'the firmware routine in FLASH, short path (6 instructions)', None, None),
    ('TWSH', 4, 'CRET', 'fetch', 'its copy in work RAM, short path', None, None),
]
# the memory tests: tag -> (region, view, kind, width); kinds L load same address, W load walk (64 bytes apart,
# every one a new cache line), Q load sequential, S store same (the value there), X store walk, Y store sequential,
# R read + write back same address (per pair), M read + write back sequential (per pair)
REGIONS = [  # key, name, view
    ('RA', 'work RAM 0x502D0000 / walk 0x50180000', 'cached'),
    ('PR', 'program flash 0x48400000 / walk 0x48600000', 'cached'),
    ('TB', 'table flash 0x48000000 / walk 0x48010000', 'cached'),
    ('BT', 'IC18 boot ROM 0x40000000 / walk 0x40010000', 'cached'),
    ('LB', 'library RAM 0x4C000000 / walk 0x4C010000', 'cached'),
    ('C2', 'IC21 0x56800000 / walk 0x56810000', 'cached'),
    ('PI', 'IC19 0x57800000 / walk 0x57810000', 'cached'),
    ('RU', 'work RAM 0x902D0000 / sequential 0x90180000', 'uncached'),
    ('CU', 'IC21 0x96800000 / sequential 0x96810000', 'uncached'),
    ('SR', 'IC23 0x84000000 / sequential 0x84010000', 'uncached'),
    ('LC', 'LCD frame 0x9CE48800 (row 232)', 'uncached'),
]
KREF = {'L': ('LOOP', 16), 'W': ('LPW5', 8), 'Q': ('LPS6', 16), 'S': ('LOOP', 16), 'X': ('LPW5', 8), 'Y': ('LPS6', 16),
        'R': ('LOOP', 8), 'M': ('LPS6', 8)}
KWHAT = {'L': 'load, same address', 'W': 'load, a new cache line each', 'Q': 'load, sequential',
         'S': 'store, same address', 'X': 'store, a new cache line each', 'Y': 'store, sequential',
         'R': 'read + write back, same address (pair)', 'M': 'read + write back, sequential (pair)'}
MEMTAGS = (['RAL4', 'RAL2', 'RAL1', 'RAW4', 'PRL4', 'PRL2', 'PRL1', 'PRW4', 'TBL4', 'TBL2', 'TBL1', 'TBW4',
            'BTL4', 'BTL2', 'BTL1', 'BTW4', 'LBL4', 'LBL2', 'LBL1', 'LBW4', 'C2L4', 'C2L2', 'C2L1', 'C2W4',
            'PIL4', 'PIL2', 'PIL1', 'PIW4', 'RUL4', 'RUL2', 'RUL1', 'RUQ4', 'RUQ2', 'CUL4', 'CUL2', 'CUL1', 'CUQ4',
            'CUQ2', 'SRL4', 'SRL2', 'SRL1', 'SRQ4', 'SRQ2', 'LCL4', 'LCL2', 'LCL1', 'LCQ4', 'LCQ2'])
ONCHIP = [('TMBC', 'TM4BC 0x340010A0 (16-bit)'), ('TMMD', 'TM4MD 0x34001080 (8-bit)'), ('ICR ', 'G17ICR 0x3400015C (16-bit)'),
          ('MEM0', 'MEMCTR0 0x32000020 (16-bit)'), ('CHC ', 'CHCTR 0x20000070 (32-bit)'),
          ('STRP', 'board strap 0x98070000 (16-bit)')]
STORETAGS = ['RAS4', 'RAS2', 'RAS1', 'RAX4', 'RAY4', 'RUS4', 'RUS2', 'RUS1', 'RUY4', 'LCS4', 'LCS2', 'LCR4', 'LCR2',
             'LCM2']
for t in MEMTAGS + STORETAGS:
    k = t[2]
    w = 2 if t == 'LCM2' else int(t[3])
    TESTS.append((t, KREF[k][1], KREF[k][0], 'mem', f'{KWHAT[k]}, {8 * w}-bit', None, (t[:2], k, w)))
for t, what in ONCHIP:
    TESTS.append((t, 16, 'LOOP', 'onchip', what, None, None))
ORDER = [t[0] for t in TESTS]
# romdump_cputime.s CtTests order: the instruction tests, the memory loads, the on-chip reads, the stores
ASM_ORDER = [t[0] for t in TESTS if t[3] not in ('mem', 'onchip')] + MEMTAGS + [t for t, _ in ONCHIP] + STORETAGS
NAMES = {t[0]: t for t in TESTS}
REGNAMES = {0x32000010: 'bus 0x32000010', 0x32000020: 'MEMCTR0', 0x32000022: 'MEMCTR1', 0x32000024: 'MEMCTR2',
            0x32000026: 'MEMCTR3', 0x32000028: 'MEMCTR4', 0x3200002A: 'MEMCTR5', 0x3200002C: 'MEMCTR6',
            0x3200002E: 'MEMCTR7', 0x32000040: 'DRAM 0x32000040', 0x32000042: 'DRAM 0x32000042',
            0x20000070: 'CHCTR', 0x34001080: 'TM4MD', 0x34001090: 'TM4BR', 0x98070000: 'board strap',
            0x3400015C: 'G17ICR'}
# the firmware's bus set-up (941 0x484D710E, 893 0x484D6F01; find_cpu.py): MEMCTR1-4 by the board class
SETUP = {1: {0x32000022: 0x804, 0x32000024: 0x824, 0x32000026: 0x424, 0x32000028: 0x865},
         'other': {0x32000022: 0xB24, 0x32000024: 0x924, 0x32000026: 0x704, 0x32000028: 0x765}}
STATUS = {1: 'TM4 DID NOT MOVE: nothing timed', 2: 'the firmware routine was not found: its tests skipped',
          4: 'the chunk ran past its time cap: later tests skipped', 8: 'no millisecond counter'}


def table(head, rows):
    """an aligned, space-padded Markdown table"""
    rows = [[str(c) for c in r] for r in rows]
    w = [max(len(str(h)), *(len(r[i]) for r in rows)) if rows else len(str(h)) for i, h in enumerate(head)]
    out = ['| ' + ' | '.join(str(h).ljust(w[i]) for i, h in enumerate(head)) + ' |',
           '|' + '|'.join('-' * (x + 2) for x in w) + '|']
    out += ['| ' + ' | '.join(c.ljust(w[i]) for i, c in enumerate(r)) + ' |' for r in rows]
    return '\n'.join(out)


def u32(b, o):
    return struct.unpack_from('<I', b, o)[0]


def parse(data):
    """the chunks: header fields, registers, tests as run, runs"""
    chunks = []
    for k in range(len(data) // CHUNK):
        c = data[k * CHUNK:(k + 1) * CHUNK]
        if c[:7] != b'CPUTIME':
            chunks.append({'chunk': k, 'bad': f'magic {c[:8]!r}'})
            continue
        h = {n: u32(c, o) for n, o in (('status', 8), ('ms0', 0x0C), ('ms1', 0x10), ('chunk', 0x14), ('ntests', 0x18),
                                       ('runs', 0x1C), ('runbytes', 0x20), ('tab', 0x24), ('res', 0x28), ('ent', 0x2C),
                                       ('chunks', 0x30), ('bc_a', 0x34), ('bc_b', 0x38), ('msaddr', 0x3C), ('leaf', 0x40),
                                       ('leafhits', 0x44), ('twin', 0x48), ('tests', 0x4C), ('scr', 0x50), ('lcd', 0x54),
                                       ('clkspin', 0x58), ('done', 0x5C), ('cap', 0x60), ('sp', 0x64), ('options', 0x68),
                                       ('build', 0x6C), ('tbuild', 0x70), ('found', 0x74), ('release', 0x78))}
        h['chunk_digit'] = c[7] - 0x30
        regs = []
        for i in range(21):
            a, w, v = struct.unpack_from('<3I', c, 0x100 + 12 * i)
            if a == 0:
                break
            regs.append((a, w, v))
        tests = []
        for i in range(h['ntests']):
            o = h['tab'] + h['ent'] * i
            tag = c[o:o + 4].decode('latin1')
            tests.append((tag,) + struct.unpack_from('<4I', c, o + 4))
        runs = []
        for i in range(h['ntests']):
            rr = []
            for r in range(h['runs']):
                o = h['res'] + (i * h['runs'] + r) * h['runbytes']
                rr.append(struct.unpack_from('<4H', c, o))
            runs.append(rr)
        chunks.append({'chunk': k, 'h': h, 'regs': regs, 'tests': tests, 'runs': runs})
    return chunks


def estimate(es):
    """the runs no interrupt fell into (within a count of the shortest): their mean; and the spread"""
    if not es:
        return None
    m = min(es)
    clean = [e for e in es if e <= m + 1]
    s = sorted(es)
    return {'est': sum(clean) / len(clean), 'min': m, 'max': max(es), 'median': s[len(s) // 2], 'nruns': len(es),
            'clean': len(clean), 'hit': len(es) - len(clean)}


def analyse(chunks):
    good = [c for c in chunks if 'h' in c]
    if not good:
        return None
    period = 2001
    br = next((v for a, w, v in good[0]['regs'] if a == 0x34001090), 0)
    if br:
        period = br + 1
    per = {}
    problems = []
    for c in good:
        for i, (tag, routine, n, a0, a1) in enumerate(c['tests']):
            for r, (b0, b1, m0, m1) in enumerate(c['runs'][i]):
                if b0 == b1 == m0 == m1 == 0:
                    continue                # not run
                e = (b0 - b1) % period
                dm = (m1 - m0) & 0xFFFF
                if dm > 2 or (dm == 2 and b1 <= b0):     # two ticks need a reload inside the run (and one late)
                    problems.append(f'{tag} chunk {c["chunk"]} run {r}: ms advanced {dm}, {e} counts: longer than '
                                    'one period?')
                p = per.setdefault(tag, {'n': n, 'a0': a0, 'a1': a1, 'routine': routine, 'e': [], 'first': None})
                p['e'].append(e)
                if c['chunk'] == 0 and r == 0:
                    p['first'] = e
    est = {t: dict(estimate(p['e']), **{k: p[k] for k in ('n', 'a0', 'a1', 'routine', 'first')})
           for t, p in per.items() if p['e']}
    res = {'period': period, 'tests': est, 'problems': problems}
    if 'NULL' not in est:
        return res
    hnull = est['NULL']['est']
    turn = {}
    for t, e in est.items():
        turn[t] = (e['est'] - hnull) / e['n'] if t != 'NULL' else 0.0
    ops = {}
    for tag, k, ref, grp, what, manual, mem in TESTS:
        if tag not in est or tag == 'NULL':
            continue
        if ref is None:
            v = turn[tag] / k
        elif ref in turn:
            v = (turn[tag] - turn[ref]) / k
        else:
            continue
        ops[tag] = v * COUNT_NS          # ns per operation
    res['ns'] = ops
    res['turn_ns'] = {t: v * COUNT_NS for t, v in turn.items()}
    res['null_ns'] = hnull * COUNT_NS
    if 'ADD ' in ops and ops['ADD '] > 0:
        res['mhz'] = 1000.0 / ops['ADD ']
    return res


def fmt(v, d=2):
    return '-' if v is None else f'{v:.{d}f}'


def report(chunks, res, out=print):
    good = [c for c in chunks if 'h' in c]
    out(f'CPUTIME.BIN: {len(chunks)} chunk(s), {len(good)} with the probe\'s header')
    for c in chunks:
        if 'bad' in c:
            out(f'  chunk {c["chunk"]}: {c["bad"]}')
    if not good:
        out('NOTHING TO DECODE')
        return 1
    h = good[0]['h']
    out(f'  PROGRAM {h["build"]}, TABLE {h["tbuild"]}, release byte {h["release"]:#x}, options {h["options"]:#x}, '
        f'loader found {h["found"]:#x}')
    bad = 0
    for c in good:
        st = c['h']['status']
        flags = [m for b, m in STATUS.items() if st & b]
        out(f'  chunk {c["chunk"]}: status {st:#x}{" (" + "; ".join(flags) + ")" if flags else ""}, '
            f'{c["h"]["done"]} of {c["h"]["ntests"]} tests, ms {c["h"]["ms0"]}..{c["h"]["ms1"]} '
            f'({c["h"]["ms1"] - c["h"]["ms0"]} ms), clock check BC {c["h"]["bc_a"]} -> {c["h"]["bc_b"]}')
        bad += bool(st & 5)
    tags = [t[0] for t in good[0]['tests']]
    if tags != ASM_ORDER:
        out(f'  THE TEST TABLE IS NOT THIS DECODER\'S: {len(tags)} tests, first difference at '
            f'{next((i for i, (a, b) in enumerate(zip(tags, ASM_ORDER)) if a != b), min(len(tags), len(ASM_ORDER)))}')
        bad += 1
    out(f'  the firmware routine for the fetch tests: '
        + (f'{h["leaf"]:#010x} (found {h["leafhits"]} time(s)); the RAM copy CtTwin at {h["twin"]:#010x}, '
           f'entries {h["leaf"] & 7} and {h["twin"] & 7} bytes into an 8-byte block'
           if h['leaf'] else f'NOT FOUND ({h["leafhits"]} matches): FLLG, FLSH, FL1L skipped'))
    out('')
    out('## Registers (chunk 0; each chunk reads them again)')
    regs = {a: (w, v) for a, w, v in good[0]['regs']}
    rows = []
    for a, (w, v) in regs.items():
        others = sorted({cc['regs'][i][2] for cc in good[1:] for i in range(len(cc['regs'])) if cc['regs'][i][0] == a})
        note = ''
        if 0x32000020 <= a <= 0x3200002E:
            note = f'bits 8-12 = {(v >> 8) & 0x1F}'
            if a in SETUP[1]:
                note += f'; the set-up writes {SETUP[1][a]:#x} (board class 1) or {SETUP["other"][a]:#x} (2, 3)'
        elif a == 0x20000070:
            note = (f'bit0 {v & 1} (I-cache on, as set at boot), bit1 {(v >> 1) & 1} (D-cache on), bit7 {(v >> 7) & 1} '
                    f'(set at boot), busy bits 2/3 {(v >> 2) & 1}/{(v >> 3) & 1}')
        elif a == 0x34001090:
            note = f'period {v + 1} counts'
        elif a == 0x34001080:
            note = '0x81 = what the firmware sets' if v == 0x81 else 'NOT 0x81'
        elif a == 0x98070000:
            cls = 3 if not v & 2 else (2 if not v & 4 else 1)
            sub = {0: 5, 1: 1, 2: 2, 3: 3}[(v >> 10) & 3]
            note = (f'bits 1,2 -> board class {cls} (941 0x484D7713, 893 0x484D7506); bits 11:10 = {(v >> 10) & 3:02b}'
                    + (f' -> hardware subtype {sub} (941 0x484D7751, 893 0x484D7544)' if cls != 3 else
                       ' (ignored: class 3 takes the subtype from 0x9CC00021 bits 3:2, which the probe does not read)')
                    + f'; bit 0 = {v & 1} (941 0x484D773A: {"1" if v & 1 else "2"})')
        rows.append((f'{a:#010x}', REGNAMES.get(a, ''), w * 8, f'{v:#06x}',
                     ', '.join(f'{x:#x}' for x in others if x != v) or 'same', note))
    out(table(('address', 'register', 'bits', 'value', 'other chunks', 'note'), rows))
    m = {a: regs[a][1] for a in regs}
    for cls, vals in SETUP.items():
        if all(m.get(a) == v for a, v in vals.items()):
            out(f'MEMCTR1-4 are the firmware\'s set-up for board class {cls}.')
    out('')
    if res is None or 'ns' not in res:
        out('NO TIMING (the null test has no runs)')
        return 1
    mhz = res.get('mhz')
    out(f'## Timing: TM4 period {res["period"]} counts of {COUNT_NS:.0f} ns; the harness alone (NULL) '
        f'{res["null_ns"]:.0f} ns; core clock implied by ADD: ' + (f'{mhz:.2f} MHz' if mhz else 'unknown'))
    for p in res['problems'][:20]:
        out('  ' + p)
    bad += len(res['problems'])

    def cyc(ns, f=None):
        f = f or mhz
        return None if ns is None or not f else ns * f / 1000.0

    est = res['tests']
    ns = res['ns']

    def row(tag, extra=()):
        e = est.get(tag)
        t = NAMES[tag]
        if e is None or tag not in ns:
            return (tag.strip(), t[4], '-', '-', '-', '-', 'not run') + tuple(extra)
        spread = f'{e["clean"]}/{e["nruns"]} clean, max +{(e["max"] - e["min"]) * COUNT_NS / 1000:.1f} us'
        return (tag.strip(), t[4], fmt(ns[tag], 1), fmt(cyc(ns[tag]), 2), fmt(cyc(ns[tag], NOMINAL_MHZ), 2),
                '-' if t[5] is None else t[5], spread) + tuple(extra)

    head = ('test', 'what', 'ns', f'cycles @{mhz:.1f}' if mhz else 'cycles', 'cycles @32', 'manual', 'runs')
    for grp, title in (('loop', 'Loops (per turn)'), ('alu', 'ALU and moves (per instruction)'),
                       ('branch', 'Branches (per instruction)'), ('stack', 'Stack, absolute and load-use'),
                       ('call', 'movm, call and return (per pair)'), ('muldiv', 'Multiply and divide (per instruction)'),
                       ('fetch', 'Calls into flash and into RAM (per call)')):
        rows = [row(t[0]) for t in TESTS if t[3] == grp]
        out(f'### {title}')
        out(table(head, rows))
        out('')
    out('### One call, cold and warm (the whole run less the null test)')
    rows = []
    for tag in ('FL1L', 'TW1L'):
        e = est.get(tag)
        if not e:
            rows.append((tag, NAMES[tag][4], '-', '-', '-'))
            continue
        warm = (e['est'] - est['NULL']['est']) * COUNT_NS
        first = None if e['first'] is None else (e['first'] - est['NULL']['est']) * COUNT_NS
        rows.append((tag, NAMES[tag][4], fmt(warm, 0), fmt(first, 0),
                     fmt(None if first is None else first - warm, 0)))
    out(table(('test', 'what', 'warm ns', 'first run ns', 'first - warm'), rows))
    out('(FL1L and TW1L come before every other call of the routine and of its copy, so the first run of chunk 0 is '
        'their first execution since the probe started: its excess is the fetch of their cache lines, from the flash '
        'and from work RAM, plus whatever else was cold.)')
    out('')
    out('### Memory, per access (loads and stores; pairs for read + write back)')
    hit = ns.get('RAL4')
    rows = []
    for key, name, view in REGIONS:
        for kind in 'LWQSXYRM':
            for w in (4, 2, 1):
                tag = f'{key}{kind}{w}'
                if tag not in NAMES or tag not in ns:
                    continue
                v = ns[tag]
                over = None if hit is None or kind in 'RM' else cyc(v - hit)
                rows.append((tag, f'{name} ({view})', KWHAT[kind], 8 * w, fmt(v, 1), fmt(cyc(v), 2),
                             fmt(cyc(v, NOMINAL_MHZ), 2), fmt(over, 2),
                             f'{est[tag]["clean"]}/{est[tag]["nruns"]}'))
    for tag, what in ONCHIP:
        if tag in ns:
            v = ns[tag]
            rows.append((tag.strip(), what, 'load, same address', '', fmt(v, 1), fmt(cyc(v), 2),
                         fmt(cyc(v, NOMINAL_MHZ), 2), fmt(None if hit is None else cyc(v - hit), 2),
                         f'{est[tag]["clean"]}/{est[tag]["nruns"]}'))
    out(table(('test', 'region', 'access', 'bits', 'ns', f'cycles @{mhz:.1f}' if mhz else 'cycles', 'cycles @32',
               'over a cache hit', 'clean runs'), rows))
    out('"over a cache hit" = cycles beyond RAL4 (a word load the D-cache answers): the wait an emulator would add to '
        'a 1-cycle access there. A walk (W, X) touches a new 16-byte line every access: its cost is a line fill.')
    out('')
    if 'LCR2' in ns and 'LCL2' in ns:
        out(f'LCD: a read + write back of a halfword {ns["LCR2"]:.0f} ns, a load alone {ns["LCL2"]:.0f} ns, so the '
            f'write {ns["LCR2"] - ns["LCL2"]:.0f} ns when it follows a read; a store alone (LCS2) '
            f'{ns.get("LCS2", 0):.0f} ns.')
    return bad


def load(path):
    if os.path.isdir(path):
        f = next((os.path.join(path, n) for n in os.listdir(path) if n.upper() == 'CPUTIME.BIN'), None)
        if f is None:
            raise SystemExit(f'{path}: no CPUTIME.BIN')
        path = f
    return open(path, 'rb').read()


# ---- self-test ---------------------------------------------------------------------------------------------
TRUE = {'NULL': 18, 'LOOP': 4, 'LPW5': 5, 'LPS6': 5, 'LBUF': 2, 'NOP ': 1, 'ADD ': 1, 'AND ': 1, 'MOVR': 1, 'INC ': 1,
        'ASL2': 1, 'LSRI': 1, 'EXTB': 1, 'MI8 ': 1, 'MI16': 1, 'MI32': 2, 'BRA ': 3, 'BNE ': 3, 'BEQ ': 1, 'JMP ': 2,
        'LDSP': 1, 'STSP': 1, 'LDAB': 2, 'LUDP': 4, 'LUIN': 2, 'MVM1': 3, 'MVM4': 9, 'CAL0': 7, 'CAL4': 11, 'CALF': 4,
        'CALS': 8, 'MREF': 3, 'MUL0': 3, 'MUL1': 13, 'MUL2': 21, 'MUL4': 34, 'MUU1': 13, 'MUU4': 34, 'DREF': 2,
        'DIV1': 14, 'DIV4': 38, 'DIVN': 38, 'DVU1': 14, 'DVU4': 38, 'CRET': 6, 'FLLG': 46, 'TWLG': 46, 'FLSH': 12,
        'TWSH': 12, 'FL1L': 60, 'TW1L': 60}
NOMINAL_N = {'NULL': 1, 'LOOP': 1024, 'LPW5': 256, 'LPS6': 256, 'LBUF': 1024, 'BRA ': 128, 'BNE ': 128, 'JMP ': 128,
             'MVM1': 64, 'MVM4': 64, 'CAL0': 64, 'CAL4': 64, 'CALF': 64, 'CALS': 64, 'MREF': 64, 'MUL0': 64, 'MUL1': 64,
             'MUL2': 64, 'MUL4': 32, 'MUU1': 64, 'MUU4': 32, 'DREF': 64, 'DIV1': 64, 'DIV4': 32, 'DIVN': 32, 'DVU1': 64,
             'DVU4': 32, 'CRET': 128, 'FLLG': 32, 'TWLG': 32, 'FLSH': 64, 'TWSH': 64, 'FL1L': 1, 'TW1L': 1}


def sim_cost(tag):
    """the simulated machine's cycles per operation for the memory tests (by region, kind, width)"""
    t = NAMES[tag]
    if t[3] == 'onchip':
        return 6
    key, kind, w = t[6]
    view = dict((k, v) for k, _, v in REGIONS)[key]
    if kind == 'W':
        return 14 if key in ('RA', 'LB') else 40
    if view == 'cached' and kind in 'LS':
        return 1
    base = {'RU': 5, 'CU': 9, 'SR': 8, 'LC': 11}.get(key, 1)
    return base * (2 if w == 4 and key in ('SR', 'CU', 'LC') else 1) + (base if kind in 'RM' else 0)


def simulate(mhz=32.0, seed=1, noclock=False, noleaf=False, irq=0.15):
    rnd = random.Random(seed)
    ntest = len(ASM_ORDER)
    data = bytearray()
    tm = 0.0                            # time in counts since a reload
    ms = 50000

    def per_turn(tag):
        t = NAMES[tag]
        k, ref = t[1], t[2]
        c = TRUE[tag] if tag in TRUE else sim_cost(tag)
        if ref is None:
            return c * k
        return per_turn(ref) + k * c

    for k in range(4):
        c = bytearray(CHUNK)
        c[:8] = b'CPUTIME' + bytes([0x30 + k])
        st = (1 if noclock else 0) | (2 if noleaf else 0)
        hdr = {8: st, 0x0C: ms, 0x14: k, 0x18: ntest, 0x1C: 16, 0x20: 8, 0x24: 0x200, 0x28: 0x200 + 128 * 20, 0x2C: 20,
               0x30: 4, 0x34: 1234, 0x38: 1234 if noclock else 734, 0x3C: 0x5002B0C0,
               0x40: 0 if noleaf else 0x48471D35, 0x44: 0 if noleaf else 1, 0x48: 0x502BCF3D, 0x4C: 0x502BD044,
               0x5C: 0 if noclock else ntest, 0x6C: 893, 0x70: 80, 0x74: 0x7F, 0x78: 0x13}
        for o, v in hdr.items():
            struct.pack_into('<I', c, o, v)
        regs = [(0x32000010, 2, 0x400), (0x32000020, 2, 0x904), (0x32000022, 2, 0x804), (0x32000024, 2, 0x824),
                (0x32000026, 2, 0x424), (0x32000028, 2, 0x865), (0x3200002A, 2, 4), (0x3200002C, 2, 0),
                (0x3200002E, 2, 2), (0x32000040, 2, 0x287), (0x32000042, 2, 0x7D0), (0x20000070, 4, 0x83),
                (0x34001080, 1, 0x81), (0x34001090, 2, 0x7D0), (0x98070000, 2, 0x0406), (0x3400015C, 2, 0x1000)]
        for i, (a, w, v) in enumerate(regs):
            struct.pack_into('<3I', c, 0x100 + 12 * i, a, w, v)
        for i, tag in enumerate(ASM_ORDER):
            n = NOMINAL_N.get(tag, 128 if NAMES[tag][3] in ('alu', 'stack') else 16)
            if NAMES[tag][3] in ('alu', 'stack', 'branch') and tag not in NOMINAL_N:
                n = 256
            if NAMES[tag][3] == 'mem' and NAMES[tag][6][0] in ('RA', 'PR', 'TB', 'BT', 'LB', 'C2', 'PI') \
                    and NAMES[tag][6][1] in 'LS':
                n = 128
            if NAMES[tag][3] == 'mem' and NAMES[tag][6][1] in 'WX':
                n = 32
            a1 = 1 if tag in ('FLLG', 'FLSH', 'FL1L') else 0
            o = 0x200 + 20 * i
            c[o:o + 4] = tag.encode('latin1')
            struct.pack_into('<4I', c, o + 4, 0x502BC690, n, 0, 0x48471D35 if a1 and not noleaf else 0)
            if noclock or (noleaf and a1):
                continue
            cycles = TRUE['NULL'] + (0 if tag == 'NULL' else n * per_turn(tag))
            dur = cycles / (mhz * 1e6) * 2e6          # counts
            for r in range(16):
                tm += rnd.uniform(20, 300)          # time between runs
                extra = rnd.uniform(5, 40) if rnd.random() < irq else 0.0
                t0, t1 = tm, tm + dur + extra
                bc0 = 2000 - int(t0 % 2001)
                bc1 = 2000 - int(t1 % 2001)
                m0 = ms + int(t0 // 2001)
                m1 = ms + int(t1 // 2001)
                struct.pack_into('<4H', c, 0x200 + 128 * 20 + (i * 16 + r) * 8, bc0, bc1, m0 & 0xFFFF, m1 & 0xFFFF)
                tm = t1
        struct.pack_into('<I', c, 0x10, ms + int(tm // 2001))
        data += c
    return bytes(data)


def self_test():
    fails = 0
    for mhz in (32.0, 16.0):
        data = simulate(mhz)
        res = analyse(parse(data))
        got = res.get('mhz')
        ok = got is not None and abs(got - mhz) < 0.01 * mhz
        print(f'simulated core at {mhz} MHz: decoder says {fmt(got)} MHz: {"ok" if ok else "WRONG"}')
        fails += not ok
        worst = []
        for tag, k, ref, grp, *_ in TESTS:
            if tag == 'NULL' or grp == 'single' or tag not in res['ns']:
                continue
            want = (TRUE[tag] if tag in TRUE else sim_cost(tag))
            have = res['ns'][tag] * mhz / 1000.0
            err = abs(have - want)
            worst.append((err / max(want, 1), tag, want, have))
            if err > max(0.06, 0.02 * want):
                print(f'  {tag}: want {want} cycles, got {have:.3f}')
                fails += 1
        worst.sort(reverse=True)
        print(f'  {len(worst)} per-operation estimates; the worst: '
              + ', '.join(f'{t.strip()} {h:.3f} for {w}' for _, t, w, h in worst[:3]))
    lines = []
    report(parse(simulate(noclock=True)), analyse(parse(simulate(noclock=True))), out=lines.append)
    ok = any('TM4 DID NOT MOVE' in ln for ln in lines) and any('NO TIMING' in ln for ln in lines)
    print(f'stopped TM4: {"reported" if ok else "NOT REPORTED"}')
    fails += not ok
    lines = []
    d = simulate(noleaf=True)
    report(parse(d), analyse(parse(d)), out=lines.append)
    ok = any('NOT FOUND' in ln for ln in lines) and analyse(parse(d))['ns'].get('FLLG') is None
    print(f'routine not found: {"reported, its tests left out" if ok else "WRONG"}')
    fails += not ok
    lines = []
    d = simulate()
    report(parse(d), analyse(parse(d)), out=lines.append)
    ok = any('board class 1' in ln and 'subtype 1' in ln for ln in lines)
    print(f'strap 0x0406 decoded as class 1, subtype 1: {"ok" if ok else "WRONG"}')
    fails += not ok
    print('SELF-TEST ' + ('PASSED' if not fails else f'FAILED ({fails})'))
    return 1 if fails else 0


def main():
    a = sys.argv[1:]
    if '--self-test' in a:
        sys.exit(self_test())
    if not a or a[0].startswith('--'):
        raise SystemExit(__doc__ if __doc__ else 'check_cpu_probe.py DIR|CPUTIME.BIN [--json OUT] [--self-test]')
    data = load(a[0])
    chunks = parse(data)
    res = analyse(chunks)
    bad = report(chunks, res)
    if '--json' in a and res:
        out = {'period': res['period'], 'count_ns': COUNT_NS, 'core_mhz': res.get('mhz'), 'null_ns': res.get('null_ns'),
               'tests': {t.strip(): {'what': NAMES[t][4], 'ns_per_op': res.get('ns', {}).get(t),
                                     'manual_cycles': NAMES[t][5], 'k': NAMES[t][1], 'ref': NAMES[t][2],
                                     'runs': {k: v for k, v in res['tests'][t].items() if k != 'routine'}}
                         for t in ORDER if t in res['tests']},
               'registers': {f'{x:#010x}': v for x, w, v in next(c for c in chunks if 'h' in c)['regs']}}
        json.dump(out, open(a[a.index('--json') + 1], 'w'), indent=1)
    print('')
    print('everything checks out' if not bad else f'{bad} problem(s)')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
