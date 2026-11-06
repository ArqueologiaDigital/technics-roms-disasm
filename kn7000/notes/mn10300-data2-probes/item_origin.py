#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""item_origin.py -- which gen_data_s.py pass typed the item at an address?

QUESTION IT ANSWERS
  "For one gen_data_s.py profile, which generator pass (the Gen method that called Gen.add) made the item
   that holds CPU address A, of what kind and size?"  Used to find which pass takes a record's head as a
   string (opaque group false-string) before the pass that knows the record runs.  An address no item holds
   (an opaque piece's first byte) names the item that ends right before it.

RUN (from the repository root; the KN7000 profiles need kn7000/build/*.labels)
  python3 kn7000/notes/mn10300-data2-probes/item_origin.py --profile 941 --scratch DIR 0x487399D2 0x48613854
  (DIR receives the generator's output; nothing in the tree is written)
"""
import argparse
import os
import sys
import traceback

HERE = os.path.dirname(os.path.abspath(__file__))
TOOLS = os.path.normpath(os.path.join(HERE, "..", "..", "tools"))
sys.path.insert(0, TOOLS)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--profile", default="941")
    ap.add_argument("--scratch", required=True)
    ap.add_argument("addr", nargs="+")
    a = ap.parse_args()
    os.chdir(os.path.join(TOOLS, ".."))
    import gen_data_s as G
    G.configure(a.profile)
    origin = {}
    add0 = G.Gen.add

    def add(self, addr, size, label, kind, render, block=None):
        st = [f.name for f in traceback.extract_stack()[:-1] if f.filename.endswith("gen_data_s.py")]
        it = add0(self, addr, size, label, kind, render, block)
        origin.setdefault(self.off(addr), (st[-1] if st else "?", " < ".join(reversed(st[-4:]))))
        return it
    G.Gen.add = add
    g = G.Gen()
    g.run(os.path.join(a.scratch, a.profile))
    for s in a.addr:
        v = int(s, 0)
        it = g.item_containing(v) or g.item_containing(v - 1)   # (an opaque piece's start: the item before it)
        if it is None:
            print(f"{v:#010x}: no item")
            continue
        o = g.off(it.start)
        print(f"{v:#010x}: {it.label} ({it.kind}, {it.size} bytes at {it.start:#010x}) made by {origin.get(o, ('?', '?'))[1]}")


if __name__ == "__main__":
    main()
