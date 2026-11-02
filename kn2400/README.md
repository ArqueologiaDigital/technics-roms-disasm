# Technics SX-KN2400 / SX-KN2600 program flash (update v1.1)

A byte-exact disassembly of the program flash image of the Technics SX-KN2400 and SX-KN2600
arrangers. The CPU is a Panasonic MN10300 running the MILK framework, the same as in the
SX-KN7000 (`../kn7000/`). The assembler and every helper script come from the KN7000 tree,
used by relative path (`../kn7000/tools`); nothing is copied.

    make            # regenerate baserom/ if needed, assemble, compare: must print OK
    make verify-kn2600

`make` needs the Technics customer-service mirror beside this repository
(`../../ca-software-mirror/files`, private). Point `CA_MIRROR=` at it if it lives elsewhere.
The build needs only Python 3. `make program-src` also needs MAME's `unidasm`
(`UNIDASM=`, default `../../tools/unidasm`).

## The reference image (not in git)

The image is copyrighted, so `baserom/` is git-ignored. `make baserom` rebuilds it from the
manufacturer's update, without running any of its programs:

| step            | tool                               | result                                                |
|-----------------|------------------------------------|-------------------------------------------------------|
| outer archive   | `sfx_extract.py kn24-11.zip`       | `kn24_11a.exe`, `kn24_11b.exe` (self-extracting ZIPs) |
| floppy contents | `sfx_extract.py kn24_11?.exe`      | `LKG1.SLD`, `LKG2.SLD`, `SMCKPR1.INF`                 |
| decompression   | `sld_decompress.py`                | 0x200000 + 0x1965D3 bytes                             |
| join            | `cat`                              | `kn2400_program.rom`, 3,761,619 bytes                 |
| checksum file   | `smck_check.py ... --expect match` | total 0x16DA58C4, 15/15 block sums match              |
| recorded SHA-1  | Makefile `ROM_SHA1`                | `39163ea892baf8ad11419c29fe58cc536bef9ca7`            |

`sld_decompress.py` falls back to a pure-Python LZSS decoder when pylzss is not installed.
`../kn7000/notes/sld-decompress-probes/` shows that both decoders give the same bytes.

**The KN2600 runs the same image.** Its own v1.1 package, `kn26-11.zip`, ships the image
uncompressed as `KN24PRG.DAT`. `make verify-kn2600` checks that this file equals
`kn2400_program.rom` byte for byte. The firmware selects KN2600, KN2400 or PR54 behaviour at
run time; see the documentation site's `kn2400-kn2600` page.

## Layout

