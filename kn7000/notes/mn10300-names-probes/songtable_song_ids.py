#!/usr/bin/env python3
"""songtable_song_ids.py -- question: what are the song-record event ids that song-records.md lists as
unknown (the CONTROL-track and part-track ids of the whitelists 0x485B9428 / 0x485B96A4)?

Joins, per id, the parameter record (block, offset, mask, shift, min, max, kind) from
notes/kn67-field-names-probes/m3em_param_map.py --table with the routines that get or set the id
with a literal (notes/kn67-field-names-probes/m3em_callers.py), keeping the firmware-named ones
(reflection names such as REVSELTitleFunc, AcSplitBoxProc).  A name is only as good as its caller.
Run from kn7000/ (needs src/program/):  python3 -I notes/mn10300-names-probes/songtable_song_ids.py
"""
import subprocess, sys, collections
IDS = ["0000a0", "008002", "008006", "008008", "008020", "008031", "008032", "008033", "008040", "008060",
       "00c080", "00c081", "00c082", "00c083", "00e000", "00e001", "00e002", "200000", "20005f", "200081",
       "200088", "2000a2", "2000b0", "204080", "204081", "00b014"]
P = "notes/kn67-field-names-probes/"
tab = subprocess.run([sys.executable, "-I", P + "m3em_param_map.py", "baserom/kn7000_program.rom", "--table"],
                     capture_output=True, text=True).stdout.splitlines()
rec = {l.split()[0]: l for l in tab if l.split() and l.split()[0] in IDS}
cal = subprocess.run([sys.executable, "-I", P + "m3em_callers.py", "src/program"] + IDS,
                     capture_output=True, text=True).stdout.splitlines()
who = collections.defaultdict(set)
for l in cal:
    p = l.split()
    if len(p) >= 4:
        who[p[0]].add(f"{p[2]}:{p[3]}")
for i in IDS:
    named = sorted(x for x in who[i] if not x.split(":")[1].startswith("func_"))
    print(f"{i}  record [{rec.get(i, '-')}]  callers {len(who[i])}  named {named[:6]}")
