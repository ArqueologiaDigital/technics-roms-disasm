#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""gap_kinds.py -- what kinds of bytes a program build's typed data region still leaves generic.

QUESTION IT ANSWERS
  "Of the .incbin_range pieces left in src/<build>/program/data/, how many bytes look like what?"
  Each generic piece (an .incbin_range not marked census: opaque) is put in the first kind that fits:
    tail     < 8 bytes right after a typed item (a struct's last fields, or its padding)
    text     >= 60% printable bytes
    pointers >= half its aligned words are program / RAM addresses
    small    every byte < 0x80 (7-bit values: parameters, MIDI data, indexes)
    other    anything else
  and in a size class (< 16, < 256, < 4096, >= 4096 bytes).  Measures; types nothing.

RUN (from kn7000/, after a build):
  python3 notes/gui-data-region-probes/gap_kinds.py [src/program/data] [baserom/kn7000_program.rom] [base]
  (base: the image's link base, default 0x48400000; the SX-KN6000 / KN6500 0x4C000000, the HD-SX3
  plug-in 0x97800000; lane siblings-final)
"""
import collections
import glob
import os
import re
import sys

d = sys.argv[1] if len(sys.argv) > 1 else "src/program/data"
rom = open(sys.argv[2] if len(sys.argv) > 2 else "baserom/kn7000_program.rom", "rb").read()
B = int(sys.argv[3], 0) if len(sys.argv) > 3 else 0x48400000
kinds, sizes, n = collections.Counter(), collections.Counter(), collections.Counter()
for f in sorted(glob.glob(os.path.join(d, "data_*.s"))):
    prev = ""
    for ln in open(f, encoding="latin-1"):
        m = re.match(r'\.incbin_range "[^"]+", 0x([0-9A-F]+), 0x([0-9A-F]+)', ln)
        if m and "opaque" not in prev:
            a, b = int(m.group(1), 16), int(m.group(2), 16)
            bs = rom[a:b]
            words = [int.from_bytes(rom[k:k + 4], "little") for k in range(a + (-a % 4), b - 3, 4)]
            ptr = sum(1 for w in words if B <= w < B + len(rom) or 0x50000000 <= w < 0x50008000)
            prev_typed = prev.strip() and not prev.startswith(".incbin") and not prev.strip().endswith(":")
            if b - a < 8 and prev_typed:
                k = "tail"
            elif sum(1 for c in bs if 0x20 <= c < 0x7F) >= 0.6 * len(bs):
                k = "text"
            elif words and 2 * ptr >= len(words):
                k = "pointers"
            elif all(c < 0x80 for c in bs):
                k = "small"
            else:
                k = "other"
            sz = "<16" if b - a < 16 else "<256" if b - a < 256 else "<4096" if b - a < 4096 else ">=4096"
            kinds[k] += b - a
            n[k] += 1
            sizes[sz] += b - a
        prev = ln
print(f"{sum(n.values())} generic pieces, {sum(kinds.values())} bytes")
for k, v in kinds.most_common():
    print(f"  {k:9s} {n[k]:6d} pieces {v:9d} bytes")
for k in ("<16", "<256", "<4096", ">=4096"):
    print(f"  size {k:7s} {sizes[k]:9d} bytes")
