#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Emits a NAMED, function-by-function MN10300 disassembly of the KN7000 program
# image, using the symbols recovered by tools/gen_symbols.py.
#
# Disassembling each function from its exact entry point (rather than doing one
# linear sweep) keeps every function aligned to real instruction boundaries. Each
# recovered function is disassembled from its entry up to the next recovered
# entry (capped), preceded by a "<name>:" label.

import argparse
import re
import subprocess
import sys

PROGRAM_BASE = 0x48400000


def load_symbols(path):
    """Returns [(cpu_addr, file_offset, name)] sorted by address."""
    syms = []
    for line in open(path):
        m = re.match(r"\s*0x([0-9A-Fa-f]+)\s+(\S+)", line)
        if m and not line.lstrip().startswith(";"):
            addr = int(m.group(1), 16)
            if addr >= PROGRAM_BASE:                       # skip RAM/IO equates
                syms.append((addr, addr - PROGRAM_BASE, m.group(2)))
    return sorted(syms)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--rom", default="baserom/kn7000_program.rom")
    ap.add_argument("--sym", default="kn7000.sym")
    ap.add_argument("--unidasm", default="../mame-sony-video/unidasm")
    ap.add_argument("--from-addr", type=lambda s: int(s, 0), default=PROGRAM_BASE)
    ap.add_argument("--to-addr", type=lambda s: int(s, 0), default=0x487F6F01)
    ap.add_argument("--cap", type=lambda s: int(s, 0), default=0x400,
                    help="max bytes to disassemble per function")
    args = ap.parse_args()

    syms = load_symbols(args.sym)
    sel = [s for s in syms if args.from_addr <= s[0] < args.to_addr]

    print(f"; KN7000 program image - named function disassembly")
    print(f"; {len(sel)} functions in [{args.from_addr:#x}, {args.to_addr:#x}); "
          f"names from {args.sym} (MILK-toolkit reflection tables, shared w/ KN5000)")
    print(";")

    for i, (cpu, off, name) in enumerate(sel):
        nxt = syms[syms.index((cpu, off, name)) + 1][1] if (cpu, off, name) != syms[-1] else off + args.cap
        count = max(1, min(nxt - off, args.cap))
        listing = subprocess.run(
            [args.unidasm, args.rom, "-arch", "mn10300",
             "-basepc", f"0x{cpu:x}", "-skip", f"0x{off:x}", "-count", str(count)],
            capture_output=True, text=True).stdout
        print(f"\n{name}:")
        sys.stdout.write(listing)


if __name__ == "__main__":
    main()
