#!/usr/bin/env python3
"""title_pool.py -- which title (screen) number does a _TT_ name have? (KN7000 941)

Question it answers: the firmware calls ChangeTitle(n); what screen is n? The program keeps the
title names as one pool of NUL-terminated "_TT_..." strings in title order, starting at title 1:
index + 1 = number, checked against three titles known from other work (_TT_DEBUG 0xFF,
_TT_MEMDUMP 0xF2, _TT_SOFTVER 0xF0).
usage: python3 -I title_pool.py PROGRAM.rom [NAME ...]
"""
import sys

d = open(sys.argv[1], "rb").read()
s = d.find(b"_TT_STYLCNVWAIT")
while True:
    j = d.rfind(b"\0", 0, s - 1)
    if d[j + 1:j + 5] != b"_TT_":
        break
    s = j + 1
names, i = [], s
while d[i:i + 4] == b"_TT_":
    e = d.index(b"\0", i)
    names.append(d[i:e].decode())
    i = e + 1
num = {n: k + 1 for k, n in enumerate(names)}
assert (num["_TT_DEBUG"], num["_TT_MEMDUMP"], num["_TT_SOFTVER"]) == (0xFF, 0xF2, 0xF0)
for n in sys.argv[2:] or [n for n in names if "STYLCNV" in n]:
    print(f"0x{num[n]:02X} {n}")
