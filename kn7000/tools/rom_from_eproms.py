#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Reconstruct a linear 4 MiB KN7000 flash image from its two EPROM-half dumps,
# exactly as MAME's kn7000 driver loads them:
#     ROMX_LOAD(even.ic17, 0x000000, 0x200000, ROM_GROUPWORD | ROM_SKIP(2))
#     ROMX_LOAD(odd.ic16,  0x000002, 0x200000, ROM_GROUPWORD | ROM_SKIP(2))
# i.e. 16-bit words interleaved: 2 bytes from even, 2 from odd, repeating. The
# result is the image the MN10300 sees (program at 0x48400000, table 0x48000000).
#
# This is the correct de-interleave the SP7001 activation RE warned about
# ("naive even/odd interleave is wrong" meant byte-wise, not word-wise).
#
# Usage:  rom_from_eproms.py <even.ic17> <odd.ic16> <out.rom>
import sys

def interleave(even_path, odd_path):
    e = open(even_path, "rb").read()
    o = open(odd_path, "rb").read()
    if not (len(e) == len(o) == 0x200000):
        sys.exit(f"each half must be 0x200000 bytes (got {len(e):#x}, {len(o):#x})")
    out = bytearray(0x400000)
    for i in range(0, 0x200000, 2):
        out[2 * i:2 * i + 2] = e[i:i + 2]
        out[2 * i + 2:2 * i + 4] = o[i:i + 2]
    return bytes(out)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    open(sys.argv[3], "wb").write(interleave(sys.argv[1], sys.argv[2]))
