# Lane v6v5-port2 (wave 11, 2026-11-06): the last v6 / v5 TODO(port) rows, the C-divergence raw bytes

Base main 2bde950fa, branch `open11/v6v5-port2`.  Items: T-kn5000-v6-todo-port, T-kn5000-v5-todo-port,
N-92c1dcce, N-2a3d2074, N-594c48be, N-ece9781f of `notes/open-items/REGISTER.md` (wave 10's lane:
`notes/v6v5-port-2026-11-06/README.md`).  Every change is a tool step that `v6/maincpu/README.md` /
`v5/maincpu/README.md` ("After generation") now list; both images stay byte-identical after each step.

## Measurements

`python3 scripts/analysis/kn5000_source_coverage.py` (verbatim debt = TODO(port) rows + json raw bytes).
The json raw counts are the last line of `ported_c_rebase.py --regen`.

| step (commit)                                                       | v6 rows | v6 raw | v6 debt | v5 rows | v5 raw | v5 debt |
|---------------------------------------------------------------------|---------|--------|---------|---------|--------|---------|
| before (2bde950fa)                                                  | 2       | 148    | 150     | 7       | 156    | 163     |
| slices re-cut, `port_todo_hand.py` edits 5-7 (41204a5b2)            | 0       | 148    | 148     | 0       | 156    | 156     |
| RAM names, `port_ram_names.py` (ff2826ddd)                          | 0       | 148    | 148     | 0       | 156    | 156     |
| `--own-values`, `--hand-c`, then `--regen`                          | 0       | 27     | 27      | 0       | 23     | 23      |
| `port_todo_hand.py` edits 8-9 (tables out of the slices), `--regen` | 0       | 5      | 5       | 0       | 5      | 5       |

v6 per bin (`--regen`): naka_widget_descriptors 42 -> 0, gui_display_struct_data 30 -> 0, accomp_display_full
12 -> 0, naka_sound_menu_drawbar 12 -> 0, se_name_editor 12 -> 0, tonegen_param_table 12 -> 0,
naka_disk_warning 6 -> 0, naka_technichord_part 6 -> 5, accomp_part_widget 3 -> 0, naka_style_bitmaps 3 -> 0,
accomp_section_widget 2 -> 0, naka_disk_menu_file_io 2 -> 0, naka_technichord_strings 2 -> 0,
tonekit_param_blocks 2 -> 0, naka_ctrl_menu_body 1 -> 0, naka_widget_names_charmap 1 -> 0.  v5 likewise
(156 -> 5; its naka_widget_names_charmap byte at 0x2CCE went with the N1 re-cut: no `.incbin` places it).

Label checks after the last step: `check_ported_labels.py` v7 -> v6 misplaced 112 (112 before), only in v6
1,433 (1,421 before: the 12 new string labels); v6 -> v5 misplaced 16 (16 before).  `ported_label_probe.py`
MISMATCH rows 5 in each tree (5 before).  Symbols (`l2_symbol_reference.py --regen --only maincpu_v6,maincpu_v5`):
v6 54,171 -> 54,183, v5 54,147 -> 54,159.

## What each step did

- **The TODO(port) rows (T-kn5000-v6/v5-todo-port, N-92c1dcce).**  They were halves of pointers that a slice
  boundary cut.  `@lo16` / `@hi16` are not needed (the LLVM backend is unchanged): `port_todo_hand.py` edits 5-7
  move the slice boundary so the pointer is whole on the assembly side.  WidgetName_InitPtrTable's entry
  Str_InitializeUser19 (v6 0xeb16f0, v5 0xeb16d8; v7 cuts the table between its slices D and E, 2 bytes
  into an entry, so WidgetName_PtrBlock_E now starts at the next entry, bin offset 0x2C0A); v5's
  Str_MainDispatchEvent entry after WidgetName_PtrBlock_N1 (N1 keeps the 3 bytes that end the entry before);
  v5's chord-type entry 39, `.long ChordTypeStr_Type39`, with ExtData_ChordTypeTable_Top kept at its
  mid-entry address as `.set ExtData_ChordTypeTable_Top, MainChordPre_ChordTypeNames + 4 * 39 + 2` (two
  link scripts name it).  `command grep -rc 'TODO(port)' v6/maincpu v5/maincpu` finds none.
