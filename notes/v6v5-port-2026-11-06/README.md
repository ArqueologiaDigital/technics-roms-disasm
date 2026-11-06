# Lane v6v5-port (wave 10, 2026-11-06): the v6 / v5 TODO(port) rows and the C-divergence raw bytes

Base main a385de42f, branch `open10/v6v5-port`.  Items: T-kn5000-v6-todo-port, N-92c1dcce,
T-kn5000-v5-todo-port, N-2a3d2074 of `notes/open-items/REGISTER.md`.  Every change is made by a tool step
that the trees' READMEs (`v6/maincpu/README.md`, `v5/maincpu/README.md`, "After generation") now list, so
a regeneration redoes it; both images stay byte-identical after each step (`make gate`).

## What the rows were, and what writes them now

`probes/classify.py` (README below) sorted the 3,403 (v6) / 4,284 (v5) row bytes by the NAKA object
`scripts/analysis/nakarest_objtab_map.py` places over them: v6 2,026 B in registered objects (tables 1,094,
records 340, names 328, propnames 184, class definitions 68, texts 12), the rest work-RAM cells (696),
naming-window character strings (232), code (~220) and small items; v5 likewise (2,537 B in objects).

| tool (commit)                                                                   | what it writes                                                                                                                                                                                                                                                                                                                                                 |
|---------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `scripts/converters/port_todo_naka.py` (new; 6d833a518 and later)               | the registered NAKA objects: table entries `.long`, whole records `NAKA_REC_<Class>`, partial records / class definitions one line per field, strings, the work-RAM cells the tree's own records point at, RegObjTable count words, a zero Class slot past the count, NULLs after tables, the rest of a pointer table; new labels named from the registrations |
| `scripts/converters/disassemble_port_todo.py` (6d833a518, 01e041572, 41e87ea64) | code blocks through further porter markers and widened over neighbour lines; `HAND_REGIONS` (three regions v7 spells as bytes); case-offset tables `.short Case - Base` with the reader's base; new labels take the source tree's name for the same bytes                                                                                                      |
| `scripts/tools/port_todo_hand.py` (new; 782e0ec39)                              | the four items read by hand, each with its evidence in the docstring (scoop TEMPO templates and their swapped labels, AccPatch_ChannelToRecordPtr, v5's MSCTSEL_13 rect, v5's two-part ON radio lists)                                                                                                                                                         |
| `scripts/converters/ported_c_rebase.py --ram-self` (0e94f07e4)                  | naka_sequencer_channels' 64 work-RAM self-pointers (halfword pairs field_1624..field_1722 before) as `Naka_DrawbarReg_Table_RamPtrs[64]` = `NAKA_WRAM(Naka_DrawbarReg_Table[16 / 29 / 42 / 55])`                                                                                                                                                               |

Label fixes on the way (the port had left names on the wrong thing): `Str_TempoEq` /
`DisplayStr_BytecodeBlock_C_Tbl` back on the templates DisplayStr_ShowTempoLine loads (it loaded the 0x93
one as the number 0xefedbf), v7's `DisplayStr_TempoString` / `_Tbl2` / `DisplayStr_RedrawStatusAndTempoLine`
(was `SqStep_ShowTempoPopup`) / `_Helper3_Skip` on the second pair; v7's `CmpStep_DrawScreen` on the routine
CmpStepTitle_OnPaint_Draw calls (a numeric call before); `VoiceSlot_Dispatch_CaseTable`'s numeric base
0xf666d2 is `VoiceSlot_Dispatch_Case0`.  `check_ported_labels.py`: misplaced v7->v6 112 and v6->v5 16 before
and after; the new labels read as only-in-v6 / only-in-v5.  `ported_label_probe.py`: MISMATCH rows 5 in each
tree before and after (already 5 at a385de42f, not 0 as the READMEs say).

## Measurements

`scripts/analysis/kn5000_source_coverage.py` (verbatim debt = TODO(port) rows + json raw bytes);
`probes/todo_blocks.py` lists the rows block by block.

| step (commit)                              | v6 rows | v6 raw | v6 debt | v5 rows | v5 raw | v5 debt |
|--------------------------------------------|---------|--------|---------|---------|--------|---------|
| before (a385de42f)                         | 3,403   | 212    | 3,615   | 4,284   | 220    | 4,504   |
| NAKA objects + widened code (323b6bc89)    | 180     | 212    | 392     | 367     | 220    | 587     |
| counts, zero slot, NULLs (e1232dfd8)       | 134     | 212    | 346     | 321     | 220    | 541     |
| pointer tables, hand regions, cut pointers | 122     | 212    | 334     | 189     | 220    | 409     |
| case-offset tables (ffaf237f3)             | 96      | 212    | 308     | 141     | 220    | 361     |
| hand edits (335639256)                     | 2       | 212    | 214     | 7       | 220    | 227     |
| work-RAM self-pointers (ff0fb778b)         | 2       | 148    | 150     | 7       | 156    | 163     |

