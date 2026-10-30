# KN6000 / KN6500 expansion board: the XAPR plug-in image (sx6-113 update)

A byte-exact disassembly of the code image the KN6000 / KN6500 expansion board holds. The
keyboard's own MN10300 CPU runs it from `0x97800000`, where the board appears with the signature
`XAPR`. The assembler and every helper script come from the KN7000 tree, used by relative path
(`../kn7000/tools`); nothing is copied.

    make            # regenerate baserom/ if needed, assemble, compare: must print OK

`make` needs the Technics customer-service mirror beside this repository
(`../../ca-software-mirror/files`, private). Point `CA_MIRROR=` at it if it lives elsewhere.
The build needs only Python 3. `make program-src` also needs MAME's `unidasm`
(`UNIDASM=`, default `../../tools/unidasm`).

## Which board: HD-SX3 or HD-SX6

The folder, the make targets (`hdsx3`, `gate-hdsx3`) and the private romset's file name
(`technics_roms/roms/hdsx3/hd-sx3_v1_1.bin`, the same bytes) all say HD-SX3. The evidence says
otherwise:

- the update's own instructions (`install.pdf` in `sx6-113.zip`) are titled
  "Installations-Anleitung für das HD-SX6 – Update";
- the image's strings name Key Soft Service (`KEY SOFT SERVICE`, the `Kss*` procedures);
- the documentation site's `mame-pull-requests` and `kn7000-expansion-and-wave-dump` pages say
  this image is the HD-SX6's and that no HD-SX3 image has been found.

The image is therefore most probably Key Soft Service's HD-SX6. Whether to rename the folder is
the owner's decision. The installer's `TECHNICS.HDD` labels the file
`KN6KHD Technics KN6000 HDD-FIRMWARE`.

## The reference image (not in git)

| step           | tool                         | result                                     |
|----------------|------------------------------|--------------------------------------------|
| outer archive  | `sfx_extract.py sx6-113.zip` | `sx6v113a.exe` (a self-extracting ZIP)     |
| floppy content | `sfx_extract.py`             | `EXTAPR.SLD` (434,964 bytes, `SLIDE4K`)    |
| decompression  | `sld_decompress.py`          | `hdsx3_extapr.rom`, 786,432 bytes          |
| recorded SHA-1 | Makefile `ROM_SHA1`          | `88699a7e9584e0c30c175babd1482e5aa586ad3d` |

The update carries no `SMCK*.INF` checksum file. The SHA-1 is the check, together with the
private romset's copy (md5 `32ca36c8ed73813ea805d17ce57fd308`), which has the same bytes.

## Layout

| file offsets          | contents                                                                        |
|-----------------------|---------------------------------------------------------------------------------|
| `0x000000`-`0x000004` | signature `XAPR`                                                                |
| `0x000004`-`0x000080` | 31 header words, emitted as `.long` rows (see below)                            |
| `0x000080`-`0x03ded6` | code                                                                            |
| `0x03ded6`-`0x0b6560` | data: bitmaps, text, the plug-in's MILK reflection tables, then a second `XAPR` |
| `0x0b6560`-`0x0c0000` | erased (0xFF)                                                                   |

The header words:

- `+0x04` points at the second `XAPR`, at `0xb655c`, the last bytes before the erased tail. It is
  labelled `XaprTrailerSignature` (`hdsx3_manual.sym`), so the header row names it. No code in
  the image refers to it; what the firmware does with it has not been traced.
- `+0x08` to `+0x54` point at code. The KN6000 firmware calls `+0x08`, `+0x0C` and `+0x10`
  through `calls (aN)` once the signature checks out, according to the documentation site's
  `kn7000-expansion-and-wave-dump` page.
- `+0x58` to `+0x7C`, ten words, all point at `0x80`, a bare `rets`, named `XaprEmptySlot` in
  `hdsx3_manual.sym`.

The roles of the individual entry vectors have not been worked out yet, so they keep the names
`func_<ADDR>`.

