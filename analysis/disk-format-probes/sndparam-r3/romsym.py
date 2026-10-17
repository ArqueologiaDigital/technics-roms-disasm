#!/usr/bin/env python3
"""romsym.py SYMBOL LEN [str|u32|u16|hex] [tree] -- dump LEN bytes of the ROM at an ELF symbol (v10 default)."""
import os, subprocess, sys
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
NM = os.path.expanduser('~/compartilhado/llvm-project/build/bin/llvm-nm')
sym, n = sys.argv[1], int(sys.argv[2], 0)
mode = sys.argv[3] if len(sys.argv) > 3 else 'hex'
tree = sys.argv[4] if len(sys.argv) > 4 else 'v10'
rom = open(os.path.join(REPO, 'original_ROMs/kn5000_%s_program.rom' % tree), 'rb').read()
out = subprocess.run([NM, '--defined-only', os.path.join(REPO, 'rebuilt_ROMs/kn5000_%s_program.llvm.elf' % tree)],
                     capture_output=True, text=True, check=True).stdout
syms = {f[2]: int(f[0], 16) for f in (l.split() for l in out.splitlines()) if len(f) == 3}
a = int(sym, 16) if sym.startswith('0x') else syms[sym]
b = rom[a - 0xE00000: a - 0xE00000 + n]
print('# %s = 0x%06X' % (sym, a))
if mode == 'str':
    print(repr(b.decode('latin-1')))
elif mode == 'u32':
    print(' '.join('%08X' % int.from_bytes(b[i:i+4], 'little') for i in range(0, n - 3, 4)))
elif mode == 'u16':
    print(' '.join('%04X' % int.from_bytes(b[i:i+2], 'little') for i in range(0, n - 1, 2)))
else:
    print(' '.join('%02x' % x for x in b))
