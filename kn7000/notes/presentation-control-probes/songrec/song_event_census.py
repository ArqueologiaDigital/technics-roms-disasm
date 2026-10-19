#!/usr/bin/env python3
"""song_event_census.py -- question: which event kinds (status bytes) occur in KN7000 song page data,
and which parameter ids do the 0xF1-0xF3 / 0xA1-0xA3 events carry?

Page format as read here (inferred from demo data + reader 0x48459C98, length table 0x485B9328):
  page = 256 bytes: [0x80, prev u16 LE, next u16 LE] then a byte stream that continues in page `next`
  (pages numbered from 1: page n at offset (n-1)*0x100); a chain starts at a page whose prev == 0.
  stream items: a byte < 0x80 is the position inside the beat (0..0x5F, 96 PPQN) and is followed by one
  event; a byte >= 0x80 is an event whose total length is LEN[status] (0x81 = next beat).
Decoding of F/A events follows the classifier 0x48458705: flags byte restores bit 7 of the following
bytes (bit k -> byte k), id = b[2]<<16|b[3]<<8|b[4] (F) / b[3]<<16|b[4]<<8|b[5] (A).
usage: python3 -I song_event_census.py ROM PAGES.bin [PAGES.bin ...]"""
import sys, struct, collections
ROM = open(sys.argv[1], "rb").read()
LEN = [struct.unpack_from("<b", ROM, 0x485B9328 - 0x48400000 + i)[0] for i in range(256)]
def walk(pg):
    n = len(pg) // 256
    heads = [i for i in range(n) if pg[i*256] == 0x80 and struct.unpack_from("<H", pg, i*256+1)[0] == 0]
    for h in heads:
        # flatten the chain
        buf = bytearray(); cur = h; seen = set()
        while cur is not None and cur not in seen and 0 <= cur < n:
            seen.add(cur); p = pg[cur*256:(cur+1)*256]
            buf += p[5:]
            nx = struct.unpack_from("<H", p, 3)[0]
            cur = nx - 1 if nx else None
        yield h, bytes(buf)
def census(path):
    pg = open(path, "rb").read()
    cnt = collections.Counter(); ids = collections.Counter(); bad = 0
    for h, s in walk(pg):
        i = 0
        while i < len(s):
            b = s[i]
            if b < 0x80: i += 1; continue
            L = LEN[b]
            if L <= 0:
                bad += 1; break
            ev = s[i:i+L]; cnt[b] += 1
            if b & 0xF0 in (0xF0, 0xA0) and len(ev) == L:
                f = ev[2] if b & 0xF0 == 0xA0 else ev[1]
                o = 3 if b & 0xF0 == 0xA0 else 2
                by = [ev[o+k] | (0x80 if f & (1 << k) else 0) for k in range(3)]
                ids[(b & 0xF0, by[0] << 16 | by[1] << 8 | by[2])] += 1
            if b == 0x82: break
            i += L
    print(f"{path}: chains={len(list(walk(pg)))} undecodable={bad}")
    print("  status counts:", " ".join(f"{k:02X}:{v}" for k, v in sorted(cnt.items())))
    if ids: print("  F/A ids:", " ".join(f"{t:02X}/{i:06X}:{v}" for (t, i), v in sorted(ids.items())))
for p in sys.argv[2:]: census(p)
