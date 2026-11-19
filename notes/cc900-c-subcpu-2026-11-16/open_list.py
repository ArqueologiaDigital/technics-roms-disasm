#!/usr/bin/env python3
"""Which sub-CPU functions were attempted in C and still do not match, and what is each one's best attempt?

QUESTION ANSWERED: for every function that some probe compiled (verdicts/*-sub-*.tsv) but that has no MATCH in
staged_v423.tsv and no C in v142/subcpu/cc900/ or cc900-staged/, the best attempt: the largest first difference, its
run and its probe file@option set.  Prints an aligned Markdown table (function, first difference, run, attempt),
largest first difference first.  The cc900/ test was added on 2026-11-19: functions built before staged_v423.tsv
recorded every MATCH (Voice_Calc_LevelPair_EGA, DSP_WriteParameter, WaveSel_StageA2_FromVelZone) were listed as open.

    python3 -B notes/cc900-c-subcpu-2026-11-16/open_list.py      (repository root)
"""
import glob, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import idiom_scan as I                                        # noqa: E402

REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
FN_RE = re.compile(r'^[\w][\w\s\*]*?\b(\w+)\s*\([^;{)]*\)\s*\{', re.M)


def defined_in_c():
    """the labels v142's C defines (cc900/ and cc900-staged/), through cc900-name short names (c_duplicates.py's rule)"""
    out = set()
    for p in glob.glob(os.path.join(REPO, 'v142', 'subcpu', 'cc900', '*.c')) + \
            glob.glob(os.path.join(REPO, 'v142', 'subcpu', 'cc900-staged', '*.c')):
        t = open(p, encoding='latin-1').read()
        lm = dict(re.findall(r'cc900-name:\s*(\w+)\s*=\s*(\w+)', t))
        out |= {lm.get(n, n) for n in FN_RE.findall(t)}
    return out


def main():
    done = I.matched() | defined_in_c()
    rows = []
    for fn, (at, run, where) in I.best_attempts(done).items():
        rows.append((fn, '+%d' % at, run, where))
    rows.sort(key=lambda r: (-int(r[1][1:]), r[0]))
    head = ('function', 'first diff', 'run', 'best attempt')
    w = [max(len(str(r[i])) for r in rows + [head]) for i in range(4)]
    line = lambda r: '| ' + ' | '.join(str(r[i]).ljust(w[i]) for i in range(4)) + ' |'
    print(line(head))
    print('|' + '|'.join('-' * (x + 2) for x in w) + '|')
    for r in rows:
        print(line(r))
    print('\n%d functions' % len(rows))


if __name__ == '__main__':
    main()
