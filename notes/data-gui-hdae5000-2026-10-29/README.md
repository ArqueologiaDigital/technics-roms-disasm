# HD-AE5000 GUI, semantically (lane gui-hdae5000, 2026-10-29)

The owner's goal for this lane (GUI addendum of the data-semantics wave): one should grasp every
HD-AE5000 screen, window, dialog and widget at a glance in the source. That means names, nesting,
captions, handlers and transitions, with the bytes unchanged. Both versions are covered:
`hdae5000/` (v2.06i) and `hdae5000_v2_01i/` (v2.01i).

## What the source looks like now

The GUI is one NAKA Viewable table, object table 0x7F. v2.06i has 789 objects and v2.01i has 786.
Each tree writes it in `<tree>/hdae5000_ui_tree.s`, one class-macro line per object, nested:

```
	TtlScreenR	HDDMENU, x=0, y=0, w=320, h=240, exit=TITLE_DKMENU, window=HdaeUiVar_HDDMENU_window, icon=idICON_i129, title="HD-AE5000"
	ui_sub
		AcScreenMenu	HDDMENU_SETUP_TOOLS, x=8, y=72, w=149, h=26, editsw=ES_Left2, selected=HdaeUiVar_HDDMENU_SETUP_TOOLS_selected, screen=HDAE5000_OBJ_SETUPS_TOOLS, icon=idICON_i6, str="SETUP & TOOLS  "
		AcScreenMenu	HDDMENU_Go_LOAD_BY_NUM, x=163, y=114, w=149, h=26, editsw=ES_Right3, ..., screen=HDAE5000_OBJ_LOAD_BY_NUM, icon=idICON_i172, str=""
		ui_sub
			AcLanguageText1	HDDMENU_Go_LOAD_BY_NUM_Text6, x=170, y=114, w=112, h=32, index=6, font=idCHARA1, fontcolor=CL_White, alignment=AL_LeftJustify, lines=2
		ui_endsub
		...
	ui_endsub
```

How to read one line:

- The **macro** is the object's NAKA class, by name. There is one macro per class the HD-AE5000
  instantiates (42), in `hdae5000/shared/naka_ui_macros.s`, which both trees share.
- The **parameters** are the firmware's own field names. They are the `propname` lists of the class
  chain: the main CPU's class tables for the 0x160 classes, and `HDAE5000_RECORD_TABLE` for the
  HD-AE5000's own 13 classes in table 0x16A.
- Each class macro's header comment lists every field with its offset and type letter.
- The geometry is `x, y, w, h`. The record stores `Viewable.rect` as x1, y1, x2, y2 inclusive.
- The first argument is the **object's name**. That is the firmware's resource name wherever its
  name table has one (178 objects). Otherwise the name is made up from the parent, then the
  caption, the object it opens, its language text or its class (`HDDMENU_Go_LOAD_BY_NUM`,
  `SELECT_DIR_Exit_HDDMENU`, `..._Text6`).
- The **nesting** is the tree. The macros number the objects in the order they appear, and compute
  each record's `super` / `sub` / `next` / `prev` from the nesting. No index is written anywhere.
- A string field is either `fld="text"`, an inline caption stored after the record, or
  `fld_at=Label`, a pointer to a string elsewhere.
- Values are spelled by name wherever the firmware or the source has one:
  - object ids: `HDAE5000_OBJ_<name>`, `NAKA_NO_OBJECT`;
  - function ids: `NAKA_APFUNC_*`, `NAKA_MAINFUNC_*`. The procedure is `HDAE5000_<name>`;
  - titles: `TITLE_*`;
  - property values by the firmware's own names, read from the main CPU's
    `SupportClass_PropTypeRecords` (one entry per propdata letter): colours `CL_*`, borders `BD_*`,
    alignment `AL_*`, edit switches `ES_*`, styles `SS_*`, line modes `LM_*`, view flags `VF_*`
    (OR-ed); fonts and icons as their dump names `idCHARA1`, `idICON_i6` (FontIDProc / IconIDProc
    name tables). These are the same names the main-CPU GUI lane (gui-kn5000) uses in its C;
  - RAM-variable pointers: `HdaeUiVar_<object>_<field>`, the label of the variable's initial value
    in the `.data` image.
- `ui_ram_object NAME, Class` marks one of the 20 objects whose record lives in the `.data` image.
  Its record is written with the same class macro between `ui_ram_records` and
  `ui_ram_records_end` in `hdae5000_init_data.s`. The macro checks that the class there is the same.
- `ui_object_table` generates `HDAE5000_UiObject_PtrTable` from the tree, and `ui_name_table`
  generates `HDAE5000_UiObjectName_PtrTable`. Each holds one entry per object, in tree order.
  The name pool is one `ui_name` / `ui_noname` line per object.
