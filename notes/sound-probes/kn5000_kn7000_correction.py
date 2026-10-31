#!/usr/bin/env python3
"""kn5000_kn7000_correction.py -- does the KN5000 tune an IC307 recording the way the KN7000 tunes the same one?

QUESTION: the KN5000's multisample SET zone records (table data, 6-byte form: selector, key word, s16 C;
  read by WaveSel_StageB_Build_Reg040 and the pitch path, v142 sub-CPU) carry a pitch correction C in the
  same 1/256-semitone unit as the KN7000 8-byte zone's s16 at +6 (TgPitchNoteResolve, lib 0x4C02FB79).
  For an IC307 wave whose audio is a KN7000 recording (waveform/wav_manifest.tsv, evidence `kn7000 <label>`),
  is C (KN5000, for the selector that plays that wave) equal to corr (KN7000, the modal correction of the
  zones that play that recording)?  If the two instruments add the same correction to the same recording,
  they read it at the same rate for the same key (given the same pitch law and pitch exponent E), so the
  KN7000's derived rate also holds for the KN5000.
SIGNAL: D = C - corr per selector (classes 4-7 = IC307 pages 0-3, the selector's top nibble; 4-byte SET zone
  records have no C and count as C = 0).  Pass = D = 0 for most; the others listed.
READS original_ROMs/kn5000_table_data.rom (tracked), waveform/ic307_page*.s and waveform/wav_manifest.tsv
  (tracked), the KN7000 references through kn7000/tools/wave_root_rates.py.
RUN  python3 notes/sound-probes/kn5000_kn7000_correction.py
Printed 2026-10-31: 390 selectors compared, D = 0 for 355.  Of the 35 others, 33 are page 1 (class 5: the
  drum kit, the selectors 0x5024-0x508e) or page 0's 0x409a / 0x40a1, mostly 4-byte SET records (no C) where
  the KN7000 zone carries a correction (2756 in 14 of them); drums play at a fixed pitch, so their C does not
  set a key's rate the way a melodic zone's does.
"""
import collections
import re
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "kn7000" / "tools"))
sys.path.insert(0, str(ROOT / "notes" / "waveform-ic307-2026-10-29" / "probes"))
import wave_root_rates as W  # noqa: E402
import tonedb_selector_users as T  # noqa: E402

B = ROOT / "kn7000" / "baserom"
R, Es = W.refs(B / "kn7000_table.rom", {"Main": B / "kn7000_wave_main.bin", "Sub": B / "kn7000_wave_sub.bin"})
corr7 = {}
for lab, rs in R.items():
    w = collections.Counter()
    for _, _, e, corr, keys in rs:
        w[corr] += max(len(keys), 1)
    corr7[lab] = w.most_common(1)[0][0]

k5to7 = {}
for ln in (ROOT / "waveform/wav_manifest.tsv").read_text().splitlines()[1:]:
    f = ln.split("\t")
    m = re.search(r"\(kn7000 (\w+)\)", f[8])
    if m:
        k5to7[f[0]] = m.group(1)
sel2lab = {}
for pg in range(4):
    txt = (ROOT / f"waveform/ic307_page{pg}.s").read_bytes().decode("latin-1")
    for m in re.finditer(r"WaveDirEntry\t\S+, \S+, (\w+)\t; \d+, selector 0x([0-9a-f]+)", txt):
        sel2lab[int(m.group(2), 16)] = m.group(1)

t = T.ToneDB()
sets = t.slot(0x30)
desc = [(t.u8(sets + 15 * i), t.u32(sets + 15 * i + 1), t.u32(sets + 15 * i + 5)) for i in range(487)]
offs = sorted({a for _, a, _ in desc} | {b for _, _, b in desc})
end = 0x863079 - T.DB
nxt = {o: (offs[k + 1] if k + 1 < len(offs) else end) for k, o in enumerate(offs)}
C5 = collections.defaultdict(collections.Counter)
form = {}
for fl, a, b in desc:
    st = 6 if fl & 0x80 else 4
    for z in range((nxt[b] - b) // st):
        s = t.u16(T.DB + b + st * z)
        C = struct.unpack_from("<h", t.r, T.DB + b + st * z + 4 - T.B)[0] if st == 6 else 0
        C5[s][C] += 1
        form.setdefault(s, set()).add(st)
d = collections.Counter()
odd = []
for s, cc in sorted(C5.items()):
    if s >> 12 < 4 or s not in sel2lab:
        continue
    k7 = k5to7.get(sel2lab[s])
    if k7 not in corr7:
        continue
    c5 = cc.most_common(1)[0][0]
    d[c5 - corr7[k7]] += 1
    if c5 != corr7[k7]:
        odd.append((s, sel2lab[s], k7, c5, corr7[k7], sorted(form[s])))
print(f"selectors compared: {sum(d.values())}; D = C - corr: {d.most_common()}")
for s, l5, l7, c5, c7, fm in odd:
    print(f"  0x{s:04x} {l5:32} {l7:16} C {c5:6} corr {c7:6} record form {fm}")
