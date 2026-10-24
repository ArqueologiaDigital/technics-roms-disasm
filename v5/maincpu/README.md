# KN5000 main program v5

`kn5000_v5_program.s` assembles to the v5 program ROM (SHA-1
`7b69a8aaa84ee3d337acc0c29c34154c5da2df32`).  The dump is not in git: `make` copies it from
the private romset (`KN5000_V5_REF`, the `PORTED_MAINCPU` rules in the root `Makefile`) and
refuses a copy with another SHA-1.

## Where the source came from

The tree was generated from `v6/maincpu` (itself generated from `v7/maincpu`) by
`scripts/converters/port_maincpu_version.py --src v6 --dst v5`, the same way v6 was made
(see `v6/maincpu/README.md` and the script's docstring), and
`scripts/converters/disassemble_port_todo.py --tree v5` then decoded the TODO(port) rows that
sit between instructions.

- v6's lines are kept where they assemble to the v5 bytes, and rewritten where only an
  operand differs.
- `.byte` rows under `; TODO(port): ...` are bytes no line of the newer tree maps to.  Rows
  whose marker says "v6 bytes with no v7 line" were carried over unchanged from v6: v5 has the
  same bytes there.  Both are verbatim debt.
- The C data sources are v7's (through v6); `includes/v5_c_divergence.json` patches the
  compiled bins where v5 differs (`scripts/build/apply_c_divergence.py v5`).

Comments were carried over unchanged, so an address or a version number quoted in a comment
may be v6's or v7's.  Labels and code are v5's.

## After generation

The generator overwrites `v5/maincpu` (except this README) and is not re-run once the tree has
been edited by hand.  Before that point, regenerate v6 first (its README), then:

    python3 scripts/converters/port_maincpu_version.py --src v6 --dst v5 --rom $V5 --emit
    rm -rf v5/maincpu/includes/generated && make v5-c-bins-raw
    python3 scripts/converters/port_maincpu_version.py --src v6 --dst v5 --rom $V5 --cdiv
    make v5-progress
    python3 scripts/converters/disassemble_port_todo.py --tree v5 --rom $V5 --apply

## Build

    make v5-progress KN5000_V5_REF=/path/to/kn5000_v5_program.rom
