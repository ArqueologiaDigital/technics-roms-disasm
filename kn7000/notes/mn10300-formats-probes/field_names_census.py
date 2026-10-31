#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""field_names_census.py -- how many record fields are still named only by their offset, per tree.

QUESTION ANSWERED: "in the record macros tools/gen_data_s.py writes (each tree's
data_structs.inc: struct arrays, pointed records and the callee records REC_<F>_Arg<slot>), how
many fields have a name that says what they are, and how many only an offset name?"  An offset
name is the generator's fallback: f<off> (a number), p<off> (a pointer), s<off> (text), a<off>
(an array), x<off> (bytes no reader touches), with trailing '_' for duplicates.  Fields no reader
touches (x<off>) are counted apart: there is nothing to name them from.  `--list` prints the
offset-named fields that have readers, kind by kind.

RUN (from kn7000/):  python3 notes/mn10300-formats-probes/field_names_census.py [--list] [--md]
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
TREES = [("kn7000-941", "kn7000/src/program/data"), ("kn7000-942", "kn7000/src/sp7001/program/data"),
         ("kn7000-935", "kn7000/src/b935/program/data"), ("kn7000-893", "kn7000/src/b893/program/data"),
         ("kn7000-sp7001plugin", "kn7000/src/sp7001/plugin/data"),
         ("kn6000", "kn6000/src/program/data"), ("kn6500", "kn6500/src/program/data"),
         ("kn2400", "kn2400/src/program/data"), ("hdsx3", "hdsx3/src/program/data")]
OFFNAME = re.compile(r"^[fpsax]\d+_*$")


def census(path):
    f = os.path.join(REPO, path, "data_structs.inc")
    if not os.path.exists(f):
        return None
    kinds = fields = off = unread = 0
    listing = []
    cur = None
    for ln in open(f, encoding="latin-1"):
        m = re.match(r"^# (\S+): \d+-byte records", ln)
        if m:
            cur = m.group(1)
            kinds += 1
            continue
        m = re.match(r"^#   \+(\d+)\s+(\S+)\s+(\S+(?: x \d+)?(?: \(\S+\))?)\s*(.*)$", ln)
        if m and cur:
            fields += 1
            name, rd = m.group(2), m.group(4)
            if OFFNAME.match(name):
                if name.startswith("x") or rd == "no reader seen":
                    unread += 1
                else:
                    off += 1
                    listing.append(f"  {cur} +{m.group(1)} {name}: {rd[:100]}")
    return kinds, fields, off, unread, listing


def main():
    lst, md = "--list" in sys.argv, "--md" in sys.argv
    rows = []
    for t, p in TREES:
        r = census(p)
        if r is None:
            continue
        kinds, fields, off, unread, listing = r
        rows.append((t, kinds, fields, fields - off - unread, off, unread))
        if lst:
            print(f"== {t}")
            print("\n".join(listing))
    head = ("tree", "kinds", "fields", "named", "offset-named with a reader", "no reader")
    if md:
        cells = [head] + [tuple(str(x) for x in r) for r in rows]
        w = [max(len(c[i]) for c in cells) for i in range(len(head))]
        print("| " + " | ".join(c.ljust(w[i]) for i, c in enumerate(head)) + " |")
        print("|" + "|".join("-" * (x + 2) for x in w) + "|")
        for c in cells[1:]:
            print("| " + " | ".join(x.ljust(w[i]) for i, x in enumerate(c)) + " |")
    else:
        for r in rows:
            print(f"{r[0]:22s} kinds {r[1]:4d}  fields {r[2]:5d}  named {r[3]:5d}  offset-named {r[4]:5d}  no reader {r[5]:5d}")


if __name__ == "__main__":
    main()
