#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""kn2400_fx_pnums.py -- what the KN2400 FX_DESC bytes +8..+11 and FX_PARAM +0x1D select, per effect.

QUESTION IT ANSWERS: "for each DSP effect type (= FxDescTable index), which parameter do FX_DESC
`pnum9` / `pnum10` / `pnum11` name, which parameters have FX_PARAM +0x1D == 0, and what is the
type's `mode`?"  The readers, all in the flash code of the KN2400 v1.1 program:

  * +9  FxDescPnum9Get (entered at FxDescPnum9Get_L5 = 0x4863D344): its only caller is the routine
        at 0x4863B51E (no label, no call site, no pointer in the image), which finds the record of
        that number, reads the current value (func_4863DF3E), adds (stack argument - 0x40), clamps
        it to FxParamMinGet / FxParamMaxGet and posts it with func_48639E41 kind 2 (parameter change).
  * +10 FxDescPnum10Get: func_4863DF3E (the parameter value getter) answers GetM3Em(4) (func_50143A7C
        with d0 = 4) instead of the stored value for that number (or, for EQ band records, that band).
  * +11 FxDescPnum11Get: func_4863B2B6 / func_4863B3CF, on a change between two effects of the same
        type, post kind 1 or kind 5 (type reload); when +11 is not -1 and the resolved codes
        (func_4863CEF5) are equal they post nothing.
  * +8  FxDescModeGet: func_4863BA0B maps it to a routing value (posted as kind 9); func_4863BA75 and
        SndUnitDbGroupQuery act only when it is 1 or 2.
  * FX_PARAM +0x1D: FxParamX29Get (d0 = code, d1 = first index) returns the index of the next
        record at or after d1 whose +0x1D is 0 (and whose variant, if any, is the code's), or -1.
        func_4863BA75 multiplies each such parameter by (stack argument) / 0x50 and posts it;
        SndUnitDbGroupQuery answers GetM3Em(0x00B0005F | part << 24) for such a parameter.

The effect names come from the effect records func_4863CDB5 / func_4863CDD8 answer (name, then
+0x12 = the type, read by FxDescIndexGet `movhu (0x12, a0), d0`).

RUN (from the repository root):  python3 -I kn7000/notes/mn10300-rest-probes/kn2400_fx_pnums.py
"""
import collections
import os
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
ROM = os.path.join(ROOT, "kn2400", "baserom", "kn2400_program.rom")
LABELS = os.path.join(ROOT, "kn2400", "src", "program", "data", "labels.sym")
B = 0x48400000
FXDESC_TABLE, N = 0x4856C74C, 260


def main():
    d = open(ROM, "rb").read()
    lab = {}
    for line in open(LABELS, encoding="latin-1"):
        p = line.split()
        if len(p) >= 2 and p[0].startswith("0x"):
            lab[p[1]] = int(p[0], 16)
    u32 = lambda a: struct.unpack_from("<I", d, a - B)[0]  # noqa: E731
    u16 = lambda a: struct.unpack_from("<H", d, a - B)[0]  # noqa: E731
    s8 = lambda a: d[a - B] - 256 * (d[a - B] > 127)  # noqa: E731
    names = collections.defaultdict(list)
    t1, t2 = lab["func_4863CDB5_Table"], lab["func_4863CDD8_Table"]
    for base, n in ((t1, (t2 - t1) // 4), (t2, 64)):
        for i in range(n):
            r = u32(base + 4 * i)
            if B <= r < B + len(d):
                nm = d[r - B:r - B + 17].split(b"\0")[0].decode("latin-1").strip()
                if nm not in names[u16(r + 0x12)]:
                    names[u16(r + 0x12)].append(nm)
    stats = collections.Counter()
    types = collections.defaultdict(list)          # descriptor -> the types (table indices) using it
    for i in range(N):
        types[u32(FXDESC_TABLE + 4 * i)].append(i)
    print("types     desc       mode  pnum9 / pnum10 / pnum11 (parameter names)     +0x1D==0 params | effect names")
    for a, ts in sorted(types.items(), key=lambda kv: kv[1][0]):
        i = ts[0]
        recs = []
        for j in range(d[a - B]):
            r = u32(a + 4) + 36 * j
            recs.append((d[r - B:r - B + 20].split(b"\0")[0].decode("latin-1"), u16(r + 20), d[r + 0x1D - B]))
        if not recs:
            continue
        mode, p9, p10, p11 = s8(a + 8), s8(a + 9), s8(a + 10), s8(a + 11)
        pn = lambda n: "-" if n < 0 else "/".join(sorted({x[0] for x in recs if x[1] == n})) or "#%d" % n  # noqa: E731
        scaled = sorted({x[0] for x in recs if x[2] == 0})
        stats["descriptors"] += 1
        stats["mode %d" % mode] += 1
        for key, v in (("pnum9", p9), ("pnum10", p10), ("pnum11", p11)):
            stats["%s %s" % (key, "set" if v >= 0 else "-1")] += 1
            if v >= 0:
                stats["%s -> %s" % (key, pn(v))] += 1
        stats["with +0x1D==0 params"] += bool(scaled)
        tl = ",".join(map(str, ts)) if len(ts) < 4 else "%d..(%d)" % (ts[0], len(ts))
        nm = sorted({n for t in ts for n in names.get(t, [])})[:4]
        print("%-9s 0x%08X %d  %-16s / %-6s / %-6s  %-28s | %s" % (
            tl, a, mode, pn(p9), pn(p10), pn(p11), ",".join(scaled), "/".join(nm)))
    print()
    for k in sorted(stats):
        print("  %-36s %d" % (k, stats[k]))


if __name__ == "__main__":
    main()
