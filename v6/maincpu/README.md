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
never edited by hand: an edit it needs goes into `scripts/tools/port_hand_edits.py`, which
redoes every such edit and is part of the sequence below.

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
    python3 scripts/tools/port_symbolize_pointers.py relink --tree v6

`port_hand_edits.py` makes `FIRMWARE_VERSION` the byte `FW_VERSION_BYTE` (v7 spells it `reti`)
and decodes `AccTone_JumpTableData` as the call/ret thunks it is (v10's spelling and names).

`port_symbolize_pointers.py` (2026-10-31) spells by name what the dispatch census found spelled
as numbers: three code-pointer tables the porter left as `; TODO(port)` `.byte` rows (`rows`), and
the C link scripts' v7 addresses, which made `apply_c_divergence.py` patch this tree's pointers in
as raw bytes (`relink`: each script gets this tree's own label addresses, and the divergence json is
recomputed).  `style_ui/ctlonly_link.ld` is left as it is: its four Scoop_* names are not at the
addresses the C data holds in v7 either, so relinking it would add patched bytes.

## Build

    make v6-progress KN5000_V6_REF=/path/to/kn5000_v6_program.rom
