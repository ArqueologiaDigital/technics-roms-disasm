#!/usr/bin/env python3
"""slack_origin.py -- where do the bytes past a record's end come from?

Question: a slot record declares its size at +0x00, but its blocks often hold non-erased bytes
past that size.  Are they data the firmware reads, or residue?  For each record of each image,
prints the residue's extent and every other record (any image) whose bytes at the SAME offsets
are identical: a match says the writer reused a buffer that still held an earlier, longer record.

Usage: python3 -I slack_origin.py IMAGE [IMAGE ...]
"""
import struct
import sys

BLOCK = 0x8000


def records(d):
    for s in range(20):
        st, n = d[2 + 2 * s], d[3 + 2 * s]
        if st:
            b = d[st * BLOCK:(st + n) * BLOCK]
            yield s, b, struct.unpack_from("<I", b, 0)[0]


imgs = {p.rsplit("/", 1)[-1]: open(p, "rb").read() for p in sys.argv[1:]}
total = matched = 0
for name, d in imgs.items():
    for s, b, size in records(d):
        e = len(b)
        while e > size and b[e - 1] == 0xFF:
            e -= 1
        tail = b[size:e]
        if not tail:
            continue
        total += 1
        hits = [f"{n2}:slot{s2}" for n2, d2 in imgs.items() for s2, b2, _ in records(d2)
                if (n2, s2) != (name, s) and b2[size:e] == tail]
        matched += bool(hits)
        print(f"{name} slot {s:2d}: size {size:#07x}, residue {len(tail):#07x} bytes;"
              f" same bytes at the same offsets in: {', '.join(hits[:4]) or '-'}")
print(f"{total} records with residue, {matched} of them matched by another record")