- The macros also define:
  - `HDAE5000_OBJ_<name>` (0x007F0000 + index), so the code's object-id constants now come from
    the tree;
  - `HdaeUi_<name>`, the record;
  - `HdaeUi_<name>_<field>`, a caption;
  - `HdaeUiRam_<name>`, a `.data`-image record;
  - `HdaeUiName_<name>`, the name string;
  - `HDAE5000_UI_OBJECT_COUNT`.
- The UI state block of `hdae5000_init_data.s` holds the initial values of the RAM variables the
  records point at. Each variable now has a `HdaeUiVar_<object>_<field>` label: 322 in v2.06i and
  318 in v2.01i.

The index of the whole GUI is generated: [`menu-map-v2_06i.md`](menu-map-v2_06i.md) and
[`menu-map-v2_01i.md`](menu-map-v2_01i.md). Each map lists the 78 top-level screens, windows and
dialogs, then for each one:

- its class, caption and geometry;
- what opens it. That is the object-id fields of other objects (`AcScreenMenu.screen` buttons,
  `IvExitScreen.screen` EXITs, `IvPageControl.window` page switches) and the routines that name its id;
- its children, nested, with their switch, handler, destination and code references.

## Tools

| script                                             | job                                                                                                                                                               | run                                                                             |
|----------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| `scripts/converters/hdae5000_ui_tree.py`           | wrote the tree, the macro file, the tables, the state-block labels and the RAM records from the ROM; idempotent on the built tree; refuses on any layout surprise | `python3 scripts/converters/hdae5000_ui_tree.py v2_06i v2_01i --macros --write` |
| `scripts/analysis/hdae5000_menu_map.py`            | the menu maps, from the source; `--check` is in `make gate`                                                                                                       | `make hdae5000-menu-map`                                                        |
| `scripts/analysis/hdae5000_gui_readability.py`     | the readability census (below); reads either source form, `--rev` for a past revision                                                                             | `python3 scripts/analysis/hdae5000_gui_readability.py [--rev REV]`              |
| `scripts/analysis/hdae5000_obj_constants_check.py` | every `HDAE5000_OBJ_*` (from the ELF) against the reference image's name table; in `make gate`, rewritten for the tree                                            | `python3 scripts/analysis/hdae5000_obj_constants_check.py`                      |
| `probes/tree_preorder.py`                          | ROM-only proof that the nesting is lossless                                                                                                                       | see `probes/README.md`                                                          |
| `probes/editsw_geometry.py`                        | geometric cross-check of the `ES_*` switch names                                                                                                                  | see `probes/README.md`                                                          |

`scripts/tools/port_hdae5000_version.py uitables <ver>` now runs the converter. The retired
`scripts/generators/gen_hdae5000_ui_pool.py` wrote the previous form, typed records with numeric
links. Its model lived on as a copy in the port tool, where it is still used by `tables`.

## Evidence

Each claim below is followed by the code or probe that backs it.

- **Every record starts with its class id `0x016S_KKKK`**: Class table 0x16S, entry KKKK.
  - Backing: `ClassProc` in the main CPU (`srl 16; and 0xFFF`, then ×24), and
    `HDAE5000_Handler_Registration`, which registers this ROM's 13 classes as table 0x16A
    (class id `NAKA_CLASS_Class`, `RootFn_ClassProc`, count `HDAE5000_RECORD_COUNT`).
  - Every record of both versions resolves to a class. The converter refuses otherwise.
- **The record's fields are its class chain's propname fields**, and they sum to `allsize`.
  - Backing: `scripts/analysis/nakarest_objtab_map.py` (THE CLASS SYSTEM) for the main CPU's classes;
    `HDAE5000_RECORD_TABLE` and `notes/hdae-class-records-2026-10-02/hdae_class_fields_probe.py` for the
    HD-AE5000's own.
  - The converter checks the sum for every class.
  - In every record of both versions, the inline captions start exactly at `allsize`.
- **Links.** Viewable +4 `super`, +6 `sub`, +8 `next` and +10 `prev` are object indices.
  - The table is the preorder walk of the forest they describe. Measured with `probes/tree_preorder.py`:
    - v2.06i: 789 objects, 78 roots;
    - v2.01i: 786 objects, 78 roots;
    - both: 0 inconsistent links, no root linked to another, and preorder equal to table order.
  - The earlier symmetry evidence is `analysis/wave7-probes/verify_hdae5000_ui_pool.py`.
  - So the nesting carries all the information, and the macros reproduce the links byte for byte (`make gate`).
