#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""reader_ext_stats.py -- what tools/data_readers.py's `ext` walk adds to the reader evidence.

QUESTION IT ANSWERS
  "With the extended walk (stack slots, joined address sets, function return values), how many
   distinct accesses does the converted code show that the plain walk does not, how many of them
   go through a T value (one of several addresses), and which functions return one of a set of data
   records?"  The numbers in ../data-final/README.md ("The extended reader walk").

RUN (from kn7000/, after a build):  python3 notes/data-final-probes/reader_ext_stats.py [--profile 941]
"""
import argparse, collections, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
KN7 = os.path.normpath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, os.path.join(KN7, "tools"))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--profile", default="941")
    a = ap.parse_args()
    os.chdir(KN7)
    import data_readers as DR
    import gen_data_s as G
    G.configure(a.profile)
    labels = {}
    for line in open(G.P["labels"]):
        n, v = line.split()
        labels[n] = int(v, 16)
    for line in open(os.path.join(G.OUTDIR, "labels.sym")):
        if not line.startswith(";"):
            ad, n, _ = line.split()
            labels[n] = int(ad, 16)
    uniq = {}
    for ext in (False, True):
        r = DR.Reader(os.path.join(G.P["src"], "*.s"), labels, G.Gen.in_data, ext=ext)
        uniq[ext] = {(x.key, x.off, x.width, x.rw, x.insn, x.cpu) for x in r.accesses}
        if ext:
            t = [x for x in r.accesses if x.key[0] == "ptr" and x.key[1][0] == "tgt"]
            print(f"ext: {len(t)} accesses through a T value, {len({x.key[1] for x in t})} distinct sets")
            print(f"ext: {len(r.returns)} functions return one of a set of data addresses in a0; largest:")
            for f, s in sorted(r.returns.items(), key=lambda kv: -len(kv[1]))[:8]:
                print(f"    {f:28s} {len(s)}")
    print(f"distinct accesses: plain walk {len(uniq[False])}, ext walk {len(uniq[True])}; "
          f"only in ext {len(uniq[True] - uniq[False])}, only in plain {len(uniq[False] - uniq[True])}")


if __name__ == "__main__":
    main()
