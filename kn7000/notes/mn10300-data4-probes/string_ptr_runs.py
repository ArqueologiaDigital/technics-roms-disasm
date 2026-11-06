#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""string_ptr_runs.py -- QUESTION ANSWERED: "how many census-opaque bytes of the siblings are runs of >= 16 bytes of
aligned words, each 0 or a pointer to a printable NUL-ended string (2..79 characters), at least 4 of them not 0?"
The rule gen_data_s.string_ptr_runs types.  Prints per model: runs, bytes, the first runs (file offset, bytes,
non-zero words).  RUN (from the repository root): python3 kn7000/notes/mn10300-data4-probes/string_ptr_runs.py"""

import os, re, sys, struct
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import fx_param_lists as F
R = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
for model, base in (("kn6000", 0x4C000000), ("kn6500", 0x4C000000), ("kn2400", 0x48400000), ("hdsx3", 0x97800000)):
    rom = open(f"{R}/{model}/baserom/" + ("hdsx3_extapr.rom" if model == "hdsx3" else f"{model}_program.rom"), "rb").read()
    def isstr(v):
        o = v - base
        if not (0 <= o < len(rom)):
            return False
        e = rom.find(b"\0", o, o + 80)
        if e < 0 or e - o < 2:
            return False
        s = rom[o:e]
        return all(0x20 <= c < 0x7F for c in s) and (o == 0 or rom[o - 1] in (0, 0xFF) or True)
    tot, runs = 0, []
    for a, e in F.opaque_ranges(model):
        o = a + (-a % 4)
        while o + 16 <= e:
            q, nz = o, 0
            while q + 4 <= e:
                v = int.from_bytes(rom[q:q + 4], "little")
                if v and not isstr(v):
                    break
                nz += bool(v)
                q += 4
            if nz >= 4 and q - o >= 16:
                runs.append((o, q - o, nz))
                tot += q - o
                o = q
            else:
                o += 4
    print(model, len(runs), tot, [(hex(o), n, z) for o, n, z in runs[:12]])
