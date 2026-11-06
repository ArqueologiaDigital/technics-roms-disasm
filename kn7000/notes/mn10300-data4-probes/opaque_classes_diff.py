#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""opaque_classes_diff.py -- the census-opaque pieces / bytes of each MN10300 data region by class, before and after.

QUESTION ANSWERED: "per tree and per class of the `census: opaque -- unknown-dump: N bytes of <what> in <where>`
lines (the classes the register's O- rows count: binary / printable / 7-bit / address-like, program flash /
initialised-RAM image / RAM image), how many pieces and bytes does a BEFORE copy of the data directories hold,
and how many does this checkout?"  BEFORE is a `git archive <base>` of the data directories, extracted to a
directory (the lane used e53dc9b3a).  Prints a Markdown table, one row per tree and class that is not 0 in both.

RUN (from the repository root):
    mkdir -p DIR && git archive e53dc9b3a kn7000/src/program/data kn7000/src/sp7001/program/data \\
        kn7000/src/b935/program/data kn7000/src/b893/program/data kn6000/src/program/data \\
        kn6500/src/program/data kn2400/src/program/data hdsx3/src/program/data | tar -x -C DIR
    python3 kn7000/notes/mn10300-data4-probes/opaque_classes_diff.py DIR
"""
import collections
import os
import re
import sys

REPO = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
TREES = [("941", "kn7000/src/program/data"), ("942", "kn7000/src/sp7001/program/data"),
         ("935", "kn7000/src/b935/program/data"), ("893", "kn7000/src/b893/program/data"),
         ("kn6000", "kn6000/src/program/data"), ("kn6500", "kn6500/src/program/data"),
         ("kn2400", "kn2400/src/program/data"), ("hdsx3", "hdsx3/src/program/data")]
RX = re.compile(rb"# census: opaque -- unknown-dump: (\d+) bytes of (.*?) in (the program flash|the initialised-RAM image|RAM)")


def classes(d):
    n, b = collections.Counter(), collections.Counter()
    if not os.path.isdir(d):
        return n, b
    for f in sorted(os.listdir(d)):
        if re.fullmatch(r"data_\d+\.s", f):
            for ln in open(os.path.join(d, f), "rb"):
                m = RX.match(ln)
                if m:
                    k = (m.group(2).decode("latin-1"), m.group(3).decode())
                    n[k] += 1
                    b[k] += int(m.group(1))
    return n, b


def main(before):
    rows = [["tree", "class", "where", "pieces / bytes before", "pieces / bytes after"]]
    for t, d in TREES:
        nb, bb = classes(os.path.join(before, d))
        na, ba = classes(os.path.join(REPO, d))
        for k in sorted(set(nb) | set(na)):
            rows.append([t, k[0], k[1], f"{nb[k]} / {bb[k]:,}", f"{na[k]} / {ba[k]:,}"])
        rows.append([t, "total", "", f"{sum(nb.values())} / {sum(bb.values()):,}",
                     f"{sum(na.values())} / {sum(ba.values()):,}"])
    w = [max(len(r[c]) for r in rows) for c in range(5)]
    line = lambda r: "| " + " | ".join(r[c].ljust(w[c]) for c in range(5)) + " |"  # noqa: E731
    print(line(rows[0]))
    print("|" + "|".join("-" * (w[c] + 2) for c in range(5)) + "|")
    for r in rows[1:]:
        print(line(r))


if __name__ == "__main__":
    main(os.path.abspath(sys.argv[1]))
