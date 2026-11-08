#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# derived_label_renames.py -- the data labels a generator derived from a func_<ADDR> name that a
# symbol file has since given the routine, as a sed script.
#
# QUESTION ANSWERED: "which labels of a tree's typed data still carry the placeholder name of a
# routine that is named now, and what are they called after it?"  gen_data_s.py names a datum after
# the routine that uses it (`func_48449462_Records`, `REC_func_4C0506C7_entry_L4_Records`,
# `Bitmap_func_4849AB47_2`) and keeps a label the converted code already spells, so a routine's
# new name never reaches the labels made from its old one.  For every label of the tree's
# labels.sym that contains `func_<ADDR>` where the tree's generated code labels the routine at ADDR
# with a name a symbol file of the tree gives (read from the code's label list: build/<image>.labels
# for the KN7000 builds, so build them after regenerating the code; src/labels.inc for the
# siblings), this writes one sed rule replacing the label by the same label with that name in place
# of `func_<ADDR>`.  With --only FILE (symbol-file rows) only the routines FILE names count.  A label whose new spelling is defined already, and a label that names a media
# file (its PNG is named after it), are left alone and listed on stderr.
#
# RUN (from the repository root):
#   python3 kn7000/tools/derived_label_renames.py TREE --out scripts/renaming/rename_X_TREE.sed
#   sed -i -f scripts/renaming/rename_X_TREE.sed <the tree's generated sources>
# TREE: 941 sp7001 b935 b893 kn6000 kn6500 kn2400 hdsx3.  --files prints the generated files the
# rules apply to (the ones that contain a renamed label), one per line.
import argparse
import glob
import os
import re
import sys

K = "kn7000"
CODE_LABELS = {"941": f"{K}/build/kn7000_program.labels", "sp7001": f"{K}/build/kn7000_program_sp7001.labels",
               "b935": f"{K}/build/kn7000_program_b935.labels", "b893": f"{K}/build/kn7000_program_b893.labels"}
TREES = {
    # tree: (symbol files naming routines, labels.sym, generated sources the labels appear in)
    "941":    ([f"{K}/kn7000.sym", f"{K}/kn7000_manual.sym", f"{K}/kn7000_exports_from_942.sym"],
               f"{K}/src/program/data", [f"{K}/src/program.s", f"{K}/src/program/*.s", f"{K}/src/program/data/*"]),
    "sp7001": ([f"{K}/kn7000_sp7001.sym", f"{K}/kn7000_sp7001_manual.sym", f"{K}/kn7000_sp7001_new.sym",
                f"{K}/kn7000_sp7001_exports.sym"],
               f"{K}/src/sp7001/program/data", [f"{K}/src/sp7001/program.s", f"{K}/src/sp7001/program/*.s",
                                                f"{K}/src/sp7001/program/data/*"]),
    "b935":   ([f"{K}/kn7000_b935.sym", f"{K}/kn7000_b935_manual.sym", f"{K}/kn7000_b935_exports.sym",
                f"{K}/kn7000_b935_own.sym", f"{K}/kn7000_b935_bycode.sym"],
               f"{K}/src/b935/program/data", [f"{K}/src/b935/program.s", f"{K}/src/b935/program/*.s",
                                              f"{K}/src/b935/program/data/*"]),
    "b893":   ([f"{K}/kn7000_b893.sym", f"{K}/kn7000_b893_manual.sym", f"{K}/kn7000_b893_exports.sym",
                f"{K}/kn7000_b893_own.sym", f"{K}/kn7000_b893_bycode.sym"],
               f"{K}/src/b893/program/data", [f"{K}/src/b893/program.s", f"{K}/src/b893/program/*.s",
                                              f"{K}/src/b893/program/data/*"]),
}
for _m in ("kn6000", "kn6500", "kn2400", "hdsx3"):
    TREES[_m] = ([f"{_m}/{_m}.sym", f"{_m}/{_m}_manual.sym", f"{_m}/{_m}_ported.sym", f"{_m}/{_m}_aligned.sym",
                  f"{_m}/src/program/data/functions.sym"],
                 f"{_m}/src/program/data", [f"{_m}/src/program.s", f"{_m}/src/labels.inc", f"{_m}/src/program/data/*"])

