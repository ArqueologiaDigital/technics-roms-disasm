#!/usr/bin/env python3
"""pcm_encoding_probe.py -- what sample encoding do the wave ROMs' recordings use?

QUESTION IT ANSWERS
  "Are the recordings two's-complement or offset-binary or sign-magnitude, little- or big-endian,
   16-bit or two 8-bit samples per word -- and is KN5000 IC307 a whole stream or one chip of a pair?"
  The WAV converter (scripts/build/wave_wav.py) maps each recording to linear PCM; this probe is the
  evidence for the mapping it uses.

METHOD
  A recording of a musical sound is smooth: a wrong reading of its words makes jumps of about full
  scale wherever the true signal crosses the reading's discontinuity (zero for offset binary read as
  two's complement and back, the sign bit for sign-magnitude, every sample for the wrong byte order).
  For each recording and each candidate reading it counts
      jumps = the steps |x[i+1] - x[i]| larger than half the full scale (32768 for 16 bits, 128 for 8)
  and counts the readings with the fewest jumps (all readings tied, e.g. a silent recording, is
  counted as "tie").
  Readings of a 16-bit word: s16le (two's complement, low byte first), s16be, u16le (offset binary),
  sm16le (sign-magnitude).  Readings of a byte, for two-samples-per-word data: s8, u8, sm8.
  A second signal separates "one 16-bit sample per word" from "two 8-bit samples per word": the
  correlation between a word's low byte and its high byte, both read as s8.  For a 16-bit sample the
  low byte is the sample's least significant bits, unrelated to the high byte (correlation near 0);
  for two 8-bit neighbours it is a neighbouring sample (correlation near 1).

  KN7000: the recordings are the `.incbin_range` items of kn7000/src/wave/{main,sub}.s, each with the
  format its directory entries give (P bit 3, `8-bit` / `16-bit` in the census reason), on the stream
  joined from the chip pair (word i of Y, then word i of X).  KN5000: the `.incbin` items of
  waveform/ic307_page*.s on IC307.

INPUTS (private, read-only; nothing is written)
  $KN7000_WAVE_DIR  default ~/compartilhado/technics_romsets/kn7000 (c3cbqd00000[1-4].ic20x)
  $KN5000_IC307     default ~/compartilhado/technics_romsets/kn5000/kn5000_waveform_rom.ic307

RUN
  python3 notes/media-files-probes/pcm_encoding_probe.py          (about 20 s; numpy)
"""
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
CHIPS = {"main": ("c3cbqd000002.ic203", "c3cbqd000001.ic204"),
         "sub": ("c3cbqd000004.ic207", "c3cbqd000003.ic208")}

RANGE = re.compile(rb'^(\w+):\s*\.incbin_range\s+"[^"]+",\s*(0x[0-9a-f]+),\s*(0x[0-9a-f]+).*pcm: (\d+) (8|16)-bit')
SKIPCOUNT = re.compile(rb'^(\w+):\s*\.incbin\s+"kn5000_waveform_rom\.ic307",\s*(0x[0-9a-f]+),\s*(\d+)')


def stream(tg):
    y = np.fromfile(WAVE_DIR / CHIPS[tg][0], dtype="<u2")
    x = np.fromfile(WAVE_DIR / CHIPS[tg][1], dtype="<u2")
    s = np.empty(y.size * 2, dtype="<u2")
    s[0::2], s[1::2] = y, x
    return s.view(np.uint8)


def jumps(x, half):
    return int((np.abs(np.diff(x.astype(np.int64))) > half).sum())


def readings16(b):
    w = b.view("<u2").astype(np.int64)
    sm = np.where(w & 0x8000, -(w & 0x7FFF), w)
    return {"s16le": b.view("<i2"), "s16be": b.view(">i2"), "u16le": w, "sm16le": sm}


def readings8(b):
    u = b.astype(np.int64)
    return {"s8": b.view(np.int8), "u8": u, "sm8": np.where(u & 0x80, -(u & 0x7F), u)}


def bytecorr(b):
    lo = b[0::2].view(np.int8).astype(np.float64)
    hi = b[1::2].view(np.int8).astype(np.float64)
    if lo.std() == 0 or hi.std() == 0:
        return None
    return float(np.corrcoef(lo, hi)[0, 1])


