# Probes of sub-lane `engine` (lane kn5000-b, 2026-10-31)

Run from the repository root.  Both read committed files only.

| script                 | question it answers                                                                                                                                   | command                                                                   |
|------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------|
| `chord_table_check.py` | Is ChordRecog_IntervalMaskTable {chord type, root offset} indexed by the interval mask of Voice_ComputeNoteBitPosition?  What are the 41 chord types? | `python3 notes/open4-kn5000-b/engine/probes/chord_table_check.py --types` |
| `sqt_event_census.py`  | Which song events occur on the KN5000 disks, with which data lengths and byte ranges?                                                                 | `python3 notes/open4-kn5000-b/engine/probes/sqt_event_census.py`          |

## What `chord_table_check.py` reads and what passing means

- `original_ROMs/kn5000_v10_program.rom` (committed): the mask table at 0xEEAE44 (2,048 x 2 bytes), the
  class table at 0xEEBE44 (512 bytes), `Chord_Tables` at 0xFEA349 (note counts at +0x91, interval rows at
  +0xBA).  v9 links the same addresses; v7 needs `--chord-tables 0xfe9b7a`.
- For each non-zero mask entry it compares the held pitch-class set ({0} and 11 - k for each set bit k) with
  the chord type's set ({root} and the row's intervals, moved up by the offset).
- Measured 2026-10-31: 292 entries; 93 exact, 34 chord-subset-of-held, 44 held-subset-of-chord, 18 mismatch
  (all 18 with bit 7 of the offset byte set), 103 of types 31-39 (no voicing row).  No entry with bit 7
  clear mismatches.  That is the evidence for the field meanings now written above the table in
  `ui_widgets/widget_dispatch.s`.

## What `sqt_event_census.py` reads

`floppy/kn5000/*/files/*.SQT.s` (72 typed song files of the KN5000 disk sets).  Measured 2026-10-31:
0x81 65,349; 0x90 36,802; 0xD2 3,809; 0xD1 2,170; 0xB0 565; 0x86 235; 0x82 183; 0xB4 154; 0xC1 130;
0xD3 115; 0xC0 90; 0x85 66; 0xB2 43; 0x80 42; 0xB3 29; 0xB1 19; a few others once or twice.  Byte 1 (the
tick) is 0..95 for every status that has data.
