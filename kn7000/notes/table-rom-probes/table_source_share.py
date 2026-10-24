#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# How much of a table-flash source still passes the reference image through?
#
# Splits the bytes a source emits three ways: `.incbin_range` of the reference image
# (passthrough: bytes nobody has explained), `.incbin` of a committed file (the JPEG
# segments in src/table/), and everything else (directives the source spells out:
# .long/.byte/.space/.align and MN10300 instructions), which is the image size minus
# the other two.  Run from kn7000/:
#
#   python3 notes/table-rom-probes/table_source_share.py src/table.s 0x3E94D4
#   python3 notes/table-rom-probes/table_source_share.py src/sp7001/table.s 0x400000
import os
import re
import sys

path, size = sys.argv[1], int(sys.argv[2], 0)
raw = files = 0
for line in open(path, encoding="latin1"):
    line = line.split("#", 1)[0]
    m = re.search(r'\.incbin_range\s+"[^"]+"\s*,\s*([^,]+),\s*([^,\n]+)', line)
    if m:
        raw += eval(m.group(2)) - eval(m.group(1))      # noqa: S307 - our own source
        continue
    m = re.search(r'\.incbin\s+"([^"]+)"', line)
    if m:
        files += os.path.getsize(m.group(1))
print(f"{path}: {size:,d} bytes; passthrough .incbin_range {raw:,d} ({100 * raw / size:.2f}%), "
      f".incbin files {files:,d} ({100 * files / size:.2f}%), "
      f"spelled out {size - raw - files:,d} ({100 * (size - raw - files) / size:.2f}%)")
