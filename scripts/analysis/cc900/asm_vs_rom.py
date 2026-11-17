#!/usr/bin/env python3
"""Does V4.23's code for our firmware C give the ROM's bytes, once addresses get the firmware's widths?

QUESTION ANSWERED: does V4.23's listing (`.asm`) of our firmware C give the ROM's bytes?  The tool rewrites each
function with model/to_llvm.py (asm900's encodings; each symbol's operand width the one the listing declares,
`extern small|medium|large` = the C's __tiny / __near / plain, probe m16 -- until 2026-11-16 it was chosen from the
address, the "proxy route" of notes/cc900-compat-plan-2026-11-08/phase6-preview.md, which hid that the C lacked its
__near qualifiers), assembles it with llvm-mc and compares it with the ROM at the
function's own name.  Names resolve as in the build (scripts/build/cc900_firmware_c.py: the tree's `.equ` values,
`ram_<hex>` cells, the symbols reference's labels).  It prints one line per function, MATCH or the first differing
offset, and no Toshiba text; never paste its input into the repository.

usage: python3 -I -B asm_vs_rom.py FILE.asm [--tree v10/maincpu] [--rom ROM] [--symbols REF] [--base 0xe00000]
                                         [--cfile C ...]   (more C whose names to resolve, e.g. a staging dir's)
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
    alias = {}
    module = set()
    for i, x in enumerate(a):
        if x == '--cfile':
            alias.update(fw.label_map(a[i + 1]))
            module |= fw.module_names(a[i + 1])     # the C's `cc900-module:` callees: calr / jr / jrl, as the build
    to_llvm.MODULE = module or None

    class CutNames(fw.Names):                            # a name cc900 cut to 31 characters resolves to the one tree
        def resolve(self, n, depth=0):                   # name (value or label) it is the prefix of
            if n in alias:                               # a short C name (`cc900-name:`) of a callee or object
                n = alias[n]
            r = super().resolve(n, depth)
            b = n.lstrip('_.')                           # the listing's `.Name` / `_Name` spelling of a cut name
            if r[0] is None and len(b) == 31:
                full = [k for k in list(self.values) + list(self.labels) if len(k) > 31 and k[:31] == b]
                if len(set(full)) == 1:
                    return super().resolve(full[0], depth)
            return r
    fw.RUNTIME.update(fw.runtime_names(tree))           # V4.23's runtime names (C9H_divlu) -> the tree's labels
    names = CutNames(fw.tree_values(tree), ref)
    to_llvm.SPELL = None
    text = open(a[0], encoding='latin-1').read()
    to_llvm.WIDTHS = listing.attributes(text)                # operand widths as the listing declares them (probe m16)
    funcs = listing.split(text)
    short = {}
    for n in ref:
        short.setdefault(n[:31], []).append(n)
    # the tree's own firmware C names a function by its first 31 characters (all cc900 keeps), and by a shorter C
    # name mapped to the tree's label (`cc900-name:`): resolve both through the tree's cc900/*.c
    import glob, re
    cnames = {}
    extra = [a[i + 1] for i, x in enumerate(a) if x == '--cfile']      # C not yet in the tree (a staging dir)
    for c in glob.glob(os.path.join(tree, 'cc900', '*.c')) + extra:
        lm = fw.label_map(c)
        for n in re.findall(r'^[\w\s\*]+?\b(\w+)\s*\([^;{)]*\)\s*\{', open(c).read(), re.M):
            cnames[n[:31]] = lm.get(n, n)
    bad = 0
    for name, lines in funcs.items():
        bare = name.lstrip('_.')
        full = cnames.get(bare) if cnames.get(bare) in ref else bare if bare in ref else \
            '_' + bare if '_' + bare in ref else \
            (short.get(bare, [None])[0] if len(short.get(bare, [])) == 1 else None)
        # ('_' + bare: a label with a leading underscore, which the listing's name prefix hides, _Read_VGA_Register)
        if full is None:
            print('%-32s not in the symbols reference' % bare); bad += 1; continue
        try:
            body = [l for l in to_llvm.translate_function(name, lines, names)
                    if l not in ('\t.globl %s' % bare, bare + ':')]
        except KeyError as e:
            print('%-32s cannot resolve %s' % (bare, e)); bad += 1; continue
        if any('untranslated' in l for l in body):
            print('%-32s to_llvm cannot translate a line' % bare); bad += 1; continue
        # relative calls / jumps to other routines (cc900-module callees) name `__cc900_at_<hex>`: define each
        # relative to this function, so llvm-mc resolves the displacement as it is in the ROM
        fa = ref[full]
        targets = sorted({int(m.group(1), 16) for m in re.finditer(r'__cc900_at_([0-9a-f]+)', '\n'.join(body))})
        # (relative to an assembler-local label: an expression on the global symbol stays a relocation for a
        # conditional jr / jrl, which then comes out as an unresolved jrl -- helper G, run 87)
        sets = ''.join('\t.set __cc900_at_%x, .Lcc900_fn0 + %d\n' % (t, t - fa) for t in targets)
        try:
            mine = check_bytes.assemble('\t.text\n\t.globl %s\n%s:\n.Lcc900_fn0:\n%s\n%s' % (full, full, '\n'.join(body), sets))[full]
        except Exception:                                 # e.g. a register to_llvm spells as llvm-mc does not
            print('%-32s llvm-mc cannot assemble the translation' % full); bad += 1; continue
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
