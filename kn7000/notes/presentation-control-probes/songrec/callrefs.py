#!/usr/bin/env python3
"""callrefs.py -- question: who calls a given address? Lists call sites in disasm/program.asm with the
nearest preceding named symbol (kn7000.sym, kn7000_manual.sym, kn7000_exports_from_942.sym)."""
import re, sys, bisect
D = "/home/fsanches/compartilhado/technics-roms-disasm/kn7000/"
syms = {}
for f in ("kn7000.sym", "kn7000_manual.sym", "kn7000_exports_from_942.sym"):
    for ln in open(D + f):
        p = ln.split()
        if len(p) >= 2 and p[0].startswith("0x"):
            try: syms[int(p[0], 16)] = p[1]
            except ValueError: pass
keys = sorted(syms)
tg = {int(x, 16) for x in sys.argv[1:]}
pat = re.compile(r"^([0-9a-f]{8}): .*\bcall +0x([0-9a-f]+)")
for ln in open(D + "disasm/program.asm"):
    m = pat.match(ln)
    if m and int(m.group(2), 16) in tg:
        a = int(m.group(1), 16); k = bisect.bisect_right(keys, a) - 1
        print(f"{a:08x} -> {m.group(2)}  in {syms[keys[k]]}+{a-keys[k]:#x}")
