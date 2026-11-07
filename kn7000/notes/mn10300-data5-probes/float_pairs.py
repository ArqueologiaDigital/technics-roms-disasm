#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""float_pairs.py -- which of a tree's "double tables" are really single-precision floats?

QUESTION IT ANSWERS
  "Of the tables gen_data_s.py's doubles() typed as IEEE-754 doubles (labels doubles_<ADDR>, the
   `# IEEE-754 doubles (lo word, hi word)` header), which pass gen_data_s.float_pairs(): at least 4 words with a
   low word that is not 0, three quarters of which read as two singles of plausible exponent (2^-31 .. 2^32)?"
   A double's low word is mantissa bits; read as a single it has such an exponent about one time in four.
   Prints each table: words, words with lo != 0, of them pairs of plausible singles, verdict.

RUN (from the repository root)
  python3 -I kn7000/notes/mn10300-data5-probes/float_pairs.py [TREE ...]   (941 942 935 893 kn6000 kn6500 kn2400 hdsx3)
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
TREES = {"941": "kn7000/src/program/data", "942": "kn7000/src/sp7001/program/data",
         "935": "kn7000/src/b935/program/data", "893": "kn7000/src/b893/program/data",
         "kn6000": "kn6000/src/program/data", "kn6500": "kn6500/src/program/data",
         "kn2400": "kn2400/src/program/data", "hdsx3": "hdsx3/src/program/data"}


def plausible(w):
    e = (w >> 23) & 0xFF
    return w & 0x7FFFFFFF == 0 or 0x60 <= e <= 0x9F


def main(argv):
    for t in argv or list(TREES):
        d = os.path.join(REPO, TREES[t])
        n_f = 0
        for f in sorted(os.listdir(d)):
            if not re.fullmatch(r"data_\d+\.s", f):
                continue
            L = open(os.path.join(d, f), "rb").read().decode("latin-1").split("\n")
            i = 0
            while i < len(L):
                m = re.match(r"^(\S+):\s+# IEEE-754 doubles", L[i])
                if not m:
                    i += 1
                    continue
                words = []
                i += 1
                while i < len(L) and L[i].startswith("\t.long\t0x"):
                    lo, hi = re.findall(r"0x([0-9A-Fa-f]{8})", L[i])[:2]
                    words.append((int(lo, 16), int(hi, 16)))
                    i += 1
                nz = [w for w in words if w[0]]
                both = sum(1 for lo, hi in nz if plausible(lo) and plausible(hi))
                fl = len(nz) >= 4 and 4 * both >= 3 * len(nz)
                n_f += fl
                print(f"{t:7s} {m.group(1):24s} {len(words):4d} words, {len(nz):4d} lo!=0, {both:4d} float pairs:"
                      f" {'SINGLES' if fl else 'doubles'}")
        print(f"{t:7s} {n_f} tables are singles")


if __name__ == "__main__":
    main(sys.argv[1:])
