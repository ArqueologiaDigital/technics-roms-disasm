# KN5000 main program v5

`kn5000_v5_program.s` assembles to the v5 program ROM (SHA-1
`7b69a8aaa84ee3d337acc0c29c34154c5da2df32`).  The dump is not in git: `make` copies it from
the private romset (`KN5000_V5_REF`, the `PORTED_MAINCPU` rules in the root `Makefile`) and
refuses a copy with another SHA-1.

## Where the source came from

The tree was generated from `v6/maincpu` (itself generated from `v7/maincpu`) by
`scripts/converters/port_maincpu_version.py --src v6 --dst v5`, the same way v6 was made
(see `v6/maincpu/README.md` and the script's docstring).

- v6's lines are kept where they assemble to the v5 bytes, and rewritten where only an
  operand differs.
- `.byte` rows under `; TODO(port): ...` are bytes no line of the newer tree maps to.  Rows
  whose marker says "v6 bytes with no v7 line" were carried over unchanged from v6: v5 has the
  same bytes there.  Both are verbatim debt.
- A v6 label for something v5 does not have is dropped: a `; port:` comment marks where it
  stood and `port_dropped_labels.txt` lists it with its v6 address.  An unused
  `.set NAME, Label + K` alias that now resolves onto another label is dropped the same way.
  `scripts/analysis/check_ported_labels.py --src v6 --dst v5` checks the labels that remain.
- The C data sources are v7's (through v6); their link scripts give each label its v5
  address, and `includes/v5_c_divergence.json` patches the compiled bins where v5 still
  differs (`scripts/build/apply_c_divergence.py v5`).  Its raw bytes are verbatim debt; its
  pointer relocations are numeric moves no v5 label checks yet.

Comments were carried over unchanged, so an address or a version number quoted in a comment
may be v6's or v7's.

## After generation

The generator overwrites `v5/maincpu` (except this README); the tree is regenerated whole,
never edited by hand.  Regenerate v6 first (its README), then:

    V5=/path/to/kn5000_v5_program.rom
    python3 scripts/converters/port_maincpu_version.py --src v6 --dst v5 --rom $V5 --emit
    rm -rf v5/maincpu/includes/generated && make v5-c-bins-raw
    python3 scripts/converters/port_maincpu_version.py --src v6 --dst v5 --rom $V5 --cdiv
    make v5-progress KN5000_V5_REF=$V5
    python3 scripts/converters/disassemble_port_todo.py --tree v5 --rom $V5 --apply
    python3 scripts/tools/port_hand_edits.py --tree v5 --fw 0x05
    python3 scripts/converters/disassemble_port_todo.py --tree v5 --rom $V5 --apply
    python3 scripts/tools/port_symbolize_pointers.py rows --tree v5 InitializeMurai_PtrTable_5 \
        PerfMode_ParamHandler_4_Data SndDispatch_Handler_1_Data
    sed -i -f scripts/renaming/rename_v5_langcheck_shift.sed v5/maincpu/sequencer/sequencer_ui.s \
        v5/maincpu/port_dropped_labels.txt
    python3 scripts/converters/port_todo_typed.py --tree v5
    python3 scripts/tools/port_fix_label_shifts.py --tree v5
    python3 scripts/tools/port_symbolize_pointers.py relink --tree v5
    python3 notes/kn5000-ports-probes/ported_label_probe.py --tree v5        # must print MISMATCH rows: 0
    make all                                 # builds v5 with the json written so far
    python3 scripts/converters/ported_c_rebase.py --tree v5 --need $TMPDIR/need-v5
    python3 scripts/converters/ported_c_rebase.py --tree v5 --set-base --need-dir $TMPDIR/need-v5
    python3 scripts/generators/gen_naka_gui_headers.py
    python3 scripts/converters/ported_c_rebase.py --tree v5 --regen $TMPDIR/need-v5
    python3 scripts/converters/ported_c_rebase.py --tree v5 --name-pointers $TMPDIR/need-v5
    python3 scripts/converters/ported_c_rebase.py --tree v5 --regen $TMPDIR/need-v5
    python3 scripts/converters/port_todo_naka.py --tree v5
    python3 scripts/converters/disassemble_port_todo.py --tree v5 --rom $V5 --apply
    python3 scripts/tools/port_todo_hand.py --tree v5
    python3 scripts/converters/naka_asm_records.py --tree v5 --gen
    make all
    python3 scripts/converters/ported_c_rebase.py --tree v5 --need $TMPDIR/need-v5-b
    python3 scripts/converters/ported_c_rebase.py --tree v5 --ram-self $TMPDIR/need-v5-b
    python3 scripts/converters/ported_c_rebase.py --tree v5 --regen $TMPDIR/need-v5-b

v5 inherits v6's hand edits through the port (`FIRMWARE_VERSION` is `.byte FW_VERSION_BYTE`,
the porter moves its default to 0x05; `AccTone_JumpTableData` is already code), so
`port_hand_edits.py` finds nothing to do; it stays in the sequence in case that changes.

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

The sed step (2026-10-31; once, before `relink`) moves the Yoko ApFunction language checks'
labels back one procedure: the port had put each of v6's names (PartSelLangCheck ...
GmOffSureLangCheck) on the procedure after its own, and left entry 0 unlabelled.  Evidence in the
script's header: v5's ApFunction table and its name table.  It is not idempotent.

`ported_c_rebase.py` (2026-11-02, lane open6/kn5000-c; `notes/kn5000-c-2026-11-02/README.md`) makes this
tree's C compile to its own bytes instead of patching them: each NAKA blob's `#define BASE` is its v5
address (a `PORT_BASE(off)` chain where the port moved parts of a blob), `naka_ram_cells.h` carries v5's
work-RAM cell addresses (`gen_naka_gui_headers.py`), and the re-ordered function-name pointer tables
name their strings.  Those were most of the json's raw bytes: they were pointers at unaligned offsets,
which a relocation cannot express.  `--need` must run before the C changes, on the tree built with the
json of the steps before; the tool reads no ROM bytes.

The last steps (2026-11-06, lane open10/v6v5-port; `notes/v6v5-port-2026-11-06/README.md`) take the
`; TODO(port)` rows from 4,284 B to 7 B.  `port_todo_naka.py` writes the rows that are NAKA objects the
firmware registers (nakarest_objtab_map.py places them: Viewable / ResName / function-name table entries,
widget records as `NAKA_REC_<Class>` or per field, class definitions, propname blocks, their strings,
the work-RAM cells the tree's own records point at, the count words RegObjTable reads, the NULL after a
table, and the rest of a pointer table the newer tree's `.long` lines begin) as what they are, with new
labels named from the registrations.  `disassemble_port_todo.py` now decodes a code block together with
the porter's further markers and its neighbour lines when an instruction straddles its edge, decodes the
three regions of `HAND_REGIONS` (code the source tree spells as bytes), and writes the case-offset tables
that hold rows as `.short Case - Base` (base from the reader).  `port_todo_hand.py` is the list of rows
read by hand, with the evidence for each.  `ported_c_rebase.py --ram-self` spells
naka_sequencer_channels' 64 work-RAM self-pointers as `NAKA_WRAM(Naka_DrawbarReg_Table[k])`.  The rows
left are halves of pointers a C slice boundary cuts (`@lo16` is an error in data).

## Build

    make v5-progress KN5000_V5_REF=/path/to/kn5000_v5_program.rom
