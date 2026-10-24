#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Question: is file 0x3285be..0x3965bb of the KN2400 program image linked for work
# RAM at 0x50120000 (cpu = file + 0x4fdf7a42) rather than for its flash address?
#
# It decodes the flash-linked code (file 0x1e427c..0x3285be, at 0x48400000 + file)
# and the candidate range twice (at its flash address and at 0x50120000), then
# counts, with MAME's unidasm:
#   A. calls/jmps in flash code whose target is in 0x50120000..0x5018e5bb, and how
#      many of those land on an instruction start of the RAM-linked decode;
#   B. calls/jmps in the candidate range whose target lies in the image or in that
#      RAM window, under each of the two link addresses;
# and prints the two other witnesses: the switch table at 0x48405c48 and the
# vector crt0 builds at 0x90000000.
#
# Run from kn2400/:  python3 notes/layout-probes/ram_linked_range.py \
#                        baserom/kn2400_program.rom /path/to/unidasm
import re
import struct
import subprocess
import sys

rom, unidasm = sys.argv[1], sys.argv[2]
d = open(rom, "rb").read()
FLASH = 0x48400000
LO, HI, RAM = 0x3285BE, 0x3965BB, 0x50120000
DELTA = RAM - LO
LINE = re.compile(r"([0-9a-f]+):\s+(?:[0-9a-f]{2} )+\s+(\S+)\s*(.*)")


def decode(off, end, cpu):
    out = subprocess.run([unidasm, rom, "-arch", "mn10300", "-basepc", hex(cpu), "-skip", hex(off),
                          "-count", str(end - off)], capture_output=True, text=True).stdout
    return [(int(m.group(1), 16), m.group(2), m.group(3)) for m in map(LINE.match, out.splitlines()) if m]


def targets(lines):
    for pc, mn, ops in lines:
        m = re.match(r"0x([0-9a-f]+)", ops)
        if mn in ("call", "calls", "jmp") and m:
            yield pc, int(m.group(1), 16)


flash = decode(0x1E427C, LO, FLASH + 0x1E427C)
as_ram = decode(LO, HI, RAM)
as_flash = decode(LO, HI, FLASH + LO)
ram_starts = {pc for pc, _m, _o in as_ram}

a = [t for _pc, t in targets(flash) if RAM <= t < RAM + (HI - LO)]
print(f"A. flash code -> RAM window: {len(a)} transfers, "
      f"{sum(t in ram_starts for t in a)} land on an instruction start of the RAM-linked decode")


def inside(t):
    return FLASH <= t < FLASH + len(d) or RAM <= t < RAM + (HI - LO)


for name, lines in (("at its flash address", as_flash), ("at 0x50120000", as_ram)):
    ts = [t for _pc, t in targets(lines)]
    print(f"B. range decoded {name:21s}: {len(ts)} transfers, {sum(map(inside, ts))} land in "
          "the image or the RAM window")

tab = [struct.unpack_from("<I", d, 0x5C48 + 4 * i)[0] for i in range(4)]
print("C. switch table at 0x48405c48:", ", ".join(f"0x{v:08x} (file 0x{v - DELTA:06x})" for v in tab))
print("D. crt0 vector target 0x5018df0b = file", hex(0x5018DF0B - DELTA),
      "| 24-byte tail:", d[HI:HI + 24].hex())
