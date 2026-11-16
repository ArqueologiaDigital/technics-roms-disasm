#!/usr/bin/env python3
"""One firmware function: does our C, through the reference model, give the ROM's bytes?  If not, where not?

usage: python3 -I -B fn_diff.py FILE.c [FUNCTION] [--tree v10/maincpu] [--rom ROM] [--symbols REF] [--base 0xe00000]
                                [--context N]
From scripts/analysis/cc900/model.  FILE.c is compiled exactly as the build compiles firmware C
(scripts/build/cc900_firmware_c.py: the reference model at -O3 -XS -Xr, personality kn5000, then to_llvm.py), but
with every name written as its address, so FUNCTION assembles on its own (check_bytes.assemble).  Its bytes are
compared with the ROM at the address the symbols reference gives FUNCTION.

Prints the model's instructions with their bytes beside the ROM's bytes at the same offsets (`=` same, `!` differs),
then MAME's unidasm reading of the ROM from FUNCTION to the end of our code plus N bytes (default 16), and the
first differing offset.  Without FUNCTION, one row per function of FILE.c (MATCH, or the first differing offset).
Exit 0 when byte-identical (every function, without FUNCTION), 1 when not.

Defaults are the KN5000 v10 main CPU: --tree v10/maincpu, original_ROMs/kn5000_v10_program.rom,
symbols/maincpu_v10_symbols_reference.txt, base 0xe00000 (all relative to the repository root).  Names the C uses
resolve as in the build: the tree's `.equ` / `.set` values, `ram_<hex>` cells, and the symbols reference's labels
(for calls).  unidasm is ~/compartilhado/tools/unidasm (override: UNIDASM); without it that part is skipped.
"""
import os, re, subprocess, sys, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..'))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, 'scripts', 'build'))
import check_bytes                                           # noqa: E402
import cc900_firmware_c as fw                                # noqa: E402


def opt(a, name, default):
    return a[a.index(name) + 1] if name in a else default


def encodings(text):
    """llvm-mc -show-encoding -> [(instruction text, its length)] in order (a fixup's bytes are placeholders there,
    so the bytes themselves are taken from the assembled object)"""
    r = subprocess.run([os.path.join(check_bytes.LLVM_BIN, 'llvm-mc'), '-triple=tlcs900', '-show-encoding'],
                       input=text, capture_output=True, text=True, check=True)
    out = []
    for l in r.stdout.splitlines():
        m = re.match(r'^\s+(.*?)\s*; encoding: \[(.*)\]', l)
        if m:
            out.append((m.group(1).replace('\t', ' '), len([x for x in m.group(2).split(',') if x])))
    return out


def compare(fn, lines, rom, ref, base):
    """-> (our bytes, the ROM's bytes at FUNCTION's address, same length)"""
    mine = check_bytes.assemble('\t.text\n\t.globl %s\n%s:\n%s\n' % (fn, fn, '\n'.join(lines)))[fn]
    at = ref[fn] - base
    return mine, rom[at:at + len(mine)]


def summary(funcs, rom, ref, base):
    bad = 0
    for fn, lines in funcs.items():
        if fn not in ref:
            print('%-40s not in the symbols reference' % fn); bad += 1; continue
        mine, r = compare(fn, lines, rom, ref, base)
        if mine == r:
            print('%-40s %4d B  MATCH' % (fn, len(mine)))
        else:
            first = next(i for i in range(len(mine)) if i >= len(r) or mine[i] != r[i])
            print('%-40s %4d B  DIFF at +%d' % (fn, len(mine), first)); bad += 1
    for fn, why in fw.REFUSED.items():
        print('%-40s refused by the model: %s' % (fn, why)); bad += 1
    n = len(funcs) + len(fw.REFUSED)
    print('%d of %d functions byte-identical' % (n - bad, n))
    return 1 if bad else 0


def main():
    a = sys.argv[1:]
    if not a:
        sys.exit(__doc__)
    pos = [x for i, x in enumerate(a) if not x.startswith('--') and (i == 0 or not a[i - 1].startswith('--'))]
    src, fn = pos[0], pos[1] if len(pos) > 1 else None
    tree = os.path.join(REPO, opt(a, '--tree', 'v10/maincpu'))
    rom = open(os.path.join(REPO, opt(a, '--rom', 'original_ROMs/kn5000_v10_program.rom')), 'rb').read()
    ref = check_bytes.load_reference(os.path.join(REPO, opt(a, '--symbols', 'symbols/maincpu_v10_symbols_reference.txt')))
    base, ctx = int(opt(a, '--base', '0xe00000'), 0), int(opt(a, '--context', '16'))
    names = fw.Names(fw.tree_values(tree), ref)
    funcs = fw.compile_c(src, names, spell=False)
    if fn is None:
        return summary(funcs, rom, ref, base)
    if fn in fw.REFUSED:
        sys.exit('%s: the model refuses %s: %s' % (src, fn, fw.REFUSED[fn]))
    if fn not in funcs:
        sys.exit('%s: no function %s (it has: %s)' % (src, fn, ' '.join(funcs)))
    if fn not in ref:
        sys.exit('%s is not in the symbols reference' % fn)
    body = '\n'.join(funcs[fn])
    mine, rbytes = compare(fn, funcs[fn], rom, ref, base)
    at = ref[fn] - base
    print('%s at 0x%06x: model %d B' % (fn, ref[fn], len(mine)))
    off = 0
    for ins, n in encodings(body):
        enc, r = mine[off:off + n], rom[at + off:at + off + n]
        print('  +%-4d %s %-30s %-16s rom %s' % (off, '=' if r == enc else '!', ins, enc.hex(' '), r.hex(' ')))
        off += n
    unidasm = os.environ.get('UNIDASM', os.path.expanduser('~/compartilhado/tools/unidasm'))
    if os.path.exists(unidasm):
        with tempfile.TemporaryDirectory() as d:
            p = os.path.join(d, 'rom.bin')
            open(p, 'wb').write(rom[at:at + len(mine) + ctx])
            r = subprocess.run([unidasm, p, '-arch', 'tlcs900', '-basepc', hex(ref[fn])], capture_output=True, text=True)
        print('ROM (unidasm, %d B past the model\'s end):' % ctx)
        for l in r.stdout.splitlines():
            print('  ' + l)
    if mine == rbytes:
        print('MATCH: %d of %d bytes' % (len(mine), len(mine)))
        return 0
    first = next(i for i in range(len(mine)) if i >= len(rbytes) or mine[i] != rbytes[i])
    print('DIFF: first differing byte at +%d (0x%06x)' % (first, ref[fn] + first))
    return 1


if __name__ == '__main__':
    sys.exit(main())
