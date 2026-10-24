# Older program builds: 935 (v1.5), ported from 941

**2026-10-24.** Program build 935 is a byte-exact target with real source (`src/b935/`),
made the way SP7001's program 942 was (`notes/sp7001-build-diff.md`): everything recovered
for build 941 is carried through the exact 941 -> 935 offset map, and only what has no
counterpart is left out.

## Where the reference comes from

| build | release | reference image (git-ignored)        | made from (private romset, `ROMSET_DIR`)                                  | SHA-1 of the 4 MiB image                   |
|-------|---------|--------------------------------------|---------------------------------------------------------------------------|--------------------------------------------|
| 935   | v1.5    | `baserom/kn7000_program_b935.rom`    | `kn7000_program_{even,odd}_v1.5_b935.ic1{7,6}`, `tools/rom_from_eproms.py` | `5690195daa4c098069c0d84b4933bd1325f98269` |

The Makefile rule de-interleaves the two EPROM halves and refuses an image whose SHA-1 is not
the one recorded. Program 935 pairs with table build 84, the table 941 pairs with, so the
symbol porter's table map is the identity. The image's header byte at `0x4840000F` (the
release the IC18 boot ROM shows as `NOW(CURRENT)`) reads `0x15`.

## Reproduce

    make verify-935          # build src/b935/program.s, compare with the reference
    make symbols-935         # kn7000_b935{,_manual,_exports}.sym + src/b935/symbols.inc (needs 941's baserom)
    make program-src-935     # regenerate src/b935/ (needs unidasm and 941's baserom; ~3 min)
    make ported-names-935    # kn7000_b935_bycode.sym (needs unidasm; then program-src-935 again)
    make check-names-935     # do the ported names sit on the same routine as in 941?
    python3 -I tools/offset_map.py baserom/kn7000_program.rom baserom/kn7000_program_b935.rom kn7000.sym kn7000_manual.sym

## What differs between 935 and 941

`tools/offset_map.py` (last command above): image `0x3F6E9D` bytes against 941's `0x3F6F01`.
Most of code region 1 sits at delta -66 (941 `0x01064F..0x18599C`), the library image and the
end of the data region at -100. The edits concentrate in three places:

- **the front of code region 1.** 941 rewrote and reordered the DSP boot code: 941
  `0x4D10..0x557B` (`DspFullReinit`, `DspBootDefaultEffects`, `DspBootProbe` and the DSP host
  port writers) has no 1:1 counterpart, 941 `0x557B..0xD118` sits at +10029 / +12129 and 941
  `0xD400..0x1023C` (the record interpreter, `ResetEntry`) at -34188 / -34192;
- **the end of code region 1.** 941 has a 5-byte stack template (a data island at
  `0x18599C`) after `DemoJpgDataL8`'s `retf`; 935 has two 0xFF bytes and the `.rodata` straight
  after, so its region 1 ends at `0x18595C` (`PORTED_BUILDS["b935"]` in `tools/gen_program_s.py`);
- **the data region.** Several blocks moved (the DSP record pool by +208548, others by -79840 and
  -100); `ResourceIdTrie` and `StyleRecordTable` hold small rewrites.

## How the source is made

`tools/gen_program_s.py --profile b935` is the `sp7001` profile's method with one change: a 941
item that has no 1:1 counterpart is dropped and counted instead of aborting the run.

- **Names.** `tools/port_symbols.py` ports `kn7000.sym`, `kn7000_manual.sym` and
  `kn7000_exports_from_942.sym`. With `--check-recovered` it re-derives the reflection names from
  935's own MILK tables: all 2302 sit exactly at the address the map gives. `--min-run 16` (new)
  refuses an address that only a 1:1 run shorter than 16 bytes holds: between two anchored
  segments, difflib aligned 6 equal bytes of rewritten code and put 941's `DspFullReinit` inside
  935's `ResetEntry`. `tools/check_ported_names.py` caught that (see below).
- **Names by code.** For the routines the map cannot place, `tools/port_names_by_code.py` (the
  tool the MN10300 sibling trees use) carries a 941 name when the relocation-masked code is the same
  and unique on both sides. Its new `--b-src` option reads the unnamed entries from the
  `func_<ADDR>` labels of a `gen_program_s.py` source (that generator writes no `labels.inc`).
- **Layout.** The palette, the data-region end and the library base come through the map.
  A FUNC_END cap, a data island and a LIB_CONVERT range port only when their whole 941 range maps
  1:1 onto one run of 935.
- **Notes.** FUNC_DOC and annotation text have their 941 CPU addresses translated. An address
  without a counterpart is printed `build-941 0x...`, so it never reads as a 935 address. Two
  addresses are the same in every build: `0x4840000F` and the library loader's sentinel
  destination `0x4C03FFF0` (the latter checked in the build's own descriptor).
- **Boot header.** 935 links the reset `jmp` in its 3-byte form, so its second vector is at
  `0x8`, not `0xA`. `boot_header()` now spells that layout too (`_reset`, `_vector_08`,
  `_rom_marker` = the release byte).

## Measured (2026-10-24)

| what                                                                   | value                     | from                               |
|------------------------------------------------------------------------|---------------------------|------------------------------------|
| reflection names at exactly the ported address                         | 2302 of 2302              | `make symbols-935`                 |
| `kn7000.sym` rows ported                                               | 2376 of 2376              | `kn7000_b935.sym`                  |
| `kn7000_manual.sym` rows ported                                        | 1860 of 1866              | `kn7000_b935_manual.sym`           |
| `kn7000_exports_from_942.sym` rows ported                              | 184 of 184                | `kn7000_b935_exports.sym`          |
| names carried by code (`DspBootDefaultEffects`, `DspBootProbe`)        | 2                         | `kn7000_b935_bycode.sym`           |
| 941 names with no place in 935                                         | 4                         | the four UNPORTED rows not carried |
| ported names on the same routine as in 941 (relocation-masked)         | 3609                      | `make check-names-935`             |
| ported names on an edited routine (`DspManagerInit`, constants)        | 1                         | `make check-names-935`             |
| region-1 functions converted (named + unnamed)                         | 3104 + 33                 | `make program-src-935`             |
| library functions converted                                            | 529 of 529                | `make program-src-935`             |
| `.byte` escapes                                                        | 0                         | `make program-src-935`             |
| 941 FUNC_END caps / data islands / LIB_CONVERT ranges dropped          | 0 / 1 (`0x18599C`) / 0    | `make program-src-935`             |
| `func_<ADDR>` function labels left (941's committed source: 6620)      | 6617                      | see below                          |

The four 941 names with no place in 935 are `DspWritePMWord`, `DspWriteDMWord`, `DspRegWrite`
and `DspFullReinit`. They name DSP host-port code in the stretch 941 rewrote; the offset map
gives them no 1:1 place, and `tools/port_names_by_code.py` finds no routine of 935 with the same
code that passes its rule (8 unmasked instructions, unique on both sides).

The `func_` count is the number of function labels that no symbol file names:

    cat src/b935/program.s src/b935/program/*.s | grep -acE '^func_[0-9A-F]{8}:'

`grep -a` is needed because the `.s` files hold raw ROM bytes.

## Still open

- Name 935's own versions of the rewritten DSP routines (front of region 1, `0x48404D10` to
  `0x48407CA8`) by reading them: they are the targets the four uncarried 941 names point at.
- Program 893 (v1.3, read from Felipe's own instrument, pairs with table 80) can take the same
  profile. Its map from 941 has 1784 insertions against 935's 167, and its region 1 ends at
  `0x1846A0` (`retf` at `0x18469A`, then three 0xFF bytes).
