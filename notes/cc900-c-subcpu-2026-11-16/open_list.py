#!/usr/bin/env python3
"""Which sub-CPU functions were attempted in C and still do not match, and what is each one's best attempt?

QUESTION ANSWERED: for every function that some probe compiled (verdicts/*-sub-*.tsv) but that has no MATCH in
staged_v423.tsv (every built or staged function has one), the best attempt: the largest first difference, its run
and its probe file@option set.  Prints an aligned Markdown table (function, bytes of our attempt, first difference,
run, attempt), largest first difference first.

    python3 -B notes/cc900-c-subcpu-2026-11-16/open_list.py      (repository root)
"""
import os, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import idiom_scan as I                                        # noqa: E402


def main():
    done = I.matched()
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
