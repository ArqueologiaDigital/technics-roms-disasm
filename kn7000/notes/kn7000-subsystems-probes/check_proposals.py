#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Question: "is every proposed name for a program-941 func_<ADDR> routine well formed, new in every
# MN10300 tree, placed on a func_ routine start, and backed by a stated evidence class?"
#
# Input: TSV files, one proposal per line:  ADDR <tab> NAME <tab> CLASS <tab> EVIDENCE
# (lines starting with '#' are skipped).  CLASS is one of the classes below.  With --rows it
# prints the kn7000_manual.sym rows (`0xADDR  NAME  ; [CLASS] EVIDENCE`), sorted by address.
#
#     python3 -I kn7000/notes/kn7000-subsystems-probes/check_proposals.py FILE.tsv ... [--rows]
#
# (run from the repository root, after `make -C kn7000 build/kn7000_program.rom`).
import argparse
import glob
import re
import sys

CLASSES = {
    "STR":    "a firmware string the routine itself uses (screen text, message, file name / pattern, format)",
    "TABLE":  "a firmware table names it or its slot (reflection / class-procedure / name table, M3 id table)",
    "WRAP":   "its whole body is one call of a named routine with constant arguments, or a named routine's twin",
    "CALLEE": "what it does, read from the named routines it calls and the arguments it passes them",
    "CALLER": "its callers are all in one named subsystem, and its body does what the name says",
    "RAM":    "the named RAM it reads / writes (accessor, flag, counter, record of a named owner)",
    "IO":     "the named I/O registers or hardware windows it drives",
    "BODY":   "a self-contained helper whose body alone shows what it computes (string copy, clamp, ...)",
}
NAME = re.compile(r"^[A-Z][A-Za-z0-9_]{2,47}$")
BAD = re.compile(r"(func|loc|data|ram)_[0-9A-Fa-f]{6,8}|_entry$|^REC_|^Str_")


def defined_names():
    names = set()
    for f in glob.glob("kn7000/build/*.labels"):
        for line in open(f, encoding="latin-1"):
            p = line.split()
            if p:
                names.add(p[0])
    pats = ["kn7000/*.sym", "kn6000/*.sym", "kn6500/*.sym", "kn2400/*.sym", "hdsx3/*.sym",
            "kn7000/src/**/labels.sym", "kn6000/src/**/labels.sym", "kn6500/src/**/labels.sym",
            "kn2400/src/**/labels.sym", "kn7000/src/**/*.inc", "kn6000/src/*.inc", "kn6500/src/*.inc",
            "kn2400/src/*.inc", "hdsx3/src/*.inc"]
    # the other KN7000 images (IC18's boot ROM, the Style Convert converters) are not program trees: a
    # 941 routine with the same code as one of theirs takes its name, as the tree already does
    # (localeconv, PfFormatInteger ... = IC18), so their names are not "taken"
    other = {"kn7000/kn7000_ic18.sym", "kn7000/cnv_manual.sym"}
    for pat in pats:
        for f in glob.glob(pat, recursive=True):
            if f in other:
                continue
            for line in open(f, encoding="latin-1"):
                c = line.split(";", 1)[0].split("#", 1)[0]
                m = re.match(r"\s*(0x[0-9A-Fa-f]+)\s+(\w+)", c)
                if m:
                    names.add(m.group(2))
                    continue
                m = re.match(r"\s*\.equ\s+(\w+)", c)
                if m:
                    names.add(m.group(1))
                    continue
                m = re.match(r"\s*\.set\s+(\w+)", c)
                if m:
                    names.add(m.group(1))
    return names


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("files", nargs="+")
    ap.add_argument("--rows", action="store_true")
    ap.add_argument("--exclude", help="file of func_<ADDR> / 0xADDR left to another lane")
    a = ap.parse_args()
    labels = {}
    for line in open("kn7000/build/kn7000_program.labels", encoding="latin-1"):
        p = line.split()
        if len(p) == 2:
            labels[p[0]] = p[1]
    taken = defined_names()
    excl = set()
    if a.exclude:
        for line in open(a.exclude):
            for m in re.findall(r"[0-9A-Fa-f]{8}", line):
                excl.add(int(m, 16))
    seen_n, seen_a, rows, bad = {}, {}, [], 0
    for f in a.files:
        for ln, line in enumerate(open(f, encoding="utf-8"), 1):
            if not line.strip() or line.startswith("#"):
                continue
            p = line.rstrip("\n").split("\t")
            where = f"{f}:{ln}"
            if len(p) != 4:
                print(f"BAD   {where}: {len(p)} columns"); bad += 1; continue
            addr, name, cls, ev = (x.strip() for x in p)
            try:
                ad = int(addr, 16)
            except ValueError:
                print(f"BAD   {where}: address {addr!r}"); bad += 1; continue
            ph = f"func_{ad:08X}"
            errs = []
            if ph not in labels:
                errs.append(f"{ph} is not a routine label of 941")
            if not NAME.match(name) or BAD.search(name):
                errs.append(f"name {name!r} not well formed")
            if name in taken:
                errs.append(f"name {name} is defined already")
            if name in seen_n and seen_n[name] != ad:
                errs.append(f"name {name} proposed twice ({seen_n[name]:08X})")
            if ad in seen_a and seen_a[ad] != name:
                errs.append(f"address proposed twice ({seen_a[ad]} / {name})")
            for c in cls.split("+"):
                if c not in CLASSES:
                    errs.append(f"class {c!r} unknown")
            if len(ev) < 25:
                errs.append("evidence too short")
            if ad in excl:
                errs.append("left to another lane")
            if errs:
                print(f"BAD   {where}: {name}: " + "; ".join(errs)); bad += 1; continue
            seen_n[name], seen_a[ad] = ad, name
            rows.append((ad, name, cls, ev))
    print(f"# {len(rows)} good, {bad} bad", file=sys.stderr)
    if a.rows:
        for ad, name, cls, ev in sorted(rows):
            print(f"0x{ad:08X}  {name:26s} ; [{cls}] {ev}")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
