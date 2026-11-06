#!/usr/bin/env python3
"""spell_acc_note_tables.py -- spell the sounding-note table bases and ends in the accompaniment code by name.

QUESTION / JOB
  add_kn5000_ram_names.py names `ld xhl, N` pointer loads but not `ld xbc, N` / `ld xix, N` or the loop bounds
  `cp xhl, N` / `cp xix, N` (hex, or decimal as v7 spells them).  This spells, in v10 / v9 / v7 sequencer/*.s, each such immediate that equals one of
  the six ACC_*_NOTES bases of that tree as the name, and the end bound base + size as `NAME+size` (decimal).
  The values are read from the tree's own shared/ram_variables_by_use.s, so a number becomes a name of the same
  value: no ROM byte changes (make gate checks).
RUN (repository root)
  python3 notes/kn5000-notes-2026-11-06/probes/spell_acc_note_tables.py [--dry-run]
"""
import glob, re, sys
NAMES = {"ACC_DRUM1_NOTES": 48, "ACC_DRUM2_NOTES": 48, "ACC_BASS_NOTES": 72,
         "ACC_ACCOMP1_NOTES": 72, "ACC_ACCOMP2_NOTES": 72, "ACC_ACCOMP3_NOTES": 72}
dry = "--dry-run" in sys.argv
for t in ("v10", "v9", "v7"):
    equ = open(f"{t}/maincpu/shared/ram_variables_by_use.s", "rb").read().decode("latin-1")
    val = {n: int(re.search(r"\.equ\s+%s,\s*(0x[0-9a-f]+)" % n, equ).group(1), 16) for n in NAMES}
    base = {v: n for n, v in val.items()}
    # an end bound that is also the next table's base is spelled as the end of the table the loop walks:
    # the loop's own `ld` names the table, so remember the last table loaded into that register.
    total = 0
    for f in sorted(glob.glob(f"{t}/maincpu/sequencer/*.s")):
        lines = open(f, "rb").read().split(b"\n")
        last = {}
        n = 0
        for i, l in enumerate(lines):
            s = l.decode("latin-1")
            m = re.match(r"^(\t(ld|cp)(\s+)x(hl|bc|ix),\s*)(0x[0-9a-f]+|\d+|ACC_\w+_NOTES)\s*$", s)
            if not m:
                continue
            op, reg, arg = m.group(2), m.group(4), m.group(5)
            if op == "ld":
                nm = arg if arg in NAMES else base.get(int(arg, 0))
                if nm:
                    last[reg] = nm
                    if arg != nm:
                        lines[i] = (m.group(1) + nm).encode(); n += 1
                continue
            if arg in NAMES or reg not in last:
                continue
            nm = last[reg]
            if int(arg, 0) == val[nm] + NAMES[nm]:
                lines[i] = (m.group(1) + "%s+%d" % (nm, NAMES[nm])).encode(); n += 1
        if n:
            total += n
            print(t, f, n)
            if not dry:
                open(f, "wb").write(b"\n".join(lines))
    print(t, "spelled", total)
