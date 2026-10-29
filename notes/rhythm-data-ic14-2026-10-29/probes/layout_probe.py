#!/usr/bin/env python3
"""layout_probe.py -- what fills IC14, 1 KB at a time, and where the 12-byte signature occurs.

QUESTION: is the image records + tracks + FF fill, with no other kind of region?  Prints the run-length
classification of 1 KB chunks (S = starts with the RhythmROM_ValidateHeader signature, F = all FF,
o = other), and the 64 KB banks that hold tracks.
USAGE: python3 notes/rhythm-data-ic14-2026-10-29/probes/layout_probe.py [IC14]
"""
import re
from ic14_common import load

d = load()
sig = bytes.fromhex("000104058300010405830001")
pos = [m.start() for m in re.finditer(re.escape(sig), d)]
print("signature occurrences %d, at 1 KB boundaries %d (last 0x%X)" % (len(pos), sum(p % 0x400 == 0 for p in pos),
                                                                    max(p for p in pos if p % 0x400 == 0)))
s = "".join("F" if d[i:i + 0x400] == b"\xff" * 0x400 else "S" if d[i:i + 12] == sig else "o"
            for i in range(0, len(d), 0x400))
i = 0
while i < len(s):
    j = i
    while j < len(s) and s[j] == s[i]:
        j += 1
    print("  %s 0x%06X-0x%06X  %4d KB" % (s[i], i * 0x400, j * 0x400 - 1, j - i))
    i = j
