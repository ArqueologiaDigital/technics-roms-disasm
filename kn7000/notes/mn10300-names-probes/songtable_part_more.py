#!/usr/bin/env python3
"""songtable_part_more.py -- question: in what order are part_more's nine fields (bytes 15..23 of a
MEMORY variation record's 0x18-byte part block) stored, and does any data disagree with "never used"?

Prints program 941's part-field table 0x485B77D4 (24 {status, controller} pairs: the RAM part template
0x5003A37C's field order, read field by field by func_4844085D from StyleTemplateBuildLoop 0x48441CDB),
the default template 0x485B7804 (fields 15..23 = 0, 0, 127, 0, 0, 64, 64, 64, 64), and the census of
bytes 15..23 over every 'TCMP' container found in tables 84/83, the owner's IC21 and the factory
customdata images.  Code facts this rests on (not re-derived here): StyleRecordBindMem 0x4843374A points
0x50034BAC[] at record+0x20+part*0x18 and func_4844187A memcpy's only 0xF bytes of each into the template;
func_48441EB4 (preset -> MEMORY) writes 15.  Expected: every tail byte 0.
Run from kn7000/:  python3 -I notes/mn10300-names-probes/songtable_part_more.py
"""
import glob, re, struct
B = 0x48400000
p = open("baserom/kn7000_program.rom", "rb").read()
o = 0x485B77D4 - B
names = {0xB0: "CC", 0xC0: "PC", 0xD0: "CP", 0xE0: "PB"}
print("part-field table 0x485B77D4:", " ".join(f"{k}:{names.get(p[o+2*k], '--')}{p[o+2*k+1]}" for k in range(24)))
print("default template 0x485B7804 fields 15..23:", list(p[0x485B7804 - B + 15:0x485B7804 - B + 24]))
files = ["baserom/kn7000_table.rom", "baserom/kn7000_table_sp7001.rom", "baserom/kn7000_ic21_own.bin"] + sorted(glob.glob("baserom/customdata/*.ic21"))
tot = nz = cont = 0
for f in files:
    try:
        d = open(f, "rb").read()
    except FileNotFoundError:
        print("missing", f); continue
    for m in re.finditer(rb"TCMP\x00\x00", d):
        s = m.start(); n = int.from_bytes(d[s + 0x16:s + 0x18], "big")
        if not 1 <= n <= 3:
            continue
        cont += 1
        for v in range(20 * n):
            r = s + 0x70 + 0x80 * n + 0xE0 * v
            for k in range(8):
                blk = d[r + 0x20 + 0x18 * k:r + 0x38 + 0x18 * k]
                tot += 1; nz += any(blk[15:24])
print(f"{cont} TCMP containers in {len(files)} images, {tot} part blocks, {nz} with a non-zero byte in 15..23")
