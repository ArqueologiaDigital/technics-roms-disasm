#!/usr/bin/env python3
"""List every non-note, non-beat event of a decompressed KN5000 demo preset, all tracks.
Usage: scan_demo_panel_events.py BIN [--summary]
Prints track, beat, status, data. With --summary, counts 0xBn events by (tag, offset)."""
import sys
from collections import Counter, defaultdict
d = open(sys.argv[1], 'rb').read()
summary = '--summary' in sys.argv
def track_payload(t):
    e = 0xD0 + t*3
    flags, cell = d[e], d[e+1] | (d[e+2] << 8)
    if not flags & 0x80: return None
    pay = bytearray(); c = cell; seen = set()
    while c not in (0, 0xFFFF) and c not in seen:
        seen.add(c); base = 0x800 + (c-1)*256
        if base+256 > len(d): break
        pay += d[base+5:base+256]; c = d[base+3] | (d[base+4] << 8)
    return pay
cnt = Counter(); vals = defaultdict(list)
for t in range(16):
    pay = track_payload(t)
    if pay is None: continue
    i = 0; beat = 0
    while i < len(pay):
        b = pay[i]
        if b & 0x80:
            j = i+1
            while j < len(pay) and not pay[j] & 0x80: j += 1
            data = bytes(pay[i+1:j])
            if b == 0x81: beat += 1
            elif b == 0x82: break
            elif (b & 0xF0) == 0x90: pass
            else:
                if (b & 0xF0) == 0xB0 and len(data) >= 4:
                    # possibly several 4-byte records after one status (running)
                    for k in range(0, len(data) - len(data) % 5, 5):
                        rec = data[k:k+5]
                        cnt[(t, b, rec[1], rec[2])] += 1
                        vals[(t, b, rec[1], rec[2])].append((beat, rec[3], rec[4]))
                if not summary:
                    print("trk %2d beat %4d st %02X %s" % (t, beat, b, data.hex(' ')))
            i = j
        else:
            i += 1
if summary:
    for k, n in sorted(cnt.items()):
        v = vals[k]
        print("trk %2d st %02X tag %02X off %02X : %3d events; first (beat,val,mask): %s" % (k[0], k[1], k[2], k[3], n, v[:6]))
