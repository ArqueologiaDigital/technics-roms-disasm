# Lane kn5000-naka (wave 11, 2026-11-06): NAKA C debt, menu paths, audio flag words

Base main 2bde950fa, branch `open11/kn5000-naka`.  Items N-45db7885, N-2f640c1d, N-7c99f0f2, N-d8cf1242 (NAKA C, from
`notes/data-semantics-2026-10-29/gui-kn5000/README.md`) and N-51b2e19c (flag bytes, from
`notes/ram-naming-2026-10-24/README.md`), each continued from wave 10's next step
(`notes/kn5000-notes-2026-11-06/README.md`).  Addresses are v10 main-CPU addresses.  Every change is byte-identical
(`make gate`).

## Measurements

`python3 scripts/analysis/naka_gui_census.py` (rom addrs, field_XX, records),
`python3 notes/kn5000-notes-2026-11-06/probes/naka_untyped_elements.py` (untyped elements, v10),
`python3 notes/kn5000-notes-2026-11-06/probes/flag_byte_uses.py --tree v10` (flag bytes),
`python3 scripts/converters/name_title_index_operands.py --tree v10 --report` (unknown-path sites) and
`docs/gui/kn5000-menu-map.md`'s summary line (titles).  Before = main 2bde950fa.

| measure                                              | v10 / v9 before | v10 / v9 after | v7 before | v7 after | v6 / v5 (not touched) |
|------------------------------------------------------|-----------------|----------------|-----------|----------|-----------------------|
| rom addrs (numeric ROM addresses in the NAKA C)      | 1               | 0              | 1         | 0        | 7                     |
| field_XX members                                     | 434             | 163            | 442       | 171      | 381                   |
| widget records typed in the C                        | 3,259           | 3,260          | 3,259     | 3,260    | 3,250                 |
| untyped Viewable elements (v10, probe's old rule)    | 52              | 49             | -         | -        | -                     |
| untyped Viewable elements (v10, probe's new rule)    | -               | 45             | -         | -        | -                     |
| title-by-index call sites with an unknown path (v10) | 20              | 19             | -         | -        | -                     |
| titles with a menu path (of 211, v10)                | 158             | 162            | -         | -        | -                     |
| numeric uses of the N-51b2e19c flag bytes (v10)      | 747             | 611            | -         | -        | -                     |

The probe's rule change: `naka_untyped_elements.py` took a NAKA_REC_ macro call as the record's typing only when it
followed its label after at most one line break; 4 records in naka_sound_technichord_dispatch.s have comment lines
between (NakaMenuItem_Mixer and three more), so it counted them as untyped.  The pattern now allows comment and blank
lines; at this lane's head the old rule gives 49, the new one 45.

## N-45db7885 and N-2f640c1d: the three blob-edge records

- **NakaWidget_Perf3RhythmSel** (PsWideToggle, element 9 of Viewable slot 0xE3): its first 34 bytes were
  `naka_dispatch_t w119` + `pad_482` + two words at the end of naka_direct_play.c, its last 8 the first member of
  naka_widget_tables_1.c.  So `.inst_ptr = 0x00F40008` (the last numeric ROM address of the v10 / v9 / v7 C) was the
  flag word 0x0008 and rect x1 = 244, and `.proc_addr = NAKA_ADDR(INTETC45)` (an SFR, 0xEE) was rect y2 = 238 and the
  font.  `scripts/converters/naka_join_perf3rhythmsel.py` moves the blob boundary 8 bytes up: naka_direct_play
  12250 -> 12258 bytes with one `naka_cls_PsWideToggle_t`, naka_widget_tables_1 BASE 0xE24056 -> 0xE2405E (206
  `.incbin` offsets -8; v7's divergence-json size follows).
- Its two "RHYTHM" captions were named the wrong way round.  The class's propnames (naka_classes.h, from the firmware's
  own Class tables) put `stron` at +26 and `stroff` at +30; the record's +26 word is the second text, as elements 7
  and 8 point `stroff` at their first text and `stron` at their second.  `scripts/renaming/rename_kn5000_naka_perf3rhythm.sed`
  swaps `NakaWidget_Perf3RhythmSel_StrOn` / `_StrOff` in all five trees.
- **NakaWidget_N1** (Window, element 24 of slot 0x1; 22 bytes at the end of naka_normal_mode.c + 14 in
  extensions/extension_data.s) and **NakaWidget_SdmenuPage** (AcWindowPage, element 1 of slot 0x2; `str_63 = "%"`, the
  class id's low word read as a string, `field_0906 = 0x0160` and `pad_1` at the end of naka_sound_menu_drawbar.c + 30
  bytes in naka_sound_technichord_dispatch.s).  Their siblings are NAKA_REC_ calls in those asm files, so
  `scripts/converters/naka_move_edge_heads_to_asm.py` moves the heads there (the blobs end 22 / 6 bytes earlier) and
  `naka_asm_records.py --apply` writes each as one macro call.

No record is cut by a blob edge any more.  The 45 untyped elements left (new rule) are all in the asm:

| where                                                                   | count | why the asm-record tool skips them                                   |
|-------------------------------------------------------------------------|-------|----------------------------------------------------------------------|
| `gui_display_struct_data.c` (IvDirmdScreen, slots 0x30..0x3F)           | 16    | inside a C blob whose 34-byte "display records" are framed 6 B early |
| `includes/gui_format_strings.s` NakaWidget_seamplfo1 (slot 0x2F)        | 1     | its last 6 bytes are the first 6 of gui_display_struct_data.bin      |
| work-RAM view records of WorkRamInit_Image (slots 0xB5 / 0xB8 / 0xB9)   | 13    | DRAM records, no label at their ROM image                            |
| FDTest (slot 0xFC), ErrorDialog_CautionHeader (0xF4)                    | 10    | blocks hold strings / `naka_header` lines, or 2 of 32 bytes          |
| slot 0x2 (NakaWidget_SoundEdit, Toshi_NORMAL_Elem62 and the menu items) | 5     | `.byte` / `.zero` / `.include` lines in the block                    |

Next step for the 17 IvDirmdScreen records: retype `includes/gui_display_struct_data.c`'s `display_records[16]`
(34-byte `gui_display_record_t`, framed from blob offset 0) as `uint8_t NakaWidget_seamplfo1_Tail[6]` + 16
`naka_cls_IvDirmdScreen_t` from offset 6 (the compile rule needs `-I <tree>/maincpu/ui_widgets` for naka_classes.h),
then move seamplfo1's 6-byte tail into gui_format_strings.s the same way as N1's head.

## N-7c99f0f2: titles without a menu path

- `SeMenu_GoToPageOnEnabledPart` (audio/semenu_routines.s) is a stack forwarder: `ld (xsp+6), a`, makes sure the current
  part is enabled, then `ld a, (xsp+6); ld bc, 0` -> `SeMenu_SendEvent` on all three paths.  Its callers' 61 / 38 / 32
  are now TT_SECOPY, TT_SETONHYB1 and TT_SEMENU.
- The filter page's type step (`UpdSeSel_DetailedUpdate`, audio/sound_editor_ui.s): A = the part's filter-type byte;
  for 2..5 `dec 1, a; ld (xbc), a; add a, TT_SEFILLPQ1` (was `add a, 48`) and `SeMenu_SendEvent` with C = 0, i.e.
  TT_SEFILHPQ1 / SEFILL241 / SEFILH241 / SEFILBPF1; type 0 opens TT_SEFILBCF1 (a constant), type 1 redraws the LPQ1
  page in place.  `name_title_index_operands.py` has a `COMPUTED` table for index registers the code computes.
- `gen_naka_menu_map.py` now names, for a title with no path, the routines that open it ("Opened by code in").

Titles with a path 158 -> 162 (53 -> 49 without); 31 of the 49 are opened by code that no traced path reaches (panel-button
handlers, the self test, the sequencer's play-mode code; e.g. `TITLE_TEST1..6` by `SelfTest_FirmwareVersionCheck`;
the routine is the nearest routine entry above the call, so an attribution can name a routine the call merely
follows), 18 by nothing found.  None of the 19
unknown-path sites left loads a constant: DirmdEmulator's pending title 0xE3DC (2 sites), tables (`DemoSong_TitleCol`,
`FileIO_ErrorCodeByteBlock_Entry_Data`), the two stack forwarders' own bodies (`DiskEvt_PostModeEvent`,
`DiskCap_PostModeEvent`), and the cancel / success paths of the disk dialogs (FmmFmt, FmmLoadTtl, FmmUtility,
FmmSmfUtility, SmfLoad, SmfMed), which go back to a title saved in RAM (0x7F6A, 0x7F6E, 0x808A, 0x843A) or passed in A.  Next step: make the panel-button handlers roots of the path search
(each title-opening handler is reached from `EVT_SW_IN_*` / the DefaultFunction), and read `DemoSong_TitleCol`'s
bytes as the titles `Demo_SelectEntry_DrawSecondary` opens.

