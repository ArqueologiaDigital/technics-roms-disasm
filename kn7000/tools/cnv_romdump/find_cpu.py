#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# find_cpu.py [--build DIR] -- the firmware facts behind pass 9 (romdump_cputime.s, the CPU timing probe), in every
# KN7000 program build we have:
#   * the bus set-up: every 16-bit write of an immediate to the bus controller (0x320000xx), with the value, in
#     program order. The set-up routine (941 0x484D710E) writes MEMCTR1-4 (0x32000022-28) one of two ways,
#     chosen by the board strap at 0x98070000 (the classifier, 941 0x484D7713); the probe reads what was written;
#   * the DSP data accessors' bus bracket (941 only): read 0x32000026, write 0x924, or 0x32000026 bits 8-12 = 0x0F
#     and 0x3200002E bit 1 cleared, around the port access, then put back;
#   * the cache control register CHCTR (0x20000070): every place that loads its address;
#   * the board strap's two routines, by signature: the classifier (bits 1, 2 -> 1, 2, 3) and the hardware subtype
#     (941 0x484D774E, `calls` entry; bits 11:10 -> 5, 1, 2, 3, or 0x9CC00021 bits 3:2 when the class is 3), and
#     the calls to the subtype routine. Its result is not kept in RAM: every caller calls it again;
#   * the routine pass 9's fetch tests call (941 0x48471E64), found by the bytes of the probe's own copy (CtTwinPre..
#     CtTwinEnd in --build DIR's romdump_cpu.bin and .map, default build/): exactly once in each build?
#   python3 -I find_cpu.py [--build DIR]
import os
import re
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import find_dsp  # noqa: E402
import find_fw  # noqa: E402

BASE = 0x48400000
BUSREG = {0x10: 'BUS 0x10', 0x20: 'MEMCTR0', 0x22: 'MEMCTR1', 0x24: 'MEMCTR2', 0x26: 'MEMCTR3', 0x28: 'MEMCTR4',
          0x2A: 'MEMCTR5', 0x2C: 'MEMCTR6', 0x2E: 'MEMCTR7', 0x40: 'DRAM 0x40', 0x42: 'DRAM 0x42'}
# 941 0x484D7713: the board class from the strap's bits 1 and 2
SIG_CLASS = find_fw.sig('fc ac 00 00 07 98 f8 ec 02 c9 06 80 03 ca 13 fc ac 00 00 07 98 f8 ec 04 c9 06 80 02 ca 04 '
                        '80 01 de 00 00')
# 941 0x484D774E: the hardware subtype (add -8, sp; call the classifier; ...; ret 0, 8)
SIG_SUBTYPE = find_fw.sig('f8 fe f8 cd ?? ?? 00 00 14 a0 03 c9 32 fc a8 21 00 c0 9c f8 c4 02 f8 e0 03 c8 10 a0 01 c8 10 '
                          'a0 02 c8 10 a0 03 c8 10 ca 12 80 04 ca 41 80 03 ca 3d 80 02 ca 39 80 01 ca 35 80 01 ca 31 '
                          'fc ac 00 00 07 98 fa ec 00 08 c9 14 fc ad 00 00 07 98 80 05 fa ed 00 04 c8 16 80 01 ca 12 '
                          'fc ad 00 00 07 98 80 02 fa ed 00 04 c8 04 80 03 14 df 00 08')


