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

| file                                         | role                                                                                                                                       |
|----------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------|
| `<tree>/maincpu/ui_widgets/naka_classes.h`   | generated: NAKA_CLASS_* constants, one typedef per class, and the property value names                                                     |
| `<tree>/maincpu/ui_widgets/naka_ids.h`       | generated: every event_codes.s constant as a `#define`                                                                                     |
| `<tree>/maincpu/ui_widgets/naka_ram_cells.h` | generated: RAM_<cell> addresses (v10 layout)                                                                                               |
| `<tree>/maincpu/ui_widgets/naka_types.h`     | includes the three, plus `NAKA_XYWH`, `NAKA_XYXY` and `NAKA_VIEW_ID`                                                                       |
| `scripts/generators/gen_naka_gui_headers.py` | writes the headers into all five trees (`--check`)                                                                                         |
| `scripts/converters/naka_gui_symbolize.py`   | the rewrite (`--apply`, `--headers`, `--sync v7,v6,v5`, `--check`). It recompiles each changed file and refuses any whose bin would change |
| `scripts/analysis/naka_gui_model.py`         | the parser and GUI graph (titles, modes, edges), and `--check` (the enums against the links)                                               |
| `scripts/generators/gen_naka_menu_map.py`    | `docs/gui/kn5000-menu-map.md` (`--check`)                                                                                                  |
| `scripts/analysis/naka_gui_census.py`        | the readability census (`--rev` for before/after, `--files TREE` per file)                                                                 |

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

Before is `python3 scripts/analysis/naka_gui_census.py --rev 9dbc03088`; after is the same command without `--rev`,
run at this lane's head. Each column counts places outside comments and strings. "prop values" counts fields
spelled as a number for which a firmware name exists, and "unnamed prop" counts those for which none exists.

| tree | state  | class ids | links | view ids | prop values | unnamed prop | rom addrs | ram cells | field_XX | records |
|------|--------|-----------|-------|----------|-------------|--------------|-----------|-----------|----------|---------|
| v10  | before | 3,445     | 7,940 | 113      | 15,460      | 1            | 384       | 1,541     | 645      | 3,206   |
| v10  | after  | 0         | 0     | 0        | 0           | 1            | 356       | 189       | 645      | 3,206   |
| v9   | before | 3,445     | 7,940 | 114      | 15,460      | 1            | 385       | 1,541     | 645      | 3,206   |
| v9   | after  | 0         | 0     | 0        | 0           | 1            | 356       | 189       | 645      | 3,206   |
| v7   | before | 3,445     | 7,940 | 113      | 15,460      | 1            | 384       | 1,541     | 653      | 3,206   |
| v7   | after  | 0         | 0     | 0        | 0           | 1            | 356       | 189       | 653      | 3,206   |
| v6   | before | 3,445     | 7,940 | 113      | 15,460      | 1            | 384       | 1,541     | 653      | 3,206   |
| v6   | after  | 0         | 0     | 0        | 0           | 1            | 356       | 189       | 653      | 3,206   |
| v5   | before | 3,445     | 7,940 | 113      | 15,460      | 1            | 384       | 1,541     | 653      | 3,206   |
| v5   | after  | 0         | 0     | 0        | 0           | 1            | 356       | 189       | 653      | 3,206   |

The "rom addrs" drop of 28 is view ids that the old spelling also matched as ROM addresses (0x00F90007 is slot 0xF9,
element 7). The v9 "before" has one more view id and one more ROM address than v10. In v10 that value,
`SendPartDataBlock_Data2` (0x00FF0000), was spelled as a pointer, but it is a ScreenID: element 0 of
`Root_ViewableTable_0FF`. Both trees now spell it `NAKA_VIEW_ID(Root_ViewableTable_0FF, OBJ_CheckTitle)`. The 420
per-file copies of the class typedefs are gone.

## Files done

