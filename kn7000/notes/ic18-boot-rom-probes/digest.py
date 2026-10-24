#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# What does each routine of src/ic18/boot.s touch? One block per routine: its
# size, callers, callees, the strings it names, the hardware registers and the
# .bss / data labels it uses -- the evidence the names in kn7000_ic18.sym were
# read from. Reads the generated source only.
#
#   python3 -I digest.py ../../src/ic18/boot.s [NAME_SUBSTRING ...]
import collections
import re
import sys

src = sys.argv[1]
want = sys.argv[2:]
routines = collections.OrderedDict()
cur = None
for line in open(src, encoding="latin1"):
    m = re.match(r"# ---- (\S+) -", line)
    if m:
        cur = routines.setdefault(m.group(1), {"n": 0, "calls": [], "strs": [], "hw": [], "vars": [],
                                              "notes": [], "ops": collections.Counter()})
        continue
    if cur is None:
        continue
    if line.startswith("# ") and not cur["n"]:
        cur["notes"].append(line[2:].rstrip())
        continue
    m = re.match(r"    ([a-z]\w*)\s*(.*)", line)
    if not m or m.group(1).startswith("."):
        continue
    mn, ops = m.group(1), m.group(2)
    cur["n"] += 1
    cur["ops"][mn] += 1
    first = ops.split(",")[0].strip()
    if mn in ("call", "calls"):
        cur["calls"].append(re.sub(r"_entry$", "", first))
    for tok in re.findall(r"\b([A-Za-z_]\w*)\b", ops):
        if tok.startswith(("Str_", "str_")):
            cur["strs"].append(tok)
        elif re.fullmatch(r"[A-Z][A-Z0-9_]+", tok) and tok not in ("DATA_SIZE", "BSS_SIZE"):
            cur["hw"].append(tok)
        elif tok.startswith(("bss_", "rodata_", "data_")) or (tok[0].islower() and tok.startswith("g")):
            cur["vars"].append(tok)
callers = collections.defaultdict(set)
for name, r in routines.items():
    for c in r["calls"]:
        callers[c].add(name)
for name, r in routines.items():
    if want and not any(w in name for w in want):
        continue
    print(f"== {name}  ({r['n']} insns)  callers: {', '.join(sorted(callers.get(name, []))) or '-'}")
    for n in r["notes"]:
        print(f"   # {n}")
    if r["calls"]:
        print("   calls:", ", ".join(dict.fromkeys(r["calls"])))
    if r["strs"]:
        print("   strs: ", ", ".join(dict.fromkeys(r["strs"])))
    if r["hw"]:
        print("   hw:   ", ", ".join(dict.fromkeys(r["hw"])))
    if r["vars"]:
        print("   vars: ", ", ".join(dict.fromkeys(r["vars"])))
