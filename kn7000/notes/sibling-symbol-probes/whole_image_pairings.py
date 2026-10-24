#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Question: what does gen_symbols.py pair in a MILK image when the whole image
# counts as code, beyond what it pairs with the image's real code ranges?
#
# The sibling trees (kn2400, kn6000, kn6500, hdsx3) run gen_symbols.py with
# --code-range set to their code ranges. This probe runs the same reflection-
# table scan twice, once with those ranges and once with --code-range
# 0:<image size>, and prints
#   * the number of names the whole-image run adds (addresses the code-range run
#     does not name), and
#   * each MILK table the whole-image run accepts and the code-range run does
#     not: its code-array file offset, its length and its first three names.
#
# Usage (from the repository root, after `make -C <tree> baserom`):
#   python3 kn7000/notes/sibling-symbol-probes/whole_image_pairings.py \
#       --rom kn2400/baserom/kn2400_program.rom --base 0x48400000 --code-range 0x1e427c:0x3285be
import argparse
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "tools"))
import gen_symbols as GS  # noqa: E402


def scan(data, base, rngs):
    GS.PROGRAM_BASE = base
    GS._is_code = lambda v: any(lo <= v - base < hi for lo, hi in rngs)
    GS.CODE_LO, GS.CODE_HI = min(r[0] for r in rngs), max(r[1] for r in rngs)
    tables = list(GS.find_tables(data, GS._ident_offsets(data)))
    syms = {cpu: name for cpu, _off, name in GS.recover_symbols(data)}
    return tables, syms


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rom", required=True)
    ap.add_argument("--base", type=lambda v: int(v, 0), required=True)
    ap.add_argument("--code-range", action="append", required=True, metavar="LO:HI")
    a = ap.parse_args()
    data = open(a.rom, "rb").read()
    rngs = [tuple(int(x, 0) for x in r.split(":")) for r in a.code_range]
    t_code, s_code = scan(data, a.base, rngs)
    t_all, s_all = scan(data, a.base, [(0, len(data))])
    extra = {c: n for c, n in s_all.items() if c not in s_code}
    print(f"{a.rom}: {len(s_code)} names with the code ranges, {len(s_all)} with the whole "
          f"image; {len(extra)} addresses named only by the whole-image run")
    seen = {co for co, _no, _n in t_code}
    for co, no, n in t_all:
        if co in seen:
            continue
        GS.PROGRAM_BASE = a.base
        first = [GS.read_name(data, GS.read_u32(data, no + 4 * k)) for k in range(min(3, n))]
        print(f"  extra table: code array at file 0x{co:06x}, {n} entries, names {first} ...")


if __name__ == "__main__":
    main()
