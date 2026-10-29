#!/usr/bin/env python3
"""format_probe.py -- QUESTION: does directory word P bit 3 say "two 8-bit samples per word"?

For every recording (distinct sample start B), read its words up to the next start two ways: as signed
16-bit samples and as signed 8-bit samples (low byte first).  Neighbouring samples of real audio
correlate strongly; the wrong reading gives noise.  Reported per value of P bit 3: how many recordings
correlate better (lag 1) as 8-bit than as 16-bit.  PASS = bit 3 set <=> 8-bit reads better.

Run:  python3 format_probe.py
"""
import numpy as np
from wavestream import stream, entries, PAGE, NPAGES


def lag1(x):
    x = x.astype(np.float64)
    x -= x.mean()
    d = (x * x).sum()
    return 0.0 if d == 0 else float((x[1:] * x[:-1]).sum() / d)


for tg in ("main", "sub"):
    s = stream(tg)
    res = {0: [0, 0], 1: [0, 0]}
    for p in range(NPAGES):
        base = p * PAGE
        ents = entries(s, p)
        starts = sorted({e[2] for e in ents})
        nxt = {b: (starts[i + 1] if i + 1 < len(starts) else PAGE // 16) for i, b in enumerate(starts)}
        seen = set()
        for (A, P, B, Q) in ents:
            if B in seen:
                continue
            seen.add(B)
            w = s[base + B * 16: base + nxt[B] * 16]
            if w.size < 64:
                continue
            c16 = lag1(w.view("<i2"))
            c8 = lag1(w.view(np.int8))
            f = (P >> 3) & 1
            res[f][0] += 1
            res[f][1] += c8 > c16
    for f in (0, 1):
        n, k = res[f]
        print(f"{tg:4s} P bit 3 = {f}: {k:5d} of {n:5d} recordings read better as 8-bit samples than as 16-bit")
