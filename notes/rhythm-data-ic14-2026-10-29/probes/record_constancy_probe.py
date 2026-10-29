#!/usr/bin/env python3
"""record_constancy_probe.py -- which bytes of the 404 record halves vary, and which never do.

QUESTION: what is fixed layout and what is a field?  Prints, for the halves of each parity (0 = "..1n",
1 = "..1v"), the runs of byte offsets that are constant (C, with the bytes when short) or variable (V).
The section map +0x000..+0x117, the FF runs and the 13 trailing zeros come out constant in all 404.
USAGE: python3 notes/rhythm-data-ic14-2026-10-29/probes/record_constancy_probe.py [IC14]
"""
from ic14_common import load, HALVES

d = load()
H = [d[i:i + 0x400] for i in HALVES]
for par in (0, 1):
    hs = H[par::2]
    var = [len({h[i] for h in hs}) > 1 for i in range(0x400)]
    i = 0
    out = []
    while i < 0x400:
        j = i
        while j < 0x400 and var[j] == var[i]:
            j += 1
        out.append("%s+%03X..+%03X%s" % ("V" if var[i] else "C", i, j - 1,
                                        "" if var[i] or j - i > 16 else "=" + hs[0][i:j].hex()))
        i = j
    print("half %d (%d halves): %s" % (par, len(hs), " ".join(out)))
