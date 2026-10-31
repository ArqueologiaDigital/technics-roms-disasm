#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""kss_bgscreen_ids.py -- what KssBgScreen's image_id and icon (the SP7001 plug-in) can name in 942.

QUESTION ANSWERED: "are the values of the plug-in's KssBgScreen fields image_id (32872 = 0x8068) and
icon (1) ids of program 942's resource-id trie, and what does icon 1 draw?"  It
  1. walks 942's resource-id trie as func_4C01BB1A (lib 0x4C01BB1A) does -- from the root table,
     a nibble of the 24-bit id per level from bit 20, 8-byte entries {target, inner, count}, a
     leaf's +0 holding the id -- and lists whether each value is a leaf id;
  2. reads 942's table-flash directory (TableRomDirectory: InitializeResource stores +8 as
     IconTablePtr, which DrawIcons_Impl indexes with 8-byte entries {u16 w, u16 h, pixels}) and
     prints icon entry 1, the one DrawTitleBar -> DrawIcons draws for MT_GetIcon = 1;
  3. counts every access at displacement 0x28 in the plug-in's code (src/sp7001/table.s, the
     functions at 0x483E8000..) whose width is 16 bits: image_id is a u16 at +0x28 of the record.

RUN (from kn7000/):  python3 notes/mn10300-formats-probes/kss_bgscreen_ids.py
"""
import os
import re
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
KN7 = os.path.normpath(os.path.join(HERE, "..", ".."))
PROG = os.path.join(KN7, "baserom", "kn7000_program_sp7001.rom")
TABLE = os.path.join(KN7, "baserom", "kn7000_table_sp7001.rom")
PB, TB = 0x48400000, 0x48000000


def label(name, sym):
    for line in open(os.path.join(KN7, sym), encoding="latin-1"):
        p = line.split()
        if len(p) >= 2 and p[1] == name:
            return int(p[0], 16)
    raise SystemExit(f"{name} not in {sym}")


def main():
    rom = open(PROG, "rb").read()
    u32 = lambda a: struct.unpack_from("<I", rom, a - PB)[0]  # noqa: E731
    # the trie walker's root: func_4C01BB1A loads `mov ResourceIdTrieNode_X+N, d2`
    # (`mov d0, d3 / mov 0x14, d0 / mov Root, d2 / setlb`: the walker's start, whatever the build calls it)
    m = None
    for f in sorted(os.listdir(os.path.join(KN7, "src", "sp7001", "program"))):
        if f.endswith(".s"):
            src = open(os.path.join(KN7, "src", "sp7001", "program", f), encoding="latin-1").read()
            m = m or re.search(r"mov\s+d0, d3\n\s+mov\s+0x14, d0\n\s+mov\s+(\w+)\+?(\d*), d2\n\s+setlb", src)
    root = label(m.group(1), "src/sp7001/program/data/labels.sym") + int(m.group(2) or 0)
    ids = {}

    def walk(t, n, shift):
        if shift < 0:
            return
        for i in range(n):
            e = t + 8 * i
            tg = u32(e)
            if not tg:
                continue
            if rom[e + 4 - PB] == 0:
                ids[u32(tg)] = tg
            else:
                walk(tg, rom[e + 5 - PB], shift - 4)
    walk(root, 16, 20)
    print(f"942 resource-id trie: root 0x{root:08X}, {len(ids)} leaves")
    for v in (0x8068, 1):
        print(f"  id 0x{v:06X}: " + (f"leaf at 0x{ids[v]:08X}" if v in ids else "no such id"))
    t = open(TABLE, "rb").read()
    d = struct.unpack_from("<I", t, 0)[0]
    # (the table's directory: TableRomDirectory is the table flash's first word, an offset from it)
    icon_tab = struct.unpack_from("<I", t, d + 8)[0]
    w, h, px = struct.unpack_from("<HHI", t, icon_tab - TB + 8 * 1)
    print(f"icon 1: ResIconTable 0x{icon_tab:08X} entry 1 = {w} x {h} at 0x{px:08X}"
          " (src/table/gui/icon_001.png)")
    code = open(os.path.join(KN7, "src", "sp7001", "table.s"), encoding="latin-1").read().split("\n")
    cur, n16, n28 = None, 0, 0
    for ln in code:
        m = re.match(r"# (\S+)\s+\(CPU 0x(483[eEfF][0-9a-fA-F]{4})\)", ln)
        if m:
            cur = m.group(1)
        if cur and re.search(r"\(0x28, a\d\)", ln):
            n28 += 1
            n16 += bool(re.match(r"\s+movhu", ln))
    print(f"plug-in code: {n28} accesses at (0x28, aN), {n16} of them 16-bit")


if __name__ == "__main__":
    main()
