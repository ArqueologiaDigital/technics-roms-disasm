# kn5000-wxn: the WSA1R naming leads of 2026-10-06/07, checked (lane open6/kn5000-d, sub-lane wsa1, 2026-11-02)

The six leads are item 1 of `notes/open4-kn5000-b/naming/README.md` "What is left". They were first reported by
the naming pilot (`wsa1/notes/naming-pilot-2026-10-06/README.md`, waves 9-11). Each lead was checked against
the code before anything was renamed. Five were right and are applied. One was wrong (lead 6) and gets a verdict
instead of a change.

These notes live here, not under `wsa1/notes/`, so that the lead finds the issue comment where the brief says.
`wsa1/notes/naming-pilot-2026-10-06/README.md` now points here.

Evidence probe: `probes/wsa1_wxn_refs.py` (see `probes/README.md`). Renames:
`rename_wsa1_wxn.sed`, which this sub-lane applied itself, because it owns `wsa1/`.

## Lead 1: Dispatch_FF3D39's page-to-screen map. RIGHT, applied

The 6 x 32 key matrix at prom_a 0xFF3D39 has three readers:

- `PanelButtonDispatch_MidiFileSave` (0xFF5ED1) indexes rows by `UI_ScreenPage`, bounded by
  `cp (UI_ScreenPage),5`. It is screen 0x4E's BUTTON method.
- `PanelButtonDispatch_FloppyDiskFormatSelectType` (0xFF6550) adds base 0xFF3F39, which is
  0xFF3D39 + 4 x 128, so it reads row 4. It is screen 0x50's BUTTON method (PanelScreen_VtableTable entry 0x70).
- `PanelButtonDispatch_FloppyDiskFormatAreYouSure` (0xFF66AA) adds base 0xFF3FB9, which is
  0xFF3D39 + 5 x 128, so it reads row 5. It is screen 0x51's BUTTON method (entry 0x71).

Probe R4 reads both `add XBC,imm32` operands from the ROM.

MIDI FILE SAVE has four pages: `ScreenEnterPages_MidiFileSave` has four entries. The only stores of 4 or 5 into
`UI_ScreenPage` belong to DISK SAVE (`DiskSaveFile_AskForPassword`, `LcdKeyRow1_DiskSaveFile_Page1`). So rows 4
and 5 are the format screens' tables. [INFERENCE] The matrix reader's bound of 5 is a trace of a layout in which the
two screens were once pages 4 and 5.

What the keys do:

| screen | caption (display list)                                  | LCD row 3 key                                        | LCD row 4 key                        | EXIT           |
|--------|---------------------------------------------------------|------------------------------------------------------|--------------------------------------|----------------|
| 0x50   | "2DD:720K ..." y = 113, "2HD:1.44M ..." y = 153         | 2DD: (0x21E8) bit 3 := 0, go to screen 0x51          | 2HD: (0x21E8) bit 3 := 1, go to 0x51 | DISK menu 0x40 |
| 0x51   | "ATTENTION! ... Are You Sure?", YES y = 111, NO y = 151 | YES: T_DiskFormat_Execute_Entry, then request 0x0201 | NO: back to screen 0x50              | DISK menu 0x40 |

`Paint_FloppyDiskFormatAreYouSure` titles the confirmation "(2HD)" when (0x21E8) bit 3 is set and "(2DD)" when it
is clear. `DiskFormat_Execute` formats as 2HD when the same bit is set. LCD rows are 48 px tall, so y = 96-143 is
row 3 and y = 144-191 is row 4.

Applied:

- The matrix is now `ScreenButtonHandlers_MidiFileSave`.
- Rows 4 and 5 have their own labels, `ScreenButtonHandlers_FloppyDiskFormatSelectType` and
  `ScreenButtonHandlers_FloppyDiskFormatAreYouSure`. The two dedicated readers name these labels instead of
  `Dispatch_FF3D39+0x200` / `+0x280`. As a result `wsa1/docs/gui-menu-map.md` now gives each screen its own keys.
