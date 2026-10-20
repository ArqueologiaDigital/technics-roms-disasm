#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# find_tm4.py [--unidasm PATH] -- the fine clock of the DSP probe's pass 8 (romdump_dsprate.s), in every KN7000
# program build we have:
#   * where the firmware sets up the MN10300's timer 4, the source of its 1 kHz tick: every instruction with an
#     absolute operand TM4MD (0x34001080, 8 bits), TM4BR (0x34001090, 16 bits) or TM4BC (0x340010A0, the counter),
#     with the value moved into d0 just before it. Pass 8 relies on TM4BR = 0x7D0 and TM4MD = 0x81 (count enable,
#     2 MHz), and on nothing in the firmware writing TM4BC;
#   * that the DSP data read runs with interrupts off: the guarded data read (DspFind's, found as find_dsp.py finds
#     it) calls the data-port accessor with 0x9C4, which calls a library routine before the handshake wait and
#     another after the port read. The first clears PSW bit 11 (IE): "and 0xf7ff, psw". So the tick handler cannot
#     run inside an access; it runs as the access ends, before the probe's next stamp.
# The library (0x4C000000) is copied from the program flash at boot: 893 from 0x487B76B1, 941 from 0x487B8FD1
# (cnv_romdump README.md, SURVEY2).
#   python3 -I find_tm4.py
import os
import re
import subprocess
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import find_dsp  # noqa: E402

REGS = {0x34001080: 'TM4MD', 0x34001090: 'TM4BR', 0x340010A0: 'TM4BC'}
LIBSRC = {'893': 0x487B76B1, '941': 0x487B8FD1, '942': 0x487BA785, '935': None}


def listing(img, start, n, base=find_dsp.BASE):
    with tempfile.NamedTemporaryFile(suffix='.bin') as t:
        t.write(img); t.flush()
        out = subprocess.run([find_dsp.UNIDASM, t.name, '-arch', 'mn10300', '-basepc', hex(start), '-skip',
                              str(start - base), '-count', str(n)], capture_output=True, text=True).stdout
    return [(int(m.group(1), 16), m.group(2).strip()) for m in
            (re.match(r'([0-9a-f]+): (?:[0-9a-f]{2} )+\s+(.*)', ln) for ln in out.splitlines()) if m]


def tm4(img):
    """every instruction that names a TM4 register: (address, instruction, the mov into d0 before it)"""
    rows = []
    for reg, name in REGS.items():
        for m in re.finditer(re.escape(reg.to_bytes(4, 'little')), img):
            a = find_dsp.BASE + m.start()
            lines = listing(img, a - 0x20, 0x30)
            for k, (pc, txt) in enumerate(lines):
                if f'{reg:08x}' in txt and pc < a <= pc + 6:
                    prev = next((t for p, t in reversed(lines[:k]) if re.match(r'mov\s+\S+, d0$', t)), '')
                    rows.append((pc, name, txt, prev))
                    break
    return sorted(set(rows))


def lock_calls(img, f, build):
    """the library calls around the port read in the data-port accessor, and the first lines of each"""
    body = f['datard'] + 3
    acc = next((int(m.group(1), 16) for _, t in find_dsp.disasm(img, body) if (m := re.match(r'call\s+0x([0-9a-f]+)', t))),
               None)
    if acc is None:
        return []
    out = []
    lines = listing(img, acc, 0x90)
    for pc, t in lines:
        m = re.match(r'call\s+0x(4c[0-9a-f]{6})', t)
        if m:
            la = int(m.group(1), 16)
            first = []
            if LIBSRC.get(build):
                lib = img[LIBSRC[build] - find_dsp.BASE:LIBSRC[build] - find_dsp.BASE + 0x40000]
                first = [x for _, x in listing(lib, la, 0x30, base=0x4C000000)][:10]
            out.append((pc, la, first))
        if t.startswith('ret'):
            break
    return acc, out


if __name__ == '__main__':
    if '--unidasm' in sys.argv:
        find_dsp.UNIDASM = sys.argv[sys.argv.index('--unidasm') + 1]
    for build, img in find_dsp.images().items():
        if build.startswith('929'):
            continue
        print(f'== {build}')
        rows = tm4(img)
        for pc, name, txt, prev in rows:
            print(f'   {pc:#010x}  {name}: {txt}' + (f'   (after {prev})' if prev else ''))
        for name in REGS.values():
            if not any(r[1] == name for r in rows):
                print(f'   {name}: named nowhere in the program flash')
        f = find_dsp.find(img)
        if isinstance(f, dict) and f['ok']:
            r = lock_calls(img, f, build)
            if r:
                acc, calls = r
                print(f'   data read {f["datard"]:#010x} -> accessor {acc:#010x}; its library calls:')
                for pc, la, first in calls:
                    ie = any(re.match(r'and\s+0xf7ff, psw', x) for x in first)
                    print(f'     {pc:#010x} call {la:#010x}: ' + ('; '.join(first[:7]) or '(no library image here)') +
                          ('   <- clears IE: interrupts off' if ie else ''))
