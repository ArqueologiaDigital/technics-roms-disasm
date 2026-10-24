#!/usr/bin/env python3
r"""subcpu_version_address_map.py -- where does each sub-CPU payload label move between versions?

QUESTION THIS ANSWERS
    The v141 and v140 trees keep v142's comments, so every address quoted in a comment is a
    v1.42 address.  For a given pair of builds, what must be subtracted from a v1.42 address
    to get the same label's address in the other version, and over which address ranges?
    The banners of v141/subcpu and v140/subcpu state that map; this script measures it.

METHOD
    Reads the `t` (.text) symbols of two linked ELFs with llvm-nm, pairs them by name, and
    prints the runs of consecutive labels (in reference-address order) that share one shift
    (other address - reference address), with the first and last reference address of each
    run.  Labels defined in only one of the two ELFs are listed after the runs.  A run is
    only as fine as the labels: a shift change falls somewhere between the last label of one
    run and the first label of the next.

RUN
    make rebuilt_ROMs/kn5000_subprogram_v142.llvm.elf rebuilt_ROMs/kn5000_subprogram_v140.llvm.elf
    python3 scripts/analysis/subcpu_version_address_map.py \
        rebuilt_ROMs/kn5000_subprogram_v142.llvm.elf rebuilt_ROMs/kn5000_subprogram_v140.llvm.elf
    (default: v142 against v140)
"""
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NM = os.path.expanduser("~/compartilhado/llvm-project/build/bin/llvm-nm")


def text_symbols(elf):
    out = subprocess.run([NM, "--defined-only", elf], check=True, capture_output=True, text=True).stdout
    syms = {}
    for line in out.splitlines():
        p = line.split()
        if len(p) == 3 and p[1] == "t":
            syms[p[2]] = int(p[0], 16)
    return syms


def main():
    args = sys.argv[1:]
    if len(args) not in (0, 2):
        sys.exit(__doc__)
    ref, other = args or [os.path.join(ROOT, "rebuilt_ROMs/kn5000_subprogram_v142.llvm.elf"),
                          os.path.join(ROOT, "rebuilt_ROMs/kn5000_subprogram_v140.llvm.elf")]
    a, b = text_symbols(ref), text_symbols(other)
    print("reference %s (%d labels)\nother     %s (%d labels)"
          % (os.path.relpath(ref, ROOT), len(a), os.path.relpath(other, ROOT), len(b)))
    pairs = sorted((a[n], b[n], n) for n in a if n in b)
    runs = []
    for ra, rb, n in pairs:
        d = rb - ra
        if runs and runs[-1][0] == d:
            runs[-1][2], runs[-1][4], runs[-1][5] = ra, n, runs[-1][5] + 1
        else:
            runs.append([d, ra, ra, n, n, 1])
    print("\n%-9s  %-8s  %-8s  %6s  %s" % ("shift", "from", "to", "labels", "first .. last label"))
    for d, lo, hi, n0, n1, k in runs:
        print("%-9s  %08x  %08x  %6d  %s .. %s" % ("%+#x" % d if d else "0", lo, hi, k, n0, n1))
    only_a = sorted((a[n], n) for n in a if n not in b)
    only_b = sorted((b[n], n) for n in b if n not in a)
    print("\nonly in reference: %d" % len(only_a))
    for addr, n in only_a:
        print("  %08x %s" % (addr, n))
    print("only in other: %d" % len(only_b))
    for addr, n in only_b:
        print("  %08x %s" % (addr, n))


if __name__ == "__main__":
    main()
