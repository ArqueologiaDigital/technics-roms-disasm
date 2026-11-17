#!/usr/bin/env python3
"""new_pool.py OUT_PREFIX TAG [TAG ...] [--min BYTES] [--max BYTES] [--exclude POOLFILE ...]

Which v10 routines has nobody tried yet?  A fresh, disjoint pool per helper when the old pools run dry.

For every routine of modules_v10.tsv (module numbers from modules_main.py), its size is the distance to the next
label of the v10 symbols reference that is a routine of that table.  A routine is left out when it is already
C (defined in v10/maincpu/cc900/*.c or cc900-staged/*.c) or when any probe of
scripts/analysis/cc900/corpus/firmware/p6_*.c defines it (tried before, by anyone).  The rest, largest first,
is dealt round-robin to the TAGs and written to OUT_PREFIX<TAG>.txt as
`bytes  address  routine  module  hand_source`.  Nothing here says a routine is compiled C; helpers screen
for hand-assembly features as before.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, HERE)
import stage_probe as sp                                     # noqa: E402


def defined_in(directory, prefix=''):
    out = set()
    if not os.path.isdir(directory):
        return out
    for f in os.listdir(directory):
        if f.endswith('.c') and f.startswith(prefix):
            text = open(os.path.join(directory, f), encoding='latin-1').read()
            alias = dict(re.findall(r'cc900-name:\s*(\w+)\s*=\s*(\w+)', text))
            for k, d in sp.items(text):
                if k == 'fn':
                    n = sp.fn_name(d)
                    out.add(alias.get(n, n))
    return out


def main():
    a = sys.argv[1:]
    lo = int(a[a.index('--min') + 1]) if '--min' in a else 40
    hi = int(a[a.index('--max') + 1]) if '--max' in a else 4000
    excl = set()
    for i, x in enumerate(a):                 # --exclude POOLFILE: routines another helper's pool still holds
        if x == '--exclude':
            excl |= set(re.findall(r'\b[A-Za-z_]\w{3,}\b', open(a[i + 1]).read()))
    pos = [x for i, x in enumerate(a)
           if not x.startswith('--') and (i == 0 or a[i - 1] not in ('--min', '--max', '--exclude'))]
    prefix, tags = pos[0], pos[1:]
    rows = []
    for line in open(os.path.join(HERE, 'modules_v10.tsv')):
        c = line.rstrip('\n').split('\t')
        if len(c) == 4 and c[0] != 'address':
            rows.append((int(c[0], 16), c[1], c[2], c[3]))
    rows.sort()
    done = defined_in(os.path.join(REPO, 'v10', 'maincpu', 'cc900'))
    done |= defined_in(os.path.join(REPO, 'v10', 'maincpu', 'cc900-staged'))
    done |= defined_in(os.path.join(REPO, 'scripts', 'analysis', 'cc900', 'corpus', 'firmware'), 'p6_')
    cand = []
    for i, (addr, name, mod, src) in enumerate(rows):
        if name in done or name in excl or i + 1 == len(rows):
            continue
        size = rows[i + 1][0] - addr
        if lo <= size <= hi:
            cand.append((size, addr, name, mod, src))
    cand.sort(reverse=True)
    pools = {t: [] for t in tags}
    for k, row in enumerate(cand):
        pools[tags[k % len(tags)]].append(row)
    for t, rs in pools.items():
        with open(prefix + t + '.txt', 'w') as fh:
            for size, addr, name, mod, src in rs:
                fh.write('%5d  %06x  %-44s %4s  %s\n' % (size, addr, name, mod, src))
        print('%s: %d routines, %d B' % (t, len(rs), sum(r[0] for r in rs)))


if __name__ == '__main__':
    main()
