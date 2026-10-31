#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""kn2400_fx_streams.py -- the KN2400's effect-DSP download streams, parameter scripts and address maps.

QUESTION IT ANSWERS: "what are the `7c aa aa 7d 55 55 ...` byte streams of the KN2400 v1.1 program
data at 0x48533EAC..0x48541618, how far does the family extend, how many blocks are there, which
effect type owns each, and which code reads them?"

The streams are read through pointer tables, never by a direct load, which is why the data typer's
reader search marked them opaque.  The readers (RAM-linked code, linked at 0x50120000):

  * func_50189F4E (d0 = DSP type, d1 = unit 0..5): a0 = type ? func_50185B0C_entry_L1c_Table[type]
    (0x48541630) : func_50189F4E_entry_Lf_Table[unit] (0x48541FF8), `mov (d0, a0), d1` at 0x50189F6A
    / 0x50189F7A, then func_5018A213 -> func_5018A345, the PROGRAM-STREAM interpreter: it loads the
    record byte at 0x5018A358 (`movbu (a0), d0`) and compares it with 0xFB / 0xFC / 0xFD / 0xF7 /
    0xFE at 0x5018A366..0x5018A389; 0xFF ends the stream.  Boot: func_501854DA calls func_50189F14
    (data_485340C5) and func_50189EF7 (data_48533EAC); the script kind 0x79 calls func_50189F31
    (data_4853F0CF).
  * func_5018A267 (d0 = unit, d1 = type, param number on the stack): a0 = func_501866EE_Table,
    a1 = func_5018A267_Table_2[type] (ADDRESS MAP), script = func_5018A267_Table[type] (PARAMETER
    SCRIPT); func_5018A724 -> func_5018AEA6 skips to group[param] (`movbu (a0), d1` 0x5018AEEA,
    end at a high byte of 0xFF, 0x5018AEFB); func_5018A7B8 runs its entries (kind byte, end 0x7A
    at 0x5018ADC5), func_5018AE27 finds the kind's group in the address map (0x5018AE3A).
  * func_50185F06 (queue flush): coefficient 0x68 with value 0 / 1 / 2 downloads data_485414AD /
    data_48541522 / data_48541597, coefficient 0x8D with value 3 / 4 / 5 data_4854160C / 10 / 14,
    through func_5018A23D -> func_5018A64E (an 0xFD-only interpreter).

Program stream record kinds (func_5018A345; len12 = (b1 & 0x0F) << 8 | b2 counts the whole record):
  0xFB len12, (len-3) bytes   sent raw after a 12-byte command (func_5018A2C1), bracketed by cmd 0x0C / 0x05
  0xFC len12, (len-3)/4 words of 4 bytes, each to program step base[unit]+i (func_5018AFD0)
  0xFD len12, u16 BE start, (len-5)/3 u24 BE values, burst-written to start, start+1, ... (func_5018B0F2)
  0xF7 len12, u16 BE start, (len-5)/3 u24 BE values, each written after register 0xFF = its address
  0xFE {u16 BE reg, u24 BE value} pairs until a byte >= 0xFB (func_5018B18A: reg 0xFF = reg, 0x1FF = value)
  0xFF end
Parameter script: groups {u16 BE len (incl. itself), entries..., 0x7A}, one per parameter number,
ended by 0xFF; an entry is {u8 kind, u8 index, operands}.  Address map: groups {u16 BE len, u8 kind,
u16 BE address x n}, ended by 0xFF.

