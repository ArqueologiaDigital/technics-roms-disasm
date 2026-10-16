#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Add a homebrew module to the SP7001 base plug-in, BASEEXT.XAP, keeping the plug-in
# itself unchanged so the instrument's SD-card features keep working.
#
# The SP7001 resident plug-in reads BASEEXT.XAP (exactly 0x1D000 bytes) to the fixed
# RAM address 0x5029B000 and calls its first byte, XapEntry (notes/sp7001-build-diff.md).
# The file's tail from 0x19D78 up is all 0xFF and never addressed: BASEEXT's own data
# and variables end at 0x502B4D78. This tool
#   1. copies the module bytes into that tail at --at (default 0x502B6000), and
#   2. replaces XapEntry's first 5 bytes -- `movm [a2,a3],(sp)` + `add -8,sp` -- with a
#      `jmp` to the module's first byte.
# Contract for the module: its first byte is the hook. It may do its own set-up, must
# preserve XapEntry's arguments (d0, d1, a0, a1) and stack, then execute the two
# displaced instructions and `jmp 0x5029B005` to resume XapEntry.
#
# Usage: xap_addon.py BASEEXT.XAP MODULE.bin OUT.XAP [--at 0x502B6000]
import argparse
import sys

XAP_BASE = 0x5029B000
XAP_SIZE = 0x1D000
FREE_FROM = 0x502B4D78                       # end of BASEEXT's data + variables
XAP_ENTRY_HEAD = bytes.fromhex("cf30f8fef8")  # movm [a2,a3],(sp) ; add -8,sp


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("base")
    ap.add_argument("module")
    ap.add_argument("out")
    ap.add_argument("--at", type=lambda v: int(v, 0), default=0x502B6000)
    a = ap.parse_args()
    x = bytearray(open(a.base, "rb").read())
    m = open(a.module, "rb").read()
    if len(x) != XAP_SIZE:
        sys.exit(f"xap_addon: {a.base} is 0x{len(x):X} bytes, expected 0x{XAP_SIZE:X}")
    if x[:5] != XAP_ENTRY_HEAD:
        sys.exit(f"xap_addon: XapEntry starts {x[:5].hex()}, expected {XAP_ENTRY_HEAD.hex()} "
                 "(not the SP7001 BASEEXT.XAP, or already patched)")
    off = a.at - XAP_BASE
    if a.at < FREE_FROM or off + len(m) > XAP_SIZE:
        sys.exit(f"xap_addon: module 0x{a.at:08X}..0x{a.at + len(m):08X} is outside the free "
                 f"tail 0x{FREE_FROM:08X}..0x{XAP_BASE + XAP_SIZE:08X}")
    if set(x[off:off + len(m)]) - {0xFF}:
        sys.exit("xap_addon: the target range is not erased (0xFF)")
    x[off:off + len(m)] = m
    x[0:5] = b"\xdc" + (a.at - XAP_BASE).to_bytes(4, "little")   # jmp d32 to the hook
    open(a.out, "wb").write(x)
    print(f"xap_addon: wrote {a.out}: module 0x{len(m):X} bytes at 0x{a.at:08X} "
          f"(file 0x{off:05X}), XapEntry -> jmp 0x{a.at:08X}")


if __name__ == "__main__":
    main()
