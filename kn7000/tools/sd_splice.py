#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Replace a file's contents, in place, on a FAT (12/16) disk image, keeping the
# same size so the directory entry and cluster chain are untouched. Used to drop
# a custom BASEEXT.XAP onto a copy of an SP7001 SD-card image.
#   sd_splice.py <image> <PATH\IN\FAT>  --verify-crc        (just locate + checksum)
#   sd_splice.py <image> <PATH\IN\FAT>  <new-contents-file> (overwrite in place)
import struct, sys, zlib

def main():
    img_path, want = sys.argv[1], sys.argv[2].upper().replace("/", "\\")
    d = bytearray(open(img_path, "rb").read())
    base = 0
    if d[0x1FE:0x200] == b"\x55\xaa" and struct.unpack_from("<H", d, 11)[0] == 0:
        base = struct.unpack_from("<I", d, 0x1BE + 8)[0] * 512       # first MBR partition
    bps, spc, rsv, nfat, nroot = struct.unpack_from("<HBHBH", d, base + 11)
    tot16, _media, spf16 = struct.unpack_from("<HBH", d, base + 19)
    tot = tot16 or struct.unpack_from("<I", d, base + 32)[0]
    fat0 = base + rsv * bps
    root = base + (rsv + nfat * spf16) * bps
    data0 = root + ((nroot * 32 + bps - 1) // bps) * bps
    fat16 = d[base+54:base+57] == b'FAT'  # trust the BPB fs-type label (FAT16/FAT12)
    def nextclus(c):
        if fat16:
            return struct.unpack_from("<H", d, fat0 + c * 2)[0]
        o = fat0 + c * 3 // 2; v = d[o] | d[o + 1] << 8
        return (v >> 4) if c & 1 else (v & 0xFFF)
    END = 0xFFF8 if fat16 else 0xFF8

    def walk_dir(sector_off, nent):
        for i in range(nent):
            e = d[sector_off + 32 * i: sector_off + 32 * i + 32]
            if e[0] in (0, 0xE5) or e[11] == 0x0F: continue
            name = e[0:8].decode("latin1").rstrip() + ("." + e[8:11].decode("latin1").rstrip() if e[8:11].strip() else "")
            clus = struct.unpack_from("<H", e, 26)[0]; size = struct.unpack_from("<I", e, 28)[0]
            yield name, e[11], clus, size, sector_off + 32 * i

    def chain_offsets(clus):
        offs = []
        while 2 <= clus < END:
            offs.append(data0 + (clus - 2) * spc * bps)
            clus = nextclus(clus)
        return offs

    # resolve PATH components, starting at the root dir
    parts = want.split("\\")
    parts = [p for p in parts if p and not p.endswith(":")]   # drop 'C:'
    cur = ("root", root, nroot)
    target = None
    for depth, comp in enumerate(parts):
        last = depth == len(parts) - 1
        found = None
        ents = walk_dir(cur[1], cur[2]) if cur[0] == "root" else \
               (e for off in chain_offsets(cur[1]) for e in walk_dir(off, spc * bps // 32))
        for name, attr, clus, size, entoff in ents:
            if name.upper() == comp:
                found = (name, attr, clus, size, entoff); break
        if not found: sys.exit(f"sd_splice: '{comp}' not found")
        if last: target = found
        else: cur = ("sub", found[2], 0)
    name, attr, clus, size, entoff = target
    offs = chain_offsets(clus)
    print(f"{name}: size 0x{size:X}, {len(offs)} clusters of 0x{spc*bps:X}; first data @0x{offs[0]:X}")
    cur_bytes = b"".join(d[o:o + spc * bps] for o in offs)[:size]
    print(f"  current CRC32 {zlib.crc32(cur_bytes)&0xffffffff:08x}")

    if len(sys.argv) >= 4 and sys.argv[3] != "--verify-crc":
        new = open(sys.argv[3], "rb").read()
        if len(new) != size: sys.exit(f"sd_splice: new file is 0x{len(new):X}, must be 0x{size:X}")
        p = 0
        for o in offs:
            n = min(spc * bps, len(new) - p)
            d[o:o + n] = new[p:p + n]; p += n
        open(img_path, "wb").write(d)
        print(f"  wrote 0x{len(new):X} bytes into {len(offs)} clusters; new CRC32 {zlib.crc32(new)&0xffffffff:08x}")

if __name__ == "__main__":
    main()
