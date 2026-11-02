#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
r"""rhythm_count_block_readers.py -- which bytes of the "Technics Rhythms" count block are read?

QUESTION ANSWERED
-----------------
"Past the rhythm count (the u16BE at +2), does any routine of program 941 or of the
KN2400 / KN6000 / KN6500 programs read the 12-byte count block
(`00 00 | 00 DC | 00 60 | 0D 08 04 02 02 02` in IC18)?"

The block is reached only through the header's u24BE at +0x18 (kn7000/notes/ic18-rhythm-rom.md,
"The header").  The probe lists every place in each image that loads a u24BE from +0x18 of
a pointer (`mov 0x18, a0` / `add dN, a0` / `call LoadU24BE`) and prints what the routine
does with the result.  The sites are StyleBuiltinNameTableInit (and, in the KN6500, one more
rhythm-resource opener), plus TechnicsPadsResourceParse, which opens the "Technics Pads"
resource of the same header layout.  In every site the only use is +2 (`add 2, a0` or
`mov 2, a0` / `add d0, a0`) and a 16-bit big-endian load (LoadU16BE, or the sibling's twin),
stored to a count cell; the block pointer itself is not kept.  PASS = every site reads +2
and nothing else of the block.

Run from the worktree root (read-only, deterministic):

    python3 -I kn7000/notes/mn10300-names-probes/rhythm_count_block_readers.py
"""
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
IMAGES = {
    "kn7000 941": sorted(glob.glob(os.path.join(ROOT, "kn7000/src/program/region1_*.s"))
                         + glob.glob(os.path.join(ROOT, "kn7000/src/program/library_*.s"))),
    "kn2400": [os.path.join(ROOT, "kn2400/src/program.s")],
    "kn6000": [os.path.join(ROOT, "kn6000/src/program.s")],
    "kn6500": [os.path.join(ROOT, "kn6500/src/program.s")],
}


def lines(paths):
    out = []
    for p in paths:
        for raw in open(p, "rb").read().decode("latin-1").split("\n"):
            x = " ".join(raw.split("#")[0].split())
            if x:
                out.append(x)
    return out


def main():
    ok = True
    for img, paths in IMAGES.items():
        L = lines(paths)
        sites = []
        for i in range(len(L) - 3):
            if L[i] == "mov 0x18, a0" and re.match(r"add d[0-3], a0$", L[i + 1]) and L[i + 2].startswith("call LoadU24BE"):
                func = next((L[j] for j in range(i, -1, -1) if re.match(r"^[A-Za-z_][\w]*:$", L[j])
                             and not re.match(r"^(loc_|.*_L[0-9a-f]+:|.*_entry:)", L[j])), "?")
                sites.append((func, L[i + 3:i + 10]))
        print(f"== {img}: {len(sites)} u24BE load(s) from +0x18")
        for f, after in sites:
            print(f"   in {f}")
            for x in after:
                print(f"      {x}")
        good = bool(sites) and all(any(x in ("add 2, a0", "mov 2, a0") for x in after)
                                   and not any(re.match(r"(add|mov) (0x[0-9a-f]+|[0-9]+), a0$", x) and x.split()[1].rstrip(",") not in ("2", "0x2") for x in after)
                                   for _f, after in sites)
        ok &= good
        print(f"   only offset +2 of the block is read: {'PASS' if good else 'FAIL'}")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
