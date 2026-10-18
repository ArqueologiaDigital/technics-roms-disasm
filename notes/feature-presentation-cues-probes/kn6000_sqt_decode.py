#!/usr/bin/env python3
"""Decode a KN6000 'I KD' .SQT (two raw-deflate parts, per kn7000_mame tools/slideshow/kn6000_sqt_pic_scan.py)
and write part1/part2 next to OUTPREFIX.  Usage: kn6000_sqt_decode.py FILE.SQT OUTPREFIX"""
import sys, struct, zlib
d = open(sys.argv[1], 'rb').read()
s1, s2, c1, c2 = struct.unpack_from('<IIII', d, 8)
o = zlib.decompressobj(-15); p1 = o.decompress(d[0x18:]); off = len(d) - len(o.unused_data) + 4
p2 = zlib.decompressobj(-15).decompress(d[off:])
print('%s: hdr %s sizes p1 %X/%X p2 %X/%X coded %X %X part2 at +%X' % (sys.argv[1], d[:8].hex(' '), len(p1), s1, len(p2), s2, c1, c2, off))
open(sys.argv[2] + '_part1.bin', 'wb').write(p1); open(sys.argv[2] + '_part2.bin', 'wb').write(p2)
