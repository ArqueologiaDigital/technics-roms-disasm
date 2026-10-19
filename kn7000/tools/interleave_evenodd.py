#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Reconstruct a linear program image by interleaving a pair of even/odd 16-bit
# MAME ROMs (ROM_LOAD32_WORD layout): linear word 2i = even[i], 2i+1 = odd[i].
#
# Used to rebuild the KN6500 linear image (which has no pre-extracted full image)
# from its MAME even/odd ROMs, so its SHARC DSP pool can be extracted with
# gen_dsp_records.py (see dsp/cross-model/README.md).  E.g.:
#
#   python3 tools/interleave_evenodd.py \
#       ../kn7000_mame_build/roms/kn6500/kn6500_program_even.rom \
#       ../kn7000_mame_build/roms/kn6500/kn6500_program_odd.rom \
#       kn6500_program_full.bin

import sys


def main():
    if len(sys.argv) != 4:
        sys.stderr.write("usage: interleave_evenodd.py EVEN.rom ODD.rom OUT.bin\n")
        return 2
    ev = open(sys.argv[1], "rb").read()
    od = open(sys.argv[2], "rb").read()
    n = min(len(ev), len(od))
    out = bytearray()
    for i in range(0, n, 2):
        out += ev[i:i + 2]
        out += od[i:i + 2]
    open(sys.argv[3], "wb").write(out)
    sys.stderr.write("wrote %s (%d bytes)\n" % (sys.argv[3], len(out)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
