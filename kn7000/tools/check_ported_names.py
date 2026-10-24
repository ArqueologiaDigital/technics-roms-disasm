#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Question it answers: "does every code name that was carried from program 941 to
# another build sit on the same routine there?"
#
# tools/port_symbols.py places a 941 name through the exact offset map
# (tools/offset_map.py). Inside a 1:1 run the map is right by construction, but a
# run can hold same-length rewrites, so a name could land on code that changed.
# This check compares, for each pair of symbol files (941 file, the build's ported
# file), the routine at the 941 address with the routine at the ported address,
# using the relocation-masked signature of tools/port_names_by_code.py (entry to
# first return; a branch/call target becomes its offset in the stretch or "out",
# every other number >= 0x10000 becomes "A").
#
# Each name falls in one class:
#   same       the two signatures are equal
#   differs    both decode to a return, but the instruction streams differ: the
#              routine was edited between the builds (the name is still the
#              routine's, it is just not the same code)
#   no-return  either side runs past its code range without a return (data, or a
#              tail that jumps away): not comparable
# Only names in code (region 1 and the library window) are checked; `_entry`
# names are skipped (their routine is the function's).
#
# Usage:
#   check_ported_names.py --b-rom baserom/kn7000_program_b935.rom
#       --a-code 0x80:0x186000 --a-code 0x3b8fd1:0x3f6f01:0x4c000000
#       --b-code 0x80:0x18595c --b-code 0x3b8f6d:0x3f6e9d:0x4c000000
#       --pair kn7000.sym:kn7000_b935.sym --pair kn7000_manual.sym:kn7000_b935_manual.sym ...
#       (a pair's 941 side may list several files, comma-separated)
#       [--unidasm PATH] [--list-differs]
import argparse
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_image_s as GI            # noqa: E402
import port_names_by_code as PN     # noqa: E402

LINE = re.compile(r"^0x([0-9A-Fa-f]{8})\s+(\S+)")


def names(path):
    out = {}
    for line in open(path):
        m = LINE.match(line)
        if m:
            out.setdefault(m.group(2), int(m.group(1), 16))
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--a-rom", default="baserom/kn7000_program.rom")
    ap.add_argument("--b-rom", required=True)
    ap.add_argument("--base", type=lambda v: int(v, 0), default=0x48400000)
    ap.add_argument("--a-code", action="append", required=True)
    ap.add_argument("--b-code", action="append", required=True)
    ap.add_argument("--pair", action="append", required=True, metavar="A.sym[,A2.sym...]:B.sym")
    ap.add_argument("--unidasm", default=os.environ.get("UNIDASM", "../../tools/unidasm"))
    ap.add_argument("--list-differs", action="store_true")
    a = ap.parse_args()
    A = GI.Image(a.a_rom, a.base, PN.ranges(a.a_code, a.base), a.unidasm)
    B = GI.Image(a.b_rom, a.base, PN.ranges(a.b_code, a.base), a.unidasm)
    total = {"same": 0, "differs": 0, "no-return": 0}
    for pair in a.pair:
        pa, pb = pair.split(":")
        na, nb = {}, names(pb)
        for path in pa.split(","):     # several 941 files: the first that names it wins
            for k, v in names(path).items():
                na.setdefault(k, v)
        cnt = {"same": 0, "differs": 0, "no-return": 0}
        diff = []
        for nm, bcpu in sorted(nb.items(), key=lambda kv: kv[1]):
            if nm.endswith("_entry") or nm not in na:
                continue
            oa, ob = A.off(na[nm]), B.off(bcpu)
            if oa is None or ob is None:
                continue
            sa, sb = PN.signature(A, oa), PN.signature(B, ob)
            if sa is None or sb is None:
                k = "no-return"
            elif sa == sb:
                k = "same"
            else:
                k = "differs"
                diff.append(f"0x{bcpu:08X} {nm} (941 0x{na[nm]:08X}: {len(sa)} vs {len(sb)} insns)")
            cnt[k] += 1
        for k in cnt:
            total[k] += cnt[k]
        print(f"{os.path.basename(pb):32s} same {cnt['same']:5d}  differs {cnt['differs']:4d}  "
              f"no-return {cnt['no-return']:4d}")
        if a.list_differs:
            for d in diff:
                print(f"    differs: {d}")
    print(f"{'total':32s} same {total['same']:5d}  differs {total['differs']:4d}  "
          f"no-return {total['no-return']:4d}")


if __name__ == "__main__":
    main()