- The six handlers are renamed (table below) and have new headers. Each header also records the old name.
- prom_a 0xFE1C98 (`calr DiskFormat_Execute / calr Ring_InitTenOfFourteen / ret`) and its prom_b directory slot are
  renamed. It is the format twin of `DiskLoadFile_Execute` / `DiskSaveFile_Execute_Entry`.

Not named: the handler `sub_FF657B` (row 4, SOFT KEY column 4 and column 5 "Alt"). When (0x21E8) bit 2 is set, it
counts eight presses in `DiskScreen_RowOption` and then requests screen 0x52. The firmware has no screen object
0x52 in `wsa1/docs/gui-menu-map.md`, and what bit 2 means is not established. So it keeps its address name. It is a
hidden key sequence of some kind [INFERENCE].

## Lead 2: the MIXER page-frame painter at 0xFBE135. RIGHT, applied

`ScreenEnterBody_CombiEditMixer` posts 0xFBE135 as a callback (`lda xbc,(0xFBE135:24)` at 0xFBDCAC, then
`T_CallbackQueue_Post` and `T_Kernel_SemaSignal_StackArg(1)`) when `CombiEdit_Page` differs from
`CombiEdit_DrawnPage`. The routine:

- copies the page into `CombiEdit_DrawnPage`;
- draws the "MIXER" title lists;
- draws, by page, PAGE1/3 SOUND / PAN / VOL, PAGE2/3 REV / EFF1 / EFF2 / MAIN / KEY SHIFT, or PAGE3/3 MIDI OUT /
  MIDI IN / MIDI CH / SUB, together with the part-cell rows;
- draws "OTHER PARTS" or "SOLO" last.

It was a `.L` local of `CombiEditMixer_ShowOtherParts`, so it looked like part of that routine. It is now
`CombiEditMixer_PaintPageFrame` and has a header. The byte before it, 0xFBE134, is a second `ret` that nothing
reaches (probe R2). This is recorded in the header and was not changed.

## Lead 3: SmfOut_WriteFirstWindow (0xF77F9A) on an unreachable copy. RIGHT, applied

prom_b holds the SMF writer's file layer three times, with every routine at the same offset (probe R3). The offsets
are +0x00 / +0x39 / +0x43 / +0x4B / +0xB3 / +0xC6 / +0xD4 / +0xEF.

- Copy A is at 0xF7659B: `InputStream_OpenAndReadFirstBlock` .. `SmfWrite_SetOutputWindow`.
- Copy D is at 0xF77D00: `InputStream_*_Copy`, `SmfOut_*`, `SmfWriteCopy_*`.
- Copy E is at 0xF77EE7.

Copy E is reached only from its own calls and from three veneers at 0xF77EDB / 0xF77EDF / 0xF77EE3. Nothing calls
those veneers: no call, calr, jp, jrl or jr in either image targets 0xF77EDB-0xF77FE8 from outside (probe R1). Seven
of its eight routines are byte-identical to copy A. The eighth is the CreateFile routine, whose two calls name copy
E's own routines.

The naming follows `wsa1/notes/wsa1_exact_copy_names.py` (`<Name>_Copy`, `_Copy2`). Copy E's three InputStream
routines were already `InputStream_*_Copy2`, so the rest of copy E takes the copy-A name plus `_Copy2`:

- 0xF77F32: new label `SmfWrite_CreateFileWithFirstWindow_Copy2`. Its locals were `sub_F77F2A_Skip` / `_Return`.
- 0xF77F9A: `SmfOut_WriteFirstWindow` becomes `SmfWrite_WriteFirstWindow_Copy2`.
- 0xF77FAD: new label `SmfWrite_WriteNextWindow_Copy2`.
- 0xF77FBB: new label `SmfWrite_WriteLastWindowAndClose_Copy2`. Its local was `SmfOut_WriteFirstWindow_Skip`.
- 0xF77FD6: `sub_F77FD6` becomes `SmfWrite_SetOutputWindow_Copy2`.

Each has a header saying it belongs to the unreached copy E. It is not `OldCopy_`, because that prefix is reserved
for 0xF6F000-0xF6F3FF.

