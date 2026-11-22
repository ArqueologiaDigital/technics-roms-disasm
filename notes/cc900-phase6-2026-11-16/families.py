#!/usr/bin/env python3
"""families.py POOL.txt [MIN_MEMBERS] -- which unbuilt routines are look-alikes of each other (one C idiom for many)?

QUESTION ANSWERED / WHY: helper M's sound-editor table handlers matched by the dozen once one C idiom was found.
For each routine of a new_pool.py pool (`bytes address routine module hand_source`), this disassembles its bytes in
the built v10 ELF (llvm-objdump) and takes its SHAPE: the mnemonic sequence with operands reduced to their kind
(register name kept, numbers -> N, symbols / addresses -> A).  Routines with the same shape form a family; families
are printed largest first (members x bytes), with the members' names and hand sources.  Nothing says a family is
compiled C; screen it.

usage: python3 -B notes/cc900-phase6-2026-11-16/families.py POOL.txt [MIN_MEMBERS]     (from the repository root; needs make)
"""
import collections
import os
import re
import subprocess
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts', 'build'))
import cc900_firmware_c as fw                                # noqa: E402

LINE = re.compile(r'^\s*([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s*\t(\S+)\s*(.*)$')


def norm(ops):
    ops = re.sub(r'0x[0-9a-f]+|\b\d+\b', 'N', ops)
    return re.sub(r'\s+', '', ops)


def main():
    pool, mn = sys.argv[1], int(sys.argv[2]) if len(sys.argv) > 2 else 4
    rows = []
    for l in open(pool):
        p = l.split()
        if len(p) >= 5:
            rows.append((int(p[0]), int(p[1], 16), p[2], p[4]))
    elf = os.path.join(REPO, 'rebuilt_ROMs', 'kn5000_v10_program.llvm.elf')
    out = subprocess.run([os.path.join(fw.LLVM_BIN, 'llvm-objdump'), '-d', elf], capture_output=True,
                         text=True, check=True).stdout
    ins = {}
    for l in out.splitlines():
        m = LINE.match(l)
        if m:
            ins[int(m.group(1), 16)] = (len(m.group(2).split()), m.group(3), norm(m.group(4)))
    fam = collections.defaultdict(list)
    for n, a, name, src in rows:
        shape, at, end = [], a, a + n
        while at < end and at in ins:
            k, mnem, ops = ins[at]
            shape.append(mnem + ' ' + ops)
            at += k
        if at == end and shape:
            fam[tuple(shape)].append((name, n, src))
    big = sorted((f for f in fam.values() if len(f) >= mn), key=lambda f: -len(f) * f[0][1])
    for f in big:
        srcs = collections.Counter(s for _, _, s in f)
        print('%3d members x %4d B  %s  e.g. %s' % (len(f), f[0][1], ', '.join('%s:%d' % kv for kv in srcs.most_common(3)),
                                                  ' '.join(x[0] for x in f[:4])))


if __name__ == '__main__':
    main()
