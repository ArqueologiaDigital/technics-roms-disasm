# Lane kn5000-c (wave 6, 2026-11-02): v6 / v5 C port debt, NAKA C numbers and strings, sequencer edit RAM

Base main c240d1c0b, branch `open6/kn5000-c` (main b71d87c75 merged before the final gate).  Items: the
KN5000 rows N-2f640c1d, N-45db7885, N-c49a6232, N-d8cf1242, N-7c99f0f2, N-e40b7174, N-51b2e19c,
T-kn5000-v6-todo-port and T-kn5000-v5-todo-port of `notes/open-items/REGISTER.md`.  Every edit was applied
to v10, v9 (v8 builds from it), v7, v6 and v5, rebuilt and gated (`make gate`, exit 0).  Probes:
`probes/` (README there).

## The v6 / v5 C port debt (T-kn5000-v6-todo-port, T-kn5000-v5-todo-port)

v6/maincpu and v5/maincpu compile v7's C data and patch the result with
`<tree>/maincpu/includes/<tree>_c_divergence.json` (`scripts/build/apply_c_divergence.py`):
`reloc` entries move a 4-byte aligned pointer, `raw` entries replace single bytes, and
`kn5000_source_coverage.py` counts every raw byte as verbatim debt.  `probes/cdiv_members.py` maps each raw
byte to the C member that holds it (from DWARF) and `probes/cdiv_kinds.py` classifies it: almost all of
them were pointers, not content.

