#!/usr/bin/env python3
"""Does Toshiba's own toolchain reproduce a firmware function from our C?  asm900's bytes against the ROM.

QUESTION ANSWERED: for each function of an oracle run's object file (`.rel`, written by V4.23's asm900 in the
oracle VM) whose name starts with PREFIX, are its bytes the ROM's bytes of ROM_FUNCTION?  This is the local checking
aid of phase 6 (notes/cc900-phase6-2026-11-16/README.md) for C the reference model cannot compile yet.  It prints one
line per function: MATCH, or the first differing offset, with no Toshiba-made text; never paste its input into the
repository.

usage: python3 -I -B rel_vs_rom.py FILE.rel ROM_FUNCTION PREFIX [--rom ROM] [--symbols REF] [--base 0xe00000]
From the repository root's scripts/analysis/cc900.  Defaults: the v10 main CPU (original_ROMs/kn5000_v10_program.rom,
symbols/maincpu_v10_symbols_reference.txt).  A function's extent in the object is from its public to the next one
(or the end of the section).  A relocated field (an extern or section-relative address) compares as a wildcard and
is counted; the PC-relative jumps inside a function are resolved by asm900 and compare exactly.
"""
import os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'notes', 'toshiba-runtime-xref-2026-11-08'))
sys.path.insert(0, os.path.join(HERE, 'model'))
import ieee695                                               # noqa: E402
import check_bytes                                           # noqa: E402


def opt(a, n, d):
    return a[a.index(n) + 1] if n in a else d


def main():
    a = sys.argv[1:]
    if len(a) < 3:
        sys.exit(__doc__)
    rel, romfn, prefix = a[:3]
    rom = open(os.path.join(REPO, opt(a, '--rom', 'original_ROMs/kn5000_v10_program.rom')), 'rb').read()
    ref = check_bytes.load_reference(os.path.join(REPO, opt(a, '--symbols', 'symbols/maincpu_v10_symbols_reference.txt')))
    base = int(opt(a, '--base', '0xe00000'), 0)
    m = ieee695.Module(open(rel, 'rb').read())
    at = ref[romfn] - base
    pubs = sorted(((v[0], v[1], m.publics[i]) for i, v in m.pubval.items() if isinstance(v, tuple) and len(v) == 2
                   and isinstance(v[1], int)), key=lambda t: (t[0], t[1]))
    bad = 0
    for k, (sec, off, name) in enumerate(pubs):
        if not name.lstrip('_.').startswith(prefix):
            continue
        code = m.code(sec)
        end = pubs[k + 1][1] if k + 1 < len(pubs) and pubs[k + 1][0] == sec else len(code)
        mine = code[off:end]
        r = rom[at:at + len(mine)]
        wild = sum(1 for x in mine if not (isinstance(x, int) and x >= 0))
        diff = [i for i, x in enumerate(mine) if isinstance(x, int) and x >= 0 and (i >= len(r) or x != r[i])]
        if diff:
            bad += 1
            print('%-32s %4d B  DIFF at +%d' % (name, len(mine), diff[0]))
        else:
            print('%-32s %4d B  MATCH%s' % (name, len(mine), ' (%d relocated bytes not compared)' % wild if wild else ''))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
