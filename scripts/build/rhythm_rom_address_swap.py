#!/usr/bin/env python3
"""rhythm_rom_address_swap.py -- the A19/A21 address-line swap between the KN5000 rhythm ROM IC14 and its raw read.

QUESTION IT ANSWERS
  "Is the chip read we hold (kn5000_rhythm_data_rom.ic14.as-read-a19a21-swapped) exactly the descrambled
   image with ROM address lines A19 and A21 exchanged?"  rhythm_data/ builds the descrambled image, the one
   the firmware's pointers are correct for (docs/accompaniment-style-reader.md: 9,696 of 9,696 lane reads
   framed correctly after the swap, 3,439 before).  --check applies the swap to the rebuilt image and
   compares it with the raw read byte for byte, so the raw read is certified by the same source.

THE TRANSFORM
  raw[a] = img[swap(a)], swap(a) = a with bits 19 and 21 exchanged.  The swap is its own inverse, so the
  same function also descrambles a raw read.  It moves whole 512 KB blocks: 0x080000 <-> 0x200000 and
  0x180000 <-> 0x300000; blocks 0, 0x100000, 0x280000 and 0x380000 stay where they are.

USAGE
  python3 scripts/build/rhythm_rom_address_swap.py IN OUT                 # write the swapped image
  python3 scripts/build/rhythm_rom_address_swap.py --check IMG RAW [--sha1 SHA1]
"""
import argparse
import hashlib
import sys

BLOCK = 1 << 19


def swap_address(a):
    b19 = (a >> 19) & 1
    b21 = (a >> 21) & 1
    return (a & ~((1 << 19) | (1 << 21))) | (b19 << 21) | (b21 << 19)


def swap_image(img):
    if len(img) != 0x400000:
        sys.exit("expected a 4 MB image, got %d bytes" % len(img))
    out = bytearray(len(img))
    for blk in range(0, len(img), BLOCK):
        t = swap_address(blk)
        out[t:t + BLOCK] = img[blk:blk + BLOCK]
    return bytes(out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true", help="compare swap(IN) with OUT instead of writing OUT")
    ap.add_argument("--sha1", help="with --check: the SHA-1 OUT must have")
    ap.add_argument("inp")
    ap.add_argument("out")
    a = ap.parse_args()
    img = open(a.inp, "rb").read()
    sw = swap_image(img)
    if not a.check:
        open(a.out, "wb").write(sw)
        return
    raw = open(a.out, "rb").read()
    if a.sha1 and hashlib.sha1(raw).hexdigest() != a.sha1:
        print("FAIL  %s has SHA-1 %s, expected %s" % (a.out, hashlib.sha1(raw).hexdigest(), a.sha1))
        sys.exit(1)
    if sw != raw:
        n = sum(1 for x, y in zip(sw, raw) if x != y)
        print("FAIL  A19/A21-swapped %s differs from %s in %d bytes" % (a.inp, a.out, n))
        sys.exit(1)
    print("OK    A19/A21-swapped %s == %s (SHA-1 %s)" % (a.inp, a.out, hashlib.sha1(raw).hexdigest()))


if __name__ == "__main__":
    main()
