# Lane kn5000-naka3 (wave 13, 2026-11-07): work-RAM view records, menu paths, field_XX, sequencer and audio state

Base main 92b5cc4a7 (main 627cf63de merged before the gates), branch `open14/kn5000-naka3`.  Items
N-2f640c1d, N-7c99f0f2, N-d8cf1242 and N-51b2e19c, each continued from wave 12's next step
(`notes/kn5000-naka2-2026-11-06/README.md`).  Addresses are v10 main-CPU addresses unless a tree is named.
Every change is byte-identical in all six main-CPU images (`make gate`).

## Measurements

Before = main 92b5cc4a7, after = this lane's head.

| measure                                          | before  | after   | instrument                                                                    |
|--------------------------------------------------|---------|---------|-------------------------------------------------------------------------------|
| untyped Viewable elements (v10)                  | 13      | 0       | `python3 notes/kn5000-notes-2026-11-06/probes/naka_untyped_elements.py`       |
| field_XX members, v10 / v9                       | 141     | 112     | `python3 scripts/analysis/naka_gui_census.py`                                 |
| field_XX members, v7                             | 149     | 123     | same                                                                          |
| field_XX members, v6 / v5                        | 171     | 145     | same                                                                          |
| field_XX in naka_extension_device.c (v10)        | 40      | 15      | `python3 scripts/analysis/naka_gui_census.py --files v10`                     |
| titles with a menu path (of 211, v10)            | 170     | 179     | `python3 notes/kn5000-naka-2026-11-06/probes/menu_map_summary.py`             |
| titles without a path / opened by unreached code | 41 / 23 | 32 / 15 | same                                                                          |
| code transitions                                 | 357     | 361     | same                                                                          |
| title-by-index call sites with an unknown path   | 18      | 5       | `python3 scripts/converters/name_title_index_operands.py --tree v10 --report` |
| numeric uses of the N-51b2e19c flag bytes (v10)  | 484     | 226     | `python3 notes/kn5000-notes-2026-11-06/probes/flag_byte_uses.py --tree v10`   |

## N-2f640c1d: the 13 work-RAM view records (a4f943242)

Slots 0xB5 (CmpRealScreen), 0xB8 (CmpNcpScreen) and 0xB9 (S2CScreen) register 13 elements at DRAM
0x3D7B4..0x3D991.  Boot_InitWorkRAM copies WorkRamInit_Image to DRAM 0x3D524 at reset, so each record's power-on
bytes are the image bytes at the same offset.

- `scripts/converters/naka_frame_wram_view_records.py` splits WorkRamInit_Image's `.byte` rows
  (ui_widgets/widget_dispatch.s) at the 13 record addresses, under labels named like their siblings
  (`CmpRealScreen_AcCmpRecBox` .. `_5`, `CmpNcpScreen_PsCmpCpFPtnBox`, `_PsNameMemBox`, `_AcMemNoBox`,
  `_PsCmpCpFGrpBox`, `_PsCmpCpFVariBox`, `S2CScreen_PsS2cTransBox`, `_PsS2cFmeasBox`, `_PsS2cLmeasBox`).  It checks
  the class id at each start, that the records tile the range and that the rows hold the ROM's bytes.
- `naka_asm_records.py --gen / --apply` then wrote the 13 NAKA_REC_ calls, and `naka_gui_symbolize.py --apply`
  renamed OBJ_s0B5_e24 .. OBJ_s0B9_e31 in all five trees' C.
