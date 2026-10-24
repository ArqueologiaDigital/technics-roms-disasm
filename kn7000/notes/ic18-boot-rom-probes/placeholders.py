#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# How many labels of src/ic18/boot.s are still address placeholders, by kind?
# (func_/loc_ code, data_/rodata_/str_ data in the image, bss_ RAM past it,
# Old*_ the older link's.) A loc_ branch target is a placeholder by design: the
# routine it is inside carries the name.
#
#   python3 -I placeholders.py ../../src/ic18/boot.s [--list KIND]
import collections
import re
import sys

src = open(sys.argv[1], encoding="latin1").read()
defined = set(re.findall(r"^([A-Za-z_]\w*):", src, re.M)) | set(re.findall(r"^\.equ (\w+),", src, re.M))
kinds = collections.Counter()
by_kind = collections.defaultdict(list)
for name in sorted(defined):
    m = re.fullmatch(r"(func|loc|data|rodata|str|bss|old_loc|old_data|Old_func|OldLink)_[0-9A-F]{8}", name)
    if m:
        kinds[m.group(1)] += 1
        by_kind[m.group(1)].append(name)
total = len(defined)
for k, n in sorted(kinds.items()):
    print(f"{k:10s} {n:5d}")
print(f"{'named':10s} {total - sum(kinds.values()):5d}  of {total} labels and .equ's")
if "--list" in sys.argv:
    print(" ".join(by_kind[sys.argv[sys.argv.index("--list") + 1]]))
