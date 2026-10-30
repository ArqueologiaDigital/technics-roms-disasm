#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""reader_rows_stats.py -- what tools/gen_data_s.py reader_rows() made of the pieces that were generic.

QUESTION IT ANSWERS
  "In each typed data region, how many pieces (and bytes) does the last fallback pass write as rows at
   their readers' widths, how many of them are read at a known width, how many only have their address
   taken (a base, a call argument), and how many are strings handed to a string routine?"  Lane
   generic-zero (2026-10-30): before it these pieces were generic `.incbin_range`s of the reference image.

WHAT IT READS
  The committed sources src/<build>/program/data/data_*.s (bytes; they hold non-UTF-8 `.ascii`).  A
  reader_rows() piece starts with one of three header comments the generator writes:
    "# N bytes read by ...; the read fields at their widths"      -> read
    "# N bytes the code takes the address of: ..."                 -> address
    "# a string, N bytes with its pad, read by ..."                -> string
  each saying the piece's size in bytes; its rows (tab_u8 / tab_s8 / tab_u16 / tab_s16 / tab_u32 / .long /
  .asciz / .align) follow.

RUN (from the repository root)
  python3 kn7000/notes/data-final-probes/reader_rows_stats.py
"""
import glob, os, re, sys

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
TREES = [("kn7000-program", "kn7000/src/program/data"), ("kn7000-sp7001", "kn7000/src/sp7001/program/data"),
         ("kn7000-b935", "kn7000/src/b935/program/data"), ("kn7000-b893", "kn7000/src/b893/program/data"),
         ("kn6000", "kn6000/src/program/data"), ("kn6500", "kn6500/src/program/data"),
         ("kn2400", "kn2400/src/program/data"), ("hdsx3", "hdsx3/src/program/data")]


def main():
    head = ["tree", "read n", "read bytes", "address n", "address bytes", "string n", "total n", "total bytes"]
    body = []
    for tree, d in TREES:
        c = {"read": [0, 0], "address": [0, 0], "string": [0, 0]}
        for f in sorted(glob.glob(os.path.join(ROOT, d, "data_*.s"))):
            lines = open(f, "rb").read().split(b"\n")
            for i, ln in enumerate(lines):
                kind = ("read" if re.match(rb"\t# \d+ bytes read by .*the read fields at their widths", ln) else
                        "address" if re.match(rb"\t# \d+ bytes the code takes the address of: ", ln) else
                        "string" if re.match(rb"\t# a string, \d+ bytes with its pad, read by ", ln) else None)
                if kind is None:
                    continue
                n = int(re.search(rb"(\d+) bytes", ln).group(1))
                c[kind][0] += 1
                c[kind][1] += n
        tn = sum(v[0] for v in c.values())
        tb = sum(v[1] for v in c.values())
        body.append([tree, str(c["read"][0]), f'{c["read"][1]:,}', str(c["address"][0]), f'{c["address"][1]:,}',
                     str(c["string"][0]), str(tn), f"{tb:,}"])
    w = [max(len(r[i]) for r in [head] + body) for i in range(len(head))]
    print("| " + " | ".join(h.ljust(w[i]) for i, h in enumerate(head)) + " |")
    print("|" + "|".join("-" * (x + 2) for x in w) + "|")
    for r in body:
        print("| " + " | ".join(x.ljust(w[i]) for i, x in enumerate(r)) + " |")


if __name__ == "__main__":
    sys.exit(main())