Left for later (not applied): copy D mixes `SmfOut_*` and `SmfWriteCopy_*` for one module copy. Renaming it to
`SmfWrite_*_Copy` would make the three copies read alike. Copy D is reached (from copy C), its names came from
evidence-backed waves, and its renaming is outside this lead.

## Lead 4: 0x216E is the COMPARE LED flag. RIGHT, applied

- Writers: `PanelLed_SetCompareFlag` (0xFDA829: 0 or 1). `CombiEdit_CompareOn` stores 1 and `CombiEdit_CompareOff`
  stores 0, together with `CombiEdit_Comparing` (0x277F). `CombiEdit_SaveOriginalForCompare` stores 0.
- Only reader: the handler at 0xF8C7AC for LED request 0x0400 (`DispatchTable_F8C2B2` id 0x0400). It copies bit 0
  onto `PanelLed_Shadow+7` bit 1 (variant 1) or `PanelLed_Shadow+6` bit 2 (variant 2).

The RAM name is `PanelLed_CompareFlag`. It is added as one row of `scripts/tools/name_wsa1_ram.py` GROUPS, which
generates `wsa1/include/wsa1_ram.inc`. `--apply` respelled its 7 operands, and `--check` reports 0 numeric
spellings left.

[INFERENCE] That this LED bit is physically the COMPARE key's LED. It is the only state the COMPARE functions write
and the only thing that handler shows. No LED-bit-to-lamp map is in the notes yet.

Not done: labelling the 0x0400 handler (`PanelLed_ShowCompare` would fit its siblings). `DispatchTable_F8C2B2`
still spells all eight of its handler pointers as `.byte` numbers, including the pointers to handlers that are
already named. The whole table should become typed records with symbolic pointers in one change.

## Lead 5: gen_prom_b_f5553f_module.py's Select36CE_%06X. RIGHT, fixed

The historical generator names routines by shape with format strings (`Select36CE_%06X`, `Fwd_%06X`,
`Nop_Ret_%06X`, ...). Later waves renamed most of them in the source. For example, wave 11 renamed the three
`Select36CE_*` to `CycleRecordScreen_SelectCycleField` / `_SelectStartMeasureField` / `_SelectEndMeasureField`.
Re-running the generator printed the placeholders again, and its in-place `--splice` would have written them back.

Fix: `labels()` now overlays, address by address, the label the committed prom_b image source has at that address.
The old behaviour is still available with `--historical-names`. The docstring explains both.

Measured with `UNIDASM=/home/fsanches/compartilhado/mame-sony-video/unidasm python3
wsa1/notes/gen_prom_b_f5553f_module.py --names` (about three minutes). The default unidasm path in
`scripts/analysis/llvm_roundtrip.py` does not exist on this machine.

| run    | content | framed | sub_XXXXXX |
|--------|---------|--------|------------|
| before | 11      | 95     | 96         |
| after  | 162     | 36     | 4          |

29 of the 36 framed names left, and all 4 `sub_` names, are the tree's own labels. The other 7 are the selector
tables `SelectorRoutines_F558AE..F55BAE`. The tree now spells these as `keymap_begin` blocks (for example
`ScreenButtons_RealtimeRecordScreen`), whose lines carry no ROM address, so the overlay cannot place them. The
generator's docstring says so.

## Lead 6: the MidiFileL0ad_ prefix (digit zero). WRONG, not renamed (`MidiFileLoad_` since 2026-11-06, below)

The prefix is the screen name `MidiFileL0ad` (now `MidiFileLoad`) (screen 0x49). It is CamelCase of the ROM's own caption "MIDI FILE
L0AD", which has a digit zero (prom_b 0xF5930F, `DL_MidiFileL0adL0ad`, now `DL_MidiFileLoadLoad`; probe R5). This follows the tree's rule, also
stated on the website's wsa1-menu-map page, that labels derived from captions keep the ROM's spelling, as in
`DiskL0adFile` ("DISK L0AD", 0xF58022; now `DiskLoadFile`) and `L0adSingleS0und` (now `LoadSingleSound`).