| file offsets          | linked for              | contents                                                                         |
|-----------------------|-------------------------|----------------------------------------------------------------------------------|
| `0x000000`-`0x000010` | `0x48400000`            | boot header: `_reset` (jmp to `crt0_start`), 5 nops, `_vector_0a`, one data byte |
| `0x000010`-`0x1e427c` | `0x48400000`            | data: names, styles, bitmaps, tables, the `MILK MN10300 Ver1.0R1` banner         |
| `0x1e427c`-`0x3285be` | `0x48400000`            | code linked for flash: the MILK kernel and application                           |
| `0x3285be`-`0x3965b8` | `0x50120000` (work RAM) | code linked for work RAM (RamSectionsCopy's first record)                        |
| `0x3965b8`-`0x3965bb` | `0x5018fff0` (work RAM) | a 3-byte `retf` stub nothing calls (RamSectionsCopy's second record)             |
| `0x3965bb`-`0x3965d3` | none                    | RamSectionsCopy's table: two 12-byte records (see below)                         |

The data comes first and the code after it: the reverse of the KN7000's program image.

**Part of the code is linked for RAM.** The code from file `0x3285be` to the end is linked for
`0x50120000`. It is placed at `file offset + 0x4fdf7a42`. The evidence, from
`notes/layout-probes/ram_linked_range.py` (README there):

- the flash code makes 6,876 calls and jumps into `0x50120000`-`0x5018dffd`. All 6,876 land
  on an instruction start of that range, decoded at that address;
- the range makes 15,011 calls and jumps of its own. Decoded at its flash address, 629 of them
  go nowhere: outside both the image and the RAM window. Decoded at `0x50120000`, 5 do;
- a switch table at `0x48405c48` holds `0x50145241`, `0x50145251`, and so on. Those are the
  case bodies at file `0x34d7ff`, `0x34d80f` and following, under the same offset;
- crt0 points the vector at `0x90000000` at `0x5018df0b`, which is file `0x3964c9` under
  the same offset.

Much of it is what the KN7000 keeps in its library at `0x4C000000`. Of the 410 names
`make ported-names` carries into this range, 318 come from KN7000 library routines, many of them
`Tg*` tone-generator routines (the rows of `kn2400_ported.sym` at `0x50120000` and above, and
those of them whose KN7000 address is `0x4C000000` or above).

`src/program.s` assembles that range under `.mnbase 0x4fdf7a42`, so its PC-relative encodings
are reproduced exactly. The 24 bytes after it hold, among others, `0x487285be` (the flash
address of the RAM-linked range), `0x50120000` (its link address) and `0x487965b8`. Those values
are a copy table. crt0 copies `.data` itself (`0x6e78` bytes from `0x485dd334` to `0x50000010`) and
then calls `RamSectionsCopy` (0x4870587e), which walks the table from `0x487965bb`: 12-byte records
{u16 flags, u16 length, u32 source, u32 dest}. It copies `0x487285be` -> `0x50120000`, `0x6dffa` bytes,
and the trailer's first 3 bytes (`retf [], 0`) to `0x5018fff0`, through the uncached view (dest +
`0x40000000`) (`notes/data-region/README.md`, resolved 2026-11-02).

## Symbols

- `kn2400.sym` / `src/symbols.inc` (generated by `make symbols`) hold 2,277 function names. They
  come from the firmware's own MILK reflection tables, found by `../kn7000/tools/gen_symbols.py`.
  Only tables whose procedures land in the flash-linked code range are used. With the whole
  image counted as code, the tool would name 194 more addresses, from seven more tables, and
  those names are wrong: event-name string tables (`MT_GetPadRun` would name the text
  `"EV_DISPPADRUN"`) and the `DiskMenu` / `SdCardMenu` menu tables, whose pointers lead into
  data. `../kn7000/notes/sibling-symbol-probes/whole_image_pairings.py` produces these figures;
  its README has the command and the output.
- `kn2400_manual.sym` holds names recovered by hand: `_reset`, `_vector_0a`, `crt0_start`.
- `kn2400_ported.sym` (`make ported-names`, generated) holds 679 names carried over from the
  KN7000 (program 941). `../kn7000/tools/port_names_by_code.py` carries a name when one of
  this image's unnamed entries is the same code as a routine the KN7000's symbol files name:
  the same instructions from the entry to the first return, with every number of 0x10000 or
  more masked out (addresses, and MILK message codes, which are renumbered between models).
  At least 8 of those instructions must have nothing masked, and the match must be unique among
  all of the KN7000's routine starts (every `movm` prologue and call target, named or not) and
  among this image's entries. Each row records the KN7000 address it came from; the file's
  header counts what was not carried.
  `--fuzzy` then compares whole routine bodies on what is left
  (`../kn7000/tools/fn_similarity.py`: every instruction control flow reaches, small
  immediates allowed to differ, callees and referenced strings compared by name, the two
  routines each other's best match). It carried 80 of the 679; their rows say "whole body"
  and give the match class and the two similarity ratios.
- `src/labels.inc` is generated with the source. It holds every other label the source defines,
  so that `kn7asm` resolves each reference in one pass and checks each label against its
  `.equ`. It holds these kinds of label:
  - `func_<ADDR>` for an entry no table names;
  - `<name>_entry` for a register-save `call` entry, the KN7000 convention: `call` saves the
    registers itself, so its callers enter after the `movm` / `add -N, sp` prologue;
  - `<entry>_L<offset>` for a branch target.

## The source

`src/program.s` is generated by `make program-src`, which runs `../kn7000/tools/gen_image_s.py`.
Its header describes the method. In short:

1. Every named entry, every call target, and the functions that sit back to back after them
   are decoded and walked by control flow.
2. Code a traced path reaches becomes instructions, re-encoded by `mn10300_asm` and
   compared with the image; with `--decode-gaps` so does what no path reaches, run by run
   (each run ends in a return or jump, or runs into the next function). The data region is
   included from `src/program/data/` (below).
3. An instruction the encoder spells differently becomes a `.byte` escape with the disassembly
   beside it. These are the compiler's non-minimal `call` / `or` forms and the `udf*`
   coprocessor operations.

The figures from `notes/conversion-stats.txt`, which the generator writes:

`named` counts the independent names (the reflection-table, manual and ported files);
`derived` counts the `<name>_entry` register-save labels of named functions, which take their
name from the function. `python3 ../kn7000/tools/stats_table_md.py notes/conversion-stats.txt`
prints the table.

| measure                      | value                                                            |
|------------------------------|------------------------------------------------------------------|
| entries                      | 15,824 (3,014 named, 852 derived `<name>_entry`, 11,958 `func_`) |
| bytes emitted as code        | 1,759,605: 98.94% of the code-range bytes                        |
| instructions                 | 664,654, plus 93 `.byte` escapes                                 |
| local branch labels          | 55,859                                                           |
| code-range bytes left binary | 0, in 0 `.incbin_range` pieces                                   |

The 18,862 code-range bytes no traced path reaches are decoded too (`--decode-gaps`, under a
comment saying so; `notes/data-region-probes/code_gap_classes.py` shows they all decode).

## The data region

File `0x0f`..`0x1e427c` is typed source, `src/program/data/`, generated by
`../kn7000/tools/gen_data_s.py --profile kn2400` (`make data-src`; `make data-and-code-src` runs
it and `make program-src` to a fixpoint): the 491 MILK classes, the 7,322 widget records of the 35
blocks as one macro line each, nested by the widget tree, the reflection / event / method tables,
strings, 45 bitmap resources as indexed PNGs, 5 JPEG / BMP files, the 8 demo songs inside `.zlib`
blocks, the built-in style (`TechnicsRhythmsResource`) and the tables the code reads.
`notes/gui-menu-map.md` is the generated menu map (`make gui-map`, checked by `make
verify-gui-map`, in `make gate-kn2400`).  `notes/data-region/README.md` has the format, the
evidence and what is still binary.

## Open work

- Names: 11,993 entries are still `func_<ADDR>`. `make ported-names` carries unique,
  non-trivial matches with a KN7000 routine, exact or, with `--fuzzy`, near-exact; most of
  what is left has no KN7000 name either (`../kn7000/notes/function-naming-2026-10-24/`).
- (settled 2026-11-02, lane mn10300-names) No reflection table names a procedure in the
  RAM-linked range: `../kn7000/notes/mn10300-names-probes/names_kn2400_ram_tables.py` finds no
  name run with RAM-linked code pointers before it, and no identifier string there that a
  pointer names by its link address.  `make symbols` now gives `gen_symbols.py` that range
  (`--code-range 0x3285be:0x3965b8:0x50120000`, the `LO:HI:LINK` form of `gen_image_s.py
  --code`) and writes the same `kn2400.sym`; the 133 names at `0x50120000` and above come from
  `kn2400_ported.sym`.
- RAM and I/O addresses outside the initialised RAM image are still numbers in the code; data
  addresses are labels (`src/program/data/labels.sym`).
- The data region's remaining binary pieces (`notes/data-region/README.md`, "What is left"): generic 0; the
  census-opaque pieces fell from 2,885 / 61,226 to 1,192 / 27,313 bytes with lane mn10300-data's passes
  (2026-11-02; what is left and why: `../kn7000/notes/mn10300-data/README.md` section 4).
- The 4 MiB half of the IC12/IC13 flash pair at `0x48000000` has not been read; the documentation
  site's `kn2400-kn2600` page covers what is known about it.
