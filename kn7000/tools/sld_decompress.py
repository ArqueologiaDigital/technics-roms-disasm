#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Decompress a KN7000 update-floppy .SLD payload (8-byte magic, 24-bit big-endian
# size, LZSS with a 4 KiB window pre-filled with 0x00) -- the format documented in
# ../../kn7000_extraction/FORMAT.md. Uses that repo's `lzss` module, so run it with
# its interpreter:  ../../kn7000_extraction/venv/bin/python tools/sld_decompress.py IN OUT
import sys

import lzss


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    d = open(sys.argv[1], "rb").read()
    size = int.from_bytes(d[8:11], "big")
    raw = lzss.decompress(data=d[11:], initial_buffer_values=0x00000000)
    if len(raw) != size:
        sys.exit(f"sld_decompress: got 0x{len(raw):X} bytes, header declares 0x{size:X}")
    open(sys.argv[2], "wb").write(raw)
    print(f"sld_decompress: {sys.argv[1]} ({d[:8].rstrip(bytes(1)).decode('latin1')}) -> 0x{size:X} bytes")


if __name__ == "__main__":
    main()
