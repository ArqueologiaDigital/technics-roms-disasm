#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""code_gap_classes.py -- what the code-range .incbin_range pieces of a sibling source are.

QUESTION IT ANSWERS
  "In a src/program.s that gen_image_s.py wrote WITHOUT --decode-gaps, do the code-range bytes
   left binary decode as instructions?"  Each piece is decoded linearly (MAME unidasm, through
   gen_image_s.Image) and put in a class:
     code-full-stop     decodes to the piece's end, the last instruction a return / jmp / bra
     code-full-nostop   decodes to the end, the last instruction something else (on both images:
                        `add -N, sp`, the prologue of the function that follows)
     fill               only 0xCB / 0xFF / 0x00
     partial            stops early (an undecodable byte inside)
  2026-10-29, on the sources at e12c2c693:
     kn2400: code-full-stop 324 / 16,189 B, code-full-nostop 42 / 2,781 B, fill 7 / 30 B,
             partial 2 / 349 B (0x1ea0c9: 0xFF fill then a prologue; 0x39643b: a jmp, 3 bytes of
             0xFF, then the vector handlers)
     hdsx3:  code-full-stop 17 / 907 B, code-full-nostop 8 / 255 B
  which is why --decode-gaps decodes run by run with 0xFF fill between runs.

RUN (from the repository root; the old source from git, the reference images built):
  git show e12c2c693:kn2400/src/program.s > $TMPDIR/k24.s
  python3 kn2400/notes/data-region-probes/code_gap_classes.py $TMPDIR/k24.s kn2400/baserom/kn2400_program.rom \\
      0x48400000 0x0:0x10 0x1e427c:0x3285be 0x3285be:0x3965bb:0x50120000 --unidasm PATH/unidasm
  git show e12c2c693:hdsx3/src/program.s > $TMPDIR/hx.s
  python3 kn2400/notes/data-region-probes/code_gap_classes.py $TMPDIR/hx.s hdsx3/baserom/hdsx3_extapr.rom \\
      0x97800000 0x80:0x3ded6 --unidasm PATH/unidasm
"""
import argparse
import collections
import os
import re
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "kn7000", "tools"))
import gen_image_s as G  # noqa: E402

ap = argparse.ArgumentParser()
ap.add_argument("source")
ap.add_argument("rom")
ap.add_argument("base", type=lambda v: int(v, 0))
ap.add_argument("code", nargs="+", metavar="LO:HI[:CPU]")
ap.add_argument("--unidasm", required=True)
ap.add_argument("--list", action="store_true", help="also print every piece that is not code-full-stop")
a = ap.parse_args()
code = []
for r in a.code:
    f = [int(x, 0) for x in r.split(":")]
    code.append((f[0], f[1], (f[2] - f[0]) if len(f) > 2 else a.base))
img = G.Image(a.rom, a.base, code, a.unidasm)
d = img.d
n, b = collections.Counter(), collections.Counter()
for line in open(a.source, encoding="latin-1"):
    m = re.match(r'\.incbin_range "[^"]+", (0x[0-9a-fA-F]+), (0x[0-9a-fA-F]+)', line)
    if not m:
        continue
    lo, hi = int(m.group(1), 16), int(m.group(2), 16)
    if not img.in_code(lo):
        continue
    ins = img.decode(lo, hi)
    end = ins[-1][0] + len(ins[-1][1]) if ins else lo
    if end == hi:
        k = "code-full-stop" if ins[-1][2] in ("ret", "retf", "rets", "rti", "jmp", "bra") else "code-full-nostop"
    elif all(x in (0xCB, 0xFF, 0x00) for x in d[lo:hi]):
        k = "fill"
    else:
        k = "partial"
    n[k] += 1
    b[k] += hi - lo
    if a.list and k != "code-full-stop":
        print(f"{k:17s} {lo:#08x}..{hi:#08x} {hi - lo:5d} B, decoded to {end:#x}: {d[lo:lo + 16].hex()}")
for k in ("code-full-stop", "code-full-nostop", "fill", "partial"):
    print(f"{k:17s} {n[k]:4d} pieces {b[k]:7,d} bytes")
