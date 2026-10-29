#!/usr/bin/env python3
"""Is the HD-AE5000 object table the preorder walk of the tree its links describe?

QUESTION: hdae5000_ui_tree.s writes the GUI as nesting and lets the macros compute every
object's index and its four Viewable links (+4 super, +6 sub, +8 next, +10 prev).  That
is only lossless if, in the ROM, (a) the links are consistent (sub's super is the owner,
next's prev is the object, siblings share a super), (b) top-level objects have no
siblings, and (c) walking each top-level object depth-first, children in next order,
and the top-level objects in index order, visits the indices 0, 1, 2 ... in order.
This reads the reference image only (object table located from the registration code by
port_hdae5000_version.ui_tables_of; RAM records read from the .data image through the
RAM pointer of the first one, 8 bytes after HDAE5000_WindowGeometry_Init).

RUN (repo root; needs the built ELF for the .data image's ROM address):
    python3 notes/data-gui-hdae5000-2026-10-29/probes/tree_preorder.py
PASS: "preorder == table order: True", 0 inconsistent links, 0 linked roots, per version.
Measured 2026-10-29: v2.06i 789 objects / 78 roots, v2.01i 786 / 78, both PASS.
"""
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
sys.path.insert(0, os.path.join(ROOT, "scripts", "tools"))
import port_hdae5000_version as P  # noqa: E402

BASE = 0x280000
NM = os.path.expanduser("~/compartilhado/llvm-project/build/bin/llvm-nm")
ok = True
for ver, elf in (("v2_06i", "hd-ae5000_v2_06i"), ("v2_01i", "hd-ae5000_v2_01i")):
    R = open(os.path.join(ROOT, "original_ROMs", "hd-ae5000_%s.ic4" % ver), "rb").read()
    syms = {f[2]: int(f[0], 16) for f in (l.split() for l in subprocess.run(
        [NM, os.path.join(ROOT, "rebuilt_ROMs", elf + ".llvm.elf")], capture_output=True,
        text=True).stdout.split("\n")) if len(f) == 3}
    u16 = lambda a: int.from_bytes(R[a - BASE:a - BASE + 2], "little")
    u32 = lambda a: int.from_bytes(R[a - BASE:a - BASE + 4], "little")
    ptrtab, nametab, n = P.ui_tables_of(R)
    ptr = [u32(ptrtab + 4 * i) for i in range(n)]
    img = syms["HDAE5000_DataSegmentImage"]
    ramb = min(p for p in ptr if p < BASE) - (syms["HDAE5000_WindowGeometry_Init"] + 8 - img)
    rec = lambda p: p if p >= BASE else p - ramb + img
    L = [[u16(rec(p) + o) for o in (4, 6, 8, 10)] for p in ptr]
    bad = 0
    for i, (sup, sub, nxt, prv) in enumerate(L):
        bad += sub != 0xFFFF and (L[sub][0] != i or L[sub][3] != 0xFFFF)
        bad += nxt != 0xFFFF and (L[nxt][3] != i or L[nxt][0] != sup)
        bad += prv != 0xFFFF and L[prv][2] != i
    roots = [i for i in range(n) if L[i][0] == 0xFFFF]
    linked = sum(1 for r in roots if L[r][2] != 0xFFFF or L[r][3] != 0xFFFF)
    order = []

    def walk(i):
        order.append(i)
        c = L[i][1]
        while c != 0xFFFF:
            walk(c)
            c = L[c][2]
    for r in roots:
        walk(r)
    pre = order == list(range(n))
    print("%s: %d objects, %d roots, %d inconsistent links, %d linked roots, preorder == table order: %s"
          % (ver, n, len(roots), bad, linked, pre))
    ok &= pre and not bad and not linked
print("PASS" if ok else "FAIL")
sys.exit(0 if ok else 1)
