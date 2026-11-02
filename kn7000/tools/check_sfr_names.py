#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# check_sfr_names.py -- QUESTION ANSWERED: do the shared register includes and the IC18 boot ROM's
# own .equ rows give every on-chip register and board device the same name?
#
# src/include/mn103002a_sfr.inc (on-chip registers + the 0x360080xx latches, every MN10300 tree) and
# src/include/kn7000_board_io.inc (the KN7000 board's devices, the KN7000 program builds) are hand-
# written; src/ic18/boot.s carries the boot ROM's own copy (tools/gen_ic18_s.py).  Fails when one
# address has two names, one name two addresses, or a register boot.s names is missing from the
# include that covers its range.  RUN (from kn7000/):  python3 tools/check_sfr_names.py
import re
import sys

INCS = {"src/include/mn103002a_sfr.inc": (0x20000000, 0x40000000),
        "src/include/kn7000_board_io.inc": (0x98000000, 0xA0000000)}
EQU = re.compile(r"\.equ\s+(\w+),\s*(0x[0-9A-Fa-f]+)")


def rows(path):
    with open(path, "rb") as f:
        text = f.read().decode("latin1")
    return [(m.group(1), int(m.group(2), 16)) for m in map(EQU.match, text.splitlines()) if m]


bad = []
by_addr, by_name = {}, {}
for path in INCS:
    for nm, a in rows(path):
        if by_addr.setdefault(a, nm) != nm:
            bad.append(f"{path}: 0x{a:08X} is both {by_addr[a]} and {nm}")
        if by_name.setdefault(nm, a) != a:
            bad.append(f"{path}: {nm} is both 0x{by_name[nm]:08X} and 0x{a:08X}")
n = 0
for nm, a in rows("src/ic18/boot.s"):
    if not any(lo <= a < hi for lo, hi in INCS.values()):
        continue
    n += 1
    if a not in by_addr:
        bad.append(f"src/ic18/boot.s: {nm} 0x{a:08X} is in no include")
    elif by_addr[a] != nm:
        bad.append(f"src/ic18/boot.s: 0x{a:08X} is {nm} there, {by_addr[a]} in the include")
for b in bad:
    print("FAIL  " + b)
if bad:
    sys.exit(1)
print(f"OK    {len(by_addr)} register names in the includes; the {n} boot.s gives agree")
