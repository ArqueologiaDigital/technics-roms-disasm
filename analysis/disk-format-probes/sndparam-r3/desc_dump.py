#!/usr/bin/env python3
"""desc_dump.py [tree] [key ...] -- dump the full 18-byte sound-parameter descriptors (all fields) for the given keys,
or for every registry entry when no key is given. Reads the ROM + ELF symbols like gen_sndparam_desc_names_r2.py."""
import os, subprocess, sys
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
NM = os.path.expanduser('~/compartilhado/llvm-project/build/bin/llvm-nm')
args = sys.argv[1:]
tree = 'v10'
if args and args[0].startswith('v'):
    tree = args.pop(0)
want = {int(a, 16) for a in args}
rom = open(os.path.join(REPO, 'original_ROMs/kn5000_%s_program.rom' % tree), 'rb').read()
out = subprocess.run([NM, '--defined-only', os.path.join(REPO, 'rebuilt_ROMs/kn5000_%s_program.llvm.elf' % tree)],
                     capture_output=True, text=True, check=True).stdout
syms = {}
byaddr = {}
for l in out.splitlines():
    f = l.split()
    if len(f) == 3:
        syms[f[2]] = int(f[0], 16)
        byaddr.setdefault(int(f[0], 16), []).append(f[2])
start = syms.get('SndParam_RegisterLoop_Data', syms.get('SndParam_Registry')) - 0xE00000
ptrs = [int.from_bytes(rom[start + 4*i:start + 4*i + 4], 'little') for i in range(972)]
print('# idx  addr     key      rec off mask lo  hi  shf xor aux rd rg l2 cdc wr  x11  name')
for i, p in enumerate(ptrs):
    b = rom[p - 0xE00000:p - 0xE00000 + 18]
    key = int.from_bytes(b[0:4], 'little')
    if want and key not in want:
        continue
    names = [n for n in byaddr.get(p, []) if not n.startswith('$')]
    print('%4d %06X 0x%05X  %02X  %2d  %02X  %3d %3d  %02X  %02X  %02X  %02X %02X %02X  %02X  %02X  %02X  %s' % (
        i, p, key, b[4], b[5], b[6], b[7], b[8], b[9], b[10], b[11], b[12], b[13], b[14], b[15], b[16], b[17], ','.join(names)))
