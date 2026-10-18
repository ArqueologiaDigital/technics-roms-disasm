#!/usr/bin/env python3
"""Dump the raw event stream of one track of a decompressed KN5000 demo preset (SLIDE4K-decoded .bin).
Usage: dump_demo_track.py BIN TRACK [--all-nonnote]
Layout per table_data/includes/demo_presets/README.md: +0x20 16 track types, +0xD0 16x{flags,u16 cell}, cells at 0x800+(c-1)*256, payload [5..255]."""
import sys
d = open(sys.argv[1], 'rb').read()
want = int(sys.argv[2], 0)
def track_payload(t):
    e = 0xD0 + t*3
    flags, cell = d[e], d[e+1] | (d[e+2] << 8)
    if not flags & 0x80:
        return None
    pay = bytearray(); c = cell; seen = set()
    while c not in (0, 0xFFFF) and c not in seen:
        seen.add(c); base = 0x800 + (c-1)*256
        if base+256 > len(d): break
        pay += d[base+5:base+256]; c = d[base+3] | (d[base+4] << 8)
    return pay
print("track types +0x20:", ' '.join('%02X' % x for x in d[0x20:0x30]))
print("mask +0x1E: %04X" % (d[0x1E] | d[0x1F] << 8))
for t in range(16):
    e = 0xD0 + t*3
    print("track %2d flags %02X cell %04X" % (t, d[e], d[e+1] | d[e+2] << 8))
pay = track_payload(want)
# tokenize: status byte + data bytes until next status
i = 0; beat = 0; out = []
while i < len(pay):
    b = pay[i]
    if b & 0x80:
        j = i+1
        while j < len(pay) and not pay[j] & 0x80: j += 1
        out.append((beat, b, bytes(pay[i+1:j])))
        if b == 0x81: beat += 1
        if b == 0x82:
            out.append((beat, 'END', bytes(pay[i+1:i+200])))
            break
        i = j
    else:
        i += 1
for beat, st, data in out:
    if st == 0x81: continue
    if st == 'END':
        print("END trailing:", data[:120]); continue
    print("beat %4d st %02X data %s" % (beat, st, data.hex(' ')))
