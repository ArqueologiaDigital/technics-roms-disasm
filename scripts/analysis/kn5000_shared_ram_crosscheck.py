#!/usr/bin/env python3
"""kn5000_shared_ram_crosscheck.py -- does another ROM's source spell a main-CPU RAM address as a number?

QUESTION THIS ANSWERS
  The inter-ROM policy wants one name per shared RAM cell.  The HD-AE5000 extension runs on the main CPU,
  so it can address the main CPU's RAM (0x400-0xFFFFF) directly.  This lists every numeric memory operand
  `(N)` / `(N:8|16|24)` in hdae5000/*.s that falls in that range, and says which of those addresses already
  have a name in the v10 RAM includes (shared/ram_variables*.s, shared/ram_panel_records.s and the constants
  files name_kn5000_ram.py reads) -- the cells whose name the HD-AE5000 source should reuse.  (The sub-CPU
  has an address space of its own, so the v142 tree shares no RAM with these.)

USAGE
  python3 scripts/analysis/kn5000_shared_ram_crosscheck.py
"""
import collections
import glob
import os
import re

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
FILES = ["shared/ram_variables.s", "shared/ram_variables_by_use.s", "shared/ram_panel_records.s",
         "cpanel_constants.s", "midi_encoder_constants.s", "gui_constants.s", "kn5000_v10_program.s"]


def main():
    names = {}
    for f in FILES:
        p = os.path.join(REPO, "v10", "maincpu", f)
        for l in open(p, "rb").read().decode("latin-1").split("\n"):
            m = re.match(r'\s*\.equ\s+(\w+)\s*,\s*(0x[0-9a-fA-F]+)', l)
            if m and 0x400 <= int(m.group(2), 16) < 0x100000:
                names[int(m.group(2), 16)] = m.group(1)
    use = collections.Counter()
    for f in glob.glob(os.path.join(REPO, "hdae5000", "*.s")):
        for l in open(f, "rb").read().decode("latin-1").split("\n"):
            c = l.split(";")[0].strip()
            if not c or c.startswith("."):
                continue
            for g in re.finditer(r'\((0x[0-9a-fA-F]+|\d+)(:8|:16|:24)?\)', c):
                v = int(g.group(1), 0)
                if 0x400 <= v < 0x100000:
                    use[v] += 1
    print("hdae5000: %d numeric main-CPU RAM operands at %d addresses" % (sum(use.values()), len(use)))
    for v, n in sorted(use.items(), key=lambda kv: -kv[1]):
        print("  0x%05x %4d  %s" % (v, n, names.get(v, "-")))
    return 0


if __name__ == "__main__":
    main()
