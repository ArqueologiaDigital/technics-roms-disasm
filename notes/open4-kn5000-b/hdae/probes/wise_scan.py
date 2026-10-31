#!/usr/bin/env python3
"""Find the raw-deflate members of a Wise (Great Lakes Business Solutions) installer.

Wise installers of the Windows 3.1 era append each installed file as a raw deflate stream
(zlib wbits=-15) followed by a 4-byte CRC32 of the inflated data.  This scans every byte offset
of the given volumes (concatenated in order, e.g. X.EXE then X.W02), tries a raw inflate there,
and keeps a stream when it ends cleanly and the 4 bytes after it equal the CRC32 of its output.
Each kept member is written to OUTDIR as member_<offset>.bin, and one line per member is
printed: offset, packed size, inflated size, first 16 bytes.

The volumes are untrusted vendor data: run with `python3 -I`, OUTDIR an empty scratch directory.

Usage: python3 -I wise_scan.py OUTDIR VOLUME [VOLUME ...]
"""
import os
import sys
import zlib

out = sys.argv[1]
vols = sys.argv[2:]
data = b''.join(open(v, 'rb').read() for v in vols)
mv = memoryview(data)
os.makedirs(out, exist_ok=True)
i = 0
n = 0
WINDOW = 4 << 20
while i < len(data) - 8:
    d = zlib.decompressobj(-15)
    chunk = mv[i:i + WINDOW]
    try:
        res = d.decompress(chunk, 64 << 20)
    except zlib.error:
        i += 1
        continue
    if not d.eof or len(res) < 16:
        i += 1
        continue
    used = len(chunk) - len(d.unused_data)
    crc = int.from_bytes(data[i + used:i + used + 4], 'little')
    if crc != zlib.crc32(res):
        i += 1
        continue
    with open(os.path.join(out, 'member_%08x.bin' % i), 'wb') as f:
        f.write(res)
    print('%08x  %8d -> %8d  %s' % (i, used, len(res), res[:16].hex()), flush=True)
    n += 1
    i += used + 4
print('members:', n)
