#!/usr/bin/env python3
"""Does V4.23's code for our firmware C give the ROM's bytes, once addresses get the firmware's widths?

QUESTION ANSWERED: rel_vs_rom.py compares asm900's object, in which every extern is `large` and so takes a 24-bit
operand; the firmware addresses its variables below 0x10000 with 16-bit operands, so a correct function still
differs there.  This tool takes the oracle's listing (`.asm`) instead, rewrites each function with
model/to_llvm.py (asm900's encodings, the operand width chosen from the address: the "proxy route" of
notes/cc900-compat-plan-2026-11-08/phase6-preview.md), assembles it with llvm-mc and compares it with the ROM at the
function's own name.  Names resolve as in the build (scripts/build/cc900_firmware_c.py: the tree's `.equ` values,
`ram_<hex>` cells, the symbols reference's labels).  It prints one line per function, MATCH or the first differing
offset, and no Toshiba text; never paste its input into the repository.

usage: python3 -I -B asm_vs_rom.py FILE.asm [--tree v10/maincpu] [--rom ROM] [--symbols REF] [--base 0xe00000]
From scripts/analysis/cc900.  Defaults: the v10 main CPU.  A name V4.23 cut to 31 characters is looked up by the
first 31 characters of the symbols reference's names.
"""
import os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..', '..'))
sys.path.insert(0, os.path.join(HERE, 'model'))
sys.path.insert(0, os.path.join(REPO, 'scripts', 'build'))
import listing                                               # noqa: E402
import to_llvm                                               # noqa: E402
import check_bytes                                           # noqa: E402
import cc900_firmware_c as fw                                # noqa: E402


def opt(a, n, d):
    return a[a.index(n) + 1] if n in a else d


def main():
    a = sys.argv[1:]
    if not a:
        sys.exit(__doc__)
    tree = os.path.join(REPO, opt(a, '--tree', 'v10/maincpu'))
    rom = open(os.path.join(REPO, opt(a, '--rom', 'original_ROMs/kn5000_v10_program.rom')), 'rb').read()
    ref = check_bytes.load_reference(os.path.join(REPO, opt(a, '--symbols', 'symbols/maincpu_v10_symbols_reference.txt')))
    base = int(opt(a, '--base', '0xe00000'), 0)
    names = fw.Names(fw.tree_values(tree), ref)
    to_llvm.SPELL = None
    funcs = listing.split(open(a[0], encoding='latin-1').read())
    short = {}
    for n in ref:
        short.setdefault(n[:31], []).append(n)
    bad = 0
    for name, lines in funcs.items():
        bare = name.lstrip('_.')
        full = bare if bare in ref else (short.get(bare, [None])[0] if len(short.get(bare, [])) == 1 else None)
        if full is None:
            print('%-32s not in the symbols reference' % bare); bad += 1; continue
        try:
            body = [l for l in to_llvm.translate_function(name, lines, names) if l not in ('\t.globl %s' % bare, bare + ':')]
        except KeyError as e:
            print('%-32s cannot resolve %s' % (bare, e)); bad += 1; continue
        if any('untranslated' in l for l in body):
            print('%-32s to_llvm cannot translate a line' % bare); bad += 1; continue
        mine = check_bytes.assemble('\t.text\n\t.globl %s\n%s:\n%s\n' % (full, full, '\n'.join(body)))[full]
        at = ref[full] - base
        r = rom[at:at + len(mine)]
        if mine == r:
            print('%-32s %4d B  MATCH' % (full, len(mine)))
        else:
            first = next(i for i in range(len(mine)) if i >= len(r) or mine[i] != r[i])
            print('%-32s %4d B  DIFF at +%d' % (full, len(mine), first)); bad += 1
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
