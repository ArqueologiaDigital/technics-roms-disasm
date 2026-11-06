#!/usr/bin/env python3
"""song_id_dump_names.py -- question (N-e411f8fa): what does the firmware itself call each part-scoped M3
parameter id?  PROGRAM 941 has a parameter dump, PartParamDumpLine 0x48500C71, that looks a key up in
func_48500C71_Records (128 x {u32 key, code pointer}) and runs the case, which sprintf()s one line with a
format string naming the parameter ("%s DRAWBAR TYPE %s", "%s SUSTAIN LENGTH %3d", ...).

Signal: the data source src/program/data/data_01.s (the REC_func_48500C71_Records rows: key, proc) and
the converted code src/program/region1_*.s (each proc's first `mov Str_..., d0` before its sprintf call),
the string's text from the data source's `.asciz`.  Prints `key  label  "format"` for every row, the
rows of the ids song-records.md section 3 lists as unexplained marked with '*'.

usage (from kn7000/):  python3 -I notes/presentation-control-probes/song_id_dump_names.py [--unknown]
"""
import glob
import re
import sys

UNKNOWN = {0x8002, 0x8006, 0x8008, 0x8031, 0x8032, 0xC081, 0xE000, 0xE002, 0x200081, 0x204080, 0x204081}
UNKNOWN |= set(range(0x200088, 0x200090)) | {0x200099, 0x20009A} | set(range(0x2000B0, 0x2000C0))

data = "\n".join(open(f, "rb").read().decode("latin-1") for f in sorted(glob.glob("src/program/data/*.s")))
strings = {}
for m in re.finditer(r'^(Str_\w+):\s*\.asciz\s+"((?:[^"\\]|\\.)*)"', data, re.M):
    strings[m.group(1)] = m.group(2)
rows = re.findall(r"REC_func_48500C71_Records\s+key=(0x[0-9A-Fa-f]+|-?\d+), proc=(\w+)", data)

code = {}
for f in sorted(glob.glob("src/program/region1_*.s")):
    L = open(f, "rb").read().decode("latin-1").splitlines()
    for i, ln in enumerate(L):
        m = re.match(r"^(loc_[0-9A-F]+):", ln)
        if m:
            code[m.group(1)] = L[i + 1:i + 40]


def fmt_of(proc):
    for ln in code.get(proc, []):
        m = re.match(r"\s+mov\s+(Str_\w+), d0$", ln)
        if m and "%" in strings.get(m.group(1), ""):
            return m.group(1), strings[m.group(1)]
        if re.match(r"\s+call\s+sprintf", ln):
            break
    return "?", "?"


only_unknown = "--unknown" in sys.argv
seen = 0
for key, proc in rows:
    k = int(key, 0)
    if k < 0:
        continue
    pid = k - 1                      # the table is keyed by id + 1 (0 = empty slot)
    if only_unknown and pid not in UNKNOWN:
        continue
    lab, s = fmt_of(proc)
    seen += 1
    print(f"{'*' if pid in UNKNOWN else ' '} id {pid:#08x}  key {k:#08x}  {proc:14} {s!r}")
print(f"{len(rows)} rows, {seen} printed")
