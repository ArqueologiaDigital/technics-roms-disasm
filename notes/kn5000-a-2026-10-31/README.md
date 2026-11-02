# Lane kn5000-a (wave 4, 2026-10-31): KN5000 / HD-AE5000 notes items and TODO groups

Base main 130735749, branch `open4/kn5000-a`.  Items: the ACTIONABLE, unowned `N-` and `T-` rows of the
`KN5000` and `HD-AE5000` sections of `notes/open-items/REGISTER.md` (not the style-bank rows, not the
tracker issues).  Probes: `probes/` here (README there).  Every rename is a sed script in `scripts/renaming/`,
applied to v10, v9 (v8 builds from it), v7, v6 and v5; every commit was rebuilt and compared (all 21
`compare_roms.py` sections 100.00%) and `l2_symbol_reference.py --check` passed.

## The three pending naming batches (N-045aedde, N-b6c6521a, N-fdf5a34c)

`analysis/kn5000-naming/pending/proposals_{hbatch_h3,sebatch_se3,corrections_c2}.json` (2026-10-17) were
re-validated and applied:

- every old label is still defined in v10, and no new name occurs in any `.s .c .h .ld` of the five maincpu
  trees, the four HD-AE5000 trees, table_data or v142 (`FDC_FormatOneTrack` is also table_data's boot-driver
  twin, a separate image; sharing the name is intended);
- 1,362 of the 1,422 file:line evidence quotes still occur word for word in the v10 source (h3 262 / 291, se3
  884 / 907, c2 216 / 224); the rest name labels renamed since;
- c2's 16 `.equ` records (encoder RAM) and 53 locals are included; c2's agent had not finished its unused-name
  check, which is the check above.

