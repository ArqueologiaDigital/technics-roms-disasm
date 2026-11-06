# Lane kn5000-naka2 (wave 12, 2026-11-06): NAKA records and cells, menu paths, audio state words

Base main e53dc9b3a, branch `open12/kn5000-naka2`.  Items N-2f640c1d, N-7c99f0f2, N-d8cf1242 (NAKA C, from
`notes/data-semantics-2026-10-29/gui-kn5000/README.md`) and N-51b2e19c (flag bytes, from
`notes/ram-naming-2026-10-24/README.md`), each continued from wave 11's next step
(`notes/kn5000-naka-2026-11-06/README.md`), plus the `add_kn5000_ram_names.py` re-spelling bug.  Addresses are
v10 main-CPU addresses.  Every change is byte-identical (`make gate`).

## Measurements

Before = main e53dc9b3a, after = this lane's head.

| measure                                                  | before    | after     | instrument                                                                  |
|----------------------------------------------------------|-----------|-----------|-----------------------------------------------------------------------------|
| untyped Viewable elements (v10)                          | 45        | 13        | `python3 notes/kn5000-notes-2026-11-06/probes/naka_untyped_elements.py`     |
| field_XX members, v10 / v9                               | 163       | 141       | `python3 scripts/analysis/naka_gui_census.py`                               |
| field_XX members, v7                                     | 171       | 149       | same                                                                        |
| field_XX in naka_sequencer_channels.c (v10)              | 22        | 0         | `python3 scripts/analysis/naka_gui_census.py --files v10`                   |
| titles with a menu path (of 211, v10)                    | 162       | 170       | `python3 notes/kn5000-naka-2026-11-06/probes/menu_map_summary.py`           |
| titles without a path / of them opened by unreached code | 49 / 31   | 41 / 23   | same                                                                        |
| title-by-index call sites with an unknown path (v10)     | 19        | 18        | `python3 scripts/converters/name_title_index_operands.py --report`          |
| numeric uses of the N-51b2e19c flag bytes (v10)          | 611       | 484       | `python3 notes/kn5000-notes-2026-11-06/probes/flag_byte_uses.py --tree v10` |
| operands a no-op rerun of add_kn5000_ram_names.py moves  | 8 / 8 / 5 | 0 / 0 / 0 | `python3 scripts/tools/add_kn5000_ram_names.py <empty file>` (v10/v9/v7)    |

## The add_kn5000_ram_names.py re-spelling bug (3c1be0d5a)

Step 5 (`spell_structs`, `to_exact`) re-spelled every `REC+k` whose address has a name of its own, also for
k >= the record's size.  Wave 10's loop ends (`cp xhl, ACC_BASS_NOTES+72`, the end of a 72-byte array) thus
became the next record's name (`ACC_ACCOMP1_NOTES`).  Now only a k inside the record counts as a field.  A run
with an empty names file used to move 8 / 8 / 5 operands (v10 / v9 / v7); now it moves none, so a rerun is a no-op.

## N-51b2e19c: the audio state words (3df5bbad6)

`ram/audio_state_names.txt` holds the names and the per-bit evidence.  It was applied with
`scripts/tools/add_kn5000_ram_names.py` (v10 / v9 / v7; v9 and v7 derive 0xC4FC.. from the same uses).

- **0xC598 `AUDIO_SEQ_TRACK_FLAGS`**.  Audio_CheckInitStatus (audio/audioinit_routines.s) rebuilds it from 0
  over the 16 sequencer tracks.  Its "group A" are the play tracks, SEQ_TRACK_MASK | 0x0D51.  Its "group B" are
  the record tracks, SEQ_REC_TRACKS | 0x0D4F.  0x0D4F / 0x0D51 are the step and beat / drum editors' own masks:
  SqStep_SetupCursorTrack sets the cursor track in both, and BmDrEdit_InitCommon_SetupDisplay copies 0x2963 into
  both.  Its "types 0xD / 0xE / 0x10" are TRACK ASSIGN 13 CHORD, 14 APC and 16 RHYTHM (SeqTrackAssign_PartTagTable,
  AudioInit_SlotOrderMap).  The bits:
  - bit 0 = exactly one record track;
  - bits 1 / 2 / 3 = a record track is CHORD / APC / RHYTHM;
  - bits 5 / 6 = a play track is CHORD / APC.  With bit 6, AUTO PLAY CHORD comes from PANEL_STYLE+4;
  - bit 8 = there are play tracks;
  - bit 9 = there are record tracks.  It is cleared again while 0x28B3 bit 3 is set, and 15 voice-allocation
    routines test it;
  - bits 4, 7 and 10-15 are never set.
