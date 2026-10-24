#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# What is where in the whole 4 MB of IC18 (C3CBND000046)? The boot ROM's used
# bytes and erased tail; the "Technics Rhythms" resource at 0x10000, its 16-bit
# checksum recomputed the way the figures in notes/ic18-boot-rom.md were (the
# big-endian word sum of 0x100000 words from 0x110000, compared with the word at
# 0x10010); the style count byte; the version string at the top of the chip; and
# the erased (0xFF) runs of 64 KB or more.
#
#   python3 -I ic18_layout.py ~/compartilhado/technics_romsets/kn7000/c3cbnd000046.ic18
import hashlib
import struct
import sys

d = open(sys.argv[1], "rb").read()
print(f"size {len(d)} bytes, SHA-1 {hashlib.sha1(d).hexdigest()}")
boot = d[:0x10000]
used = len(boot.rstrip(b"\xff"))
print(f"boot ROM 0x0000-0xFFFF: used up to 0x{used:04X} ({used} bytes), then 0xFF; "
      f"{sum(1 for b in boot if b != 0xFF)} bytes are not 0xFF; "
      f"SHA-1 of the 64 KB {hashlib.sha1(boot).hexdigest()}")
h = 0x10000
magic = d[h:h + 16]
stored = struct.unpack_from(">H", d, h + 0x10)[0]
calc = sum(struct.unpack_from(">%dH" % 0x100000, d, h + 0x100000)) & 0xFFFF
print(f"0x{h:06X}: {magic!r}; checksum word 0x{stored:04X}, recomputed 0x{calc:04X}"
      f" ({'equal' if calc == stored else 'DIFFERENT'})")
print(f"0x{h + 0x2A:06X}: byte 0x{d[h + 0x2A]:02X} = {d[h + 0x2A]} (the style count, by notes/ic18-boot-rom.md)")
top = d[0x3FFFE8:0x3FFFF8].split(b"\0")[0]
print(f"0x3FFFE8: {top!r}")
run0 = None
for i in range(0, len(d) + 1, 0x1000):
    blank = i < len(d) and d[i:i + 0x1000] == b"\xff" * 0x1000
    if blank and run0 is None:
        run0 = i
    elif not blank and run0 is not None:
        if i - run0 >= 0x10000:
            print(f"erased 0x{run0:06X}-0x{i:06X} ({(i - run0) // 1024} KB)")
        run0 = None
