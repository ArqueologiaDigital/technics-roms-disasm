# KN5000 main program v6

`kn5000_v6_program.s` assembles to the v6 program ROM (SHA-1
`51108e2d75b180a034395e90bd40ca2bd2a0adfb`).  The dump is not in git: `make` copies it from
the private romset (`KN5000_V6_REF`, the `PORTED_MAINCPU` rules in the root `Makefile`) and
refuses a copy with another SHA-1.

## Where the source came from

The tree was generated from `v7/maincpu` by `scripts/converters/port_maincpu_version.py`
(its docstring has the method).  Each v7 line was aligned with the v6 bytes and:

- kept as written where it assembles to the v6 bytes (v7's labels resolve to their v6
  addresses);
- rewritten where only an operand differs (a moved RAM variable, a constant), with the
  operand read from the v6 bytes; a numeric `.equ` that every use moves the same way gets
  the new value at its definition;
- replaced by `.byte` rows under `; TODO(port): v6 bytes with no v7 line -- disassemble`
  where no v7 line maps.  Those rows are verbatim debt and are meant to be disassembled.

Labels: a v7 label stays on the v6 bytes its v7 bytes map to, or goes where the v6 uses of
it point (the v6 bytes of every mapped use vote).  A v7 label for something v6 does not have
(v7-only code or data, or a branch v6 sends straight to the next thing) is dropped: a
`; port:` comment marks where it stood and `port_dropped_labels.txt` lists every one with its
v7 address.  `scripts/analysis/check_ported_labels.py --src v7 --dst v6` checks every carried
label against the bytes (see its docstring for what "misplaced" can and cannot tell).

`scripts/converters/disassemble_port_todo.py --tree v6` then decoded the TODO(port) rows that
are code (between instructions, or reached by a branch, call or jump) and named the branch
and call targets they and the porter's rewritten lines reach.  The rows left are mostly data
next to v7's C data and pointer tables.

The C data sources are v7's.  Their link scripts give each ROM label its v6 address.
`includes/v6_c_divergence.json` records where the v6 ROM still differs from what they compile
to, as pointer relocations and raw bytes, and `scripts/build/apply_c_divergence.py v6` applies
it after compiling.  The json is written by `port_maincpu_version.py --cdiv`.  The raw bytes
count as verbatim debt.  The relocations are numeric moves of v7's compiled pointers: no v6
label checks what they point at, so they are not yet explained.

Comments were carried over from v7 unchanged, so an address or a version number quoted in a
comment may be v7's.

## After generation