## N-d8cf1242: field_XX

naka_sequencer_channels.c is the work-RAM image `Boot_InitWorkRAM` (boot/system_handlers.s) copies from ROM 0xEED8C8 to
RAM 0x3D524 (0x219E bytes) and from 0xEEFA66 to RAM 0xE35E (0x95B), so a member at blob offset o is the power-on value
of RAM 0x3D524 + (0xEEE078 + o - 0xEED8C8), and its readers are the code that addresses that RAM.

- `scripts/converters/naka_type_trackmixer_map.py`: `TrackMixer_ColumnPartMap[26]` (RAM 0x3EBE8; TrackMixer_Init
  installs it as the PsMixer grid array, TrackMixer_UpdateHandler writes word [track]) and
  `ChordName_TypeRootTables[64]` (RAM 0x3F2F8; MainChordPre_AppendChordSuffix follows [type], [root], [bass]): 152
  members.
- `scripts/converters/naka_widen_ram_cells.py`: the live-value cells of propdata letters r / s (pSlongProc /
  pUlongProc, SupportClass_PropTypeRecords entries 'r'-'A' / 's'-'A' read from the ROM) are 32-bit; the C had each as
  `uint16_t <Record>_<Field>` + `uint16_t field_XXXX`.  117 pairs merged (Window / TtlScreen `window`, `parent`,
  `child` ...), each checked: RAM_<name>'s value is the member's RAM address and every field that names or holds it
  has letter r or s.

