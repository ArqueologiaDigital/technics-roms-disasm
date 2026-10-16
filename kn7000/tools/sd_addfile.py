#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Add or replace a file of ARBITRARY size on a FAT16 disk image, allocating
# fresh clusters and updating both FAT copies.  This is the grow/shrink sibling
# of sd_splice.py (which only overwrites a file in place, same size).  It reuses
# the same MBR + BPB parsing.  Used to drop AWDATA.AW onto a copy of an SP7001
# SD-card image.
#
#   sd_addfile.py <image> '<DOS\PATH\NAME.EXT>' <source-file>
#
# The target directory (all path components but the last) must already exist.
import struct, sys

def main():
    if len(sys.argv) != 4:
        sys.exit("usage: sd_addfile.py <image> '<DOS\\PATH\\NAME.EXT>' <source-file>")
    img_path = sys.argv[1]
    want = sys.argv[2].upper().replace("/", "\\")
    payload = open(sys.argv[3], "rb").read()
    d = bytearray(open(img_path, "rb").read())

    # ---- MBR + BPB (mirrors sd_splice.py) -----------------------------------
    base = 0
    if d[0x1FE:0x200] == b"\x55\xaa" and struct.unpack_from("<H", d, 11)[0] == 0:
        base = struct.unpack_from("<I", d, 0x1BE + 8)[0] * 512   # first MBR partition
    bps, spc, rsv, nfat, nroot = struct.unpack_from("<HBHBH", d, base + 11)
    tot16, _media, spf16 = struct.unpack_from("<HBH", d, base + 19)
    tot = tot16 or struct.unpack_from("<I", d, base + 32)[0]
    if d[base + 54:base + 57] != b"FAT":
        sys.exit("sd_addfile: not a FAT16 BPB (only FAT16 supported)")
    cluster_bytes = spc * bps
    fat0 = base + rsv * bps
    root = base + (rsv + nfat * spf16) * bps
    data0 = root + ((nroot * 32 + bps - 1) // bps) * bps
    # Total number of data clusters -> highest valid cluster index.
    total_clusters = (tot - (data0 - base) // bps) // spc
    max_clus = total_clusters + 1               # clusters are numbered from 2
    END = 0xFFFF

    def fat_get(c):
        return struct.unpack_from("<H", d, fat0 + c * 2)[0]

    def fat_set(c, v):
        # Write identically into every FAT copy.
        for n in range(nfat):
            off = fat0 + n * spf16 * bps + c * 2
            struct.pack_into("<H", d, off, v & 0xFFFF)

    def chain_offsets(clus):
        offs = []
        while 2 <= clus < 0xFFF8:
            offs.append(data0 + (clus - 2) * cluster_bytes)
            clus = fat_get(clus)
        return offs

    def chain_clusters(clus):
        cl = []
        while 2 <= clus < 0xFFF8:
            cl.append(clus)
            clus = fat_get(clus)
        return cl

    def walk_dir(sector_off, nent):
        for i in range(nent):
            entoff = sector_off + 32 * i
            e = d[entoff:entoff + 32]
            if e[0] in (0, 0xE5) or e[11] == 0x0F:   # free / deleted / LFN
                continue
            name = e[0:8].decode("latin1").rstrip()
            ext = e[8:11].decode("latin1").rstrip()
            if ext:
                name += "." + ext
            clus = struct.unpack_from("<H", e, 26)[0]
            size = struct.unpack_from("<I", e, 28)[0]
            yield name, e[11], clus, size, entoff

    # ---- resolve the target directory (all but the last path component) -----
    parts = [p for p in want.split("\\") if p and not p.endswith(":")]
    if not parts:
        sys.exit("sd_addfile: empty path")
    dirparts, fname = parts[:-1], parts[-1]

    # Directory iteration: the root is a fixed area; subdirs are cluster chains.
    cur = ("root", root, nroot)                 # (kind, offset-or-firstclus, nent)
    for comp in dirparts:
        if cur[0] == "root":
            ents = walk_dir(cur[1], cur[2])
        else:
            ents = (e for off in chain_offsets(cur[1])
                    for e in walk_dir(off, cluster_bytes // 32))
        found = None
        for name, attr, clus, size, entoff in ents:
            if name.upper() == comp and (attr & 0x10):
                found = clus
                break
        if found is None:
            sys.exit(f"sd_addfile: directory '{comp}' not found")
        cur = ("sub", found, 0)

    # List of (entry-offset) slots in the target dir, and a scan for the file.
    def dir_entry_slots():
        """Yield every 32-byte directory-entry offset in the target dir."""
        if cur[0] == "root":
            for i in range(cur[2]):
                yield cur[1] + 32 * i
        else:
            for off in chain_offsets(cur[1]):
                for i in range(cluster_bytes // 32):
                    yield off + 32 * i

    # ---- find existing entry (replace) or a free slot (add) -----------------
    target_entoff = None
    free_entoff = None
    for entoff in dir_entry_slots():
        first = d[entoff]
        if first in (0x00, 0xE5):
            if free_entoff is None:
                free_entoff = entoff
            if first == 0x00:                   # end of used entries; stop scanning
                break
            continue
        if d[entoff + 11] == 0x0F:              # LFN component
            continue
        name = d[entoff:entoff + 8].decode("latin1").rstrip()
        ext = d[entoff + 8:entoff + 11].decode("latin1").rstrip()
        full = name + ("." + ext if ext else "")
        if full.upper() == fname:
            target_entoff = entoff
            break

    replace = target_entoff is not None
    if replace:
        old_clus = struct.unpack_from("<H", d, target_entoff + 26)[0]
        freed = chain_clusters(old_clus)
        for c in freed:
            fat_set(c, 0x0000)
        print(f"replacing existing '{fname}' @0x{target_entoff:X}: "
              f"freed {len(freed)} old cluster(s)")
        entoff = target_entoff
    else:
        if free_entoff is None:
            sys.exit("sd_addfile: no free directory entry in target dir "
                     "(root dir full; growing subdirs not supported)")
        entoff = free_entoff
        print(f"adding new '{fname}' @0x{entoff:X}")

    # ---- allocate clusters for the payload ----------------------------------
    n_clusters = (len(payload) + cluster_bytes - 1) // cluster_bytes  # 0 for empty file
    free = []
    c = 2
    while c <= max_clus and len(free) < n_clusters:
        if fat_get(c) == 0x0000:
            free.append(c)
        c += 1
    if len(free) < n_clusters:
        sys.exit(f"sd_addfile: not enough free clusters "
                 f"(need {n_clusters}, found {len(free)})")

    # Chain them in the FAT: each -> next, last -> EOF.
    for i, clus in enumerate(free):
        fat_set(clus, free[i + 1] if i + 1 < len(free) else END)

    # Write payload into the cluster data area, zero-padding the final cluster.
    p = 0
    for clus in free:
        o = data0 + (clus - 2) * cluster_bytes
        chunk = payload[p:p + cluster_bytes]
        d[o:o + len(chunk)] = chunk
        if len(chunk) < cluster_bytes:          # zero-pad tail of last cluster
            d[o + len(chunk):o + cluster_bytes] = b"\x00" * (cluster_bytes - len(chunk))
        p += len(chunk)

    # ---- build the 8.3 directory entry --------------------------------------
    if "." in fname:
        base_n, ext_n = fname.rsplit(".", 1)
    else:
        base_n, ext_n = fname, ""
    if len(base_n) > 8 or len(ext_n) > 3:
        sys.exit(f"sd_addfile: '{fname}' is not a valid 8.3 name")
    name83 = base_n.ljust(8)[:8].encode("latin1") + ext_n.ljust(3)[:3].encode("latin1")
    first_clus = free[0] if free else 0
    # Fixed, valid date/time: 2026-01-01 00:00:00.
    fat_date = ((2026 - 1980) << 9) | (1 << 5) | 1
    fat_time = 0
    ent = bytearray(32)
    ent[0:11] = name83
    ent[11] = 0x20                              # attr = archive
    ent[12] = 0x00                             # reserved
    ent[13] = 0x00                             # creation 10ms
    struct.pack_into("<H", ent, 14, fat_time)  # creation time
    struct.pack_into("<H", ent, 16, fat_date)  # creation date
    struct.pack_into("<H", ent, 18, fat_date)  # last-access date
    struct.pack_into("<H", ent, 20, 0)         # first-cluster-high (0 for FAT16)
    struct.pack_into("<H", ent, 22, fat_time)  # write time
    struct.pack_into("<H", ent, 24, fat_date)  # write date
    struct.pack_into("<H", ent, 26, first_clus)
    struct.pack_into("<I", ent, 28, len(payload))
    d[entoff:entoff + 32] = ent

    open(img_path, "wb").write(d)
    print(f"  wrote 0x{len(payload):X} ({len(payload)}) bytes into "
          f"{n_clusters} cluster(s) of 0x{cluster_bytes:X}")
    print(f"  first cluster {first_clus}, chain: "
          f"{free[:8]}{'...' if len(free) > 8 else ''}")
    print(f"  dir entry @0x{entoff:X}, name '{name83.decode('latin1')}', "
          f"size {len(payload)}")

if __name__ == "__main__":
    main()
