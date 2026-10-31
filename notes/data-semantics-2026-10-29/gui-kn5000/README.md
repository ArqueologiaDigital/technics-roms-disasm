# Lane gui-kn5000: the KN5000 main-CPU GUI, readable at a glance (2026-10-29)

The owner asked for this on 2026-10-29: *"The entire set of GUI data structures must also be semantically
described. One should be able to easily grasp all the menus, submenus, screens, GUI widgets, etc, just by
glancing at the source code."* This lane covers the NAKA UI framework's widget records in the main-CPU C sources,
`<tree>/maincpu/ui_widgets/*.c`, in all five trees: v10, v9, v7, v6 and v5 (v8 builds from v9's sources). Each tree
compiles those files with clang into `includes/generated/*.bin` and includes the bins with `.incbin`. Every step
below is byte-identical: `make gate` passes, and `gui-check` is now part of it.

## What a screen looks like now

Here is `v10/maincpu/ui_widgets/naka_disk_menu_file_io.c`, cut short:

```c
    /* ==== SCREEN TITLE_DKMENU "DISK MENU" -- "TT_DKMENU", title id 0x60, function NAKA_APFUNC_DefaultFunction ====
     * Path: mode MD_DISK
     * Menu: "STYLE CONVERT" -> TITLE_STYLCNVWAIT
     * Menu: "HARD DISK MAIN MENU" -> TITLE_HDDEXT
     * Menu: "LOAD" -> by code, NAKA_MAINFUNC_LoadTtlJgFunc
     * EXIT -> TITLE_PS */
    .DiskMenu = {
        .class_ = NAKA_CLASS(TtlScreen),
        .super = NAKA_NONE,
        .sub = OBJ_StyleConvert_AcTitleMenu,
        .flag = VF_Fixed | VF_Const,
        .rect = NAKA_XYWH(0, 0, 320, 240),
        .color = CL_Gray,
        .border = BD_Single2,
        .exit = TITLE_PS,
        .window = RAM_DiskMenu_Window,
        .title = SELF(DiskMenu_text),
        .icon = idICON_i147,
    },
    .DiskMenu_text = "DISK MENU",
    .StyleConvert_AcTitleMenu = {
        .class_ = NAKA_CLASS(AcTitleMenu),
        .super = OBJ_DiskMenu,
        .next = OBJ_Cheap_HardDiskMenuView,
        .rect = NAKA_XYWH(8, 114, 149, 26),
        .font = idCHARA1, .fontcolor = CL_White, .align = AL_Center,
        .editsw = ES_Left3,
        .selected = RAM_StyleConvert_AcTitleMenu_Selected,
        .str = SELF(StyleConvert_text),
        .title = TITLE_STYLCNVWAIT,
    },
```

Each file also declares its object tree once, before the initializer. There is one enum per Viewable table, with one
constant per element in index order, indented by depth:

```c
#define Toshi_Viewable_NORMAL_SLOT 0x001u
enum Toshi_Viewable_NORMAL_objects {
    OBJ_Normal,                          /*  0 TtlScreen "Normal" */
    OBJ_normal,                          /*  1 NormScreen "normal" */
      OBJ_normal_AcTempoBox,             /*  2 AcTempoBox */
      ...
      OBJ_normal_AcSoundName_2,          /*  6 AcSoundName */
        OBJ_RIGHT2_StringBox,            /*  7 StringBox */
```

The whole GUI can be browsed in [`docs/gui/kn5000-menu-map.md`](../../../docs/gui/kn5000-menu-map.md). It lists
every title, its menu path, its menu entries, where EXIT goes and the widget tree of its screen.

## The representation, and the evidence for each name

| what                  | spelled as                                                                                                                     | evidence (v10)                                                                                                                                                                                                                                                                                                                                                                                              |
|-----------------------|--------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| class id              | `NAKA_CLASS(TtlScreen)`; `naka_cls_<Class>_t`                                                                                  | `ClassProc` (0xFA44E2, `ui/ui_widget_defs.s`) maps id 0x016S_KKKK to entry KKKK of the Class table in slot 0x16S. All 293 classes come from the 9 Class tables (`nakarest_objtab_map.py`, THE CLASS SYSTEM).                                                                                                                                                                                                |
| field names           | the class chain's `propname` strings                                                                                           | the same tables (`naka_classes.h`).                                                                                                                                                                                                                                                                                                                                                                         |
| object links          | `.super = OBJ_normal`; enum per table, indented by depth                                                                       | Viewable +4/+6/+8/+10 are element indices of the same table (ext lane, `ext_lane_checks.py`). `naka_gui_model.py --check` asserts that every record's constant has its element index, that the indentation is the depth its `super` gives, and that sub/next/prev agree.                                                                                                                                    |
| rectangle             | `NAKA_XYWH(x, y, w, h)`                                                                                                        | `RectX2Proc` (0xFA7058) and `RectY2Proc` (0xFA7112) name x2 and y2 "width" and "height". GET answers x2 - x1 + 1; SET stores x1 + width - 1.                                                                                                                                                                                                                                                                |
| enumerated properties | `CL_White`, `BD_None`, `VF_Fixed \| VF_Const`, `AL_Center`, `ES_Left3`, `SS_*`, `LM_*`, `FR_*`, `PT_*`, `TR_*`, `IT_*`, `idu*` | A propdata letter L selects SupportClass entry L - 'A'. `ClassProc` does `sub a, 0x41; add xwa, 0x2600000; SendEvent` (`ui/ui_widget_defs.s`, label `TitleWidget_Select`). That table is `SupportClass_PropTypeRecords` (0xEB7690, 0x37 entries), registered at slot 0x260 by `InitializeObjectTable` (0xFA40B3). Each entry is {proc, count, size, -> {name, value} pairs}, and those pairs are the names. |
| fonts                 | `idCHARA1` .. `idCHARA5W`                                                                                                      | `FontIDProc` (0xFA7BCF) reads RAM 0x3EFAC, whose work-RAM image is `FontIDProc_FontNameTable` (0xEEF350). The dump prefix is `FontIDProc_DumpPrefix` = "id".                                                                                                                                                                                                                                                |
| bitmaps               | `idTrashIcon` ...                                                                                                              | `BitmapIDProc` (0xFA7E0F) reads `BitmapIDProc_PtrTable` (0xEAB3CC, 34 entries). The prefix is "id".                                                                                                                                                                                                                                                                                                         |
| icons                 | `idICON_None`, `idICON_Default`, `idICON_i0` ...                                                                               | `IconIDProc` (0xFA7CEF) reads `IconIDProc_NameTable` (0xEB193C, 177 names). The prefix is "idICON_". The firmware's own names are mostly `iNN`.                                                                                                                                                                                                                                                             |
| title ids             | `TITLE_*`                                                                                                                      | Letter a is `TitleIDProc` (0xFA8F6F). `RegTitle` / `RegisterTitle` (0xFA4D80) bind each title to its view object. The names come from event_codes.s.                                                                                                                                                                                                                                                        |
| mode / function ids   | `NAKA_MODE_*`, `NAKA_APFUNC_*`, `NAKA_FUNC_*`, `NAKA_MAINFUNC_*`                                                               | Letters \` j k (`ModeIDProc`, `ApFuncIDProc`, `MainFuncIDProc`). The names come from event_codes.s (`naka_object_id_names.py`).                                                                                                                                                                                                                                                                             |
| view object ids       | `NAKA_VIEW_ID(Table, OBJ_x)`                                                                                                   | Letters t and N (`WindowIDProc` 0xFA8999, `ScreenIDProc` 0xFA8609). The id is 0x0SSS_KKKK. All 113 ids point into a table of the same file.                                                                                                                                                                                                                                                                 |
| live-value cells      | `RAM_<cell>`                                                                                                                   | Letters m..s (`pBoolProc` .. `pUlongProc`) hold the address of a DRAM cell. `Boot_InitWorkRAM` (0xEF0B46) copies ROM 0xEED8C8 to RAM 0x3D524 (0x219E bytes). The cell names are the C members of `naka_sequencer_channels.c` (`name_widget_value_cells.py`).                                                                                                                                                |
| screen headers        | `/* ==== SCREEN TITLE_X "TEXT" ...` / `/* ==== VIEW ...`                                                                       | Generated. The title comes from the TITLE_ comment in event_codes.s. The path is the shortest chain of `AcTitleMenu.title` entries from a mode's home title (`RegMode`). EXIT is the screen's `exit` field. Menu boxes with a `main_func` (the `*TtlJgFunc` boxes) open a title by code, and the header names the function.                                                                                 |

Records that are registered at DRAM addresses are read through the two `Boot_InitWorkRAM` images: ROM 0xEED8C8 to
RAM 0x3D524, and ROM 0xEEFA66 to RAM 0xE35E. 28 of them hold, for example, the DISK MENU's "HARD DISK MAIN MENU"
entry, `Cheap_HardDiskMenuView`.

## Headers and tools

| file                                               | role                                                                                                                                       |
|----------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------|
| `<tree>/maincpu/ui_widgets/naka_classes.h`         | generated: NAKA_CLASS_* constants, one typedef per class, and the property value names                                                     |
| `<tree>/maincpu/ui_widgets/naka_ids.h`             | generated: every event_codes.s constant as a `#define`                                                                                     |
| `<tree>/maincpu/ui_widgets/naka_ram_cells.h`       | generated: RAM_<cell> addresses (v10 layout)                                                                                               |
| `<tree>/maincpu/ui_widgets/naka_types.h`           | includes the three, plus `NAKA_XYWH`, `NAKA_XYXY` and `NAKA_VIEW_ID`                                                                       |
| `scripts/generators/gen_naka_gui_headers.py`       | writes the headers into all five trees (`--check`)                                                                                         |
| `scripts/converters/naka_gui_symbolize.py`         | the rewrite (`--apply`, `--headers`, `--sync v7,v6,v5`, `--check`). It recompiles each changed file and refuses any whose bin would change |
| `scripts/analysis/naka_gui_model.py`               | the parser and GUI graph (titles, modes, edges), and `--check` (the enums against the links)                                               |
| `scripts/generators/gen_naka_menu_map.py`          | `docs/gui/kn5000-menu-map.md` (`--check`)                                                                                                  |
| `scripts/analysis/naka_gui_census.py`              | the readability census (`--rev` for before/after, `--files TREE` per file)                                                                 |
| `scripts/generators/gen_title_mode_index_equs.py`  | the TT_* / MD_* index block of each event_codes.s (`--check`)                                                                              |
| `scripts/converters/name_title_index_operands.py`  | names title / mode index operands from control flow; `opens_by_routine()` feeds the menu map                                               |
| `scripts/converters/naka_asm_records.py`           | `shared/naka_gui.s` (`--gen`, `--check`) and the NAKA_REC_ macro records (`--apply`, `--report`)                                           |
| `scripts/converters/naka_type_c_slices.py`         | types records one C member covers exactly                                                                                                  |
| `scripts/converters/name_class_string_pointers.py` | labels class-name / propdata slices, spells their pointers                                                                                 |
| `scripts/converters/retype_prop_type_records.py`   | SupportClass_PropTypeRecords as `naka_prop_type_t[51]`                                                                                     |

There are three make targets. `make menu-map` regenerates the map. `make gui-census` prints the census. `make
gui-check` checks the headers, the enums against the links, the spelling and SCREEN headers of all five trees, and
the menu map. `make gate` runs `gui-check`.

The headers are generated from v10 and copied unchanged into v9, v7, v6 and v5. Those trees compile v10's GUI C:
v9's differs only in `naka_style_bitmaps.c` and `naka_widget_descriptors.c`, and v7, v6 and v5 patch the compiled
bins with their `*_c_divergence.json`, which this lane did not have to change. To redo the whole thing:

    python3 scripts/generators/gen_naka_gui_headers.py
    python3 scripts/converters/naka_gui_symbolize.py --tree v10 --apply
    python3 scripts/converters/naka_gui_symbolize.py --tree v9 --apply
    python3 scripts/converters/naka_gui_symbolize.py --tree v10 --headers --apply
    python3 scripts/converters/naka_gui_symbolize.py --tree v9 --headers --apply
    python3 scripts/converters/naka_gui_symbolize.py --sync v7,v6,v5
    for t in v7 v6 v5; do python3 scripts/converters/naka_gui_symbolize.py --tree $t --apply; done
    python3 scripts/generators/gen_naka_menu_map.py
    make gate

## The GUI-readability census, before and after

Each column counts places outside comments and strings. "prop values" counts fields spelled as a number for which
a firmware name exists, and "unnamed prop" counts those for which none exists. "before" is
`python3 scripts/analysis/naka_gui_census.py --rev 9dbc03088` (the lane's base). "pass 1" is the first merge
(2fcde02ba). "now" is the same command without `--rev`, at the head of the second pass.

| tree | state  | class ids | links | view ids | prop values | unnamed prop | rom addrs | ram cells | field_XX | records |
|------|--------|-----------|-------|----------|-------------|--------------|-----------|-----------|----------|---------|
| v10  | before | 3,445     | 7,940 | 113      | 15,460      | 1            | 384       | 1,541     | 645      | 3,206   |
| v10  | pass 1 | 0         | 0     | 0        | 0           | 1            | 356       | 189       | 645      | 3,206   |
| v10  | now    | 0         | 0     | 0        | 0           | 1            | 73        | 0         | 525      | 3,242   |
| v9   | before | 3,445     | 7,940 | 114      | 15,460      | 1            | 385       | 1,541     | 645      | 3,206   |
| v9   | now    | 0         | 0     | 0        | 0           | 1            | 73        | 0         | 525      | 3,242   |
| v7   | before | 3,445     | 7,940 | 113      | 15,460      | 1            | 384       | 1,541     | 653      | 3,206   |
| v7   | now    | 0         | 0     | 0        | 0           | 1            | 73        | 0         | 533      | 3,242   |
| v6   | before | 3,445     | 7,940 | 113      | 15,460      | 1            | 384       | 1,541     | 653      | 3,206   |
| v6   | now    | 0         | 0     | 0        | 0           | 1            | 75        | 0         | 533      | 3,242   |
| v5   | before | 3,445     | 7,940 | 113      | 15,460      | 1            | 384       | 1,541     | 653      | 3,206   |
| v5   | now    | 0         | 0     | 0        | 0           | 1            | 75        | 0         | 533      | 3,242   |

Pass 1 removed 28 "rom addrs" that were view ids the old spelling had also matched as ROM addresses (0x00F90007 is
slot 0xF9, element 7). The v9 "before" has one more view id and one more ROM address than v10: in v10 the value
`SendPartDataBlock_Data2` (0x00FF0000) was spelled as a pointer, but it is a ScreenID, element 0 of
`Root_ViewableTable_0FF`. Both trees now spell it `NAKA_VIEW_ID(Root_ViewableTable_0FF, OBJ_CheckTitle)`. Pass 1
also removed the 420 per-file copies of the class typedefs.

Two more measures were taken outside this census:

| measure                                                        | before | pass 1 | now                     |
|----------------------------------------------------------------|--------|--------|-------------------------|
| titles with a menu path (`docs/gui/kn5000-menu-map.md`)        | -      | 60     | 130 of 211              |
| title / mode indices spelled TT_* / MD_* in the asm (per tree) | 0      | 0      | 279 / 30                |
| widget records outside the C as one NAKA_REC_ macro call (v10) | 0      | 0      | 86 (88 in v6/v5)        |
| Viewable elements with no typed record (v10)                   | 187    | 187    | 65 (13 of them in DRAM) |

## The second pass (2026-10-29, after the first merge)

1. **Titles opened by code.** Three routines in `ui/ui_control_panel.s` post a title or mode change from an index:
   `UI_ChangeTitleByIndex` (was `UI_PostModeChangeEvent`), `UI_InterruptTitleByIndex` (was
   `SoundCtrl_SendCommand`) and `UI_ChangeModeByIndex` (was `UI_PostPartChangeEvent`). They post
   `EVT_CHANGE_TITLE` / `EVT_INTERRUPT_TITLE` with `TITLE_PS + A`, and `EVT_CHANGE_MODE` with
   `NAKA_MODE_MD_PS + A`. The renames are in `scripts/renaming/rename_title_by_index.sed`. `shared/event_codes.s`
   now ends with a generated block of `TT_X` / `MD_X` index constants, the firmware's own names
   (`gen_title_mode_index_equs.py`). `name_title_index_operands.py` walks each file's control flow back from every
   call (including the two stack-spilling forwarders `FileIO_DiskEventDispatch` and `FileIO_GetDiskCapacity`) and
   names each operand: `ldw wa, TT_DKLD`. That covers 279 title and 30 mode operands per tree. 18 title sites and 1
   mode site take the index from memory.
2. **Panel buttons.** `PanelButton_ModeKey` (`audio/audio_control_engine.s`) maps a mode key's lowest set button
   bit through `PanelButton_ModeKeyCodes*` and posts `EVT_SW_IN_MODE` (`boot/main_title_ctrl_panel.s`:
   `NAKA_MODE_MD_PS + payload`). Those maps (`naka_extension_device.c`) are now one `MD_*` byte per button,
   commented with the MAME driver's port names:
   - MENU SOUND / CONTROL / MIDI / DISK
   - DEMO, MSP MENU, HELP, ENTERTAINER
   - SEQUENCER EASY REC / MENU
   - COMPOSER MENU, SOUND ARRANGER SET

   `PanelButton_ModeKey_FilterTarget` can redirect two of the sequencer keys: EASY REC opens `MD_SEQ` when byte
   0x26FC is 1, and MENU opens `MD_SEQ_PLAY` when bit 0 of 0x266A is set. Headers and the menu map now start a path
   at the button: `MENU DISK button (mode MD_DISK) > "LOAD" (by LoadTtlJgFunc)`.
3. **Records outside the C.** `scripts/converters/naka_asm_records.py --gen` writes `shared/naka_gui.s` (included
   after event_codes.s) with class ids, value names, `IDX_<label>` element indices and one keyword-argument macro
   per class, `NAKA_REC_<Class>`. `--apply` rewrites 86 asm records (88 in v6/v5) as one call each.
   `scripts/converters/naka_type_c_slices.py` types 36 records that one C member covered exactly: the work-RAM
   view records of `naka_sequencer_channels.c`, the IvExit byte arrays and `NakaWidget_SVARI`. The nine
   `bytes_XXXX` members took their asm labels.
4. **Class-string pointers.** `scripts/converters/name_class_string_pointers.py` labels the already-sliced
   class-name / propdata strings (`ClassName_<Class>`, `ClassPropdata_<Class>`). It spells 283 pointers per tree
   (281 in v6/v5) as `NAKA_ADDR()`. Each link script defines the label with the pointer's own value, so each tree's
   blob is unchanged. In v7/v6/v5 that value is v10's address, as the shared C carries it, and their divergence
   patches apply as before.
5. **RAM cells.** `naka_ram_cells.h` also names every cell outside the C-spelled image, after the widget field
   that keeps its live value there: `<record>_<Field>`, read from the ROM records. The 18 `field_XXXX` members of
   `naka_sequencer_channels.c` that are such cells take the cell's name.
6. **field_XX.** `SupportClass_PropTypeRecords` letters A..s are a typed array, `naka_prop_type_t [51]`:
   - `proc`;
   - `count`, which CommonIDProc walks;
   - `size`, which `SupportClassProc_OnGetPropSize` reads at +6;
   - `values`.

   This is `retype_prop_type_records.py`.

## Files done

The records in all 15 record-holding files are fully converted, in all five trees: `control_menu_header.c`,
`naka_accomp7_widgets.c`, `naka_composer_style.c`, `naka_ctrl_menu_body.c`, `naka_debug_naming.c`,
`naka_direct_play.c`, `naka_disk_menu_file_io.c`, `naka_effects_seq.c`, `naka_extension_device.c`,
`naka_midi_reverb.c`, `naka_msp_recording.c`, `naka_normal_mode.c`, `naka_perf_style.c`,
`naka_sound_menu_drawbar.c` and `naka_technichord_part.c`. The second pass added records in
`naka_sequencer_channels.c`, `naka_widget_names_charmap.c` and `naka_widget_tables_1.c`, for 3,242 in all. The class
ids are named in every GUI C file.

## What remains (measured, not guessed)

- **65 Viewable elements with no typed record.** 20 straddle two C members. For example, an IvExit and the record
  after it share one `naka_dispatch_t`, so typing them means splitting members, and some of those members hold a
  pointer at an odd offset (`.inst_ptr = NAKA_ADDR(CRTC_LINE_COMPARE)` in `w47`). 13 are DRAM records in the asm's
  `WorkRamInit_Image`; the other 15 DRAM records are now typed in `naka_sequencer_channels.c`. 32 asm records were
  skipped by `naka_asm_records.py --report`, because their block holds strings (`aligned_string`) or ends before or
  after the record. The enums and the menu map name all of them.
- **73 numeric ROM addresses** (75 in v6/v5): 25 in `naka_widget_descriptors.c`, 19 in `naka_block_007.c`, 15 in
  `naka_technichord_strings.c`, and a few handler words. They point at string or record interiors with no slice of
  their own, and need a label split first.
- **525 `field_XX` members** (533 in v7/v6/v5). 291 are in `naka_sequencer_channels.c`; none of those is read by its
  RAM address in the asm (checked: one direct `(0xADDR)` use among them), and none is a widget's cell. Naming them
  needs the routines that reach them through a base pointer. The rest are spread over 15 files.
- **1 property value has no name**: `TEST3.fontcolor = 0x0043`.  (Settled 2026-10-31, lane kn5000-a: it cannot have a
  firmware name.  ColorIDProc's name table names no 0x43, the boot palette's entry 0x43 is 0x000000, and
  `SineWaveScreenProc` never reads its fontcolor field, +42: it draws with the fixed colours 0xff / 0xf5.  (A comment in
  the record would break naka_gui_model.py / naka_gui_symbolize.py, which parse the initializers, so the note lives
  here.)  naka_gui_census.py's 'unnamed prop' stays 1 for that reason.)
- **81 titles have no path.** No traced code opens 108 of the 130 title names that the asm never spells. That
  includes most sound-edit (`TITLE_SE*`) pages, which the Scoop module's sound-editor screens open through their own
  data, not NAKA records.
- **Icons**: the firmware names most only `iNN`.  (Done 2026-10-31, lane kn5000-a: each of the 113 icons the KN5000 and
  HD-AE5000 records use has a description of what it shows, `scripts/generators/naka_icon_descriptions.json`, written
  beside its `idICON_iNN` in naka_classes.h / naka_values.s and in the HD-AE5000 menu maps; the names stay the firmware's.)

## Open questions

- `RectX2Proc`'s internal labels are `TabDraw_TopEdge*`, borrowed from unrelated code. This lane did not rename
  them.  (Done 2026-10-31, lane kn5000-a: they take RectY2Proc's case names, `RectX2Proc_OnGetPropMember` ...,
  in v10/v9/v7/v6/v5; `scripts/renaming/rename_rectx2proc_locals.sed`.)
- Is the font index table (`FontIDProc_FontNameTable`, in DRAM) rewritten at run time? The names assume the boot
  image.  (Answered 2026-10-31, lane kn5000-a: no.  The RAM copy, now `FONTID_NAME_TABLE` (0x3efac; 0x3efa8 in v6/v5), is
  read by FontIDProc's three loads of its base and written by nothing else in any main-CPU or HD-AE5000 image:
  `notes/kn5000-a-2026-10-31/probes/fontid_table_writers.py`.)
- These routine names changed in the second pass, and the documentation site still uses the old ones in
  `feature-demo.md`, `test-modes.md` and `ssf-presentation.md`:
  - `UI_PostModeChangeEvent` is now `UI_ChangeTitleByIndex`;
  - `SoundCtrl_SendCommand` is now `UI_InterruptTitleByIndex`;
  - `UI_PostPartChangeEvent` is now `UI_ChangeModeByIndex`. (Resolved: technics-docs 92e54be, the pages now use the new names and quote the old ones only as "named ... until 2026-10-29"; open-items register 2026-10-31.)

## Website page draft (for `ui-framework.md`, section "Widget records in the C sources")

> Since 2026-10-29 the widget records in the NAKA C sources (`v10/maincpu/ui_widgets/*.c` and the same in v9, v7, v6
> and v5) are written with the firmware's own names. A record's class is `NAKA_CLASS(<Class>)`. Its links to
> parent, first child and siblings are object names (`OBJ_<record>`), declared once per Viewable table in an enum
> that is indented by tree depth. Its rectangle is `NAKA_XYWH(x, y, width, height)`, the way `RectX2Proc` and
> `RectY2Proc` edit it. Colours, borders, view flags, alignment, edit switches and styles, line modes, frames,
> parts, tracks and times use the value names of `SupportClass_PropTypeRecords` (`CL_White`, `BD_Single2`,
> `VF_Fixed | VF_Const`, ...). A property's type letter selects SupportClass entry letter - 'A'. Fonts, bitmaps and
> icons use their dump names (`idCHARA1`, `idTrashIcon`, `idICON_i12`). Titles, modes and function objects use
> event_codes.s names, view ids are `NAKA_VIEW_ID(Table, OBJ_x)`, and live-value cells are `RAM_<cell>`. Every
> title's screen record starts with a generated comment: what the screen is, its menu path from a mode's home title,
> its menu entries and where EXIT goes. The repository's `docs/gui/kn5000-menu-map.md` lists all 211 titles and
> 21 modes with each screen's widget tree. The headers `naka_classes.h`, `naka_ids.h` and `naka_ram_cells.h` are
> generated by `scripts/generators/gen_naka_gui_headers.py`, and `make gui-check` (part of `make gate`) keeps
> everything in sync.
