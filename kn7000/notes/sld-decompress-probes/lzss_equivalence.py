#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Question: does the pure-Python LZSS decoder in tools/sld_decompress.py give the
# same bytes as pylzss (the `lzss` C module in ../../kn7000_extraction/venv) on
# every Technics MN10300 update payload we hold?
#
# Run from kn7000/ with the extraction venv's interpreter, which has pylzss:
#   ../../kn7000_extraction/venv/bin/python notes/sld-decompress-probes/lzss_equivalence.py \
#       ../../technics_roms/sources/*/*.SLD
# Prints one row per file: name, declared size, pylzss == declared size, pure == pylzss.
# Exit status 1 if any row differs.
import os
import sys

import lzss

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "tools"))
import sld_decompress as SD  # noqa: E402

bad = 0
for p in sys.argv[1:]:
    d = open(p, "rb").read()
    size = int.from_bytes(d[8:11], "big")
    a = lzss.decompress(data=d[11:], initial_buffer_values=0)
    b = SD.lzss_decompress(d[11:])
    ok = len(a) == size and a == b
    bad += not ok
    print(f"{p:60s} 0x{size:06X} pylzss_len_ok={len(a) == size} pure_equal={a == b}")
sys.exit(1 if bad else 0)
