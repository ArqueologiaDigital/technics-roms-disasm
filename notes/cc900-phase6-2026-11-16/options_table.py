#!/usr/bin/env python3
"""Which option sets reproduce each firmware C function?  An aligned Markdown table, one row per function.

QUESTION ANSWERED: for every function of TREE/cc900/*.c, are the reference model's bytes the ROM's at -O3 -XS -Xr,
and at -Xr (no -O)?  And which set does the build use (the file's `cc900-options:` comment, default -O3 -XS -Xr)?
A function that matches at only one set is evidence for the options its file was built with.

usage (from the repository root):
    python3 -B notes/cc900-phase6-2026-11-16/options_table.py [--tree v10/maincpu] [--rom ROM] [--symbols REF]
Defaults: v10/maincpu, original_ROMs/kn5000_v10_program.rom, symbols/maincpu_v10_symbols_reference.txt.
"""
import glob, os, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
sys.path.insert(0, os.path.join(REPO, "scripts", "build"))
sys.path.insert(0, os.path.join(REPO, "scripts", "analysis", "cc900", "model"))
import cc900_firmware_c as fw  # noqa: E402
import check_bytes             # noqa: E402
import fn_diff                 # noqa: E402


def opt(a, n, d):
    return a[a.index(n) + 1] if n in a else d


def main():
    a = sys.argv[1:]
    tree = os.path.join(REPO, opt(a, "--tree", "v10/maincpu"))
    rom = open(os.path.join(REPO, opt(a, "--rom", "original_ROMs/kn5000_v10_program.rom")), "rb").read()
    ref = check_bytes.load_reference(os.path.join(REPO, opt(a, "--symbols", "symbols/maincpu_v10_symbols_reference.txt")))
    names = fw.Names(fw.tree_values(tree), ref)
    real = fw.file_options
    rows = []
    for c in sorted(glob.glob(os.path.join(tree, "cc900", "*.c"))):
        used = real(c)[0]
        res = {}
        for flags in ("-O3 -XS -Xr", "-Xr"):
            fw.file_options = lambda p, f=flags: (f,) + fw.OPTION_SETS[f]
            for f, lines in fw.compile_c(c, names, spell=False).items():
                mine, r = fn_diff.compare(f, lines, rom, ref, 0xe00000)
                res.setdefault(f, {})[flags] = "yes" if mine == r else "no"
            fw.file_options = real
        for f, v in res.items():
            rows.append([f, os.path.basename(c), v["-O3 -XS -Xr"], v["-Xr"], used])
    head = ["function", "C file", "-O3 -XS -Xr", "-Xr", "built with"]
    w = [max(len(r[i]) for r in rows + [head]) for i in range(len(head))]
    fmt = lambda r: "| " + " | ".join(x.ljust(w[i]) for i, x in enumerate(r)) + " |"
    print(fmt(head))
    print("|" + "|".join("-" * (x + 2) for x in w) + "|")
    for r in rows:
        print(fmt(r))


if __name__ == "__main__":
    main()