def bus_writes(img):
    """(address, register, value) for every `mov imm, d0` directly followed by `movhu d0, (0x320000xx)`"""
    out = []
    for m in re.finditer(rb'\xfc\x83(.)\x00\x00\x32', img, re.S):
        o, reg = m.start(), m.group(1)[0]
        if img[o - 3] == 0x2C:
            val = struct.unpack_from('<h', img, o - 2)[0] & 0xFFFF
        elif img[o - 2] == 0x80:
            val = img[o - 1]
        elif img[o - 4] == 0xFA and img[o - 3] == 0xE4:      # or imm16, d0 (a read-modify-write)
            val = f'|= {struct.unpack_from("<H", img, o - 2)[0]:#x}'
        elif img[o - 3] == 0xF8 and img[o - 2] == 0xE4:      # or imm8, d0
            val = f'|= {img[o - 1]:#x}'
        elif img[o - 4] == 0xFA and img[o - 3] == 0xE0:      # and imm16, d0
            val = f'&= {struct.unpack_from("<H", img, o - 2)[0]:#x}'
        elif img[o - 1] == 0x00:                              # clr d0
            val = 0
        else:
            val = '(from d0)'
        out.append((BASE + o, BUSREG.get(reg, f'0x320000{reg:02X}'), val))
    return out


def calls_to(img, target):
    """`call target` instructions (cd d16 or dd d32) anywhere in the image"""
    n = 0
    for m in re.finditer(rb'\xcd', img):
        o = m.start()
        if o + 5 <= len(img) and BASE + o + struct.unpack_from('<h', img, o + 1)[0] == target:
            n += 1
    for m in re.finditer(rb'\xdd', img):
        o = m.start()
        if o + 7 <= len(img) and (BASE + o + struct.unpack_from('<i', img, o + 1)[0]) & 0xFFFFFFFF == target:
            n += 1
    return n


def twin(build):
    """the probe's copy of the firmware routine: (bytes from CtTwinPre to CtTwinEnd, CtTwin's offset in them)"""
    m = open(os.path.join(build, 'romdump_cpu.map')).read()
    lab = {k: int(v, 16) for v, k in re.findall(r'0x([0-9A-Fa-f]+)\s+(CtTwinPre|CtTwin|CtTwinEnd)\b', m)}
    b = open(os.path.join(build, 'romdump_cpu.bin'), 'rb').read()
    a = 0x502BA000
    return b[lab['CtTwinPre'] - a:lab['CtTwinEnd'] - a], lab['CtTwin'] - lab['CtTwinPre']


def main():
    build = sys.argv[sys.argv.index('--build') + 1] if '--build' in sys.argv else \
        os.path.join(os.path.dirname(os.path.abspath(__file__)), 'build')
    tw = twin(build) if os.path.exists(os.path.join(build, 'romdump_cpu.map')) else None
    for k, img in find_dsp.images().items():
        print(f'== {k}')
        if not any(img[:0x200000]):
            print('   (lower half not dumped: the set-up code is not there)')
        rows = bus_writes(img)
        for a, r, v in rows:
            print(f'   {a:#010x}  {r:10} <- {v if isinstance(v, str) else hex(v)}')
        ch = [BASE + m.start() for m in re.finditer(rb'\xfc\xdc\x70\x00\x00\x20', img)]
        print(f'   CHCTR (0x20000070) loaded into a0 at: {", ".join(hex(x) for x in ch) or "nowhere"}')
        c = find_fw.find(img, SIG_CLASS)
        s = find_fw.find(img, SIG_SUBTYPE)
        print(f'   strap classifier: {", ".join(hex(BASE + x) for x in c) or "not found"}; subtype routine (calls entry): '
              f'{", ".join(hex(BASE + x) for x in s) or "not found"}' +
              (f', called {calls_to(img, BASE + s[0] + 3)} times (body {BASE + s[0] + 3:#x}); its result is not stored'
               if len(s) == 1 else ''))
        nstrap = len(re.findall(rb'\x00\x00\x07\x98', img))
        print(f'   0x98070000 appears as an operand {nstrap} times')
        if tw:
            pat, off = tw
            hits = [BASE + m.start() + off for m in re.finditer(re.escape(pat), img)]
            print(f'   pass 9 fetch routine (the probe copy\'s {len(pat)} bytes): '
                  + (', '.join(hex(h) for h in hits) or 'not found') + (' -- exactly once' if len(hits) == 1 else ''))


if __name__ == '__main__':
    main()
