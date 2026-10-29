# The KN2400 / KN2600 program and the HD-SX3 (HD-SX6) plug-in: data as typed source, GUI first

Lane sib-kn2400 of the data-semantics effort (`notes/data-semantics-2026-10-29/README.md` at the
repository root), 2026-10-29. It covers two MN10300 "MILK" images:

- `kn2400/`: the SX-KN2400 / SX-KN2600 program flash v1.1, data first (file `0x0f`..`0x1e427c`);
- `hdsx3/`: the KN6000 / KN6500 expansion board's XAPR plug-in (sx6-113, most probably the HD-SX6's),
  data after its code (file `0x3ded6`..`0xb655c`), then erased flash.

Both now use lane gui-kn7000's tools through the profile mechanism lane sib-kn6000 and this lane
built in parallel (merged: `gen_data_s.py` profiles with `root`, `milk_model.configure`,
`gen_image_s.py --data-src`, `regen_sibling_data_and_code.sh`).

## What is where

| file                                       | what it holds                                                   |
|--------------------------------------------|-----------------------------------------------------------------|
| `kn2400/src/program/data/`                 | the data region: `data.s`, `data_NN.s`, `gui_classes.inc` ...   |
| `kn2400/src/program/data/media/`           | 45 bitmap resources (indexed PNG), 3 JPEG, 2 BMP                |
| `kn2400/src/constants.inc`                 | the image's own CL_ BD_ ES_ VF_ ... tables (file 0x15000..)     |
| `kn2400/notes/gui-menu-map.md`             | the menu map, 7,322 objects in 35 blocks (generated)            |
| `hdsx3/src/program/data/`                  | the plug-in's data region, its GUI on the KN6000's classes      |
| `hdsx3/notes/gui-menu-map.md`              | the plug-in's menu map, 999 objects (generated)                 |
| `kn2400/notes/data-region-probes/`         | the probes behind the numbers below (README in each docstring)  |

## Tools changed by this lane (all in `kn7000/tools/`)

