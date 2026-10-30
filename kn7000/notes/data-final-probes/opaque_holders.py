#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""opaque_holders.py -- does anything in the image hold an address inside a declared-opaque piece?

QUESTION IT ANSWERS
  "For the biggest pieces of a build's data region declared `census: opaque -- unknown-dump`, is there
   any 32-bit little-endian word ANYWHERE in the image (any alignment: a data pointer, or the imm32 of
   a `mov` in the code) whose value lies inside the piece, or within 64 bytes before it (a base the
   code adds an offset to)?"  It is the indirect-reader search behind ../data-final/README.md's list
   of what stays opaque: a piece with no holder at all can only be reached by an address computed
   from something further away.

RUN (from kn7000/, after a build):
  python3 notes/data-final-probes/opaque_holders.py [--profile 941] [--top 20]
"""
import argparse, bisect, os, re, struct, sys

HERE = os.path.dirname(os.path.abspath(__file__))
KN7 = os.path.normpath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(KN7, "tools"))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--profile", default="941")
    ap.add_argument("--top", type=int, default=20)
    a = ap.parse_args()
    os.chdir(KN7)
    import gen_data_s as G
    import generic_readers as GR
    G.configure(a.profile)
    rom = open(G.P["rom"], "rb").read()
    base = G.BASE
    labs = []
    for line in open(G.P["labels"]):
        n, v = line.split()
        labs.append((int(v, 16), n))
    labs.sort()
    keys = [x for x, _ in labs]

    def where(cpu):
        i = bisect.bisect_right(keys, cpu) - 1
        return f"{labs[i][1]}+{cpu - labs[i][0]}" if i >= 0 else hex(cpu)
    ps = sorted(GR.pieces(G.OUTDIR, True), key=lambda p: -(p[1] - p[0]))[:a.top]
    words = {}
    for o in range(len(rom) - 3):
        words.setdefault(struct.unpack_from("<I", rom, o)[0], []).append(o)
    for lo, hi, lab, f, ln in ps:
        lo_c, hi_c = base + lo, base + hi
        hits = [(v, o) for v in range(lo_c - 64, hi_c) for o in words.get(v, ())]
        print(f"{hi - lo:6d} {lo_c:08X}-{hi_c:08X} {f}:{ln} after {lab}: {len(hits)} holder(s)")
        for v, o in hits[:6]:
            print(f"         value {v:08X} ({'+' if v >= lo_c else ''}{v - lo_c}) held at {base + o:08X} = {where(base + o)}")


if __name__ == "__main__":
    main()
