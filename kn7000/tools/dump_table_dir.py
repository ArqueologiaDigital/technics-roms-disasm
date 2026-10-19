#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Prints the KN7000 "Table" flash directory as an annotated listing: the 85
# uint32 little-endian offsets and, for each of the 84 resulting segments, its
# range, size and a guess at its content type.

import struct
import sys


def classify(seg):
    if seg[:2] == b"\xff\xd8":
        return "JPEG image"
    if seg[:2] == b"BM":
        return "Windows BMP"
    tag = ""
    for b in seg[:4]:
        if 0x20 <= b < 0x7F:
            tag += chr(b)
        else:
            break
    printable = sum(1 for c in seg[:64] if 32 <= c < 127 or c in (9, 10, 13))
    if printable > 56:
        return "text"
    return f"data (tag {tag!r})" if tag else "data"


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else "baserom/kn7000_table.rom"
    rom = open(path, "rb").read()

    first = struct.unpack_from("<I", rom, 0)[0]
    count = first // 4
    entries = list(struct.unpack_from(f"<{count}I", rom, 0))
    dirents = [entries[0]]
    for v in entries[1:]:
        if v <= dirents[-1] or v > len(rom):
            break
        dirents.append(v)

    print(f"; KN7000 table flash directory ({path})")
    print(f"; {len(dirents)} uint32 offsets -> {len(dirents) - 1} segments;"
          f" file size {len(rom):#x}")
    print(";")
    for i, (start, end) in enumerate(zip(dirents, dirents[1:])):
        print(f"seg{i:02d}: {start:#08x}..{end:#08x}"
              f"  {end - start:#8x} bytes  {classify(rom[start:end])}")
    print(f"; end sentinel dir[{len(dirents) - 1}] = {dirents[-1]:#x}"
          f" (== file size)")


if __name__ == "__main__":
    main()
