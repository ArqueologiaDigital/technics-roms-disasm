#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""tg_image_regs.py -- which tone-generator register each field of the SX-KN6000 / KN6500 voice register image
goes to.

QUESTION ANSWERED: "func_4C0948CB (KN6000; KN6500 func_4C094795) writes a 160-byte record, a0 = the voice's
register image, to the MAIN TG one register at a time: for each field, which TG register (the class half of
the packed word (slot << 20) | (class << 16) | data that the writer (KN6000 func_4C09465B, KN6500 func_4C094525: the routine's first call) latches to 0x98050000 / 0x98050002)?"
The routine's straight-line code is read as: `movhu (OFF, a2), d1` (or `mov (OFF, a2), d0` for +0x7C, the
pitch's 17th bit) then `or 0xCCCC0000, d0` / `or 0xCCCCDDDD, d0` before the `call func_4C09465B`.  A field
written twice is listed once per write.  Prints `offset class` rows, and a data_struct_names.py dict.

RUN (from the repository root):  python3 kn7000/notes/mn10300-data4-probes/tg_image_regs.py [kn6000|kn6500]
"""
import os
import re
import sys

REPO = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
FUNC = {"kn6000": "func_4C0948CB", "kn6500": "func_4C094795"}
SYMS = {"IVAR0": 0x20000000}


def regs(model):
    L = open(os.path.join(REPO, model, "src/program.s"), encoding="latin-1").read().split("\n")
    i = L.index(f"{FUNC[model]}:")
    out, off, cls, writer = [], None, None, None
    for ln in L[i + 1:]:
        if re.match(r"^\w+:", ln) and not ln.startswith(FUNC[model]):
            break
        m = re.match(r"\s+(?:movhu|mov)\s+\((?:(0x[0-9a-f]+|\d+), )?a2\), d1$", ln)
        if m:
            off, cls = int(m.group(1) or "0", 0), None
            continue
        m = re.match(r"\s+mov\s+\((0x[0-9a-f]+|\d+), a2\), d0$", ln)
        if m:
            off, cls = int(m.group(1), 0), None
            continue
        m = re.match(r"\s+or\s+(0x[0-9a-f]{8}|[A-Z]\w+), d[01]$", ln)
        if m:
            # (a constant the code spells with a symbol: IVAR0 is 0x20000000, the MN10300 SFR address the
            # same number names)
            v = int(m.group(1), 16) if m.group(1).startswith("0x") else SYMS.get(m.group(1))
            cls = v >> 16 if v is not None else None
            continue
        m = re.match(r"\s+call\s+(func_[0-9A-F]{8})\b", ln)
        if m and writer is None:
            writer = m.group(1)
        if m and m.group(1) == writer:
            if off is not None and cls is not None:
                out.append((off, cls))
            off, cls = None, None
        if re.match(r"\s+(ret|retf)\b", ln):
            break
    return out


if __name__ == "__main__":
    for mdl in sys.argv[1:] or ["kn6000", "kn6500"]:
        rs = regs(mdl)
        print(f"== {mdl} {FUNC[mdl]}: {len(rs)} field writes")
        print("  " + ", ".join(f"+{o:#x}->{c:#06x}" for o, c in rs))
