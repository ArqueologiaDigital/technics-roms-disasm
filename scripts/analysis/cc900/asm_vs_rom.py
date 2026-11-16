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
    for i, x in enumerate(a):
        if x == '--cfile':
            alias.update(fw.label_map(a[i + 1]))

    class CutNames(fw.Names):                            # a name cc900 cut to 31 characters resolves to the one tree
        def resolve(self, n):                            # name (value or label) it is the prefix of
            if n in alias:                               # a short C name (`cc900-name:`) of a callee or object
                n = alias[n]
            r = super().resolve(n)
            if r[0] is None and len(n) == 31:
                full = [k for k in list(self.values) + list(self.labels) if len(k) > 31 and k[:31] == n]
                if len(set(full)) == 1:
                    return super().resolve(full[0])
            return r
    names = CutNames(fw.tree_values(tree), ref)
    import re
    text = open(a[0], encoding='latin-1').read()
    # Operand widths.  V4.23 writes every access to a named object alike ((_x), lda XR,_x); the width is the
    # object's attribute, declared at the end of the listing (probe m16, run 2026-11-16-29-p6-m16): `extern large`
    # 24-bit (plain C), `medium` 16-bit (__near), `small` 8-bit (__tiny); objects defined in the file take their
    # section's (f_area / n_area / t_area).  asm900 encodes exactly that width.  So each named operand gets its
    # attribute's width here, not one chosen from its address; --by-address restores the old narrowing (to_llvm's own).
    attr = {}
    for kind, lst in re.findall(r'^\s*extern\s+(large|medium|small)\s+(.+)$', text, re.M):
        for n in lst.split(','):
            attr[n.strip().lstrip('_.')] = kind
    sect = None
    for l in text.split('\n'):
        m = re.match(r'^\s*\w+\s+section\s+\w+\s+(large|medium|small)\b', l)
        if m:
            sect = m.group(1); continue
        m = re.match(r'^_(\w+):', l)
        if m and sect:
            attr.setdefault(m.group(1), sect)
    width = {'large': 24, 'medium': 16, 'small': 8}
    by_address = '--by-address' in a

    class Mark(dict):                                     # to_llvm writes every named operand as S_<name>, so the
        def get(self, k, d=None):                         # width can be set per name below
            return 'S_' + k
    to_llvm.SPELL = None if by_address else Mark()

    def unmark(line):
        def opnd(m):
            n, off, w = m.group(1), int(m.group(2) or 0), int(m.group(3))
            return '(0x%x:%d)' % (to_llvm.lookup(n, names) + off, width[attr[n]] if n in attr else w)
        line = re.sub(r'\(S_(\w+)(?:\+(\d+))?:(\d+)\)', opnd, line)
        return re.sub(r'\bS_(\w+)(?:\+(\d+))?', lambda m: '0x%x' % (to_llvm.lookup(m.group(1), names) + int(m.group(2) or 0)), line)
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
            body = [unmark(l) for l in to_llvm.translate_function(name, lines, names)
                    if l not in ('\t.globl %s' % bare, bare + ':')]
        except KeyError as e:
            print('%-32s cannot resolve %s' % (bare, e)); bad += 1; continue
        if any('untranslated' in l for l in body):
            print('%-32s to_llvm cannot translate a line' % bare); bad += 1; continue
        try:
            mine = check_bytes.assemble('\t.text\n\t.globl %s\n%s:\n%s\n' % (full, full, '\n'.join(body)))[full]
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
