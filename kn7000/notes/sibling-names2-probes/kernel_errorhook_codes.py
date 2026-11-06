#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Question: "which function code does each MILK kernel service pass to KernelErrorHook /
# KernelErrorHook2 (d0, with the uITRON 3.0 error code in d1), and which of those services
# are still func_<ADDR>?"  A lead for naming the kernel's services by the uITRON 3.0
# function-code table (not in this repo: the codes are listed, not translated).
# Reads <model>/src/program.s: for each `call KernelErrorHook*`, the nearest `mov N, d0` and
# `mov N, d1` among the 8 lines before it.  Run from the repo root:
#     python3 -I kn7000/notes/sibling-names2-probes/kernel_errorhook_codes.py kn6000 kn6500 kn2400
import collections
import re
import sys

for m in sys.argv[1:]:
    lines = open(f"{m}/src/program.s", "rb").read().decode("latin-1").split("\n")
    cur, out = None, collections.defaultdict(set)
    for i, ln in enumerate(lines):
        mm = re.match(r"^([A-Za-z_]\w*):", ln)
        if mm and not re.search(r"_L[0-9a-f]+$", mm.group(1)) and not mm.group(1).startswith("loc_") \
                and not mm.group(1).endswith("_entry"):
            cur = mm.group(1)
        if re.search(r"\tcall\tKernelErrorHook2?,", ln):
            got = {}
            for j in range(i - 1, max(i - 9, 0), -1):
                r = re.search(r"\tmov\t(-?0x[0-9a-f]+|-?\d+), (d[01])$", lines[j])
                if r and r.group(2) not in got:
                    got[r.group(2)] = int(r.group(1), 0)
            out[cur].add((got.get("d0"), got.get("d1")))
    print(f"{m}: {len(out)} services call the error hooks; "
          f"{sum(1 for k in out if k.startswith('func_'))} of them are func_ placeholders")
    for k, v in sorted(out.items(), key=lambda x: sorted(c for c, _e in x[1] if c is not None)[:1]):
        print(f"  {k:24s} " + ", ".join(f"d0 {c:#x} d1 {e:#x}" if c is not None and e is not None else
                                         f"d0 {c} d1 {e}" for c, e in sorted(v, key=str)))
