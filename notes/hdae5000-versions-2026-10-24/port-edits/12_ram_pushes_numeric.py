"""Undo `pushw HDAE5000_RAM_X@hi16 / @lo16` pairs that the far-pointer pass made.

The first version of `port_hdae5000_version.py farptrs` (fixed since) also took plain
numeric pushes with a high half 0x0020-0x0023 for RAM pointers.  v2.06i spells every
RAM pointer push numerically, and some such pairs are not pointers at all
(`pushw 0x20 ; count = 32` + `pushw 0 ; fill value = 0`, the arguments of a fill,
became HDAE5000_RAM_AtaIdentifyBuffer).  Every one of them goes back to two numbers.

RUN (once): python3 notes/hdae5000-versions-2026-10-24/port-edits/12_ram_pushes_numeric.py
"""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
T = os.path.join(ROOT, "hdae5000_v2_01i")
equ = {}
for l in open(os.path.join(T, "hd-ae5000_v2_01i.s"), encoding="latin-1"):
    m = re.match(r'^\s*\.equ\s+(HDAE5000_RAM_\w+),\s*(0x[0-9a-fA-F]+)', l)
    if m:
        equ[m.group(1)] = int(m.group(2), 16)
n = 0
for fn in sorted(os.listdir(T)):
    if not fn.endswith(".s"):
        continue
    p = os.path.join(T, fn)
    s = open(p, "rb").read()

    def hi(m):
        global n
        n += 1
        return b"pushw" + m.group(1) + b"0x%04x" % (equ[m.group(2).decode()] >> 16)

    def lo(m):
        c = m.group(3)
        if b"low half of" in c:
            c = b""
        return b"pushw" + m.group(1) + b"0x%04x" % (equ[m.group(2).decode()] & 0xffff) + c
    t = re.sub(rb"pushw(\s+)(HDAE5000_RAM_\w+)@hi16", hi, s)
    t = re.sub(rb"pushw(\s+)(HDAE5000_RAM_\w+)@lo16([^\n]*)", lo, t)
    if t != s:
        open(p, "wb").write(t)
print("%d pairs back to numbers" % n)
