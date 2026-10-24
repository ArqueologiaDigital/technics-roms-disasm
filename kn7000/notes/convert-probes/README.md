# Full-conversion probes (2026-10-24)

The scripts behind the numbers quoted in the commits that converted every
function of code region 1 and of the library image to MN10300 source
(`tools/gen_program_s.py`, `CONVERT_ALL` / `LIB_ALL`). Run each from `kn7000/`.

| script                 | question it answers                                                                                                                                                          | command                                                                                                         |
|------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| `reach.py`             | Is any decoded "code" really data? Reports unreached bytes and every decoded instruction with a sign of data.                                                                | `UNIDASM=/path/unidasm python3 notes/convert-probes/reach.py SCRATCH_DIR`                                       |
| `libconv_analysis.py`  | Which `LIB_CONVERT` entries were real overrides, and which repeated the next symbol-file boundary?                                                                           | `python3 notes/convert-probes/libconv_analysis.py`                                                              |
| `fix_entry_names.py`   | The edit that renamed 21 library names to the movm prologue (the old address became `X_entry`).                                                                              | already applied; kept as the record                                                                             |
| `prune_libconvert.py`  | The edit that cut `LIB_CONVERT` down to its overrides and moved its section comments to `LIB_SECTION_DOC`.                                                                   | already applied; kept as the record                                                                             |
| `prologue_census.py`   | Which labelled call entries sit right after a register-save prologue, is the prologue labelled, does a block header split them, and do the `call` frames match the prologue? | `python3 notes/convert-probes/prologue_census.py`                                                               |
| `entry_rename_map.py`  | Which `func_<ADDR>` names quoted in prose are no longer labels, and what the label at that address is now (writes a sed script).                                             | `python3 notes/convert-probes/entry_rename_map.py FILE... > SED`                                                |
| `seed_layout_probe.py` | Does a `kn7asm --labels` seed lead the passes to the right layout? Traces each pass and finds the first wrong byte.                                                          | `python3 notes/convert-probes/seed_layout_probe.py src/program.s SEED baserom/kn7000_program.rom [GOOD_LABELS]` |

## What they printed

- `reach.py`, after the conversion (the DemoJpgDataL8 tail and the library
  descriptor typed as `DATA_ISLANDS`): 690,776 decoded instructions; 5,867
  unreached runs, 384,363 bytes; **0** decoded instructions with a sign of data.
  The unreached bytes are mostly switch-case bodies: the window procedures
  dispatch through `{key, handler}` tables in the data region (`jmp (a0)`).
  Before the two islands were typed, the same check flagged only
  0x4858599C..0x48586000 (the end of code region 1 is the start of `.rodata`).
  A `?` / `other*` register list / a wild call target is the signal: a 0xFF byte
  is `?`, and data decoded as code tends to produce `ret [a3,other3,other]`-style
  register lists and calls outside both images.
- `libconv_analysis.py`, on the tree before the library conversion (commit
  4a9b620a6): 437 entries; 24 end before the next symbol-file name (kept as
  overrides), 413 end at it (dropped); 9 names existed only in `LIB_CONVERT`
  (moved to `kn7000_manual.sym`). On the current tree it reports the 24
  overrides only.
- `fix_entry_names.py`: 21 names fixed (each checked: CF movm at the new
  address, the old address right after the movm + `add -N, sp`).

- `prologue_census.py`, after the prologue labelling (gen_program_s
  `find_prologues`): 6,276 labels follow a prologue that is not reachable by
  falling through. 6,235 are `X_entry` behind a labelled prologue `X` (5,489 of
  them were `func_<ADDR>` call entries before; `gen_program_s.py` prints that
  count in its summary line);
  30 are symbol-file names on the call entry itself, with the block header
  moved above their unlabelled prologue; 8 library names (`LibSprintf` after
  `sprintf`, ...) keep their own name after a named prologue, header above both.
  No block header sits between a prologue and its entry. Frames: 6,257 entries
  match every direct `call`, 18 have none, 1 does not (`func_4840FF64`: a bare
  `add -8, sp` before it, its callers save `[d2]` in an 8-byte frame), so it is
  left out.
- `seed_layout_probe.py`, with the labels of the build before the relabelling
  as the seed: 6 passes (the restart after the inexact seeded pass), output ==
  reference.

`tools/validate_asm.sh` (committed beside the encoder) gives the encoder
round-trip figures quoted with the encoder changes.
