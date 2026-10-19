#!/usr/bin/env python3
"""song_tables.py -- question: what does the KN7000 (941) song engine accept, per its own ROM tables?
Prints (all addresses = program ROM, base 0x48400000):
  * event length table 0x485B9328 (status -> total length, -1 = invalid), read by 0x4845BC5B
  * per-track-kind parameter whitelists used by 0x4845BC6D (playback 0x484599D2, recording 0x4845A15D):
      parts (flag 0) / B.PEDAL 0x485B9428, parts (flag 1, PART 10 = DRUMS) 0x485B9574, APC 0x485B9670,
      CONTROL 0x485B96A4, RHYTHM 0x485B9728; flag table 0x485B974C; CHORD (0x1B) has no list (all ids pass)
  * track-assign preset 0x485B91F8 (track 1..16 -> kind) and kind names 0x486773D8
  * encoder class hash 0x485B9228 (0x484582D5) and value-size hash 0x485B92A8 (0x48458AC7)
usage: python3 -I song_tables.py [ROM]"""
import sys, struct
ROMP = sys.argv[1] if len(sys.argv) > 1 else "/home/fsanches/compartilhado/kn7000_disassembly/baserom/kn7000_program.rom"
rom = open(ROMP, "rb").read(); B = 0x48400000
u8 = lambda a: rom[a - B]; s8 = lambda a: struct.unpack_from("<b", rom, a - B)[0]
u32 = lambda a: struct.unpack_from("<I", rom, a - B)[0]
def cstr(a): return rom[a - B:a - B + 16].split(b"\0")[0].decode("latin1")
print("event length table 0x485B9328 (valid statuses only):")
print("  " + " ".join(f"{i:02X}:{s8(0x485B9328 + i)}" for i in range(256) if s8(0x485B9328 + i) > 0))
for name, t in (("PART kind, flag 0 (and B.PEDAL 0x1F)", 0x485B9428), ("PART kind, flag 1", 0x485B9574),
                ("APC 0x40", 0x485B9670), ("CONTROL 0x41", 0x485B96A4), ("RHYTHM 0x42", 0x485B9728)):
    ids = []; a = t
    while u32(a) != 0xFFFFFFFF: ids.append(u32(a)); a += 4
    print(f"whitelist {name} @{t:08X}: {len(ids)} ids")
    print("  " + " ".join(f"{v:06X}" for v in ids))
print("part flag table 0x485B974C:", " ".join(f"{u8(0x485B974C + i):02X}" for i in range(0x13)))
names = {k: cstr(u32(0x486773D8 + 4 * k)).strip() for k in range(0x43)}
print("track-assign preset 0x485B91F8:", " ".join(f"T{i+1}={names[u8(0x485B91F8+i)] or hex(u8(0x485B91F8+i))}" for i in range(16)))
print("encoder class hash 0x485B9228:", " ".join(f"{u32(0x485B9228+8*i)-1:02X}->{u32(0x485B9228+8*i+4):08X}" for i in range(16) if u32(0x485B9228+8*i)))
sz = {0x48458B05: 3, 0x48458B09: 2, 0x48458B0D: 1}
print("value-size hash 0x485B92A8 (id -> bytes, default 1):", " ".join(f"{u32(0x485B92A8+8*i)+3:06X}->{sz[u32(0x485B92A8+8*i+4)]}" for i in range(16) if u32(0x485B92A8+8*i)))
