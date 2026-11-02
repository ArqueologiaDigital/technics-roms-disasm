#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""opaque_left.py -- which `census: opaque -- unknown-dump` pieces are left, by group, in generated sources?

QUESTION IT ANSWERS
  "In a tree's data sources -- the committed ones, or a generator run's output directory (data_stats.py's
   <scratch>/<profile>_on/) -- how do the opaque pieces cluster (../mn10300-rest-probes/opaque_groups.py's
   generic groups: ram-widget-var, table-tail, labelled-held ...), and which are the biggest left?"
   It is opaque_groups.py pointed at another directory: that probe's rules, unchanged.

  --classes prints the pieces by the census line's own "N bytes of <what> in <where>" instead: the classes
  the open-items register's O- rows count (binary / printable / 7-bit / address-like, program flash /
  initialised-RAM image).

RUN (from the repository root)
  python3 -I kn7000/notes/mn10300-data-probes/opaque_left.py --tree 941                       # committed
  python3 -I kn7000/notes/mn10300-data-probes/opaque_left.py --tree 941 --dir DIR/941_on --by-table
  python3 -I kn7000/notes/mn10300-data-probes/opaque_left.py --tree kn2400 --dir DIR/kn2400_on --list table-tail
  python3 -I kn7000/notes/mn10300-data-probes/opaque_left.py --classes kn2400/src/program/data
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "mn10300-rest-probes"))
import opaque_groups as OG  # noqa: E402

def classes(ddir):
    import collections
    import re
    c = collections.Counter()
    b = collections.Counter()
    for f in sorted(os.listdir(ddir)):
        if not re.fullmatch(r"data_\d+\.s", f):
            continue
        L = open(os.path.join(ddir, f), "rb").read().split(b"\n")
        for i, ln in enumerate(L):
            m = re.match(rb"# census: opaque -- unknown-dump: (\d+) bytes of (.*?) in (the program flash|the initialised-RAM image)", ln)
            if m:
                what = m.group(2).decode("latin-1")
                what = ("printable" if what.startswith("printable") else "address-like" if what.startswith("words")
                        else what)
                k = (what, "RAM image" if b"RAM" in m.group(3) else "program flash")
                c[k] += 1
                b[k] += int(m.group(1))
    rows = [[k[0], k[1], f"{c[k]:,}", f"{b[k]:,}"] for k in sorted(c)]
    rows.append(["total", "", f"{sum(c.values()):,}", f"{sum(b.values()):,}"])
    print(OG.table(rows, ["class", "where", "pieces", "bytes"]))


if __name__ == "__main__":
    argv = sys.argv[1:]
    if "--classes" in argv:
        classes(os.path.abspath(os.path.expanduser(argv[argv.index("--classes") + 1])))
        sys.exit(0)
    if "--dir" in argv:
        i = argv.index("--dir")
        d = os.path.abspath(os.path.expanduser(argv[i + 1]))
        del argv[i:i + 2]
        t = argv[argv.index("--tree") + 1]
        OG.TREES[t] = (OG.TREES[t][0], d)
    sys.argv = [sys.argv[0]] + argv
    sys.exit(OG.main())
