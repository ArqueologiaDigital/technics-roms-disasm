#!/usr/bin/env python3
"""hdae5000_label_family_numbering.py -- are the HD-AE5000's routine-internal label families numbered in order?

QUESTION IT ANSWERS
  localize_hdae5000_address_locals.py names routine-internal labels <Owner>_<Suffix>[N] (Suffix one of Loop,
  Skip, Join, Done, Return, Next, Epilogue; N = none, 2, 3 ... in address order); older passes left
  .L<Owner>_<Suffix>N locals numbered from 1.  Later renames can leave a family with a gap (Loop, Loop2,
  Loop5) or out of address order (Join9, Join13, Join10).  This prints the number of families, and every
  family whose numbers, read in source order, are not 1..n (an unnumbered label counts as 1).
  Exit status 1 when any family is gapped or out of order.

RUN (repository root)
  python3 scripts/analysis/hdae5000_label_family_numbering.py
"""
import collections
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
FAMILY = re.compile(rb'^((?:\.L)?[A-Za-z_]\w*?_(?:Loop|Skip|Join|Done|Return|Next|Epilogue))(\d*):')


def main():
    fam = collections.defaultdict(list)
    for p in sorted(glob.glob(os.path.join(ROOT, "hdae5000", "*.s"))):
        for i, ln in enumerate(open(p, "rb").read().split(b"\n")):
            m = FAMILY.match(ln)
            if m:
                fam[m.group(1).decode()].append((os.path.basename(p), i, int(m.group(2) or 1)))
    bad = {b: [n for *_, n in sorted(v)] for b, v in fam.items()
           if [n for *_, n in sorted(v)] != list(range(1, len(v) + 1))}
    print("hdae5000: %d label families; %d gapped or out of address order" % (len(fam), len(bad)))
    for b, ns in sorted(bad.items()):
        print("  %-56s %s" % (b, ns))
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
