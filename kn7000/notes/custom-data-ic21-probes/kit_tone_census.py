#!/usr/bin/env python3
"""kit_tone_census.py -- question (N-b8f49b1e): is the CUSTOM bank's custom-sound block a TABLE tone
laid out like the table flash's kits, and which values does a voice record's +0x0D (the byte
TgNoteOnTableTone 0x4C03600D tests: bit 0 stages layer 0, bit 2 layer 1) take?

Signal: the typed sources, read as bytes --
  * src/table/voices/internal_archive.s: each `tone_head_table` row (class + 22 bytes after the
    16-character name) and each `VOICE_HEAD "name", h0d, ...` row;
  * src/customdata/*/Slot*.inc: the `CSOUND_HEAD "name", class, 22 bytes` rows and the
    VOICE_HEAD rows that follow one (stale residue copies are skipped: they are .incbin / .byte).
Prints the distinct TABLE heads with the tones that use them, and the +0x0D histogram per source.

usage (from kn7000/):  python3 -I notes/custom-data-ic21-probes/kit_tone_census.py
"""
import collections
import glob
import re

HEAD = re.compile(r"^(Tone_\w+):\s*$")
TH = re.compile(r"^\s+tone_head_table\s+(.*?)\s*(#.*)?$")
CH = re.compile(r'^\s+CSOUND_HEAD\s+"([^"]*)",\s*(.*?)\s*(#.*)?$')
VH = re.compile(r'^(?:\w+:)?\s+VOICE_HEAD\s+"[^"]*",\s*(0x[0-9a-f]+)')


def ints(s):
    return tuple(int(x, 0) for x in s.split(","))


heads = collections.defaultdict(list)
h0d = {"table flash archive": collections.Counter(), "CUSTOM banks": collections.Counter()}
tone = None
for ln in open("src/table/voices/internal_archive.s", "rb").read().decode("latin-1").splitlines():
    m = HEAD.match(ln)
    if m:
        tone = m.group(1)
    m = TH.match(ln)
    if m:
        heads[ints(m.group(1))].append(tone)
    m = VH.match(ln)
    if m:
        h0d["table flash archive"][int(m.group(1), 16)] += 1
for path in sorted(glob.glob("src/customdata/*/Slot*.inc")):
    if "Residue" in path:
        continue
    for ln in open(path, "rb").read().decode("latin-1").splitlines():
        m = CH.match(ln)
        if m:
            heads[ints(m.group(2))].append(f"{path.split('/')[-2]}/{path.split('/')[-1]} {m.group(1).strip()!r}")
        m = VH.match(ln)
        if m:
            h0d["CUSTOM banks"][int(m.group(1), 16)] += 1
print("== TABLE-tone heads (class, then the 22 bytes after it)")
for h, users in sorted(heads.items(), key=lambda kv: -len(kv[1])):
    cust = [u for u in users if not u.startswith("Tone_")]
    print(f"  {' '.join(f'{x:02x}' for x in h)}  {len(users)} tones: {', '.join(users[:6])}{' ...' if len(users) > 6 else ''}"
          + (f"  [CUSTOM: {', '.join(cust)}]" if cust else ""))
for src, c in h0d.items():
    print(f"== voice record +0x0D, {src}: {sum(c.values())} records")
    for v, n in sorted(c.items()):
        print(f"  0x{v:02x}  {n:5d}  layer 0 {'on' if v & 1 else 'off'}, layer 1 {'on' if v & 4 else 'off'}, other bits 0x{v & ~5 & 0xff:02x}")
