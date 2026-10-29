#!/usr/bin/env python3
"""maincpu_slices_probe.py -- are the v6/v5 bytes that were romslice .incbins, and the v6/v5 boot
banners, the same bytes v7 / v10 spell natively?

1. For each former romslice label, compares the v6 (and v5) reference ROM bytes at the label's address
   (symbols/maincpu_<v>_symbols_reference.txt) with v7's bytes at v7's address of the same label, over
   the length the slice had.  Equal bytes mean v7's source lines can be used verbatim, provided they hold
   no absolute ROM address (checked by eye: only RAM addresses and relative branches).
2. cmp of the eight Bitmap_1bit_* banners of v6 and v5 against v10's.
Needs the git-ignored references original_ROMs/kn5000_v{5,6}_program.rom (copied by `make gate`).

    python3 notes/kn5000-existing-includes-2026-10-29/probes/maincpu_slices_probe.py
"""
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
SLICES = [('LoadExtROM_JumpEntry_Data', 6), ('ResInfo_GetResourceListPtr_Str_TEST', 6),
          ('RhythmFillIn_PatternTable', 8), ('CmpStepTitle_Method3Nop', 1),
          ('BitMapOut_CopyExtTable_Check', 0xb5)]


def sym(v):
    out = {}
    for ln in (ROOT / 'symbols' / f'maincpu_{v}_symbols_reference.txt').read_text().splitlines():
        w = ln.split()
        if len(w) == 2 and not ln.startswith('#'):
            out.setdefault(w[0], int(w[1], 16))
    return out


rom = {v: (ROOT / 'original_ROMs' / f'kn5000_{v}_program.rom').read_bytes() for v in ('v5', 'v6', 'v7')}
S = {v: sym(v) for v in rom}
for name, n in SLICES:
    a7 = S['v7'][name] - 0xE00000
    for v in ('v6', 'v5'):
        if name not in S[v]:
            print(f'  {v} {name}: no such label'); continue
        a = S[v][name] - 0xE00000
        print(f'  {v} {name:<38} {n:4} B  v{v[1:]} 0x{a + 0xE00000:06X} vs v7 0x{a7 + 0xE00000:06X}: '
              f'{"EQUAL" if rom[v][a:a + n] == rom["v7"][a7:a7 + n] else "DIFFERENT"}')
for v in ('v6', 'v5'):
    for f in sorted((ROOT / v / 'maincpu' / 'images').glob('Bitmap_1bit_*.bin')):
        same = f.read_bytes() == (ROOT / 'v10' / 'maincpu' / 'images' / f.name).read_bytes()
        print(f'  {v} {f.name:<40} {"== v10" if same else "DIFFERS from v10"}')
