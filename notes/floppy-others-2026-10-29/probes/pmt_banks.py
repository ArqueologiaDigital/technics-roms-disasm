"""Do the KN6000/KN7000 .PMT payloads tile as: a 0x10-byte header (count at +0x0E), then per bank a
16-character name and 8 tag/length record lists each ended by FF FF?  Run in floppy/build after a gate:
  python3 -I pmt_banks.py 'kn*/*/*.pmt.p1.ref'
Result 2026-10-29: all 72 tile exactly, banks * 8 == the count, 1,464 memories of 42 records (KN6000)
and 344 of 43 (KN7000).  (Walking from +0x20 as one list instead resynchronises by luck on most files and
overruns on 6: the bank names are not records.)"""
import collections, glob, sys
def block(p, o):
    q, recs = o, []
    while q + 2 <= len(p):
        t, l = p[q], p[q + 1]
        if t == 0xff and l == 0xff:
            return recs, q + 2
        recs.append((q, t, l)); q += 2 + l
    return None, None
R, N = collections.Counter(), collections.Counter()
for f in sorted(glob.glob(sys.argv[1])):
    p = open(f, 'rb').read(); n = p[0xe] | p[0xf] << 8; o, ok, banks = 0x10, True, 0
    while o < len(p) and ok:
        o += 16; banks += 1
        for k in range(8):
            r, e = block(p, o)
            if r is None: ok = False; break
            N[len(r)] += 1; o = e
    R[(ok and o == len(p), banks * 8 == n)] += 1
print(R, sorted(N.items()))