field_XX 434 -> 163 (v10 / v9), 442 -> 171 (v7).  Left in naka_sequencer_channels.c: 22 (`field_0d3c`'s 12-member run at
RAM 0x3EA10, just before the PsMixer array-base cells 0x3EA30 / 0x3EA34, and 10 odd-aligned words at blob 0x18A3..0x18B9,
RAM 0x3F577..); 141 in the other files (`naka_gui_census.py --files v10`).  (The widening script's 11 skipped "pairs" are two
field_XX words of these runs, which no RAM_ cell names.)  Next step: the 0x3EA10 run (read the PsMixer code around
Util_StorePartArrayBase / Util_StoreGridArrayBase), then the other files' members with
`naka_gui_census.py --files v10`.

## N-51b2e19c: flag bytes

`ram/audio_config_names.txt`, applied with `scripts/tools/add_kn5000_ram_names.py` (v10 / v9 / v7):

- 0xC594 `AUDIO_CONFIG_UPDATE`: bit 2 = re-apply the audio configuration (35 setters, consumed by
  AudioInit_ProcessModeChange); bit 4 = MimeSyori's EVT_SET_PARAM state (AudioMode_ConfigureExternal); bits 0 / 1.
- 0xC596 `AUDIO_CONFIG_FLAGS`: bits 0-2 = the AUTO PLAY CHORD recognizer, one-hot (ONE FINGER, FINGERED, PIANIST;
  open6 note A6), from PANEL_STYLE+3 through ParamEdit_WordTable; bit 4 = PANEL_STYLE+3 bit 3 (APC memory); bits 10 / 11
  = PANEL_STYLE+4 bits 6 / 4; bits 8, 9, 13 and 3 / 5 / 7 by their writers and readers (the name's comment lists them).
- `PanelTag48_UpdateAudioConfig_StyleNumber` is switch entry 3 of the record-0x48 listener, the PANEL_STYLE+3 arm:
  renamed `PanelTag48_UpdateAudioConfig_ApcMode` (`scripts/renaming/rename_kn5000_naka_paneltag48.sed`, five trees).

A tool side effect to know: `add_kn5000_ram_names.py`'s record pass (step 5) re-spells operands of every `[N bytes]`
record, and turned wave 10's loop ends `ACC_BASS_NOTES+72` into `ACC_ACCOMP1_NOTES` (and the like, 5 hunks per tree in
accompaniment_engine.s, 3 in rhythm_routines.s).  Those hunks were reverted by hand.

Numeric uses 747 -> 611.  Left: 0xC1FE, 0xC598 (the sound-group status word Audio_CheckInitStatus clears and the
AudioInit_* group checks set), 0xC59C, 0x28B2 / 0x28B3, 0x34CD, 0x35B0, 0xE3E2.  Next step: 0xC598 per bit (its writers
are AudioInit_GroupA_* / GroupB_*: what the sound groups A / B and types 0x0E / 0x10 are).

## Website page draft