def probe(items, label):
    """items: [(name, bytes, declared)]; declared is 8, 16 or None"""
    best = {8: Counter(), 16: Counter(), None: Counter()}
    corr = {8: [], 16: [], None: []}
    for name, b, dec in items:
        if len(b) < 64:
            continue
        for tag, rd, half in (("16-bit: ", readings16(b), 32768), ("8-bit: ", readings8(b), 128)):
            r = {k: jumps(v, half) for k, v in rd.items()}
            lo = min(r.values())
            win = [k for k, v in r.items() if v == lo]
            best[dec][tag + (win[0] if len(win) == 1 else "tie")] += 1
        c = bytecorr(b)
        if c is not None:
            corr[dec].append(c)
    print(f"== {label}")
    for dec in (16, 8, None):
        if not best[dec]:
            continue
        n = len(corr[dec])
        cc = np.array(corr[dec])
        what = {16: "declared 16-bit", 8: "declared 8-bit", None: "format not declared"}[dec]
        print(f"  {what}: {sum(best[dec].values()) // 2} recordings")
        print("    fewest jumps as one 16-bit sample per word: " + ", ".join(f"{k[8:]} {v}" for k, v in best[dec].most_common() if k.startswith("16")))
        print("    fewest jumps as two 8-bit samples per word:  " + ", ".join(f"{k[7:]} {v}" for k, v in best[dec].most_common() if k.startswith("8")))
        print(f"    low/high byte correlation: median {np.median(cc):+.3f}; > 0.5 in {(cc > 0.5).sum()} of {n}; "
              f"< 0.2 in {(cc < 0.2).sum()} of {n}")


def kn7000():
    for tg in ("main", "sub"):
        s = stream(tg)
        items = []
        for line in (ROOT / f"kn7000/src/wave/{tg}.s").read_bytes().split(b"\n"):
            m = RANGE.match(line)
            if m:
                a, b = int(m.group(2), 16), int(m.group(3), 16)
                items.append((m.group(1).decode(), s[a:b], int(m.group(5))))
        probe(items, f"KN7000 {tg} stream, {len(items)} recordings")


def kn5000():
    rom = np.fromfile(IC307, dtype=np.uint8)
    items = []
    for p in range(4):
        for line in (ROOT / f"waveform/ic307_page{p}.s").read_bytes().split(b"\n"):
            m = SKIPCOUNT.match(line)
            if m:
                a, n = int(m.group(2), 16), int(m.group(3))
                items.append((m.group(1).decode(), rom[a:a + n], None))
    probe(items, f"KN5000 IC307, {len(items)} recordings")
    # the test sine: whole period, and is it a stream half (every other sample of a 512-sample sine)?
    sine = rom[0x1a30:0x1a30 + 512].view("<i2").astype(np.float64)
    k = np.arange(256)
    ref = 32767 * np.sin(2 * np.pi * k / 256)
    print(f"  P0_W0000_Sine (256 words) vs one period of 32767 sin: mean |error| {np.abs(sine - ref).mean():.2f} LSB")


def kn7000_sine():
    s = stream("main")
    m = re.search(rb'^Main_P00_W000:\s*\.incbin_range\s+"[^"]+",\s*(0x[0-9a-f]+),\s*(0x[0-9a-f]+)',
                  (ROOT / "kn7000/src/wave/main.s").read_bytes(), re.M)
    a, b = int(m.group(1), 16), int(m.group(2), 16)
    w = s[a:b].view("<i2").astype(np.float64)
    k = np.arange(len(w))
    ref = 32767 * np.sin(2 * np.pi * k / len(w))
    print(f"== KN7000 Main_P00_W000 ({len(w)} samples) vs one period of 32767 sin: mean |error| {np.abs(w - ref).mean():.2f} LSB;"
          f" its even samples vs IC307's sine: equal = {bool(np.array_equal(w[0::2], np.fromfile(IC307, dtype='<i2')[0x1a30 // 2:0x1a30 // 2 + 256]))}")


if __name__ == "__main__":
    kn7000()
    kn5000()
    kn7000_sine()
