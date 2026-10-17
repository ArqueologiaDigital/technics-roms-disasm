# Next steps after the 2026-10-17 semantic-coverage session

The owner stopped this autonomous session at about 10:00 BST to save tokens for other work. Everything
below was committed before it ended, except the items listed under **Pending work**. Their inputs
are saved in the repository, so a later session can pick them up without redoing the research.

## Where things stand

| measure (`make semantic-score`) | 2748ddff (start) | b85f1c53 (mid-session) | f38b7c30 (end) |
|---------------------------------|------------------|------------------------|----------------|
| all, score                      | 96.09            | 96.38                  | 96.47          |
| KN5000, score                   | 96.51            | 96.84                  | 96.95          |
| KN5000, names                   | 94.8%            | 96.1%                  | 96.3%          |
| WSA1, score                     | 92.62            | 92.62                  | 92.62          |

KN5000 bytes went from 96.7% to 97.0% between b85f1c53 and f38b7c30. Most of that is the data census
rule change of 1b6c7965e (data-macro one-liners and 1-3 byte pads in compact blocks), which adds 15,234 B
of KNOWN-A to v10.

## What this session added (tools worth reusing)

| tool                                                   | what it does                                                                                           |
|--------------------------------------------------------|--------------------------------------------------------------------------------------------------------|
| `scripts/renaming/localize_internal_generic_labels.py` | generic labels reached only by jumps inside one named routine become `<Owner>_Skip/_Join/_Loop...`     |
| `scripts/renaming/harmonize_permuted_locals.py`        | fixes v9/v7 "name taken" rows that are a permutation of v10's local-label numbering                    |
| `scripts/renaming/gen_sndparam_desc_names_r3.py`       | round 3 of the sound-parameter descriptor names (evidence: `analysis/disk-format-probes/sndparam-r3/`) |
| `scripts/tools/align_md_tables.py`                     | re-pads Markdown tables; keeps `:` markers and list indentation                                        |
| `scripts/analysis/compiler_id/`                        | the evidence that Toshiba's cc900 built the firmware (`verify_toshiba_runtime.sh`)                     |

Naming-agent proposals go through `scripts/renaming/apply_kn5000_naming_proposals.py TAG FILE --apply`,
then `make all`, `harmonize_version_labels.py --to v9 --apply` and `--to v7 --apply` (re-run until it
settles), `rename_orphan_locals.py --tree <t> --apply` for each tree, `make gate-all` (4 PASS lines),
`l2_symbol_reference.py --regen` and `--check`, and a check of technics-docs for the old names. The
validator used this session is `~/compartilhado/tmp/kn5000-s1017/validate_props.py`, harvested into
research-scratch. Unlike `naming_pipeline/kn5000_validate_proposals.py`, it also checks `.set` names and
C identifiers.

## Pending work (inputs saved, not applied)

The three naming agents running when the session stopped were asked to write out their finished
records and mark the rest "not reviewed". Their outputs are copied into `analysis/kn5000-naming/pending/`
(see the README there). Validate them, spot-check the evidence, copy each into
`analysis/kn5000-naming/proposals-<date>-<tag>.json`, then apply them as above:

1. `proposals_hbatch_h3.json`: names for 47 `_Helper` routines with named callers. These were the last
   helpers with a named caller that no earlier batch had proposed.
2. `proposals_sebatch_se3.json`: 193 names. 158 cover the 159 `SeScreenData_0x<offset>` sound-editor record
   lists and 35 cover misnamed tables and records. The agent re-checked that none of the names is in use
   and that every old label is still defined.
3. `proposals_corrections_c2.json`: corrections for misleading names. These cover the `CompIface_*`
   routines (the claim is that they are the fade engine), `PanelAction_ModWheel`,
   `Timer7_DisableInterrupt`, and the encoder RAM names in `shared/midi_encoder_constants.s`.

## Leads not yet worked

- **55 sound-parameter descriptors** are still unnamed: Lsw 0x605, drawbar 0x221, 0xC1, 0x301,
  0x4080/0x4081, record 0x99's flag bits and its six unshown function bytes. What is known about each is
  in `analysis/disk-format-probes/sndparam-r3/unresolved.json`. Two names are only probable and are not
  applied (`inferred.json`): 0x4000 MAIN VOLUME and 0x4A00.
- **Sub CPU (v142) controllers.** 0x5E (`Voice_CC_Portamento` / `Voice_Portamento_OnHandler`), 0x91, 0x9B
  and 0x9D keep their GM-guess names. `SndPart_SetParam` does not send them, so another main-CPU sender
  has to be found (98670dc62).
- **Batch r2's leads** (`analysis/kn5000-naming/proposals-2026-10-17-generic-r2.json`):
  - The `SysEx4B_` / `SysEx49_ChannelWords` tables are named after the wrong blocks: the 4B words feed
    chorus 0x49, and the 49 words feed reverb 0x4B.
  - `PanelTag48_UpdateAudioConfig_StyleNumber` is really the arm for byte 3 of record 0x48.
  - `ExtData_ToneParam_DispatchHandler` toggles bit 0 of part-record byte +22. This contradicts
    `README-lsw-part-record-fields.md`.
  - `scoop_display.s` 13832-13841 is unreachable code.
- **Batch r1's leads.** The alias `PmemOutLGridCheck_CaseTable_Tail` should be merged (the C field needs
  renaming too). `FileIO_BytecodeData_Code_Join18`, `_Loop3` and `NakaData_WidgetInit1` are foot-pedal
  function handlers with placeholder names. `ExitWindow_Init` belongs to ObjectProc.
- **`ScreenGroup_Dispatch` / `_InitState` / `_ReInit`** still carry the old "screen group" reading. They
  run the subsystem init phases (see technics-docs boot-sequence.md). Other old screen-group leftovers:
  `VoiceInit_Dispatch`, `ScreenGroup_DispatchAlt` (an alias) and `ScreenGroup_WidgetLoop`.
- **Remaining generic pools** (v10, after this session): about 1,500 generic names. 452 of them are
  `_Helper`, and almost none of those has a named caller left. v7 has about 380 more generic names than
  v10, in code that differs from v10, so they need v7-specific reading. WSA1's positional pool (prom_b
  `T_` thunks to unnamed targets, display lists without text, `sub_`) needs table and state research,
  not caller-based naming. Localizing WSA1 labels would gain only about 100.
- **Data census grade B.** The largest KN5000 grade-B pools are headerless named items. Examples are
  the `NakaInst_*` resource-name strings after each ResNameProc table in `naka_screen_dispatch.s`, and the
  `ChordTypeStr_*` strings after their pointer table. They need an evidence-bearing header directly
  above each string block. WSA1's grade-B regions mostly carry honest "Unknown:" fields, so they need
  real research, not rewording.
