#!/usr/bin/env python3
"""Find Toshiba's C startup (Stc94ml.mac / Stc95ml.mac: __startup's f_area zero-fill and f_data copy loops) in our
images, by its instruction bytes with branch displacements wildcarded.

usage: python3 -I startup_idiom.py
ZERO = ld ix,bc; srl xbc,1; jr z; ld xhl,xde; ldw (xde+),0; dec 1,xbc; or xbc,xbc; jr z; ldirw; cp qbc,0; jr z;
       ld wa,qbc; ldirw          (the template: srl 1,xbc / ldw (xde+),0 / sub xbc,1 / ldirw / cp qbc,0 / ld wa,qbc)
COPY = or xbc,xbc; jr z; ldirb; cp qbc,0; jr z; ld wa,qbc; ldirb
Prints, per image, each hit's address, the label there, and the immediates loaded just before it
(ld xde / ld xhl / ld xbc, read back as start, source and size).
"""
import re, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import xref_runtime as X

ZERO = re.compile(rb'\xd9\x8c\xe9\xef\x01\x66.\xea\x8b\xf5\xe9\x02\x00\x00\xe9\x69\xe9\xe1\x66.\x93\x11\xd7\xe6\xd8\x66.\xd7\xe6\x88\x93\x11', re.S)
COPY = re.compile(rb'\xe9\xe1\x66.\x83\x11\xd7\xe6\xd8\x66.\xd7\xe6\x88\x83\x11', re.S)

def ld32(data, end, reg):
    """the last `ld xRR, imm32` (40+r imm32) in the 24 bytes before end"""
    op = {'xde': 0x42, 'xhl': 0x43, 'xbc': 0x41}[reg]
    for p in range(end - 5, max(0, end - 24), -1):
        if data[p] == op: return int.from_bytes(data[p + 1:p + 5], 'little')
    return None

for iname, img, elf in X.IMAGES:
    syms = X.symbols(elf); addrs = sorted(syms)
    for va, data in X.segments(elf):
        for kind, rx in (('zero-fill', ZERO), ('copy', COPY)):
            for m in rx.finditer(data):
                s = m.start()
                vals = ['%s=%s' % (r, '%06x' % v if v is not None else '?') for r in ('xde', 'xhl', 'xbc')
                        for v in [ld32(data, s, r)] if not (kind == 'zero-fill' and r == 'xhl')]
                print('%-12s %-9s %06x  %-45s %s' % (iname, kind, va + s, X.label(syms, addrs, va + s)[:45], ' '.join(vals)))
