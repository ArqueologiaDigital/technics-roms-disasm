#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Every figure in notes/ic18-rhythm-rom.md about the layout and the contents of
# IC18's "Technics Rhythms" resource, measured on the chip image. It reads the
# resource the way program 941 does (StyleBuiltinNameTableInit,
# StyleBuiltinNameResolve, StyleNameCommit, StyleRecordBindBuiltin,
# RhyEventLenByStatus) and checks, without assuming them:
#
#   * the header fields, the checksum (SumU16BE) and the count block;
#   * the 2048-entry style-ID index: how many entries are styles of this table,
#     aliases, or table-ROM styles, and that every ID resolves;
#   * that the count-in patterns, the 169 styles and their 20 variations tile the
#     chip from 0x10000 with no gap or overlap, and in which slot order;
#   * that every event stream parses with RhyEventLenByStatus's lengths, opens with
#     0xF4, ends with 0xF5 and holds (bars x beats) 0xF4 markers;
#   * that the bytes below 0x80 between events are tick positions 0..95, rising
#     within a beat (the reason for "96 ticks a beat");
#   * event and controller counts, the last byte of the note events per part,
#     the bar counts per slot, the per-part constants of the part set-ups;
#   * what lies past the last style, and the version string.
#
#   python3 -I ic18_rhythm_probe.py ~/compartilhado/technics_romsets/kn7000/c3cbnd000046.ic18 \
#       [--program kn7000/baserom/kn7000_program.rom]
#
# With --program (program 941), it also maps each style to its rhythm group and
# style-ID through RhythmGenreNameTable 0x48735EE4.
import argparse
import struct
from collections import Counter, defaultdict

ap = argparse.ArgumentParser()
ap.add_argument("rom")
ap.add_argument("--program")
ap.add_argument("--table", help="table 84 (kn7000_table.rom): compare its copy of the header")
ap.add_argument("--source", help="the src/ic18 directory: also measure its text against the bytes")
a = ap.parse_args()
d = open(a.rom, "rb").read()
B = 0x10000


def u16(o):
    return (d[o] << 8) | d[o + 1]


def u24(o):
    return (d[o] << 16) | (d[o + 1] << 8) | d[o + 2]


def evlen(o):
    s = d[o]
    if s == 0xF0:
        return d[o + 1] + 2
    return {0x90: 6, 0xB0: 3, 0xC0: 4, 0xD0: 2, 0xE0: 3}.get(s & 0xF0, 1)


print("== header")
print("signature", d[B:B + 16])
ck, cks, ckl = u16(B + 0x10), u24(B + 0x12), u24(B + 0x15)
calc = sum(struct.unpack_from(f">{ckl}H", d, B + cks)) & 0xFFFF
print(f"checksum 0x{ck:04x}, over {ckl:#x} halfwords from +{cks:#x} (file {B + cks:#x}): "
      f"recomputed 0x{calc:04x} {'equal' if calc == ck else 'DIFFERENT'}")
offs = {n: u24(B + o) for n, o in [("count block", 0x18), ("index", 0x1B), ("style table", 0x1E),
                                   ("count-in table", 0x21), ("fallback", 0x24)]}
print("offsets", {k: hex(v) for k, v in offs.items()})
cb = B + offs["count block"]
print("count block", d[cb:B + offs["index"]].hex(" "), f"-> count {u16(cb + 2)}, then {u16(cb + 4)}")
count = u16(cb + 2)
nst = (offs["count-in table"] - offs["style table"]) // 3
styles = [u24(B + offs["style table"] + 3 * i) for i in range(nst)]
idx = [u16(B + offs["index"] + 2 * i) for i in range(0x800)]
print(f"style table: {nst} entries; first = fallback: {styles[0] == offs['fallback']}")

print("== the style-ID index")
kinds = Counter("style" if e < count else ("alias" if e >> 14 == 2 else ("table ROM" if e >> 14 == 1 else "other"))
                for e in idx)
print(dict(kinds))
plain = [e for e in idx if e < count]
print(f"style entries name {len(set(plain))} distinct styles, max {max(plain)}; each once: {len(plain) == len(set(plain))}")
tab = sorted(e & 0x3FFF for e in idx if e >> 14 == 1)
print(f"table-ROM entries name styles {tab[0]}..{tab[-1]}, {len(set(tab))} distinct")
unres = 0
for e in idx:
    if e >> 14 == 2:
        e = idx[e & 0x7FF]
    if not (e < nst or e >> 14 == 1):
        unres += 1
print(f"IDs that resolve to no style after one alias hop: {unres}")

print("== tiling")
cov = bytearray(len(d))


def mark(s, e):
    for i in range(s, e):
        cov[i] += 1