- **Rect**: +14 is x1, y1, x2, y2. In the 769 v2.06i pool records it fits 0..321 / 0..239 at +14 and at no
  other offset (`verify_hdae5000_ui_pool.py`). Record 0 (HDDMENU) is 0,0-319,239.
- **Edit switches**: the firmware's own names for `editsw` values (`SupportClass_PropTypeRecords`
  letter 'e') are `ES_Bottom1-8` = 0-7, `ES_Right1-5` = 8-12, `ES_Left1-5` = 0x88-0x8C, `ES_Exit` =
  0x0F and `ES_None` = 0xFF, matching ui-framework.md's `GetEditSwPoint` numbering. The geometric
  cross-check is `probes/editsw_geometry.py`: in both versions every object carrying a side-row value
  sits on that side at that row's height (y 42-49, 84-92, 126, 168, 204-211), and every Bottom value
  on the bottom row (y 227-230). The 39 objects with `ES_None` are all mid-screen.
- **Property value names**: read exactly as the main-CPU GUI lane's
  `scripts/generators/gen_naka_gui_headers.py` reads them (`hdae5000_ui_tree.py`, `HostClasses.prop_types`),
  from the v10 build. Every font, colour, border, icon, style, alignment, line-mode and flag value of
  both versions has a name there.
- **Function ids**: 0x012A0000 + k is entry k of the HD-AE5000's ApFunction table (registered as
  0x12A: `HDAE5000_ObjHandler_Table`, names `HDAE5000_ObjName_Table`). 0x014A0000 + k is entry k of
  its MainFunction table (`HDAE5000_ScreenProc_Table`, names `HDAE5000_ScreenName_Table`). The names
  are the firmware's own, and the routine labels already carry them.
  - v2.06i: 77 constants are defined in `hdae5000_ui_tree.s` because `shared/event_codes.s` lacks them.
  - v2.01i: 75 constants.
- **Object ids**: 0x007F0000 + index. `RootFn_ViewableProc` is registered for table 0x7F by
  `HDAE5000_Handler_Registration`.
- **RAM variables**: every field of type m, n, r or s in every record of both versions points into the
  `.data` image's RAM copy, inside the state block. No two fields share a variable. The converter
  refuses otherwise.
  - [INFERENCE] What a variable holds is known only from the field's firmware name. No code in this
    ROM spells one of those RAM addresses.

## Readability census, before and after

`python3 scripts/analysis/hdae5000_gui_readability.py --rev 9dbc03088`, the lane's base, compared
with the working tree after this lane's commits:

| tree            | when   | objects | class_numeric | links_numeric | addr_numeric | fields_unnamed | state_unlabelled | style_numeric |
|-----------------|--------|---------|---------------|---------------|--------------|----------------|------------------|---------------|
| hdae5000        | before | 789     | 789           | 3,156         | 520          | 6,379          | 497              | -             |
| hdae5000        | after  | 789     | 0             | 0             | 0            | 0              | 0                | 0             |
| hdae5000_v2_01i | before | 786     | 786           | 3,144         | 516          | 6,314          | 491              | -             |
| hdae5000_v2_01i | after  | 786     | 0             | 0             | 0            | 0              | 0                | 0             |

`style_numeric` counts the font, colour, border, icon, style, alignment and line-mode values, defaults
included, that are still plain numbers. Before, they were part of the 6,379 unnamed "class body"
words. After the switch to the firmware's value names, which came late in the lane, none is left.
At commit f5599830a, before that switch, 2,939 / 2,913 were still numeric.

`data_incbin_census.py`: `kn5000-hdae5000` and `kn5000-hdae201` are generic 0. Their 10 `.incbin`s
each are the generated images. This lane added no `.incbin`.

## Conventions shared with the other GUI lanes

By its commit ff38e293f, the main-CPU lane (gui-kn5000) writes its C records with the same model:

- one type per NAKA class, the propname fields;
- `NAKA_XYWH` geometry;
- links named, with the table in preorder;
- the firmware's own value names (`CL_*`, `ES_*`, ...).

This lane's assembler form follows it:

- class macros named by the class;
- the same field names;
- `x, y, w, h`;
- the same value names, read the same way from the same table;
- `NAKA_NONE` (0xFFFF) for a missing link.

