#!/usr/bin/env python3
r"""port_ram_names.py -- give a ported KN5000 main-program tree (v6, v5) v7's RAM variable names.

QUESTION THIS ANSWERS / JOB IT DOES
    v6/maincpu and v5/maincpu were ported from v7 (port_maincpu_version.py) on 2026-10-24, the day
    v7 got shared/ram_variables_by_use.s (8cfaef2e0, WP17: the main-CPU RAM variables named from the
    code that uses them).  The port ran on the v7 of before, so the ported trees have no such file and
    spell those variables as numbers (`ld a, (0x25ea:16)`), and their NAKA C spells the RAM-address
    tables of naka_widget_descriptors.c (AppEvtHandler_Branch_002_RamPtrs, AppEvent_SubDispatch_RamPtrs)
    as v7's numbers, which v6 / v5's C-divergence json then patches as raw bytes.  Which of v7's names
    can be given each tree's own value, from the same instructions in the same routines?  v6 takes them
    from v7, v5 from v6 (each from the tree it was ported from; run v6 first).

HOW
    1. TREE/maincpu/shared/ram_variables_by_use.s is written from v7's file: the same lines (names,
       reasons), with the source tree's values for the moment, and TREE's shared/ram_variables.s includes it where
       v7's does.  A name the tree already defines (label, .equ, .set) is left out.  On a rerun a line
       the file already has is kept as it is (its value was derived, and its uses are names now).
    2. scripts/tools/name_kn5000_ram.py --tree TREE --ref v7 --apply derives each name's TREE value:
       every v7 routine whose body has the same instruction shapes in TREE (same label, same count,
       numbers and names blanked) votes, operand by operand, for the number TREE has where v7 has the
       name; a name is applied only when all its votes agree.  Its .equ is corrected to that value (the
       comment says so) and TREE's numeric operands of that value take the name.
    3. A name of the file that TREE's code does not use after step 2 had no vote (or disagreeing
       ones): it is dropped, so no line keeps v7's value (the convention of the other trees' files).
    4. The tree is rebuilt and must be byte-identical (make's own rule; else it stops: git checkout).
    Then ported_c_rebase.py --ram-names (lane open11/v6v5-port2) spells the C's RAM-address tables
    with these names, and gen_naka_gui_headers.py gives naka_ram_cells.h their TREE values.

RUN (tree built: make all)
    python3 scripts/converters/port_ram_names.py --tree v6
    python3 scripts/converters/port_ram_names.py --tree v5
"""
import argparse
import glob
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
FILE = "shared/ram_variables_by_use.s"
SRC = {"v6": "v7", "v5": "v6"}     # the tree each was ported from
INCLUDE = ("; variables named from their uses (audit WP17): one file, so that the naming lane owns it\n"
           "\t.include \"shared/ram_variables_by_use.s\"\n")
ANCHOR = "; the live panel records (TLV payloads), named from SndParam_BlockRamPtrs\n"
HEADER = ("; ram_variables_by_use.s -- main-CPU RAM variables named from the code that uses them (audit WP17).\n"
          "; The names and reasons are v10's, through %s's copy (%s/maincpu/shared/ram_variables_by_use.s); the\n"
          "; values here are %s's own, derived by scripts/tools/name_kn5000_ram.py --ref %s from the same\n"
          "; instructions in the same routines of %s (scripts/converters/port_ram_names.py; a corrected line\n"
          "; says so).  Names it could not derive for %s are left out.\n")
EQU = re.compile(r'^\s*\.equ\s+([A-Za-z_]\w*)\s*,')


def rd(p):
    return open(p, "rb").read().decode("latin-1")


def wr(p, s):
    open(p, "wb").write(s.encode("latin-1"))


def defined(tree, skip):
    out = set()
    for f in glob.glob(os.path.join(ROOT, tree, "maincpu", "**", "*.s"), recursive=True):
        if os.path.abspath(f) == os.path.abspath(skip):
            continue
        for l in rd(f).split("\n"):
            m = re.match(r'^([A-Za-z_][\w$]*):', l) or re.match(r'^\s*\.(?:equ|set)\s+([A-Za-z_]\w*)', l)
            if m:
                out.add(m.group(1))
    return out


