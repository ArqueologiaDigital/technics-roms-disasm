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
#     which moves from build to build, but also a MILK message code such as
#     0x1760002, which is renumbered between models) becomes "A"; smaller numbers
#     (offsets, masks, counts, event codes below 0x10000) are kept.
# A name is carried over only when
#   * the signature has at least --min instructions that keep all their content,
#     i.e. that have no number masked to "A" (a handler that only compares a
#     message code with three masked constants and returns is not evidence);
#   * it occurs exactly once among ALL of A's entries -- every `movm` prologue of
#     A's linear decode, every call target and every named address -- so that the
#     name cannot belong to an unnamed twin in A;
#   * and it occurs exactly once among B's entries.
# An ambiguous or weak match carries nothing. The output is a .sym file whose
# every row records the A address it came from and the length of the match.
#
# --fuzzy adds a second pass over what is left: whole routine bodies compared by
# tools/fn_similarity.py (every instruction control flow reaches, not just up to the
# first return; small immediates allowed to differ; callees and referenced strings
# checked by name), carrying a name only when the two routines are each other's best
# match in one of its classes exact / skeleton / fuzzy (its header has the rules).
# Those rows say "whole body" and give the class, the two similarity ratios and the
# number of callees or strings that agree.
#
# Usage:
#   port_names_by_code.py --a-rom A.rom --a-code LO:HI[:CPU] ... --a-sym A1.sym [A2.sym ...]
#                         --b-rom B.rom --b-base 0x... --b-code LO:HI[:CPU] ... --b-sym B.sym ...
#                         --b-labels B/src/labels.inc --out B_ported.sym --title "..."
#                         [--unidasm PATH] [--min 8] [--fuzzy [--cache DIR]]
#   B's unnamed entries come from a gen_image_s.py labels.inc (--b-labels), or, for
#   a source gen_program_s.py wrote (a KN7000 build ported from 941), from the
#   func_<ADDR> labels its .s files define (--b-src FILE ...); with --b-src, the
#   entries an earlier run named are read back from --out itself.
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


def kept(sig):
    """Instructions of a signature that have no number masked to "A"."""
    return sum(1 for i in sig if not re.search(r"\bA\b", i))


