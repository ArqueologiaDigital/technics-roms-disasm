#!/usr/bin/env python3
"""songtable_demo_l.py -- question: does the Feature Demo ever ask for the '27\\n' placeholders that
DemoJpgDataL1..L4, L7, L8 return (table segments 51-54, 65, 66)?

1. StartFeatureDemo (941) plays StartFeatureDemo_Table 0x4867F75C[song - 1]: prints its 15 script
   pointers and, per script, the fdemo_<x> groups its <SHOW OBJ="..."> lines name.
2. From kn7000/src/program/data/*.s: every VwJpegFile widget's func=FN_DemoJpgData<xn>, grouped by
   picture, with the screens (fdemo_<group><n>) that hold it.
Expected: ten scripts (groups a..j), slots 11..15 the empty script 0x4867F73C; L1 named only by the ten
fdemo_l screens, L2-L4/L7/L8 by no widget.
Run from kn7000/:  python3 -I notes/mn10300-names-probes/songtable_demo_l.py
"""
import glob, re, struct
from collections import defaultdict
B = 0x48400000
d = open("baserom/kn7000_program.rom", "rb").read()
for k in range(15):
    p = struct.unpack_from("<I", d, 0x4867F75C - B + 4 * k)[0]
    o = p - B; e = d.find(b"</ACTION>", o)
    objs = re.findall(rb'OBJ="fdemo_([a-z])', d[o:e])
    print(f"song {k + 1:2d}: script 0x{p:08X}, {len(objs):2d} SHOWs, groups {sorted(set(x.decode() for x in objs))}")
use = defaultdict(set)
for f in glob.glob("src/program/data/*.s"):
    for m in re.finditer(rb"VwJpegFile\s+(fdemo_\w+?)_JpegFile\d+.*?func=FN_DemoJpgData(\w+)", open(f, "rb").read()):
        use[m.group(2).decode()].add(m.group(1).decode())
for xn in ("L1", "L2", "L3", "L4", "L5", "L6", "L7", "L8"):
    print(f"DemoJpgData{xn}: {len(use[xn])} screens {sorted(use[xn])}")
