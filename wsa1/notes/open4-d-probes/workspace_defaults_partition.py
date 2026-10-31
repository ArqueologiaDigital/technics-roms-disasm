#!/usr/bin/env python3
"""Partition of prom_b WorkspaceDefaults (0xF46074, 161 bytes) and the block-store heap's size.

Answers open-items N-c4ef2711 / N-0bbd0164 (how the 161-byte object divides) and N-1837e44c
(how many 256-byte records the 0x617800 heap has).  Every number is read from the ROM image:
the run starts from the `ld XIX/XIY,<imm32>` operands at the copy sites, the run lengths from the
loop bounds at those sites, and the heap figures from the bytes BStore_BootPhase0 copies.

Run (from wsa1/):
    python3 notes/open4-d-probes/workspace_defaults_partition.py            # the table
    python3 notes/open4-d-probes/workspace_defaults_partition.py --selftest # asserts, exit 1 on drift
"""
import glob, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PB = open(os.path.join(ROOT, "original_ROMs/wsa1_prom_b.ic13"), "rb").read()
PA = open(os.path.join(ROOT, "original_ROMs/wsa1_prom_a.ic12"), "rb").read()
B0, A0 = 0xF00000, 0xF80000
OBJ, OBJ_LEN = 0xF46074, 161

rb = lambda a, n=1: PB[a - B0:a - B0 + n]
u32 = lambda a: int.from_bytes(rb(a, 4), "little")
u16 = lambda a: int.from_bytes(rb(a, 2), "little")

# (run name, offset, length, element, copy sites: (site of the ld XIX/XIY, site of the bound), bound
#  encoding, destination).  The bound is checked against the ROM bytes at the bound site.
RUNS = [
    ("WorkspaceDefaults_Header8",          0x00, 8, "byte", [(0xF44319, 0xF4432A), (0xF4436F, 0xF44380)],
     "cp IY,7 / jr ULE: IY = 0..7, then a 0 is stored at +8", 0x603400),
    ("WorkspaceDefaults_Words4",           0x08, 8, "word", [(0xF4433C, 0xF4434F), (0xF44392, 0xF443A5)],
     "add IY,2 / cp IY,8 / jr C: IY = 0,2,4,6", 0x603414),
    ("WorkspaceDefaults_HeapDescriptor",   0x10, 6, "long+word", [(0xF44070, None)],
     "ld XWA,(XIX+HL) / add HL,4 / ld WA,(XIX+HL): one long and one word", 0x003604),
    ("WorkspaceDefaults_HeapDescriptorAlt", 0x16, 6, "long+word", [(0xF44051, None)],
     "the same pair, on the branch `xor HL,HL / jr Z` never falls into", 0x003604),
    ("WorkspaceDefaults_TrackToPart",      0x1C, 17, "byte", [(0xF444EC, 0xF444FD)],
     "cp IY,0x11 / jr C: IY = 0..16", 0x603422),
    ("WorkspaceDefaults_TrackToPartGm",    0x2D, 17, "byte", [(0xF45D2D, 0xF45D3E)],
     "cp IY,0x11 / jr C", 0x603422),
    ("WorkspaceDefaults_TrackOutNone",     0x3E, 17, "byte", [(0xF442EC, 0xF44309), (0xF45D55, 0xF45D72), (0xF45E25, 0xF45E42)],
     "cp IY,0x11 / jr C", 0x603433),
    ("WorkspaceDefaults_TrackOutChannel",  0x4F, 17, "byte", [(0xF442F8, 0xF44309)],
     "cp IY,0x11 / jr C (non-GM, (0x6034C7) bit 1 set)", 0x603433),
    ("WorkspaceDefaults_TrackOutChannelGm", 0x60, 17, "byte", [(0xF45D61, 0xF45D72), (0xF45E31, 0xF45E42)],
     "cp IY,0x11 / jr C (GM, (0x6034C7) bit 1 set)", 0x603433),
    ("WorkspaceDefaults_SongName",         0x71, 6, "3 words", [(0xF442CF, 0xF442C7)],
     "ld BC,3 / ldirw: three words", 0x6034CA),
    ("WorkspaceDefaults_SixteenthTicks",   0x77, 4, "byte", [(0xF446AE, 0xF4469D)],
     "indexed by position & 3 (and C,3)", 0x000093),
]
TAIL = (0x7B, OBJ_LEN - 0x7B)     # 38 bytes no site reads


def ld_imm32_operand(site):
    """`ld XIX,imm32` (0x44) / `ld XIY,imm32` (0x45) at site: return imm32."""
    op = rb(site)[0]
    assert op in (0x44, 0x45), "%06X: not ld XIX/XIY,imm32 (%02X)" % (site, op)
    return u32(site + 1)