The four labels the lead names are `MidiFileL0ad_LcdKeyRow1` (now `MidiFileLoad_LcdKeyRow1`), `T_MidiFileL0ad_LcdKeyRow1` (now `T_MidiFileLoad_LcdKeyRow1`),
`MidiFileL0ad_SelectSeqBankAndReadSmf` (now `MidiFileLoad_SelectSeqBankAndReadSmf`) and `_Skip`. They belong to a family of 16 names that includes
`Paint_MidiFileL0ad` (now `Paint_MidiFileLoad`), `ExitKey_MidiFileL0ad` (now `ExitKey_MidiFileLoad`) and `PanelButtonDispatch_MidiFileL0ad` (now `PanelButtonDispatch_MidiFileLoad`). Renaming only these four would
split the family. Renaming the whole family to `MidiFileLoad` would collide with nothing, but it would depart from
the ROM-spelling rule for every caption-derived name, and that is an owner decision (open question below).

**Update 2026-11-06.** The owner decided: "Normalise: rename across the whole tree, L0ad->Load, S0und->Sound,
C0py->Copy, F0rmat->Format, and so on." Lane open9/zero-for-o renamed all 992 such names, this family with them
(`wsa1/notes/zero-for-o/README.md`, `scripts/renaming/rename_wsa1_zero_for_o.sed`). The ROM's caption bytes keep
their zeros.

## Renamed labels

| old                                 | new                                                         | address               |
|-------------------------------------|-------------------------------------------------------------|-----------------------|
| `Dispatch_FF3D39`                   | `ScreenButtonHandlers_MidiFileSave`                         | prom_a 0xFF3D39       |
| (none; was `Dispatch_FF3D39+0x200`) | `ScreenButtonHandlers_FloppyDiskFormatSelectType`           | 0xFF3F39              |
| (none; was `Dispatch_FF3D39+0x280`) | `ScreenButtonHandlers_FloppyDiskFormatAreYouSure`           | 0xFF3FB9              |
| `LcdKeyRow3_MidiFileSave_Page4`     | `LcdKeyRow3_FloppyDiskFormatSelectType`                     | 0xFF65B2              |
| `LcdKeyRow4_MidiFileSave_Page4`     | `LcdKeyRow4_FloppyDiskFormatSelectType`                     | 0xFF65D5              |
| `ExitKey_MidiFileSave_Page4`        | `ExitKey_FloppyDiskFormatSelectType`                        | 0xFF65F8              |
| `LcdKeyRow3_MidiFileSave_Page5`     | `LcdKeyRow3_FloppyDiskFormatAreYouSure`                     | 0xFF66D5              |
| `LcdKeyRow4_MidiFileSave_Page5`     | `LcdKeyRow4_FloppyDiskFormatAreYouSure`                     | 0xFF66F8              |
| `ExitKey_MidiFileSave_Page5`        | `ExitKey_FloppyDiskFormatAreYouSure`                        | 0xFF6712              |
| `MidiFileSave_Page5_LcdKeyRow3`     | `DiskFormat_Execute_Entry`                                  | 0xFE1C98              |
| `T_MidiFileSave_Page5_LcdKeyRow3`   | `T_DiskFormat_Execute_Entry`                                | prom_b directory slot |
| `.LFBE135`                          | `CombiEditMixer_PaintPageFrame`                             | 0xFBE135              |
| (none)                              | `SmfWrite_CreateFileWithFirstWindow_Copy2`                  | prom_b 0xF77F32       |
| `sub_F77F2A_Skip` / `_Return`       | `SmfWrite_CreateFileWithFirstWindow_Copy2_Skip` / `_Return` | 0xF77F48 / 0xF77F99   |
| `SmfOut_WriteFirstWindow`           | `SmfWrite_WriteFirstWindow_Copy2`                           | 0xF77F9A              |
| (none)                              | `SmfWrite_WriteNextWindow_Copy2`                            | 0xF77FAD              |
| (none)                              | `SmfWrite_WriteLastWindowAndClose_Copy2`                    | 0xF77FBB              |
| `SmfOut_WriteFirstWindow_Skip`      | `SmfWrite_WriteLastWindowAndClose_Copy2_Skip`               | 0xF77FCC              |
| `sub_F77FD6`                        | `SmfWrite_SetOutputWindow_Copy2`                            | 0xF77FD6              |
| RAM `(0x216e)`                      | `PanelLed_CompareFlag`                                      | 0x216E                |

