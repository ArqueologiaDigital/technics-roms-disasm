#!/usr/bin/env python3
r"""Is v10 routine X the same code as v7 routine Y?

QUESTION ANSWERED
    The hand ports in analysis/header-propagation/handport-2026-10-24.txt rename a callee in
    a v10 header to the label v7 uses for it (v7 often still has a placeholder name), and
    accept a header over a span whose v7 text is spelled differently.  Both need the same
    evidence: the ROM bytes at X (v10 image) and at Y (v7 image) are equal except for
      * 2-byte RAM operands related by the measured v10 -> v7 RAM map
        (analysis/header-propagation/v7-ram-shift-2026-10-24.txt, from
        scripts/analysis/v7_ram_shift_map.py), and
      * 3-byte ROM pointers (0xE00000-0xFFFFFF in both), counted and reported.
    It prints, per pair, the differences it could not explain (none = the same code modulo
    relocation) and the labels found N bytes on in each image, which shows whether a span ends
    at the same place.

RUN
    make all
    python3 scripts/analysis/v7_routine_equivalence.py X=Y=N [X=Y=N ...]
    e.g. CmpRealTtl_EnterTitle_Impl=RhythmFillIn_PatternTable_Code_Helper=60  FDC_CMD_EXEC=FDC_CMD_EXEC=672
"""
import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, "scripts", "tools"))
import propagate_v10_headers as P  # noqa: E402

MAP = os.path.join(REPO, "analysis", "header-propagation", "v7-ram-shift-2026-10-24.txt")


def load_runs(path=MAP):
    runs = []
    for line in open(path):
        m = re.match(r'^0x([0-9a-f]+)\s+0x([0-9a-f]+)\s+([+-]\d+)', line)
        if m:
            runs.append((int(m.group(1), 16), int(m.group(2), 16), int(m.group(3))))
    return runs


def delta(runs, v):
    for lo, hi, d in runs:
        if lo <= v <= hi:
            return d
    return None


def compare(src, dst, runs, x, y, n):
    a = src.rom[src.addr[x] - 0xE00000:][:n]
    b = dst.rom[dst.addr[y] - 0xE00000:][:n]
    i, unexplained, ram, ptr = 0, [], 0, 0
    while i < min(len(a), len(b)):
        if a[i] == b[i]:
            i += 1
            continue
        for j in (i - 1, i):
            if j >= 0:
                va, vb = int.from_bytes(a[j:j + 2], "little"), int.from_bytes(b[j:j + 2], "little")
                d = delta(runs, va)
                if d is not None and va + d == vb:
                    i, ram = j + 2, ram + 1
                    break
        else:
            for j in (i - 2, i - 1, i):
                if j >= 0:
                    va, vb = int.from_bytes(a[j:j + 3], "little"), int.from_bytes(b[j:j + 3], "little")
                    if 0xE00000 <= va <= 0xFFFFFF and 0xE00000 <= vb <= 0xFFFFFF:
                        i, ptr = j + 3, ptr + 1
                        break
            else:
                unexplained.append(i)
                i += 1
    end_a = sorted(k for k, v in src.addr.items() if v == src.addr[x] + n)
    end_b = sorted(k for k, v in dst.addr.items() if v == dst.addr[y] + n)
    return unexplained, ram, ptr, end_a, end_b


def main():
    runs = load_runs()
    src, dst = P.Tree("v10"), P.Tree("v7")
    src.load_elf()
    dst.load_elf()
    for arg in sys.argv[1:]:
        x, y, n = arg.split("=")
        un, ram, ptr, ea, eb = compare(src, dst, runs, x, y, int(n))
        verdict = "SAME modulo the RAM map" if not un else "DIFFERENT at +%s" % ", +".join(map(str, un[:8]))
        print("%s (v10 0x%06x) vs %s (v7 0x%06x), %s bytes: %s; %d RAM operands mapped, %d pointers "
              "relocated; labels at the end: v10 %s, v7 %s" % (x, src.addr[x], y, dst.addr[y], n,
                                                              verdict, ram, ptr, ea[:2], eb[:2]))


if __name__ == "__main__":
    main()
