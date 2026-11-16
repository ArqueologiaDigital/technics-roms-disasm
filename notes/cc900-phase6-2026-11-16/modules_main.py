#!/usr/bin/env python3
"""Where are the main CPU's original C modules (source files)?  Inferred from calr against call (v10 by default).

QUESTION ANSWERED: the method of lane_sub's notes/cc900-c-subcpu-2026-11-16/modules.py (branch cc900/c-subcpu-hdae),
applied to a main-CPU tree.  V4.23 writes every call as `cal`; asm900 turns one into the 3-byte `calr` only when the
target is in the same module (relocatable section) and within reach.  So in the ROM:
  - a `calr` from routine X to routine Y means X and Y are in ONE module: no module boundary between them;
  - an absolute `call` from X to a Y within calr reach (|distance| < 0x8000) means they are in DIFFERENT modules.
Modules are contiguous address ranges; the fewest boundaries that satisfy every "different" pair without crossing a
"same" pair are placed greedily, and the near calls no allowed boundary can satisfy are listed (hand assembly, a
wrong routine split, or a call written in assembly).  Routines are the labels some call / calr targets; a call made
from an inner label counts for the routine that holds it.  Hand assembly calls `calr` too, so a module here is an
upper bound of a C module: what matters for firmware C is that functions joined by calr must share one C file.

    python3 -B notes/cc900-phase6-2026-11-16/modules_main.py [--tree v10] [--tsv OUT] [--md OUT]
        --tsv: one row per routine: address, name, module number, hand source; --md: the module table.
"""
import bisect, os, re, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))


def main():
    a = sys.argv[1:]
    t = a[a.index('--tree') + 1] if '--tree' in a else 'v10'
    tree = os.path.join(REPO, t, 'maincpu')
    ref = {}
    for l in open(os.path.join(REPO, 'symbols', 'maincpu_%s_symbols_reference.txt' % t)):
        p = l.split()
        if len(p) == 2 and not l.startswith('#'):
            ref[p[0]] = int(p[1], 16)
    calls, where = [], {}
    for dp, dn, fn in os.walk(tree):
        dn[:] = [d for d in dn if d != 'generated']
        for f in fn:
            if not f.endswith('.s'):
                continue
            p = os.path.join(dp, f)
            cur = None
            for line in open(p, encoding='latin-1'):
                m = re.match(r'^([A-Za-z_]\w*):', line)
                if m and m.group(1) in ref:
                    cur = ref[m.group(1)]
                    where.setdefault(m.group(1), os.path.relpath(p, tree))
                c = line.split(';')[0].replace(',', ' ').split()
                if len(c) >= 2 and c[0].lower() in ('calr', 'call') and c[-1] in ref and cur is not None:
                    calls.append((c[0].lower(), cur, c[-1]))
    targets = {y for _, _, y in calls}
    rts = sorted((ref[n], n, where.get(n, '?')) for n in targets)
    addrs = [r[0] for r in rts]

    def idx(x):
        return bisect.bisect_right(addrs, x) - 1
    same, diff = [], []
    for kind, cur, y in calls:
        i, j = idx(cur), idx(ref[y])
        if i < 0 or j < 0 or i == j:
            continue
        lo, hi = min(i, j), max(i, j)
        if kind == 'calr':
            same.append((lo, hi))
        elif abs(ref[y] - cur) < 0x8000:
            diff.append((lo, hi, rts[i][1], y))
    n = len(rts)
    forbid = [False] * (n + 1)
    for lo, hi in same:
        for k in range(lo + 1, hi + 1):
            forbid[k] = True
    allowed = [k for k in range(1, n) if not forbid[k]]
    import bisect as b_
    bounds, bad = [], []
    for lo, hi, x, y in sorted(diff, key=lambda d: d[1]):
        if any(lo < b <= hi for b in bounds[-50:]) or any(lo < b <= hi for b in bounds):
            continue
        k = b_.bisect_right(allowed, hi) - 1
        if k < 0 or allowed[k] <= lo:
            bad.append((x, y)); continue
        bounds.append(allowed[k])
    bounds = sorted(set(bounds))
    mods, start = [], 0
    for bd in bounds + [n]:
        mods.append((start, bd - 1)); start = bd
    if '--tsv' in a:
        with open(a[a.index('--tsv') + 1], 'w') as fh:
            fh.write('address\troutine\tmodule\thand_source\n')
            for m, (s, e) in enumerate(mods):
                for r in rts[s:e + 1]:
                    fh.write('%06x\t%s\t%d\t%s\n' % (r[0], r[1], m, r[2]))
    multi = [(s, e) for s, e in mods if e > s]
    out = ['## Modules of %s inferred from calr / call (%d calr pairs, %d near absolute calls)' % (t, len(same), len(diff)),
           '', '%d routines, %d boundaries, so %d modules (%d of more than one routine); %d near calls cannot be '
           'separated.' % (n, len(bounds), len(mods), len(multi), len(bad)), '']
    w = [('%06x' % rts[s][0], '%06x' % rts[e][0], rts[s][1], str(e - s + 1), rts[s][2]) for s, e in multi]
    head = ('from', 'last routine at', 'first routine', 'routines', 'hand source')
    cw = [max(len(x[k]) for x in w + [head]) for k in range(5)]
    out.append('| ' + ' | '.join(h.ljust(c) for h, c in zip(head, cw)) + ' |')
    out.append('|' + '|'.join('-' * (c + 2) for c in cw) + '|')
    out += ['| ' + ' | '.join(v.ljust(c) for v, c in zip(x, cw)) + ' |' for x in w]
    text = '\n'.join(out) + '\n'
    if '--md' in a:
        open(a[a.index('--md') + 1], 'w').write(text)
    print('\n'.join(out[:3]))


if __name__ == '__main__':
    main()