- `naka_gui_model.rom_image_of` now takes the tree (`work_ram_images` reads each tree's Boot_InitWorkRAM).  v6 / v5
  place the images at 0xEED7CC / 0xEED7B4 and copy 0x219A bytes, v7's second image is (0xE2C2, 0x931).  With
  v10's constants, v6 / v5's naka_gui.s had named slot 0xB8 elements 26 / 31 IDX_RamInit_NumStrPtrs /
  IDX_RamInit_MajorMinorPtrs and lacked 15 DRAM elements' IDX_ names.  Both are fixed (nothing used them).

Closed: no untyped Viewable element is left.

## N-7c99f0f2: titles without a menu path (8168bbc33)

- **Compare guards** (`name_title_index_operands.guard_value`).  `cp a, K; jr z` taken, or `jr nz` not taken,
  means A == K on that edge.  FileIO_ErrorCodeByteBlock reaches UI_ChangeTitleByIndex only that way on both its
  paths (FileIO_ErrorCodeByteBlock_Skip5 and _Skip7 both follow `cp a, 119; jr z`), so both compares now read
  `cp a, TT_DKMDLY` (all five trees).
- **Return-title cells** (`return_cells`).  Six RAM cells are written only from PREVIOUS_TITLE when a dialog's
  title procedure is activated (`ldmm8 CELL, PREVIOUS_TITLE`, or `ld a, (PREVIOUS_TITLE); ld (CELL), a`):

| cell   | written by                                   | read by                                       |
|--------|----------------------------------------------|-----------------------------------------------|
| 0x7F5C | title_handlers.s line 100 (utility page)     | FmmUtility_HandleCancel / _HandleSuccess      |
| 0x7F5E | title_handlers.s line 232 (SMF utility page) | FmmSmfUtility_HandleCancel / _HandleSuccess   |
| 0x7F6A | FmmFormatFunc                                | FmmFmt_HandleProgress / _HandleAbort / _Final |
| 0x7F6E | the disk-load title procedure (FmmLoadTtl)   | FmmLoadTtl_StateCancelLoad / _StateSuccess    |
| 0x808A | SmfLoad's activation                         | SmfLoad_AbortPartial / SmfLoad_Success        |
| 0x843A | SmfMed's EVT_ACTIVATE_STATE arm              | SmfMed_CallPauseMode                          |

  Opening the title in such a cell goes back to the opener, which has its own path.  The 12 sites now count as
  "returns to the opener" instead of unknown, and they add no edge.
- **The boot sequence is a root** (`naka_gui_model.BOOT_ENTRY`).  User_didnt_request_flash_mem_update, the reset
  path's main boot routine (kn5000_v10_program.s), calls SelfTest_FirmwareVersionCheck and
  Boot_HandleComboDisplay directly.  Their titles (TEST1..6, EXT, title 0xFC; SOFTVER) get the path
  'power-on boot sequence User_didnt_request_flash_mem_update > (by R)'.

Regenerated: `docs/gui/kn5000-menu-map.md` (3,896 lines) and v10 / v9 / v7's SCREEN headers.

Left: 32 titles without a path.  15 are opened by code that no traced path reaches, among them the sequencer's
play / edit code (ApPlaySyori: SQCYCPLY / SQCYCREC / SQMETBAL; BmDrEdit_*; Part_ValidateAndActivate: SQSTEP)
and FmmPdMedleyFunc (DPPD / DPMDLYPD).  17 are opened by nothing found.  5 sites still take the index from RAM
or the stack: DirmdEmu_CheckModeChange / _CheckSoundCtrl (RAM 0xE3DC), SeMenu_GoToPageOnEnabledPart_Join4,
DiskEvt_PostModeEvent and DiskCap_PostModeEvent (the caller's stack arguments).

Next step: an edge rule for ApPlaySyori's event handlers.  A widget's ApFunction posts an event to ApPlaySyori,
and the handler opens a title.  Example: TT_SQREALREC's MetRecSw has func MetroOnOffFunc, which posts
EVT_SET_METRO; ApPlaySyori_OnSetMetro then opens TT_SQMETBAL (see N-51b2e19c below).  SQCYCPLY / SQCYCREC are
probably reached the same way.  Then the stack-argument sites (DiskEvt / DiskCap).

## N-d8cf1242: field_XX (23caaee66)

`scripts/converters/naka_frame_c_by_asm_slices.py` retypes a run of field_XXXX members when the .s files
already cut the same bytes into labelled slices that have a header comment (the evidence):
- one member per slice, named after the slice label, with the header's description as its comment;
- text becomes a string literal (ALIGNED_STRING when a 0xFF pad follows), a 1-byte slice or a count becomes a
  scalar, and a u16 table becomes uint16_t.

It refuses slices without a header, pointer slices and symbolic initializers.  It writes a file only when its
compiled bytes are unchanged; the values come from compiling the tree's current C, before any C-divergence
patch.  Examples:
- naka_extension_device.c: PanelButton_SoundGroupCodes_RightSeg1 / _RightSeg2,
  PanelButton_RhythmGroupCodes_LeftSeg0 / _LeftSeg6, PanelButton_MspBank17FuncCodes / 18FuncCodes,
  PanelButton_VariationCodes;
- naka_disk_warning.c: GetSoundName_Str_DashedName, VwUserBitmapByName_Str_BmpExt;
- naka_technichord_strings.c: SingleLoadSrc_PanelMemEntryCount.

Left (v10): 112 field_XX.  92 of them lie in slices that have no header, and 18 in no slice; the script's
summary line counts them.  Next step: write headers, with their readers, for the slices of
naka_disk_menu_file_io.c (19) and naka_effects_seq.c (16), then rerun the script.  For example, in
naka_extension_device.c, FileIO_BytecodeData_Data_12 (+0x3594) and ExtDevScreen_UserInitWallpaper_Flag (+0x3788)
are slices with no header.

## N-51b2e19c: flag bytes (0578eb2ce, 862b5497a)

`ram/seq_flag_names.txt` and `ram/audio_state_record.txt` hold the names with their evidence.  They were applied
with `scripts/tools/add_kn5000_ram_names.py` (v10 / v9 / v7) and `scripts/converters/port_ram_names.py` (v6, v5).
That port also carried wave 12's four AUDIO_* words to v6 / v5.  The per-bit lists come from
`probes/flag_bit_ops.py`.

- **0x28B2 `SEQ_METRO_FLAGS`.**
  - bit 0 = the METRONOME switch of the four record pages (MetRecSw / MetPunchSw / MetPunchmSw, func
    MetroOnOffFunc).  MetroOnOffFunc posts EVT_SET_METRO (MT_SetMetro) to ApPlaySyori, and the handler stores
    the state.  That handler was NoteEditSy_ModeScroll, which the event-code catalogue already called misnamed;
    it is now `ApPlaySyori_OnSetMetro` (`scripts/renaming/rename_kn5000_naka3_metro.sed`, its locals too).
  - bit 1 = the take starts with the metronome count-in.  It is set with bit 0 when recording starts, and
    SEQ_START_MEASURE is saved for the stop.
  - bit 2 = the count-in runs: measure -2, then -1 (SeqPlay_CountInToLastBar).  SeqPlay_CountInEnd ends record
    standby on the last beat.
  - bit 7 is only cleared; bits 3-6 are untouched.
- **0x28B3 `SEQ_CONTROL_FLAGS`.**
  - bit 0 = a redraw is due;
  - bit 1 = recording was started by a start request;
  - bit 2 = a restart check is due after a stop;
  - bit 3 = record standby: tracks are armed but recording has not begun.  This is why Audio_CheckInitStatus
    drops AUDIO_SEQ_TRACK_FLAGS bit 9;
  - bit 4 = the buffers are to be re-initialised when the sequencer is idle;
  - bit 5 is tested and cleared but never set;
  - bit 6 is set but never read.
- **0xC1FE `AUDIO_STATE` and 0xC364 `AUDIO_STATE_SENT`, `[358 bytes]` each.**  This is the decision wave 12 left
  open, and it is yes.  AudioInit_DispatchChanges compares the parts its change masks name and sends what
  differs.  AudioInit_Dispatch_Finalize then copies all 179 words over the sent copy, so the two blocks share
  one layout and a field reads AUDIO_STATE+k / AUDIO_STATE_SENT+k.  The RECORD+offset spelling covers 635 / 606 /
  635 / 633 / 629 operands (v10 / v9 / v7 / v6 / v5).  For v6 / v5 it comes from the new
  `scripts/tools/spell_named_records.py`, which runs add_kn5000_ram_names' step 5 for chosen records only.

Left: 0x34CD (67 numeric uses), 0x35B0 (77) and 0xE3E2 (82).  Next step: name them per bit from
`python3 notes/kn5000-naka3-2026-11-07/probes/flag_bit_ops.py 0x34cd 0x35b0 0xe3e2`.  0x35B0 bit 0 is set by
the ToneBank_* copy routines and tested by RhythmROM_LoadDrumKit / AccWidget_ProcessSpecialCmd.  Bit 2 is cleared
by the VoiceSlot_Resolve_* and AccSection_ProcessEntry_* arms and set by AccFill_ProcessEntry.  Then the fields
inside AUDIO_STATE (AUDIO_STATE+1 = the record track's slot, +4, +36, +182 .. the most used).

## Scripts

| script                                                 | question it answers                                             | command                                                                         |
|--------------------------------------------------------|-----------------------------------------------------------------|---------------------------------------------------------------------------------|
| `scripts/converters/naka_frame_wram_view_records.py`   | which image bytes are the 13 DRAM view records; labels them     | `python3 scripts/converters/naka_frame_wram_view_records.py --tree v10`         |
| `scripts/analysis/naka_gui_model.py`                   | (extended) per-tree work-RAM images; the boot-sequence root     | `python3 notes/kn5000-naka-2026-11-06/probes/menu_map_summary.py`               |
| `scripts/converters/name_title_index_operands.py`      | (extended) compare guards; return-title cells                   | `python3 scripts/converters/name_title_index_operands.py --tree v10 --report`   |
| `scripts/converters/naka_frame_c_by_asm_slices.py`     | which field_XX words are documented asm slices; retypes them    | `python3 scripts/converters/naka_frame_c_by_asm_slices.py --tree v10 [--apply]` |
| `scripts/tools/spell_named_records.py`                 | RECORD+offset spelling for chosen records of any tree (v6 / v5) | `python3 scripts/tools/spell_named_records.py v6 AUDIO_STATE AUDIO_STATE_SENT`  |
| `probes/flag_bit_ops.py`                               | which routines set, clear and test each bit of a RAM flag byte  | `python3 notes/kn5000-naka3-2026-11-07/probes/flag_bit_ops.py 0x28b2 0x28b3`    |
| `ram/seq_flag_names.txt`, `ram/audio_state_record.txt` | the names with their per-bit evidence                           | input of `scripts/tools/add_kn5000_ram_names.py`                                |

## Website page draft

**technics-docs `kn5000-menu-map.md`** (replaces wave 12's draft in notes/kn5000-naka2-2026-11-06/README.md).
Figures from `notes/kn5000-naka-2026-11-06/probes/menu_map_summary.py`.

1. Intro: "generated from program v10 on 2026-11-07" and "(3,896 lines)".  Add to the paragraph on the path
   rules:

   > The boot sequence is a root as well: the titles the power-on self test and the boot key combinations open
   > (TEST1..6, EXT, SOFTVER) have the path "power-on boot sequence".  A dialog that returns to the title it was
   > opened from (the title saved from PREVIOUS_TITLE when it opens) adds no transition.

2. The count table becomes:

| what                                   | count |
|----------------------------------------|-------|
| titles                                 | 211   |
| titles with a path                     | 179   |
| modes (each with a home title)         | 21    |
| titles one step below a home or a root | 96    |
| titles two steps below a home          | 40    |
| titles three steps below a home        | 21    |
| titles four steps below a home         | 1     |
| widget records, in 18 C files          | 3,260 |
| menu entries                           | 99    |
| code transitions                       | 361   |
| EXIT links                             | 267   |

3. "Titles with no path" becomes 32.  The intro becomes "15 of them are opened by code no traced path reaches,
   17 by nothing found", and the closing sentence "5 call sites take the title from RAM or from the caller's stack".
   These rows are dropped from its table: `TITLE_SOFTVER`, `TITLE_TEST1` .. `TITLE_TEST6`, `TITLE_EXT`; and
   `0x01A000FC` from "no opener found".

**technics-docs `memory-map.md`** (main-CPU RAM), new rows:

| address | name                | what                                                                                                                  |
|---------|---------------------|-----------------------------------------------------------------------------------------------------------------------|
| 0x28B2  | `SEQ_METRO_FLAGS`   | bit 0 the record pages' METRONOME switch, bit 1 the take starts with a count-in, bit 2 the count-in runs              |
| 0x28B3  | `SEQ_CONTROL_FLAGS` | bit 0 redraw due, 1 recording started by a start request, 2 restart check due, 3 record standby, 4 buffer re-init due |
| 0xC1FE  | `AUDIO_STATE`       | the 358-byte audio state of the voice routing                                                                         |
| 0xC364  | `AUDIO_STATE_SENT`  | its copy as last sent; AudioInit_DispatchChanges sends the fields that differ, then copies the state over             |

**technics-docs `event-codes.md`**, row `EVT_SET_METRO` (0x01E80045): the handler is `ApPlaySyori_OnSetMetro`
(was `NoteEditSy_ModeScroll`).  It stores the switch in SEQ_METRO_FLAGS bit 0 unless the sequencer or the
count-in runs, and switching it on in TT_SQREALREC opens TT_SQMETBAL.  hdae5000-homebrew.md and ../Mines are not
affected: no handler registration changed.