Old names in dated records (the naming-pilot proposal JSONs, `prom_a_preservation_check.py`,
`prom_b_names_session_53b889a2.py`, `scripts/renaming/*.sed`, the lane worklists under `notes/lanes/`) are history
and were left as they are. `wsa1/docs/gui-menu-map.md` was regenerated. With the row labels, it now gives screens
0x4E / 0x50 / 0x51 25 / 5 / 3 live key slots each. Before, each screen was credited with all 33 slots of the matrix.

## Found on the way: gate-wsa1 could not pass in a fresh tree

`scripts/analysis/gui_menu_map.py --check`, the gate's third step, reads `rebuilt_ROMs/wsa1_prom_a.llvm.elf` and
`wsa1_prom_b.llvm.elf`. Since the joint link (82cfe8a4e, 2026-10-31), `wsa1/Makefile` makes those two only on request:
they are cut from `wsa1_maincpu.llvm.elf`. The byte gate's `make all` did not build them. In a new worktree the
check therefore stopped with "build first: ... wsa1_prom_a.llvm.elf missing". An older checkout passed only because
it still held ELFs from before the joint link. Fix: `all: $(MAINCPU_ELFS)` in `wsa1/Makefile`.

## Gate

`flock /home/fsanches/compartilhado/tmp/open6-kn5000-d/build.lock make gate-wsa1` exited 0 on 2026-11-02:
"PASS: every rebuilt ROM is byte-identical.", images-check 210 / 210 bitmaps and 12 / 12 faces, and
"OK: docs/gui-menu-map.md is up to date".

## Open questions

- RESOLVED 2026-11-06 (owner: normalise). Was: should caption-derived WSA1 names keep the ROM's 0-for-O spelling
  (`MidiFileL0ad`, now `MidiFileLoad`; `L0adSingleS0und`, now `LoadSingleSound`; `DL_*F0rmat*`, now `DL_*Format*`), or be
  normalised tree-wide? Done by lane open9/zero-for-o: `wsa1/notes/zero-for-o/README.md`.
- Screen 0x52 and (0x21E8) bit 2, behind `sub_FF657B`'s eight-press counter.
- The meaning of the request 0x0201 that YES posts after a format.

## Website page draft

**technics-docs `wsa1-menu-map.md`, "Every screen, at a glance", table "Disk (0x40-0x54)"**. The "keys" column for
0x4E / 0x50 / 0x51 counted the whole 6-row matrix for each of the three screens. Now each screen has its own table:

    | 0x4E | `PageDispatch_MidiFileSave`          | SAVE                                                         | 25   | -            |
    | 0x50 | `Paint_FloppyDiskFormatSelectType`   | COMPOSER LOAD                                                | 5    | -            |
    | 0x51 | `Paint_FloppyDiskFormatAreYouSure`   | ATTENTION! / Using DISK FORMAT will erase / any current data | 3    | -            |

(was 33 / 33 / 33; the new values are those of `wsa1/docs/gui-menu-map.md`, regenerated 2026-11-02), and add one
sentence under the table:

    Screens 0x50 and 0x51 (FLOPPY DISK FORMAT: choose 2DD / 2HD, then "Are You Sure?") read rows 4 and 5 of
    MIDI FILE SAVE's key matrix through their own button methods; on 0x50 LCD row 3 picks 2DD and row 4 2HD,
    on 0x51 row 3 is YES (format) and row 4 NO.

**Renamed labels quoted on the website**: none. A read-only grep of `../technics-docs` for every old name in the table
above, and for `MidiFileL0ad` (now `MidiFileLoad`), found only the unchanged `Paint_MidiFileL0ad` (now `Paint_MidiFileLoad`) and `ScreenEnterBody_CombiEditMixer`
in `wsa1-menu-map.md`.
