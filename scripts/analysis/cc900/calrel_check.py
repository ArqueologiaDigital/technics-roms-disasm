#!/usr/bin/env python3
"""Does model/to_llvm.py's CAL / J rule give the bytes asm900 gave?  (cc900 phase 6, probe calrel)

QUESTION ANSWERED: V4.23 writes every call `cal` and every tail call `j`; asm900 picks the encoding.  Probe calrel
(corpus/firmware/p6_calrel*.c, oracle run 2026-11-16-42-p6-calrel, assembled with `-l`) shows its choice in ASM900's
list file.  This tool translates the whole V4.23 listing (`.asm`) the build's way -- WIDTHS from the listing's
attributes, MODULE = the functions the file defines -- assembles it as one llvm-mc unit and compares every function's
bytes with the object bytes of ASM900's list file (`.lst`).  Relocated fields are zero in both (an unlinked object).
It prints one line per function, MATCH or the first differing offset, and no Toshiba text; never paste its input
into the repository.

usage: python3 -I -B scripts/analysis/cc900/calrel_check.py FILE.asm FILE.lst
  e.g. RUN=~/compartilhado/cc900-oracle/runs/2026-11-16-42-p6-calrel/out/v423/O3Xr/firmware
       python3 -I -B scripts/analysis/cc900/calrel_check.py $RUN/p6_calrel.asm $RUN/p6_calrel_lst.lst
Exit 0 when every function matches.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, 'model'))
import listing                                               # noqa: E402
import to_llvm                                               # noqa: E402
import check_bytes                                           # noqa: E402

LST = re.compile(r'^([0-9A-F]{8})  ([0-9A-F]+)\s')


class Any(dict):
    """every name resolves (to a large address); the spelling below keeps the name, so llvm-mc resolves it"""
    def __contains__(self, k):
        return True

    def __getitem__(self, k):
        return 0x400000

    def get(self, k, d=None):
        return k.lstrip('_.')


def assemble(text):
    """llvm-mc on one unit -> {label: bytes}, every label (local or global), each to the next one"""
    import subprocess
    import tempfile
    with tempfile.TemporaryDirectory() as d:
        s, o, b = (os.path.join(d, x) for x in ('f.s', 'f.o', 'f.bin'))
        open(s, 'w').write(text)
        subprocess.run([os.path.join(check_bytes.LLVM_BIN, 'llvm-mc'), '-triple=tlcs900', '-filetype=obj', s, '-o', o],
                       check=True)
        subprocess.run([os.path.join(check_bytes.LLVM_BIN, 'llvm-objcopy'), '-O', 'binary', '-j', '.text', o, b],
                       check=True)
        nm = subprocess.run([os.path.join(check_bytes.LLVM_BIN, 'llvm-nm'), '--defined-only', o], check=True,
                            capture_output=True, text=True).stdout
        code = open(b, 'rb').read()
    syms = {p[2]: int(p[0], 16) for p in (l.split() for l in nm.splitlines()) if len(p) == 3 and p[1] in 'tT'
            and not p[2].startswith('.L')}
    order = sorted(syms, key=syms.get)
    return {n: code[syms[n]:syms[order[i + 1]] if i + 1 < len(order) else len(code)] for i, n in enumerate(order)}


def lst_bytes(path):
    """ASM900 list file -> {address: byte}"""
    out = {}
    for line in open(path, encoding='latin-1'):
        m = LST.match(line)
        if m:
            a, h = int(m.group(1), 16), m.group(2)
            for i in range(0, len(h), 2):
                out[a + i // 2] = int(h[i:i + 2], 16)
    return out


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    text = open(sys.argv[1], encoding='latin-1').read()
    funcs = listing.split(text)
    to_llvm.SPELL = Any()
    to_llvm.WIDTHS = listing.attributes(text)
    to_llvm.MODULE = {n.lstrip('_.') for n in funcs}
    src = ['\t.text']
    for name, lines in funcs.items():
        lines = [l for l in lines if 'section' not in l]
        src += to_llvm.translate_function(name, lines[lines.index(name + ':'):], Any())
    bad = [l for l in src if 'untranslated' in l]
    if bad:
        sys.exit('to_llvm cannot translate %d line(s)' % len(bad))
    # no .globl: the trees' labels are local, and llvm-mc resolves (and widens) a branch to a local label itself,
    # where one to a global label is left to the linker (always jrl / a relocated calr)
    mine = assemble('\n'.join(l for l in src if not l.startswith('\t.globl')) + '\n')
    ref = lst_bytes(sys.argv[2])
    # each function's address in the list file, in the order of the listing
    starts = {}
    for line in open(sys.argv[2], encoding='latin-1'):
        m = re.match(r'^([0-9A-F]{8})\s+\+0\s+\d+\s+\d+\s+([._]\w+):\s*$', line)
        if m:
            starts[m.group(2).lstrip('_.')] = int(m.group(1), 16)
    fails = 0
    for name in funcs:
        b = name.lstrip('_.')
        got = mine.get(b, b'')
        at = starts.get(b)
        want = bytes(ref.get(at + i, 0x100) & 0xff if (at + i) in ref else 0x100 for i in range(len(got))) \
            if at is not None and all((at + i) in ref for i in range(len(got))) else None
        if want == got:
            print('%-16s %4d B  MATCH' % (b, len(got)))
        else:
            fails += 1
            first = next((i for i in range(len(got)) if want is None or got[i] != want[i]), len(got))
            print('%-16s %4d B  DIFF at +%d' % (b, len(got), first))
    return 1 if fails else 0


if __name__ == '__main__':
    sys.exit(main())