| tool                             | change                                                                                   |
|----------------------------------|------------------------------------------------------------------------------------------|
| `gen_image_s.py`                 | `--decode-gaps` (code no traced path reaches, run by run); `--fill LO:HI`                |
| `gen_data_s.py`                  | profiles kn2400 / hdsx3; `host` (a plug-in on a host's classes); `string_arrays`; macro  |
|                                  | parameters per field offset (a field name declared twice; several rects)                 |
| `milk_model.py`                  | `HOST_CALLS` (calls through the host's Function table), `Model(host=)`, `Obj.fvalues`;   |
|                                  | the call tracker does not reset at gen_image_s.py's `<entry>_L<hex>` branch labels       |
| `gen_symbols.py`                 | reflection tables are start-aligned when a non-identifier name cuts the name run short   |
| `gen_constants.py`               | `--base`, `--scan`, `--model` (merged with sib-kn6000's identical change)                |
| `gui_menu_map.py`, `gui_readability.py` | kn2400 / hdsx3 rows; a plug-in's model built with its host                        |
| `regen_sibling_data_and_code.sh` | also watches `code_refs.txt`                                                             |
| `floppy/tools/kd/kn_sqt.py`      | `RECORD_LEN`: the KN2400's song-record signature 01 0E (0x8E0 bytes)                    |

## Format and evidence: the KN2400

The KN2400 is the KN7000's MILK layout throughout; `milk_model.py` reads it unchanged (scheme
`kn7000`, 16 registry slots per block): `RegisterObjectTable` 0x48601E82, `ClassProc` 0x48601F6D,
`RegisterOTBlock` 0x48608F3C, `RegisterMode` 0x48608F57, `RegisterTitle` 0x48608FA1. It finds
389 registrations, 491 classes, 7,322 widget records in 35 Viewable tables, 35 OT blocks, 278
titles, 23 modes; `milk_model --check` rules: 0 failures.

- **Initialised RAM**: `crt0_start` (0x48705BDF) copies .data 0x485DD334 -> 0x50000010, 0x6E78
  bytes (stated in the profile: once the code names data by label, `find_raminit`'s pattern no
  longer matches).
- **Function names**: `gen_symbols.py` had paired 90 procedures of SDFM MainFunctions (slot
  0x213: names 0x485CFC18, 111 entries, an identifier run of 90) 21 entries late.
  `fn_table_pairing.py`: before 2,193 agree / 90 disagree; after 2,283 / 0.
- **Demo songs**: `func_486183E3` inflates song n's three streams (record, events, panel memory;
  `ptrs_50000C18` / `C48` / `C78`) through `func_486D4A2A`, as the KN7000's `func_48457350` /
  `func_48533758`. The record signature is 01 0E (measured on the 8 songs). All 24 streams are
  typed inside `.zlib 6` blocks (Python's zlib reproduces them).
- **Built-in style**: `TechnicsRhythmsResource` 0x4852BD9C (IC18's format, one style), typed by
  `program_rhythm.py`.
- **Bitmaps**: the procedures that answer MT_GetBitmapData / Width / Height / Palette /
  GetBitCount (lane sib-kn6000's rule) give 45 bitmaps, PNG in `media/`, rebuilt by `table_png.py`.
- **RamCodeTrailer** (0x487965B8, 27 bytes after the RAM-linked code): 7 bytes, then 0x487285BE,
  0x50120000, 0x00038003, 0x487965B8, 0x5018FFF0. [INFERENCE] a copy descriptor; nothing reads it.
- **Code gaps**: `code_gap_classes.py` on the source before this lane: 324 pieces end in a return
  or jump, 42 run into the next function's `add -N, sp`, 7 are fill, 2 stop early (0xFF fill
  before more code). All 18,862 bytes are now instructions; 0 code-range bytes are binary.

## Format and evidence: the XAPR plug-in

The plug-in does not call the KN6000 directly. Every host call is
`mov (0x979126B4), aN / mov (0x100C, aN), aN / mov (OFF, aN), aM / calls (aM)`: 0x979126B4 holds
the registry base, +0x100C is the table pointer of slot 0x100 (16-byte registry records, +0xC the
table), which is the KN6000's block-0 Function table at 0x4C32923C (422 entries), so OFF / 4 is the
function index. Found by locating RegisterObjectTable (0x4C01D198) in that table at +0xEC.
`plugin_registry.py` lists the 41 offsets used (0xA8 DrawBox, 77 calls; 0x2D8 GetClientBox, 55;
0x25C MainFuncCall, 34; 0x108 SendEvent, 29; ...) and what they register:

| slot  | kind         | count | table      |
|-------|--------------|-------|------------|
| 0x168 | Class        | 55    | 0x978B0740 |
| 0x077 | Viewable     | 999   | 0x978B1F44 |
| 0x277 | ResName      | 999   | 0x978B2EE4 |
| 0x108 | Function     | 52    | 0x97912378 |
| 0x128 | ApFunction   | 44    | 0x979118EC |
| 0x148 | MainFunction | 7     | 0x97912520 |
| 0x188 | ResEvent     | 47    | 0x9791211C |
| 0x1A8 | ResMethod    | 100   | 0x979121E0 |

(the names of the three function tables are at slot + 0x200). `RegisterTitle` (OFF 0x278): title
0x77 = TT_HDDEXT, screen object 0x00770000 = HDD_MAIN_MENU, main function 0x01480000. The tables at
0x9791xxxx are in the plug-in's initialised RAM, copied from 0x978B3E84 (0x26D8 bytes,
`func_97800082`, the first header vector). The 55 classes use the NAKA alphabet and derive from
KN6000 classes (38 of which the records use; `gui_classes.inc` equates them), so the generator
builds the KN6000's model first (`gen_data_s.host_model`). Two link checks fail, both in the
plug-in's own data: object 11's `next` is its child 14, object 137's `next` is the orphan 138.
The pictures: BitmapBg001 / Bg002 / Dirsel answer the host's MT_GetBitmap* ids; 640 x 240, 8 bits,
palette 256 x 0x00BBGGRR.

## Readability (`kn7000/tools/gui_readability.py`)

Before: e12c2c693 (this lane's start); after: this branch.

| tree           | records typed | records in blobs | raw ids | numeric links | numeric addresses | code -> data nums | unnamed fields |
|----------------|---------------|------------------|---------|---------------|-------------------|-------------------|----------------|
| before, kn2400 | 0             | 7322             | 0       | 0             | 0                 | 13045             | 0              |
| before, hdsx3  | 0             | 999              | 0       | 0             | 0                 | 5138              | 0              |
| after, kn2400  | 7322          | 0                | 3       | 0             | 3                 | 2                 | 0              |
| after, hdsx3   | 999           | 0                | 0       | 0             | 3                 | 1                 | 0              |

The 3 raw ids in kn2400 are title ids no RegisterTitle call registers (0x000F000F, 0x000F0102);
the numeric addresses are Function-table entries that point at code no label names, and a
`.mnbase` line.

## Binary-include census (`scripts/analysis/data_incbin_census.py`)

| tree   | before n | before bytes | after n | after bytes | generated (n / B) | media (n / B) | opaque |
|--------|----------|--------------|---------|-------------|-------------------|---------------|--------|
| kn2400 | 446      | 1,993,350    | 5646    | 590,773     | 45 / 107,346      | 5 / 43,175    | 0      |
| hdsx3  | 30       | 533,544      | 414     | 6,623       | 3 / 309,200       | 0 / 0         | 0      |

The entry counts rose because blobs became many labelled pieces between typed items; the bytes are
what fell. Generic is not 0.

## What is left (generic), and why

kn2400, by kind (64 KB banks of the file offset):

- 0x190000..0x1AFFFF, about 125 KB: tone / sound parameter records (repeated
  `.. 64 15 02 55 50 3C 28 00 6C 40 1C 40 40 40 80 ..` shapes, names such as "Hippie Piano" in the
  pointer tables at 0x48571564 / 0x48577738). Their reader and record length were not traced; the
  KN7000's `voice_record.inc` macros are the candidate.
- 0x20000..0x30FFF, about 106 KB: the chord tables ("Basic Chord 100%", "Chord CEGB" ... each
  followed by signed byte steps and pointers into the table area). Not traced.
- 0x170000, 0x130000, 0x100000: about 128 KB of other tables the code reads with computed offsets.
- 0x1DD334..0x1E41AC (the initialised RAM image) and 0x0..0x10000: about 1,900 small pieces
  between labelled variables and strings.
- false strings inside binary (`Str_R_5_ER`, `Str_i_iixii`) split some of these pieces; the
  `text_strict` rule does not catch all of them.

hdsx3: 414 pieces, 6,623 bytes: a 1,525-byte high-entropy block at 0x978B014B, tables of file
extensions and fonts beside their strings, and RAM-image variables.

## Open questions

- [INFERENCE] RamCodeTrailer is a copy descriptor; who copies the RAM-linked code is still unknown.
- The KN2400 title ids 0x000F000F / 0x000F0102 that records name but no RegisterTitle registers.
- `gen_symbols.py`'s start-alignment rule would change `kn6000.sym` in 330 lines: not applied
  there (lane sib-kn6000's tree).
- `gen_data_s.py`'s per-field macro parameters change KN7000 941's `AcOtpRamBox` macro (its
  second `font` field) when 941 is regenerated; the bytes are the same.

## Website page draft

(For a `kn2400-kn2600` / `kn6000-expansion` section in technics-docs, to be added by the website sync.)

> **The KN2400 / KN2600 screens in the source.** The program draws its GUI from 7,322 widget
> records in 35 blocks, instances of 491 MILK classes the firmware describes itself; the source
> spells each as one macro line named by its class, nested by the widget tree, with its links,
> rect, colours, strings, titles and procedures by name (`kn2400/src/program/data/`). The menu map
> (`kn2400/notes/gui-menu-map.md`) is generated from it.
>
> **The HD-SX6 plug-in.** The expansion board's plug-in has no direct calls into the keyboard: it
> calls the SX-KN6000's routines through the keyboard's own registered Function table, and with
> them registers 55 classes of its own (all derived from the keyboard's) and 999 widget records,
> starting from the HDD_MAIN_MENU screen (title TT_HDDEXT). Its source and menu map
> (`hdsx3/notes/gui-menu-map.md`) are generated the same way, on the KN6000's class model.
