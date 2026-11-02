#!/usr/bin/env python3
"""wave_split_list.py -- QUESTION: what is a record's "split list" (the parameter words with a value below 0x80,
descending multiples of 8)?  (wave-roms-2026-10-29.md, "The split list"; item N-a0f81837)

The firmware never reads these words (no CPU reads the wave ROMs but the service checksum,
notes/wave-rom-port.md), so only the data and the tone database can say what they belong to.  It prints:
  1. the shape of the lists: how many descend by exactly 8 per word, and what they end on;
  2. what each word covers: wave_record_extent.py shows that each of them is one granule of the recording,
     after the segments; here, how alike neighbouring split granules are (correlation of their samples)
     and whether their spectral centroid falls along the list;
  3. how the list depends on the key: for every pair of entries that play the SAME recording with the same
     segments but different split lists, whether one list is the other plus a constant, and how that
     constant relates to the difference of the keys their zones cover (tools/wave_root_rates.py:
     key map -> zone -> (page, entry); mean of each entry's keys).
Signal: in 3, the shift has the sign of the key difference in every pair and grows by about 8 per 12 keys:
the values are in steps of 1/8 octave of playback pitch.

RUN (from kn7000/, after `make` has made baserom/kn7000_table.rom):
    python3 -I notes/wave-roms-probes/wave_split_list.py
"""
import collections
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
K = os.path.normpath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(K, "tools"))
from wavestream import stream, entries, record, granule, PAGE, NPAGES   # noqa: E402
import wave_root_rates as W                                            # noqa: E402

TGN = {"main": "Main", "sub": "Sub"}


def centroid(g):
    X = np.abs(np.fft.rfft(g - g.mean())) ** 2
    return float((X * np.arange(X.size)).sum() / (X.sum() + 1e-9))


def main():
    keys = collections.defaultdict(list)       # (TG, page, entry) -> keys of the zones that select it
    for pr in W.params(W.archive(os.path.join(K, "baserom/kn7000_table.rom"))):
        zk = W.zone_keys(pr)
        for zi, z in enumerate(pr["zones"]):
            keys[(W.side_tg(z["fb"]), z["page"], z["ent"])] += zk.get(zi, [])
    shape, gran, shift = collections.Counter(), collections.Counter(), collections.Counter()
    cors, per = [], collections.defaultdict(list)
    for tg in ("main", "sub"):
        s = stream(tg)
        for p in range(NPAGES):
            base = p * PAGE
            byB = collections.defaultdict(list)
            for j, (A, P, B, Q) in enumerate(entries(s, p)):
                r = record(s, p, A)[1:]
                ks = [v & 0xFF for v in r if 0 < v & 0xFF < 0x80]
                if not ks or P & 0x0200:
                    continue
                shape["records with a split list"] += 1
                shape["... descending by 8 per word" if all(a - b == 8 for a, b in zip(ks, ks[1:])) else "... not"] += 1
                shape[f"... last value {ks[-1]}"] += 1
                segs = [v & 0xFF for v in r if v & 0xFF >= 0x80]
                byB[B].append((j, ks, segs, keys.get((TGN[tg], p, j), [])))
                # 2: the split granules
                m, L = (2 if P & 8 else 1), granule(P)
                n0 = sum(256 - v for v in segs)
                low = [v for v in r if v & 0xFF < 0x80]
                d = s[base + B * 16: base + PAGE]
                d = (d.view(np.int8) if m == 2 else d.view(np.int16)).astype(float)
                G = [d[(n0 + i) * L:(n0 + i + 1) * L] for i in range(len(low))]
                if len(G) >= 3 and all(g.any() for g in G):
                    gran["records, all split granules non-silent"] += 1
                    cors += [float(np.corrcoef(a, b)[0, 1]) for a, b in zip(G, G[1:])]
                    c = [centroid(g) for g in G]
                    gran["... centroid never rises along the list"] += all(b <= a + 1e-9 for a, b in zip(c, c[1:]))
            for B, L_ in byB.items():
                for a in range(len(L_)):
                    for b in range(a + 1, len(L_)):
                        (j1, k1, s1, K1), (j2, k2, s2, K2) = L_[a], L_[b]
                        if k1 == k2:
                            continue
                        if s1 != s2 or len(k1) != len(k2):
                            shift["pairs: segments or list length differ"] += 1
                            continue
                        d = {y - x for x, y in zip(k1, k2)}
                        if len(d) != 1:
                            shift["pairs: not a constant shift"] += 1
                            continue
                        if not K1 or not K2:
                            shift["pairs: constant shift, one entry selected by no key"] += 1
                            continue
                        sh, dk = d.pop(), float(np.mean(K2) - np.mean(K1))
                        if sh < 0:
                            sh, dk = -sh, -dk
                        shift["pairs: constant shift"] += 1
                        shift["... the higher list belongs to the higher keys"] += dk > 0
                        per[sh].append(dk)
    print("1.", ", ".join(f"{k} {v}" for k, v in sorted(shape.items())))
    print("2.", ", ".join(f"{k} {v}" for k, v in sorted(gran.items())),
          f"; correlation of neighbouring split granules: median {np.median(cors):.3f}, 10th percentile"
          f" {np.percentile(cors, 10):.3f} ({len(cors)} pairs)")
    print("3.", ", ".join(f"{k} {v}" for k, v in sorted(shift.items())))
    for sh in sorted(per):
        print(f"   shift {sh:3d}: {len(per[sh]):4d} pairs, mean key difference {np.mean(per[sh]):6.1f}"
              f" ({8 * np.mean(per[sh]) / 12:5.1f} = 8 x octaves)")


if __name__ == "__main__":
    main()