mark(B, B + offs["count-in table"] + 24)
bars_by_slot = defaultdict(Counter)
meter = Counter()
events = Counter()
ctls = Counter()
rule_by_part = defaultdict(Counter)
setup_ev = Counter()
pos_bytes = pos_max = pos_back = 0
streams = bad = 0


head_bytes = Counter()
stream_bytes = Counter()


def var(o, slot=None, kind="style"):
    global pos_bytes, pos_max, pos_back, streams, bad
    bars, beats = d[o] + 1, d[o + 1] + 1
    L = u16(o + 4)
    head_bytes[kind] += 9 + L
    stream_bytes[kind] += u24(o + 6 + L)
    S = u24(o + 6 + L)
    s, e = o + 9 + L, o + 9 + L + S
    mark(o, e)
    p = o + 6
    while p < o + 6 + L:
        setup_ev[d[p] & 0xF0] += 1
        p += evlen(p)
    if p != o + 6 + L:
        bad += 1
    p, n4, last = s, 0, -1
    while p < e:
        c = d[p]
        if c == 0xF4:
            n4, last = n4 + 1, -1
        elif c < 0x80:
            pos_bytes += 1
            pos_max = max(pos_max, c)
            pos_back += c < last
            last = c
        if c >= 0x80:
            events[c if c >= 0xF0 else c & 0xF0] += 1
        if c & 0xF0 == 0xB0:
            ctls[d[p + 1]] += 1
        if c & 0xF0 == 0x90:
            rule_by_part[c & 15][d[p + 5]] += 1
        if c not in (0xF0, 0xF4, 0xF5) and c >= 0x80 and any(x >= 0x80 for x in d[p + 1:p + evlen(p)]):
            bad += 1
        p += evlen(p)
    streams += 1
    if p != e or d[s] != 0xF4 or d[e - 1] != 0xF5 or n4 != bars * beats:
        bad += 1
    if slot is not None:
        bars_by_slot[slot][bars] += 1
    meter[beats] += 1
    return e


for k in range(8):
    var(B + u24(B + offs["count-in table"] + 3 * k), kind="count-in")
orders = Counter()
for i, r in enumerate(styles):
    o = B + r
    mark(o, o + 0xC6)
    so = [u24(o + 0x8A + 3 * j) for j in range(20)]
    orders[tuple(sorted(range(20), key=lambda j: so[j]))] += 1
    for j in range(20):
        var(o + so[j], j)
end = max(i for i in range(B, len(d)) if cov[i]) + 1
gaps = sum(1 for i in range(B, end) if not cov[i])
over = sum(1 for i in range(B, end) if cov[i] > 1)
print(f"styles + count-ins cover {B:#x}..{end:#x}: {gaps} bytes uncovered, {over} covered twice")
print(f"{streams} streams; malformed: {bad}")
print("slot order in the chip:", orders.most_common(1)[0][0], f"({orders.most_common(1)[0][1]} styles)")
print("beats a bar over all streams:", dict(meter))
for j in range(20):
    print(f"  slot {j:2d} bars", dict(sorted(bars_by_slot[j].items())))
print(f"position bytes: {pos_bytes}, max {pos_max}, falling within a beat: {pos_back}")
print("events:", {hex(k): v for k, v in sorted(events.items())})
print("set-up events by status:", {hex(k): v for k, v in sorted(setup_ev.items())})
print("controllers in streams:", dict(sorted(ctls.items())))
for p in sorted(rule_by_part):
    print(f"  note last byte, part {p}:", rule_by_part[p].most_common(5))

print("== part set-ups")
for f in range(15):
    vals = Counter(d[B + r + 0x11 + 15 * p + f] for r in styles for p in range(8))
    print(f"  byte {f:2d}:", vals.most_common(6))
for p in range(8):
    print(f"  part {p}: mode", Counter(d[B + r + 0x11 + 15 * p] for r in styles).most_common(3),
          "bank_msb", Counter(d[B + r + 0x11 + 15 * p + 4] for r in styles).most_common(3))
print("part 1 byte 2 (program):", Counter(d[B + r + 0x11 + 15 + 2] for r in styles).most_common(4))
print("style +0x0D..+0x10 (sound-unit keys):", Counter(d[B + r + 13:B + r + 17].hex() for r in styles).most_common(4))
print("style byte +0x89:", Counter(d[B + r + 0x89] for r in styles))
print("variation bytes +2/+3:", Counter(d[B + r + u24(B + r + 0x8A + 3 * j) + 2:B + r + u24(B + r + 0x8A + 3 * j) + 4].hex()
                                        for r in styles for j in range(20)).most_common(8))