ROW = re.compile(r"^\s*0x([0-9A-Fa-f]{8})\s+([A-Za-z_]\w*)")
DERIVED = re.compile(r"func_([0-9A-F]{8})")


def sym_names(files):
    names = set()
    for f in files:
        if not os.path.exists(f):
            continue
        for line in open(f, encoding="latin-1"):
            m = ROW.match(line.split(";", 1)[0])
            if m and not m.group(2).endswith("_entry") and not m.group(2).startswith("func_"):
                names.add(m.group(2))
    return names


def code_labels(tree):
    """name -> address of every label the tree's generated code defines"""
    lab = {}
    if tree in CODE_LABELS:
        for line in open(CODE_LABELS[tree], encoding="latin-1"):
            p = line.split()
            if len(p) == 2:
                lab[p[0]] = int(p[1], 16)
    else:
        for f in (f"{tree}/src/labels.inc", f"{tree}/src/symbols.inc"):
            for line in open(f, encoding="latin-1"):
                m = re.match(r"\.equ\s+(\w+),\s*0x([0-9A-Fa-f]+)", line)
                if m:
                    lab[m.group(1)] = int(m.group(2), 16)
    return lab


def routine_names(tree, files, only):
    """address -> the routine name the code gives it (one of the symbol files' names)"""
    names = sym_names(files)
    if only is not None:
        names &= only
    by, amb = {}, set()
    for n, a in code_labels(tree).items():
        if n in names:
            if a in by and by[a] != n:
                amb.add(a)
            by[a] = n
    for a in amb:
        print(f"skip 0x{a:08X}: two routine names in the code", file=sys.stderr)
        del by[a]
    return by


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("tree", choices=sorted(TREES))
    ap.add_argument("--out")
    ap.add_argument("--title", default="data labels made from routine placeholder names, renamed after the routine")
    ap.add_argument("--files", action="store_true")
    ap.add_argument("--only", nargs="*", help="symbol files: only the routines they name")
    a = ap.parse_args()
    syms, ddir, srcs = TREES[a.tree]
    names = routine_names(a.tree, syms, sym_names(a.only) if a.only else None)
    labels = []
    for line in open(os.path.join(ddir, "labels.sym"), encoding="latin-1"):
        if not line.startswith(";") and line.strip():
            labels.append(line.split()[1])
    defined = set(labels)
    media = {os.path.splitext(os.path.basename(f))[0] for f in glob.glob(os.path.join(ddir, "media", "*"))}
    rules, skipped = [], []
    for lab in labels:
        new = DERIVED.sub(lambda m: names.get(int(m.group(1), 16), m.group(0)), lab)
        if new == lab:
            continue
        if new in defined:
            skipped.append(f"{lab} -> {new}: defined already")
            continue
        if lab in media:
            skipped.append(f"{lab}: a media file is named after it")
            continue
        defined.add(new)
        rules.append((lab, new))
    for s in skipped:
        print("skip", s, file=sys.stderr)
    if a.files:
        files = sorted({f for g in srcs for f in glob.glob(g) if os.path.isfile(f)})
        pat = re.compile(rb"\b(" + b"|".join(re.escape(o.encode()) for o, _ in rules) + rb")\b") if rules else None
        for f in files:
            if pat and pat.search(open(f, "rb").read()):
                print(f)
        return
    out = open(a.out, "w") if a.out else sys.stdout
    out.write(f"# {a.tree}: {a.title} (kn7000/tools/derived_label_renames.py {a.tree})\n")
    for o, n in rules:
        out.write(f"s/\\b{o}\\b/{n}/g\n")
    print(f"{a.tree}: {len(rules)} rules, {len(skipped)} left", file=sys.stderr)


if __name__ == "__main__":
    main()
