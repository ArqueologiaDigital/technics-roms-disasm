#!/usr/bin/env python3
"""Does anything in a KN5000 program ROM point at an address?  Prints every offset where the
3-byte little-endian form of each address appears (a .long / 24-bit operand would contain it).

    python3 notes/open4-kn5000-b/cpanel/probes/ref_scan.py original_ROMs/kn5000_v10_program.rom 0xFC4021 0xFC47F1
"""
import sys
rom = open(sys.argv[1], 'rb').read()
for a in sys.argv[2:]:
    a = int(a, 0)
    pat = a.to_bytes(3, 'little')
    hits = [0xE00000 + i for i in range(len(rom) - 2) if rom[i:i + 3] == pat]
    print(f'{a:#08x}: {len(hits)} hit(s) ' + ' '.join(f'{h:#08x}' for h in hits))
