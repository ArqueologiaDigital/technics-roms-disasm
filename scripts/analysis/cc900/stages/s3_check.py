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
import re
import glob
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..', 'notes',
                                'cc900-feedback-plan-2026-11-22', 'i2'))
import s1_check  # noqa: E402
import s3  # noqa: E402
import i2_registers  # noqa: E402


def param_orders(path):
    """{function: [parameter names in order]} from the -g function type records (`symbol_t N,xc,"f",ret,n,"a",..`)"""
    out = {}
    for l in open(path, encoding='latin-1'):
        m = re.match(r'^\tsymbol_t\s+\d+,xc,"([^"]+)",(.*)$', l.rstrip('\r\n'))
        if m:
            out.setdefault(m.group(1), re.findall(r'"([^"]+)"', m.group(2)))
    return out


def truth(path):
    """[(function, {I<n>/P<n>: register or 'stack'})] of a -g listing, in order"""
    per = collections.OrderedDict()
    porder = param_orders(path)
    frames, locals_ = {}, {}
    cur = None
    for l in open(path, encoding='latin-1'):
        m = re.match(r'^\tsymbol_b\s+"([^"]*)",5,', l)
        if m:
            cur = m.group(1)
        m = re.match(r'^\tsymbol_n\s+"([^"]+)",', l)
        if m and cur:
            locals_.setdefault(cur, [])
            if m.group(1) not in locals_[cur]:
                locals_[cur].append(m.group(1))   # the function's locals in order: I0, I1, ...
    for l in open(path, encoding='latin-1'):
        m = re.match(r'^\tsymbol_a\s+"([^"]+)",0,\s*(\d+),0', l)
        if m:
            frames.setdefault(m.group(1), int(m.group(2)))   # (the function's frame size)
    for fn, var, kind, val, flag in i2_registers.records(path):
        per.setdefault(fn, {}).setdefault(var, {})[kind] = (val, flag)
    out = []
    del FRAMES[:]
    for fn, vs in per.items():
        m = {}
        params = porder.get(fn, [])
        offs = {}
        for var, d in vs.items():
            if 7 in d:
                v, fl = d[7]
                name = 'I%d' % (v - 1) if fl == 1 else ('P%d' % (v - 9) if v >= 9 else None)
            elif var in params:
                name = 'P%d' % params.index(var)     # a parameter on the stack: by its place in the type record
            elif var in locals_.get(fn, []):
                deltas = collections.Counter(locals_[fn].index(v2) - (d2[7][0] - 1) for v2, d2 in vs.items()
                                             if 7 in d2 and d2[7][1] == 1 and v2 in locals_[fn])
                delta = deltas.most_common(1)[0][0] if deltas else 0
                i_ = locals_[fn].index(var) - delta     # a local on the stack: its symbol_n place, calibrated on
                if i_ < 0:                               # the locals whose -g record gives the number
                    continue
                name = 'I%d' % i_
            else:
                continue
            if not name:
                continue
            if 2 in d:
                m[name] = i2_registers.NAMES[d[2][0]] if 0 <= d[2][0] < len(i2_registers.NAMES) else '?'
            elif 1 in d:
                m[name] = 'stack'
                offs[name] = d[1][0]
        frame = frames.get(fn, 0)
        out.append((fn, m))
        FRAMES.append((fn, offs, frame))
    return out


FRAMES = []                                          # (function, {name: stack offset}, frame size) of the last truth()


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
        seen = set(re.findall(r'\b([IP]\d+)\(', '\n'.join(zim)))
        for n, want in t.items():
            if n not in seen:
                continue                             # never in the code: no decision to compare
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
