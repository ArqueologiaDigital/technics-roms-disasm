#!/usr/bin/env python3
"""kn7000_names_missed: why does a KN7000 941 routine name not reach a sibling, when the
sibling has a routine with the same body?

Question it answers (lane open11/sibling-names, "library code identical to a named
KN7000 routine that port_names_by_code.py misses: measure why"): every routine name of
941's symbol files (kn7000_manual.sym, kn7000_exports_from_942.sym, kn7000.sym) that sits
at a routine start is put in one class:

  B has the name              the sibling names some routine so already
  no strict-equal body in B   no sibling routine start has the same whole body
                              (fn_similarity.Side.tokens(...).strict: every instruction
                              control flow reaches, relocations masked) -- the routine is
                              changed, or the sibling lacks it
  ... all named               the sibling's same-body routines all have other names
  kept<8 / kept>=8, A twins N, B open M
                              the same body exists unnamed in the sibling; kept = the
                              instructions with nothing masked (port_names_by_code.py
                              needs 8), A twins = how many 941 routine starts share the
                              body, B open = how many unnamed sibling starts do; only
                              "kept>=8, A twins 1, B open 1" is port_names_by_code.py's
                              own case

The names are read from the working tree, or with --rev REV from that commit
(`git show REV:path`), so the before / after of a change is measured by one script.
--a-range LO:HI counts only the 941 names in that CPU range (the tone-generator library
941 links at 0x4C000000: --a-range 0x4C000000:0x4C03DF30, the KN2400's RAM-linked twin);
"B has the name" is then split by where B has it (--b-range, the KN2400's 0x50120000..).

usage (from the repo root; needs the reference images, make -C <model> baserom and
make -C kn7000 baserom, and MAME's unidasm):
  python3 -I kn7000/notes/sibling-names-probes/kn7000_names_missed.py MODEL \
      [--rev REV] [--unidasm PATH] [--cache DIR] [--examples N] [--a-range LO:HI [--b-range LO:HI]]
  MODEL = kn6000 | kn6500 | kn2400 | hdsx3
"""
import argparse
import collections
import os
import re
import subprocess
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "kn7000", "tools"))
import fn_similarity as FS  # noqa: E402
import gen_image_s as GI  # noqa: E402
from port_names_by_code import ranges  # noqa: E402

MODELS = {   # base, code ranges (the Makefiles' CODE), symbol files besides functions.sym
    "kn6000": (0x4C000000, ["0x0:0xd", "0x80:0x176037", "0x3f47ec:0x3f77e7", "0x3f78b4:0x3f7a31"],
               "kn6000_program.rom"),
    "kn6500": (0x4C000000, ["0x0:0xd", "0x80:0x176839", "0x37e44c:0x381447", "0x381514:0x381691"],
               "kn6500_program.rom"),
    "kn2400": (0x48400000, ["0x0:0xf", "0x1e427c:0x3285be", "0x3285be:0x3965b8:0x50120000"],
               "kn2400_program.rom"),
    "hdsx3": (0x97800000, ["0x80:0x3ded6"], "hdsx3_extapr.rom"),
}
A_SYMS = ["kn7000/kn7000_manual.sym", "kn7000/kn7000_exports_from_942.sym", "kn7000/kn7000.sym"]


def text(path, rev):
    if rev:
        r = subprocess.run(["git", "-C", ROOT, "show", f"{rev}:{path}"], capture_output=True, text=True)
        return r.stdout if r.returncode == 0 else ""
    p = os.path.join(ROOT, path)
    return open(p).read() if os.path.exists(p) else ""