## Symbols and source

- `hdsx3.sym` / `src/symbols.inc` (`make symbols`) hold 98 procedure names from the plug-in's
  own MILK reflection tables: `Kss*` window procedures, `Debug_Wind_RW`, `Bitmap*` resource
  procedures, and others.
- `hdsx3_manual.sym` holds `XaprEmptySlot` and `XaprTrailerSignature`.
- `hdsx3_ported.sym` (`make ported-names`, generated) holds 52 names carried over from the
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
  routines each other's best match). It carried none here: no unnamed entry of this image is close enough
  to a named KN7000 routine.
- `src/program.s` and `src/labels.inc` are generated by `make program-src`, which runs
  `../kn7000/tools/gen_image_s.py` (`../kn2400/README.md` explains its label conventions). The
  header and the code half of each of the three reflection tables are emitted as `.long` rows of
  names, and both `XAPR` signatures as text.

From `notes/conversion-stats.txt`, which the generator writes:

`named` counts the independent names (the reflection-table, manual and ported files);
`derived` counts the `<name>_entry` register-save labels of named functions, which take their
name from the function. `python3 ../kn7000/tools/stats_table_md.py notes/conversion-stats.txt`
prints the table.

| measure                      | value                                                   |
|------------------------------|---------------------------------------------------------|
| entries                      | 991 (155 named, 40 derived `<name>_entry`, 796 `func_`) |
| bytes emitted as code        | 252,331: 99.53% of the code-range bytes                 |
| instructions                 | 88,617, plus 12 `.byte` escapes                         |
| local branch labels          | 9,244                                                   |
| code-range bytes left binary | 0, in 0 `.incbin_range` pieces                          |

The 1,162 code-range bytes no traced path reaches are decoded too (`--decode-gaps`).

## The data region and the plug-in's GUI

File `0x3ded6`..`0xb655c` is typed source, `src/program/data/`, generated by
`../kn7000/tools/gen_data_s.py --profile hdsx3` (`make data-src`, `make data-and-code-src`). The
plug-in calls the SX-KN6000's routines through the host's block-0 Function table (registry slot
0x100): `mov (0x979126b4), aN / mov (0x100c, aN), aN / mov (OFF, aN), aM / calls (aM)` is entry
OFF / 4 (0xec RegisterObjectTable, 0x278 RegisterTitle, 0xa8 DrawBox ...). With them it registers
55 classes of its own (slot 0x168, all deriving from KN6000 classes), 999 widget records (Viewable
0x77, ResName 0x277), its Function / ApFunction / MainFunction, ResEvent and ResMethod tables, and
the title TT_HDDEXT, whose screen is HDD_MAIN_MENU. The generator reads the KN6000's model from
`../kn6000` (its reference image and source) for the classes and ids the plug-in uses. The three
640 x 240 pictures (BitmapBg001, BitmapBg002, BitmapDirsel) are indexed PNGs. The erased tail is
`.space`. `notes/gui-menu-map.md` is the menu map (`make verify-gui-map`, in `make gate-hdsx3`);
`../kn2400/notes/data-region/README.md` has the evidence.

## Open work

- The entry vectors' roles: what the firmware passes to them and expects back.
- The plug-in has no direct call into the KN6000 firmware. It makes 2,625 indirect
  `calls (aN)` (`grep -c 'calls	(a' src/program.s`). Those that load the host's block-0 Function
  table are traced (above: entry OFF / 4); the others, through pointers the plug-in builds at run time,
  are not.
- 40 small data pieces (266 bytes) are still generic `.incbin`s, and 101 (3,133 bytes) are declared opaque after the
  reader search (`docs/coverage/data-incbin-2026-10-30-01.txt`, `../kn6000/notes/siblings-data-final/README.md`).
- The 2,625 indirect calls could print the host routine's name for OFF (`plugin_registry.py` lists
  the 41 offsets); they are still numbers.
