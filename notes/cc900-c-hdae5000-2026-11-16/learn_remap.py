#!/usr/bin/env python3
"""Which v2.06i RAM / string addresses sit elsewhere in an older HD-AE5000 image, read from the near misses?

QUESTION ANSWERED (2026-11-19): `port_built.py --remap` moves a `ram_<hex>` cell by the label at its v2.06i address,
but many RAM cells have no label (a field inside a work area), so the ported C still writes v2.06i's address there.
The instruction-level comparison of a near miss (`selectlist/cmp.py --image IMG`, ROM first, then V4.23's code) shows
such a cell as a pair of otherwise equal lines that differ only in one address.  This reads every cmp file given,
collects the pairs (generated address -> ROM address) for addresses in the expansion's RAM (0x200000-0x23ffff) or
ROM (0x280000-0x2fffff), and writes them as a TSV that `port_built.py --remap --extra FILE` applies before the
label remap.  A generated address seen with two ROM addresses is left out (reported); a pair whose generated address
the v2.06i C does not spell as ram_<hex> does nothing.  The table holds addresses only, no listing text.

    python3 -B notes/cc900-c-hdae5000-2026-11-16/learn_remap.py OUT.tsv TREE CMP_FILE...
        TREE: the older tree the cmp files compared with (hdae5000_v2_01i, hdae5000_v1_15i, hdae5000_v1_10i);
        OUT.tsv gets one `tree  v2.06i-address  tree-address  functions` row per pair (rows of other trees in
        an existing OUT.tsv are kept)
Run from the repository root.
"""
import os, re, sys

ADDR = re.compile(r'0x([0-9a-fA-F]{6})\b')


def in_range(a):
    return 0x200000 <= a < 0x240000 or 0x280000 <= a < 0x300000


def pairs_of(path):
    """[(generated, rom)] from one cmp file's hunks: a run of '-' lines followed by as many '+' lines, line by line,
    where the two lines are the same but for 6-digit addresses"""
    out, minus, plus = [], [], []

    def flush():
        if minus and len(minus) == len(plus):
            for r, g in zip(minus, plus):
                ra, ga = ADDR.findall(r), ADDR.findall(g)
                if ADDR.sub('#', r) != ADDR.sub('#', g) or len(ra) != len(ga):
                    continue
                for x, y in zip(ga, ra):
                    gx, ry = int(x, 16), int(y, 16)
                    if gx != ry and in_range(gx) and in_range(ry):
                        out.append((gx, ry))
        minus.clear()
        plus.clear()
    for l in open(path, encoding='latin-1'):
        l = l.rstrip('\n')
        if l.startswith('---') or l.startswith('+++'):
            continue
        if l.startswith('-'):
            if plus:
                flush()
            minus.append(l[1:])
        elif l.startswith('+'):
            plus.append(l[1:])
        else:
            flush()
    flush()
    return out


def main():
    if len(sys.argv) < 4:
        sys.exit(__doc__)
    out, tree, files = sys.argv[1], sys.argv[2], sys.argv[3:]
    seen = {}
    for f in files:
        fn = os.path.basename(f).rsplit('.', 1)[0]
        for g, r in pairs_of(f):
            seen.setdefault(g, {}).setdefault(r, set()).add(fn)
    rows = []
    if os.path.exists(out):
        rows = [l.rstrip('\n').split('\t') for l in open(out) if l.strip() and not l.startswith('#')
                and l.split('\t')[0] != tree]
    kept = conflicts = 0
    for g in sorted(seen):
        if len(seen[g]) != 1:
            conflicts += 1
            print('conflict 0x%06x -> %s' % (g, ', '.join('0x%06x' % r for r in sorted(seen[g]))))
            continue
        r, fns = next(iter(seen[g].items()))
        rows.append([tree, '%06x' % g, '%06x' % r, ','.join(sorted(fns))])
        kept += 1
    with open(out, 'w') as f:
        f.write('# learn_remap.py: v2.06i address -> older tree address, from selectlist/cmp.py near misses\n')
        f.write('tree\tv206i\taddress\tfunctions\n')
        for row in rows:
            if row[0] != 'tree':
                f.write('\t'.join(row) + '\n')
    print('%s: %d pairs, %d conflicts' % (tree, kept, conflicts))


if __name__ == '__main__':
    main()
