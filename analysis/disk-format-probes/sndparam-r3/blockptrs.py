#!/usr/bin/env python3
"""blockptrs.py [tree] -- print SndParam_BlockRamPtrs: record (bank_index) -> RAM payload address (0 = virtual)."""
import os, subprocess, sys
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
NM = os.path.expanduser('~/compartilhado/llvm-project/build/bin/llvm-nm')
tree = sys.argv[1] if len(sys.argv) > 1 else 'v10'
rom = open(os.path.join(REPO, 'original_ROMs/kn5000_%s_program.rom' % tree), 'rb').read()
out = subprocess.run([NM, '--defined-only', os.path.join(REPO, 'rebuilt_ROMs/kn5000_%s_program.llvm.elf' % tree)],
                     capture_output=True, text=True, check=True).stdout
syms = {f[2]: int(f[0], 16) for f in (l.split() for l in out.splitlines()) if len(f) == 3}
base = syms['SndParam_BlockRamPtrs'] - 0xE00000
for r in range(0x100):
    v = int.from_bytes(rom[base + 4*r: base + 4*r + 4], 'little')
    if v and v != 0xFFFFFFFF:
        print('rec 0x%02X -> 0x%06X' % (r, v))