The records in all 15 record-holding files are fully converted, in all five trees: `control_menu_header.c`,
`naka_accomp7_widgets.c`, `naka_composer_style.c`, `naka_ctrl_menu_body.c`, `naka_debug_naming.c`,
`naka_direct_play.c`, `naka_disk_menu_file_io.c`, `naka_effects_seq.c`, `naka_extension_device.c`,
`naka_midi_reverb.c`, `naka_msp_recording.c`, `naka_normal_mode.c`, `naka_perf_style.c`,
`naka_sound_menu_drawbar.c` and `naka_technichord_part.c`. That is 3,206 records. In the files that hold class
tables but no records, the class ids are named: `naka_block_007.c`, `naka_block_012.c`, `naka_disk_warning.c`,
`naka_sequencer_channels.c`, `naka_sequencer_exit.c`, `naka_technichord_strings.c`, `naka_widget_descriptors.c`,
`naka_widget_names_charmap.c`, `naka_widget_tables_1.c` and `naka_widget_tables_2.c`.

## What remains (measured, not guessed)

- **187 Viewable elements have no typed C record.** 159 are in ROM: 77 `NakaWidget_*`, 38 `Toshi_*`, 25 `FDTest_*`,
  11 `NakaMenuItem_*` and a few others. They are either in `.s` files (`extensions/extension_data.s`, the factory
  test) or still untyped members such as `NakaWidget_N1` and `bytes_0464` in `naka_normal_mode.c`. The other 28 are
  DRAM records in the work-RAM image. The enums name all of them, after their asm label, and the menu map reads them
  from the ROM. Typing them is next: they need the same `naka_cls_*` treatment.
- **356 numeric ROM addresses.** Most are the `name` / `propdata` pointers of the Class descriptor tables, and they
  point into the class-name string pools of *other* blobs, at offsets with no label. Symbolizing them needs labels
  inside those pools. A few are handler words in `naka_perf_style.c` and `naka_technichord_part.c`, and
  `IvMesage_Windows`.
- **189 RAM cells** are in the first 0x7B0 bytes of the work-RAM image (RAM 0x3D524..0x3DCD3). The asm holds that part
  as `WorkRamInit_Image` and names no cells in it.
- **645 `field_XX` / `bytes_XX` / `ptr_XX` members** (653 in v7/v6/v5). They are outside the widget records, mostly
  in `naka_sequencer_channels.c` (309) and `naka_style_bitmaps.c` (104).
- **1 property value has no name.** `naka_extension_device.c` `TEST3.fontcolor = 0x0043`: ColorIDProc names no
  colour 0x43.
- **Menu entries that open a title by code.** These are the `AcTtlJgBox` boxes with a `main_func` (LOAD, DISK TOOLS,
  DIRECT PLAY, SONG MEDLEY ...). The functions pass raw title indices, for example `LoadTtlJgFunc`
  (`file_io/title_handlers.s`) does `ldw wa, 0x61; ldw bc, 0x64; calr FileIO_DiskEventDispatch`. Naming them
  `TITLE_*` in the asm would let the map follow them. Today 60 of the 211 titles have a menu path; the others are
  listed as "opened by code".
- **Icons.** `IconIDProc_NameTable` names most icons only `i0`..`i174`, so `idICON_i147` is the firmware's name but
  not a description.

## Open questions

- Which panel button enters which mode (MD_DISK, MD_SOUND ...)? The modes are the roots of the menu map, but the
  button-to-mode table was not traced in this lane. The headers therefore say "mode MD_DISK", not "DISK button".
- `RectX2Proc`'s internal labels are `TabDraw_TopEdge*`, borrowed from unrelated code. The routine is the x2/width
  property type, and its labels should be renamed like `RectY2Proc`'s. This lane did not rename them.
- Is the font index table (`FontIDProc_FontNameTable`, in DRAM) ever rewritten at run time? The names assume the
  boot image.

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