- **RAM names (N-2a3d2074, part 1).**  The trees were ported on 2026-10-24 from the v7 of before WP17
  (8cfaef2e0, the same day), so they had no `shared/ram_variables_by_use.s` and spelled those variables as
  numbers.  `scripts/converters/port_ram_names.py` writes each tree's copy (v6 from v7's, v5 from v6's),
  includes it from `shared/ram_variables.s` as v7 does, and runs `name_kn5000_ram.py --tree T --ref SRC
  --apply` (new `--ref`): every routine of the source tree with the same instruction shapes votes, operand
  by operand, for the tree's number where the source has the name; only agreeing votes apply, names without
  one are dropped (v6: 9 of 438).  v6 values against v7: 213 names -0x1c, 125 unchanged, 46 -0x24, 36 -0x1a,
  5 -6, 4 -4.  Numeric operands spelled by name: v6 10,416 + 404 ldmm + 11 wide pointers, v5 10,421 + 404 + 11.
- **The C's own values (N-2a3d2074, part 2).**  `ported_c_rebase.py --own-values` (docstring) makes each edit
  only when every placed byte that was right stays right and at least one wrong one is fixed:
  RAM names the source tree's C spells (the SQEDT RamPtrs tables: SQEDT_TRNS_TRACK = 0x2602 etc. in v6, now
  in v6's naka_ram_cells.h by gen_naka_gui_headers.py); link-script-only names given the tree's address
  (SE_TuningSystem_Names, SE_NoteDivision_Names, SE_NameEditor_CursorCoords_0/1, Accomp_*_Names; v7's
  value in a comment); numeric literals found by group testing (each literal of the candidate initializers
  gets a number k, the literals with bit b of k set are perturbed together, so the bytes that change spell
  which literal makes them: log2 N compiles); `#define`s (tonegen's SENTINEL 0x6B4A -> v6 0x6A21, the
  accomp screen blob's `_BASE`; a NAKA blob's BASE stays `--set-base`'s).  `--hand-c` writes the two
  initializers that were read as pointers but are coordinate pairs (below).  `port_todo_hand.py` edits 8-9
  take two pointer tables out of the C slices because their strings are the port's assembly lines: the
  ResEvent 0x1c1 names (v6 / v5 have no EV_MPVERSION: 9 names, Murai_ResEventCount_1C1 = 9) and
  NakaClass_AcBitEditBox_PropNames, now `.long Str_EV_<name>` / `.long NakaClass_AcBitEditBox_PropName_*`.
- **Records with their own values (N-594c48be).**  The 8 straddling records of naka_technichord_part.c
  (wave 10: "DIFFERS") were 6 / 8 raw bytes: one is `NakaData_DescriptorPad1_ptr`, which is not a pointer
  (the halfwords 8, 230: bytes 08 00 E6 00 in v10, v7, v6 and v5 while the label it was read as moves:
  0xE60008 in v10 / v7, 0xE6000E in v6, 0xE5FFF6 in v5) and is now `8u | 230u << 16`; the other five are the
  work-RAM cells below.  naka_technichord_strings' `Naka_PresentationRootState_ptr` is x2 = 319, y2 = 239 of
  FDemoText_ScreenClipRect (the C's own note says so) and is now `319u | 239u << 16`.
  naka_widget_names_charmap's raw byte (field_5670, a work-RAM cell pointer half: 0xF0AC -> v6 0xF0A8) is a
  number the C now spells with v6's value.  `naka_type_straddling_records.py` read v10's bytes for v7 / v6 /
  v5; for v6 / v5 it now reads what the tree's own C compiles to, and typed the 8 + 1 records in both trees
  (IDENTICAL); `naka_gui_symbolize.py --tree v6|v5 --apply` and `--headers --apply` spelled them, `--check`
  reports both trees up to date.
- **The 52-byte blocks (N-ece9781f).**  They are not at entries 16 / 29 / 42 / 55: v6's NAKA_WRAM took the
  blob's one BASE, but from the slice at bin offset 0xC48 on v6 (and v5) place the blob 4 bytes lower, so
  `NAKA_WRAM(Naka_DrawbarReg_Table[16])` compiled to the RAM copy of entry 17.  `ported_c_rebase.py
  --ram-self-pieces` makes NAKA_WRAM piecewise (`WRAM_BASE(off)`, from the slices as PORT_BASE is) and the
  elements now read entries 17, 30, 43 and 56 (bytes unchanged).  What they are, from the reader
  MainChordPre_AppendChordSuffix (`kn5000_v10_program.s`; `lda xbc, (0x3f2f8:24)`, v6 / v5 0x3f2f4):
  Naka_DrawbarReg_Table is 12 wallpaper-palette pointers (entries 0-11), 5 other pointers (12-16:
  EditSw_PageMap2, EditSw_PageMap4, VariScreen_EditSwLayout6, VariScreen_EditSwLayout8, EditSw_SplitMap10)
  and four 13-entry blocks (17-29, 30-42, 43-55, 56-68), which end the 69-entry table exactly.  The 64
  pointers after it (Naka_DrawbarReg_Table_RamPtrs) are one per CHORD TYPE (DISPLAY_CHORD_TYPE, 0-63, the
  64 chord-type names of MainChordPre_ChordTypeNames); each names one block; the block is indexed by the
  chord ROOT (DISPLAY_CHORD_ROOT) and gives a 16-entry note-name table, which the BASS note
  (DISPLAY_CHORD_BASS) indexes: the bass-note name MainChordPre appends to the chord display after
  "on".  The blocks choose flat (SeqChanContainer_ChordTypeRef_A: "D~a0" = Db ...) or sharp (_B: "C~9e" =
  C# ...) spelling per root, like a key signature: block 17 (49 chord types, the major family) flats for
  Db, Eb, F, Ab, Bb and sharps for D, E, F#, G, A, B; block 30 (types 5 6 7 9 17 19 21 22 39, minor family)
  flats also for G; block 43 (types 8 20 27: m7(b5), m(b5), mM7(b5)) flats but for F# and B; block 56
  (types 13 14 25: (b5), 7(b5), M7(b5)) the mixed tables NoteNameStr_Table_1..3 for D, E and A.  Roots are
  MainChordPre_RootNames' indices (1 = C .. 12 = B, 0 = none).  `probes/bass_name_tables.py` prints it; v10 and v6 hold the
  same blocks.  Suggested names for the owning lane (v10 / v9 / v7 NAKA C is not this lane's):
  `MainChordPre_BassNameBlocks` for entries 17-68 and `MainChordPre_BassNameBlockByType` for the RamPtrs.

## What remains

- **v6 5 B, v5 5 raw json bytes: work-RAM cells after RAM_MPVersion_Window.**  v6 / v5 have no MPVersion view,
  so their Murai_SoundMenuWorkCells (assembly, `ui_widgets/sequencer_channel_containers.s`) lack the 4-byte
  MPVersion window cell and the five cells after it (Softver window, MainProgram / MainTable / SubProgram /
  SoundTable selected) sit 4 bytes lower than `naka_ram_cells.h` says.  The header is
  `scripts/generators/gen_naka_gui_headers.py`'s (`ram_mapper`: the nearest label both trees define inside
  the image), which is not this lane's file.  Next step: let ram_mapper place v6 / v5 cells by the tree's
  own work-cell lines (`; work cell: <record> <field>` in Murai_SoundMenuWorkCells), or give the image a label
  after the missing cell in both trees.

## Probes

`probes/README.md`: `rawsites.py` (where a json's raw bytes are, by C member) and `bass_name_tables.py`
(N-ece9781f).

## Website page draft (`rom-reconstruction.md`, the v6 / v5 rows)

> The v6 and v5 trees have no port row left: the last ones, halves of pointers cut by a C slice boundary,
> are whole pointers since the slices were re-cut, and the trees carry v7's RAM variable names with their
> own values.  Their C compiles to their own bytes but for 5 (v6) and 5 (v5) bytes of work-RAM
> cell addresses; verbatim debt is 5 B and 5 B (100.0 % source).
