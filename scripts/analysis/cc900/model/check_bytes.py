#!/usr/bin/env python3
"""Do the model's functions assemble to the ROM's bytes?  Byte compare of to_llvm.py output against a ROM image.

usage: python3 -I -B check_bytes.py FILE.s ROM SYMBOLS_REFERENCE BASE [--llvm-bin DIR]
FILE.s is to_llvm.py's output.  It is assembled with llvm-mc (default ~/compartilhado/llvm-project/build/bin);
each global label's bytes run to the next label (the last to the end of .text) and are compared with the ROM at
the address SYMBOLS_REFERENCE gives the same name (symbols/*_symbols_reference.txt rows `NAME 00ADDRESS`), BASE
being the ROM's load address (0xe00000 for the main CPU).  Prints one row per function; exit 1 on any difference.
Scratch files go to $TMPDIR.

As a module (fn_diff.py): assemble(text) -> {name: bytes} and load_reference(path) -> {name: address}.
"""
import os, sys, subprocess, tempfile

LLVM_BIN = os.path.expanduser('~/compartilhado/llvm-project/build/bin')


def assemble(text, bindir=LLVM_BIN):
    """llvm-mc on one source text -> {global label: its bytes}, each running to the next label (the last to the end
    of .text).  Raises CalledProcessError, with llvm-mc's message on stderr, when the text does not assemble."""
    with tempfile.TemporaryDirectory() as d:
        s, o, b = os.path.join(d, 'f.s'), os.path.join(d, 'f.o'), os.path.join(d, 'f.bin')
        open(s, 'w').write(text)
        subprocess.run([os.path.join(bindir, 'llvm-mc'), '-triple=tlcs900', '-filetype=obj', s, '-o', o], check=True)
        subprocess.run([os.path.join(bindir, 'llvm-objcopy'), '-O', 'binary', '-j', '.text', o, b], check=True)
        nm = subprocess.run([os.path.join(bindir, 'llvm-nm'), '--defined-only', o], check=True, capture_output=True,
                            text=True).stdout
        code = open(b, 'rb').read() if os.path.exists(b) else b''
    syms = {p[2]: int(p[0], 16) for p in (l.split() for l in nm.splitlines()) if len(p) == 3 and p[1] == 'T'}
    order = sorted(syms, key=syms.get)
    return {n: code[syms[n]:syms[order[i + 1]] if i + 1 < len(order) else len(code)] for i, n in enumerate(order)}


def load_reference(path):
    """symbols/*_symbols_reference.txt -> {NAME: address}"""
    return {p[0]: int(p[1], 16) for p in (l.split() for l in open(path)) if len(p) == 2 and not p[0].startswith('#')}


def main():
    a = sys.argv[1:]
    src, rom, symf, base = a[0], a[1], a[2], int(a[3], 0)
    bindir = a[a.index('--llvm-bin') + 1] if '--llvm-bin' in a else LLVM_BIN
    funcs = assemble(open(src).read(), bindir)
    ref = load_reference(symf)
    img = open(rom, 'rb').read()
    bad = 0
    for n, mine in funcs.items():
        if n not in ref: print('%-32s no address in %s' % (n, symf)); bad += 1; continue
        r = img[ref[n] - base:ref[n] - base + len(mine)]
        ok = mine == r; bad += not ok
        print('%-32s %4d B  %s' % (n, len(mine), 'MATCH' if ok else 'DIFF  ours %s  rom %s' % (mine.hex(' '), r.hex(' '))))
    print('%d of %d functions byte-identical' % (len(funcs) - bad, len(funcs)))
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
