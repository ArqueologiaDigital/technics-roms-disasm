#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# lfn_bytes.py SHORT11 LONGNAME -- print the VFAT long-name entries that precede the 8.3 entry
# SHORT11 (11 bytes as stored, space padded, no dot), in on-disk order (highest sequence number
# first), as xapasm .byte lines. sdraw_probe.s carries its output for "FILE1   BIN".
#   python3 -I lfn_bytes.py "FILE1   BIN" kn7000_program_even_v1.6_b941.ic17
import sys
def cksum(s):
    c = 0
    for b in s:
        c = (((c & 1) << 7) | (c >> 1)) + b & 0xff
    return c
short = sys.argv[1].encode('ascii'); assert len(short) == 11
name = sys.argv[2]
u = [ord(ch) for ch in name]
if len(u) % 13:
    u += [0]
    u += [0xffff] * ((13 - len(u) % 13) % 13)
n = len(u) // 13
cs = cksum(short)
ents = []
for i in range(n):
    part = u[13*i:13*i+13]
    seq = (i + 1) | (0x40 if i == n - 1 else 0)
    e = bytearray(32)
    e[0] = seq
    for k, ch in enumerate(part):
        off = [1,3,5,7,9,14,16,18,20,22,24,28,30][k]
        e[off] = ch & 0xff; e[off+1] = ch >> 8
    e[11] = 0x0f; e[12] = 0; e[13] = cs; e[26] = 0; e[27] = 0
    ents.append(bytes(e))
print(f"# {n} LFN entries for {name!r} -> {sys.argv[1]!r}, checksum 0x{cs:02x}")
for e in reversed(ents):
    for h in (e[:16], e[16:]):
        print("    .byte   " + ", ".join(f"0x{b:02x}" for b in h))
