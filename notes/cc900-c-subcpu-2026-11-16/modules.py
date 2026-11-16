#!/usr/bin/env python3
"""Where are the payload's original C modules (source files)?  Inferred from calr against call.

QUESTION ANSWERED: V4.23 writes every call as `cal`; asm900 turns one into the 3-byte `calr` only when the
target is in the same module (relocatable section) and within reach.  So in the ROM:
  - a `calr` from routine X to routine Y means X and Y are in ONE module: no module boundary between them;
  - an absolute `call` from X to a Y within calr reach (|distance| < 0x8000) means they are in DIFFERENT
    modules: at least one boundary between them.
Modules are contiguous address ranges (one link order).  The script places the fewest boundaries that satisfy
every "different" pair without crossing a "same" pair (interval stabbing, greedy), and lists the "different" pairs
that no allowed boundary can satisfy (a contradiction: hand assembly, a wrong routine split, or a call written
in assembly).  Routines are survey.tsv's (call targets after a flow end); a call made from an inner label counts
for the routine that holds it.

    python3 -B notes/cc900-c-subcpu-2026-11-16/modules.py [--md OUT]      (from the repository root)
"""
import bisect, glob, os, re, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
NOTES = os.path.join(REPO, 'notes', 'cc900-c-subcpu-2026-11-16')


def main():
    a = sys.argv[1:]
    ref = {}
    for l in open(os.path.join(REPO, 'symbols', 'subcpu_symbols_reference.txt')):
        p = l.split()
        if len(p) == 2 and not l.startswith('#'):
            ref[p[0]] = int(p[1], 16)
    rows = [l.rstrip('\n').split('\t') for l in open(os.path.join(NOTES, 'survey.tsv'))][1:]
    rts = sorted((int(r[0], 16), r[3], r[4]) for r in rows)
    addrs = [r[0] for r in rts]

    def idx(x):
        return bisect.bisect_right(addrs, x) - 1
    same, diff = [], []
    files = sorted(glob.glob(os.path.join(REPO, 'v142', 'subcpu', 'core', '*.s'))) + \
        [os.path.join(REPO, 'v142', 'subcpu', f) for f in ('subcpu_data_tables.s', 'subcpu_fp_math.s')]
    for f in files:
        cur = None
        for line in open(f, encoding='latin-1'):
            m = re.match(r'^([A-Za-z_]\w*):', line)
            if m and m.group(1) in ref:
                cur = ref[m.group(1)]
            c = line.split(';')[0].split()
            if len(c) >= 2 and c[0].lower() in ('calr', 'call') and c[1] in ref and cur is not None:
                i, j = idx(cur), idx(ref[c[1]])
                if i < 0 or j < 0 or i == j:
                    continue
                lo, hi = min(i, j), max(i, j)
                if c[0].lower() == 'calr':
                    same.append((lo, hi))
                elif abs(ref[c[1]] - cur) < 0x8000:
                    diff.append((lo, hi, rts[i][1], c[1]))
    n = len(rts)
    # boundary k lies between routine k-1 and routine k (k = 1 .. n-1); forbidden when inside a calr span
    forbid = [False] * (n + 1)
    for lo, hi in same:
        for k in range(lo + 1, hi + 1):
            forbid[k] = True
    allowed = [k for k in range(1, n) if not forbid[k]]
    bounds, bad = [], []
    for lo, hi, x, y in sorted(diff, key=lambda d: d[1]):
        if any(lo < b <= hi for b in bounds):
            continue
        cand = [k for k in allowed if lo < k <= hi]
        if not cand:
            bad.append((x, y)); continue
        bounds.append(cand[-1])                   # the latest allowed point serves the most later intervals
    bounds = sorted(set(bounds))
    mods, start = [], 0
    for b in bounds + [n]:
        mods.append((start, b - 1)); start = b
    out = ['## Modules inferred from calr / call (%d calr pairs, %d near absolute calls)' % (len(same), len(diff)), '',
           '%d boundaries, so %d modules; %d near calls cannot be separated (listed below).' %
           (len(bounds), len(mods), len(bad)), '']
    w = []
    for s, e in mods:
        w.append(('%06x' % rts[s][0], '%06x' % (rts[e + 1][0] if e + 1 < n else ref['Payload_Bss_Start']), rts[s][1],
                  str(e - s + 1), rts[s][2]))
    head = ('from', 'to', 'first routine', 'routines', 'hand source')
    cw = [max(len(x[k]) for x in w + [head]) for k in range(5)]
    out.append('| ' + ' | '.join(h.ljust(c) for h, c in zip(head, cw)) + ' |')
    out.append('|' + '|'.join('-' * (c + 2) for c in cw) + '|')
    out += ['| ' + ' | '.join(v.ljust(c) for v, c in zip(x, cw)) + ' |' for x in w]
    out += ['', 'Near absolute calls inside one calr-joined span:', '']
    out += ['- `%s` -> `%s`' % b for b in bad]
    text = '\n'.join(out) + '\n'
    if '--md' in a:
        open(a[a.index('--md') + 1], 'w').write(text)
    else:
        print(text)


if __name__ == '__main__':
    main()
