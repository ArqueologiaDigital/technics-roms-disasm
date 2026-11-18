#!/usr/bin/env python3
"""Which C files of an oracle run made V4.23 crash?

QUESTION ANSWERED: V4.23 bug candidate 12 (cc900-v423-bugs.md) shows as a Wine page fault in a file's compiler log
and a truncated listing, and it loses every function of the file.  For each <stem>.cc.log of RUN_DIR/out/v423/<set>/
sub/ matching PATTERN this prints the stem, CRASH or ok, and the listing's line count.  No Toshiba text is printed.

    python3 -B notes/cc900-c-subcpu-2026-11-16/crash_check.py RUN_DIR [PATTERN]      (repository root)
"""
import fnmatch, glob, os, sys


def main():
    run = sys.argv[1]
    pat = sys.argv[2] if len(sys.argv) > 2 else '*'
    n = 0
    for log in sorted(glob.glob(os.path.join(run, 'out', 'v423', '*', 'sub', '*.cc.log'))):
        stem = os.path.basename(log)[:-len('.cc.log')]
        if not fnmatch.fnmatch(stem, pat):
            continue
        crashed = 'page fault' in open(log, encoding='latin-1').read()
        asm = log[:-len('.cc.log')] + '.asm'
        lines = sum(1 for _ in open(asm, encoding='latin-1')) if os.path.exists(asm) else 0
        print('%-24s %-5s %-6s listing %d lines' % (stem, os.path.basename(os.path.dirname(os.path.dirname(log))),
                                                     'CRASH' if crashed else 'ok', lines))
        n += crashed
    print('%d file(s) crashed' % n)


if __name__ == '__main__':
    main()
