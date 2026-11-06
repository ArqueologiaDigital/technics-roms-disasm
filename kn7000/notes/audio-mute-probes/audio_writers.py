#!/usr/bin/env python3
"""audio_writers.py -- question (N-44e56012): which code in a KN7000 program build can move the three
software-driven audio lines the service manual shows, and with what value?

  PMUT  GPIO byte P04 (0x36008004) bit 2: every bset / bclr of mask 0x04 and every byte / word store
        to P04 (with the constant loaded into the stored register just before, when there is one)
  SPSW, SDMODE, DAC  the sound-control latch SD_POWER_CTRL (0x98060000; IC25): every store to it and
        every call of its bit setters with the constant mask passed in d0
  M3 0x600009  the parameter whose handler (0x48491B18 in 941) sets / clears SPSW: every
        `mov 0x?0600009, d0` and the value passed in d1
  DAC words  every constant passed to the DAC mode-word writer (SdPowerSerial16 / DacModeWordWrite)

Signal: the converted program source src/<tree>/program/*.s, read as bytes (the files hold raw
non-UTF-8 bytes).  Each hit prints `file:line  routine  instruction  [constant]`, the routine being
the last `func_` / named label above the line.

usage (from kn7000/):  python3 -I notes/audio-mute-probes/audio_writers.py [program|b893|b935|sp7001]
"""
import glob
import re
import sys

tree = sys.argv[1] if len(sys.argv) > 1 else "program"
base = "src/program" if tree == "program" else f"src/{tree}/program"
LATCH_FNS = ("SdPowerCtrlSet", "SdPowerCtrlClear", "SdPowerCtrlWrite", "SdPowerCtrlSetRaw",
             "SdPowerCtrlClearRaw", "SoundLatchSet", "SoundLatchClear", "SoundLatchWrite",
             "SoundLatchSetRaw", "SoundLatchClearRaw")
DAC_FNS = ("SdPowerSerial16", "DacModeWordWrite")
LABEL = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*):\s*$")
MOVK = re.compile(r"^\s+mov\s+(-?0x[0-9a-fA-F]+|-?\d+(?::32)?), (d\d)\s*$")

hits = {"PMUT": [], "LATCH": [], "M3 0x600009": [], "DAC": []}
for path in sorted(glob.glob(f"{base}/*.s")):
    lines = open(path, "rb").read().decode("latin-1").splitlines()
    routine = "?"
    last = {}                      # register -> (line index, constant) of the last `mov K, dN`
    for i, ln in enumerate(lines):
        m = LABEL.match(ln)
        if m and not m.group(1).startswith("loc_"):
            routine = m.group(1)
            last = {}
        m = MOVK.match(ln)
        if m:
            last[m.group(2)] = (i, m.group(1).replace(":32", ""))
        s = ln.strip()
        where = f"{path.split('/')[-1]}:{i + 1}"
        if re.match(r"b(set|clr)\s+0x04, \(P04\)$", s):
            hits["PMUT"].append((where, routine, s, ""))
        m = re.match(r"(movbu|movhu|mov)\s+(d\d), \(P04\)$", s)
        if m:
            k = last.get(m.group(2))
            v = k[1] if k and i - k[0] <= 3 else "?"
            hits["PMUT"].append((where, routine, s, f"value {v}"))
        if re.match(r"movbu\s+d\d, \(SD_POWER_CTRL\)$", s):
            hits["LATCH"].append((where, routine, s, ""))
        m = re.match(r"call\s+(\w+?)(?:_entry)?,", s)
        if m and m.group(1) in LATCH_FNS + DAC_FNS:
            k = last.get("d0")
            v = k[1] if k and i - k[0] <= 4 else "?"
            hits["DAC" if m.group(1) in DAC_FNS else "LATCH"].append((where, routine, s, f"d0 = {v}"))
        if re.match(r"mov\s+0x[0-9a-f]?0600009, d0$", s):
            v = "?"
            for j in range(i + 1, min(i + 4, len(lines))):
                mm = re.match(r"\s+(?:mov\s+(-?0x[0-9a-fA-F]+|\d+), d1|clr\s+d1)\s*$", lines[j])
                if mm:
                    v = mm.group(1) or "0"
                    break
            hits["M3 0x600009"].append((where, routine, s, f"d1 = {v}"))

for k, rows in hits.items():
    print(f"== {k}: {len(rows)}")
    for where, routine, s, extra in rows:
        print(f"  {where:24} {routine:28} {s:36} {extra}")
