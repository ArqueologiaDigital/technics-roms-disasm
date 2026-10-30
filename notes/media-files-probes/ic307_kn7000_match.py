#!/usr/bin/env python3
"""ic307_kn7000_match.py -- is KN5000 IC307 one chip of a Y/X pair, and which KN7000 recording is each of its waves?

QUESTION IT ANSWERS
  "IC307's directory reads like the Y half of a KN7000 wave stream (kn7000_mame
   notes/g13-waves-2026-10-20/README.md, an inference).  Do IC307's recordings occur in the KN7000's
   wave ROMs, in which chip, and what format does the KN7000 directory give them?"
  The answer decides what a WAV of an IC307 wave holds: a whole recording, or every other word of one.

METHOD
  For every PCM item of waveform/ic307_page*.s (skip, count from the source) it searches the four KN7000
  chips for the item's bytes.  The search key is the item's first 64 bytes (items shorter than 64 B are
  skipped); on a hit it extends the match word by word and reports how much of the item matches.
  A hit at Y-chip byte y is stream word 2 * (y / 2), stream byte 2 * y (the stream is word i of Y, then
  word i of X: kn7000/notes/wave-roms-2026-10-29.md); the KN7000 recording whose `.incbin_range`
  (kn7000/src/wave/{main,sub}.s) contains that stream byte gives the format (8-bit / 16-bit, from its
  directory entries' P bit 3).

  It also prints, per KN7000 format, how IC307's low/high byte correlation (pcm_encoding_probe.py's
  second signal) splits, so the correlation rule for the unmatched items is calibrated on matched ones.

INPUTS (private, read-only; nothing is written): as pcm_encoding_probe.py.

RUN
  python3 notes/media-files-probes/ic307_kn7000_match.py              (about 1 min)
  python3 notes/media-files-probes/ic307_kn7000_match.py --list       (one line per IC307 item)
"""
import bisect
import os
import re
import sys
from collections import Counter
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
H = Path.home() / "compartilhado"
WAVE_DIR = Path(os.environ.get("KN7000_WAVE_DIR", H / "technics_romsets/kn7000"))
IC307 = Path(os.environ.get("KN5000_IC307", H / "technics_romsets/kn5000/kn5000_waveform_rom.ic307"))
CHIPS = {"c3cbqd000002.ic203": ("main", "Y"), "c3cbqd000001.ic204": ("main", "X"),
         "c3cbqd000004.ic207": ("sub", "Y"), "c3cbqd000003.ic208": ("sub", "X")}
RANGE = re.compile(rb'^(\w+):\s*\.incbin_range\s+"[^"]+",\s*(0x[0-9a-f]+),\s*(0x[0-9a-f]+).*pcm: (\d+) (8|16)-bit')
SKIPCOUNT = re.compile(rb'^(\w+):\s*\.incbin\s+"kn5000_waveform_rom\.ic307",\s*(0x[0-9a-f]+),\s*(\d+)')


def kn7000_items(tg):
    out = []
    for line in (ROOT / f"kn7000/src/wave/{tg}.s").read_bytes().split(b"\n"):
        m = RANGE.match(line)
        if m:
            out.append((int(m.group(2), 16), int(m.group(3), 16), m.group(1).decode(), int(m.group(5))))
    return out


def ic307_items():
    out = []
    for p in range(4):
        for line in (ROOT / f"waveform/ic307_page{p}.s").read_bytes().split(b"\n"):
            m = SKIPCOUNT.match(line)
            if m:
                out.append((m.group(1).decode(), int(m.group(2), 16), int(m.group(3))))
    return out


def bytecorr(b):
    a = np.frombuffer(b, dtype=np.int8).astype(np.float64)
    lo, hi = a[0::2], a[1::2]
    if lo.std() == 0 or hi.std() == 0:
        return None
    return float(np.corrcoef(lo, hi)[0, 1])


def match(listing=False):
    rom = IC307.read_bytes()
    chips = {c: (WAVE_DIR / c).read_bytes() for c in CHIPS}
    k7 = {tg: kn7000_items(tg) for tg in ("main", "sub")}
    k7start = {tg: [r[0] for r in k7[tg]] for tg in k7}
    rows = []
    for name, a, n in ic307_items():
        body = rom[a:a + n]
        hit = None
        if n >= 64:
            for c, (tg, half) in CHIPS.items():
                y = chips[c].find(body[:64])
                if y >= 0 and y % 2 == 0:
                    d = chips[c]
                    m = 64
                    while m < n and d[y + m:y + m + 2] == body[m:m + 2]:
                        m += 2
                    sb = 2 * y if half == "Y" else 2 * y + 2
                    i = bisect.bisect_right(k7start[tg], sb) - 1
                    rec = k7[tg][i] if i >= 0 and k7[tg][i][0] <= sb < k7[tg][i][1] else None
                    hit = (c, tg, half, y, m, rec, sb)
                    break
        rows.append((name, a, n, hit, bytecorr(body)))
    return rows


def main():
    rows = match()
    if "--list" in sys.argv:
        for name, a, n, hit, c in rows:
            if hit:
                ch, tg, half, y, m, rec, sb = hit
                where = f"{ch} ({tg} {half}) +{y:#x}, {m} of {n} B match"
                where += f", in {rec[2]} +{sb - rec[0]:#x} ({rec[3]}-bit)" if rec else ", outside every KN7000 recording"
            else:
                where = "no KN7000 chip holds its first 64 B" if n >= 64 else "shorter than 64 B, not searched"
            cs = "" if c is None else f"  corr {c:+.2f}"
            print(f"{name}\t{a:#08x}\t{n}\t{where}{cs}")
    searched = [r for r in rows if r[2] >= 64]
    hits = [r for r in searched if r[3]]
    print(f"IC307 PCM items: {len(rows)}; searched (>= 64 B): {len(searched)}; found in a KN7000 chip: {len(hits)}")
    print("  by chip: " + ", ".join(f"{c} ({CHIPS[c][0]} {CHIPS[c][1]}) {v}" for c, v in Counter(r[3][0] for r in hits).most_common()))
    full = sum(1 for r in hits if r[3][4] >= r[2])
    print(f"  the whole item matches: {full} of {len(hits)}")
    inrec = [r for r in hits if r[3][5]]
    print(f"  inside a KN7000 recording: {len(inrec)}; at its first sample: {sum(1 for r in inrec if r[3][6] == r[3][5][0])}")
    fm = Counter(r[3][5][3] for r in inrec)
    print(f"  the KN7000 recording's format: " + ", ".join(f"{k}-bit {v}" for k, v in sorted(fm.items())))
    for f in (16, 8):
        cc = np.array([r[4] for r in inrec if r[3][5][3] == f and r[4] is not None])
        if len(cc):
            print(f"  IC307 low/high byte correlation of items the KN7000 plays as {f}-bit: > 0.5 in {(cc > 0.5).sum()} of {len(cc)}, "
                  f"median {np.median(cc):+.3f}")
    rest = np.array([r[4] for r in rows if not (r[3] and r[3][5]) and r[4] is not None])
    print(f"  items not matched to a KN7000 recording: {len(rows) - len(inrec)}; of those with a correlation, > 0.5 in "
          f"{(rest > 0.5).sum()} of {len(rest)}")


if __name__ == "__main__":
    main()