The generator overwrites `v6/maincpu` (except this README).  The tree is regenerated whole,
never edited by hand: an edit it needs goes into `scripts/tools/port_hand_edits.py` (or the
HAND lists of `port_fix_label_shifts.py`), which redo every such edit and are part of the
sequence below.  Other lanes' generators (the NAKA GUI records, e.g. dc10ee5ff; their `--gen`
runs over every tree) also write into the committed tree and are not in the sequence below.

    V6=/path/to/kn5000_v6_program.rom
    python3 scripts/converters/port_maincpu_version.py --src v7 --dst v6 --rom $V6 --emit
    rm -rf v6/maincpu/includes/generated && make v6-c-bins-raw
    python3 scripts/converters/port_maincpu_version.py --src v7 --dst v6 --rom $V6 --cdiv
    make v6-progress KN5000_V6_REF=$V6
    python3 scripts/converters/disassemble_port_todo.py --tree v6 --rom $V6 --apply
    python3 scripts/tools/port_hand_edits.py --tree v6 --fw 0x06
    python3 scripts/converters/disassemble_port_todo.py --tree v6 --rom $V6 --apply
    python3 scripts/tools/port_symbolize_pointers.py rows --tree v6 InitializeMurai_PtrTable_5 \
        PerfMode_ParamHandler_4_Data SndDispatch_Handler_1_Data
    python3 scripts/converters/port_todo_typed.py --tree v6
    python3 scripts/tools/port_fix_label_shifts.py --tree v6
    python3 scripts/tools/port_symbolize_pointers.py relink --tree v6
    python3 notes/kn5000-ports-probes/ported_label_probe.py --tree v6        # must print MISMATCH rows: 0
    make all                                 # builds v6 with the json written so far
    python3 scripts/converters/ported_c_rebase.py --tree v6 --need $TMPDIR/need-v6
    python3 scripts/converters/ported_c_rebase.py --tree v6 --set-base --need-dir $TMPDIR/need-v6
    python3 scripts/generators/gen_naka_gui_headers.py
    python3 scripts/converters/ported_c_rebase.py --tree v6 --regen $TMPDIR/need-v6
    python3 scripts/converters/ported_c_rebase.py --tree v6 --name-pointers $TMPDIR/need-v6
    python3 scripts/converters/ported_c_rebase.py --tree v6 --regen $TMPDIR/need-v6
    python3 scripts/converters/port_todo_naka.py --tree v6
    python3 scripts/converters/disassemble_port_todo.py --tree v6 --rom $V6 --apply
    python3 scripts/tools/port_todo_hand.py --tree v6
    python3 scripts/converters/naka_asm_records.py --tree v6 --gen
    make all
    python3 scripts/converters/ported_c_rebase.py --tree v6 --need $TMPDIR/need-v6-b
    python3 scripts/converters/ported_c_rebase.py --tree v6 --ram-self $TMPDIR/need-v6-b
    python3 scripts/converters/ported_c_rebase.py --tree v6 --regen $TMPDIR/need-v6-b
    # v6 first: v5's --own-values copies the RAM names v6's C spells
    python3 scripts/converters/port_ram_names.py --tree v6
    python3 scripts/converters/ported_c_rebase.py --tree v6 --need $TMPDIR/need-v6-c
    python3 scripts/converters/ported_c_rebase.py --tree v6 --ram-self-pieces $TMPDIR/need-v6-c
    python3 scripts/converters/ported_c_rebase.py --tree v6 --own-values $TMPDIR/need-v6-c
    python3 scripts/converters/ported_c_rebase.py --tree v6 --hand-c $TMPDIR/need-v6-c
    python3 scripts/converters/ported_c_rebase.py --tree v6 --regen $TMPDIR/need-v6-c
    python3 scripts/tools/port_todo_hand.py --tree v6          # edits 8 and 9 take bin slices out
    python3 scripts/converters/ported_c_rebase.py --tree v6 --regen $TMPDIR/need-v6-c
    python3 scripts/converters/naka_type_straddling_records.py --tree v6 --apply
    python3 scripts/converters/naka_gui_symbolize.py --tree v6 --apply
    python3 scripts/converters/naka_gui_symbolize.py --tree v6 --headers --apply
    # lane open12/v6v5-port3: the work cells by the tree's own lines, then wave 11's NAKA converters
    make all
    python3 scripts/converters/ported_c_rebase.py --tree v6 --need $TMPDIR/need-v6-d
    python3 scripts/generators/gen_naka_gui_headers.py
    python3 scripts/converters/ported_c_rebase.py --tree v6 --regen $TMPDIR/need-v6-d
    python3 scripts/converters/naka_join_perf3rhythmsel.py --tree v6
    make all
    python3 scripts/converters/naka_gui_symbolize.py --tree v6 --apply
    python3 scripts/converters/naka_gui_symbolize.py --tree v6 --headers --apply
    python3 scripts/converters/naka_move_edge_heads_to_asm.py --tree v6
    make all
    python3 scripts/converters/naka_asm_records.py --tree v6 --apply
    python3 scripts/converters/naka_type_trackmixer_map.py --tree v6
    sed -i -f scripts/renaming/rename_v6v5_chordname_typeroottables.sed v6/maincpu/ui_widgets/naka_sequencer_channels.c
    python3 scripts/converters/naka_widen_ram_cells.py --tree v6
    python3 scripts/converters/naka_case_tables_retype.py --apply          # every tree; a no-op where done
    make all
    python3 scripts/converters/ported_c_rebase.py --tree v6 --need $TMPDIR/need-v6-e
    python3 scripts/converters/ported_c_rebase.py --tree v6 --regen $TMPDIR/need-v6-e
    python3 scripts/converters/naka_type_straddling_records.py --tree v6 --strings --apply
    python3 scripts/converters/ported_c_rebase.py --tree v6 --regen $TMPDIR/need-v6-e
    python3 scripts/converters/port_unplaced_names.py --tree v6 --apply
    python3 scripts/converters/naka_gui_symbolize.py --tree v6 --apply

