# Resume instructions — build 893 photo transcription

Paused 2026-08-09 at Felipe's request, to pursue a cheaper capture route (video grabber;
see `KN7000/side-quests/pending/kn7000_dump_roms_via_debug_screen_in_video_grabber.txt`).
Nothing here is blocked — it can be picked up cold.

## State

- **37 of 60 photos transcribed**: 9,472 bytes, 17 unknown cells. In `screens.json` /
  `screens.hex`, one entry per photo with the source filename recorded.
- Photos live in `~/compartilhado/KN7000/photos/dump-via-debug/`, named
  `photo_517029803815987NNNN_y.jpg` for NNNN = 0967…1026.
- **Done**: 0967, 0985–0990, 1009–1014, plus the 24 salvaged from the interrupted run
  (see `screens.json` for the exact list).
- **Remaining: 23 photos.** Diff the `photo` fields in `screens.json` against the directory
  listing to get the exact set — do not assume a contiguous range.

## The recipe that works (58 K tokens/photo, vs 330 K for the naive approach)

1. View the photo **once** at full size. The top ~10 rows are usually readable directly.
2. In **one** message, generate **all** band crops you expect to need (4–6 tall bands of
   60–70 px covering the dimmer lower rows) and view them together. Never crop cell by cell.
3. Pixel-level side-by-side against a known glyph **only** for genuinely contested cells.
4. Aim for under 20 tool calls per photo. Batch 3 photos per agent — larger batches blow up
   context, which is the real cost driver (a 1560 px image is only ~350 tokens).

**Geometry**: the shots are slightly off-axis, so text rows slope — a row sits 15–20 px
higher at the right edge than at the left. Measure once, reuse across the set.

**All 16 hex columns are present**; only the ASCII column is cut off, so ASCII is not a
cross-check. The colour legend is (Aqua = F0, Yellow = F7, Lime = FF, Fuchsia = XX) and is.

**The trap**: never infer a byte from a pattern. At 0x48400DF0 byte 13 the surrounding
`EC 01/02/04/10/20` progression suggested `40`; the pixels said `80`, and the pixels were
right.

## Verification

Correlate each screen against the archived images at every shift in ±0x8000:
`kn7000_program.rom` (build 941, CPU base 0x48400000), `kn7000_table.rom` (build 84, base
0x48000000). A screen landing ≥96 % under a single shift is verified. Never rewrite a cell
toward the oracle without photographic support — that manufactures agreement and destroys
the build differences being preserved.

## Next photographs to request (ranked) — see DRIFT-ANALYSIS.md

| # | dial | why |
|---|---|---|
| 1 | **485F1000** | bisects the bracket holding +6,227 of the 6,451 drift bytes (3.19 MB wide) |
| 2 | **4842CF00** | bisects the +201 bracket, 0x48400E00–0x48459000 |
| 3 | **481D9000** | finds the table half's 3-byte insertion, 0x48159100–0x48259000 |
| 4 | 487A1000 | bisects the +25 bracket |
| 5 | 48029000 | re-check: this screen correlates at −1088 with 100 %, contradicting every neighbour |

Each bisection photo halves a bracket; ~12 well-placed shots pin an insertion point that
brute force would need ~16,000 photographs to find.

## Open items

- The 23 untranscribed photos may already collapse some brackets — do them before asking
  for new photography.
- The −2 byte step at 0x487E9000 is either a real deletion or a correlation near-tie; it is
  the least trustworthy row in the drift table.
- No reconstructed 893 image has been produced, and any that ever is must be labelled
  **derived, not a dump**.