- **0xC59E `AUDIO_REC_TRACK_SLOT`**: the AudioInit_SlotOrderMap entry of the first record track.  With bit 0,
  AudioInit_ConfigureVoiceFromFlags copies it to 0xC1FF.
- **0xC59C `AUDIO_STATE_CHANGES`** and **0xC59A `AUDIO_VOICE_CHANGES`**: the two change masks of
  AudioInit_DispatchChanges.  Each bit selects one compare-and-send pass (AudioInit_CompareVoiceConfig,
  _ComparePartAssignment, _ComparePartConfig, _ComparePartStates, _CompareVolumeTable, _CompareChannelConfig,
  _CompareChannelMappings, _ComparePriorityTable, the tone re-allocation) over the 358-byte audio state at
  0xC1FE.  The routine then copies that state over its sent copy at 0xC364 (`ldirw`, 0xB3 words) and clears both
  words.  Some bits are set but never read: 0xC59C bits 5 and 11, 0xC59A bits 2 and 10.  No code sets 0xC59A
  bit 12.
- Renames (`scripts/renaming/rename_kn5000_naka2_audio_tracks.sed`, all five trees): the labels named after the
  wrong guess become play / record track names, e.g. AudioInit_CheckGroupA -> AudioInit_CheckPlayTrack,
  AudioInit_GroupB_TypeE -> AudioInit_RecTrack_Apc, AudioInit_GroupB_Type10 -> AudioInit_RecTrack_Rhythm.
  `rename_kn5000_naka2_audio_comments.sed` respells the address comments.

Left: 0xC1FE (byte 0 of the 358-byte state block: bits 1-3 select the voice routing), 0xC59C's neighbours,
0x28B2 / 0x28B3 (sequencer state; 0x28B3 bit 3 suppresses AUDIO_SEQ_TRACK_FLAGS bit 9), 0x34CD, 0x35B0 and
0xE3E2.  Next step: 0x28B2 / 0x28B3 per bit, starting from their 63 + 63 uses
(`flag_byte_uses.py` lists the counts).  Then decide whether 0xC1FE gets a `[358 bytes]` record name, which
would spell its interior operands as RECORD+k, and 0xC364 the same for its sent copy.

## N-d8cf1242: field_XX

- **The 12-member run at RAM 0x3EA10** (7bf7a8e1f).  These are AcWelcomScreen_Select's three saved
  WELCOME-script steps (ui/drawbar_panel_ui.s), not PsMixer data.  A step is 12 bytes: +0 the SetApTimer
  interval, +4 x, +6 y, +8 op, +10 argument.
  - Op 2 keeps two slots at `lda xwa, (0x03ea0c:24)` + 12 * argument.
  - Ops 9 / 12 (COLOR / COLOUR) keep one slot at 0x3EA24.
  - Each op blits back the step saved in its slot, unless the slot's +10 is 0xFFFF, then copies the current
    step in (`ld bc, 6; ldirw`).

  The power-on images are empty steps of those ops.  Part_CaptionStrPtrs had taken slot 0's first word as its
  28th entry, and pad_169 / pad_170 were the other two slots' first words.
  `scripts/converters/naka_type_welcome_steps.py` writes `AcWelcomScreen_Step_t AcWelcomScreen_SavedSteps[3]`.
- **The 10 odd-aligned words at blob 0x18A3** (065f55a6f).  These are RAM 0x3F576..0x3F591.  The records that
  use those cells name them: SONG1_AcMstSong1GridBox's pcol / prow / crow (letter s, 32-bit) and its three
  song-category counters, SONG2's window parent / child (letter r), and SONG2_AcMstSong2GridBox's selrow.  The
  C had cut them from odd offsets, plus `str_12` and `NakaData_RomEnd_ptr_3` (0x00FFFFFF, a coincidence of
  bytes).  `scripts/converters/naka_frame_song_grid_cells.py` writes the nine cells under the names the records
  already use, and naka_ram_cells.h is regenerated.

Left: 141 field_XX (v10 / v9) and 149 (v7), none of them in naka_sequencer_channels.c.  Next step: the files
with the most, from `python3 scripts/analysis/naka_gui_census.py --files v10`:

