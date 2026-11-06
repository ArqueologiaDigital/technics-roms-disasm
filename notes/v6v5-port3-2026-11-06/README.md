# Lane v6v5-port3 (wave 12, 2026-11-06): the last v6 / v5 json raw bytes; wave 11's NAKA converters per tree

Base main e53dc9b3a, branch `open12/v6v5-port3`.  Items N-2a3d2074 and N-c20ee5a7 of
`notes/open-items/REGISTER.md` (wave 11's lane: `notes/v6v5-port2-2026-11-06/README.md`; the hand-over list:
`notes/kn5000-naka-2026-11-06/README.md`, "What v6 / v5 need").  Every step is a tool run that
`v6/maincpu/README.md` / `v5/maincpu/README.md` ("After generation") now list; both images stay byte-identical
after each step (`make all`: 21 sections 100.00%).

## Measurements

`python3 scripts/analysis/naka_gui_census.py` (before: `--rev e53dc9b3a`) and
`python3 scripts/analysis/kn5000_source_coverage.py` (verbatim debt = json raw bytes; no TODO(port) row is left).
v6 and v5 read the same at every step; v7 is the target (171 field_XX, 0 rom addrs, 0 ram cells, 3,260 records).

| step (commit)                                                                | rom addrs | ram cells | field_XX | records | json raw | debt |
|------------------------------------------------------------------------------|-----------|-----------|----------|---------|----------|------|
| before (e53dc9b3a)                                                           | 6         | 1         | 349      | 3,259   | 5        | 5 B  |
| `gen_naka_gui_headers.py` work-cell anchors, `--regen` (c38c0826a)           | 6         | 1         | 349      | 3,259   | 0        | 0 B  |
| `naka_join_perf3rhythmsel.py` (df7419356)                                    | 5         | 1         | 348      | 3,260   | 0        | 0 B  |
| `naka_move_edge_heads_to_asm.py` + `naka_asm_records.py --apply` (2022a8f3c) | 5         | 1         | 347      | 3,260   | 0        | 0 B  |
| `naka_type_trackmixer_map.py` (8ccc4b4fa)                                    | 5         | 1         | 323      | 3,260   | 0        | 0 B  |
| `naka_widen_ram_cells.py` (14f92adbb)                                        | 5         | 1         | 206      | 3,260   | 0        | 0 B  |
| `naka_case_tables_retype.py --apply` (8bfc822ba)                             | 4         | 1         | 173      | 3,260   | 0        | 0 B  |
| `naka_type_straddling_records.py --strings` (b1744f048)                      | 2         | 1         | 171      | 3,260   | 0        | 0 B  |
| `port_unplaced_names.py`, IvMPver class definition (f1abfe376)               | 0         | 1         | 171      | 3,260   | 0        | 0 B  |
| `naka_gui_symbolize.py` with the tree's own RAM cells (b5b906f60)            | 0         | 0         | 171      | 3,260   | 0        | 0 B  |

(The kn5000-naka notes counted "7" rom addrs for v6 / v5 at their head; wave 11's port lane had typed one of them
before this lane's base.  N-c20ee5a7's text says the 7 close "via naka_join_perf3rhythmsel.py": that script closes
one; the other five needed the case-table retype (1), the --strings pass (2) and the IvMPver names (2).)

Label checks after the last step: `check_ported_labels.py --src v7 --dst v6` misplaced 112 (112 before), only in v6
1,433 (1,434: NakaWidget_Perf3RhythmSel_Tail is gone, as in v10 / v9 / v7); v6 -> v5 misplaced 16 (16 before).
`ported_label_probe.py` MISMATCH rows 5 in each tree (5 before).  Symbols
(`l2_symbol_reference.py --regen --only maincpu_v6,maincpu_v5`): v6 54,183 -> 54,182, v5 54,159 -> 54,158.

## N-2a3d2074: the last 5 raw json bytes per tree

They were the low bytes of five work-RAM cell pointers in naka_technichord_part.c (records Softver, MainProgram,
MainTable, SubProgram, SoundTable; `notes/v6v5-port2-2026-11-06/probes/rawsites.py`: compiled 10 14 16 18 1a, needed
0c 10 12 14 16).  v6 / v5 have no MPVersion view, so their Murai_SoundMenuWorkCells (assembly lines in
`ui_widgets/sequencer_channel_containers.s`, one `; work cell: <record> <field> (<Class>)` line per cell, 266 of
them) lack v10's MPVersion window cell (v10 holds the block as a 267-field struct of naka_sequencer_channels.c,
`Murai_SoundMenuWorkCells_t`).  `gen_naka_gui_headers.ram_mapper` placed every cell by the nearest label both trees
define, Murai_SoundMenuWorkCells itself, so the five cells after the missing one were 4 bytes too high.

`asm_cell_anchors()` (new) aligns the tree's cell lines with v10's struct fields in order (a dynamic programme: a
pair costs 0 when the sizes agree and the record names agree, 1 when only the sizes agree, a gap 2).  The result
is one gap, MPVersion_Window, and 13 pairs that differ only in naming (e.g. v10 `NoMessage_AcRamBox_Value` against
the line `NakaWidget_Mesage_21_AcRamBox data`), all of the same size.  Each pair is an anchor of ram_mapper, and a
v10 cell with no line is marked in the header as not in the tree's image.  Regenerated, only the v6 / v5 headers
change: RAM_Softver_Window 0x3E910 -> 0x3E90C, the four `*_Selected` cells each -4 (and two comment lines); the v10,
v9 and v7 copies are byte-identical (diffed against copies taken before).  `ported_c_rebase.py --regen`: raw bytes
5 -> 0 in both trees.

