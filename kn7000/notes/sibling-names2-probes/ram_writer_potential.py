#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Question: "would a third RAM rule, 'every store to the address lies in one named routine'
# (a writer class beside name_ram_by_use.py's accessor and owner), name many of the RAM
# addresses that are still numbers?"  For each 0x50 / 0x90 / 0x84 address still spelled as
# a number in <model>/src/program.s: its users split into the routines that store to it
# (`mov|movbu|movhu rN, (ADDR)`, an immediate store, bset / bclr) and the rest.
# Run from the repo root:  python3 -I kn7000/notes/sibling-names2-probes/ram_writer_potential.py kn6000
import collections
import os
import re
import sys

sys.path.insert(0, os.path.join(os.getcwd(), "kn7000", "tools"))
import gen_image_s as GI  # noqa: E402
import name_ram_by_use as N  # noqa: E402

STORE = re.compile(rb"^(?:[ad]\d+|0x[0-9a-fA-F]+|-?\d+), \((0x[0-9a-fA-F]{8})\)$")
for m in sys.argv[1:]:
    syms = GI.load_syms([p for p in (f"{m}/{m}.sym", f"{m}/{m}_manual.sym", f"{m}/{m}_ported.sym",
                                     f"{m}/{m}_aligned.sym", f"{m}/src/program/data/functions.sym")
                         if os.path.exists(p)])
    named = set(syms.values())
    rs = N.read_routines(f"{m}/src/program.s", lambda nm: not (re.search(r"_L[0-9a-f]+_*$", nm)
                                                                or nm.endswith("_entry") or nm.startswith("loc_")))
    st, rd = collections.defaultdict(set), collections.defaultdict(set)
    for nm, ins in rs:
        for mnem, ops in ins:
            for h in N.HEX.findall(ops):
                v = int(h, 16)
                if (v >> 24) not in (0x50, 0x90, 0x84):
                    continue
                (st if mnem.startswith(("mov", "bset", "bclr")) and STORE.match(ops.strip()) else rd)[v].add(nm)
    c = collections.Counter()
    for v in set(st) | set(rd):
        if len(st[v] | rd[v]) == 1:
            c["one user (the owner class's case)"] += 1
        elif len(st[v]) == 1:
            c["one writer, named" if next(iter(st[v])) in named else "one writer, a func_ placeholder"] += 1
        elif not st[v]:
            c["no direct store"] += 1
        else:
            c["several writers"] += 1
    print(m, ", ".join(f"{k}: {n}" for k, n in c.most_common()))
