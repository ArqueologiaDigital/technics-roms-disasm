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
| How many review-list names does v7 define now?            | `python3 scripts/analysis/v7_review_names_resolved.py [--tsv-rev REV] [--list]`                  |
| Is v10 routine X the same code as v7 routine Y?           | `python3 scripts/analysis/v7_routine_equivalence.py X=Y=NBYTES`                                  |

`DIR` is a scratch directory for the two `llvm-objdump` listings (about a minute each to make).

### Measured 2026-10-24

The tool was applied 19 times, rebuilding v7 between runs, until a run proposed nothing, plus one
`--rename-named --only ...` run (below) and one more run after the re-framing (step 7 of the next
section).  Its rename rules are recorded in `scripts/renaming/harmonize_v7_by_caller_alignment.sed`:
18 run blocks, 1,858 `s///` lines, 1,788 renames (1,766 at a986ccd51, 22 in step 7).  The first 14
blocks write one direct rule per rename (none of them holds a swap or chain); from the 15th block on
the generator sends every rename of a run through a temporary name, two lines each (140
`HARMONIZE_TMP` lines, 70 temporaries; in the 15th block 40 of its 43 renames are members of swaps
or chains).  The runs also inserted three labels where v7 had none:
`CmpStep_DrawScreen` (first run), `AccTone_JumpTableData_Data` and `AccTone_JumpTableData_Helper`
(seventh run).  Inserts change no name, so sed cannot replay them; they are listed as
`# insert NAME at ADDR before FILE:LINE` comments in their run blocks (backfilled from the run
reports; the tool now writes these comments itself).  One swap was made by hand:
`scripts/renaming/rename_v7_perfmode_note_map_swap.sed` (v7 had `PerfMode_MapEventNoteToDisplay` on
the inverse routine; `v7_routine_equivalence.py` shows both routines equal to v10's under the
swapped names, 36 bytes each).

| measure                           | before (79e035417) | after (a986ccd51) | command                          |
|-----------------------------------|--------------------|-------------------|----------------------------------|
| v7 labels (linked ELF)            | 53,559             | 53,693            | `version_shared_names.py`        |
| v7 labels that are also v10 names | 51,374             | 52,845            | `version_shared_names.py`        |
| v7 labels that are not v10 names  | 2,185              | 848               | `version_shared_names.py`        |
| v7 `.Lc_<addr>` locals            | 638                | 507               | `doc_quality_census.py`, row (c) |

The label count grew because `.Lc_` assembler-local labels renamed to v10 names became symbols, and
because of the three inserted labels.

The review list (`analysis/header-propagation/review-2026-10-24.tsv`) was regenerated later in this
lane (see "Headers" below), and a regenerated list holds only what is still missing, so the names it
listed before the lane are read from git.  Measured at the branch head (after every step of this
lane) against the list as it stood at 79e035417:

    $ python3 scripts/analysis/v7_review_names_resolved.py --tsv-rev 79e035417
    review list: analysis/header-propagation/review-2026-10-24.tsv at 79e035417
    v7 label-absent labels:             356, defined now  220
    v7 names-absent-symbol names:       138, defined now   79
    v7 names-absent-symbol rows:        189, every name defined now  108

