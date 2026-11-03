#!/usr/bin/env python3
"""wave_runout_halves.py -- QUESTION: where do the run-outs that are NOT a copy of their loop's first 32
samples come from?  (wave-roms-2026-10-29.md, "Recording lines"; lane wav-merge, 2026-11-03)

After an explicit loop's end the stream holds a 32-sample run-out, and in all but 9 recordings (MAIN 6, SUB 3)
it repeats the loop's first 32 samples (loop_probe.py).  Since 2026-11-03 the WAV files end at the loop end,
so the source can no longer read those 9 from their WAVs; this probe finds what they are.

Run-outs are compared as stream WORDS: r = 32 words for a 16-bit recording, 16 for an 8-bit one (two samples
per word); h = r / 2.  For each recording with LOOP_START and LOOP_END (alternate starts merged into their
recording as in wave_record_extent.py; the reversed entry Main_P00_E0AF left out) it classifies the run-out:
  exact       words [le, le + r) == words [ls, ls + r)
  halves      words [le, le + h) == [ls, ls + h), and words [le + h, le + r) == words [ls' + h, ls' + r) of the
              loop start ls' of an EARLIER recording of the same page (the DONOR; the nearest one is reported,
              and how many earlier recordings would do)
  other       neither
and prints, for each non-exact one, the donor, the donor's format, the number of loop recordings between the
two, and how often the second half's 16 words occur anywhere in the page.
Signal: other = 0.  Then every run-out is spelled from loop starts alone (kn7000/tools/gen_wave_s.py does so).

RUN (from anywhere):  python3 -I kn7000/notes/wave-roms-probes/wave_runout_halves.py
Chip images: $KN7000_WAVE_DIR (wavestream.py), private, read-only; prints numbers and labels only.
"""
import collections
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from wavestream import stream, entries, record, PAGE, NPAGES   # noqa: E402
from wave_record_extent import extent                          # noqa: E402


def recordings(s, p):
    """[{st, end, lp (ls, le) in words from the page or None, m, lab}] in start order, alternate starts merged"""
    E = []
    for j, (A, P, B, Q) in enumerate(entries(s, p)):
        if P & 0x0200:
            continue
        m = 2 if P & 8 else 1
        n, lp, _ = extent(record(s, p, A)[1:], P)
        st = B * 16
        if lp is not None:
            lp = ((lp[0] if lp[0] is not None else 0) // m + st, lp[1] // m + st)
        E.append(dict(j=j, st=st, end=st + (n + m - 1) // m, lp=lp, m=m))
    E.sort(key=lambda e: (e["st"], -e["end"]))
    recs = []
    for e in E:
        if recs and recs[-1]["st"] <= e["st"] < recs[-1]["end"]:
            c = recs[-1]
            c["end"] = max(c["end"], e["end"])
            c["lp"] = c["lp"] or e["lp"]
            continue
        e["lab"] = f"P{p:02X}_W{e['j']:03X}"
        recs.append(e)
    return recs


def main():
    for tg in ("main", "sub"):
        s = stream(tg)
        C = collections.Counter()
        rows = []
        for p in range(NPAGES):
            base = p * PAGE
            page = s[base: base + PAGE]
            recs = recordings(s, p)
            for i, e in enumerate(recs):
                if not e["lp"]:
                    continue
                ls, le = e["lp"]
                r = 32 // e["m"]
                h = r // 2
                ro = page[le: le + r]
                C["run-outs"] += 1
                if np.array_equal(ro, page[ls: ls + r]):
                    C["exact"] += 1
                    continue
                if not np.array_equal(ro[:h], page[ls: ls + h]):
                    C["OTHER (first half is not the loop's)"] += 1
                    rows.append((e["lab"], "-", "-", "-", "-"))
                    continue
                donors = [d for d in recs[:i] if d["lp"] and d["lp"][0] + r <= d["lp"][1]
                          and np.array_equal(page[d["lp"][0] + h: d["lp"][0] + r], ro[h:])]
                if not donors:
                    C["OTHER (second half from no earlier loop start)"] += 1
                    rows.append((e["lab"], "-", "-", "-", "-"))
                    continue
                C["halves"] += 1
                d = donors[-1]
                between = sum(1 for x in recs[recs.index(d) + 1: i] if x["lp"])
                win = np.lib.stride_tricks.sliding_window_view(page, h)
                hits = int((win == ro[h:]).all(1).sum())
                rows.append((f"{e['lab']} ({'16' if e['m'] == 1 else '8'}-bit)", d["lab"],
                             "16-bit" if d["m"] == 1 else "8-bit", str(between), str(hits)))
        print(f"{tg}:")
        for k in ("run-outs", "exact", "halves", "OTHER (first half is not the loop's)",
                  "OTHER (second half from no earlier loop start)"):
            print(f"  {k:50s} {C[k]:5d}")
        if rows:
            print("  run-out               donor (nearest)  donor format  loop recordings between  "
                  "second half found in the page")
            for row in rows:
                print(f"  {row[0]:21s} {row[1]:16s} {row[2]:13s} {row[3]:24s} {row[4]}")


if __name__ == "__main__":
    main()