def all_entries(img):
    """File offsets of every routine start of img a name could belong to: each
    `movm [regs], (sp)` prologue of the linear decode, and each call target."""
    out = set()
    for o, (b, mnem, ops) in img.ix.items():
        if mnem == "movm" and b[:1] == b"\xcf":
            out.add(o)
        elif mnem in ("call", "calls"):
            t = GI.target_of(mnem, ops)
            t = img.off(t) if t is not None else None
            if t is not None:
                out.add(t)
    return out


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
    ap.add_argument("--b-labels", help="B's generated labels.inc (its entries)")
    ap.add_argument("--b-src", nargs="+", metavar="FILE",
                    help="instead of --b-labels: B's generated .s files (their func_<ADDR> labels)")
    ap.add_argument("--out", required=True)
    ap.add_argument("--title", required=True)
    ap.add_argument("--min", type=int, default=8,
                    help="fewest instructions with nothing masked a carried signature has")
    ap.add_argument("--unidasm", default=os.environ.get("UNIDASM", "../../tools/unidasm"))
    ap.add_argument("--fuzzy", action="store_true",
                    help="then compare whole routine bodies (tools/fn_similarity.py)")
    ap.add_argument("--cache", help="keep unidasm's decodes in this directory between runs")
    a = ap.parse_args()

    if a.cache:
        import fn_similarity as FS
        A = FS.cached_image(a.a_rom, a.a_base, ranges(a.a_code, a.a_base), a.unidasm, a.cache)
        B = FS.cached_image(a.b_rom, a.b_base, ranges(a.b_code, a.b_base), a.unidasm, a.cache)
    else:
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
    if (a.b_labels is None) == (a.b_src is None):
        sys.exit("port_names_by_code: give exactly one of --b-labels and --b-src")
    if a.b_labels:
        for nm, v in re.findall(r"^\.equ\s+(\w+),\s*0x([0-9a-fA-F]+)", open(a.b_labels).read(), re.M):
            if re.fullmatch(r"func_[0-9A-F]{8}", nm) or nm in before:
                b_entries[int(v, 16)] = nm
    else:
        for path in a.b_src:              # .s files hold raw ROM bytes: read them as bytes
            for m in re.finditer(rb"^func_([0-9A-F]{8}):", open(path, "rb").read(), re.M):
                b_entries[int(m.group(1), 16)] = "func_" + m.group(1).decode()
        if os.path.exists(a.out):
            b_entries.update(load([a.out]))

    sa, weak = {}, 0
    for cpu, nm in a_names.items():
        s = signature(A, A.off(cpu))
        if not s:
            continue
        if kept(s) < a.min:
            weak += 1
            continue
        sa.setdefault(s, []).append((cpu, nm))
    # every routine start of A, named or not: a signature two of them share is
    # ambiguous even when only one of the two is named
    a_starts = all_entries(A) | {A.off(cpu) for cpu in a_names}
    a_count = {}
    for o in a_starts:
        s = signature(A, o)
        if s in sa:
            a_count[s] = a_count.get(s, 0) + 1
    sb = {}
    for cpu in list(b_entries) + list(b_named):
        o = B.off(cpu)
        if o is None:
            continue
        s = signature(B, o)
        if s and kept(s) >= a.min:
            sb.setdefault(s, []).append(cpu)

    rows, skipped_taken, twins = [], 0, 0
    for s, alist in sa.items():
        if len(alist) != 1 or len(sb.get(s, ())) != 1:
            continue
        if a_count.get(s, 0) != 1:
            twins += 1
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

    fz, fz_rejected = [], {}
    if a.fuzzy:
        import fn_similarity as FS
        carried = {bcpu: nm for bcpu, nm, _acpu, _n in rows}
        b_names = {cpu: nm for cpu, nm in b_named.items()
                   if not nm.endswith("_entry") and B.off(cpu) is not None}
        b_names.update(carried)
        SA = FS.Side(A, a_names, {})
        SB = FS.Side(B, b_names, {cpu: nm for cpu, nm in b_entries.items() if cpu not in carried})
        a_cands = {A.off(cpu): nm for cpu, nm in a_names.items() if nm not in carried.values()}
        b_open = {B.off(cpu) for cpu in b_entries if cpu not in carried and B.off(cpu) is not None}
        fz, fz_rejected, _differs = FS.carry(SA, SB, a_cands, b_open, b_taken)
        fz.sort()

    with open(a.out, "w") as f:
        f.write(f"; {a.title}\n")
        f.write("; GENERATED by kn7000/tools/port_names_by_code.py -- do not edit; its header says\n")
        f.write("; how a name qualifies. Columns: B address, name, ; the A address it was carried\n")
        f.write("; from and the number of instructions that matched (entry to first return).\n;\n")
        f.write(f"; {len(rows)} names carried ({len(a_names)} candidates in A, {len(a_starts)} "
                f"routine starts in A, {len(b_entries)} unnamed entries in B)\n")
        f.write(f"; not carried: {weak} A signatures with fewer than {a.min} unmasked instructions; "
                f"{twins} with a twin among A's routine starts;\n; {skipped_taken} whose name "
                f"is taken in B\n")
        if a.fuzzy:
            by = {c: sum(1 for r in fz if r.cls == c) for c in ("exact", "skeleton", "fuzzy")}
            f.write(f"; --fuzzy, whole bodies (tools/fn_similarity.py): {len(fz)} more names carried "
                    f"({by['exact']} exact, {by['skeleton']} skeleton, {by['fuzzy']} fuzzy); not carried:\n")
            for why, n in sorted(fz_rejected.items()):
                f.write(f";   {n:5d} {why}\n")
        out = [(bcpu, f"0x{bcpu:08X}  {nm}\t; = 0x{acpu:08X}, {n} insns\n") for bcpu, nm, acpu, n in rows]
        out += [(r.b_cpu, f"0x{r.b_cpu:08X}  {r.name}\t; = 0x{r.a_cpu:08X}, whole body {r.n} insns, "
                          f"{r.cls} (ratios {r.sk:.3f}/{r.st:.3f}, {r.agree} callees or strings agree)\n")
                for r in fz]
        for _bcpu, line in sorted(out):
            f.write(line)
    print(f"port_names_by_code: {len(rows) + len(fz)} names -> {a.out}"
          + (f" ({len(fz)} by whole body)" if a.fuzzy else ""))


if __name__ == "__main__":
    main()
