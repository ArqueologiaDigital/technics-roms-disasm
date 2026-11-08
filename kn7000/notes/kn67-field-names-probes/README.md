# kn67-field-names probes

Probes behind the field names of the KN7000 / KN6000 panel-memory, one-touch, song and sound-record
macros (`kn7000/src/include/panel_memory.inc`, `voice_record.inc`, `floppy/tools/kn_song.inc`). The lane
notes are `notes/data-semantics-2026-10-29/kn67-field-names.md`. Every script reads only the git-ignored
reference images and prints to stdout.

| script              | question it answers                                                                                                                 | command                                                                                                              |
|---------------------|-------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|
| `m3em_param_map.py` | which byte of the live panel record (block = record tag, offset, mask, shift) each parameter id reads and writes, with its range    | `python3 -I m3em_param_map.py kn7000/baserom/kn7000_program.rom --table` (add `--model kn6000` and the KN6000 image) |
| `m3em_callers.py`   | which named routine (GUI proc, FN_ handler, MIDI path) gets or sets a parameter id with a literal, so a field can be named after it | `python3 -I m3em_callers.py kn7000/src/program [ID_HEX ...]`                                                         |

## What the signals mean

- `m3em_param_map.py` walks `ResourceIdTrie` (KN7000 0x4858B424; KN6000 0x4C1935DC), the nibble trie
  library `func_4C01BB1A` walks for `GetM3Em` / `PutM3Em`. A leaf is a record `{u32 id, u16 type, u16 kind,
  u16 min, u16 max, u8 block, u8 offset, u8 mask, u8 shift}`. For type 0, `M3GetByKind` dispatches on
  `kind` (table 0x4858C254) and reads the byte through `M3BlockFieldRead(block, offset, mask)`; the block is
  record +0x0C, or the id's top byte when the id is part-indexed (`func_4C01BC28`). `--blocks` prints the
  block pointer table (KN7000 0x4858D44C, read by `M3BlockPtrGet`; KN6000 0x4C195520): block n is the
  payload of the panel record's tag n (0x84000020 + ...), except blocks 0x13-0x1A (ACCOMP1-5, BASS,
  DRUMS1, DRUMS2), which are work RAM 0x500D28C2 + i*0x4A (KN6000 0x5024F686 + i*0x4A).
- The KN6000 addresses were found by matching the bytes of the KN7000 routines `func_4C01BB1A` and
  `M3BlockPtrGet` in `kn6000/baserom/kn6000_program.rom` (walker at 0x4C02CA6A, block-table reader at
  0x4C031C94).
- Counts measured 2026-10-29: KN7000 469 records (314 of type 0), KN6000 307 of type 0. The two type-0
  maps agree on every part-record field except the KN7000-only ones (scale bits 0x2000B0-BF at part
  +0x38/+0x39, tremulant 0x2000A2 at +0x23, APC reverb 0x00E030-3F at tag 0x44 +0x0C..+0x13) and a few
  ranges (`diff` of the two `--table` outputs).
- `m3em_callers.py` counts a call when one of the 8 lines before it loads d0 with an immediate; the id is
  that immediate & 0xFFFFFF. Measured: 1,303 calls, 213 distinct ids. Ids built at run time (for example
  the MIDI control grid's) are not seen.
