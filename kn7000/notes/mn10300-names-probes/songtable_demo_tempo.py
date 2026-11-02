#!/usr/bin/env python3
"""songtable_demo_tempo.py -- question: why does (almost) every built-in demo song open with tempo 250?

Inflates demo songs 1..10 the way func_48457355 does (pages <- zlib of u32[0x50000C50 + 4*(N-1)], the
.data image of 0x50000010.. at program ROM 0x487B0B78; same as kn7000_mame tools/slideshow/
demo_song_extract.py), walks every page chain with the firmware's length table 0x485B9328, and prints
for each song: the 0x80 tempo events (value = b1 + (b2 << 7), func_48458898: no scale, no offset;
TempoBpmReloadWrite 0x4844786C clamps 40..300 and loads TM5 with 1,250,000 / BPM), the beat of the
first note, and which statuses occur before the second tempo event.
Run from kn7000/:  python3 -I notes/mn10300-names-probes/songtable_demo_tempo.py
"""
import struct, zlib
from collections import Counter
B = 0x48400000
rom = open("baserom/kn7000_program.rom", "rb").read()
LEN = [struct.unpack_from("<b", rom, 0x485B9328 - B + i)[0] for i in range(256)]
word = lambda a: struct.unpack_from("<I", rom, a - B)[0]
data_word = lambda a: word(0x487B0B78 + (a - 0x50000010))


def chains(pg):
    n = len(pg) // 256
    for h in [i for i in range(n) if pg[i * 256] == 0x80 and struct.unpack_from("<H", pg, i * 256 + 1)[0] == 0]:
        buf, cur, seen = bytearray(), h, set()
        while cur is not None and cur not in seen and 0 <= cur < n:
            seen.add(cur); p = pg[cur * 256:(cur + 1) * 256]; buf += p[5:]
            nx = struct.unpack_from("<H", p, 3)[0]; cur = nx - 1 if nx else None
        yield bytes(buf)


for n in range(1, 11):
    src = data_word(0x50000C50 + 4 * (n - 1))
    pg = zlib.decompressobj().decompress(rom[src - B:src - B + 0x20000])
    evs = []
    for buf in chains(pg):
        i = beat = 0
        while i < len(buf):
            b = buf[i]
            if b < 0x80:
                i += 1; continue
            if b == 0x81:
                beat += 1
            elif b != 0x82:
                evs.append((beat, b, buf[i:i + LEN[b]]))
            if b == 0x82 or LEN[b] <= 0:
                break
            i += LEN[b]
    tempos = [(bt, e[1] + (e[2] << 7)) for bt, s, e in evs if s == 0x80]
    real = tempos[1][0] if len(tempos) > 1 else None
    first_note = min(bt for bt, s, e in evs if s & 0xF0 == 0x90)
    pre = Counter(f"{s:02X}" for bt, s, e in evs if real is not None and bt < real and s != 0x80)
    print(f"song {n:2d}: tempo events (beat, BPM) {tempos[:4]}{' ...' if len(tempos) > 4 else ''}; "
          f"first note at beat {first_note}; before beat {real}: {dict(pre)}")
