# v7 catch-up (wave 2, lane v7-harmonize, audit WP07)

Work package WP07 of `notes/repo-audit-2026-10-24/` brings `v7/maincpu` closer to `v10/maincpu`:
v10's names on the routines v7 shares with it, re-framed `.byte` code, the last verbatim bytes, and
v10's headers on the newly matching routines.  This folder holds the evidence for the names.

## Names: `scripts/renaming/harmonize_by_caller_alignment.py`

`scripts/renaming/harmonize_version_labels.py` pairs a v10 label with a v7 address only between two
shared labels whose v10->v7 deltas are equal.  Where v7's code moved non-uniformly it finds nothing
(on this tree's state it reported 0 renames).  The new tool lines up the code that uses a routine:
it walks the two disassemblies in parallel from every label the two trees share and trust, pairs the
ROM operands of aligned instructions (call / jump / pointer targets, relative branch targets), and
proposes v10's name for the v7 address it pairs with.  Every proposal must pass a body-equivalence
proof over the v10 routine's extent: equal instructions, every differing number explained by the
measured RAM map (`analysis/header-propagation/v7-ram-shift-2026-10-24.txt`) or by a pointer that
is checked against a trusted label or the pair map and not contradicted.  Data spans (pointer
tables, records) are proved by bytes instead, with the same checks.  The tool's docstring gives the
rules in full.

A *trusted* name is one defined in both trees that marks the same place: a non-structural name, or
a structural one (`X_Skip3`) that hangs off the same parent X in both trees.  Structural names were
numbered per tree, so `X_Skip3` in v7 was often v10's `X_Skip5`.  Swaps and chains (v7's `X_Skip3`
must become `X_Skip5` while its `X_Skip5` becomes `X_Skip7`) are applied in one run, through
temporary names.

| question                                                  | command                                                                                          |
|-----------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| What would be renamed / inserted, and what is refused?    | `python3 scripts/renaming/harmonize_by_caller_alignment.py --to v7 --cache DIR --report OUT.tsv` |
| Apply (then `make all` and run again until `rename` is 0) | the same with `--apply`                                                                          |
| How many v7 labels are v10 names?                         | `python3 scripts/analysis/version_shared_names.py [--rev REV]`                                   |
| How many review-list names does v7 define now?            | `python3 scripts/analysis/v7_review_names_resolved.py [--list]`                                  |
| Is v10 routine X the same code as v7 routine Y?           | `python3 scripts/analysis/v7_routine_equivalence.py X=Y=NBYTES`                                  |

`DIR` is a scratch directory for the two `llvm-objdump` listings (about a minute each to make).

### Measured 2026-10-24

The tool was applied 19 times, rebuilding v7 between runs, until a run proposed nothing.  Its rename
rules are recorded in `scripts/renaming/harmonize_v7_by_caller_alignment.sed` (1,814 `s///` lines,
of which 48 are the two halves of 24 swaps through a temporary name).  One swap was made by hand:
`scripts/renaming/rename_v7_perfmode_note_map_swap.sed` (v7 had `PerfMode_MapEventNoteToDisplay` on
the inverse routine; `v7_routine_equivalence.py` shows both routines equal to v10's under the
swapped names, 36 bytes each).

| measure                                                   | before (79e035417) | after  | command                          |
|-----------------------------------------------------------|--------------------|--------|----------------------------------|
| v7 labels (linked ELF)                                    | 53,559             | 53,693 | `version_shared_names.py`        |
| v7 labels that are also v10 names                         | 51,374             | 52,845 | `version_shared_names.py`        |
| v7 labels that are not v10 names                          | 2,185              | 848    | `version_shared_names.py`        |
| v7 `.Lc_<addr>` locals                                    | 638                | 507    | `doc_quality_census.py`, row (c) |
| review `label-absent` labels v7 defines                   | 0 of 356           | 219    | `v7_review_names_resolved.py`    |
| review `names-absent-symbol` names v7 defines             | 0 of 138           | 78     | `v7_review_names_resolved.py`    |
| review `names-absent-symbol` rows with every name defined | 0 of 189           | 107    | `v7_review_names_resolved.py`    |

The label count grew because `.Lc_` assembler-local labels renamed to v10 names became symbols, and
one label (`CmpStep_DrawScreen`) was inserted.

### What the final run refused: `caller-alignment-v7-final.tsv`

The output of the last (dry) run.  One row per paired v10 label that v7 does not define at that
address.

| result                                 | rows | meaning, and what to do                                                                                                  |
|----------------------------------------|------|--------------------------------------------------------------------------------------------------------------------------|
| `parent-differs`                       | 176  | v10's structural name hangs off a parent v7 places differently; resolve the parents first                                |
| `v10-name-misparented`                 | 142  | v10's structural name carries another routine's stem while v7's is right: a re-parenting rename belongs in v10           |
| `v10-name-defined-elsewhere-in-target` | 132  | v10's name is on another v7 label that is not renamed away; a person must look at both places                            |
| `insert-mid-line`                      | 23   | v7 has no source line starting there (a `.byte` run or a misframed instruction): re-frame first                          |
| `proof-failed`                         | 22   | the bodies differ (a changed immediate, different code), or a pointer contradicts a trusted label                        |
| `both-named`                           | 2    | v7's name is not a placeholder.  `MasterSetup_HandleDialStop/Turn` (v10) are v7's `AcMstStyleAlp_Boundary_OnHide/OnSwIn` |
| `old-name-is-a-v10-name-elsewhere`     | 1    | `Display_BytecodeBlock_F_Tbl2` in v7 is v10's `_Tbl3`, and v10 has another `_Tbl2`                                       |

