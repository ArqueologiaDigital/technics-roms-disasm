#!/usr/bin/env python3
"""Check stage S2 against V4.23: for every function of job_i2.sh runs with both dumps, s2.py applied to thc2's -zio
dump against thc2's -zim dump (its dump lines only).

QUESTION ANSWERED: for how many functions does our S2, started from V4.23's own S1, equal V4.23's S2 (exactly, and up
to temporary numbering); for the others, the first differing line's kind (counts only).

    python3 -B scripts/analysis/cc900/stages/s2_check.py [--labels Xr,...] RUN_DIR [RUN_DIR ...]
"""
import collections
import glob
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import s1_check  # noqa: E402
import s2  # noqa: E402


def main():
    a = sys.argv[1:]
    labels = None
    if '--labels' in a:
        i = a.index('--labels'); labels = set(a[i + 1].split(',')); a = a[:i] + a[i + 2:]
    count, first = collections.Counter(), collections.Counter()
    for r in a:
        for z in sorted(glob.glob(os.path.join(r, 'out', '*', '*', '**', '*_zio.asm'), recursive=True)):
            label = os.path.relpath(z, os.path.join(r, 'out')).split(os.sep)[1]
            if labels and label not in labels:
                continue
            m = z[:-len('_zio.asm')] + '_zimg.asm'
            if not os.path.exists(m):
                continue
            inter = z[:-len('_zio.asm')] + '.inter'
            orders = []
            if os.path.exists(inter):
                import thc1ir                      # every symbol declaration in file order; a snapshot per function
                seen = []
                for l in thc1ir.parse(open(inter, 'rb').read().decode('latin-1')):
                    if l.kind == 'decl' and l.fields[0].startswith('@'):
                        seen.append(l.fields[0])
                    elif l.kind == 'op' and l.op == 'END' and (not orders or orders[-1][0] != l.fields[1]):
                        orders.append((l.fields[1], list(seen)))
                orders = [o for _, o in orders]
            for n_, (zio, zim) in enumerate(zip(s1_check.zio_functions(z), s1_check.zio_functions(m))):
                try:
                    ours = s2.s2_lines(zio, orders[n_] if n_ < len(orders) else None)
                except Exception as ex:
                    count[(label, 'error')] += 1
                    first[('error', type(ex).__name__)] += 1
                    continue
                count[(label, 'functions')] += 1
                if ours == zim:
                    count[(label, 'exact')] += 1
                if s1_check.renamed(ours) == s1_check.renamed(zim):
                    count[(label, 'renamed')] += 1
                    continue
                k = next(i for i in range(max(len(ours), len(zim)))
                         if i >= len(ours) or i >= len(zim) or ours[i] != zim[i])
                first[(s1_check.kind(zim[k] if k < len(zim) else None), s1_check.kind(ours[k] if k < len(ours) else None))] += 1
    print('| option set | functions | exact | equal up to temporary numbering | errors |')
    print('|------------|-----------|-------|---------------------------------|--------|')
    for lab in sorted({k[0] for k in count}):
        print('| %-10s | %9d | %5d | %31d | %6d |' % (lab, count[(lab, 'functions')], count[(lab, 'exact')],
                                                   count[(lab, 'renamed')], count[(lab, 'error')]))
    print('\nfirst difference (thc2 line kind, our line kind): count')
    for k, v in first.most_common(20):
        print('  %-40s %d' % ('%s / %s' % k, v))


if __name__ == '__main__':
    main()