| file                     | field_XX |
|--------------------------|----------|
| naka_extension_device.c  | 40       |
| naka_disk_menu_file_io.c | 19       |
| naka_effects_seq.c       | 16       |
| naka_style_bitmaps.c     | 13       |
| naka_ctrl_menu_body.c    | 12       |
| naka_disk_warning.c      | 11       |
| naka_perf_style.c        | 11       |
| 8 other files            | 19       |

## N-2f640c1d: untyped Viewable elements

- **The 16 IvDirmdScreen records of slots 0x30..0x3F** (cd67e8859).  includes/gui_display_struct_data.c had
  framed them 6 bytes early, as "display parameter records" plus a "17th record header".  The 6 bytes before
  them were the tail of NakaWidget_seamplfo1 (slot 0x2F).  `scripts/converters/naka_move_dirmd_screens_to_asm.py`
  moves them to the asm, where their siblings of slots 0x20..0x2F already are:
  - the blob starts 0x226 bytes later and is 4,611 bytes long instead of 5,161;
  - 108 `.incbin` offsets move by -0x226, and v7's divergence-json relocations by -550;
  - GUI_DisplayStructData, an unreferenced label 6 bytes into seamplfo1, goes;
  - `naka_asm_records.py --apply` writes the 17 records as NAKA_REC_IvDirmdScreen calls.

  GUI_DisplayStructData_0x226 is now Scoop_ViewableTable_020, the first block of its series
  (`rename_kn5000_naka2_viewable020.sed`).
- **15 more asm records** (a50867fdf).  `scripts/converters/naka_frame_text_records.py` handles the records
  whose text followed them under their own label, or whose zero fields were a `.zero`:
  - seven FDTest records of slot 0xFC;
  - five sound-menu entries and NakaWidget_SoundEdit of slot 0x2.

  It gives each text the label its siblings use (FDTest_String_<record>, MenuStr_<entry>) and writes `.zero` as
  `.long 0`.  Two more records were fixed separately:
  - ErrorDialog_CautionHeader began with the last 2 bytes of control_menu_screens.s; those bytes move after the
    file's `.include` (`scripts/converters/naka_join_caution_header.py`);
  - Toshi_NORMAL_Elem62 sits before that `.include`, so it was written by hand as its macro call.

Left: 13, all of them work-RAM view records of WorkRamInit_Image (slots 0xB5 elements 24-28, 0xB8 elements 18 /
26 / 27 / 30 / 31, 0xB9 elements 24 / 28 / 31; ROM image 0xEEDB58..0xEEDD35).  Next step: split
WorkRamInit_Image's `.byte` rows (ui_widgets/widget_dispatch.s) at the 13 record addresses, give each record a
label, and run `naka_asm_records.py --apply`.  This needs coordination.  `naka_gui_symbolize.py` names the
elements of every tree's object enums from the v10 label at the record's image address (`OBJ_s0B5_e24` today),
so the labels rename those constants in all five trees' C.  It can only land together with a
`naka_gui_symbolize.py --tree v6/v5 --apply` that the v6 / v5 lane runs, or after it.

## N-7c99f0f2: titles without a menu path

The path model is `scripts/analysis/naka_gui_model.py` (`add_code_edges`, `menu_paths`).  It now has two rules
for v10, v9 and v7 (`CALLEE_RULE_TREES`):

- **A title procedure's direct callees.**  The titles they open count as the procedure's own.  Menu-box
  functions already followed this rule.
  - StylCnvModlTtlFunc -> FloppyState_Dispatch opens the five Style Convert pages STYLCNVCNVT / STOR / TXT /
    SEL / CONT.
  - DkMdlyPlyTtlFunc -> PlayMode_CheckAndDispatch opens TITLE_SQMDLY, and SQMDLY's procedure ->
    FmmIntMedleyFunc opens TITLE_SQMDLYPLY.
- **Panel-switch handlers as roots.**  A root is a Function-table entry that is no title's procedure and whose
  own body names an `EVT_SW_IN*` event (`name_title_index_operands.routines_naming`).  It and its direct callees
  give the path 'panel switch handler F > (by R)', and mode paths keep precedence.  Eight such handlers exist,
  and they give one new path: TITLE_PMBKSEL, by PmBankNamingCheck -> BitMapOut_UpdateWidget_Finalize.
  - A wider first attempt took every NAKA_MAINFUNC_* entry as a root.  It gave six more paths, through
    ApPlaySyori, NoteEditSyori and FmmPdFileNameFunc.  None of those three handles a switch event, so how they
    are reached is not known, and they stay out.
  - `probes/unreached_openers.py` shows why deeper call chains were not used: the routine graph attributes
    fall-through code to the nearest entry above it, and 4-8-step chains through INTTR4_BytecodeSnippet /
    MainTitle_SetBootFlag are artefacts of that.
