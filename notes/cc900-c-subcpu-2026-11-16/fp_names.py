#!/usr/bin/env python3
"""Which library routines does V4.23 call in each function of a listing?

QUESTION ANSWERED: for the floating-point probes (sub_fp_19a/b/c.c: one operation per function), the names of the
routines each function calls, in order, so that each can be paired with the tree label the ROM calls for the same
operation (scripts/build/cc900_runtime_names.tsv).  Only names are printed: function<TAB>callee callee ...
No line of the Toshiba listing is printed.

    python3 -B notes/cc900-c-subcpu-2026-11-16/fp_names.py LISTING.asm ...      (repository root)
"""
import re, sys


def main():
    for path in sys.argv[1:]:
        fn, calls, order = None, {}, []
        for l in open(path, encoding='latin-1'):
            m = re.match(r'^([._A-Za-z]\w*):', l)
            if m:
                fn = m.group(1)
                if fn not in calls:
                    calls[fn] = []
                    order.append(fn)
                continue
            m = re.match(r'^\s+(?:call|calr|cal)\s+(?:\w+\s*,\s*)?([._A-Za-z][\w.]*)', l, re.I)
            if m and fn is not None:
                calls[fn].append(m.group(1))
        for fn in order:
            if calls[fn]:
                print('%s\t%s' % (fn, ' '.join(calls[fn])))


if __name__ == '__main__':
    main()