def syms(paths, rev):
    out = {}
    for p in paths:
        for line in text(p, rev).splitlines():
            if line.lstrip().startswith(";"):
                continue
            m = re.match(r"0x([0-9A-Fa-f]+)\s+([A-Za-z_]\w*)", line)
            if m:
                out.setdefault(int(m.group(1), 16), m.group(2))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("model", choices=sorted(MODELS))
    ap.add_argument("--rev")
    ap.add_argument("--unidasm", default=os.environ.get("UNIDASM", "/home/fsanches/compartilhado/mame-sony-video/unidasm"))
    ap.add_argument("--cache")
    ap.add_argument("--examples", type=int, default=0)
    ap.add_argument("--a-range")
    ap.add_argument("--b-range")
    a = ap.parse_args()
    m = a.model
    base, codes, rom = MODELS[m]
    A = FS.cached_image(os.path.join(ROOT, "kn7000/baserom/kn7000_program.rom"), 0x48400000,
                        ranges(["0x80:0x186000", "0x3b8fd1:0x3f6f01:0x4c000000"], 0x48400000), a.unidasm, a.cache)
    B = FS.cached_image(os.path.join(ROOT, m, "baserom", rom), base, ranges(codes, base), a.unidasm, a.cache)
    b_files = [f"{m}/{m}.sym", f"{m}/{m}_manual.sym", f"{m}/{m}_ported.sym", f"{m}/{m}_aligned.sym",
               f"{m}/src/program/data/functions.sym"]
    an = {c: n for c, n in syms(A_SYMS, None).items() if not n.endswith("_entry") and A.off(c) is not None}
    bn = {c: n for c, n in syms(b_files, a.rev).items() if not n.endswith("_entry") and B.off(c) is not None}
    bu = {}
    for nm, v in re.findall(r"^\.equ\s+(\w+),\s*0x([0-9a-fA-F]+)", text(f"{m}/src/labels.inc", a.rev), re.M):
        if re.fullmatch(r"func_[0-9A-F]{8}", nm):
            bu[int(v, 16)] = nm
    SA, SB = FS.Side(A, an, {}), FS.Side(B, bn, bu)
    bnames = {n.lower() for n in bn.values()}
    ga, gb = collections.defaultdict(list), collections.defaultdict(list)
    for o in SA.starts:
        t = SA.tokens(o)
        if t.n:
            ga[t.strict].append(o)
    for o in SB.starts:
        t = SB.tokens(o)
        if t.n:
            gb[t.strict].append(o)
    cat, ex = collections.Counter(), collections.defaultdict(list)
    rng = [int(x, 0) for x in a.a_range.split(":")] if a.a_range else None
    brng = [int(x, 0) for x in a.b_range.split(":")] if a.b_range else None
    b_at = {n.lower(): c for c, n in bn.items()}
    for cpu, nm in sorted(an.items()):
        if rng and not rng[0] <= cpu < rng[1]:
            continue
        o = A.off(cpu)
        if o not in SA.starts:
            cat["A name not at a routine start"] += 1
            continue
        if nm.lower() in bnames:
            if brng:
                inside = brng[0] <= b_at[nm.lower()] < brng[1]
                cat["B has the name, " + ("in --b-range" if inside else "elsewhere")] += 1
            else:
                cat["B has the name"] += 1
            continue
        t = SA.tokens(o)
        bs = gb.get(t.strict, [])
        if not bs:
            cat["no strict-equal body in B"] += 1
            continue
        k = "kept<8" if t.kept < 8 else "kept>=8"
        bopen = [x for x in bs if B.cpu(x) in bu and B.cpu(x) not in bn]
        if not bopen:
            cat[f"strict-equal bodies in B all named ({k})"] += 1
            continue
        na = len(ga[t.strict])
        key = f"{k}, A twins {na if na < 3 else '3+'}, B open {len(bopen) if len(bopen) < 3 else '3+'}"
        cat[key] += 1
        ex[key].append(nm)
    rows = sorted(cat.items(), key=lambda kv: (-kv[1], kv[0]))
    w = max(len(k) for k, _v in rows)
    print(f"{m}{' at ' + a.rev if a.rev else ''}: {sum(cat.values())} KN7000 941 routine names"
          + (f" in {a.a_range}" if rng else ""))
    print(f"| {'class'.ljust(w)} | names |")
    print(f"|{'-' * (w + 2)}|-------|")
    for k, v in rows:
        print(f"| {k.ljust(w)} | {v:5d} |")
    if a.examples:
        for k, v in sorted(ex.items()):
            print(f"{k}: {', '.join(v[:a.examples])}")


if __name__ == "__main__":
    main()