`port_hand_edits.py` makes `FIRMWARE_VERSION` the byte `FW_VERSION_BYTE` (v7 spells it `reti`)
and decodes `AccTone_JumpTableData` as the call/ret thunks it is (v10's spelling and names).

`port_symbolize_pointers.py` (2026-10-31) spells by name what the dispatch census found spelled
as numbers: three code-pointer tables the porter left as `; TODO(port)` `.byte` rows (`rows`), and
the C link scripts' v7 addresses, which made `apply_c_divergence.py` patch this tree's pointers in
as raw bytes (`relink`: each script gets this tree's own label addresses, and the divergence json is
recomputed).  Since 2026-10-31 only the bytes some `.incbin` of the tree puts in the image count
(the rest are don't-care), so `style_ui/ctlonly_link.ld` relinks too: its handler words are not in
the image (the tree spells Scoop_StaticOpHandlerTable as `.long` lines), and its four Scoop_* lines
had kept v10's addresses.  `notes/kn5000-ports-probes/link_script_names.py` checks every line.

`port_todo_typed.py` (2026-10-31) writes the pointers (`.long Label`) and NUL-terminated text
(`.asciz`, `aligned_string`) inside the `; TODO(port)` rows; the bytes nothing explains stay rows.
`port_fix_label_shifts.py` (2026-10-31) puts the names the port left on the wrong thing back
(the firmware's registration and name tables, its pointer tables, the bodies that name a label;
its HAND lists are the edits read by hand), and `ported_label_probe.py` shows 0 MISMATCH rows
afterwards: `notes/kn5000-ports-2026-10-31/README.md`.

`ported_c_rebase.py` (2026-11-02, lane open6/kn5000-c; `notes/kn5000-c-2026-11-02/README.md`) makes this
tree's C compile to its own bytes instead of patching them: each NAKA blob's `#define BASE` is its v6
address (a `PORT_BASE(off)` chain where the port moved parts of a blob), `naka_ram_cells.h` carries v6's
work-RAM cell addresses (`gen_naka_gui_headers.py`), and the re-ordered function-name pointer tables
name their strings.  Those were most of the json's raw bytes: they were pointers at unaligned offsets,
which a relocation cannot express.  `--need` must run before the C changes, on the tree built with the
json of the steps before; the tool reads no ROM bytes.

The last steps (2026-11-06, lane open10/v6v5-port; `notes/v6v5-port-2026-11-06/README.md`) take the
`; TODO(port)` rows from 3,403 B to 2 B.  `port_todo_naka.py` writes the rows that are NAKA objects the
firmware registers (nakarest_objtab_map.py places them: Viewable / ResName / function-name table entries,
widget records as `NAKA_REC_<Class>` or per field, class definitions, propname blocks, their strings,
the work-RAM cells the tree's own records point at, the count words RegObjTable reads, the NULL after a
table, and the rest of a pointer table the newer tree's `.long` lines begin) as what they are, with new
labels named from the registrations.  `disassemble_port_todo.py` now decodes a code block together with
the porter's further markers and its neighbour lines when an instruction straddles its edge, decodes the
three regions of `HAND_REGIONS` (code the source tree spells as bytes), and writes the case-offset tables
that hold rows as `.short Case - Base` (base from the reader).  `port_todo_hand.py` is the list of rows
read by hand, with the evidence for each.  `ported_c_rebase.py --ram-self` spells
naka_sequencer_channels' 64 work-RAM self-pointers as `NAKA_WRAM(Naka_DrawbarReg_Table[k])`.

The steps after that (2026-11-06, lane open11/v6v5-port2; `notes/v6v5-port2-2026-11-06/README.md`) leave no
`; TODO(port)` row and almost no raw json byte.  `port_todo_hand.py` edits 5-7 write the last rows, halves
of pointers a slice boundary cut, as whole `.long` pointers by moving the slice boundary; edits 8-9 write
two pointer tables whose strings the port spells (the ResEvent 0x1c1 names, AcBitEditBox's property names)
as `.long` to labelled strings.  `port_ram_names.py` gives the tree v7's `shared/ram_variables_by_use.s`
names (values derived from the source tree's routines by `name_kn5000_ram.py --ref`; the code's numeric
operands take them).  `ported_c_rebase.py --ram-self-pieces` makes NAKA_WRAM piecewise (the elements name
entries 17 / 30 / 43 / 56, the bass-note spelling blocks MainChordPre_AppendChordSuffix reads),
`--own-values` gives the C the tree's own RAM names, link-script addresses, literals and `#define`s, and
`--hand-c` the two initializers that were read as pointers but are coordinate pairs.

The steps after that (2026-11-06, lane open12/v6v5-port3; `notes/v6v5-port3-2026-11-06/README.md`) leave the
C-divergence json no raw byte and bring the tree's NAKA C level with v7's (`naka_gui_census.py`: no numeric ROM
address or RAM cell, field_XX 171 as in v7).  `gen_naka_gui_headers.py` places the work cells of
Murai_SoundMenuWorkCells by the tree's own `; work cell:` lines (the tree has no MPVersion window cell, so the five
cells after it sit 4 bytes lower than v10's layout says).  Wave 11's converters (`naka_join_perf3rhythmsel.py`,
`naka_move_edge_heads_to_asm.py`, `naka_type_trackmixer_map.py`, `naka_widen_ram_cells.py`) read the tree's own
addresses; `naka_case_tables_retype.py` and `naka_type_straddling_records.py --strings` (whose v6 / v5 values are
relocated v7 numbers, so the check is that the json needs fewer relocations and no raw byte) cover the tree;
`port_unplaced_names.py` gives the numbers no slice places (the IvMPver class, which the tree lacks) v7's names;
`naka_gui_symbolize.py` names RAM cells from the tree's own header.  A json-only change rebuilds nothing: remove
`rebuilt_ROMs/kn5000_v6_program.llvm.elf` (and the bins concerned) before `make all` to check it.

## Build

    make v6-progress KN5000_V6_REF=/path/to/kn5000_v6_program.rom