`NAKA_NO_OBJECT` (0xFFFFFFFF) is this lane's name for an empty object-id field. The C side spells it
otherwise, and one shared name would be better. A shared assembler include of the value names
(`.equ` twins of `naka_classes.h`'s `#define`s) would let `naka_ui_macros.s` drop its guarded copies:

- the `.ifndef`-guarded value names;
- the `NAKA_CLASS_*` constants that `shared/event_codes.s` lacks.

That is proposed, not done: the main-CPU header is theirs.

## Open questions

1. **Button texts.** The 122 `AcLanguageText1` objects draw entry `index` of a language text.
   `NAKA_APFUNC_LanguageTextReturn` (`HDAE5000_LanguageTextReturn`) answers `EVT_GET_LANGUAGE_PTR` with
   `HDAE5000_TextPtrs_LANENG001_to_LANENG006`. That table holds six resource names (`LANENG001`,
   `LANDEU002`, `LANFRA003` ...), not texts.
   - The texts themselves are not in this ROM. Where the main CPU loads `LANxxxnnn` from is not traced.
   - Until it is, many buttons show as `text #n` and their names fall back to the destination they open.
2. **Fonts / icons.** These are named by their dump names (`idCHARA1`, `idICON_i129`), which are
   the firmware's own but terse. What each icon looks like is not in this lane's notes.
3. **Handles in the state block.** Some 8-byte state variables (`SelectList.str_adr` and others) start
   with words 0x0070xxxx.
   - [INFERENCE] These are run-time handles. No code of this ROM names them.
4. **Registration code.** `HDAE5000_Handler_Registration` still loads the RAM tables by number, for
   example `lda xwa, (0x2397ea:24)`.
   - The `.equ` names of some of them are misnomers. In `hdae5000_ui_display.s`,
     `HDAE5000_RAM_DATA_A_SIZE` = 0x239822 is the ResEvent count and `HDAE5000_SERIAL_DATA_1` =
     0x239872 is the Function table.
   - This is code, not GUI data, so it was left for a code lane.
5. **C.** The GUI brief assumes the HD-AE5000 tree already compiles C. It does not. Its 10 generated
   includes are the PNG-built images (`scripts/build/hdae5000_images.py`).
   - Assembler macros were used instead. They let the tree compute its links from the nesting, which
     C initialisers could not do without a generator.
6. **Older versions.** v1.10i / v1.15i (private romset) are not ported. The converter's `VERSIONS`
   table would need their trees.

## Shared files touched

- `Makefile`: `make gate` runs `hdae5000_menu_map.py --check`, and a new target `hdae5000-menu-map`
  was added. Two small blocks.
- `CLAUDE.md` was **not** edited. Its symbol table now understates two rows: `hdae5000` went from
  5,298 to 7,197 symbols and `hdae5000_v2_01i` from 5,209 to 7,099. Both counts come from
  `l2_symbol_reference.py --regen`, and the integrator should update them.

## Website page draft

For `technics-docs/hdae5000.md`, replacing the pool rows of the memory table:

> | 0x29DC12-0x2A5D2B | 33,050 | UI object pool: 769 objects of the GUI tree in `hdae5000/hdae5000_ui_tree.s` (one NAKA class macro per object, nested; `scripts/converters/hdae5000_ui_tree.py`) |
> | 0x2A5D2C | `HDAE5000_UiObject_PtrTable` | object table 0x7F, generated from the tree (`ui_object_table`) |

The paragraph on "Caution: 0x2A477C is not a structure boundary" should end like this:

> The GUI is now written as a tree (`hdae5000/hdae5000_ui_tree.s`). Each object is one line naming
> its NAKA class and its fields by their firmware names, and `ui_sub` / `ui_endsub` nest the
> children. The macros of `hdae5000/shared/naka_ui_macros.s` compute every object index and
> parent / child / sibling link from that nesting: in both v2.06i and v2.01i the object table is the
> preorder walk of the tree. No class body is undecoded any more. The generated menu map
> (`notes/data-gui-hdae5000-2026-10-29/menu-map-v2_06i.md`) lists the 78 screens and dialogs, what
> opens each, and their widgets.

For `technics-docs/hdae5000-resources.md`, line 23 should read:

> | 0x29DC12 | 33,050 | The 769 UI objects, as a tree of class macros, every field named |

Line 188 should replace `HdaeUiName_789` / `HdaeUiName_000` with: the pool is
`HDAE5000_UiObjectName_Pool`, one `ui_name` / `ui_noname` line per object, highest index first.

For `technics-docs/ui-framework.md`, a short "HD-AE5000" note under "Field names come from the firmware":

> The HD-AE5000's 789 objects (v2.06i) are written in exactly this model, one macro per class with the
> propname fields as parameters (`hdae5000/shared/naka_ui_macros.s`). Its `editsw` values follow the
> switch numbering above: `ES_Left2` = 0x89 is the left side row 2, and the record values use the firmware names (`CL_*`, `BD_*`, `ES_*`, `idCHARA*`, ...).
