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
| `0x3285be`-`0x3965bb` | `0x50120000` (work RAM) | code linked for work RAM                                                         |
| `0x3965bb`-`0x3965d3` | none                    | 24 bytes after the last instruction (see below)                                  |

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

Much of it is what the KN7000 keeps in its library at `0x4C000000`. Of the 337 names
`make ported-names` carries into this range, 250 come from KN7000 library routines, many of them
`Tg*` tone-generator routines.

`src/program.s` assembles that range under `.mnbase 0x4fdf7a42`, so its PC-relative encodings
are reproduced exactly. The 24 bytes after it hold, among others, `0x487285be` (the flash
address of the RAM-linked range), `0x50120000` (its link address) and `0x487965b8`. Those values
fit a copy descriptor. No code in this image reads them, and the routine that copies the range
to RAM has not been found: crt0 copies only `.data`, `0x6e78` bytes from `0x485dd334` to
`0x50000010`. Both points are open.

## Symbols

- `kn2400.sym` / `src/symbols.inc` (generated by `make symbols`) hold 2,277 function names. They
  come from the firmware's own MILK reflection tables, found by `../kn7000/tools/gen_symbols.py`.
  Only tables whose procedures land in the flash-linked code range are used. With the whole
  image counted as code, the tool accepts 194 more pairings, and those are wrong: event-name
  string tables (`MT_GetPadRun` would name the text `"EV_DISPPADRUN"`) and a menu table whose
  pointers lead into data.
- `kn2400_manual.sym` holds names recovered by hand: `_reset`, `_vector_0a`, `crt0_start`.
- `kn2400_ported.sym` (`make ported-names`, generated) holds 512 names carried over from the
  KN7000 (program 941). `../kn7000/tools/port_names_by_code.py` carries a name when one of
  this image's unnamed entries is the same code as a routine the KN7000's symbol files name:
  the same instructions from the entry to the first return, with addresses masked out,
  at least 8 of them, and a unique match on both sides. Each row records the KN7000 address
  it came from.
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
2. Only code a traced path reaches becomes instructions, re-encoded by `mn10300_asm` and
   compared with the image. Everything else stays `.incbin_range` from `baserom/`, so data is
   never spelled as instructions.
3. An instruction the encoder spells differently becomes a `.byte` escape with the disassembly
   beside it. These are the compiler's non-minimal `call` / `or` forms and the `udf*`
   coprocessor operations.

The figures from `notes/conversion-stats.txt`, which the generator writes:

| measure                      | value                                 |
|------------------------------|---------------------------------------|
| entries                      | 15,797 (3,471 named, 12,326 `func_`)  |
| bytes emitted as code        | 1,759,156: 98.88% of the code ranges  |
| instructions                 | 657,260, plus 389 `.byte` escapes     |
| local branch labels          | 54,871                                |
| code-range bytes left binary | 19,986, in 377 `.incbin_range` pieces |

Most of the remaining code-range bytes are short stretches no traced path enters, such as switch
cases reached only through RAM-linked jump tables and handlers reached only through tables of
non-`movm` code pointers.

## Open work

- Names: 12,326 entries are still `func_<ADDR>`. `make ported-names` carries only exact,
  unique matches. Routines that differ slightly from their KN7000 versions need another method.
- Reflection tables whose procedures are in the RAM-linked range: `gen_symbols.py` assumes one
  link base, so it pairs none of them.
- RAM, I/O and data addresses are still numbers in the source.
- The 4 MiB half of the IC12/IC13 flash pair at `0x48000000` has not been read; the documentation
  site's `kn2400-kn2600` page covers what is known about it.
