#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""make_rompath.py -- a MAME rompath whose IC21 CUSTOM bank is one of the factory banks.

Question: how to boot the kn7000_mame build with, say, 03custm3 in the CUSTOM STYLE memory, so that
kit_readers.lua can play CUSTOM slot 7's user kit.

The driver loads IC21's bank from `kn7000_custom_data.rom` (at 0x20000, 0x1E0000 bytes, in a
ROM_REGION16_BE).  Builds before kn7000_mame b5581e5 (this lane used md5 20455440aa8db9739bf9f930e6066dec)
loaded it with a plain ROM_LOAD_OPTIONAL, so a bank file given as it is reached the CPU halfword-swapped
(the directory's "IK" read "KI", and the firmware wrote an empty directory over it).  For those builds pass
--swap: the bank is written with each pair of bytes swapped, which the CPU then reads in its own order
(checked: 0x96820000 reads 49 4B 01 01 08 01 ..., the directory of 03custm3).  From b5581e5 on (published
kn7000-emulator md5 4e4c2390) the driver loads it ROM_GROUPWORD | ROM_REVERSE like the other Initial Data
files, and the bank must be given as it is: the default.  --swap on such a build turns the directory back
into "KI".  An nvram/kn7000/customflash saved by an older build still holds the swapped or emptied bank,
so run with a fresh -nvram_directory.  The other files of the set are symlinks to the romset's.  MAME
warns about the checksum (the driver lists 01ctmini's) and runs.

Usage:  python3 -I make_rompath.py [--swap] ROMSET_DIR BANK OUT_DIR
  e.g.  python3 -I make_rompath.py ~/compartilhado/technics_romsets/kn7000 \\
            ~/compartilhado/technics_romsets/kn7000/03custm3.ic21 ~/compartilhado/tmp/<lane>/rom
then run MAME with -rompath OUT_DIR.  The output is regenerable scratch (2 MB plus symlinks).
"""
import os
import sys
from pathlib import Path


def main():
    args = sys.argv[1:]
    swap = "--swap" in args
    args = [a for a in args if a != "--swap"]
    romset, bank, out = (Path(a).expanduser() for a in args[:3])
    d = out / "kn7000"
    d.mkdir(parents=True, exist_ok=True)
    for f in sorted(romset.iterdir()):
        link = d / f.name
        if not link.exists():
            os.symlink(f, link)
    src = bank.read_bytes()
    assert len(src) == 0x1E0000, len(src)
    b = bytearray(src)
    if swap:
        b[0::2], b[1::2] = src[1::2], src[0::2]
    target = d / "kn7000_custom_data.rom"
    if target.is_symlink():
        target.unlink()
    target.write_bytes(bytes(b))
    print(f"wrote {target} ({bank.name}{', halfword-swapped' if swap else ''})")


if __name__ == "__main__":
    main()
