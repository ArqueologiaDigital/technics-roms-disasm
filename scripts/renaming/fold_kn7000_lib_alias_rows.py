#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""Fold kn7000_manual.sym's library alias rows into rows at the library address.

Question it answers: "which KN7000 library routines does kn7000_manual.sym name only
through the library image's FLASH copy (0x487B8FD1 + X - 0x4C000000), where the
generated source never shows the name?"

The library runs at 0x4C000000; tools/gen_program_s.py emits its code under that
address, so a name at the flash copy's address labels nothing (LibIrqScheduler was
func_4C03DE26 in the source).  A row `0xFLASH  Name ; = lib 0xLIB: ...` is
  * dropped when the symbol files already name 0xLIB (that row says the same);
  * moved to 0xLIB when 0xLIB is a routine start of the generated library source
    (a `func_<ADDR>:` label) or the register-save `call` entry right after the
    movm / `add -N, sp` prologue of a named routine (the .sed then renames it
    <routine>_entry);
  * otherwise left alone and listed (its library address is inside a routine).

Run from kn7000/, before scripts/renaming/rename_kn7000_lib_entries.sed:

    python3 ../scripts/renaming/fold_kn7000_lib_alias_rows.py kn7000_manual.sym
"""
import glob
import os
import re
import sys

sys.path.insert(0, os.path.join(os.getcwd(), "tools"))
import gen_image_s as GI  # noqa: E402

FLASH, LIB, END = 0x487B8FD1, 0x4C000000, 0x487F6F01
FILE_BASE = 0x3B8FD1                     # the library image's offset in the program ROM
path = sys.argv[1]
rom = open("baserom/kn7000_program.rom", "rb").read()
src = b"".join(open(f, "rb").read() for f in sorted(glob.glob("src/program/library_*.s")))
func_starts = {int(h, 16) for h in re.findall(rb"^func_(4C[0-9A-F]{6}):", src, re.M)}
named = {}
for f in ("kn7000_manual.sym", "kn7000_exports_from_942.sym", "kn7000.sym"):
    for line in open(f, encoding="utf-8"):
        m = re.match(r"0x([0-9A-Fa-f]+)\s+(\w+)", line)
        if m and not line.startswith(";"):
            named.setdefault(int(m.group(1), 16), m.group(2))
out, kept = [], []
for line in open(path, encoding="utf-8").read().split("\n"):
    m = re.match(r"0x([0-9A-Fa-f]{8})(\s+)(\w+)(\s+); = lib 0x([0-9A-Fa-f]{8}): (.*)$", line)
    if not m or not FLASH < int(m.group(1), 16) < END:
        out.append(line)
        continue
    flash, lib, name = int(m.group(1), 16), int(m.group(5), 16), m.group(3)
    assert lib == flash - FLASH + LIB, line
    if lib in named:
        print(f"dropped  {name:20s} lib 0x{lib:08X} is {named[lib]}")
        continue
    p = GI.prologue_before(rom, lib - LIB + FILE_BASE)
    owner = named.get(p - FILE_BASE + LIB) if p is not None else None
    if lib in func_starts or owner:
        out.append(f"0x{lib:08X}{m.group(2)}{name}{m.group(4)}; (flash copy 0x{flash:08X}) {m.group(6)}")
        print(f"moved    {name:20s} 0x{flash:08X} -> lib 0x{lib:08X}"
              + (f" (the call entry of {owner})" if owner else ""))
        continue
    kept.append(name)
    out.append(line)
print("left (library address inside a routine):", " ".join(kept) or "-")
open(path, "w", encoding="utf-8").write("\n".join(out))