The two `both-named` rows are a v10 naming defect: the dispatcher sends `EVT_HIDE` to
`MasterSetup_HandleDialStop` and `EVT_SW_IN` to `MasterSetup_HandleDialTurn`
(`v10/maincpu/ui/ui_mode_handlers.s`), so v7's `_OnHide` / `_OnSwIn` say what the code does.  v10 is
outside this lane; the rename should be made there and carried to v9/v7.  Eight other `both-named`
rows were read and renamed to v10's name with `--rename-named --only ...`: three
`RhythmPart{3,4,5}_ProcessAccentData` (v7 `AccVoice_LoadRhythmParams_Part{3,4,5}`, whose
`RhythmPart3_LoadAndStore` join already had v10's stem), `AccPatch_CountAvailableSlotsInAltImage`,
`AppEvent_InlineHandler_DecLastMeasure_OnTitleSqnotecng` (v7 `AppEvent_SubDispatch_Code_2`),
`VoiceParam_ModeDispatch_Table`, `MidiStream_PanelEventHandlerTable`, and the
`PerfMode_MapDisplayNoteToEvent` swap above.

## Verbatim bytes and `.byte` runs: re-framed as instructions and typed data

| step | what                                                                                                             | command                                                                                                                                    |
|------|------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------|
| 1    | the eight flash-update banners round-trip from PNGs (`mono_images.py` covers v7)                                 | `python3 scripts/build/mono_images.py verify`                                                                                              |
| 2    | the last eight romslice `.incbin`s spelled as `.byte` rows (the inliner now takes `Label:` and an offset/length) | `python3 scripts/converters/inline_romslice_incbin.py FILES`                                                                               |
| 3    | `.byte` runs whose framing the same label's v10 code confirms, re-framed                                         | `reframe_v7_runs_crosscheck_v10.py` (its docstring gives the three commands)                                                               |
| 4    | branch operands left numeric by step 3 named; the 19 R3-refused sites on step 3's lines trusted                  | `symbolize_numeric_branches.py --image v7 --trust-traced analysis/v7-harmonize-2026-10-24/r3-trusted-reframed-sites.json --apply --verify` |
| 5    | the romslice regions the disassembler cannot fully decode, one by one                                            | `python3 scripts/converters/v7_byte_region_to_insns.py FILE LABEL [--auto-indexed] [--fix ...] --apply`                                    |
| 6    | `.byte` runs in front of a misread instruction tail, or holding a register-indexed `(xrr+rr)` form               | `python3 scripts/converters/reframe_byte_runs_by_decode.py --image v7 --linemap LM.json FILES --apply`                                     |
| 7    | names: the structural labels steps 4-6 inserted take v10's names where the parents agree                         | `harmonize_by_caller_alignment.py --to v7 ... --apply` (as above)                                                                          |

Step 5 regions: `CmpStep_DataBlock` (32 bytes; it is v10's `CmpStepTitle_OnPaint`, renamed by
`scripts/renaming/rename_v7_cmpstep_onpaint.sed`), `Not_sure_maybe_SOFT_VERSION_related` (361),
`AccTone_JumpTableData_Helper` (845, including v10's `_Helper2` and `_Helper3`),
`BitMapOut_CopyExtTable_Check` (181).  The data were typed by hand: `AccPatch_ChannelToParamTable`
with `AccPatch_ChannelToRecordPtr` (v7's records are at 0x2BF8-0x2EF8), `RhythmFillIn_PatternTable`
(v10 still spells its 8 bytes as instructions: `rcf / max / push sr ...`), and the `"XAPR"` / `"TEST"`
strings.  `FDC_INTERRUPT_HANDLER`'s `.byte 0xc1, 0x88, 0x89 / FDC_INTERRUPT_HANDLER_Code: push xsp /
nop` is `cp (FDC_ERROR_CODE:16), 0`; the unreferenced mid-instruction label was dropped.  The eight
romslice `.bin` files no source includes any more were removed (`scripts/build/extract_v7_bins.py`,
which named one of them, is retired).

| measure (v7)                                  | before (79e035417) | after  | command                              |
|-----------------------------------------------|--------------------|--------|--------------------------------------|
| verbatim (DEBT) bytes                         | 6,591              | 0      | `kn5000_verbatim_list.py v7/maincpu` |
| source coverage                               | 99.7%              | 100.0% | `kn5000_source_coverage.py`          |
| `.byte` runs after a fall-through instruction | 180                | 78     | `doc_quality_census.py`, row (d)     |
| ... their bytes                               | 1,427              | 1,018  | `doc_quality_census.py`, row (d)     |
| `.byte` runs after a terminator               | 119                | 97     | `doc_quality_census.py`, row (d)     |
| ... their bytes                               | 4,794              | 4,324  | `doc_quality_census.py`, row (d)     |
| numeric branch targets                        | 7                  | 7      | `doc_quality_census.py`, row (b)     |

The re-framing added labels: v7 now has 53,742 labels, 52,870 of them v10 names and 872 not
(`version_shared_names.py`).  The 24 new non-v10 names are structural labels symbolize_numeric_branches.py
put on new branch targets whose v10 name the harmonizer refuses (`parent-differs` or
`v10-name-misparented`).

What is left in row (d) is mostly forms the backend cannot spell at all (`sll a, hl`, `srl a, bc`,
`ldcf a, rh3`, `minc1`, the `d7 fa ...` previous-bank forms), each already commented as such, plus
data runs next to code.