- **DemoSong_TitleCol.**  `name_title_index_operands.py`'s new `COMPUTED_LOADS` reads Demo_SelectEntry_DrawSecondary's
  `lda xbc, (DemoSong_TitleCol:24); ld a, (xbc+wa)` as TT_DEMOSTYLE / DEMOSOUND / DEMORHY / DEMOFEATURE.  These
  are the column's only bytes; `probes/demo_title_column.py` reads them from the ROM.  This resolves one
  unknown-path site (19 -> 18).  The key includes the instruction before the load, because `ld a, (xbc+wa)`
  occurs 8 times in that file.

Regenerated: `docs/gui/kn5000-menu-map.md` (3,904 lines) and the SCREEN headers of v10 / v9 / v7's C
(`naka_gui_symbolize.py --tree <t> --headers --apply`, comments only, compiled bins identical).

Left: 41 titles without a path.
- 23 are opened by code that no traced path reaches.
  - The self test (`SelfTest_FirmwareVersionCheck`: TEST1..6, EXT) and the SOFTVER boot combination.
  - The sequencer's play / edit code (ApPlaySyori: SQCYCPLY / SQCYCREC / SQMETBAL; the BmDrEdit_* routines:
    SQNOTEEDT / SQDRMEDT / SQNOTECYCP / SQDRMCYCP; Part_ValidateAndActivate: SQSTEP).
  - FmmPdMedleyFunc: DPPD / DPMDLYPD.
  - A few attributions to routines the call merely follows.
- 18 are opened by nothing found.

18 call sites still take the index from RAM or a table.  Next step: FileIO_ErrorCodeByteBlock's site (it opens
index 119, TITLE_DKMDLY, on its `cp a, 119; jr z` path, but Join2 has a second predecessor); the saved return
titles of the disk dialogs (RAM 0x7F6A / 0x7F6E / 0x808A / 0x843A: find their writers); then the boot self-test
entry, which is reached from the reset path and not from a Function table.

## What v6 / v5 need (lane v6v5-port3 owns their C and json)

This lane changed only these files of theirs: the sed renames (`rename_kn5000_naka2_audio_tracks.sed`,
`rename_kn5000_naka2_viewable020.sed`, applied to v6 / v5) and the generated naka_ram_cells.h, which
`gen_naka_gui_headers.py` writes for all five trees.  After their C / json are regenerated, add the tree to each
script's `--tree` choices and run, in order:

