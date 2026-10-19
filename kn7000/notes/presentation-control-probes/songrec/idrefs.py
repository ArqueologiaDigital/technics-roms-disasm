#!/usr/bin/env python3
"""idrefs.py -- question: which named functions load a given M3 parameter id as an immediate?
Scans disasm/program.asm for 'mov <id>, dN' (both 0x0000XXXX and short forms) and reports the
enclosing named symbol (nearest lower address in kn7000.sym / kn7000_manual.sym / exports)."""
import re, sys, bisect
D = "/home/fsanches/compartilhado/kn7000_disassembly/"
syms = {}
for f in ("kn7000.sym", "kn7000_manual.sym", "kn7000_exports_from_942.sym"):
    for ln in open(D + f):
        p = ln.split()
        if len(p) >= 2 and p[0].startswith("0x"):
            try: syms[int(p[0], 16)] = p[1]
            except ValueError: pass
keys = sorted(syms)
ids = [int(x, 16) for x in sys.argv[1:]]
pat = re.compile(r"^([0-9a-f]{8}): .*\bmov +0x([0-9a-f]+), d[0-3]")
hits = {i: [] for i in ids}
for ln in open(D + "disasm/program.asm"):
    m = pat.match(ln)
    if not m: continue
    v = int(m.group(2), 16)
    if v in hits:
        a = int(m.group(1), 16)
        k = bisect.bisect_right(keys, a) - 1
        hits[v].append((a, syms[keys[k]] if k >= 0 else "?", a - keys[k] if k >= 0 else 0))
for i in ids:
    print(f"{i:#08x}: {len(hits[i])} refs")
    for a, n, o in hits[i][:40]:
        print(f"    {a:08x}  {n}+{o:#x}")
