#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Check a KN7000 flash image against a Panasonic SMCK*.INF checksum file from
# an update floppy: '@XXXXXXXX ; TOTAL SUM CHECK' = 32-bit sum of every byte of
# the image, then 16 x '@XXXX ; BLOCK n' = 16-bit byte sum of flash block n
# (0x40000 bytes each; the last one partial). See ../kn7000_extraction/FORMAT.md.
#
# Question it answers: "is this image the one the checksum file describes -- and
# if not, which blocks differ?" --length cuts the image (an update ships only up
# to the end of its payload); --patch OFF:TEXT tests a stated variant of the image
# (e.g. a different version marker), so a hypothesis about WHAT differs can be
# confirmed or refuted against all 17 sums at once.
#
# Usage: smck_check.py <image> <SMCK.INF> [--length N] [--patch OFF:TEXT ...] [--expect match|mismatch]
import argparse
import re
import sys

BLOCK = 0x40000


def sdiff(a, b):
    """16-bit wrapped a - b as a signed number."""
    d = (a - b) & 0xFFFF
    return d - 0x10000 if d >= 0x8000 else d


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("image")
    ap.add_argument("inf")
    ap.add_argument("--length", type=lambda v: int(v, 0))
    ap.add_argument("--patch", action="append", default=[], metavar="OFF:TEXT")
    ap.add_argument("--expect", choices=("match", "mismatch"))
    a = ap.parse_args()

    e = [int(x, 16) for x in re.findall(r"@([0-9A-Fa-f]+)", open(a.inf, encoding="latin1").read())]
    total, blocks = e[0], e[1:]
    img = bytearray(open(a.image, "rb").read())
    if a.length is not None:
        img = img[:a.length]
    for p in a.patch:
        off, text = p.split(":", 1)
        off = int(off, 0)
        img[off:off + len(text)] = text.encode("latin1")

    t = sum(img) & 0xFFFFFFFF
    got = [sum(img[i * BLOCK:(i + 1) * BLOCK]) & 0xFFFF for i in range(len(blocks))]
    bad = [i for i in range(len(blocks)) if got[i] != blocks[i]]
    ok = t == total and not bad
    desc = f"{a.image} (0x{len(img):X} bytes" + (f", {len(a.patch)} patch(es)" if a.patch else "") + ")"
    print(f"{desc} vs {a.inf}: total 0x{t:08X} {'==' if t == total else '!='} 0x{total:08X}; "
          f"{len(blocks) - len(bad)}/{len(blocks)} blocks match"
          + ("" if not bad else "; differ: " + ", ".join(
              f"block {i} 0x{got[i]:04X} vs 0x{blocks[i]:04X} ({sdiff(got[i], blocks[i]):+d})"
              for i in bad)))
    if a.expect == "match" and not ok:
        sys.exit(1)
    if a.expect == "mismatch" and ok:
        sys.exit(1)


if __name__ == "__main__":
    main()