def used_names(tree, names, skip):
    rx = re.compile(r'\b(%s)\b' % "|".join(map(re.escape, sorted(names, key=len, reverse=True))))
    used = set()
    for f in glob.glob(os.path.join(ROOT, tree, "maincpu", "**", "*.s"), recursive=True):
        if os.path.abspath(f) == os.path.abspath(skip):
            continue
        for l in rd(f).split("\n"):
            code = l.split(";")[0]
            if not code.lstrip().startswith(".equ"):
                used |= set(rx.findall(code))
    return used


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tree", required=True, choices=("v6", "v5"))
    a = ap.parse_args()
    dst = os.path.join(ROOT, a.tree, "maincpu", FILE)
    rv = os.path.join(ROOT, a.tree, "maincpu", "shared", "ram_variables.s")
    sref = SRC[a.tree]
    src = rd(os.path.join(ROOT, sref, "maincpu", FILE)).split("\n")
    have = defined(a.tree, dst)
    # a rerun keeps the lines an earlier run derived: their uses are names now and cannot vote again
    # (name_kn5000_ram.py trusts the value of a name the code already uses)
    old = {}
    if os.path.exists(dst):
        for l in rd(dst).split("\n"):
            if EQU.match(l):
                old[EQU.match(l).group(1)] = l
    body = [old.get(EQU.match(l).group(1), l) for l in src if EQU.match(l) and EQU.match(l).group(1) not in have]
    skipped = [EQU.match(l).group(1) for l in src if EQU.match(l) and EQU.match(l).group(1) in have]
    wr(dst, HEADER % (sref, sref, a.tree, sref, sref, a.tree) + "\n".join(body) + "\n")
    s = rd(rv)
    if INCLUDE not in s:
        assert s.count(ANCHOR) == 1, "ram_variables.s: anchor line not found"
        wr(rv, s.replace(ANCHOR, INCLUDE + ANCHOR))
    print("%s: %d of %s's %d names written (%d the tree defines already: %s)"
          % (a.tree, len(body), sref, len(body) + len(skipped), len(skipped), " ".join(skipped)))
    # name_kn5000_ram.py reads the tree's ram_variables_by_use.s as one of its constants files
    r = subprocess.run([sys.executable, os.path.join(ROOT, "scripts", "tools", "name_kn5000_ram.py"),
                        "--tree", a.tree, "--ref", sref, "--apply"], cwd=ROOT, capture_output=True, text=True)
    sys.stdout.write(r.stdout)
    if r.returncode:
        sys.exit(r.stderr)
    names = {EQU.match(l).group(1) for l in body}
    used = used_names(a.tree, names, dst)
    L = rd(dst).split("\n")
    keep = [l for l in L if not EQU.match(l) or EQU.match(l).group(1) in used]
    dropped = sorted(names - used)
    wr(dst, "\n".join(keep))
    print("%s: %d names kept (the code uses them), %d dropped (no agreeing vote)" % (a.tree, len(used), len(dropped)))
    r = subprocess.run(["make", "-s", "rebuilt_ROMs/kn5000_%s_program.llvm.rom" % a.tree], cwd=ROOT,
                       capture_output=True, text=True)
    built = os.path.join(ROOT, "rebuilt_ROMs", "kn5000_%s_program.llvm.rom" % a.tree)
    ref = os.path.join(ROOT, "original_ROMs", "kn5000_%s_program.rom" % a.tree)
    if r.returncode != 0 or open(built, "rb").read() != open(ref, "rb").read():
        sys.stderr.write(r.stderr[-3000:])
        sys.exit("%s: not byte-identical; undo with git checkout %s/maincpu" % (a.tree, a.tree))
    print("%s: byte-identical" % a.tree)


if __name__ == "__main__":
    main()