They now live as `analysis/kn5000-naming/proposals-2026-10-31-{hbatch-h3,sebatch-se3,corrections-c2}.json`.
The applier `apply_kn5000_naming_proposals.py` renames v10 only and `harmonize_version_labels.py` carries
names to v9 / v7 but not to v6 / v5, so a new tool did all five trees in one pass:
`scripts/renaming/carry_v10_renames.py` (docstring: the byte proof).  A label is renamed in a tree when the
tree defines the old name, does not define the new one and the 24 ROM bytes at the label match v10's (at least
half equal; differences only inside 3-byte ROM addresses, plus at most four runs of at most 2 bytes, the
16-bit RAM operands v7 / v6 / v5 place lower).  `.equ` names are renamed by name (the RAM lanes gave each
tree's name to its own address; v7 is 0x9c lower, v6 / v5 0xc0).  Result
(`carry-v10-renames-2026-10-31.txt`, the tool's output):

| tree | renamed | not defined there | code differs |
|------|---------|-------------------|--------------|
| v10  | 320     | 0                 | 0            |
| v9   | 320     | 0                 | 0            |
| v7   | 315     | 3                 | 2            |
| v6   | 311     | 5                 | 4            |
| v5   | 307     | 8                 | 5            |

`check_ported_labels.py` afterwards: v7 -> v6 misplaced 100, v6 -> v5 16, v7 -> v5 87 (101 / 17 / 89 in the
kn5000-ports notes): nothing rose.

Prose that still quotes old names: the historical records (older proposal files, review JSONs, census
reports) are left as they were.  The live converters were updated (`panel_button_actions_retype.py`,
`name_kn5000_ram.py`'s docstring).  technics-docs pages that quote the old names (not edited here, see the
Website page draft): `control-panel-protocol.md` (22 names, the encoder table), `memory-map.md` (24),
`data-wheel-investigation.md` (5), `audio-subsystem.md` (2), `rom-reconstruction.md`, `panel-parameter-keys.md`,
`swbwr-tone-init.md`, `subcpu-command-format.md` (1 each).

## The v7-harmonize follow-up renames (N-b4e8e54c)

`analysis/v7-harmonize-2026-10-24/caller-alignment-v7-final.tsv` (2026-10-24) lists 142 `v10-name-misparented`
rows: v10's structural label carries another routine's stem while v7's label at the same code (address
correspondence with a byte proof) has the right parent.  Re-read against the current ELFs: 133 still apply (the
v10 label is where the tsv says, v7 has a label there that v10 does not define); 8 have v7's current name on
another v10 label, so they need a person; 1 v10 label is gone.  The 133, plus the two `both-named` rows
`MasterSetup_HandleDialStop/Turn` -> v7's `AcMstStyleAlp_Boundary_OnHide/OnSwIn` (the dispatcher sends
EVT_HIDE / EVT_SW_IN there, `ui/ui_mode_handlers.s`), are
`analysis/kn5000-naming/proposals-2026-10-31-v7-reparent.json`, applied with `carry_v10_renames.py` to v10 (135)
and v9 (124; v9 does not define the 11 `Voice_FactoryPresetData_*` labels; run log
`carry-v7-reparent-2026-10-31.txt`).  v6 and v5 already had v7's names.  `sync_names_from_v10.py --tree v9`
and `--tree v7` then found 6 and 3 same-address same-bytes pairs (v9's `SeScreenData_0x216B..0x2193` are the se3
batch's `SeFilHpq1_SeFilLpq1_Field1..4_Record`); applied, and v7's 3 carried to v6 / v5 by name.

## Panel records and RAM quotes (N-4aa9f799, N-b5219071)

`scripts/tools/name_kn5000_panel_records.py` now covers all five trees (v6 / v5's `SndParam_BlockRamPtrs` and
default panel image `SndParamRam_DefaultImage` (0xEDB300 / 0xEDB2E8) are byte-identical to v7's, so the records
sit at the same RAM): it wrote `shared/ram_panel_records.s` for v6 / v5 (included from their `ram_variables.s`)
and respelled 1,022 / 1,018 memory operands and 17 pointer loads there.  It now also spells the table itself as
`.long PANEL_*` (77 entries per tree, 0 staying 0).

33 of the 35 `PANEL_REC_<tag>` placeholders take names (`rename_panel_rec_placeholders.sed` for their uses):

| tag(s)             | name                              | evidence                                                                                    |
|--------------------|-----------------------------------|---------------------------------------------------------------------------------------------|
| 0x78               | `PANEL_STYLIST_NAME`              | README-lsw-nonpart-records.md [CODE]: EffectMode_DisplayName_Render copies the 16-char name |
| 0x44 / 0x45 / 0x46 | `PANEL_DRAWBAR_RIGHT1/2`, `_LEFT` | README-lsw-drawbar-records.md: 48 parameter ids 0x82nn / 0x86nn / 0x8Ann                    |
| 0xC0..0xD4, 0xD7   | `PANEL_VARI_<part>`               | PanelTlv_CompanionOfPart's table maps part T to block 0xC0+T; MainVariSet writes it         |
| 0x49               | `PANEL_VARI_STYLE`                | PanelTlv_CompanionOfPart_Style returns it for the style record 0x48                         |
| 0x60               | `PANEL_EFFECT_SWITCHES`           | key table: acoustic illusion / equalizer / reverb on/off (+1)                               |
| 0x70               | `PANEL_PLAY_SETTINGS`             | key table: rotary speed, split point, transpose, orchestrator, TechniChord type, fade times |
| 0x71               | `PANEL_PMEMOUT_L`                 | README-lsw-drawbar-records.md: bit 1 is the ON/OFF cell PmemOutLGridCheck draws             |
| 0x90               | `PANEL_CONDUCTOR`                 | key table: conductor (+0), APC on bass / left hold (+3), R1R2 octave (+4)                   |
| 0x91               | `PANEL_GM`                        | key table: GM on/off (+3)                                                                   |
| 0x98               | `PANEL_PMEM_SETTINGS`             | key table: panel memory mode / number, music style arranger, metronome, memory filter       |

`PANEL_REC_68` and `PANEL_REC_9A` keep their tag: README-lsw-nonpart-records.md records that nothing but the
generic block walkers (`PanelTlv_ValidateBlock1`, `BitMapOut_CopyAuxTable_*`) reads them, and its probe
`analysis/disk-format-probes/lsw_nonpart_records.py` is the search; there is no reader to name them from.
The meaning of the C-family's index (sound group) stays the [INFERENCE] that note marks.

`scripts/tools/respell_ram_quotes_in_comments.py` names the parenthesised RAM quotes of comments, "(0x0D57)" ->
"(SQSTEP_CLOCK)", when exactly one `.equ` of the tree has the value: 728 in v10, 527 in v9 (their RAM equates
agree, 574 of 574).  v7 / v6 / v5 are not run: their headers often carry v10's text and v10's addresses.

## Port D bit 0 is FDCRST (T-kn5000-tabledata-todo-identify-what)

The service manual's CPU SECTION (A) diagram (p. 32) wires IC5 TMP94C241F pin 12 PD0 to the sheet label FDCRST,
pin 13 INT4 to FDCINT, pin 14 INT5 to FDCDRQ and pin 17 PD6 to FD.I/O (`probes/sm_pd0_net.py` renders the
crops; the scan has no text layer, so the reading is by eye, recorded in its docstring).  So the 10-tick pulse is
the floppy controller's hardware reset: table_data's `Boot_PulsePD0` and the main CPU's
`Reset_Floppy_Disk_Controller` (whose comment said "I am not entirely sure") are both `FDC_PulseResetLine` now,
with headers saying so (`rename_fdc_pulse_reset_line.sed`).

## FDC_CmdSenseDriveStatus, the NMI header, the 0x01EA comments (N-99d09c1a, N-edecc6e4, N-b6dceb67, N-42c40102)

- `FDC_INTERRUPT_HANDLER` was FDC command 11, SENSE DRIVE STATUS (uPD72068 command byte 0x04, ST3 bits 7 / 5 / 6
  -> 0x32 / 0x31 / 0x2f, technics-docs fdc-subsystem.md's error codes); no `ei` / `di` in it.  Named after its
  table_data twin.  v6 / v5 also had `cp (FDC_ERROR_CODE:16), 0` split into `.byte` + a mid-instruction label;
  respelled.
- `NMI_StorePayloadChecksums`'s header names BOOT_STAGE and its writers.
- HD-AE5000, all four trees: the SEL_DIR screen comments now say the 0x01EA codes are the module's own ResMethod
  ids (HDAE5000_Handler_Registration, ResMethodProc), the arms are `.Lfd_select_ok` / `.Lfd_select_save`
  (MT_SelectOK / OK2 / SAVE), and the filesystem / MT_SetStrAdr / init_data comments follow.  The v1.15i replay
  edits that match those lines were updated (`port-edits-v1_15i/04g_no_select_all.py`, `94b_v1_prose.py`).
- `NAKA_TYPE_*`: every class index carries its firmware class name (all 109 root classes), in macros.s,
  naka_types.h and the converters.
- `port-edits/00_filepanel_picture.py` keeps quoting the comment it replaced: it is the record of a one-off edit
  and nothing replays that directory; its docstring now says so.

## Smaller renames and answers

| item                       | what                                                                                                  |
|----------------------------|-------------------------------------------------------------------------------------------------------|
| N-ec33691a                 | `AccStyle_VelocityTable*` -> `AccStyle_PanelRhythmTable*`, `AccStyle_LookupPanelRhythm` with a header |
| N-830904fd                 | RectX2Proc's `TabDraw_*` locals take RectY2Proc's case names                                          |
| T-kn5000-v10-todo-the-name | `MidiThru_Enable/Disable` -> `MidiIn_IgnoreClockTransport` / `MidiIn_AcceptClockTransport`            |
| N-bc8cf677                 | the last 21 `<Table>_Target<k>` handlers named (Scoop bound ops, panel-LED handlers, display events)  |
| N-d4782271                 | FONTID_NAME_TABLE is never written after boot (`probes/fontid_table_writers.py`)                      |
| N-ef0b5633                 | `TEST3.fontcolor = 0x0043` has no firmware name and is never read (gui-kn5000 README)                 |
| N-94f26143                 | AcLanguageTextProc adds `4 * HELP_LANGUAGE` back; its borrowed `AcTrkSw_ShowHide*` labels renamed     |

## Website page draft

For the docs lane (technics-docs is not edited here):

- `memory-map.md`, I/O table, row `0x34 PD`: add the main CPU's use of Port D.  (Corrected 2026-11-02: this
  draft used to call the row's "bit 0=sub ready" wrong; the row is in the sub-CPU SFR table, where it is right.
  The docs lane added a main-CPU note to it instead.)  On the main CPU, Port D bit 0 is FDCRST (the floppy
  controller's hardware reset, pulsed by `FDC_PulseResetLine`), bit 6 is FD.I/O (disk change); INT4 is FDCINT
  and INT5 FDCDRQ (service manual p. 32).
- `fdc-subsystem.md`: replace "the neighbouring `Boot_PulsePD0` ..., whose Port D bit 0 line is not yet
  identified" with "`FDC_PulseResetLine` pulses FDCRST (Port D bit 0) for 10 ticks"; command 11 is
  `FDC_CmdSenseDriveStatus` in both images.
- The encoder / panel pages quote the old c2 names; replace by the map in
  `scripts/renaming/rename_kn5000_naming_w4_v10.sed` (e.g. `Encoder_ProcessModwheel` ->
  `Encoder_ProcessExpressionPedal`, `ENCODER_STATE_BASE` -> `PANEL_LED_IMAGE`, `CompIface_*` -> `Fade_*`,
  `Timer7_DisableInterrupt` -> `Demo_ReleaseGlidePedal`): control-panel-protocol.md, memory-map.md,
  data-wheel-investigation.md, audio-subsystem.md, rom-reconstruction.md, panel-parameter-keys.md,
  swbwr-tone-init.md, subcpu-command-format.md.
- `hdae5000-homebrew.md`: the 0x01EA ids are private to the module (no main-CPU code uses one).

## Icons (N-b0077010, N-94c35266)

`idICON_iNN` has the value NN + 2, and DrawIcons_Impl reads entry `0x938000 + 8 * id` of the icon table, whose entry
k points at `IconPixels_k` (checked for entries 0-4, 100, 130, 131, 175 against the table_data symbols).  The 113
icons the v10 C records and the HD-AE5000 sources use were rendered to one contact sheet (extract_icons.py's
renders, 2x, labelled; scratch only) and described by eye: `scripts/generators/naka_icon_descriptions.json`.
`gen_naka_gui_headers.py` writes the description beside each `#define idICON_iNN` (naka_classes.h, all five
trees) and `.equ` (hdae5000/shared/naka_values.s); `hdae5000_menu_map.py` adds it to the HD-AE5000 menu maps.
The KN5000 menu map does not print icons.  Descriptions say what the picture shows, not what the firmware uses
it for.

## IC14 style records (N-628bbeaf, N-a7314f90, N-ae3d1690, N-8f4e2d69)

`probes/ic14_slot_readers.py` lists the evidence; `notes/rhythm-data-ic14-2026-10-29/README.md` (open questions
2, 3, 4, 6) has the answers, and `rhythm_data/rhythm_macros.inc` (via `gen_rhythm_data_s.py`, which still
reproduces it) says them per field:

- part_sound +4 `voice4`: byte 4 of the part's voice record and of the 0xC0 ring-buffer record, never read alone;
  +5 `turnover` (-> 0x32c3+n -> 0x32cb, Rhythm_TransposeNote / Rhythm_BassToRoot); +6 `ceiling`
  (-> 0x32c7+n -> 0x32cc, the octave-folding limit).
- slots 8..11: no caller of AccPart_GetParamAddr passes their offsets; leftover bars.
- +0x3e3..+0x3f2: no reader anywhere in v10; declared authoring metadata.
- 8beats / 6beats: every locator reader but Rhythm_LoadCurrentTimeSig remaps; that one reads only the time
  signature.  No path plays them: leftovers.

## Accompaniment per-lane RAM (N-11e956be)

`ram/acc_lane_names.txt` (applied with `scripts/tools/add_kn5000_ram_names.py`, which derived v7's addresses,
0x9c lower, from the same instructions): `ACC_LANE_BAR[6]` 0x32b5 and its working copy `ACC_CUR_BAR` 0x33da
(AccVoice_SavePartStateN / RestorePartStateN, incremented by AccVoice_HandleBarEndEvent at a bar wrap),
`ACC_LANE_MEASURE[6]` 0x33eb and `ACC_CUR_MEASURE` 0x33ea (AccVoice_IncrementBarCounter wraps it at record byte
+13), `ACC_CH_TURNOVER[4]` 0x32c3 / `ACC_CH_CEILING[4]` 0x32c7 and their working copies 0x32cb / 0x32cc (IC14
part_sound +5 / +6, above), `ACC_CH_CC3[4]` 0x332f and `ACC_CUR_CC3` 0x3333 (the last 0xD3, controller selector 3,
value of the pattern, sent as `0xdn 0x03 v`).  The headers that call them "program" (AccVoice_SendProgChange) and
"volume" (Rhythm_SendVolume_Dn) are not settled by this lane: the bytes come from 0xD3 events, which the IC19
analysis reads as damper [INFERENCE]; the names stay neutral.  v6 / v5 have no ram_variables_by_use.s yet.

## Scoop unknowns (N-1fe9a5df, split)

`probes/scoop_unknown_readers.py`: the 64 bytes after Str_TuningEq's "TUNING=", Str_ExtTabEffectEnDis,
Unref_EF6BD3_Tbl, Unref_EFA7C5_Tbl and ClockConfig_Select_Table have no instruction operand inside them in the
linear listing, and every 3-byte occurrence of their addresses lies inside other instructions; ParamPopup_PartTuning
copies exactly 7 bytes.  No reader: closed for these five.  Left: the 0x09 bytes of Tbl_AccompPartNames are
printed as character code 9 by ParamPopup_AccompPart; what glyph the status font has at 9 was not looked up
(the region-0 renderer's font must be traced first).

## Not done by this lane (for the integrator)

The lane ran alone (the sub-lane split it planned could not start: the session's agent limit was reached), so
these items of its list were not worked; nothing in this branch changes them:

| item                   | why not, and the first step                                                                                                                                                                                                                                                                                                                                          |
|------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| T-kn5000-v6-todo-port  | port debt v6 13,756 B (3,403 TODO(port) rows + 10,353 json raw bytes, 25 bins); needs per-version C, biggest naka_style_bitmaps                                                                                                                                                                                                                                      |
| T-kn5000-v5-todo-port  | port debt v5 15,910 B (4,284 rows + 11,626 json raw bytes, 29 bins); same work, after v6                                                                                                                                                                                                                                                                             |
| N-d8cf1242             | 525 field_XX members; trace the base-pointer readers of naka_sequencer_channels.c first                                                                                                                                                                                                                                                                              |
| N-2f640c1d             | 65 Viewable elements untyped (20 straddling members, 13 DRAM records, 32 skipped by naka_asm_records.py)                                                                                                                                                                                                                                                             |
| N-45db7885             | 73 numeric ROM addresses in the NAKA C; split the target slices, then NAKA_ADDR(label)                                                                                                                                                                                                                                                                               |
| N-c49a6232             | about 66 *_Strings char[] members to split into one member per string                                                                                                                                                                                                                                                                                                |
| N-7c99f0f2             | 81 titles without a menu path; trace the Scoop sound-editor openers of TITLE_SE*                                                                                                                                                                                                                                                                                     |
| N-51b2e19c             | per-bit naming of the busiest flag bytes (kn5000_ram_bit_usage.py)                                                                                                                                                                                                                                                                                                   |
| N-e40b7174             | the per-title RAM address tables (AppEvtHandler_Branch_002_RamPtrs / AppEvent_SubDispatch_RamPtrs in naka_widget_descriptors.c) hold 0xF1F1, 0x261C ...: they need the SQEDT_* names in a C header (gen_naka_gui_headers.py does not export RAM names yet); 0x2640 / 0x2642 / 0x263a (SeqPart_VelZoneLookup, SeqPart_VelExprClamp) are the only numeric .s uses left |
| N-52dcf02a, N-d352b868 | IC307 sequence words / unselected entries; owned in effect by kn5000-b (tracker kn5000-d38)                                                                                                                                                                                                                                                                          |

## Merge of main 37ecc2a2b (kn5000-b, kn5000-style, misc, wsa1)

Lane kn5000-b's cpanel sub-lane had renamed the same encoder / panel-action labels as this lane's c2 batch, so 77
files conflicted (611 hunks in sources).  Resolution: every source hunk took main's side, then this lane's sed
scripts were run again over all five trees (they are idempotent), and where both lanes had renamed one label
differently main's name wins: `scripts/renaming/rename_kn5000_a_reconcile_main.sed` (11 labels per tree found by
comparing the base, main and lane symbol files by address, plus the 12 encoder RAM `.equ` names, e.g.
`Encoder_TouchSettingsListener` -> `Encoder_OnTouchSensitivityChange`, `PANEL_LED_IMAGE` -> `CPANEL_LED_IMAGE`).
Two RAM `.equ` lines of this lane (ACC_CH_CC3 / ACC_CUR_CC3) sat in a conflicted hunk and were re-added.  Headers this
lane inserted inside conflicted hunks (some c2 / h3 headers) are main's text now.  Checked after the merge: none of
the 455 old names of the four proposal files remains in v10, every hand edit of this lane listed above is present in
all five trees, the v1 HD-AE5000 replays reproduce their committed trees (run before the merge, at 81875bdd9's
successor), and `make gate` passes.

## Gates and read-only censuses (after the merge, 03a2f1719)

- `make gate`: exit 0.
- `doc_quality_census.py --compare` (against doc-quality-2026-10-31-02): 15 figures rose, all present on main
  37ecc2a2b alone (main shows 17; (d) byte runs in v10..v5, headers in v142/v141/v140, kn6000/kn6500).  Before the
  merge this branch rose in nothing, and after it v6 / v5's (d) bytes are 3 lower than main's (the FDC respelling).
- `data_incbin_census.py --compare`: nothing rose.
- dispatch census (maps in scratch): 9 figures rose, all in the HD-AE5000 v2.01i / v1.15i / v1.10i rows.  This lane
  changed only comments and two `.L` local labels in those trees; main's HD-AE5000 lanes were not re-measured alone.
- `check_ported_labels.py`: v7 -> v6 misplaced 100, v6 -> v5 16, v7 -> v5 87 (before the merge; none rose).
