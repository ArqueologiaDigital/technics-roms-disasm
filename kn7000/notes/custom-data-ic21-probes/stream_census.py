#!/usr/bin/env python3
"""stream_census.py -- do all the style and pad streams parse as the firmware's events?

Question: with the event lengths of RhyEventLenByStatus 0x484403D5 / RhySysexLen 0x484403CD,
does every TCMP variation stream and TPAD pad stream of every live slot record parse to its
exact end, and which event kinds occur (how many)?  Prints the totals.

Usage: python3 -I stream_census.py IMAGE [IMAGE ...]
"""
import collections
import struct
import sys


def u24(b, o):
    return b[o] << 16 | b[o + 1] << 8 | b[o + 2]


def ev_len(d, o):
    c = d[o]
    if c == 0xF0:
        return d[o + 1] + 2
    return {0x90: 6, 0xB0: 3, 0xC0: 4, 0xD0: 2, 0xE0: 3}.get(c & 0xF0, 1)


kinds = collections.Counter()
streams = bad = hidata = nbytes = 0
maxpos = 0
for path in sys.argv[1:]:
    d = open(path, "rb").read()
    for s in range(20):
        st = d[2 + 2 * s]
        b = d[st * 0x8000:]
        for sec, nrec, ro, rs, so in ((0x94, 20, 0xF0, 0xE0, 0x15), (0x9C, 6, 0xA0, 0x60, 0x1D)):
            off, sz = struct.unpack_from("<II", b, sec)
            c = b[off:off + sz]
            for i in range(nrec):
                p = u24(c, ro + i * rs + so)
                q, e = p + 4, p + 4 + u24(c, p + 1)
                streams += 1
                nbytes += e - q
                while q < e:
                    x, n = c[q], ev_len(c, q)
                    kinds["position" if x < 0x80 else f"{x:#04x}" if x >= 0xF0 else f"{x & 0xF0:#04x}"] += 1
                    if x < 0x80:
                        maxpos = max(maxpos, x)
                    elif x not in (0xF0, 0xF4, 0xF5) and any(y >= 0x80 for y in c[q + 1:q + n]):
                        hidata += 1
                    q += n
                bad += q != e
print(f"{streams} streams, {nbytes} event bytes, {sum(kinds.values())} events; "
      f"{bad} do not end exactly; {hidata} events with a data byte >= 0x80; largest position {maxpos}")
for k, v in kinds.most_common():
    print(f"  {k:9s} {v}")
