#!/bin/bash
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# kn7000_ram_names_reach.sh SCRATCH MODEL...
#
# Question: "if KN7000 941's RAM addresses were named the way name_ram_by_use.py names the
# siblings' (accessor / owner, from 941's own routine names), how many sibling RAM addresses
# would the RAM map (<model>/notes/ram-map-kn7000.tsv) give a name they lack today?"
# 941's code (kn7000/src/program/region1_*.s, library_*.s, tail_code.s, 4-space indented) is
# joined into SCRATCH with a tab indent, which is what name_ram_by_use.py reads; its output
# goes to SCRATCH/k941-ram.sym.  Nothing tracked is written.  Run from the repo root.
set -e
S=$1; shift
mkdir -p "$S"
cat kn7000/src/program/region1_*.s kn7000/src/program/library_*.s kn7000/src/program/tail_code.s \
    | sed 's/^    /\t/' > "$S/k941-program-cat.s"
( cd kn7000 && python3 tools/name_ram_by_use.py --src "$S/k941-program-cat.s" \
    --sym kn7000.sym kn7000_manual.sym kn7000_exports_from_942.sym \
    --taken src/symbols.inc src/program/data/labels.sym src/constants.inc \
    --out "$S/k941-ram.sym" --report "$S/k941-ram-report.md" --title "KN7000 941 RAM names by use (trial)" )
cat "$S/k941-ram-report.md"
python3 - "$S/k941-ram.sym" "$@" <<'PY'
import collections, re, sys
cls = {}
for ln in open(sys.argv[1]):
    m = re.match(r"0x([0-9A-F]+)\s+(\w+)\t; (\w+)", ln)
    if m:
        cls[int(m.group(1), 16)] = m.group(3)
for m in sys.argv[2:]:
    named = set()
    for f in (f"{m}/{m}.sym", f"{m}/{m}_manual.sym", f"{m}/{m}_ported.sym", f"{m}/{m}_aligned.sym",
              f"{m}/{m}_ram.sym", f"{m}/src/program/data/functions.sym"):
        for ln in open(f):
            r = re.match(r"0x([0-9A-Fa-f]+)\s+\w", ln)
            if r:
                named.add(int(r.group(1), 16))
    c = collections.Counter()
    for ln in open(f"{m}/notes/ram-map-kn7000.tsv"):
        if ln.startswith("0x"):
            vb, va = (int(x, 16) for x in ln.split("\t")[:2])
            if va in cls:
                c[f"941 {cls[va]}, sibling {'named' if vb in named else 'unnamed'}"] += 1
    print(m, ", ".join(f"{k}: {n}" for k, n in sorted(c.items())))
PY