RUN (from the repository root):  python3 -I kn7000/notes/mn10300-rest-probes/kn2400_fx_streams.py [--blocks]
"""
import collections
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
ROM = os.path.join(ROOT, "kn2400", "baserom", "kn2400_program.rom")
LABELS = os.path.join(ROOT, "kn2400", "src", "program", "data", "labels.sym")
B = 0x48400000
NTYPES = 208          # func_50185B0C: `cmp 0xcf, d0` before indexing the table
# operand bytes per script kind (after the index byte), from the converters' pointer advance;
# 0x70 and 0x76 have a first operand byte whose low nibble adds bytes (func_501884FA, func_5018909C)
OPS = {0x21: 6, 0x23: 1, 0x24: 1, 0x25: 0, 0x40: 0, 0x61: 1, 0x62: 1, 0x63: 1, 0x64: 6, 0x65: 1, 0x66: 6, 0x67: 3,
       0x68: 3, 0x69: 0, 0x6A: 1, 0x6B: 6, 0x6C: 6, 0x6D: 0, 0x6E: 1, 0x6F: 0, 0x71: 0, 0x72: 1,
       0x73: 6, 0x74: 1, 0x75: 4, 0x78: 4, 0x79: 0}


def main():
    d = open(ROM, "rb").read()
    lab = {}
    for line in open(LABELS, encoding="latin-1"):
        p = line.split()
        if len(p) >= 2 and p[0].startswith("0x"):
            lab[p[1]] = int(p[0], 16)
    u32 = lambda a: struct.unpack_from("<I", d, a - B)[0]  # noqa: E731
    u16 = lambda a: struct.unpack_from("<H", d, a - B)[0]  # noqa: E731
    by = lambda a: d[a - B]  # noqa: E731
    tab = lambda name, n: [u32(lab[name] + 4 * i) for i in range(n)]  # noqa: E731

    def prog(a):
        recs, p = [], a
        while by(p) != 0xFF:
            op = by(p)
            if op in (0xFB, 0xFC, 0xFD, 0xF7):
                ln = (by(p + 1) & 15) << 8 | by(p + 2)
                n = {0xFB: ln - 3, 0xFC: (ln - 3) // 4}.get(op, (ln - 5) // 3)
                recs.append((op, p, ln, n))
                p += ln
            elif op == 0xFE:
                q = p + 1
                while by(q) < 0xFB:
                    q += 5
                recs.append((op, p, q - p, (q - p - 1) // 5))
                p = q
            else:
                return recs, None
        return recs, p + 1

    def groups(a):
        g, p = [], a
        while by(p) != 0xFF:
            ln = by(p) << 8 | by(p + 1)
            if ln < 3 or ln > 0x800:
                return g, None
            g.append((p, ln))
            p += ln
        return g, p + 1

    def entries(body):          # one script group body, after the u16 length
        out, i = [], 0
        while i < len(body):
            k = body[i]
            if k == 0x7A:
                out.append("end")
                i += 1
                continue
            if i + 1 >= len(body):
                return out, False
            if k == 0x70:
                n = 1 + {1: 1, 3: 2}.get(body[i + 2] & 15, 0)
            elif k == 0x76:
                n = 1 + (body[i + 2] & 15 == 2)
            elif k in OPS:
                n = OPS[k]
            else:
                return out, False
            out.append(k)
            i += 2 + n
        return out, i == len(body) and body[-1] == 0x7A

    # effect names per DSP type: the 44/48-byte effect records func_4863CDB5 / func_4863CDD8
    # answer hold the type (= FxDescTable index) at +0x12 (FxDescIndexGet `movhu (0x12, a0), d0`)
    names = collections.defaultdict(list)
    t1, t2 = lab["func_4863CDB5_Table"], lab["func_4863CDD8_Table"]
    for base, n in ((t1, (t2 - t1) // 4), (t2, 64)):
        for i in range(n):
            r = u32(base + 4 * i)
            if B <= r < B + len(d):
                nm = d[r - B:r - B + 17].split(b"\0")[0].decode("latin-1").strip()
                if nm not in names[u16(r + 0x12)]:
                    names[u16(r + 0x12)].append(nm)

    # the units a type may load on: func_50185A10 (d0 = unit, d1 = type) reads one 208-byte table per
    # unit (`movbu (d0, a0), d0`); unit 4 has no table and takes type 0x4F only (`cmp 0x4f, d0`)
    utab = ["func_50185A10_Table", "func_50185A10_Table_2", "func_50185A10_Table_3",
            "func_50185A10_Table_4", None, "func_50185A10_Table_5"]
    units = collections.defaultdict(set)
    for u, name in enumerate(utab):
        for t in range(NTYPES):
            if (by(lab[name] + t) if name else t == 0x4F):
                units[t].add(u)

    blocks = collections.defaultdict(set)
    for i, a in enumerate(tab("func_50185B0C_entry_L1c_Table", NTYPES)):
        if a:
            blocks[(a, "program")].add(i)
    for i, a in enumerate(tab("func_50189F4E_entry_Lf_Table", 6)):
        blocks[(a, "program")].add("unit%d" % i)
    for i, a in enumerate(tab("func_5018A267_Table", NTYPES)):
        if a:
            blocks[(a, "script")].add(i)
    for i, a in enumerate(tab("func_5018A267_Table_2", NTYPES)):
        if a:
            blocks[(a, "map")].add(i)
    for n, why in (("data_48533EAC", "boot (func_50189EF7)"), ("data_485340C5", "boot (func_50189F14)"),
                   ("data_4853F0CF", "kind 0x79 (func_50189F31)"), ("data_485414AD", "coef 0x68 = 0"),
                   ("data_48541522", "coef 0x68 = 1"), ("data_48541597", "coef 0x68 = 2"),
                   ("data_4854160C", "coef 0x8D = 3"), ("data_48541610", "coef 0x8D = 4"),
                   ("data_48541614", "coef 0x8D = 5")):
        blocks[(lab[n], "program")].add(why)

    parsed = []
    for (a, kind), who in sorted(blocks.items()):
        recs, end = prog(a) if kind == "program" else groups(a)
        parsed.append([a, end, kind, recs, who, "pointed"])
    starts = sorted(p[0] for p in parsed)
    for p in parsed:            # a block that does not parse ends where the next pointed one starts
        if p[1] is None:
            p[1], p[5] = min(s for s in starts if s > p[0]), "malformed"
    # tile the extent and type what no pointer reaches
    lo, hi = min(p[0] for p in parsed), max(p[1] for p in parsed)
    cov = sorted((p[0], p[1]) for p in parsed)
    gaps, pos = [], lo
    for a, e in cov:
        if a > pos:
            gaps.append((pos, a))
        pos = max(pos, e)
    for g0, g1 in gaps:         # program if it parses as one, else a script if every group parses, else a map
        p = g0
        while p < g1:
            recs, end = prog(p)
            kind = "program"
            if not (end and end <= g1 and recs):
                recs, end = groups(p)
                kind = "script" if recs and all(entries(d[g - B + 2:g - B + n])[1] for g, n in recs) else "map"
            if not (end and end <= g1 and recs):
                parsed.append([p, g1, "?", [], set(), "unparsed"])
                break
            parsed.append([p, end, kind, recs, set(), "orphan"])
            p = end
    parsed.sort(key=lambda p: (p[0], p[2]))
    print("family extent 0x%08X..0x%08X (%d bytes); func_50189FF6_Table 0x%08X (37 bytes) sits inside"
          % (lo, hi, hi - lo, lab["func_50189FF6_Table"]))
    cnt = collections.Counter((p[2], p[5]) for p in parsed)
    for k in sorted(cnt):
        print("  %-8s %-8s %4d blocks" % (k[0], k[1], cnt[k]))
    print("  unparsed bytes:", sum((p[1] - p[0]) for p in parsed if p[2] == "?"),
          [("0x%08X" % p[0], p[1] - p[0]) for p in parsed if p[2] == "?"])

    rk = collections.Counter()
    for p in parsed:
        if p[2] == "program":
            for r in p[3]:
                rk["%02X records" % r[0]] += 1
                rk["%02X items" % r[0]] += r[3]
    print("program-stream records:", ", ".join("%s %d" % kv for kv in sorted(rk.items())))
    sk, bad, mk = collections.Counter(), [], collections.Counter()
    for p in parsed:
        if p[2] == "script":
            for g, ln in p[3]:
                ents, ok = entries(d[g - B + 2:g - B + ln])
                sk.update(e for e in ents if e != "end")
                if not ok:
                    bad.append((p[0], g, d[g - B:g - B + ln].hex(" ")))
        elif p[2] == "map":
            for g, ln in p[3]:
                mk[by(g + 2)] += 1
    print("script entries by kind:", ", ".join("%02X %d" % kv for kv in sorted(sk.items())))
    print("map groups by kind:   ", ", ".join("%02X %d" % kv for kv in sorted(mk.items())))
    print("script groups that do not parse (%d):" % len(bad))
    for blk, g, hx in bad:
        print("  block 0x%08X group 0x%08X  %s" % (blk, g, hx))
    if "--blocks" in sys.argv:
        for a, e, kind, recs, who, how in parsed:
            types = sorted(w for w in who if isinstance(w, int))
            other = sorted(w for w in who if not isinstance(w, int))
            nm = sorted({n for t in types for n in names.get(t, [])})[:3]
            summ = (" ".join("%02X" % r[0] for r in recs) if kind == "program"
                    else "%d groups" % len(recs))
            us = sorted({u for t in types for u in units[t]})
            print("0x%08X..0x%08X %5d %-7s %-9s types=%s units=%s %s %s | %s" % (
                a, e, e - a, kind, how, ",".join(map(str, types[:8])) + ("..%d" % len(types) if len(types) > 8 else "") or "-",
                "".join(map(str, us)) or "-", ",".join(other), "/".join(nm), summ))


if __name__ == "__main__":
    main()
