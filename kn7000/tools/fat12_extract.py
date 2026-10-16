#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Extract one file from the root directory of a FAT12 floppy image (e.g. the
# SP7001 table update disk, label 'SP7001 TB2'), without mounting it.
#
# Usage:  fat12_extract.py <image.img> <NAME.EXT> <out>
#         fat12_extract.py <image.img> --list
import struct
import sys


def root_entries(d):
    bps, spc, rsv, nfat, nroot, _tot, _md, spf = struct.unpack_from("<HBHBHHBH", d, 11)
    fat = d[rsv * bps:(rsv + spf) * bps]
    root = (rsv + nfat * spf) * bps
    data0 = root + nroot * 32

    def chain(clus, size):
        out = bytearray()
        while 2 <= clus < 0xFF8 and len(out) < size:
            o = data0 + (clus - 2) * spc * bps
            out += d[o:o + spc * bps]
            v = fat[clus * 3 // 2] | fat[clus * 3 // 2 + 1] << 8
            clus = (v >> 4) if clus & 1 else (v & 0xFFF)
        if len(out) < size:
            sys.exit("fat12_extract: cluster chain shorter than the file size")
        return bytes(out[:size])

    for i in range(nroot):
        e = d[root + 32 * i:root + 32 * i + 32]
        if e[0] == 0:
            break
        if e[0] == 0xE5 or e[11] == 0x0F or e[11] & 0x18:      # deleted, LFN, dir, label
            continue
        name = e[0:8].decode("latin1").rstrip()
        ext = e[8:11].decode("latin1").rstrip()
        clus, size = struct.unpack_from("<H", e, 26)[0], struct.unpack_from("<I", e, 28)[0]
        yield (f"{name}.{ext}" if ext else name), size, (lambda c=clus, s=size: chain(c, s))


def main():
    if len(sys.argv) == 3 and sys.argv[2] == "--list":
        for nm, size, _get in root_entries(open(sys.argv[1], "rb").read()):
            print(f"{nm:14s} {size:9d}")
        return
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    img, want, out = sys.argv[1:]
    for nm, _size, get in root_entries(open(img, "rb").read()):
        if nm.upper() == want.upper():
            open(out, "wb").write(get())
            return
    sys.exit(f"fat12_extract: {want} not in {img}")


if __name__ == "__main__":
    main()
