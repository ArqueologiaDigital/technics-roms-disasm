#!/usr/bin/env python3
"""Probe: which register did thc2 give each temporary?  For every function, S4 (s4.py, fed V4.23's own -zim and -g)
is regenerated with forced choices for its temporaries (s4.FORCED), searching greedily for the choices that make its
code match thc2's longest; the decisions before the final first difference are taken as thc2's.

QUESTION ANSWERED: how often does S4's default choice for a temporary differ from thc2's, and in which contexts (size,
defining operation, hint, busy registers); a dataset for the temporaries' allocation rule.  Counts only (no Toshiba
output is written; the dataset rows hold our own decision records).

    python3 -B scripts/analysis/cc900/stages/s4_temps.py [--labels Xr] [--tsv OUT.tsv] RUN_DIR [RUN_DIR ...]
"""
import collections
import glob
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import listing2  # noqa: E402
import s3_check  # noqa: E402
import s4  # noqa: E402

FAMS = ['XWA', 'XBC', 'XDE', 'XHL', 'XIX', 'XIY', 'XIZ']
TRIES = 80


def prefix(a, b):
    n = 0
    for x, y in zip(a, b):
        if x != y:
            break
        n += 1
    return n


def run(args, code, forced):
    s4.FORCED.clear()
    s4.FORCED.update(forced)
    lab, tab = s4.LABEL_NEXT[0], s4.TABLE_NEXT[0]
    try:
        out = s4.Fn(*args).gen()
    except Exception:
        out = None
    log = list(s4.LOG)
    s4.LABEL_NEXT[0], s4.TABLE_NEXT[0] = lab, tab
    return out, log


def search(args, code):
    """(forced choices, final match, decision log of the final generation)"""
    forced = {}
    out, log = run(args, code, forced)
    if out is None:
        return None
    p = prefix(out, code)
    tries = 0
    fixed = set()
    while out != code and tries < TRIES:
        cands = [d for d in log if d[3] <= p and d[0] not in fixed]
        if not cands:
            break
        d = cands[-1]
        best = None
        for f in FAMS:
            if f == d[2] or (d[1] == 1 and f in ('XIZ',)):
                continue
            tries += 1
            o2, l2 = run(args, code, dict(forced, **{d[0]: f}))
            if o2 is None:
                continue
            p2 = prefix(o2, code)
            if p2 > p and (best is None or p2 > best[0]):
                best = (p2, f, o2, l2)
        fixed.add(d[0])
        if best:
            p, f, out, log = best
            forced[d[0]] = f
    return forced, out == code, log, p


def one_file(z):
    rows, c = [], collections.Counter()
    fs, tr = listing2.functions(z), s3_check.truth(z)
    frames = list(s3_check.FRAMES)
    s4.load_types(z)
    inter = z[:-len('_zimg.asm')] + '.inter'
    if os.path.exists(inter):
        s4.load_switches(inter)
    if len(fs) != len(tr):
        return rows, c
    for k, ((dmp, code), (fn, regs)) in enumerate(zip(fs, tr)):
        _, offs, frame = frames[k]
        args = (['FUNC_START'] + [d for d in dmp if 'FUNC_' not in d] + ['FUNC_END'], regs, offs, frame, fn)
        lab, tab = s4.LABEL_NEXT[0], s4.TABLE_NEXT[0]
        r = search(args, code)
        # advance the unit's label counters as the real generation does
        s4.LABEL_NEXT[0], s4.TABLE_NEXT[0] = lab, tab
        run(args, code, {})
        s4.FORCED.clear()
        if r is None:
            c['refused'] += 1
            continue
        forced, exact, log, p = r
        import re
        recs = [x.split('|', 1)[1] if '|' in x else x for x in args[0][1:-1]]
        c['functions'] += 1
        c['exact after search'] += exact
        for (n, size, fam, at, busy, prefs, op) in log:
            if at > p:
                continue                             # past the final first difference: not known
            c['decisions'] += 1
            changed = n in forced
            c['changed'] += changed
            uses = [i for i, l in enumerate(recs) if re.search(r'\b%s\(' % n, l)]
            base = any(re.search(r'(@\(|\*)%s\(' % n, recs[i]) for i in uses)
            ty = next((m.group(1) for l in recs for m in [re.search(r'\b%s(\([^()]*\))' % n, l)] if m), '')
            ops = '+'.join(sorted({recs[i].split()[1] if len(recs[i].split()) > 1 else '' for i in uses}))[:40]
            calls = sum(' CALL ' in l or 'ACALL' in l or 'CCALL' in l for l in recs[uses[0]:uses[-1]]) if uses else 0
            rows.append((os.path.basename(z), fn, n, size, op, ','.join(prefs), ','.join(str(b) for b in busy),
                         fam if not changed else '?', fam, 'changed' if changed else 'same', ty, int(base),
                         (uses[-1] - uses[0]) if uses else 0, calls, ops))
    return rows, c


def main():
    import multiprocessing
    a = sys.argv[1:]
    labels, tsv = None, None
    if '--labels' in a:
        i = a.index('--labels'); labels = set(a[i + 1].split(',')); a = a[:i] + a[i + 2:]
    if '--tsv' in a:
        i = a.index('--tsv'); tsv = a[i + 1]; a = a[:i] + a[i + 2:]
    files = [z for r in a for z in sorted(glob.glob(os.path.join(r, 'out', '*', '*', '**', '*_zimg.asm'), recursive=True))
             if not labels or os.path.relpath(z, os.path.join(r, 'out')).split(os.sep)[1] in labels]
    c, rows = collections.Counter(), []
    with multiprocessing.Pool(8) as pool:
        for r1, c1 in pool.imap_unordered(one_file, files, chunksize=2):
            rows += r1
            c.update(c1)
    print(' '.join('%s %d' % kv for kv in sorted(c.items())))
    # context of changed decisions: (size, op, hint present, default -> thc2)
    ctx = collections.Counter()
    for f, fn, n, size, op, prefs, busy, default, final, ch in (r[:10] for r in rows):
        if ch == 'changed':
            ctx[(size, op, 'hint' if prefs else '-')] += 1
    print('\nchanged decisions by (size, defining op, hint):')
    for k, v in ctx.most_common(15):
        print('  %5d %s' % (v, k))
    if tsv:
        with open(tsv, 'w') as o:
            o.write('file\tfunction\ttemp\tsize\top\thints\tbusy\tdefault\tchosen\tstatus\ttype\tbase\tspan\tcalls\tops\n')
            for r in rows:
                o.write('\t'.join(str(x) for x in r) + '\n')


if __name__ == '__main__':
    main()
