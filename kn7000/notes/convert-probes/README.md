# Full-conversion probes (2026-10-24)

The scripts behind the numbers quoted in the commits that converted every
function of code region 1 and of the library image to MN10300 source
(`tools/gen_program_s.py`, `CONVERT_ALL` / `LIB_ALL`). Run each from `kn7000/`.

| script                | question it answers                                                                                       | command                                                                   |
|-----------------------|-----------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------|
| `reach.py`            | Is any decoded "code" really data? Reports unreached bytes and every decoded instruction with a sign of data. | `UNIDASM=/path/unidasm python3 notes/convert-probes/reach.py SCRATCH_DIR` |
| `libconv_analysis.py` | Which `LIB_CONVERT` entries were real overrides, and which repeated the next symbol-file boundary?        | `python3 notes/convert-probes/libconv_analysis.py`                        |
| `fix_entry_names.py`  | The edit that renamed 21 library names to the movm prologue (the old address became `X_entry`).           | already applied; kept as the record                                       |
| `prune_libconvert.py` | The edit that cut `LIB_CONVERT` down to its overrides and moved its section comments to `LIB_SECTION_DOC`. | already applied; kept as the record                                       |

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

`tools/validate_asm.sh` (committed beside the encoder) gives the encoder
round-trip figures quoted with the encoder changes.
