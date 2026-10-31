# marker.py -- who writes the A5 A5 5A 5A fill at IC21 0x6000-0x7FFF?  Look for the constant and the address
# in programs 893 and 941 (the address as a 32-bit immediate, little-endian).
# Adapted 2026-10-31 from the private ic21-analysis/marker.py.
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _paths
for name in ('893', '941'):
    p = _paths.program(name)
    for label, pat in (('a5a55a5a', bytes.fromhex('a5a55a5a')), ('5a5aa5a5', bytes.fromhex('5a5aa5a5')),
                       ('a5a5 (u16 imm)', bytes.fromhex('a5a5')), ('0x96806000', (0x96806000).to_bytes(4, 'little')),
                       ('0x00006000+base?', (0x6000).to_bytes(4, 'little'))):
        hits, i = [], p.find(pat)
        while i >= 0 and len(hits) < 8: hits.append(hex(0x48400000 + i)); i = p.find(pat, i + 1)
        n = p.count(pat)
        print(f'{name} {label:16s} {n:5d} hits  {hits if n <= 8 else hits[:4]}')
