#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# wave_pair.py -- a tone generator's two wave ROMs <-> the one stream of 16-bit words they hold.
#
# The KN7000 has two tone generators, and each reads a pair of 16 MiB wave ROMs: a Y chip and an
# X chip.  The pair is one stream of 16-bit samples, word i of Y followed by word i of X
# (real_dump_v1.3_b893/wave-analysis/xy.py in the private ROM repository; notes/wave-roms-2026-10-29.md).
# src/wave/main.s and src/wave/sub.s describe the streams; this tool makes the chips from them and,
# the other way round, the reference streams from the chip images.
#
#   wave_pair.py join Y.ic X.ic STREAM.bin       word 2i of STREAM = Y[i], 2i+1 = X[i]
#   wave_pair.py split STREAM.bin Y.ic X.ic      the inverse
#
# Whole-buffer slicing (array module), no per-word Python loop: 32 MiB in well under a second.
import array
import sys


def words(path):
    a = array.array("H")
    with open(path, "rb") as f:
        a.frombytes(f.read())
    if sys.byteorder != "little":
        a.byteswap()
    return a


def save(a, path):
    if sys.byteorder != "little":
        a = array.array("H", a)
        a.byteswap()
    with open(path, "wb") as f:
        f.write(a.tobytes())


def main():
    if len(sys.argv) != 5 or sys.argv[1] not in ("join", "split"):
        sys.exit("usage: wave_pair.py join Y X STREAM | split STREAM Y X")
    if sys.argv[1] == "join":
        y, x = words(sys.argv[2]), words(sys.argv[3])
        if len(y) != len(x):
            sys.exit(f"the two chips differ in size ({2 * len(y):#x}, {2 * len(x):#x} bytes)")
        s = array.array("H", bytes(4 * len(y)))
        s[0::2] = y
        s[1::2] = x
        save(s, sys.argv[4])
    else:
        s = words(sys.argv[2])
        if len(s) % 2:
            sys.exit("the stream holds an odd number of words")
        save(s[0::2], sys.argv[3])
        save(s[1::2], sys.argv[4])
    return 0


if __name__ == "__main__":
    sys.exit(main())
