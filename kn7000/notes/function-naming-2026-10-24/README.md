# KN7000 program 941: naming the `func_<ADDR>` routines (2026-10-24)

This pass started from 6,620 routines in `src/program/` whose only name was `func_<ADDR>`. It
asked which of them can be given an evidence-based name, and which existing names were
duplicates or wrong. The work went in three steps:

1. Compare the routines with the named ones in the other MN10300 images, by code.
2. Carry the KN7000's names into those images the same way.
3. Name the rest from strings, the call graph and library export names.

| file                    | what it holds                                                                                                 |
|-------------------------|---------------------------------------------------------------------------------------------------------------|
| `count_names.py`        | counts the `func_<ADDR>` labels, and the names this pass added per evidence class (command below)             |
| `renames.tsv`           | every duplicate or misplaced name fixed: old name, new name, evidence                                         |
| `string-evidence.tsv`   | every name given from strings, constants and the call graph, with the evidence per routine                    |
| `../sibling-name-port/` | the names carried by whole-routine match: `accepted.tsv`, `differs.tsv`, `report.md` (with the audit), README |

    python3 kn7000/notes/function-naming-2026-10-24/count_names.py --rev 79e035417

## What moved

`func_<ADDR>` routine labels in `kn7000/src/program/*.s`: **6,620 -> 6,496**. The figures
come from `count_names.py --rev 79e035417`, the commit this work started from. `python3
scripts/analysis/doc_quality_census.py` row (e) for `program` (placeholder routine names)
went from 6,624 to 6,500. The 124 are:

| evidence                                                                        | names | where                               |
|---------------------------------------------------------------------------------|-------|-------------------------------------|
| same code as a routine IC18 names (exact 30, fuzzy 2)                           | 32    | `../sibling-name-port/accepted.tsv` |
| same code as a sibling's reflection-table name (exact 10, skeleton 1, fuzzy 4)  | 15    | `../sibling-name-port/accepted.tsv` |
| zlib 1.0.4: strings, constants, call graph                                      | 63    | `string-evidence.tsv`               |
| an error text that names the routine, and its helper                            | 2     | `string-evidence.tsv`               |
| the signature, file-name or pattern text a routine compares, writes or searches | 5     | `string-evidence.tsv`               |
| library names moved from the flash copy to the library address                  | 2     | `renames.tsv`                       |
| a name moved from a routine's register-save entry to its start                  | 1     | `renames.tsv`                       |
| `kn7000_manual.sym` names the committed source was older than                   | 4     | below (regenerated, no new name)    |

The four older names were added to `kn7000_manual.sym` by 39dc53359 (the table-ROM segment
loaders), but the committed `src/program/` had not been regenerated since:
`MemPadAreaLoadFactory` (0x48432175), `TechnicsPadsResourceParse` (0x48433F4A),
`TechnicsPadsResourceInit` (0x484342B4) and `SramRecordsLoadFactory` (0x4843FB65).

The pass also fixed 13 duplicate or misplaced names; `renames.tsv` lists them:

- Seven `Lib*` names sat on a library routine's register-save entry. They are now
  `<export>_entry`, as everywhere else in the tree (`sprintf_entry`, `dly_tsk_entry`, ...).
- Five rows named library routines through the flash copy of the library image. Three of
  them duplicated a name the routine already had and were dropped; the other two became
  `memset_entry` and `GetM3Em_entry` rows at the library address.
- `ter_tsk` had been ported from build 942 onto build 941's `get_tid`.
  `tools/itron_stubs.py` now checks every exported service by its body.

`tools/gen_xap_s.py` now also matches a firmware routine's body from its register-save entry.
As a result BASEEXT.XAP names 11 routines as firmware copies, up from 7 (`strncmp`, `memcpy`,
`memset`, `strcpy`, `LibF64NegTo` among them), and the converters keep `strncmp`.

## The wall: what the other images cannot give

The siblings' MILK reflection tables name almost the same routines as the KN7000's own
tables. Of KN2400's 2,280 names, the KN7000 already has 2,041; KN6000 and KN6500 overlap in
the same way (`../sibling-name-port/report.md`). The KN7000's 6,500 or so remaining
`func_<ADDR>` routines are static C functions: compiler helpers, case bodies and screen
procedures that the firmware never registers by name. No image in this tree names them.
Matching by code cannot name them either. Naming them means reading the code, as was done
for zlib here, and that is per-routine work:

- **The fmm and FAT layer around 0x4852xxxx-0x4853xxxx.** Its strings (`*.MID`, `*.CST`,
  `MUSIC.DIR`, `C:\SD_SOUND`) and the named `fmm*` entries make it the next-best target.
- **The `NO EDIT` / `%3d` parameter formatters at 0x48412D06..** These are `SndRecCountGet`
  callers.
- **The three routines in front of zlib** (0x484737D2, 0x48473A86, 0x48473AA8). They are
  application code tied to the routine at 0x48472B31 (it calls two of them, the third calls
  it), not part of the library.

## How the whole-routine match was checked

The audit table in `../sibling-name-port/report.md` reruns the matching rules on names both
images already give, and counts how often the rules land on the routine the KN7000 gives that
name. Results:

- **KN6000 and KN6500:** every pick right (1,146 picks in all).
- **IC18:** every pick right (10 picks).
- **KN2400:** 984 right and 19 wrong. The 19 are all in the SD-card screens, where the two
  routines are the same code under different names. That is a disagreement between the two
  images' reflection-table pairings, not between bodies (README there).

## Reverse direction (KN7000 names into the siblings)

The siblings' `ported-names` targets now pass `--fuzzy` to `tools/port_names_by_code.py`.
After its first-return signature match, the tool runs the same whole-routine rules on what is
left. The exact pass also picks up the names the KN7000 gained. Each `*_ported.sym` header
gives its own counts, and each row says which pass carried it: "whole body" rows give the
class and the two ratios. The `func_` counts come from each tree's
`notes/conversion-stats.txt`, which `make program-src` writes:

| tree   | ported names | of them whole body | `func_` entries left |
|--------|--------------|--------------------|----------------------|
| kn2400 | 485 -> 679   | 80                 | 12,359 -> 11,993     |
| kn6000 | 546 -> 715   | 76                 | 10,789 -> 10,501     |
| kn6500 | 552 -> 722   | 76                 | 10,816 -> 10,526     |
| hdsx3  | 29 -> 52     | 0                  | 842 -> 799           |

A second `make -C kn6000 ported-names` run reproduced its file byte for byte.
