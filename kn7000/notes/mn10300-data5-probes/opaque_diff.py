#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""opaque_diff.py -- which census-opaque byte ranges did a regeneration add or remove?

QUESTION IT ANSWERS
  "Between two copies of a tree's data directory (BEFORE, e.g. the committed one or a `git archive` of the base,
   and AFTER, a generator run's output), which bytes are opaque (`census: opaque -- unknown-dump` +
   `.incbin_range`) in one and not the other?"  Prints the ranges that became opaque (a rise to explain) and,
   with --all, those that stopped being opaque; totals both ways.

RUN (from the repository root)
  python3 -I kn7000/notes/mn10300-data5-probes/opaque_diff.py BEFORE_DIR AFTER_DIR [--all]
"""
import os
import re
import sys


def ranges(ddir):
    out = []
    for f in sorted(os.listdir(ddir)):
        if not re.fullmatch(r"data_\d+\.s", f):
            continue
        L = open(os.path.join(ddir, f), "rb").read().split(b"\n")
        for i, ln in enumerate(L[:-1]):
            if ln.startswith(b"# census: opaque -- unknown-dump"):
                m = re.match(rb'\.incbin_range "[^"]+", (0x[0-9A-Fa-f]+), (0x[0-9A-Fa-f]+)', L[i + 1])
                if m:
                    out.append((int(m.group(1), 16), int(m.group(2), 16), ln[:160].decode("latin-1")))
    return out


def cover(rs):
    s = set()
    for a, b, _c in rs:
        s.update(range(a, b))
    return s


def spans(bs):
    bs = sorted(bs)
    out = []
    for b in bs:
        if out and out[-1][1] == b:
            out[-1][1] = b + 1
        else:
            out.append([b, b + 1])
    return out


def main(argv):
    show_all = "--all" in argv
    argv = [a for a in argv if a != "--all"]
    before, after = ranges(argv[0]), ranges(argv[1])
    B, A = cover(before), cover(after)
    note = {a: c for a, _b, c in after}
    up, down = spans(A - B), spans(B - A)
    print(f"opaque bytes: before {len(B):,}, after {len(A):,}; newly opaque {len(A - B):,} in {len(up)} spans,"
          f" no longer opaque {len(B - A):,} in {len(down)} spans")
    for a, b in up:
        c = next((note[x] for x in sorted(note) if x <= a), "")
        print(f"  + 0x{a:06X}..0x{b:06X} ({b - a} B)  {c[:120]}")
    if show_all:
        for a, b in down:
            print(f"  - 0x{a:06X}..0x{b:06X} ({b - a} B)")


if __name__ == "__main__":
    main(sys.argv[1:])
