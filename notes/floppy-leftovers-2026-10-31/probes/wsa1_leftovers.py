#!/usr/bin/env python3
"""wsa1_leftovers.py -- are the WSA1R .CMB and .MID stale tails copies of earlier bytes of the same file?

Reads the files fat12_extract.py writes (floppy/build/wsa1/<disk>/; `make -C floppy gate-wsa1` first).
Prints one line per file and a summary.

  .CMB (0x16400 bytes): is +0x16300..+0x163FF equal to +0x13700..+0x137FF, the first 0x100 bytes of
       combination 112 (the window bytes +0x300..+0x3FF of the chunk before the last, see
       floppy/wsa1/formats.py describe_cmb)?
  .MID: past the SMF's last track, is the rest of the last 1024-byte window equal to the bytes 1024
       earlier (the window buffer reused for each window)?

Usage: python3 notes/floppy-leftovers-2026-10-31/probes/wsa1_leftovers.py [floppy dir]
"""
import glob, os, struct, sys

FL = sys.argv[1] if len(sys.argv) > 1 else 'floppy'


def smf_length(d):
    if d[:4] != b'MThd':
        return None
    i = 8 + struct.unpack('>I', d[4:8])[0]
    for _ in range(struct.unpack('>H', d[10:12])[0]):
        i += 8 + struct.unpack('>I', d[i + 4:i + 8])[0]
    return i


cmb = mid = cmb_ok = mid_ok = 0
for f in sorted(glob.glob(os.path.join(FL, 'build', 'wsa1', '*', '*'))):
    ext = f.rsplit('.', 1)[-1].lower()
    d = open(f, 'rb').read()
    if ext == 'cmb' and len(d) == 0x16400:
        cmb += 1
        ok = d[0x16300:] == d[0x13700:0x13800]
        cmb_ok += ok
        print('%-40s CMB tail == +0x13700..+0x137FF (combination 112, first 0x100 bytes): %s' % (os.path.relpath(f, FL), ok))
    elif ext == 'mid':
        n = smf_length(d)
        if n is None or n == len(d):
            continue
        mid += 1
        t = len(d) - n
        ok = n >= 1024 and d[n:] == d[n - 1024:n - 1024 + t]
        mid_ok += ok
        print('%-40s MID SMF %d bytes, file %d, tail %d == the bytes 1024 earlier: %s' % (os.path.relpath(f, FL), n, len(d), t, ok))
print('CMB: %d of %d tails are that copy; MID: %d of %d tails are that copy' % (cmb_ok, cmb, mid_ok, mid))
