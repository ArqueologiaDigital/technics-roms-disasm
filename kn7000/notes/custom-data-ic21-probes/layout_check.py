#!/usr/bin/env python3
"""layout_check.py -- does every factory custom-data image follow the layout the firmware reads?

Question: for each image, are the directory, the slot records, their sections and the two style
containers laid out exactly as the KN7000 program's accessors (kn7000/notes/custom-data-ic21.md)
expect, with no byte unaccounted for?  Prints one line per image, the free blocks that are not
erased (they hold older records, which gen_customdata_s.py types when they are complete), and
every exception to the layout.

Usage: python3 -I layout_check.py IMAGE [IMAGE ...]
"""
import struct
import sys

BLOCK = 0x8000


def u24(b, o):
    return b[o] << 16 | b[o + 1] << 8 | b[o + 2]


def u16(b, o):
    return b[o] << 8 | b[o + 1]


def check_container(rec, base, size, sig, nrec, recsize, streamoff, what, errs):
    """A 'TCMP'/'TPAD' N=1 container at rec[base:base+size]: header, records, then streams."""
    c = rec[base:base + size]
    if c[:4] != sig or c[4:6] != b"\0\0":
        errs.append(f"{what}: signature {c[:6]!r}")
    if c[6:0x10] != bytes(10):
        errs.append(f"{what}: +6..+0x10 not zero: {c[6:0x10].hex()}")
    if u24(c, 0x10) != size or u24(c, 0x13) != size:
        errs.append(f"{what}: length {u24(c, 0x10):#x} top {u24(c, 0x13):#x} != {size:#x}")
    if u16(c, 0x16) != 1:
        errs.append(f"{what}: count {u16(c, 0x16)}")
    pos = nrec[1]
    for i, ro in enumerate(nrec[0]):
        so = u24(c, ro + streamoff)
        if so != pos:
            errs.append(f"{what}: record {i} stream at {so:#x}, expected {pos:#x}")
            pos = so
        idx, ln = c[so], u24(c, so + 1)
        if c[so + 4] != 0xF4 or c[so + 4 + ln - 1] != 0xF5:
            errs.append(f"{what}: stream {i} not F4..F5")
        pos = so + 4 + ln
    if pos != size:
        errs.append(f"{what}: streams end at {pos:#x}, container is {size:#x}")


def check(path):
    d = open(path, "rb").read()
    errs = []
    if d[:2] != b"IK":
        errs.append("signature")
    used = [0] * 60
    used[0] = 1
    stale = []
    for s in range(20):
        st, n = d[2 + 2 * s], d[3 + 2 * s]
        if not st:
            continue
        rec = d[st * BLOCK:(st + n) * BLOCK]
        size = struct.unpack_from("<I", rec, 0)[0]
        if (size + BLOCK - 1) // BLOCK != n:
            errs.append(f"slot {s}: {n} blocks for {size:#x} bytes")
        if rec[0xA4] != st or rec[0xA5] != n:
            errs.append(f"slot {s}: +0xA4 {rec[0xA4]},{rec[0xA5]} != directory {st},{n}")
        for b in range(st, st + n):
            used[b] += 1
        sec = [struct.unpack_from("<II", rec, o) for o in range(0x54, 0xA4, 8)]
        pos = 0x100
        # +0x54..+0x7C: five kinds of 0x42-byte records, then 0x2C8-byte, 0x48A7-byte blocks:
        # offset u32 and a count byte (+0x58 ...); then OTS, TCMP, TPAD: offset u32 and size u32
        stride = [0x42] * 5 + [0x2C8, 0x48A7]
        for k in range(7):
            off, cnt = sec[k][0], rec[0x58 + 8 * k]
            if cnt:
                if off != pos:
                    errs.append(f"slot {s}: section {k} at {off:#x}, expected {pos:#x}")
                pos = off + cnt * stride[k]
            elif off:
                errs.append(f"slot {s}: section {k} offset {off:#x} with count 0")
        for k, name in ((7, "OTS"), (8, "TCMP"), (9, "TPAD")):
            off, sz = sec[k]
            if off != pos:
                errs.append(f"slot {s}: {name} at {off:#x}, expected {pos:#x}")
            pos = off + sz
        if pos != size:
            errs.append(f"slot {s}: sections end at {pos:#x}, record is {size:#x}")
        t_off, t_sz = sec[8]
        check_container(rec, t_off, t_sz, b"TCMP", ([0xF0 + 0xE0 * v for v in range(20)], 0x1270),
                        0xE0, 0x15, f"slot {s} TCMP", errs)
        p_off, p_sz = sec[9]
        check_container(rec, p_off, p_sz, b"TPAD", ([0xA0 + 0x60 * v for v in range(6)], 0x2E0),
                        0x60, 0x1D, f"slot {s} TPAD", errs)
    for b in range(60):
        if used[b] > 1:
            errs.append(f"block {b} used by {used[b]} slots")
        if d[0x2A + b] != (1 if used[b] else 0):
            errs.append(f"block map {b} = {d[0x2A + b]}, used {used[b]}")
        if not used[b] and set(d[b * BLOCK:(b + 1) * BLOCK]) != {0xFF}:
            stale.append(b)
    if set(d[0x66:BLOCK]) != {0xFF}:
        errs.append("directory block tail not erased")
    print(f"{path}: {'OK' if not errs else 'EXCEPTIONS'}; free blocks holding older data: {stale or 'none'}")
    for e in errs:
        print("   ", e)
    return not errs


if __name__ == "__main__":
    ok = all([check(p) for p in sys.argv[1:]])
    sys.exit(0 if ok else 1)