**technics-docs `kn5000-menu-map.md`** (its tables and "Titles with no path" list are of 2026-10-29).  Figures from
`probes/menu_map_summary.py`, which reads the model `gen_naka_menu_map.py` writes `docs/gui/kn5000-menu-map.md` from.

1. Intro, "The numbers below are that file's, generated from program v10 on 2026-10-29.": make it "on 2026-11-06", and
   "(about 200 KB, 3,861 lines)" -> "(3,912 lines)".  Replace the paragraph "**Since 2026-11-06 the generated file reads
   further** ... still those of 2026-10-29." with:

   > Since 2026-11-06 the sound editor's pages (`TITLE_SE*`, DirmdEmulator screens) are modelled through their method
   > tables and switch handlers, `SeMenu_SendEvent` and `SeMenu_GoToPageOnEnabledPart` are traced as title openers, and
   > the filter page's type step is read (its type 2..5 opens `TITLE_SEFILHPQ1` / `SEFILL241` / `SEFILH241` /
   > `SEFILBPF1`).  For a title no path reaches, the generated file names the code that opens it.

2. The count table becomes:

   | what                            | count |
   |---------------------------------|-------|
   | titles                          | 211   |
   | titles with a path              | 162   |
   | modes (each with a home title)  | 21    |
   | titles one step below a home    | 86    |
   | titles two steps below a home   | 40    |
   | titles three steps below a home | 15    |
   | widget records, in 18 C files   | 3,260 |
   | menu entries                    | 99    |
   | code transitions                | 282   |
   | EXIT links                      | 267   |

3. "Modes and their home screens": `MD_SOUNDEDIT`'s "titles below" 0 -> 32; the other rows are unchanged.

4. Replace the section "## Titles with no path (81)" (its intro, group table and the two paragraphs after it) with:

   > ## Titles with no path (49)
   >
   > 31 of them are opened by code, but by code that no traced path reaches: panel-button handlers, the self test, the
   > sequencer's play modes.  The routine named is the nearest routine entry above the opening call.
   >
   > | title               | opened by code in                                                                            |
   > |---------------------|----------------------------------------------------------------------------------------------|
   > | `TITLE_SDOCT`       | `MidiPartGridCheck`                                                                          |
   > | `TITLE_STYLCNVCNVT` | `FloppyState_Dispatch`, `TableData_JumpToEntry`                                              |
   > | `TITLE_STYLCNVSTOR` | `FloppyState_Dispatch`                                                                       |
   > | `TITLE_STYLCNVTXT`  | `FloppyState_Dispatch`                                                                       |
   > | `TITLE_STYLCNVSEL`  | `FloppyState_Dispatch`                                                                       |
   > | `TITLE_STYLCNVCONT` | `AccBankData_ProcessWithCopy`, `FloppyState_Dispatch`                                        |
   > | `TITLE_DPPD`        | `FmmPdMedleyFunc`                                                                            |
   > | `TITLE_DPMDLYPD`    | `FmmPdMedleyFunc`                                                                            |
   > | `TITLE_SQMDLY`      | `PlayMode_CheckAndDispatch`, `PlayMode_StartAndSendCommand`, `SeqRestart_SendPlaybackNotify` |
   > | `TITLE_SQMDLYPLY`   | `FmmIntMedleyFunc`                                                                           |
   > | `TITLE_SQCYCPLY`    | `ApPlaySyori`                                                                                |
   > | `TITLE_SQCYCREC`    | `ApPlaySyori`                                                                                |
   > | `TITLE_SQSTEP`      | `Part_ValidateAndActivate`                                                                   |
   > | `TITLE_SQNOTEEDT`   | `BmDrEdit_SaveSequencerState`                                                                |
   > | `TITLE_SQNOTECYCP`  | `BmDrEdit_PostModeChange96`                                                                  |
   > | `TITLE_SQDRMEDT`    | `BmDrEdit_SaveSequencerState`, `SeMenu_HandleMenuChange`                                     |
   > | `TITLE_SQDRMCYCP`   | `BmDrEdit_PostModeChange99`                                                                  |
   > | `TITLE_SQSTEPBAL`   | `UIDisp_StepMeasure`                                                                         |
   > | `TITLE_SQMETBAL`    | `ApPlaySyori`                                                                                |
   > | `TITLE_MUSICSTYL`   | `EffectMode_CopyVoiceParams`                                                                 |
   > | `TITLE_MSPBKSL`     | `AccompSeq_ProcessAfterNote_Helper`, `SoundCtrl_CalcScaledTempo`                             |
   > | `TITLE_PMBKSEL`     | `BitMapOut_UpdateWidget_Finalize`                                                            |
   > | `TITLE_APCSEL`      | `SoundCtrl_CalcScaledTempo`                                                                  |
   > | `TITLE_SOFTVER`     | `Boot_HandleComboDisplay`, `MainTitle_PrepareAndDispatch`                                    |
   > | `TITLE_TEST1`       | `SelfTest_FirmwareVersionCheck`                                                              |
   > | `TITLE_TEST2`       | `SelfTest_FirmwareVersionCheck`                                                              |
   > | `TITLE_TEST3`       | `SelfTest_FirmwareVersionCheck`                                                              |
   > | `TITLE_TEST4`       | `SelfTest_FirmwareVersionCheck`                                                              |
   > | `TITLE_TEST5`       | `SelfTest_FirmwareVersionCheck`                                                              |
   > | `TITLE_TEST6`       | `SelfTest_FirmwareVersionCheck`                                                              |
   > | `TITLE_EXT`         | `SelfTest_FirmwareVersionCheck`                                                              |
   >
   > For the other 18 no opener was found: `TITLE_CTPMPARA`, `TITLE_SQPUNCHM`, `TITLE_CMPLD`, `TITLE_CMMODE`, `TITLE_MSCTSEL`, `TITLE_MSSCTSEL`, `TITLE_MSSONGLIST`, `TITLE_MSALPSEL`, `TITLE_PMVIEW`, `TITLE_PMNAME`, `TITLE_PMBKNAME`, `TITLE_SVARI`, `TITLE_RVARI`, `TITLE_ACCORDION`, `TITLE_SPLITSEL`, `TITLE_WELCOM`, `0x01A000FC`, `TITLE_FDMSP`.  19 call
   > sites take the title index from RAM or a table (DirmdEmulator's pending title, the saved return titles of the disk
   > dialogs, `DemoSong_TitleCol`), which the tracer does not follow, so some of these may be opened there.