1. `naka_type_welcome_steps.py`, `naka_frame_song_grid_cells.py` (then `gen_naka_gui_headers.py`).
2. `naka_move_dirmd_screens_to_asm.py` (their json's relocations of `gui_display_struct_data.bin` move by -550,
   as v7's did), `naka_frame_text_records.py`, `naka_join_caution_header.py` and the Toshi_NORMAL_Elem62 macro
   line, then build and run `naka_asm_records.py --tree <t> --apply`.
3. The RAM names of `ram/audio_state_names.txt`: `add_kn5000_ram_names.py` covers v10 / v9 / v7 only;
   `scripts/converters/port_ram_names.py` ports them.
4. Add the tree to `CALLEE_RULE_TREES` in naka_gui_model.py and run `naka_gui_symbolize.py --tree <t> --headers
   --apply`.

## Scripts

| script                                                 | question it answers                                                              | command                                                                       |
|--------------------------------------------------------|----------------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| `scripts/tools/add_kn5000_ram_names.py`                | (fixed) leaves an end-of-record NAME+N alone                                     | `python3 scripts/tools/add_kn5000_ram_names.py <file>`                        |
| `ram/audio_state_names.txt`                            | the audio state words' names with their per-bit evidence                         | input of the line above                                                       |
| `scripts/converters/naka_type_welcome_steps.py`        | types the RAM 0x3EA0C saved-step slots of the work-RAM image                     | `python3 scripts/converters/naka_type_welcome_steps.py --tree v10`            |
| `scripts/converters/naka_frame_song_grid_cells.py`     | frames blob 0x18A2..0x18BD by the SONG1 / SONG2 records' cells                   | `python3 scripts/converters/naka_frame_song_grid_cells.py --tree v10`         |
| `scripts/converters/naka_move_dirmd_screens_to_asm.py` | moves the 16 IvDirmdScreen records + seamplfo1's tail from the C blob to the asm | `python3 scripts/converters/naka_move_dirmd_screens_to_asm.py --tree v10`     |
| `scripts/converters/naka_frame_text_records.py`        | gives FDTest / sound-menu record texts their own labels, `.zero` as `.long`      | `python3 scripts/converters/naka_frame_text_records.py --tree v10`            |
| `scripts/converters/naka_join_caution_header.py`       | puts ErrorDialog_CautionHeader in one file                                       | `python3 scripts/converters/naka_join_caution_header.py --tree v10`           |
| `scripts/analysis/naka_gui_model.py`                   | (extended) title-procedure callees, panel-switch handler roots                   | `python3 notes/kn5000-naka-2026-11-06/probes/menu_map_summary.py`             |
| `scripts/converters/name_title_index_operands.py`      | (extended) COMPUTED_LOADS; routines_naming                                       | `python3 scripts/converters/name_title_index_operands.py --tree v10 --report` |
| `probes/unreached_openers.py`                          | how the openers of titles with no path are reached (call graph upwards)          | `python3 notes/kn5000-naka2-2026-11-06/probes/unreached_openers.py`           |
| `probes/demo_title_column.py`                          | which titles Demo_SelectEntry_DrawSecondary can open                             | `python3 notes/kn5000-naka2-2026-11-06/probes/demo_title_column.py`           |

## Website page draft

**technics-docs `kn5000-menu-map.md`** (replaces wave 11's draft in notes/kn5000-naka-2026-11-06/README.md,
whose figures this supersedes).  Figures from `notes/kn5000-naka-2026-11-06/probes/menu_map_summary.py`.

1. Intro: "generated from program v10 on 2026-11-06" and "(3,904 lines)".  Add a sentence to the 2026-11-06
   paragraph:

   > A title procedure's direct callees count as the procedure (the Style Convert pages are opened by
   > `FloppyState_Dispatch`, which `StylCnvModlTtlFunc` calls), and a Function-table entry that handles a panel
   > switch event is a root of its own ("panel switch handler").

2. The count table becomes:

| what                                      | count |
|-------------------------------------------|-------|
| titles                                    | 211   |
| titles with a path                        | 170   |
| modes (each with a home title)            | 21    |
| titles one step below a home or a handler | 87    |
| titles two steps below a home             | 40    |
| titles three steps below a home           | 21    |
| titles four steps below a home            | 1     |
| widget records, in 18 C files             | 3,260 |
| menu entries                              | 99    |
| code transitions                          | 357   |
| EXIT links                                | 267   |

3. "Modes and their home screens": `MD_DISK`'s "titles below" becomes 34; the other rows are as in wave 11's draft.

4. "Titles with no path" becomes 41.  Its table keeps wave 11's rows except these eight, which now have paths:
   `TITLE_STYLCNVCNVT`, `TITLE_STYLCNVSTOR`, `TITLE_STYLCNVTXT`, `TITLE_STYLCNVSEL`, `TITLE_STYLCNVCONT`,
   `TITLE_SQMDLY`, `TITLE_SQMDLYPLY`, `TITLE_PMBKSEL`.  The intro becomes "23 of them are opened by code ...",
   and the closing sentence "18 call sites ...".

**technics-docs `memory-map.md`** (main-CPU RAM), new rows:

| address | name                    | what                                                                                         |
|---------|-------------------------|----------------------------------------------------------------------------------------------|
| 0xC598  | `AUDIO_SEQ_TRACK_FLAGS` | which sequencer tracks (play / record; CHORD, APC, RHYTHM) the voice routing must serve      |
| 0xC59A  | `AUDIO_VOICE_CHANGES`   | AudioInit_DispatchChanges' second change mask (voice config, priority table, tone refresh)   |
| 0xC59C  | `AUDIO_STATE_CHANGES`   | which parts of the 358-byte audio state at 0xC1FE AudioInit_DispatchChanges compares / sends |
| 0xC59E  | `AUDIO_REC_TRACK_SLOT`  | the slot of the first record track                                                           |
