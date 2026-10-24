#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Carries hand-recovered names from one MN10300 MILK firmware to another where
# the named routine is the same code, linked elsewhere.
#
# Question it answers: "which unnamed entries (func_<ADDR>) of image B are a
# routine that image A names?"
#
# A routine's signature is its instruction stream from its entry to its first
# return (ret / retf / rets / rti), decoded with MAME unidasm and normalised so
# that relinking does not change it:
#   * the target of a branch, jump or call becomes its offset from the entry when
#     it lies inside the stretch, else just "out";
#   * every other number of 0x10000 or more (a code, data, RAM or I/O address,
#     which moves from build to build) becomes "A"; smaller numbers (offsets,
#     masks, counts, event codes below 0x10000) are kept.
# A name is carried over only when the signature has at least --min instructions
# and occurs exactly once among A's named routines and exactly once among B's
# entries -- an ambiguous match carries nothing. The output is a .sym file whose
# every row records the A address it came from and the length of the match.
#
# Usage:
#   port_names_by_code.py --a-rom A.rom --a-code LO:HI[:CPU] ... --a-sym A1.sym [A2.sym ...]
#                         --b-rom B.rom --b-base 0x... --b-code LO:HI[:CPU] ... --b-sym B.sym ...
#                         --b-labels B/src/labels.inc --out B_ported.sym --title "..."
#                         [--unidasm PATH] [--min 8]
import argparse
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_image_s as GI  # noqa: E402

RETS = {"ret", "retf", "rets", "rti"}
NUM = re.compile(r"0x[0-9a-fA-F]+|\b\d+\b")


def ranges(specs, base):
    out = []
    for r in specs:
        f = [int(x, 0) for x in r.split(":")]
        out.append((f[0], f[1], (f[2] - f[0]) if len(f) > 2 else base))
    return sorted(out)


def signature(img, off, limit=0x4000):
    """Normalised instruction tuple from off to its first return, or None."""
    end = min(img.code_end(off), off + limit)
    insns = img.decode(off, end)
    cpu0 = img.cpu(off)
    body = []
    for o, b, mnem, ops in insns:
        body.append((o, b, mnem, ops))
        if mnem in RETS:
            break
    else:
        return None
    lo, hi = cpu0, img.cpu(body[-1][0]) + len(body[-1][1])
    sig = []
    for o, b, mnem, ops in body:
        t = GI.target_of(mnem, ops)
        if t is not None:
            rest = ops[len(re.match(r"0x[0-9a-fA-F]+", ops).group(0)):]
            ops = (f"@{t - cpu0}" if lo <= t < hi else "out") + rest

        def norm(m):
            v = int(m.group(0), 0)
            return "A" if v >= 0x10000 else m.group(0)
        if t is None:
            ops = NUM.sub(norm, ops)
        sig.append(f"{mnem} {ops}")
    return tuple(sig)


def load(paths):
    return GI.load_syms(paths) if paths else {}


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--a-rom", required=True)
    ap.add_argument("--a-base", type=lambda v: int(v, 0), default=0x48400000)
    ap.add_argument("--a-code", action="append", required=True)
    ap.add_argument("--a-sym", nargs="+", required=True, help="the names to carry")
    ap.add_argument("--b-rom", required=True)
    ap.add_argument("--b-base", type=lambda v: int(v, 0), required=True)
    ap.add_argument("--b-code", action="append", required=True)
    ap.add_argument("--b-sym", nargs="+", required=True, help="B's names (never overridden)")
    ap.add_argument("--b-labels", required=True, help="B's generated labels.inc (its entries)")
    ap.add_argument("--out", required=True)
    ap.add_argument("--title", required=True)
    ap.add_argument("--min", type=int, default=8, help="shortest signature carried")
    ap.add_argument("--unidasm", default=os.environ.get("UNIDASM", "../../tools/unidasm"))
    a = ap.parse_args()

    A = GI.Image(a.a_rom, a.a_base, ranges(a.a_code, a.a_base), a.unidasm)
    B = GI.Image(a.b_rom, a.b_base, ranges(a.b_code, a.b_base), a.unidasm)

    a_names = {cpu: nm for cpu, nm in load(a.a_sym).items()
               if not nm.endswith("_entry") and A.off(cpu) is not None}
    b_named = load(a.b_sym)
    b_taken = set(b_named.values())
    # B's unnamed entries: its func_<ADDR> labels, plus the ones an earlier run of
    # this tool named (they are labels under those names once the source has been
    # regenerated with --out among its symbol files), so a rerun is a fixed point
    before = set(load([a.out]).values()) if os.path.exists(a.out) else set()
    b_entries = {}
    for nm, v in re.findall(r"^\.equ\s+(\w+),\s*0x([0-9a-fA-F]+)", open(a.b_labels).read(), re.M):
        if re.fullmatch(r"func_[0-9A-F]{8}", nm) or nm in before:
            b_entries[int(v, 16)] = nm

    sa = {}
    for cpu, nm in a_names.items():
        s = signature(A, A.off(cpu))
        if s and len(s) >= a.min:
            sa.setdefault(s, []).append((cpu, nm))
    sb = {}
    for cpu in list(b_entries) + list(b_named):
        o = B.off(cpu)
        if o is None:
            continue
        s = signature(B, o)
        if s and len(s) >= a.min:
            sb.setdefault(s, []).append(cpu)

    rows, skipped_taken = [], 0
    for s, alist in sa.items():
        if len(alist) != 1 or len(sb.get(s, ())) != 1:
            continue
        (acpu, nm), bcpu = alist[0], sb[s][0]
        if bcpu not in b_entries:
            continue                         # B already names it
        if nm in b_taken:
            skipped_taken += 1
            continue
        b_taken.add(nm)
        rows.append((bcpu, nm, acpu, len(s)))
    rows.sort()
    with open(a.out, "w") as f:
        f.write(f"; {a.title}\n")
        f.write("; GENERATED by kn7000/tools/port_names_by_code.py -- do not edit; its header says\n")
        f.write("; how a name qualifies. Columns: B address, name, ; the A address it was carried\n")
        f.write("; from and the number of instructions that matched (entry to first return).\n;\n")
        f.write(f"; {len(rows)} names carried ({len(a_names)} candidates in A, {len(b_entries)} "
                f"unnamed entries in B, {skipped_taken} skipped: the name is taken in B)\n")
        for bcpu, nm, acpu, n in rows:
            f.write(f"0x{bcpu:08X}  {nm}\t; = 0x{acpu:08X}, {n} insns\n")
    print(f"port_names_by_code: {len(rows)} names -> {a.out}")


if __name__ == "__main__":
    main()
