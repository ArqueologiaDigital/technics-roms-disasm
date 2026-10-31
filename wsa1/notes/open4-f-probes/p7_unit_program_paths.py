#!/usr/bin/env python3
"""p7_unit_program_paths.py -- which DSP does each P7 unit program reach, and which code
uploads a directory record's +12 body (open items N-9918e40f and N-10ecf076, 2026-10-31).

Read from prom_c's bytes and from prom_c/p7/p7_module.s (the byte-identical source), nothing
from an emulator run.  Every assertion is an instruction operand or a ROM byte:

 1. PoolDir_Records (0xFDBFD9, stride 25) is named by exactly 15 instructions in the whole
    image (the 24-bit operand occurs 15 times in the ROM), and exactly ONE of them adds +12:
    P7Unit_ReloadOnProgramChange (was sub_FA3A3C) at 0xFA3AEA.  So that routine is the only reader of the op-3 body pointer.
 2. All 56 records' +12 stream is ONE op-3 record whose payload opens 01 00 6e: command 0x01
    (P7Byte_SendCmd) and the 16-bit address 0x006E, which the op-3 arm (0xF9AAFB) relocates
    by base b3 of the six-byte record P7Stream_Run selects.
 3. P7Unit_ReloadOnProgramChange calls P7Stream_Run(+12, unit + 1, P7Stream_Data_FD4B85) at 0xFA3B9C with no
    branch between its entry and that call, and P7Byte_SendCmd has no early return: so every
    call of it puts the body on the bus.
 4. P7Stream_Data_FD4B85 gives each unit its destination (b5) and op-3 base (b3):
        unit 0 -> destination 0, body at 0x006E
        unit 1 -> destination 0, body at 0x00E7
        unit 2 -> destination 1, body at 0x00A8
    and destination 2 (IC30 by the schematic nets quoted in kn7000_mame wsa1.cpp: DSP2CS =
    P2.7) is NO unit's destination: only P7Stream_Data_FD4B97 index 4 reaches it.
 5. Its three call sites (0xFA5773, 0xFA581C, 0xFA58CE, P7Units_ResolveProgramsAndReload)
    run it for units 1, 0, 2 when the unit block's resolved record (+0x18 of 0x856E + 26*u)
    differs from its shadow (+0x18 of 0x85BC + 26*u).
 6. The boot loader uploads an op-3 program at 0x0030 to destinations 0, 1 AND 2
    (P7Stream_FCD2C6 / FCD5E2 / FCDA77) with every DSPnRST2 line low (PB3/PB4/PB1 res at
    0xFA312A-0xFA3130), and releases them afterwards (set at 0xFA3196/0xFA31B0/0xFA31CA).
    P7Unit_ReloadOnProgramChange touches no PB bit.

    python3 notes/open4-f-probes/p7_unit_program_paths.py      (exits 1 on any failed check)
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
ROM = (ROOT / 'original_ROMs/wsa1_prom_c.ic28').read_bytes()
SRC = (ROOT / 'prom_c/p7/p7_module.s').read_bytes().decode('latin-1').split('\n')
BASE = 0xF80000
POOLDIR = 0xFDBFD9
FAIL = []


def check(ok, what):
    print(('ok    ' if ok else 'FAIL  ') + what)
    if not ok:
        FAIL.append(what)


def b(a, n=1):
    return ROM[a - BASE:a - BASE + n]


def u32(a):
    return int.from_bytes(b(a, 4), 'little')


def addr_of(line):
    m = re.search(r';\s*([0-9A-F]{6})\b', line)
    return int(m.group(1), 16) if m else None


def lines_in(a0, a1):
    return [ln for ln in SRC if (addr_of(ln) or -1) >= a0 and (addr_of(ln) or -1) <= a1
            and not ln.startswith(';')]


# 1. readers of PoolDir_Records and the offset each adds
hits = [m.start() + BASE for m in re.finditer(re.escape(POOLDIR.to_bytes(3, 'little')), ROM)]
check(len(hits) == 15, 'PoolDir_Records base occurs as a 24-bit operand 15 times: %d' % len(hits))
offsets = {}
for i, ln in enumerate(SRC):
    code = ln.split(';')[0]
    if 'PoolDir_Records' in code and ':' not in code:
        prev = SRC[i - 1].split(';')[0]
        m = re.search(r'(?:inc\s+(\d+)|add\s+x\w+,\s*(\d+))\s*$', prev.strip())
        off = int(m.group(1) or m.group(2)) if m else 0
        offsets[addr_of(ln)] = off
check(len(offsets) == 15, 'the source spells all 15 symbolically: %d' % len(offsets))
plus12 = [a for a, o in offsets.items() if o == 12]
check(plus12 == [0xFA3AEA], 'exactly one +12 reader, 0xFA3AEA: %s' % [hex(a) for a in plus12])

# 2. every record's +12 stream is one op-3 record opening 01 00 6e
bodies = []
for r in range(56):
    p = u32(POOLDIR + 25 * r + 12)
    h0, h1 = b(p, 2)
    ln = ((h0 & 15) << 8) | h1
    bodies.append((h0 >> 4, b(p + 2, 3), b(p + ln)[0] >> 4))
check(all(op == 3 and pay == b'\x01\x00\x6e' and nxt == 15 for op, pay, nxt in bodies),
      'all 56 +12 streams = one op-3 record (cmd 0x01, address 0x006E) then END')

# 3. no branch in sub_FA3A3C before the +12 P7Stream_Run, and SendCmd never returns early
head = lines_in(0xFA3A3C, 0xFA3B9C)
branches = [ln for ln in head if re.match(r'\s*(jr|jrl|jp|djnz|ret)\b', ln.split(';')[0])]
check(not branches, 'P7Unit_ReloadOnProgramChange 0xFA3A3C-0xFA3B9C has no jump or return: %d' % len(branches))
check(any('call\tP7Stream_Run' in ln and addr_of(ln) == 0xFA3B9C for ln in head),
      'P7Unit_ReloadOnProgramChange calls P7Stream_Run at 0xFA3B9C')
send = lines_in(0xF9A163, 0xF9A194)
check(not any(re.match(r'\s*(ret|jp)\b', ln.split(';')[0]) for ln in send),
      'P7Byte_SendCmd 0xF9A163-0xF9A194 dispatches on the destination without returning')

# 4. the per-unit relocation records
units = []
for u in range(3):
    rec = b(0xFD4B85 + 6 * u, 6)
    units.append((rec[5], 0x006E + rec[3]))
check(units == [(0, 0x6E), (0, 0xE7), (1, 0xA8)],
      'units 0/1/2 -> (destination, body address) %s' % [(d, hex(a)) for d, a in units])
fixed = [b(0xFD4B97 + 6 * i, 6)[5] for i in range(4)]
check(fixed == [0, 0, 1, 2], 'P7Stream_Data_FD4B97 indexes 1..4 -> destinations %s' % fixed)

# 5. the guard on each call site
for call, unit in ((0xFA5773, 1), (0xFA581C, 0), (0xFA58CE, 2)):
    window = [ln.split(';')[0].strip() for ln in lines_in(call - 0x40, call)]
    txt = ' | '.join(window)
    ok = ('lda\txbc, (0x85BC:24)' in txt and 'lda\txbc, (0x856E:24)' in txt and 'add\txix, 24' in txt
          and 'cp\ta, h' in txt and ('ld\t(xiz-1), %d' % unit) in ' | '.join(
              ln.split(';')[0].strip() for ln in lines_in(call - 0x60, call)))
    check(ok, 'call 0x%06X: unit %d, taken only when record byte +0x18 != its shadow' % (call, unit))

# 6. boot: op-3 to 0x0030 on all three destinations, RST2 lines low; sub_FA3A3C no PB
for s in (0xFCD2C6, 0xFCD5E2, 0xFCDA77):
    check(b(s)[0] >> 4 == 3 and b(s + 2, 3) == b'\x01\x00\x30', 'boot stream 0x%06X is op-3 cmd 0x01 @0x0030' % s)
boot = [ln.split(';')[0].strip() for ln in lines_in(0xFA3127, 0xFA31CA)]
check(boot[:4] == ['res_dd8\t2, PB', 'res_dd8\t3, PB', 'res_dd8\t4, PB', 'res_dd8\t1, PB'],
      'boot drops DSPRST and the three DSPnRST2 lines first')
check([x for x in boot if x.startswith('set_dd8')] == ['set_dd8\t2, PB', 'set_dd8\t3, PB',
                                                         'set_dd8\t4, PB', 'set_dd8\t1, PB'],
      'then raises DSPRST, and DSP0/1/2RST2 only after the three program uploads')
body = lines_in(0xFA3A3C, 0xFA3CA5)
check(not any(', PB' in ln.split(';')[0] for ln in body), 'P7Unit_ReloadOnProgramChange writes no PB bit')

print('FAILURES: %d' % len(FAIL))
sys.exit(1 if FAIL else 0)
