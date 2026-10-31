#!/usr/bin/env python3
"""What do sound-descriptor slots +0x30 and +0x34 hold, and is the voice index they are indexed by a GM program?

Reads the descriptor through SoundData_CategoryDescPtr (symbols/maincpu_<v>_symbols_reference.txt) in each of
the v10, v9 and v7 dumps and prints:
  * slot +0x30 grouped by value: which indices map to which (b, 0) pair -- the GS drum-set grouping
    (0-7, 8-15, 16-23, 24/26-31, 32-39, 40-47, 48-55, 56-63) shows if the index is a drum-set program;
  * slot +0x34 grouped by value (0, +12, -12);
  * slot +0x1C (voice index -> pointer to {program, bank, 0xFF} records): whether the FIRST record of voice v
    is (program v, bank 0) -- if it is for every v, the voice index is the bank-0 program number.
Asserts the three dumps agree.
Run:  python3 notes/open4-kn5000-b/midi/probes/sound_desc_slots_30_34.py
"""
import os, struct
from collections import defaultdict

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), *[".."] * 4))
B = 0xE00000


def load(v):
    rom = open(os.path.join(ROOT, "original_ROMs/kn5000_%s_program.rom" % v), "rb").read()
    sym = {}
    for line in open(os.path.join(ROOT, "symbols/maincpu_%s_symbols_reference.txt" % v)):
        p = line.split()
        if len(p) == 2 and not line.startswith("#"):
            sym[p[0]] = int(p[1], 16)
    u32 = lambda a: struct.unpack_from("<I", rom, a - B)[0]
    desc = u32(sym["SoundData_CategoryDescPtr"])
    t30 = rom[u32(desc + 0x30) - B:][:256]
    t34 = rom[u32(desc + 0x34) - B:][:128]
    t1c = u32(desc + 0x1C)
    first = [tuple(rom[u32(t1c + 4 * v) - B:][:2]) for v in range(128)]
    return t30, t34, first


res = {v: load(v) for v in ("v10", "v9", "v7")}
assert res["v10"] == res["v9"] == res["v7"], "dumps differ"
t30, t34, first = res["v10"]
print("dumps v10 == v9 == v7 for slots +0x30, +0x34 and +0x1C first records")
g = defaultdict(list)
for i in range(128):
    g[(t30[2 * i], t30[2 * i + 1])].append(i)
print("+0x30 (index -> (b, 0)):")
for k, ix in sorted(g.items()):
    print("  %02X %02X  <- %s" % (k[0], k[1], ix))
g = defaultdict(list)
for i in range(128):
    g[t34[i] - 256 if t34[i] > 127 else t34[i]].append(i)
print("+0x34 (voice index -> signed byte):")
for k, ix in sorted(g.items()):
    print("  %+d  <- %s" % (k, ix if len(ix) < 40 else "%d indices" % len(ix)))
same = [v for v in range(128) if first[v] == (v, 0)]
print("+0x1C: first {program, bank} of voice v is (v, 0) for %d of 128 voices; others: %s"
      % (len(same), [(v, first[v]) for v in range(128) if first[v] != (v, 0)][:12]))
