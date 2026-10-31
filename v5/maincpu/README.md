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
    python3 scripts/tools/port_symbolize_pointers.py relink --tree v5

v5 inherits v6's hand edits through the port (`FIRMWARE_VERSION` is `.byte FW_VERSION_BYTE`,
the porter moves its default to 0x05; `AccTone_JumpTableData` is already code), so
`port_hand_edits.py` finds nothing to do; it stays in the sequence in case that changes.

`port_symbolize_pointers.py` (2026-10-31) spells by name what the dispatch census found spelled
as numbers: three code-pointer tables the porter left as `; TODO(port)` `.byte` rows (`rows`), and
the C link scripts' v7 addresses, which made `apply_c_divergence.py` patch this tree's pointers in
as raw bytes (`relink`: each script gets this tree's own label addresses, and the divergence json is
recomputed).  `style_ui/ctlonly_link.ld` is left as it is: its four Scoop_* names are not at the
addresses the C data holds in v7 either, so relinking it would add patched bytes.

The sed step (2026-10-31; once, before `relink`) moves the Yoko ApFunction language checks'
labels back one procedure: the port had put each of v6's names (PartSelLangCheck ...
GmOffSureLangCheck) on the procedure after its own, and left entry 0 unlabelled.  Evidence in the
script's header: v5's ApFunction table and its name table.  It is not idempotent.

## Build

    make v5-progress KN5000_V5_REF=/path/to/kn5000_v5_program.rom
