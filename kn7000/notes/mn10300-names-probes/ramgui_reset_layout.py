#!/usr/bin/env python3
"""ramgui_reset_layout: where does each KN7000 program build (941, 942, 935, 893) put its
boot stack, .data and .bss, as its reset code sets them up?

Reads ResetEntry .. the stub writes in each build's byte-exact source
(src/<build>/region1_00.s) and prints: INITIAL_SP, the .bss clear (start, length, end),
the second clear, the .data copy (ROM source, RAM destination, length, end).  Expected
(2026-11-02): .data starts at 0x50000010 and the .bss clear ends at 0x50180000 in all
four builds; INITIAL_SP is 0x50021CF8 / 0x50021D08 / 0x50021CCC / 0x50021CC8.

usage (from kn7000/):
  python3 -I notes/mn10300-names-probes/ramgui_reset_layout.py
"""
import re

BUILDS = {"941": "src/program", "942": "src/sp7001/program", "935": "src/b935/program",
          "893": "src/b893/program"}
SYM = {"941": "src/symbols.inc", "942": "src/sp7001/symbols.inc", "935": "src/b935/symbols.inc",
       "893": "src/b893/symbols.inc"}
LAB = {b: d + "/data/labels.sym" for b, d in BUILDS.items()}

for b, d in BUILDS.items():
    L = open(d + "/region1_00.s", "rb").read().decode("latin-1").split("\n")
    i = next(k for k, x in enumerate(L) if x.startswith("ResetEntry:"))
    eq = dict(re.findall(r"\.equ (\w+), (0x[0-9A-Fa-f]+)", open(SYM[b]).read()))
    for ln in open(LAB[b]):
        p = ln.split()
        if len(p) >= 2 and p[0].startswith("0x5000"):
            eq.setdefault(p[1], p[0])
    val = lambda t: int(eq.get(t, t), 0)
    movs = []
    j = next(k for k in range(i, i + 120) if re.match(r"\s+mov\s+a0, sp$", L[k]))
    sp = val(re.match(r"\s+mov\s+(\w+), a0$", L[j - 1]).group(1))    # mov INITIAL_SP, a0 / mov a0, sp
    for x in L[j + 1:j + 120]:
        m = re.match(r"\s+mov\s+(\w+), (a0|a1|d1)$", x)
        if m:
            movs.append((m.group(2), m.group(1)))
        if "0x90000000" in x:
            break
    # the three loops: (d1 = length, a0 = start) x2, then (d1 = length, a0 = ROM, a1 = RAM)
    seq = [(r, val(v)) for r, v in movs]
    n1, s1, n2, s2, n3, rom, ram = [v for _, v in seq[:7]]
    print(f"{b}: INITIAL_SP {sp:#010x} | .bss clear {s1:#010x} + {n1:#x} = {s1 + n1:#010x} | "
          f"clear {s2:#010x} + {n2:#x} = {s2 + n2:#010x} | .data {rom:#010x} -> {ram:#010x} + {n3:#x} = {ram + n3:#010x}")