(79e035417 is the default of `--tsv-rev`.  Before the lane every one of these was 0, by the list's
definition.  a986ccd51's commit message quotes 219 / 78 / 107, measured before the later steps.)

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
| 8    | the lines steps 3-6 wrote, respelled like v10 (tab after the mnemonic, v10's hex/decimal, `call cc, (X:24)`)     | `python3 scripts/tools/respell_v7_new_lines_like_v10.py --apply`                                                                           |

Step 8 rewrites only the lines `git blame` gives to the re-framing commit (d89e64558), and only their
spelling.  Where the enclosing label's v10 block has the same instruction (number-masked text, aligned
with difflib) each number takes v10's notation; elsewhere RAM operands of 256 and up, and/or/xor masks of
10 and up and 32-bit register loads of 256 and up are written in hex.  Of the 880 instruction lines it
examined (572 with a v10 counterpart, 308 by the fallback rules) it changed 486, 4 of them `call_24`, and
brought the v7 count of `mnemonic<space>operand` lines back to where it stood before the lane: 157,378 at 79e035417, 157,771 at 5ecd0dbdf, 157,378 after
(`respell_v7_new_lines_like_v10.py --space-count REV`).  `make gate` stays IDENTICAL.

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

## Headers on the newly matching routines

`python3 scripts/tools/propagate_v10_headers.py --apply` was re-run after the renames and the re-framing
(rules unchanged, see `analysis/header-propagation/README.md`); `--verify HEAD` passed (25 files: code
unchanged, comment insertions only) and `--check-ram HEAD` flagged 0 of the 223 headers it touched.  The
review list `analysis/header-propagation/review-2026-10-24.tsv` was regenerated by that run (its 183
hand-port rows kept).  **Merge note:** the list is a generated file that any lane re-running
`propagate_v10_headers.py --apply` rewrites as a whole (926 lines changed here), so a merge with another
such lane will conflict on it.  Take either side, then regenerate it once both lanes are in, with
`python3 scripts/tools/propagate_v10_headers.py --apply --review analysis/header-propagation/review-2026-10-24.tsv`
(only `--apply` rewrites an existing list; `--count` changes nothing, and without `--review` the list is
named after the day of the run).

| measure                                         | before (79e035417) | after | command                                  |
|-------------------------------------------------|--------------------|-------|------------------------------------------|
| v10 labels with a header whose v7 label has one | 9,035              | 9,257 | `propagate_v10_headers.py --count`       |
| v10 labels with a header whose v9 label has one | 9,601              | 9,602 | `propagate_v10_headers.py --count`       |
| v7 routines with a header (census rule)         | 1,076              | 1,287 | `doc_quality_census.py`, "with a header" |
| v7 routines without a header                    | 7,814              | 7,628 | `doc_quality_census.py`, row (a)         |

The "before" `--count` figures were measured on this branch after the renames and before this run
(the renames themselves add no header); the census figures are the committed
`docs/coverage/doc-quality-2026-10-24-03.txt`.

## One census figure rose, as expected

`python3 scripts/analysis/doc_quality_census.py --compare` against `doc-quality-2026-10-24-03` reports one
rise for v7: (b) "(number) operand elsewhere" 28,877 -> 29,059 (+182).  These are the RAM operands
(`and (0x357a:16), 254`, `ld (0x36ff:16), 16`; decimal until step 8) of the instructions this lane
spelled from bytes: as `.byte` they were not counted at all.  v7 names few RAM variables (`shared/ram_variables.s`); naming them is the RAM
lane's work (WP17 (a)).  Everything else the census compares fell or held: (a) -186 routines without a
header, (c) -131 `.Lc_` locals, (d) -124 runs.  The read-only dispatch census
(`census.py --compare docs/coverage/dispatch-census-2026-10-24-02.json`, maps built in a scratch
`DISPATCH_CENSUS_DIR`) reports nothing rose.

## Follow-ups for other lanes

- v10 headers: `FDC_INTERRUPT_HANDLER`'s header (`v10/maincpu/storage/fdc_routines.s`, carried to v9/v7)
  says "Enables interrupts via prevbank (D7 FA 04 = ei 4)" and "Disables interrupts (D7 FA 05 = di 4)",
  but the routine starts `push qiz / cp (FDC_ERROR_CODE:16), 0` and contains no `ei` or `di`.  The
  wording should be fixed in v10 and re-propagated.
- v10 names: the 142 `v10-name-misparented` rows of `caller-alignment-v7-final.tsv` and
  `MasterSetup_HandleDialStop/Turn` (above) are renames that belong in v10.
- ~~The respelling of step 8 is a post-process; the converters still emit llvm-objdump's spelling.~~
  **CLOSED 2026-10-31** (lane open4/misc, `notes/misc-2026-10-31/README.md`): both converters call
  `respell_v7_new_lines_like_v10.respell_lines()` on the lines they write; a re-run on committed step-5 blocks
  reproduces the tree (6 of 7 blocks identical, the seventh differing only by a RAM name applied later).
