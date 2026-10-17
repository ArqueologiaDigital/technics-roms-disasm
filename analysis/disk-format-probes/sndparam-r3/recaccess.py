#!/usr/bin/env python3
"""recaccess.py REC:OFF[,REC:OFF...] [tree] -- every instruction whose absolute operand (hex or decimal, any :8/:16/:24
suffix) lands on payload byte OFF of record REC (RAM base from SndParam_BlockRamPtrs), in the HEAD snapshot.
Also reports `lda/ld xRR, 0xBASE` base loads of the record (pointer reach, displacement not resolved).
Prints file:line, enclosing label, the line, and the next line (where a mask usually sits)."""
import glob, os, re, subprocess, sys
SNAP = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'snap') + '/'
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
NM = os.path.expanduser('~/compartilhado/llvm-project/build/bin/llvm-nm')
tree = sys.argv[2] if len(sys.argv) > 2 else 'v10'
rom = open(os.path.join(REPO, 'original_ROMs/kn5000_%s_program.rom' % tree), 'rb').read()
out = subprocess.run([NM, '--defined-only', os.path.join(REPO, 'rebuilt_ROMs/kn5000_%s_program.llvm.elf' % tree)],
                     capture_output=True, text=True, check=True).stdout
syms = {f[2]: int(f[0], 16) for f in (l.split() for l in out.splitlines()) if len(f) == 3}
base = syms['SndParam_BlockRamPtrs'] - 0xE00000
recbase = {}
for r in range(0x100):
    v = int.from_bytes(rom[base + 4*r: base + 4*r + 4], 'little')
    if v and v != 0xFFFFFFFF and v not in recbase.values():
        recbase[r] = v
want = {}
for spec in sys.argv[1].split(','):
    r, o = spec.split(':')
    a = recbase[int(r, 16)] + int(o, 0)
    want[a] = (int(r, 16), int(o, 0))
bases = {recbase[r]: r for r, o in want.values()}
OP = re.compile(r'\((0x[0-9a-fA-F]+|\d+)(?::(?:8|16|24))?\)')
IMM = re.compile(r',\s*(0x[0-9a-fA-F]+|\d+)\s*$')
for p in sorted(glob.glob(SNAP + tree + '/maincpu/**/*.s', recursive=True)):
    L = open(p, 'rb').read().decode('latin-1').split('\n')
    lab = '?'
    for i, l in enumerate(L):
        m = re.match(r'^([A-Za-z_][\w]*):', l)
        if m:
            lab = m.group(1)
        code = l.split(';')[0]
        hit = None
        for mm in OP.finditer(code):
            v = int(mm.group(1), 0)
            if v in want:
                hit = 'R%02X+%d' % want[v]
        if not hit:
            mm = re.match(r'\s+(lda|ld)\w*\s+x\w+\s*,\s*(0x[0-9a-fA-F]+|\d+)\s*$', code)
            if mm and int(mm.group(2), 0) in bases:
                hit = 'BASE R%02X' % bases[int(mm.group(2), 0)]
        if hit:
            nxt = L[i+1].split(';')[0].strip() if i + 1 < len(L) else ''
            print('%-10s %s:%d  [%s]  %s   || %s' % (hit, p.replace(SNAP, ''), i+1, lab, code.strip(), nxt))
