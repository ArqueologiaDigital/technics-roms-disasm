#!/usr/bin/env python3
"""carry_v10_renames.py -- carry a reviewed v10 rename batch to v9, v7, v6 and v5, with a byte proof per label.

QUESTION IT ANSWERS / JOB IT DOES
  apply_kn5000_naming_proposals.py renames v10 only, and harmonize_version_labels.py carries names to v9 / v7
  but not to v6 / v5 (ported from v7 by port_maincpu_version.py, so they carry v7's names).  Every tree defines
  most old labels of a batch under the SAME name, so the rename can be made by name -- provided the label sits on
  the same thing.  For each record of the proposal files (verdict "name") and each tree in --trees:
    * the old name must be defined in the tree and the new one must not;
    * PROOF, labels: the 12 ROM bytes at the old label's address in the tree's linked ELF equal the 12 bytes at
      the old label's address in v10's ELF, except where a 3-byte run is a ROM address (0xE00000-0xFFFFFF) in both
      (a call target or pointer the two builds place differently).  Anything else skips the label.
    * PROOF, absolute symbols (.equ / .set): the same value in both ELFs.
  Run it BEFORE the v10 rename (it reads v10's ELF under the old names), after `make all`.
  The header of each record goes above the label line, as in apply_kn5000_naming_proposals.py.  The rules are
  written to scripts/renaming/rename_kn5000_naming_<tag>_<tree>.sed and applied to the tree's *.s, *.ld, *.h
  and the code segments of its *.c files (never a C comment).

RUN (repository root)
  make all
  python3 scripts/renaming/carry_v10_renames.py TAG proposals.json ... [--trees v9,v7,v6,v5] [--apply]
  python3 scripts/renaming/apply_kn5000_naming_proposals.py TAG proposals.json ... --apply      (v10)
  make gate
"""
import glob
import json
import os
import re
import subprocess
import sys
import textwrap

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "scripts/converters"))
from name_resname_strings import segments   # noqa: E402

NM = os.path.expanduser("~/compartilhado/llvm-project/build/bin/llvm-nm")
BASE = 0xE00000


def syms(tree):
    elf = os.path.join(ROOT, "rebuilt_ROMs", "kn5000_%s_program.llvm.elf" % tree)
    out = subprocess.run([NM, "--defined-only", elf], capture_output=True, text=True, check=True).stdout
    s = {}
    for l in out.split("\n"):
        p = l.split()
        if len(p) == 3:
            s[p[2]] = (p[1], int(p[0], 16))
    return s


def rom(tree):
    return open(os.path.join(ROOT, "rebuilt_ROMs", "kn5000_%s_program.llvm.rom" % tree), "rb").read()


def same_bytes(a, b):
    """12 bytes equal, except 3-byte runs that are ROM addresses in both."""
    if len(a) != len(b):
        return False
    i = 0
    while i < len(a):
        if a[i] == b[i]:
            i += 1
            continue
        # a differing byte: accept if it is inside a 3-byte little-endian ROM address in both
        for s in (i - 2, i - 1, i):
            if s >= 0 and s + 3 <= len(a) and 0xE0 <= a[s + 2] <= 0xFF and 0xE0 <= b[s + 2] <= 0xFF:
                i = s + 3
                break
        else:
            return False
    return True


def main():
    apply = "--apply" in sys.argv
    args = [a for a in sys.argv[1:] if a != "--apply"]
    trees = ["v9", "v7", "v6", "v5"]
    if "--trees" in args:
        k = args.index("--trees")
        trees = args[k + 1].split(",")
        del args[k:k + 2]
    tag, files = args[0], args[1:]
    recs = [r for f in files for r in json.load(open(f)) if r.get("verdict") == "name"]
    s10, r10 = syms("v10"), rom("v10")
    for tree in trees:
        st, rt = syms(tree), rom(tree)
        tdir = os.path.join(ROOT, tree, "maincpu")
        defs = {}
        for p in sorted(glob.glob(os.path.join(tdir, "**", "*.s"), recursive=True)):
            for i, x in enumerate(open(p, "rb").read().decode("latin-1").split("\n")):
                m = re.match(r'^([A-Za-z_][\w$]*):', x)
                if m:
                    defs.setdefault(m.group(1), (p, i))
        ren, skipped = [], []
        for r in recs:
            o, n = r["old"], r["new"]
            if o not in st:
                skipped.append((o, "not defined"))
                continue
            if n in st:
                skipped.append((o, "%s already defined" % n))
                continue
            if o not in s10:
                skipped.append((o, "not in v10's ELF"))
                continue
            kt, at = st[o]
            k10, a10 = s10[o]
            if kt in "aA" or k10 in "aA":
                if (kt, at) != (k10, a10):
                    skipped.append((o, "value 0x%x differs from v10's 0x%x" % (at, a10)))
                    continue
            else:
                bt, b10 = rt[at - BASE:at - BASE + 12], r10[a10 - BASE:a10 - BASE + 12]
                if not same_bytes(bt, b10):
                    skipped.append((o, "bytes differ from v10's (%s vs %s)" % (bt.hex(), b10.hex())))
                    continue
            ren.append(r)
        print("%s: %d renames, %d skipped" % (tree, len(ren), len(skipped)))
        for x in skipped:
            print("    skip %-50s %s" % x)
        if not apply or not ren:
            continue
        byfile = {}
        for r in ren:
            if r["old"] in defs:
                p, i = defs[r["old"]]
                byfile.setdefault(p, []).append((i, r))
        for p, items in byfile.items():
            L = open(p, "rb").read().decode("latin-1").split("\n")
            for i, r in sorted(items, key=lambda x: -x[0]):
                h = " ".join((r.get("header") or "").split())
                if not h:
                    continue
                lines = ["; " + x for x in textwrap.wrap("%s: %s" % (r["new"], h), 116, subsequent_indent="  ")]
                if lines[0] not in L[max(0, i - 6):i]:
                    L[i:i] = lines
            open(p + ".tmp", "wb").write("\n".join(L).encode("latin-1"))
            os.replace(p + ".tmp", p)
        rmap = {r["old"]: r["new"] for r in ren}
        rx = re.compile(r'\b(%s)\b' % "|".join(sorted(map(re.escape, rmap), key=len, reverse=True)))
        hit = subprocess.run(["grep", "-rlwE", "|".join(map(re.escape, rmap)), tdir, "--include=*.s", "--include=*.c",
                              "--include=*.h", "--include=*.ld"], capture_output=True, text=True).stdout.split()
        for q in hit:
            t = open(q, "rb").read().decode("latin-1")
            if q.endswith(".c"):
                t = "".join(rx.sub(lambda m: rmap[m.group(1)], seg) if k == "code" else seg for k, seg in segments(t))
            else:
                t = rx.sub(lambda m: rmap[m.group(1)], t)
            open(q + ".tmp", "wb").write(t.encode("latin-1"))
            os.replace(q + ".tmp", q)
        sed = os.path.join(ROOT, "scripts/renaming/rename_kn5000_naming_%s_%s.sed" % (tag, tree))
        open(sed, "w").write("# written by scripts/renaming/carry_v10_renames.py\n"
                             + "".join("s/\\b%s\\b/%s/g\n" % (o, n) for o, n in rmap.items()))
        print("    renamed in %d files" % len(hit))


if __name__ == "__main__":
    main()
