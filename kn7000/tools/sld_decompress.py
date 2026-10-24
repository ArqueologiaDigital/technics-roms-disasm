#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Decompress a KN7000 update-floppy .SLD payload (8-byte magic, 24-bit big-endian
# size, LZSS with a 4 KiB window pre-filled with 0x00) -- the format documented in
# ../../kn7000_extraction/FORMAT.md. The same container carries the KN6000/KN6500
# (IKPRG4K), KN2400 (LKGP14K/LKGP24K) and HD-SX3 (SLIDE4K) firmware.
#
# When the `lzss` module (pylzss, installed in ../../kn7000_extraction/venv) is
# importable it is used; otherwise the pure-Python decoder below does the same job,
# so the build of the MN10300 sibling trees needs nothing outside the standard
# library. Both give byte-identical output (the header's size field and, for the
# programs, the SMCK*.INF checksums check the result).
#
# Usage:  sld_decompress.py IN OUT
import sys

try:
    import lzss
except ImportError:
    lzss = None


def lzss_decompress(src):
    """Okumura LZSS as the Technics updaters use it: a flag byte, LSB first, 1 =
    literal byte, 0 = a two-byte reference: 12-bit window position
    (low byte | high nibble of the 2nd byte << 4) and length (low nibble + 3);
    4 KiB window, zero-filled, first write at 0xFEE."""
    win = bytearray(0x1000)
    wp = 0xFEE
    out = bytearray()
    i, n = 0, len(src)
    while i < n:
        flags = src[i]
        i += 1
        for bit in range(8):
            if i >= n:
                break
            if flags & (1 << bit):
                c = src[i]
                i += 1
                out.append(c)
                win[wp] = c
                wp = (wp + 1) & 0xFFF
            else:
                if i + 1 >= n:
                    i = n
                    break
                lo, hi = src[i], src[i + 1]
                i += 2
                pos = lo | ((hi & 0xF0) << 4)
                for k in range((hi & 0x0F) + 3):
                    c = win[(pos + k) & 0xFFF]
                    out.append(c)
                    win[wp] = c
                    wp = (wp + 1) & 0xFFF
    return bytes(out)


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    d = open(sys.argv[1], "rb").read()
    size = int.from_bytes(d[8:11], "big")
    if lzss is not None:
        raw = lzss.decompress(data=d[11:], initial_buffer_values=0x00000000)
    else:
        raw = lzss_decompress(d[11:])
    if len(raw) != size:
        sys.exit(f"sld_decompress: got 0x{len(raw):X} bytes, header declares 0x{size:X}")
    open(sys.argv[2], "wb").write(raw)
    print(f"sld_decompress: {sys.argv[1]} ({d[:8].rstrip(bytes(1)).decode('latin1')}) -> 0x{size:X} bytes")


if __name__ == "__main__":
    main()
