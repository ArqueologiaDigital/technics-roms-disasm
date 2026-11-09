#!/usr/bin/env python3
"""Do the model's functions assemble to the ROM's bytes?  Byte compare of to_llvm.py output against a ROM image.

usage: python3 -I -B check_bytes.py FILE.s ROM SYMBOLS_REFERENCE BASE [--llvm-bin DIR]
FILE.s is to_llvm.py's output.  It is assembled with llvm-mc (default ~/compartilhado/llvm-project/build/bin);
each global label's bytes run to the next label (the last to the end of .text) and are compared with the ROM at
the address SYMBOLS_REFERENCE gives the same name (symbols/*_symbols_reference.txt rows `NAME 00ADDRESS`), BASE
being the ROM's load address (0xe00000 for the main CPU).  Prints one row per function; exit 1 on any difference.
Scratch files go to $TMPDIR.
"""
import os, sys, subprocess, tempfile
a = sys.argv[1:]
src, rom, symf, base = a[0], a[1], a[2], int(a[3], 0)
bindir = a[a.index('--llvm-bin') + 1] if '--llvm-bin' in a else os.path.expanduser('~/compartilhado/llvm-project/build/bin')
with tempfile.TemporaryDirectory() as d:
    o, b = os.path.join(d, 'f.o'), os.path.join(d, 'f.bin')
    subprocess.run([os.path.join(bindir, 'llvm-mc'), '-triple=tlcs900', '-filetype=obj', src, '-o', o], check=True)
    subprocess.run([os.path.join(bindir, 'llvm-objcopy'), '-O', 'binary', '-j', '.text', o, b], check=True)
    nm = subprocess.run([os.path.join(bindir, 'llvm-nm'), '--defined-only', o], check=True, capture_output=True, text=True).stdout
    code = open(b, 'rb').read()
syms = {p[2]: int(p[0], 16) for p in (l.split() for l in nm.splitlines()) if len(p) == 3 and p[1] == 'T'}
ref = {p[0]: int(p[1], 16) for p in (l.split() for l in open(symf)) if len(p) == 2 and not p[0].startswith('#')}
img = open(rom, 'rb').read()
order = sorted(syms, key=syms.get); bad = 0
for i, n in enumerate(order):
    s = syms[n]; e = syms[order[i + 1]] if i + 1 < len(order) else len(code)
    mine = code[s:e]
    if n not in ref: print('%-32s no address in %s' % (n, symf)); bad += 1; continue
    r = img[ref[n] - base:ref[n] - base + len(mine)]
    ok = mine == r; bad += not ok
    print('%-32s %4d B  %s' % (n, len(mine), 'MATCH' if ok else 'DIFF  ours %s  rom %s' % (mine.hex(' '), r.hex(' '))))
print('%d of %d functions byte-identical' % (len(order) - bad, len(order)))
sys.exit(1 if bad else 0)
