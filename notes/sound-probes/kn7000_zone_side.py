#!/usr/bin/env python3
"""kn7000_zone_side.py -- which tone generator does a zone's side bit name, and do the zones agree on a tuning?

QUESTION 1: TgVoiceSideSelect (lib 0x4C02BECB) takes a melodic zone's halfword +0 & 0x0C00 as the voice's
  side, 0x400 or 0x800.  Which of the MAIN (IC203/IC204) and SUB (IC207/IC208) tone generators is which?
  Signal: a zone names (page, entry); for the zones whose entry exists in only one TG's directory, count
  the side bit against that TG.  Pass = no zone contradicts.
QUESTION 2: does every parameter record that selects a recording agree on its tuning?  The quantity is
  K = 3072 (E - 9) + corr (E the entry's pitch exponent, corr the 8-byte zone's s16 +6, 0 for 6-byte zones,
  plus (66 - centre) x 256 for the 13 records whose centre key is not 66;
  1/256 semitone units): how many recordings carry one K, and how far apart are the others.
READS kn7000/baserom/kn7000_table.rom and kn7000/baserom/kn7000_wave_{main,sub}.bin through
  kn7000/tools/wave_root_rates.py (git-ignored references; `make -C kn7000` copies them, SHA-1 checked).
RUN  python3 notes/sound-probes/kn7000_zone_side.py
Printed 2026-10-31: side 0x400 -> MAIN only 242, SUB only 0; side 0x800 -> SUB only 416, MAIN only 0;
  recordings reached 2,662, one K 2,632, two or more 30.
"""
import collections
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "kn7000" / "tools"))
import wave_root_rates as W  # noqa: E402

B = ROOT / "kn7000" / "baserom"
c = W.archive(B / "kn7000_table.rom")
D = {"Main": W.stream_dir(B / "kn7000_wave_main.bin", "Main"), "Sub": W.stream_dir(B / "kn7000_wave_sub.bin", "Sub")}
cnt = collections.Counter()
for p in W.params(c):
    for z in p["zones"]:
        k = (z["page"], z["ent"])
        cnt[(z["fb"] & 0x0C, k in D["Main"], k in D["Sub"])] += 1
print("side bit, entry exists in MAIN, in SUB: zones")
for k, v in sorted(cnt.items()):
    print(f"  0x{k[0] << 8:03x}  {str(k[1]):5}  {str(k[2]):5}  {v}")
R, Es = W.refs(B / "kn7000_table.rom", {"Main": B / "kn7000_wave_main.bin", "Sub": B / "kn7000_wave_sub.bin"})
nk = collections.Counter()
spread = []
for lab, rs in R.items():
    ks = sorted({3072 * (e - 9) + corr for _, _, e, corr, _ in rs})
    nk[min(len(ks), 2)] += 1
    if len(ks) > 1:
        spread.append((lab, ks))
print(f"recordings reached through parameter-record zones: {len(R)}; one K: {nk[1]}; two or more: {nk[2]}")
for lab, ks in spread:
    print(f"  {lab}: K - min = {[k - ks[0] for k in ks]}")
