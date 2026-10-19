# KN7000 build 893 / table build 80 — photographic transcription (PARTIAL)

**This is NOT a chip dump.** It is a transcription of photographs of the KN7000's own
built-in MEMORY DUMP hex viewer, taken by the instrument's owner on 2026-08-09 from a
machine running **PROGRAM build 893 / TABLE build 80** — a firmware pair that exists
nowhere else. Never present it as a dump and never load it as one.

## What is here

- `screens.json` — 12 screens, 16 rows × 16 bytes each, as transcribed, with the source
  photo recorded per screen. Unknown cells are `"??"`.
- `screens.hex` — the same, address-ordered, human-auditable.

**9,472 bytes, 17 unknown cells** (37 of the 60 screens). Two transcription runs were cut
short -- one by a usage limit, one interrupted deliberately -- and these are what completed.

Coverage: table half at 0x48039000, 0x48049000, 0x48059000, 0x48159000, 0x48259000,
0x48359000; program half at 0x48400D00 and 0x487F4400–0x487F49FF.

**The insertion point is bounded.** The 0x48400D00 screen agrees with build 941 at shift **0**
(98.4 %, 252/256), while every 0x487F44xx–49xx screen needs **+0x1933**. So the ~6,451-byte
block that build 941 has and build 893 lacks sits somewhere in
**0x48400E00 – 0x487F4400**.

⚠ **The single-shift model below is SUPERSEDED by DRIFT-ANALYSIS.md**, which shows the
drift accumulates in at least four steps (0 -> +201 -> +6428 -> +6453 -> +6451) rather than
being one block. The correlation evidence and the verification argument still hold.

## ★ The original finding (12 screens): build 893 is build 941 minus ~6.4 KB

Every screen was correlated against our archived images (`kn7000_program.rom` build 941,
`kn7000_table.rom` build 84) at every shift in ±0x4000. Each landed on a single
consistent offset:

| screens | shift | agreement |
|---|---|---|
| 0x48039000, 0x48049000, 0x48159000 (table) | 0 | **100.0 %** |
| 0x48059000 (table) | 0 | 99.2 % |
| 0x48259000, 0x48359000 (table) | **+3** | 99.6 %, 100 % |
| all six program screens 0x487F44xx–0x487F49xx | **+0x1933 (6,451)** | 96.8 – 100 % |

`0x1933` is exactly the distance by which our build-941 code outruns the owner's: his last
non-FF byte is at 0x487F55CE, ours at 0x487F6F00.

**Interpretation.** Build 941 = build 893 with a ~6,451-byte block inserted somewhere below
0x487F4400. Above the insertion point the two builds are the same code, displaced. The
residual 2–4 % of mismatches are consistent with **relocated absolute pointer constants** —
exactly the bytes that must change when code moves.

The table halves differ similarly but far less: identical up to somewhere between
0x48159000 and 0x48259000, then displaced by **3 bytes**.

## Why this doubles as verification

Six independent screens agreeing 96.8–100 % under one shift cannot arise from chance or
from OCR error. The apparent "2 % agreement" of the program screens in a naive same-address
comparison was an artefact of comparing at the wrong offset, not a transcription problem.
The readers were accurate.

## What it implies for archiving 893

Photographing 4 MB at 256 bytes per screen is ~16,000 photographs. If 893 is 941 minus one
block with pointers relocated, most of it is **reconstructible**, and the photography needed
collapses to: locate the insertion point, then verify a sample. That has not been done yet
and this file does not claim it — it states the hypothesis and the evidence for it.

## Method and caveats

- Readers were instructed never to guess: `??` for any cell destroyed by glare or blur, and
  no inference from context or from our other ROM.
- All 16 hex byte columns are present in these photos; only the ASCII column is cut off at
  the right edge, so ASCII was **not** available as a cross-check.
- The screen's colour legend (Aqua = F0, Yellow = F7, Lime = FF, Fuchsia = XX) encodes those
  values a second time and was used to confirm marginal cells.
- The correlation above is the only verification these 12 screens have received; the
  planned independent structural verifier never ran.
