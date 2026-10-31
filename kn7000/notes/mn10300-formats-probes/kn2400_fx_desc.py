#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""kn2400_fx_desc.py -- the KN2400's DSP-effect descriptors and their parameter records.

QUESTION ANSWERED: "what are the 1,089 small pieces between effect names at 0x48439000.. of the
KN2400 v1.1 program, and do the field meanings gen_data_s.py fx_descriptors() writes hold in every
record?"  FxDescGet (0x4863CDEF) answers FxDescTable[i] (0x4856C74C, 260 pointers; i from
func_4863D3FF).  Each pointer leads to a 16-byte descriptor {u8 count, u8 nparams, u16 0,
params, s8 +8 .. +12, 3 bytes}, whose params are `count` 36-byte records right before it:
{char name[20]; u16 number, s16 min, s16 max; u8 +26, +27, +28, +29; u16 +30; values}.
The probe checks, over every descriptor the table reaches:
  * the descriptors and their records tile one region with no gap (and where it starts / ends);
  * every name is NUL-padded to 20 bytes;
  * nparams = the highest parameter number + 1 (several records may share a number: the "(V)"
    twins, whose +28 is 1 where the plain one's is 0);
  * a record's name ends in "(V)" exactly when its +28 is 1;
  * +12 is the number of the record named "REVERB SEND", or -1 when there is none;
  * +9 is the number of a record whose name holds "LFO SPEED" / "SPEED", or -1 (the counts are
    printed: this one is [INFERENCE], the data agreeing);
and prints the value distributions of the bytes whose readers are not traced.

RUN (from kn7000/):  python3 notes/mn10300-formats-probes/kn2400_fx_desc.py
"""
import collections
import os
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
ROM = os.path.normpath(os.path.join(HERE, "..", "..", "..", "kn2400", "baserom", "kn2400_program.rom"))
B = 0x48400000
TABLE, N = 0x4856C74C, 260


def main():
    d = open(ROM, "rb").read()
    u32 = lambda o: struct.unpack_from("<I", d, o)[0]  # noqa: E731
    ents = [u32(TABLE - B + 4 * i) for i in range(N)]
    descs = sorted(set(ents))
    spans, ok = [], collections.Counter()
    dist = collections.defaultdict(collections.Counter)
    for a in descs:
        o = a - B
        cnt, npar, p = d[o], d[o + 1], u32(o + 4) - B
        spans.append((p, o + 16))
        recs = []
        for i in range(cnt):
            r = p + 36 * i
            nm = d[r:r + 20]
            z = nm.find(b"\0")
            ok["name NUL-padded"] += z > 0 and nm[z:] == bytes(20 - z)
            num = struct.unpack_from("<H", d, r + 20)[0]
            recs.append((nm[:z].decode("latin-1"), num))
            ok["(V) in the name <=> +28 == 1"] += ("(V)" in recs[-1][0]) == (d[r + 28] == 1)
            for k in (26, 27, 28, 29):
                dist[f"param +{k}"][d[r + k]] += 1
            dist["param +30"][struct.unpack_from("<H", d, r + 30)[0]] += 1
        ok["records"] += cnt
        if cnt:
            ok["nparams = max number + 1"] += npar == max(n for _s, n in recs) + 1
            s8 = lambda k: d[o + k] - 256 if d[o + k] >= 0x80 else d[o + k]  # noqa: E731
            send = [n for s, n in recs if s == "REVERB SEND"]
            ok["+12 = REVERB SEND's number (or -1)"] += s8(12) == (send[0] if send else -1)
            lfo = [n for s, n in recs if "SPEED" in s]
            ok["+9 = a *SPEED* record's number (or -1 when none)"] += (s8(9) in lfo) if s8(9) >= 0 else not lfo
            ok["descriptors with records"] += 1
            for k in (8, 10, 11):
                dist[f"desc +{k}"][s8(k)] += 1
            dist["desc +13..15"][d[o + 13:o + 16].hex()] += 1
    spans.sort()
    gaps = sum(1 for x, y in zip(spans, spans[1:]) if x[1] != y[0])
    print(f"{len(descs)} distinct descriptors in {N} table entries; region 0x{B + spans[0][0]:08X}.."
          f"0x{B + spans[-1][1]:08X} ({spans[-1][1] - spans[0][0]} bytes), {gaps} gaps")
    for k, v in ok.items():
        print(f"  {k:52s} {v}")
    for k, c in dist.items():
        print(f"  {k:14s} " + ", ".join(f"{v}: {n}" for v, n in sorted(c.items(), key=lambda x: str(x[0]))))


if __name__ == "__main__":
    main()
