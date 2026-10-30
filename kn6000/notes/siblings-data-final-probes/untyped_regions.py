#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""untyped_regions.py -- the largest stretches of a sibling's data region that are still bytes.

QUESTION IT ANSWERS
  "Where, in <model>'s typed data region, are the biggest runs of .incbin_range pieces (generic, or
   declared opaque), what label starts each run, how much of it is opaque, and what do the bytes
   look like?"  Consecutive pieces separated only by labels / comments count as one run.

RUN (from the repository root, after `make -C <model> verify`):
  python3 kn6000/notes/siblings-data-final-probes/untyped_regions.py kn6000 [N] [--kind opaque|generic]
  model: kn6000, kn6500, kn2400 or hdsx3.
"""
import glob
import os
import re
import sys

ROMS = {"kn6000": ("kn6000/baserom/kn6000_program.rom", 0x4C000000),
        "kn6500": ("kn6500/baserom/kn6500_program.rom", 0x4C000000),
        "kn2400": ("kn2400/baserom/kn2400_program.rom", 0x48400000),
        "hdsx3": ("hdsx3/baserom/hdsx3_extapr.rom", 0x97800000)}


def runs(model):
    rom_path, base = ROMS[model]
    rom = open(rom_path, "rb").read()
    out, cur = [], None
    for f in sorted(glob.glob(f"{model}/src/program/data/data_*.s")):
        lab, opq = None, False
        for ln in open(f, encoding="latin-1").read().split("\n"):
            m = re.match(r"^([A-Za-z_]\w*):", ln)
            if m:
                lab = m.group(1)
                ln = ln[m.end():]
            if "census: opaque" in ln and ".incbin" not in ln:
                opq = True
            m = re.search(r'\.incbin_range\s+"[^"]+",\s*0x([0-9A-Fa-f]+),\s*0x([0-9A-Fa-f]+)', ln)
            if m:
                a, b = int(m.group(1), 16), int(m.group(2), 16)
                o = opq or "census: opaque" in ln
                if cur and cur["end"] == a:
                    cur["end"] = b
                    cur["opaque" if o else "generic"] += b - a
                    cur["n"] += 1
                else:
                    cur = {"start": a, "end": b, "lab": lab, "file": os.path.basename(f), "n": 1,
                           "opaque": b - a if o else 0, "generic": 0 if o else b - a}
                    out.append(cur)
                opq = False
                continue
            s = ln.strip()
            if s and not s.startswith("#") and not s.startswith(";"):
                cur = None          # typed bytes between: a new run
                opq = False if not s.startswith(".") or not s.startswith(".incbin") else opq
    return out, rom, base


def main():
    model = sys.argv[1]
    n = int(sys.argv[2]) if len(sys.argv) > 2 and sys.argv[2].isdigit() else 40
    kind = sys.argv[sys.argv.index("--kind") + 1] if "--kind" in sys.argv else None
    out, rom, base = runs(model)
    if kind:
        out = [r for r in out if r[kind]]
    out.sort(key=lambda r: -(r["end"] - r["start"]))
    tot_o = sum(r["opaque"] for r in out)
    tot_g = sum(r["generic"] for r in out)
    print(f"{model}: {len(out)} runs, opaque {tot_o:,} B, generic {tot_g:,} B")
    for r in out[:n]:
        a, b = r["start"], r["end"]
        print(f"{b - a:8d} 0x{a:06X}-0x{b:06X} CPU 0x{base + a:08X} pieces {r['n']:4d} opaque {r['opaque']:7d}"
              f" {r['file']} {r['lab']}  {rom[a:a + 20].hex(' ')}")


if __name__ == "__main__":
    main()
