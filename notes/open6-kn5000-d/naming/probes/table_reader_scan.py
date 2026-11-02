#!/usr/bin/env python3
"""Does anything in a KN5000 program image point into a given labelled table?

QUESTION IT ANSWERS
  kn5000-j8z: RhythmProc_ChannelMapTable (now StyleSection_GroupBaseTable) had no reader in the source.  This
  scans each reference image for every way a TLCS-900 instruction or a pointer table can name a ROM byte:
  a little-endian 24-bit (and so also 32-bit) value equal to any address from LABEL - SLACK to LABEL + SIZE,
  and a PC-relative LDAR (f3 13 d16, PC taken as the address after 4 and after 5 bytes).  It prints every hit;
  "0 hits" for every tree is the evidence for "no reader".

RUN (repository root; the label is looked up in symbols/maincpu_<tree>_symbols_reference.txt):
  python3 notes/open6-kn5000-d/naming/probes/table_reader_scan.py [LABEL] [SIZE] [SLACK]
  defaults: StyleSection_GroupBaseTable 30 32.  v6 / v5 / v8 images are git-ignored copies made by `make`
  (rebuilt_ROMs/kn5000_<tree>_program.llvm.rom is used when original_ROMs/ has no file; it is byte-identical,
  `make gate`).
"""
import os
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", ".."))
label = sys.argv[1] if len(sys.argv) > 1 else "StyleSection_GroupBaseTable"
size = int(sys.argv[2], 0) if len(sys.argv) > 2 else 30
slack = int(sys.argv[3], 0) if len(sys.argv) > 3 else 32
BASE = 0xE00000
for tree in ("v10", "v9", "v7", "v6", "v5"):
    addr = None
    for line in open(os.path.join(REPO, "symbols", "maincpu_%s_symbols_reference.txt" % tree)):
        p = line.split()
        if len(p) == 2 and p[0] == label:
            addr = int(p[1], 16)
    rom = os.path.join(REPO, "original_ROMs", "kn5000_%s_program.rom" % tree)
    if not os.path.exists(rom):
        rom = os.path.join(REPO, "rebuilt_ROMs", "kn5000_%s_program.llvm.rom" % tree)
    if addr is None or not os.path.exists(rom):
        print("%-4s label or image missing" % tree)
        continue
    d = open(rom, "rb").read()
    lo, hi = addr - slack, addr + size
    hits = []
    for i in range(len(d) - 3):
        v = d[i] | d[i + 1] << 8 | d[i + 2] << 16
        if lo <= v < hi:
            hits.append("abs24 at 0x%06X -> 0x%06X" % (BASE + i, v))
        if d[i] == 0xF3 and d[i + 1] == 0x13:
            disp = int.from_bytes(d[i + 2:i + 4], "little", signed=True)
            for n in (4, 5):
                t = BASE + i + n + disp
                if lo <= t < hi:
                    hits.append("ldar at 0x%06X -> 0x%06X" % (BASE + i, t))
    print("%-4s %s = 0x%06X, window 0x%06X..0x%06X: %d hits" % (tree, label, addr, lo, hi - 1, len(hits)))
    for h in hits:
        print("       " + h)
