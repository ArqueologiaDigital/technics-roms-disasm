#!/usr/bin/env python3
"""wave_record_extent.py -- QUESTION: where does each recording end, and what lies between one recording and
the next?  (wave-roms-2026-10-29.md, "Recording boundaries" and "What plays after the loop"; items N-79b9c8d3,
N-cbaf135a)

The directory gives only starts.  The rule tested here: EVERY record word is a run of granules of
L = 2^(K+4) samples -- a value >= 0x80 is (256 - value) granules (the known segments), and a value < 0x80
(the "split list" and the REC_END word's 0) is exactly ONE granule.  So a record's extent is
    with LOOP_END:     the loop end + 32 samples (the run-out, loop_probe.py)
    without LOOP_END:  the sum of the granules of all its words, the REC_END word's included.
Entries are taken in start order; a start that lies inside an earlier recording's extent is an ALTERNATE
START into that recording (two entries, one recording), not a recording of its own.  Main_P00_E0AF (P bit 9,
the reversed entry, wave_reverse_entry.py) is left out.

For each tone generator it prints:
  1. the alternate starts, and whether each ends exactly where its recording ends (and shares its loop);
  2. for every recording, what lies between its extent and the next recording's start (or the page's
     0xFFFF fill): nothing, a run of N zero words, or anything non-zero -- separately for records with and
     without LOOP_END;
  3. recordings whose extent runs past the next recording's start (must be 0);
  4. the last granule of records without LOOP_END: all zero (one-shots) or not, by record shape;
  5. records with LOOP_END but no LOOP_START: whether the run-out after the loop end repeats the
     recording's first 32 samples (then the loop starts at the first sample).
Signal: 0 in 3, and 0 "non-zero" in 2: then the record grammar gives every recording's exact end.

RUN (from anywhere):  python3 -I kn7000/notes/wave-roms-probes/wave_record_extent.py
"""
import collections
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from wavestream import stream, entries, record, granule, segments, PAGE, NPAGES   # noqa: E402


def extent(r, P):
    """(samples covered from the recording's first sample, (loop start, loop end) or None, shape)"""
    L = granule(P)
    ls, le, _ = segments(r, L)
    if le is not None:
        return le + 32, (ls, le), "loop" if ls is not None else "LOOP_END without LOOP_START"
    n = sum((256 - (v & 0xFF)) if v & 0xFF >= 0x80 else 1 for v in r)
    k = sum(1 for v in r if 0 < v & 0xFF < 0x80)
    seg = any(v & 0xFF >= 0x80 for v in r)
    return n * L, None, ("split list" if k else "segments, then REC_END" if seg else "REC_END only")


def main():
    for tg in ("main", "sub"):
        s = stream(tg)
        C = collections.Counter({"3. extent runs past the next recording's start": 0,
                                 "2. any kind: after the extent, NON-ZERO words": 0})
        for p in range(NPAGES):
            base = p * PAGE
            E = []
            for j, (A, P, B, Q) in enumerate(entries(s, p)):
                if P & 0x0200:
                    C["reversed entries left out"] += 1
                    continue
                r = record(s, p, A)[1:]
                m = 2 if P & 8 else 1
                n, lp, shape = extent(r, P)
                st = B * 16
                if lp and lp[0] is None:        # LOOP_END without LOOP_START: does it loop from sample 0?
                    d = s[base + B * 16: base + PAGE]
                    d = d.view(np.uint8) if m == 2 else d
                    C["5. LOOP_END without LOOP_START"] += 1
                    C["5.   ... the 32 samples after its loop end repeat the recording's first 32"] += bool(
                        np.array_equal(d[lp[1]:lp[1] + 32], d[:32]))
                E.append(dict(j=j, st=st, end=st + (n + m - 1) // m, lp=(st + lp[0] // m, st + lp[1] // m) if lp and lp[0] is not None else None,
                              shape=shape, m=m, n=n, L=granule(P)))
            E.sort(key=lambda e: (e["st"], -e["end"]))
            recs = []
            for e in E:
                if recs and recs[-1]["st"] < e["st"] < recs[-1]["end"]:
                    c = recs[-1]
                    C["1. alternate starts (entries)"] += 1
                    C["1.   ... ending where their recording ends"] += e["end"] == c["end"]
                    if e["lp"] and c["lp"]:
                        C["1.   ... with a loop, the same loop as their recording's"] += e["lp"] == c["lp"]
                        C["1.   ... with a loop"] += 1
                    continue
                if recs and recs[-1]["st"] == e["st"]:
                    recs[-1]["end"] = max(recs[-1]["end"], e["end"])
                    recs[-1]["shapes"].add(e["shape"])
                    continue
                e["shapes"] = {e["shape"]}
                recs.append(e)
            t = PAGE
            while t and s[base + t - 1] == 0xFFFF:
                t -= 1
            for i, e in enumerate(recs):
                nxt = recs[i + 1]["st"] if i + 1 < len(recs) else t
                kind = ("with LOOP_END" if "loop" in e["shapes"] else
                        "LOOP_END only" if "LOOP_END without LOOP_START" in e["shapes"] else "without LOOP_END")
                C["2. recordings"] += 1
                if e["end"] > nxt:
                    if i + 1 == len(recs):
                        C["3. last recording of a page: its own last samples are 0xFFFF (fill starts later)"] += 1
                    else:
                        C["3. extent runs past the next recording's start"] += 1
                    continue
                gap = s[base + e["end"]: base + nxt]
                if gap.size == 0:
                    what = "nothing"
                elif gap.any():
                    C["2. any kind: after the extent, NON-ZERO words"] += 1
                    what = "NON-ZERO words"
                else:
                    what = f"{gap.size} zero words"
                C[f"2. {kind}: after the extent, {what}"] += 1
                if kind == "without LOOP_END" and e["n"]:
                    lg = s[base + e["end"] - e["L"] // e["m"]: base + e["end"]]
                    for sh in e["shapes"]:
                        C[f"4. {sh}: last granule all zero" if not lg.any() else f"4. {sh}: last granule not silent"] += 1
        print(f"{tg}:")
        for k in sorted(C):
            print(f"  {k:92s} {C[k]:5d}")


if __name__ == "__main__":
    main()