Source share 99.8 % -> 100.0 % in both trees (150 / 163 B of 2,097,152).

## What remains (all items stay OPEN, with the exact next step)

> **Superseded (wave 11, lane open11/v6v5-port2, `notes/v6v5-port2-2026-11-06/README.md`):** the TODO(port)
> rows are gone, the json raw bytes are 5 per tree, the straddling records are typed and the 52-byte blocks
> are traced (entries 17 / 30 / 43 / 56, the bass-note spelling blocks).  What is left is listed there.

- TODO(port) rows, v6 2 B, v5 7 B: halves of pointers that a C slice boundary cuts
  (`widget_names_charmap.s` after WidgetName_PtrBlock_B2, v5 also after WidgetName_PtrBlock_N1;
  v5 `extension_data.s` before ExtData_ChordTypeTable_Top).  The assembler takes `Sym@lo16` only in an
  instruction immediate (`.short X@lo16`: "@hi16/@lo16 needs a 16-bit immediate").  Next step: cut the C
  slices at the pointer's start instead (the bin's .incbin lengths), or teach the TLCS-900 backend a 16-bit
  data fixup for @lo16 / @hi16.
- json raw bytes, v6 148 / v5 156: naka_widget_descriptors 42 (the SQEDT RamPtrs tables and SndArgNmGet
  RamPtrs: main-RAM variable addresses, which need v6 / v5 RAM names -- there is no
  `ram_variables_by_use.s` in these trees -- and Tempo_AdjustEffect_Table 10), gui_display_struct_data 30,
  accomp_display_full 12 / 16, naka_sound_menu_drawbar 12 / 13, se_name_editor 12, tonegen_param_table 12,
  small others.  Next step: `notes/kn5000-c-2026-11-02/probes/cdiv_members.py` per bin, then give v6 / v5
  RAM names for the RamPtrs (port v7's `ram_variables_by_use.s` values through the porter's operand map).
- Hand-over from lane kn5000-notes (main 55860e8d7, merged before the final gates): after the json was
  regenerated, `naka_type_straddling_records.py --tree v6 / v5 --apply` refused naka_technichord_part.c's 8
  records ("DIFFERS": the retyped C would compile to another blob, because these trees' C holds v10's values
  there and the json's 6 / 8 raw bytes patch them).  It typed naka_widget_names_charmap.c's record
  (NakaWidget_PanelSimulator), but `make gate`'s gui-check then failed: `naka_gui_symbolize.py --tree v6
  --apply` refuses to spell that record ("DIFFERS", the same cause) and `--check` reports it stale.  The
  charmap typing was therefore reverted (both trees; the commit that did it is 607f48c77).  Next step: give
  those records their own v6 / v5 values in the C (the json raw bytes say which), then rerun
  naka_type_straddling_records.py and naka_gui_symbolize.py.
- The 52-byte blocks inside `Naka_DrawbarReg_Table[69]` that the RamPtrs point at (entries 16, 29, 42, 55)
  are typed as table entries by the C; what they are (likely view records kept in work RAM) is not traced.

## Probes

| script                  | question it answers                                                                          | run                                                                                  |
|-------------------------|----------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------|
| `probes/todo_blocks.py` | which TODO(port) blocks does a ported tree still have (bytes, labels, preview)?              | `python3 notes/v6v5-port-2026-11-06/probes/todo_blocks.py v6`                        |
| `probes/classify.py`    | which NAKA object (nakarest_objtab_map Map) covers each TODO(port) row byte?                 | `python3 notes/v6v5-port-2026-11-06/probes/classify.py v6` (tree built)              |
| `probes/cells.py`       | which of the tree's records point into a block of the work-RAM image, at which cell offsets? | `python3 notes/v6v5-port-2026-11-06/probes/cells.py v6 Murai_SoundMenuWorkCells 696` |

## Website page draft (`rom-reconstruction.md`, the v6 / v5 rows)

> Since 2026-11-06 the v6 and v5 trees have almost no port debt left: the bytes no v7 / v6 line mapped to
> are written as the NAKA objects the firmware registers (tables, widget records, class definitions,
> strings, work-RAM cells), as decoded code, or as case-offset tables, and the C spells its work-RAM
> self-pointers.  Verbatim debt is 150 B (v6) and 163 B (v5), 100.0 % source: halves of pointers cut by
> a C slice boundary and 148 / 156 raw bytes of the C-divergence patch.
