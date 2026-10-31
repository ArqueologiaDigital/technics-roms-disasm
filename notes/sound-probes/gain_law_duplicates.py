#!/usr/bin/env python3
"""gain_law_duplicates.py -- is any 8-bit KN7000 recording also stored as 16-bit, so the 8-bit gain law can be measured?

QUESTION: an 8-bit recording's segments carry a 6-bit code (record word bits 13:8) that the tone generator
  applies as a gain; no CPU reads it, and no datasheet for the TG LSIs is known, so its law (kn7000_mame g13
  code8fit.py: 2^(-(code & 7)/2), a continuity fit) cannot be read from firmware.  If the same audio were
  also stored as 16-bit, the ratio 16-bit / 8-bit per segment would MEASURE the law.  Is there such a copy?
METHOD: for each 8-bit recording (kn7000/src/wave/{main,sub}_wav.tsv), take the first 64-sample window
  inside the recording with |sample| >= 2 throughout and >= 8 sign changes (a gain-invariant pattern);
  search its sign bits, in all 8 bit phases, in the sign bits of every 16-bit recording of both streams;
  verify each of the first 20 candidates per phase by the correlation of 512 samples (pass > 0.8).
READS kn7000/baserom/kn7000_wave_{main,sub}.bin (git-ignored; `make -C kn7000` joins them, SHA-1 checked).
RUN  python3 notes/sound-probes/gain_law_duplicates.py      (numpy; about 1 minute)
Printed 2026-10-31: 548 of the 959 8-bit recordings have such a window; 0 have a 16-bit copy.
"""
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
K7 = ROOT / "kn7000"
W = 64
streams = {tg: np.frombuffer((K7 / f"baserom/kn7000_wave_{tg}.bin").read_bytes(), dtype="<i2") for tg in ("main", "sub")}
rows = []
for tg in ("main", "sub"):
    for ln in (K7 / f"src/wave/{tg}_wav.tsv").read_text().splitlines()[1:]:
        f = ln.split("\t")
        rows.append((tg, f[0], int(f[1], 0), int(f[2], 0), int(f[3])))
packed = {}
for tg, s in streams.items():
    m = np.zeros(len(s), bool)
    for r in rows:
        if r[0] == tg and r[4] == 16:
            m[r[2] // 2:r[3] // 2] = True
    packed[tg] = np.packbits((s >= 0) & m).tobytes()
queries, hits = 0, []
for tg, lab, a, b, bits in rows:
    if bits != 8:
        continue
    x = streams[tg].view(np.int8)[a:b].astype(np.int16)
    ok = np.abs(x) >= 2
    ch = np.abs(np.diff((x >= 0).astype(np.int8)))
    st = next((i for i in range(16, len(x) - W - 8, 2) if ok[i:i + W + 8].all() and ch[i:i + W + 8].sum() >= 8), None)
    if st is None:
        continue
    queries += 1
    found = None
    for ph in range(8):
        q = np.packbits(x[st + ph:st + ph + W] >= 0).tobytes()
        for tg2, pk in packed.items():
            pos, tries = pk.find(q), 0
            while pos >= 0 and found is None and tries < 20:
                tries += 1
                w0 = pos * 8 - ph - st
                y = streams[tg2][w0:w0 + min(len(x), 512)].astype(float)
                if w0 >= 0 and len(y) > 100 and y.std() > 0:
                    cc = np.corrcoef(x[:len(y)].astype(float), y)[0, 1]
                    if cc > 0.8:
                        found = (tg2, 2 * w0, cc)
                pos = pk.find(q, pos + 1)
            if found:
                break
        if found:
            break
    if found:
        hits.append((tg, lab, found))
        print(tg, lab, found)
print(f"8-bit recordings with a searchable window: {queries}; with a 16-bit copy: {len(hits)}")