print("== past the last style")
used = len(d[:0x3FFFE8].rstrip(b"\xff"))
print(f"last style ends {end:#x}; non-0xFF bytes up to {used:#x} ({used - end} bytes); then 0xFF to 0x3FFFE8")
p = d.index(b"\xf5", end) + 1
print(f"  a stream tail {end:#x}..{p:#x}")
k = 0
while p < used:
    o = p
    try:
        L = u16(o + 4)
        S = u24(o + 6 + L)
        e = o + 9 + L + S
        ok = d[o + 2] == 0xFF and e <= used and d[o + 9 + L] == 0xF4 and d[e - 1] == 0xF5
    except IndexError:
        ok = False
    if not ok:
        break
    print(f"  variation record {o:#x}..{e:#x}: {d[o] + 1} bars of {d[o + 1] + 1}")
    p, k = e, k + 1
lo, hi = d.index(b"\xf5", end) + 1, p
q, uniq = lo, 0
while q < hi:
    L = u16(q + 4)
    S = u24(q + 6 + L)
    st = d[q + 9 + L:q + 9 + L + S]
    uniq += d.count(st) == 1
    q += 9 + L + S
print(f"  of those {k} records' streams, {uniq} occur nowhere else in the chip")
f1 = d.index(b"\xf5", p) + 1
print(f"  then {p:#x}..{f1:#x} and {f1:#x}..{used:#x}; the second = the last {used - f1} bytes of the first: "
      f"{d[f1:used] == d[f1 - (used - f1):f1]}")
print("top of chip:", d[0x3FFFE8:0x400000])
print("== bytes by representation")
rows = [("header, count block, index, tables", offs["count-in table"] + 24),
        ("169 style records (0xC6 each)", 0xC6 * nst),
        ("variation headers + set-up events (styles)", head_bytes["style"]),
        ("event streams of the styles", stream_bytes["style"]),
        ("the leftovers, whole", used - end),
        ("count-in patterns, whole", (B + styles[0]) - (B + offs["count-in table"] + 24)),
        ("erased + version string", 0x400000 - used)]
for n, v in rows:
    print(f"  {n:48s} {v:9,d}")
total = sum(v for _, v in rows)
print(f"  {'sum':48s} {total:9,d} of {0x400000 - B:,d} bytes from 0x10000")
if a.table:
    t = open(a.table, "rb").read()
    to = t.find(b"Technics Rhythms")
    n = len(t) - to
    diff = [i for i in range(n) if t[to + i] != d[B + i]]
    print(f"table ROM copy at file {to:#x}, {n:#x} bytes: differs from IC18 in {len(diff)} bytes at",
          [hex(i) for i in diff], f"count {(t[to + 0x29] << 8) | t[to + 0x2A]}")
if a.source:
    import os
    import re
    files = [os.path.join(a.source, f) for f in ("rhythm.s", "old_build.s")]
    for root, _, fs in os.walk(os.path.join(a.source, "styles")):
        files += [os.path.join(root, f) for f in fs if f.endswith(".s")]
    text = lines = incbins = 0
    for f in files:
        b = open(f, "rb").read()
        text += len(b)
        lines += b.count(b"\n")
        incbins += len(re.findall(rb"^\s*(?:\S+:\s*)?\.incbin", b, re.M))
    nstyle = len(files) - 2
    print(f"  {a.source}: {len(files)} files ({nstyle} style files), {lines:,d} lines, {text:,d} bytes of text"
          f" for {0x400000 - B:,d} bytes: {text / (0x400000 - B):.2f}x; .incbin lines: {incbins}")
if a.program:
    prog = open(a.program, "rb").read()
    PB, go = 0x48400000, 0x48735EE4 - 0x48400000
    seen, total = {}, 0
    for g in range(16):
        rec = prog[go + g * 0x18:go + g * 0x18 + 0x18]
        n, ptr = rec[0x11], struct.unpack_from("<I", rec, 0x14)[0] - PB
        name = rec[:16].decode().strip()
        here = Counter()
        for i in range(n):
            sid = struct.unpack_from("<I", prog, ptr + 4 * i)[0]
            if sid & 0x00700000:            # MEMORY / CUSTOM source (StyleNameSourceSet)
                here["other source"] += 1
                continue
            e = idx[((sid & 0xF00) >> 1) | (sid & 0x7F)]
            if e >> 14 == 2:
                e = idx[e & 0x7FF]
            if e < nst:
                here["IC18"] += 1
                seen.setdefault(e, name)
            elif e >> 14 == 1:
                here["table ROM"] += 1
        total += n
        print(f"  group {g:2d} {name:16s} {n:2d} rhythms: {dict(here)}")
    print(f"{total} rhythms in the groups; {len(seen)} of the {nst} IC18 styles are in one;"
          f" group order = chip order: {[seen[i] for i in range(nst)] == sorted([seen[i] for i in range(nst)], key=lambda x: list(dict.fromkeys(seen[j] for j in range(nst))).index(x))}")