def bound_ok(bsite, run):
    name, off, ln = run[0], run[1], run[2]
    b = rb(bsite, 6)
    if name.endswith("Header8"):
        return b[:3] == bytes([0xDD, 0xDF, 0x63])      # cp IY,7 (compact i3 form) / jr ULE
    if name.endswith("Words4"):
        return b[:5] == bytes([0xDD, 0xCF, 0x08, 0x00, 0x67])  # cp IY,0x0008 / jr C
    if name.endswith("SongName"):
        return b[:3] == bytes([0x31, 0x03, 0x00])      # ld BC,0x0003
    if name.endswith("SixteenthTicks"):
        return b[:3] == bytes([0xCB, 0xCC, 0x03])      # and C,0x03
    return b[:5] == bytes([0xDD, 0xCF, 0x11, 0x00, 0x67])  # cp IY,0x0011 / jr C


def checks():
    out = []
    obj = rb(OBJ, OBJ_LEN)
    pos = 0
    for run in RUNS:
        name, off, ln, el, sites, how, dest = run
        out.append(("%s starts where the previous run ends" % name, off == pos))
        pos = off + ln
        for s, bsite in sites:
            out.append(("%s: operand at %06X = %06X" % (name, s, OBJ + off), ld_imm32_operand(s) == OBJ + off))
            if bsite:
                out.append(("%s: bound at %06X" % (name, bsite), bound_ok(bsite, run)))
    out.append(("the unread tail starts where the last run ends", TAIL[0] == pos))
    # the two heap descriptors are equal; the live one is (0x00617800, 0x050C)
    out.append(("HeapDescriptor == HeapDescriptorAlt", obj[0x10:0x16] == obj[0x16:0x1C]))
    base, count = int.from_bytes(obj[0x10:0x14], "little"), int.from_bytes(obj[0x14:0x16], "little")
    out.append(("heap base 0x00617800", base == 0x00617800))
    out.append(("block count 0x050C = 1292", count == 1292))
    out.append(("heap end 0x617800 + 1292*256 = 0x668400 lies inside CS3 (<= 0x680000)",
                base + count * 256 == 0x668400 <= 0x680000))
    # BStore_BootPhase0: xor HL,HL / jr Z,(the +0x10 path): Z is always set, so +0x16 is never read
    out.append(("0xF4404B xor HL,HL ; 0xF4404D jr Z", rb(0xF4404B, 3) == bytes([0xDB, 0xD3, 0x66])))
    out.append(("destination XIY = 0x3604 (BStore_HeapBase), BlockCount at +4 = 0x3608",
                rb(0xF44046) == bytes([0x45]) and u32(0xF44047) == 0x3604))
    # the tail: 38 bytes, and no 24-bit operand anywhere in either CPU-1 image points into it
    hits = []
    for img, base0 in ((PB, B0), (PA, A0)):
        for i in range(len(img) - 2):
            v = img[i] | img[i + 1] << 8 | img[i + 2] << 16
            if OBJ + TAIL[0] <= v < OBJ + OBJ_LEN:
                hits.append(base0 + i)
    # the one byte hit is prom_a 0xF8E21C..E = the last byte of `cp BC,0x0014` and `jr LT` (61 F4)
    out.append(("no operand points into the 38-byte tail (one coincidental byte run in prom_a)",
                hits == [0xF8E21C]))
    out.append(("the tail repeats the TrackOutChannelGm/SongName/SixteenthTicks bytes",
                obj[0x7B:0x86] == obj[0x66:0x71] and obj[0x86:0x97] == obj[0x60:0x71]
                and obj[0x97:0xA1] == obj[0x71:0x7B]))
    return out


def main():
    if "--selftest" in sys.argv:
        res = checks()
        fails = sum(1 for _, ok in res if not ok)
        for n, ok in res:
            print("%-4s %s" % ("ok" if ok else "FAIL", n))
        print("FAILURES: %d" % fails)
        sys.exit(1 if fails else 0)
    obj = rb(OBJ, OBJ_LEN)
    print("| run                                  | offset | bytes | element   | destination | values |")
    print("|--------------------------------------|--------|-------|-----------|-------------|--------|")
    for name, off, ln, el, sites, how, dest in RUNS:
        print("| %-36s | +0x%02X  | %5d | %-9s | 0x%06X    | %s |" % (name, off, ln, el, dest, obj[off:off + ln].hex(" ")))
    print("| %-36s | +0x%02X  | %5d | %-9s | none        | %s |" % ("WorkspaceDefaults_UnreadTail", TAIL[0], TAIL[1], "byte",
                                                                  obj[TAIL[0]:].hex(" ")))


if __name__ == "__main__":
    main()
