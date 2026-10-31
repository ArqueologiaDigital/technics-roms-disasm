#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""tg_side_bits.py -- which tone generator, MAIN or SUB, a 'JK' zone's side bits 0x400 / 0x800 pick.

QUESTION IT ANSWERS: "TgVoiceSideSelect (0x4C02BECB) takes a zone's halfword +0 & 0x0C00; which
TG does each bit select, and does every zone's selected TG hold the wave entry (page, entry) the
zone names?"  It prints:
  1. the code chain, checked by matching the instructions in src/program/library_01.s:
     TgElemRequestFlags `btst 0x0400` -> `or 0x08` and `btst 0x0800` -> `or 0x10`;
     TgVoiceNodePick `cmp 8` -> TgNodeScanSideA, else TgNodeScanSideB;
     TgNodeScanSideA keeps hw slots `cmp 0x40` below 0x40;
     TgVoiceRegWrite sends slots < 0x40 to 0x98050000, the others to 0x98040000
     (the MAIN TG = 0x98050000 = IC203/IC204, notes/wave-rom-port.md, read on hardware 2026-10-19);
  2. for every zone of src/table/voices/internal_archive.s (jk_zone6 / jk_zone8: the zone lists and
     JkKitZones), side = (flags byte >> 2) & 3, against the Main_Ppp_Eeee / Sub_Ppp_Eeee labels of
     src/wave/main.s / sub.s, counted for the reading "0x400 = MAIN, 0x800 = SUB" and for the swap.
Signal: "0x400=MAIN: agree N, disagree 0".

RUN (from the repository root):  python3 -I kn7000/notes/mn10300-rest-probes/tg_side_bits.py
"""
import collections
import os
import re

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
K = os.path.join(ROOT, "kn7000")


def routine(lines, name):
    i = lines.index(name + ":")
    out = []
    for ln in lines[i + 1:]:
        if re.match(r"^# \w+  \(lib CPU", ln):
            break
        out.append(ln.strip())
    return " | ".join(re.sub(r"\s+", " ", x) for x in out)


def main():
    lib = open(os.path.join(K, "src", "program", "library_01.s"), "rb").read().decode("latin-1").split("\n")
    checks = [
        ("TgVoiceSideSelect", [r"cmp 1, d0 \| beq (loc_\w+)", r"mov 0x400, d0", r"mov 0x800, d0", r"and 0x0c00, d0"]),
        ("TgElemRequestFlags", [r"btst 0x0400, d0 \| beq loc_\w+ \| movbu \(a0\), d1 \| or 0x08, d1",
                                r"btst 0x0800, d0 \| beq loc_\w+ \| movbu \(a0\), d1 \| or 0x10, d1"]),
        ("TgVoiceNodePick", [r"mov TgNodeScanSideA, a3 \| cmp 8, d0 \| beq loc_\w+ \| mov TgNodeScanSideB, a3"]),
        ("TgNodeScanSideA", [r"movbu \(0x29, a0\), d0 \| cmp 0x40, d0 \| bge"]),
        ("TgNodeScanSideB", [r"movbu \(0x29, a0\), d0 \| cmp 0x40, d0 \| blt"]),
        ("TgVoiceRegWrite", [r"cmp 0x40, d0 \| bge loc_\w+", r"movhu d1, \(0x98050000\)", r"movhu d1, \(0x98040000\)"]),
    ]
    for name, pats in checks:
        body = routine(lib, name)
        for p in pats:
            print(f"  {name:20s} {'found' if re.search(p, body) else 'MISSING'}: {p}")
    wave = {}
    for tg in ("Main", "Sub"):
        wave[tg] = set()
        for ln in open(os.path.join(K, "src", "wave", tg.lower() + ".s"), "rb"):
            m = re.match(rb"(?:Main|Sub)_P([0-9A-F]{2})_E([0-9A-F]{3}):", ln)
            if m:
                wave[tg].add((int(m.group(1), 16), int(m.group(2), 16)))
    print(f"wave directory entries: Main {len(wave['Main'])}, Sub {len(wave['Sub'])}")
    sec, cnt = "zone lists", collections.Counter()
    for ln in open(os.path.join(K, "src", "table", "voices", "internal_archive.s"), "rb"):
        if ln.startswith(b"JkKitZones:"):
            sec = "JkKitZones"
        m = re.match(rb"\s+jk_zone[68]\s+0x([0-9a-f]+), 0x([0-9a-f]+), 0x([0-9a-f]+)", ln)
        if m:
            page, fl, ent = (int(x, 16) for x in m.groups())
            cnt[(sec, (fl >> 2) & 3, (page, ent) in wave["Main"], (page, ent) in wave["Sub"])] += 1
    print("zones by (where, side bits 0x0C00 >> 10, in Main, in Sub):")
    for k in sorted(cnt):
        print(f"  {k[0]:10s} side {k[1]}  Main {'y' if k[2] else 'n'}  Sub {'y' if k[3] else 'n'}  {cnt[k]:5d}")
    for label, m1, m2 in (("0x400=MAIN, 0x800=SUB", 2, 3), ("0x400=SUB, 0x800=MAIN (swap)", 3, 2)):
        ok = bad = 0
        for (sec, side, im, isb), n in cnt.items():
            have = {1: (im, isb)[m1 - 2], 2: (im, isb)[m2 - 2], 3: im and isb, 0: False}[side]
            ok, bad = (ok + n, bad) if have else (ok, bad + n)
        print(f"{label}: agree {ok}, disagree {bad}")


if __name__ == "__main__":
    main()
