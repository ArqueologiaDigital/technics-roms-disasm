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

The C data sources are v7's.  `includes/v6_c_divergence.json` records where the v6 ROM
differs from what they compile to, as pointer relocations and raw bytes, and
`scripts/build/apply_c_divergence.py v6` applies it after compiling.  The json is written
by `port_maincpu_version.py --cdiv`.

Comments were carried over from v7 unchanged, so an address or a version number quoted in a
comment may be v7's.  Labels and code are v6's.

## After generation

The generator overwrites `v6/maincpu` and is not re-run once the tree has been edited by
hand or by later passes; later changes are ordinary commits to this tree.

## Build

    make v6-progress KN5000_V6_REF=/path/to/kn5000_v6_program.rom
