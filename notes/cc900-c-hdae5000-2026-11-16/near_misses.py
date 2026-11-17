#!/usr/bin/env python3
"""Where does each v2.06i function without matching C stand: which probe came closest, in which V4.23 run?

QUESTION ANSWERED: staged_v423.tsv only records matches.  For the functions still missing there, this re-checks every
oracle run of the lane (runs/*-hd-r*, `hd_v423.py --check RUN --calr`) and keeps, per function, the attempt whose
first differing byte is furthest into the function: label, ROM-side size, best first-difference offset, the probe
(file[:C name]) and the run.  A function that now matches in an old run but is not in the ledger (the translator
learned something since) is listed as MATCH: it only needs staging and a staged run.

    python3 -B notes/cc900-c-hdae5000-2026-11-16/near_misses.py [--runs DIR] [--tsv OUT.tsv]
Run from the repository root.  Reads the private oracle repo's runs (default ~/compartilhado/cc900-oracle/runs);
prints names, sizes and offsets only, never listing text.
"""
import glob, os, re, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
LINE = re.compile(r'^(\S+)\s+(\d+) B\s+(MATCH|best DIFF at \+(\d+)) ?\(?([^)\s]*)')


def opt(a, n, d):
    return a[a.index(n) + 1] if n in a else d


def main():
    a = sys.argv[1:]
    runs = opt(a, '--runs', os.path.expanduser('~/compartilhado/cc900-oracle/runs'))
    done = set()
    for l in open(os.path.join(HERE, 'staged_v423.tsv')):
        f = l.rstrip('\n').split('\t')
        if len(f) == 8 and f[0] == 'hdae5000' and f[7] == 'MATCH':
            done.add(f[5])
    best = {}
    for run in sorted(glob.glob(os.path.join(runs, '*-hd-r*'))):
        r = subprocess.run([sys.executable, '-B', os.path.join(HERE, 'hd_v423.py'), '--check', run, '--calr'],
                           capture_output=True, text=True)
        for l in r.stdout.split('\n'):
            m = LINE.match(l)
            if not m or m.group(1) in done or not m.group(1).startswith('HDAE5000_'):
                continue
            size = int(m.group(2))
            if m.group(3) == 'MATCH':
                score, probe = 1 << 30, l.split('MATCH', 1)[1].split()[0]
            else:
                score, probe = int(m.group(4)), m.group(5)
            if score > best.get(m.group(1), (-1,))[0]:
                best[m.group(1)] = (score, size, probe, os.path.basename(run))
    rows = sorted(best.items(), key=lambda kv: -kv[1][1])
    out = ['function\tbytes\tbest\tprobe\trun']
    for name, (score, size, probe, run) in rows:
        out.append('%s\t%d\t%s\t%s\t%s' % (name, size, 'MATCH' if score == 1 << 30 else '+%d' % score, probe, run))
    if '--tsv' in a:
        open(opt(a, '--tsv', ''), 'w').write('\n'.join(out) + '\n')
    for l in out:
        f = l.split('\t')
        print('%-46s %6s  %-7s %-40s %s' % tuple(f))
    print('%d functions without a ledger MATCH have an attempt in some run' % len(rows))


if __name__ == '__main__':
    main()