## What v6 / v5 need (lane v6v5-port2 owns their C and json)

Run after their C-divergence json is regenerated (`ported_c_rebase.py --regen`), with the tree added to each script's
`--tree` choices: `naka_join_perf3rhythmsel.py` (their `w119`), `naka_move_edge_heads_to_asm.py`,
`naka_type_trackmixer_map.py`, `naka_widen_ram_cells.py`; `name_title_index_operands.py --tree v6 --apply` (3
operands) and the `add a, TT_SEFILLPQ1` respelling in sound_editor_ui.s; AUDIO_CONFIG_UPDATE / AUDIO_CONFIG_FLAGS
(`add_kn5000_ram_names.py` covers v10 / v9 / v7 only).  The two sed renames of this lane were applied to v6 / v5.

## Scripts

| script                                              | question it answers                                                             | command                                                                   |
|-----------------------------------------------------|---------------------------------------------------------------------------------|---------------------------------------------------------------------------|
| `scripts/converters/naka_join_perf3rhythmsel.py`    | types the PsWideToggle split across naka_direct_play.c / naka_widget_tables_1.c | `python3 scripts/converters/naka_join_perf3rhythmsel.py --tree v10`       |
| `scripts/converters/naka_move_edge_heads_to_asm.py` | moves the heads of the two records a C blob end cuts into the asm               | `python3 scripts/converters/naka_move_edge_heads_to_asm.py --tree v10`    |
| `scripts/converters/naka_type_trackmixer_map.py`    | types work-RAM image runs of naka_sequencer_channels.c from their RAM readers   | `python3 scripts/converters/naka_type_trackmixer_map.py --tree v10`       |
| `scripts/converters/naka_widen_ram_cells.py`        | merges the 32-bit (letter r / s) RAM cells cut as two u16 members               | `python3 scripts/converters/naka_widen_ram_cells.py --tree v10 --dry-run` |
| `scripts/converters/name_title_index_operands.py`   | (extended) GoToPage forwarder, COMPUTED index registers                         | `python3 scripts/converters/name_title_index_operands.py --report`        |
| `scripts/generators/gen_naka_menu_map.py`           | (extended) names the openers of titles with no path                             | `python3 scripts/generators/gen_naka_menu_map.py`                         |
| `probes/menu_map_summary.py`                        | the figures of the website's KN5000 Menu Map summary                            | `python3 notes/kn5000-naka-2026-11-06/probes/menu_map_summary.py`         |
| `ram/audio_config_names.txt`                        | RAM names with their per-bit evidence, input of add_kn5000_ram_names.py         | `python3 scripts/tools/add_kn5000_ram_names.py <file>`                    |
