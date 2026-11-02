#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
r"""rhythm_style_record_readers.py -- who reads a built-in style record, and does anyone read +0x89?

QUESTION ANSWERED
-----------------
"Does any routine of program 941 (SX-KN7000) or of the KN2400 / KN6000 / KN6500 programs
read byte +0x89 of a built-in style record (the byte that is 1 in every style)?"

A built-in style record (kn7000/notes/ic18-rhythm-rom.md, "A style record") reaches code
only as a pointer: StyleBuiltinNameResolve returns it in a0, StyleNameSourceSet caches it
in a RAM cell, and StyleNameCommit derives three more cells from it (record+0x0D, the
units; record+0x11+15i, the part set-ups; record+0x8A+3j -> the 20 variation records).
The probe parses each image's StyleNameCommit to find those cells, then collects the
READER SET: every routine that names one of the cells or calls StyleBuiltinNameResolve,
plus every routine that calls a leaf accessor which hands one of the cells out.  For each
reader it prints the record-relative displacements, add-immediates and memcpy lengths it
uses.  It also scans the whole image for any `(0x89, aN)` operand and `add 0x89, aN`.

PASS = no 0x89 displacement anywhere in the reader set, and every memcpy out of the
record stays below +0x89 (13-byte name, 4-byte units, 15-byte part set-ups, 0x78 bytes
of all eight set-ups from +0x11, ending at +0x88).  The verdict lines are printed; the
human reading of each reader is in kn7000/notes/ic18-rhythm-rom.md ("The byte at +0x89").

Read-only on the sources; deterministic.  Run from the worktree root:

    python3 -I kn7000/notes/mn10300-names-probes/rhythm_style_record_readers.py
"""
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
IMAGES = {
    "kn7000 941": sorted(glob.glob(os.path.join(ROOT, "kn7000/src/program/region1_*.s"))
                         + glob.glob(os.path.join(ROOT, "kn7000/src/program/library_*.s"))
                         + glob.glob(os.path.join(ROOT, "kn7000/src/program/tail_code.s"))),
    "kn2400": [os.path.join(ROOT, "kn2400/src/program.s")],
    "kn6000": [os.path.join(ROOT, "kn6000/src/program.s")],
    "kn6500": [os.path.join(ROOT, "kn6500/src/program.s")],
}
LOCAL = re.compile(r"^(loc_[0-9A-Fa-f]+|.*_L[0-9a-f]+|.*_entry)$")


def functions(paths):
    """[(name, [instruction text, ...])] in source order; whitespace normalised."""
    out, cur = [], None
    for p in paths:
        for raw in open(p, "rb").read().decode("latin-1").split("\n"):
            line = raw.split("#")[0].rstrip()
            m = re.match(r"^([A-Za-z_.][\w.]*):", line)
            if m:
                if not LOCAL.match(m.group(1)):
                    cur = (m.group(1), [])
                    out.append(cur)
                continue
            if cur and line.strip():
                cur[1].append(" ".join(line.split()))
    return out


def cells_of_commit(body):
    rec = next(re.match(r"mov \((0x[0-9a-f]+)\), a3", x).group(1) for x in body if re.match(r"mov \(0x[0-9a-f]+\), a3", x))
    arrays = [re.match(r"mov (0x5[0-9a-f]{7}), a0", x).group(1) for x in body if re.match(r"mov 0x5[0-9a-f]{7}, a0", x)]
    units = [re.match(r"mov d0, \((0x[0-9a-f]+)\)", x).group(1) for x in body if re.match(r"mov d0, \(0x[0-9a-f]+\)", x)][-1]
    # arrays[0] is the name buffer, arrays[1] the part set-up pointers, arrays[2] the variation pointers
    return {"record": rec, "name buffer": arrays[0], "part pointers": arrays[1], "variation pointers": arrays[2], "units": units}


def main():
    ok = True
    for img, paths in IMAGES.items():
        fns = functions(paths)
        by = {n: b for n, b in fns}
        cells = cells_of_commit(by["StyleNameCommit"])
        print(f"== {img}: cells " + ", ".join(f"{k} {v}" for k, v in cells.items()))
        cellset = {cells[k] for k in ("record", "part pointers", "units")}
        seeds = set()
        for n, b in fns:
            if any(c in x for x in b for c in cellset) or any("call StyleBuiltinNameResolve" in x for x in b):
                seeds.add(n)
        # leaf accessors: short routines that only load a cell and return it
        leaves = {n for n in seeds if len(by[n]) <= 12 and any(x.startswith("ret") for x in by[n])}
        readers = set(seeds)
        for n, b in fns:
            if any(re.match(rf"call {re.escape(l)}(_entry)?,", x) for x in b for l in leaves):
                readers.add(n)
        # helpers the readers hand the record (or a pointer into it) to: their direct callees,
        # minus the library string / byte-order leaves and the module's own entry points above
        helpers = set()
        for n in list(readers):
            for x in by[n]:
                m = re.match(r"calls? ([A-Za-z_]\w*?)(_entry)?,", x)
                if m and m.group(1) in by and m.group(1) not in readers and not re.match(
                        r"(memcpy|memset|strncpy|strcpy|strncmp|LibStrlen|LoadU(16|24|32)BE|GetM3EmVal|PutM3Em|MainPutM3Em|StyleIdArrayStore|LibDiv32)$",
                        m.group(1)):
                    helpers.add(m.group(1))
        readers |= helpers
        hits89 = []
        for n, b in fns:
            for x in b:
                if re.search(r"\(0x89, *a[0-3]\)", x) or re.match(r"add 0x89, a[0-3]$", x):
                    hits89.append((n, x))
        bad = []
        for n in sorted(readers):
            b = by[n]
            disp = sorted({m.group(1) for x in b for m in re.finditer(r"\((0x[0-9a-f]+|\d+), a[0-3]\)", x)},
                          key=lambda s: int(s, 0))
            adds = sorted({m.group(1) for x in b for m in [re.match(r"(?:add|mov) (0x[0-9a-f]+), [ad][0-3]$", x)] if m
                           and int(m.group(1), 16) < 0x100}, key=lambda s: int(s, 16))
            cpy = []
            for i, x in enumerate(b):
                if x.startswith("call memcpy") or x.startswith("call strncpy"):
                    ln = next((re.match(r"mov (0x[0-9a-f]+|\d+), d0$", y).group(1) for y in reversed(b[max(0, i - 6):i])
                               if re.match(r"mov (0x[0-9a-f]+|\d+), d0$", y)), "?")
                    cpy.append(ln)
            if "0x89" in disp:
                bad.append(n)
            print(f"   {n:32s} disp {' '.join(disp) or '-'} | small imm {' '.join(adds) or '-'} | memcpy len {' '.join(cpy) or '-'}")
        print(f"   whole image: (0x89, aN) / add 0x89, aN -> {len(hits89)} hit(s)" + "".join(f"\n      {n}: {x}" for n, x in hits89))
        v = "PASS" if not bad else "FAIL " + ", ".join(bad)
        ok &= not bad
        print(f"   readers {len(readers)} ({len(seeds)} direct, {len(leaves)} leaf accessors, {len(helpers)} callees); 0x89 displacement in a reader: {v}")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