RAM_MPVersion_Window stays in the v6 / v5 headers because v7's C, which they compile, has MPVersion records that
name it; `probes/unplaced_members.py` shows that no slice of v6 / v5 places those records (nor IvMPver's class
definition, below), so their bytes never reach the image.

## N-c20ee5a7: wave 11's four kn5000-naka converters, per tree

| script                                              | v10 constants it had                                       | what it reads now                                                                                                                         |
|-----------------------------------------------------|------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| `scripts/converters/naka_join_perf3rhythmsel.py`    | BASE 0xE24056, captions 0xE24066 / 0xE2405E, onoff 0x3DEA0 | the two blobs' `#define BASE`s, the tree's symbols (checked against the bases and the compiled record), the tree's naka_ram_cells.h       |
| `scripts/converters/naka_move_edge_heads_to_asm.py` | none (record words, the same in every tree)                | `--tree v6 / v5`; it now writes SdmenuPage's one-line comment itself (v10 / v9 / v7 got it by hand in f3220ffc9)                          |
| `scripts/converters/naka_type_trackmixer_map.py`    | RAM 0x3EBE8 / 0x3F2F8 / 0x3D524 in the comments it writes  | blob offset -> the tree's slice address (`ported_c_rebase.slice_bases`) -> its Boot_InitWorkRAM copy (`work_ram_images`): v6 / v5 0x3EBE4 |
| `scripts/converters/naka_widen_ram_cells.py`        | BLOB_BASE 0xEEE078, IMG_ROM 0xEED8C8, IMG_RAM, IMG_END     | the same per-tree mapping; the RAM_ cells were already the tree's header                                                                  |

v10 / v9 / v7 runs after the change: the first two refuse ("already converted"), the last two print "nothing to do"
/ "0 pairs to merge" (the same `not merged` counts as before); nothing is written.  v10's TrackMixer comment renders
exactly as committed from the new template.

What else v6 / v5 needed to be level with v7 (kn5000-notes, wave 10, and kn5000-naka, wave 11):

- `naka_case_tables_retype.py`: v6 / v5 added, with a check that the tree's own label sits at the ROM address its
  slices give the v10 blob offset.  CtrlPanel_DispatchByIndex_CaseTable (v6 0xEA9908, v5 0xEA98F0) and
  AcPresentationControlProc_CaseTable (v6 0xE9F8B6, v5 0xE9F89E); the compiled bins are byte-identical (cmp).
- `naka_type_straddling_records.py --strings`: in v6 / v5 the old EditSw records' `str` still held v7's numbers
  (0x00E850A8, 0x00E8512C), relocated by -72 by the json.  The pass now takes the string's offset from v7's BASE (shared
  layout) and accepts the rewrite when the json then needs no raw byte and fewer relocations (4 -> 2).
- `scripts/converters/port_unplaced_names.py` (new): a numeric ROM address whose v7 line spells NAKA_ADDR(<sym>), with
  v7's link script giving <sym> that number, and whose member reaches no byte of the tree's image, takes the name, with
  `<sym> = <number>; /* v7's address: nothing in <tree> places it */` in the tree's link script (the port's own
  convention).  Two per tree: IvMPver's class name and propdata (`classdef_161_36`), a class v6 / v5 do not have.
- `naka_gui_symbolize.py`: RAM cells are named from the tree's own naka_ram_cells.h (it read v10's; v6's
  NakaWidget_PanelSimulator.window = 0x3F0A8 is RAM_PanelSimulator_Window there, 0x3F0AC in v10, where v6's 0x3F0AC
  is another cell).  v10 / v9 / v7 headers define the same RAM_ cells: `--check` up to date in all three.
- `ported_c_rebase.py --regen` drops a tail no slice places when a bin's C compiles shorter (naka_sound_menu_drawbar
  2314 -> 2308 after the edge-head move; the json had kept 2314 and the build padded 6 zero bytes back).
- `scripts/renaming/rename_v6v5_chordname_typeroottables.sed`: the 64 chord-type pointers that `--ram-self` named
  `Naka_DrawbarReg_Table_RamPtrs` take v10's `ChordName_TypeRootTables` (C and the two port lanes' notes).
- Already done by wave 11's port lane, checked again: `name_title_index_operands.py --tree v6 / v5 --report` gives
  the same 336 sites, 19 unknown-path sites and 0 to apply as v10; `TT_SEFILLPQ1`; AUDIO_CONFIG_UPDATE / _FLAGS.

## Things to know

- A json-only change does not rebuild anything: the json is not a make dependency of the bins, and `.SECONDARY`
  keeps make from remaking a missing intermediate (bin, `.o`) while the ELF is up to date.  To check one, remove
  `rebuilt_ROMs/kn5000_<tree>_program.llvm.elf` (and the bins concerned) first; this lane did so after each json step.
- v5's naka_style_bitmaps.bin is the one json entry whose size differs from the compiled bin (101,804 < 101,962): the
  json cuts it, as before this lane.

## What remains

Nothing of the two items.  The v6 / v5 NAKA C now has v7's census figures; the field_XX left (171) are the ones v7
has, owned by the NAKA lanes (N-d8cf1242).

## Probes

`probes/README.md`.

## Website page draft (`rom-reconstruction.md`, the v6 / v5 rows)

Old text (wave 11's draft):

> ... Their C compiles to their own bytes but for 5 (v6) and 5 (v5) bytes of work-RAM cell addresses; verbatim debt
> is 5 B and 5 B (100.0 % source).

New text:

> The v6 and v5 trees have no port row left and their C compiles to their own bytes everywhere: the last five bytes,
> work-RAM cell addresses after the MPVersion window cell that v6 and v5 do not have, are placed by the trees' own
> work-cell lines.  Verbatim debt is 0 B in both (100.0 % source), and their NAKA GUI C reads like v7's (no numeric ROM
> address or RAM cell left).
