#!/usr/bin/env python3
"""layout_probe.py -- QUESTION: what is in each 2 MiB page of a tone generator's wave stream, and do the
layout rules src/wave/*.s relies on hold for every page of both pairs?

Prints, per page: directory entries (and how many are 8-bit, P bit 3), distinct recordings (distinct B),
record words, the word where the first recording starts, and the 0xFFFF fill that ends the page.  Then
the rule checks, each counted over all 3,974 entries (PASS = every entry):
  R1  entry 0's A = 4 x the entry count            R5  P bits 15:12 = 0x1
  R2  records follow the directory in entry order, R6  record word 0 = the entry's B
      each starting on an even word, pad words 0  R7  Q = the record's first parameter word
  R3  the first recording starts at the first     R8  the code field (bits 13:8) is non-zero only in
      16-word boundary after the records, 0-fill       records of PCM8 entries
  R4  no 0xFFFF run of >= 128 words inside a page
and the census of record shapes (S segment, k split value, Z value 0; the digit is the flags field).

Run:  python3 layout_probe.py
"""
import collections
import re
import numpy as np
from wavestream import stream, entries, record, PAGE, NPAGES

TOTAL = collections.Counter()
for tg in ("main", "sub"):
    s = stream(tg)
    shapes = collections.Counter()
    print(f"{tg}: page  entries  8-bit  recordings  record-words  first-pcm-word  fill-words")
    for p in range(NPAGES):
        base = p * PAGE
        ents = entries(s, p)
        n = len(ents)
        TOTAL["entries"] += n
        TOTAL["R1"] += s[base] == 4 * n
        pos = 4 * n
        for (A, P, B, Q) in ents:
            r = record(s, p, A)
            TOTAL["R2"] += A == pos + (pos & 1) and (not pos & 1 or s[base + pos] == 0)
            TOTAL["R5"] += P >> 12 == 1
            TOTAL["R6"] += r[0] == B
            TOTAL["R7"] += r[1] == Q
            TOTAL["R8"] += bool(P & 8) or all(((v >> 8) & 0x3F) == 0 for v in r[1:])
            k = ""
            for v in r[1:]:
                fl, val = v >> 14, v & 0xFF
                c = "S" if val >= 0x80 else ("Z" if val == 0 else "k")
                k += c if fl == 0 else c + str(fl)
            shapes[re.sub(r"k+", "k*", re.sub(r"S+", "S*", k))] += 1
            pos = A + len(r)
        starts = sorted({e[2] for e in ents})
        pcm0 = starts[0] * 16
        TOTAL["pages"] += 1
        TOTAL["R3"] += pcm0 == (pos + 15) // 16 * 16 and not s[base + pos: base + pcm0].any()
        pg = s[base: base + PAGE]
        t = PAGE
        while t and pg[t - 1] == 0xFFFF:
            t -= 1
        ff = np.concatenate(([0], (pg[:t] == 0xFFFF).astype(np.int8), [0]))
        d = np.diff(ff)
        runs = np.where(d == -1)[0] - np.where(d == 1)[0]
        TOTAL["R4"] += not (runs >= 128).any()
        n8 = sum(1 for e in ents if e[1] & 8)
        print(f"{tg}: 0x{p:02X}  {n:7d}  {n8:5d}  {len(starts):10d}  {pos - 4 * n:12d}  {pcm0:#14x}  {PAGE - t:10d}")
    print(f"{tg}: record shapes: " + ", ".join(f"{k} {v}" for k, v in shapes.most_common()))
print()
print(f"R1 {TOTAL['R1']} of {TOTAL['pages']} pages; R3 {TOTAL['R3']} of {TOTAL['pages']}; R4 {TOTAL['R4']} of {TOTAL['pages']}")
for r in ("R2", "R5", "R6", "R7", "R8"):
    print(f"{r} {TOTAL[r]} of {TOTAL['entries']} entries")
