#!/usr/bin/env python3
"""Check stage S3 against V4.23: s3.py's register for every parameter and local of every firmware function, from
thc2's own -zim dump, against thc2's -g storage record (job_i2.sh runs with the `zimg` option set).

QUESTION ANSWERED: for how many named variables (and functions, all variables right) does our allocation equal
V4.23's; the most frequent (truth, ours) pairs as a worklist.  Counts only.

    python3 -B scripts/analysis/cc900/stages/s3_check.py [--labels Xr,...] RUN_DIR [RUN_DIR ...]
-g records pair with -zim functions in order; the C name maps to I<n> / P<n> by the record of kind 7
(flag 1: a local, I = value - 1; flag 0 and value >= 9: a parameter, P = value - 9).
"""
import collections
import glob
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..', 'notes',
                                'cc900-feedback-plan-2026-11-22', 'i2'))
import s1_check  # noqa: E402
import s3  # noqa: E402
import i2_registers  # noqa: E402


def truth(path):
    """[(function, {I<n>/P<n>: register or 'stack'})] of a -g listing, in order"""
    per = collections.OrderedDict()
    for fn, var, kind, val, flag in i2_registers.records(path):
        per.setdefault(fn, {}).setdefault(var, {})[kind] = (val, flag)
    out = []
    for fn, vs in per.items():
        m = {}
        for var, d in vs.items():
            if 7 not in d:
                continue
            v, fl = d[7]
            name = 'I%d' % (v - 1) if fl == 1 else ('P%d' % (v - 9) if v >= 9 else None)
            if not name:
                continue
            if 2 in d:
                m[name] = i2_registers.NAMES[d[2][0]] if 0 <= d[2][0] < len(i2_registers.NAMES) else '?'
            elif 1 in d:
                m[name] = 'stack'
        out.append((fn, m))
    return out


def one_file(z):
    """(counts, pairs) for one -zimg listing"""
    c, pairs = collections.Counter(), collections.Counter()
    zims, tr = s1_check.zio_functions(z), truth(z)
    if len(zims) != len(tr):
        c['unpaired files'] += 1
        return c, pairs
    for zim, (fn, t) in zip(zims, tr):
        ours = s3.allocate(zim)
        ok = True
        for n, want in t.items():
            got = ours.get(n, '?')
            c['variables'] += 1
            if got == want:
                c['right'] += 1
            else:
                ok = False
                pairs[(n[0], want, got)] += 1
        c['functions'] += 1
        c['functions all right'] += ok
    return c, pairs


def main():
    import multiprocessing
    a = sys.argv[1:]
    labels = None
    if '--labels' in a:
        i = a.index('--labels'); labels = set(a[i + 1].split(',')); a = a[:i] + a[i + 2:]
    files = []
    for r in a:
        for z in sorted(glob.glob(os.path.join(r, 'out', '*', '*', '**', '*_zimg.asm'), recursive=True)):
            label = os.path.relpath(z, os.path.join(r, 'out')).split(os.sep)[1]
            if not labels or label in labels:
                files.append(z)
    c, pairs = collections.Counter(), collections.Counter()
    with multiprocessing.Pool(8) as pool:
        for c1, p1 in pool.imap_unordered(one_file, files, chunksize=4):
            c.update(c1)
            pairs.update(p1)
    print(' '.join('%s %d' % kv for kv in sorted(c.items())))
    print('\nmost frequent (kind, V4.23, ours):')
    for k, v in pairs.most_common(20):
        print('  %5d %s' % (v, k))


if __name__ == '__main__':
    main()