| why the C compiled another byte                                                                                                                                             | fix                                                            |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------|
| `#define BASE` is v7's blob address, so every SELF() pointer is off by the blob's move; at an odd or 2-mod-4 offset inside a packed record a pointer cannot be a relocation | `--set-base`: BASE = the blob's address in the tree            |
| the port moved parts of eight blobs (their labelled slices imply several bases)                                                                                             | `--set-base --need-dir`: `PORT_BASE(off)` chain used by SELF() |
| the widget records point at work-RAM cells, and v6 / v5 place 652 of the 1,892 cells lower                                                                                  | `gen_naka_gui_headers.py`: per-tree `naka_ram_cells.h`         |
| bytes of a bin that no `.incbin` places (the port spells those tables as `.long Str_X` rows)                                                                                | `--regen` compares placed bytes only                           |
| the function-name pointer tables of naka_widget_names_charmap point at strings the port re-ordered                                                                          | `--name-pointers`: NAKA_ADDR(<the string's label>)             |

All in `scripts/converters/ported_c_rebase.py` (docstring: the steps and their order; it reads no ROM
bytes, `--need` derives the bytes the tree needs from the committed C + json and checks them against the
build).  The regeneration sequence of `v6/maincpu/README.md` / `v5/maincpu/README.md` now ends with these
steps.

`kn5000_source_coverage.py`, verbatim debt (TODO(port) rows + json raw bytes):

| step (commit)                                           | v6 rows | v6 raw | v6 debt | v5 rows | v5 raw | v5 debt |
|---------------------------------------------------------|---------|--------|---------|---------|--------|---------|
| before (c240d1c0b)                                      | 3,403   | 10,353 | 13,756  | 4,284   | 11,626 | 15,910  |
| own BASE (1becec8c9)                                    | 3,403   | 2,528  | 5,931   | 4,284   | 2,704  | 6,988   |
| PORT_BASE, own RAM cells, placed bytes only (0c9eb932d) | 3,403   | 804    | 4,207   | 4,284   | 778    | 5,062   |
| name tables by label (3f4df7a2e)                        | 3,403   | 237    | 3,640   | 4,284   | 253    | 4,537   |
| new labels at each tree's own address (after the merge) | 3,403   | 212    | 3,615   | 4,284   | 220    | 4,504   |

Source share 99.3 % -> 99.8 % (v6), 99.2 % -> 99.8 % (v5).  Relocations rose (they are not debt): a moved
SELF pointer that was raw bytes is now a relocation where it is aligned, or exact.

What remains (the items stay OPEN):

- the TODO(port) `.byte` rows, 3,403 B (v6) / 4,284 B (v5), unchanged by this lane: bytes no v7 / v6 line
  maps to (mostly data beside v7's C data and pointer tables, `v6/maincpu/README.md`).  Next step: type
  them per blob (records the newer tree lacks), or disassemble the code rows `disassemble_port_todo.py`
  did not reach.
- the json raw bytes, 212 / 220 (237 / 253 before the last step; `cdiv_kinds.py`, at 237: v6 106 in pointers, 74 in work-RAM pointers, 57 other):
  `naka_sequencer_channels` 64 (32-bit RAM pointers typed as two uint16_t field_XXXX each, offsets
  0x1624-0x1720: type them as RAM_ cells and the header fixes them), `naka_widget_descriptors` 67 (the
  SQEDT RamPtrs tables, 18 B, which v6 / v5 cannot name until they have RAM names, and East_ClassTable_163),
  `gui_display_struct_data` 30, `tonegen_param_table` 12, `se_name_editor` 12, small others.  The v6 / v5
  RAM names (no `ram_variables_by_use.s` there) are the precondition for most of the rest.

## Numeric ROM addresses in the NAKA C (N-45db7885)

`naka_gui_census.py` rom addrs: v10 / v9 / v7 73 -> 9, v6 / v5 75 -> 11.

| what the numbers were                                                              | now                                                                                     | count |
|------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|-------|
| class descriptors' name / propdata pointers into `aligned_string` lines of the asm | `ClassName_<Class>` / `ClassPropdata_<Class>` labels (name_class_descriptor_strings.py) | 48    |
| IvMesage_Windows: six "addresses" 0x00EE00xx                                       | view ids `NAKA_VIEW_ID(Murai_ViewableTable_0EE, k)` with the OBJ_ name                  | 6     |
| FDemoText_MarkupTag_HandlerColumn's handler words                                  | `FDemoText_Tag_<TAG>` routine labels with headers (label_fdemo_markup_tag_handlers.py)  | 9     |
| MetPunchSw.stron, into a string cut across members                                 | `SELF(MetPunchSw_StrOn)`, the two texts retyped                                         | 1     |

Twelve propdata strings named `NakaInst_*` after the record that follows them are `ClassPropdata_<Class>`
(`scripts/renaming/rename_class_propdata_labels.sed`).

Left, 9 per tree (v6 / v5 11): all are fields of records typed with the wrong layout, the
N-2f640c1d population: `.link_ptr = 0x00EB0000` (x2, naka_disk_menu_file_io.c w37 / w91),
`.inst_ptr = 0x00F40008` (naka_direct_play.c w119), `.link_ptr = 0x00FB0020` (naka_technichord_part.c
w66): `naka_dispatch_t` overlays whose 32-bit fields are pairs of 16-bit coordinates; `.handler =
0x00E0FC10 / 0x00E0FC3C` (naka_perf_style.c w73 / w74) and `0x00E850A8 / 0x00E8512C`
(naka_technichord_part.c w91 / w94): old EditSw overlays whose `handler` points at the record's own tail
text; `.ptr_0d72 = 0x00E000CA` (naka_disk_warning.c).  v6 / v5 also keep IvMPver's class strings
(0x00E81088 / 86): that class is not in v6 / v5, its descriptor stays in the C copy.  Next step: retype
those records by class (naka_cls_<Class>_t), which is N-2f640c1d.

## String runs as one member (N-c49a6232)

`scripts/converters/split_c_string_runs.py`: every `char X[N]` member whose bytes the assembly places as
two or more labelled slices that tile it, each a whole string (ends in NUL, or NUL + 0xFF), is one member
per slice, named by its label, and `SELF(X[k])` names the piece: 49 members in each tree (245 strings),
for example `East_ResNames_3EC_Strings[252]` (the item's example) -> 22 members.  The dry run afterwards
finds 3 tilings left, each with a label inside a string (a pointer to a string's interior).  Members whose
strings the assembly does not label one by one (no far pointer reaches them) keep one member: the C now
names exactly what the assembly names.

## Sequencer edit RAM (N-e40b7174)

- `naka_ram_cells.h` (gen_naka_gui_headers.py) ends with the tree's RAM `.equ` names that its NAKA C
  spells; `AppEvtHandler_Branch_002_RamPtrs` / `AppEvent_SubDispatch_RamPtrs` are `SQEDT_*_TRACK` (v10 /
  v9 / v7; v6 / v5 have no RAM names to use).
- `ram/seq_qtz_names.txt` (applied with `add_kn5000_ram_names.py`): SQEDT_QTZ_STRENGTH 0x2600,
  SQEDT_QTZ_WINDOW 0x2602, SEQ_QTZ_TICK 0x2638, SEQ_QTZ_ZONE_EDGE_A / _B 0x2640 / 0x2642, 44 operands per
  tree.  Evidence: the comments of each line.
- Left numeric: 0x263a / 0x263c / 0x263e (decimal 9786 / 9788 / 9790 in sequencer_engine.s), working values
  of the quantize engine (`SeqPart_VelExpr*`); next step, trace one quantize run (the routine labels
  `SeqPart_Vel*` are themselves misnomers for the quantize engine: `SeqPart_VelocityCurveCalc` reads
  SEQ_OP_QUANTIZE and picks a grid by it).

## Items not worked by this lane

| item       | state | exact next step                                                                                                                                                                                                           |
|------------|-------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| N-2f640c1d | OPEN  | 65 elements; the 9 numeric fields above are most likely among them.  Retype each straddling `naka_dispatch_t` / old EditSw overlay as its class's `naka_cls_<Class>_t` (naka_type_c_slices.py does the exact-member case) |
| N-d8cf1242 | OPEN  | 523 / 531 field_XX (2 fewer: MetPunchSw); trace the base-pointer readers of naka_sequencer_channels.c's 291 first                                                                                                         |
| N-7c99f0f2 | OPEN  | 81 titles; trace the Scoop sound-editor openers of TITLE_SE* (no traced code opens them yet)                                                                                                                              |
| N-51b2e19c | OPEN  | per-bit analysis with kn5000_ram_bit_usage.py of 0xC1FE / 0xC594-0xC59C, 0x28B2 / 0x28B3, 0x32F4 ..., 0xE3E2                                                                                                              |

The last step: the ClassName_ / ClassPropdata_ / FDemoText_Tag_ labels this lane added first carried v10's
value in every tree's link script (so no compiled byte changed).  For v7 / v6 / v5 they now carry the tree's
own address, as generate_v7_naka_link_scripts.py does for v7, and the jsons were recomputed
(`regenerate_v7_c_divergence.py --apply`: v7 patch bytes 3,237 -> 3,201; `ported_c_rebase.py --regen`).
Until then the dispatch census read the nine handler words of FDemoText_MarkupTag_HandlerColumn in v7 / v6 /
v5 as numeric (unframed_not_used 0 -> 1 in each).

## Corrections

- The message of 0c9eb932d says "652 of the 1,300 cells move": the header has 1,892 cells (652 move).

## Ledgers (read-only, after the merge, at the last commit)

- `make gate`: exit 0.
- `census.py --compare docs/coverage/dispatch-census-2026-10-31-03.json`: nothing rose.
- `doc_quality_census.py --compare` (doc-quality-2026-10-31-03): nothing rose ((b) numeric operands fell by 44 in
  v10 / v9 / v8 / v7: the quantize names).
- `data_incbin_census.py --compare` (newest data-incbin snapshot): exit 0, nothing rose.

## Website page draft (for `rom-reconstruction.md`, the v6 / v5 rows)

> Since 2026-11-02 the v6 and v5 trees compile their own C: each NAKA blob takes its own address
> (`#define BASE`, or a `PORT_BASE(off)` chain where the port moved parts of it), the work-RAM cell
> header carries their own addresses, and the re-ordered name tables name their strings.  The C-divergence
> patch shrank from 10,353 to 212 raw bytes (v6) and from 11,626 to 220 (v5); verbatim debt is now
> 3,615 B (v6, 99.8 % source) and 4,504 B (v5, 99.8 %), most of it TODO(port) rows.
