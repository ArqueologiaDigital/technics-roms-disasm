#!/usr/bin/env python3
"""loop_probe.py -- QUESTION: do the record's LOOP_START / LOOP_END marks, counted in granules of
L = 2^(K+4) samples (K = directory word P bits 2:0), fall where the sample data itself has a loop?

The signal: a looping wavetable chip needs the samples right after the loop end to repeat the first
samples of the loop (the interpolator reads ahead across the wrap).  For every entry whose record has
both marks, compare the N samples after loop_end with the N samples after loop_start (16-bit entries:
words; 8-bit entries, P bit 3: bytes).  PASS = all N equal.  As a control, the same test with the marks
read in granules of L/2 and 2L.

Run:  python3 loop_probe.py            (reads the four chip images, see wavestream.py)
"""
import sys
import numpy as np
from wavestream import stream, entries, record, granule, segments, PAGE, NPAGES

N = 32


def test(s, scale):
    tot = ok = 0
    for p in range(NPAGES):
        base = p * PAGE
        for (A, P, B, Q) in entries(s, p):
            r = record(s, p, A)
            L = int(granule(P) * scale)
            ls, le, _ = segments(r[1:], L)
            if ls is None or le is None or le <= ls:
                continue
            is8 = bool(P & 8)
            start = base + B * 16
            if is8:
                d = s[start: base + PAGE].view(np.uint8)
            else:
                d = s[start: base + PAGE]
            if le + N > d.size:
                continue
            tot += 1
            ok += bool(np.array_equal(d[le:le + N], d[ls:ls + N]))
    return tot, ok


for tg in ("main", "sub"):
    s = stream(tg)
    for scale, what in ((1, "L = 2^(K+4)"), (0.5, "control L/2"), (2, "control 2L")):
        tot, ok = test(s, scale)
        print(f"{tg:4s} {what:12s}: {ok:5d} of {tot:5d} entries with both marks repeat the loop's first {N} samples after its end")
