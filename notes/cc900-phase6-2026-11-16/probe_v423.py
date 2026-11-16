#!/usr/bin/env python3
"""Which probe functions does Toshiba V4.23 turn into the v10 ROM's bytes, in which form and option set?

QUESTION ANSWERED: an oracle run compiles probe files scripts/analysis/cc900/corpus/firmware/p6_<TAG>_<round><form>.c
(the same function names in each form a / b / c) at several option sets.  For each listing, asm_vs_rom.py compares
every function with the v10 ROM.  This prints one row per function: its size, the forms and sets that MATCH, else
the best first differing offset.

    python3 -B notes/cc900-phase6-2026-11-16/probe_v423.py RUN_DIR [PATTERN] [--tsv OUT]
        PATTERN: a glob on the probe file names (default p6_*); --tsv writes the rows (function, bytes, matches,
        best difference) for the helpers

No Toshiba text is printed: names, sizes and verdicts only.  Run from the repository root.
"""
import fnmatch, os, re, subprocess, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
CC = os.path.join(REPO, 'scripts', 'analysis', 'cc900')


def main():
    a = sys.argv[1:]
    if not a:
        sys.exit(__doc__)
    run = a[0]
    pat = a[1] if len(a) > 1 and not a[1].startswith('--') else 'p6_*'
    tsv = a[a.index('--tsv') + 1] if '--tsv' in a else None
    res = {}                                     # function -> {(file, set): (bytes, verdict)}
    base = os.path.join(run, 'out', 'v423')
    for label in sorted(os.listdir(base)):
        d = os.path.join(base, label, 'firmware')
        if not os.path.isdir(d):
            continue
        for f in sorted(os.listdir(d)):
            stem = f[:-4]
            if not f.endswith('.asm') or not fnmatch.fnmatch(stem, pat):
                if f.endswith('.cc.log') and fnmatch.fnmatch(f[:-7], pat) and not os.path.exists(os.path.join(d, f[:-7] + '.asm')):
                    print('%s %s: V4.23 refused the file (see its .cc.log)' % (label, f[:-7]))
                continue
            r = subprocess.run([sys.executable, '-I', '-B', os.path.join(CC, 'asm_vs_rom.py'), os.path.join(d, f)],
                               capture_output=True, text=True, cwd=CC)
            for l in r.stdout.splitlines():
                m = re.match(r'^(\S+)\s+(\d+) B\s+(MATCH|DIFF at \+(\d+))$', l)
                if m:
                    res.setdefault(m.group(1), {})[(stem, label)] = (int(m.group(2)), m.group(3))
                elif l.split():
                    res.setdefault(l.split()[0], {})[(stem, label)] = (0, l.split(None, 1)[1].strip())
    rows = []
    for fn in sorted(res):
        v = res[fn]
        ok = sorted('%s@%s' % k for k, x in v.items() if x[1] == 'MATCH')
        size = max(x[0] for x in v.values() if x[1] == 'MATCH') if ok else max(x[0] for x in v.values())
        diffs = [(int(x[1].split('+')[1]), '%s@%s' % k) for k, x in v.items() if x[1].startswith('DIFF')]
        best = '+%d %s' % max(diffs) if diffs else '-'
        other = sorted(set(x[1] for x in v.values() if not x[1].startswith(('MATCH', 'DIFF'))))
        rows.append((fn, size, ' '.join(ok) or '-', '' if ok else (best if diffs else '; '.join(other))))
    w = max([len(r[0]) for r in rows] + [8])
    for r in rows:
        print('%-*s %4d B  %-6s %s' % (w, r[0], r[1], 'MATCH' if r[2] != '-' else 'diff', r[2] if r[2] != '-' else r[3]))
    n = sum(1 for r in rows if r[2] != '-')
    print('%d of %d functions match; %d B' % (n, len(rows), sum(r[1] for r in rows if r[2] != '-')))
    if tsv:
        with open(tsv, 'w') as fh:
            fh.write('function\tbytes\tmatches\tbest_diff\n')
            for r in rows:
                fh.write('%s\t%d\t%s\t%s\n' % r)


if __name__ == '__main__':
    sys.exit(main())
