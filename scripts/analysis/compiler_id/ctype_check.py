#!/usr/bin/env python3
"""ctype_check.py -- is the ROM's character-class table Toshiba's `_ctype[256]`?

QUESTION IT ANSWERS
  Builds Toshiba's `_ctype` table from the package's LIB/SRC/_CTYPE.C (128 initialised entries, the rest zero by C
  rules) with the bit values of INCLUDE/CTYPE.H (__UC 0x01 ... __BLK 0x40, __HEX 0x80 -- not the BSD layout) and
  compares it with 256 bytes of a ROM image.  The KN5000 v10 table is CType_ClassTable at 0xEED778 (file offset
  0xED778); the HD-AE5000 copy is at 0x2F9362 (file offset 0x79362).

RUN
  python3 -I scripts/analysis/compiler_id/ctype_check.py T900_DIR ROM FILE_OFFSET
  e.g. python3 -I scripts/analysis/compiler_id/ctype_check.py T900 original_ROMs/kn5000_v10_program.rom 0xED778
"""
import re
import sys


def main():
    t900, rom, off = sys.argv[1], sys.argv[2], int(sys.argv[3], 16)
    defs = {}
    for line in open(t900 + "/INCLUDE/CTYPE.H", encoding="latin-1"):
        m = re.match(r'#define\s+(__\w+)\s+(0x[0-9a-fA-F]+)', line)
        if m:
            defs[m.group(1)] = int(m.group(2), 16)
    src = open(t900 + "/LIB/SRC/_CTYPE.C", encoding="latin-1").read()
    body = src[src.index("{") + 1:src.index("}")]
    vals = []
    for item in body.replace("\r", "").replace("\n", "").split(","):
        item = item.strip()
        if item:
            v = 0
            for t in item.split("|"):
                v |= defs[t.strip()]
            vals.append(v)
    vals += [0] * (256 - len(vals))
    tab = open(rom, "rb").read()[off:off + 256]
    same = sum(1 for a, b in zip(vals, tab) if a == b)
    print("%s @ 0x%X: %d of 256 bytes equal Toshiba's _ctype" % (rom, off, same))
    sys.exit(0 if same == 256 else 1)


if __name__ == "__main__":
    main()
