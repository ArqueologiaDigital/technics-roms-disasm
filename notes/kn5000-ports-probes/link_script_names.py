#!/usr/bin/env python3
r"""Do the KN5000 main-program trees' C link scripts give each name its tree's address?

QUESTION THIS ANSWERS
    The C data of each main-program tree (v10, v9, v7, v6, v5) is linked by small scripts,
    TREE/maincpu/**/*_link.ld, whose lines `Name = 0x...;` give the ROM labels the C names.  A line
    whose address is not the tree's own ELF address of that name compiles a wrong pointer, which the
    tree's divergence json (v7: apply_v7_c_divergence.py, v6 / v5: apply_c_divergence.py) then has
    to patch, or which lands in bytes the image does not use.  Which lines disagree with the ELF?

    A row "wrong" is such a line (name, script address, ELF address).  Names the ELF does not define
    (RAM, other ROMs) are not judged.  The goal is 0 wrong lines in every tree.

RUN (repository root; the trees built)
    python3 notes/kn5000-ports-probes/link_script_names.py [TREE ...]
    Exit status 1 when any line is wrong.
"""
import glob
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NM = os.path.expanduser("~/compartilhado/llvm-project/build/bin/llvm-nm")
LINE = re.compile(r"^([A-Za-z_]\w*)\s*=\s*0x([0-9A-Fa-f]+);", re.M)


def elf(tree):
    out = subprocess.run([NM, "--defined-only", os.path.join(ROOT, "rebuilt_ROMs", "kn5000_%s_program.llvm.elf" % tree)],
                         capture_output=True, text=True, check=True).stdout
    d = {}
    for ln in out.split("\n"):
        p = ln.split()
        if len(p) == 3 and p[1] in "tT":
            d.setdefault(p[2], int(p[0], 16))
    return d


def main():
    trees = sys.argv[1:] or ["v10", "v9", "v7", "v6", "v5"]
    bad = 0
    for t in trees:
        syms = elf(t)
        n = w = 0
        for p in sorted(glob.glob(os.path.join(ROOT, t, "maincpu", "**", "*_link.ld"), recursive=True)):
            for m in LINE.finditer(open(p, encoding="latin-1").read()):
                name, v = m.group(1), int(m.group(2), 16)
                if name not in syms or not 0xE00000 <= v < 0x1000000:
                    continue
                n += 1
                if syms[name] != v:
                    w += 1
                    print("%s wrong %s %s = 0x%06x, ELF 0x%06x" % (t, os.path.relpath(p, ROOT), name, v, syms[name]))
        print("%s: %d link-script lines judged, %d wrong" % (t, n, w))
        bad += w
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
