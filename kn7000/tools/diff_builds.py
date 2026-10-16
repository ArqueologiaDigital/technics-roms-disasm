#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Report the change-regions between two linear KN7000 flash images (same base
# address), collapsing runs of differences separated by <= GAP identical bytes.
# Answers: "across these two firmware builds, what actually changed, and where?"
#
# Usage:  diff_builds.py <old.rom> <new.rom> <base_hex> [gap]
#   base_hex : CPU address of offset 0 (0x48400000 program / 0x48000000 table)
import sys

def runs(a, b, base, gap=16):
    n = min(len(a), len(b))
    diffs = [i for i in range(n) if a[i] != b[i]]
    diffs += list(range(n, max(len(a), len(b))))   # length mismatch = all-diff tail
    if not diffs:
        return [], 0
    merged = []
    s = p = diffs[0]
    for i in diffs[1:]:
        if i - p <= gap:
            p = i
        else:
            merged.append((s, p)); s = p = i
    merged.append((s, p))
    return [(base + s, base + e, e - s + 1) for s, e in merged], len(diffs)

if __name__ == "__main__":
    if len(sys.argv) not in (4, 5):
        sys.exit(__doc__)
    a = open(sys.argv[1], "rb").read()
    b = open(sys.argv[2], "rb").read()
    base = int(sys.argv[3], 16)
    gap = int(sys.argv[4]) if len(sys.argv) == 5 else 16
    r, nd = runs(a, b, base, gap)
    tot = max(len(a), len(b))
    print(f"{nd} bytes differ ({100*nd/tot:.3f}% of {tot:#x}), "
          f"{len(r)} change-regions (gap<={gap}):")
    for s, e, ln in r:
        print(f"  0x{s:08X}-0x{e:08X}  ({ln} bytes)")
