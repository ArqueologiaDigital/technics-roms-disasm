#!/usr/bin/env python3
"""Feedback plan step I2: read thc2's storage records (-g) from job_i2.sh runs into one table.

QUESTION ANSWERED: for every local and parameter of every function compiled in the runs, where V4.23 put it: the
record kind and value thc2's -g output gives (kind 2 = a register, value = thc2's register number, decoded here;
kind 1 = a stack offset; other kinds kept raw), with the run, the option label and the C file.

    python3 -B notes/cc900-feedback-plan-2026-11-22/i2/i2_registers.py [--suffix _g] OUT.tsv RUN_DIR [RUN_DIR ...]

RUN_DIR: cc900-oracle runs/<run>/ of job_i2.sh with a `-g` option set (dataset.txt's `zimg`).  OUT.tsv reproduces
facts of Toshiba's output, so write it inside the private cc900-oracle (internals/); it prints counts only.
The record syntax is read as observed in run 2026-11-22-45 (README.md): a function opens with a block record naming
it, and each variable's storage is a record `"name",kind,value,flag`.
"""
import collections
import glob
import os
import re
import sys

NAMES = (['W', 'A', 'QW', 'QA', 'B', 'C', 'QB', 'QC', 'D', 'E', 'QD', 'QE', 'H', 'L', 'QH', 'QL',
          'IXH', 'IXL', 'QIXH', 'QIXL', 'IYH', 'IYL', 'QIYH', 'QIYL', 'IZH', 'IZL', 'QIZH', 'QIZL',
          'SPH', 'SPL', 'QSPH', 'QSPL',
          'WA', 'QWA', 'BC', 'QBC', 'DE', 'QDE', 'HL', 'QHL', 'IX', 'QIX', 'IY', 'QIY', 'IZ', 'QIZ', 'SP', 'QSP',
          'XWA', 'XBC', 'XDE', 'XHL', 'XIX', 'XIY', 'XIZ', 'XSP', 'F'])
BLOCK = re.compile(r'^\tsymbol_b\s+"([^"]*)",5,')
STORE = re.compile(r'^\tsymbol_a\s+"([^"]+)",(\d+),\s*(-?\d+),(-?\d+)\s*$')


def records(path):
    fn = None
    for line in open(path, encoding='latin-1'):
        m = BLOCK.match(line)
        if m:
            fn = m.group(1)
            continue
        m = STORE.match(line)
        if m and fn and m.group(1) != fn:
            yield fn, m.group(1), int(m.group(2)), int(m.group(3)), int(m.group(4))


def main():
    a = sys.argv[1:]
    suffix = '_zimg'
    if a and a[0] == '--suffix':
        suffix, a = a[1], a[2:]
    out, runs = a[0], a[1:]
    if not runs:
        sys.exit(__doc__)
    n = collections.Counter()
    regs = collections.Counter()
    with open(out, 'w') as f:
        f.write('run\tlabel\tsource\tfunction\tvariable\tkind\tvalue\tflag\tregister\n')
        for r in runs:
            for p in sorted(glob.glob(os.path.join(r, 'out', '*', '*', '**', '*%s.asm' % suffix), recursive=True)):
                rel = os.path.relpath(p, os.path.join(r, 'out')).split(os.sep)
                label, src = rel[1], '/'.join(rel[2:])[:-len(suffix + '.asm')]
                n['files'] += 1
                for fn, var, kind, val, flag in records(p):
                    reg = NAMES[val] if kind == 2 and 0 <= val < len(NAMES) else ''
                    n['records'] += 1
                    n['kind %d' % kind] += 1
                    if reg:
                        regs[reg] += 1
                    f.write('\t'.join(str(x) for x in (os.path.basename(r.rstrip('/')), label, src, fn, var, kind,
                                                      val, flag, reg)) + '\n')
    for k, v in sorted(n.items()):
        print('%-10s %d' % (k, v))
    print('registers:', ', '.join('%s %d' % kv for kv in regs.most_common()))


if __name__ == '__main__':
    main()
