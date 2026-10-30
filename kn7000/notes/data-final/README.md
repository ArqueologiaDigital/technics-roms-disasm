# KN7000 data, last pass: program builds' remaining pieces, and the SP7001 plug-in's GUI

Lane kn7000-final of the data-semantics effort (`notes/data-semantics-2026-10-29/README.md` at the
repository root), 2026-10-30.  It continues lane kn7000-data-rest (`../data-rest/README.md`) on the
four program builds (941, 942 = `src/sp7001`, 935, 893), and lane kn7000-table's preparation of the
SP7001 table plug-in (`../table-semantics-2026-10-29.md`, "The SP7001 plug-in's GUI data").
Probes: `../data-final-probes/` (README there).

## Part 1: the program builds' last pieces

### The extended reader walk (`tools/data_readers.py`, `Reader(ext=True)`)

The previous walk lost a value whenever the compiler parked it in the function's frame, met it at a
label from two paths, or got it back from a call.  `ext` (profile key `readers_ext`, set for the four
KN7000 program builds only; the siblings' and the plug-in's walks are unchanged) adds:

| rule              | what it follows                                                                                                                                      | example                                                                                      |
|-------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|
| stack slots       | `mov aN, (8, sp)` ... `mov (8, sp), a0`: a slot keeps the value stored (same width)                                                                  | func_484C4229 spills its a1 (a value block) to (0x2c, sp) and reads it with `movbu (a0), d2` |
| T values (joins)  | a label that paths reach with different data addresses (or NULL) holds "one of them"; reads through it are reads of each                             | func_484C01F1, a 260-way switch that leaves one descriptor's address in (0, sp)              |
| return values     | a first walk collects what each function returns in a0: one of a set of addresses (a T), or a pointer loaded from a typed field; callers' a0 gets it | func_484C01F1 (260 records), func_485831BA (an entry of func_485831BA_Table)                 |
| named loop labels | a label is a function start only at its `# Name  (CPU ...)` header, or where nothing falls in and no branch reaches it                               | `DrawIcons_Impl_RowLoop:` keeps `a3 = DrawIcons_PixelPairTable`                              |
| loop bodies       | a label reached only by a backward branch keeps the frame's slots; at `setlb` a register holding a constant becomes an unknown index                 | func_485831DC's `movbu (d1, a0), d2` over a demo stream                                      |
| bounds            | a load whose source the walk does not know drops the bound an earlier `cmp` gave the register                                                        | DrawIcons_PixelPairTable is 256 entries, not the 240 of `cmp 0xf0, d0` on the row counter    |
| dedupe            | a callee's access seen through many call sites of one caller is one access (without it the stack slots make the rounds multiply)                     |                                                                                              |

`notes/data-final-probes/reader_ext_stats.py`, program 941: the plain walk shows 22,372 distinct
accesses, the extended one 26,677 (4,416 new, 111 of the old ones gone: what a joined state no
longer agrees on); 2,358 accesses go through a T value (146 distinct sets); 126 functions return one
of a set of data addresses, the largest func_484C01F1 (260 switch descriptors), func_484ADFC8 (42)
and func_484BFE61 (29); func_4C01BB1A (the resource-id trie walk) and func_485831BA (a demo stream
of func_485831BA_Table) return a pointer loaded from a typed field.

### New passes (gen_data_s.py, `readers_ext` profiles)

| pass              | types                                                                                                                                                                                                    | evidence                                                                                                      |
|-------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------|
| `support_classes` | the SupportClass table (registry slot 0xD, 54 entries + an empty one) as `SUPPORT_CLASS proc, x4, propsize, data`                                                                                        | InitSptClassTable 0x4842E5DC registers it; SupportClassProc 0x4842AAF0 reads it (src/include/data_tables.inc) |
| `sysex_strings`   | MIDI SysEx messages a typed pointer points at (0xF0, data < 0x80, 0xF7; 0x50 = Matsushita) as one `.byte` row each                                                                                       | the framing, and the pointer fields of the records that hold them                                             |
| `copied_blocks`   | a data address passed to memcpy / memcmp / strncmp / strncpy with a constant length: that many bytes, as u8 rows                                                                                         | the call's a0 / a1 and d0, cited in the header                                                                |
| `pointer_runs`    | aligned runs of >= 3 words no item holds, each 0 or an address of the data region: `.long Label`, and text where they point                                                                              | [INFERENCE] by value; the header says the reader was not traced                                               |
| `ptr_records`     | records one function selects (a T key): named `<func>_Result` / `<func>_Selected`; records of varying size get the fields all hold, and tails of rows when a common distance would drop the shorter ones | the reads through the T value                                                                                 |

| `resource_trie`   | the resource-id trie: 177 tables (940 entries, 7,400 bytes) as `RES_TRIE_ENTRY target, inner, count`; its 469 leaves typed from what func_4C01BB1A's callers read | func_4C01BB1A (lib 0x4C01BB1A): nibble-indexed 8-byte entries, inner 0 = leaf whose +0 is the id |
| size variants     | (ptr_records) records too short for their kind's size: a kind `<kind>_s<N>` per size, with the fields that fit                 | the same reads                                                                        |

### Census

`python3 scripts/analysis/data_incbin_census.py` (count / bytes).  "Before" is fd73a97fa (main when the
lane started), "after" ba88f212a (this lane before merging main; the merge changes no KN7000 count):

| tree           | before generic n / bytes | before opaque   | after generated | after media     | after opaque   | after generic n | after generic bytes |
|----------------|--------------------------|-----------------|-----------------|-----------------|----------------|-----------------|---------------------|
| kn7000-program | 433 / 17,416             | 4,129 / 119,033 | 87 / 162,942    | 10 / 58,992     | 4,298 / 82,196 | 177             | 2,948               |
| kn7000-sp7001  | 440 / 64,145             | 4,163 / 127,904 | 526 / 462,454   | 169 / 1,375,301 | 4,321 / 80,480 | 179             | 3,044               |
| kn7000-b935    | 435 / 17,512             | 4,153 / 130,423 | 87 / 162,942    | 10 / 58,992     | 4,309 / 83,003 | 179             | 3,044               |
| kn7000-b893    | 432 / 17,412             | 4,146 / 129,306 | 87 / 162,942    | 10 / 58,992     | 4,303 / 81,886 | 176             | 2,944               |

kn7000-sp7001 holds table 83 too: its plug-in's 46,625 generic bytes are now typed (part 2).  gen_data_s
for 941 types 2,106,173 of 2,306,001 bytes (91.3%; 89.0% before).

### What stays generic (941: 177 pieces, 2,948 bytes; the other builds the same pieces)

Each is read by some instruction (`generic_readers.py` lists the readers) that no pass turns into a
type yet:

- **records of the 260-way switch the size variants still miss** (30 bytes each, `Str_L_4`.. in data_01):
  func_484C01F1's descriptors whose pointer fields point into their own tail, so their room is less than
  any variant's fields;
- **RAM-image tables** read with an index from a RAM pointer (`data_500077A4`+, 208 bytes; 0x5000102C /
  0x50001120, 124 / 120 bytes of zeros the code fills);
- **small tables read once through a computed base** (`func_4841493C_Table` tail, 72; the two 64-byte
  colour tables at 0x4859E484 / 0x485EFF04; `SjisMissingGlyph`'s 32 bytes);
- **blocks handed to library routines** whose layout the callee decides at run time (func_4C015CA9 /
  func_4C01829B / func_4C01BC28 argument words, 8-32 bytes each).

### What stays opaque, and what was searched

`census: opaque -- unknown-dump` now means: no load, store, base or call argument of the converted code
lands in the bytes under the EXTENDED walk (stack slots, joins, return values, the trie, pointer runs),
the line says whether a typed pointer or a code immediate still holds their address, and
`opaque_holders.py` searched the whole image for any 32-bit word (any alignment: data pointers and the
imm32 of every `mov`) holding an address in the piece or up to 64 bytes before it.  The biggest, 941:

| piece                                   | bytes | holders | what the bytes look like, and the reader search                                                        |
|-----------------------------------------|-------|---------|--------------------------------------------------------------------------------------------------------|
| 0x48730AB3 after `Str_I_J`              | 2,101 | 0       | 7-byte groups `xx 90 xx xx xx 00 00`; no word anywhere points in or just before it                     |
| 0x486D0A8F after `Str_a9X_B`            | 1,525 | 0       | high-entropy bytes (a compressed or scrambled blob, [INFERENCE]); nothing points at it                 |
| 0x486CFC43                              | 641   | 17      | held by the tone generator's tables (data_02) but read through no instruction the walk follows         |
| 0x48715746 (func_48412A17)              | 458   | 0       | rows `NN 00 NN 01 ..` then 0xFF: more of func_48412A17's 128-byte records' tails, past its index bound |
| 0x48733632 / 0x48733428                 | 774   | 0       | after `ChordRecogTable2`: chord-recognition rows the reader indexes from a computed base [INFERENCE]   |
| 0x485ED01C / 0x485ECDA0                 | 824   | 20      | `01 00 0N 00 43 00 02 00 ..` records with pointers; held by typed records, read by none the walk sees  |
| 0x485F95E0 (HpFlashWriteDefaults_Table) | 304   | 0       | `ffff ffff 3100` rows: the table's tail past the bound its reader checks                               |

These are the walk's limits ([INFERENCE] on what they are): an address computed from a pointer the walk
does not carry across a loop iteration (a record walked with a stepped pointer), a RAM pointer set at
start-up, or a table read only in a branch the linear walk enters with no state.

## Part 2: the SP7001 plug-in's GUI (table flash 83)

The plug-in is the Key Soft Service XAPR application at table 83 0x3E8000..0x3FB5A0 (CPU
0x483E8000, `src/sp7001/table.s`).  Its code (0x3E803C..0x3EF6C5) was already MN10300 assembly;
its data (0x3EF6C5..0x3FB59C, 48,855 bytes) held the three generic pieces lane kn7000-table left
(33,127 + 4,274 + 9,224 bytes) and typed bits between them.  It is now `src/sp7001/plugin/data/`,
generated by `tools/gen_data_s.py --profile sp7001plugin`, the way the HD-SX6 plug-in (`../../../hdsx3/`)
was typed against its host:

- **host = program 942** (`host="sp7001"`): its records use 942's block-0 classes and its own (registry
  block 0x2F0), and it calls 942's routines through 942's Function table.  Evidence: func_483E8071
  (0x483E8071) makes the registrations: `mov (KssFrameworkObj), a0 / mov (0x1c, a0), a0 / mov (0xec, a0),
  a1 / calls (a1)` reads entry 0xEC / 4 of registry slot 1's table (16-byte registry records, +0xC the
  table; slot 1 is block 0's Function table, `host_model`) = RegisterObjectTable, with the 16-byte
  {class, proc, count, table} on the stack and the slot in d0 (0x2F4 classes, 0x2F5 events, 0x2F6
  methods, 0x2F1 / 0x2F9 functions and their names, 0x2F2 / 0x2FA ApFunctions, 0x2F3 / 0x2FB
  MainFunctions, 0x2F0 the Viewable table, 0x2F8 its ResName table), as milk_model.parse_calls reads them.
- **initialised RAM**: func_483E803E clears 0xA48 bytes from 0x50299498 (`KssWorkRam`, an `.equ` in
  data.s) and copies 0x1498 bytes from 0x483FA104 (labelled `KssRamImage`) to 0x50298000; widget
  records and the variables their fields point at live there, labelled by their RAM addresses.
- **its 10 classes** (`PLUG_Classes`, `plugin_milk_probe.py`'s list): one `.macro` each in
  `src/sp7001/plugin/data/gui_classes.inc`, with the host classes they derive from.
- **479 widget records** in one Viewable table (OT block `OTB_PLUG`, 31 screens), each one macro
  invocation by class name with its links by object name, nested by indentation, X / Y / W / H, colours
  and flags by constant name, captions inline, procedures by FN_ id, title / exit targets by TT_ name
  (942's `TT_PS`, `TT_SDCCUS`, `TT_SDAUDPLY` in `gui_ids.inc`).
- **menu map**: `../sp7001-plugin-menu-map.md` (`tools/gui_menu_map.py --profile sp7001plugin`; `make
  gui-map` writes it, `make verify-gui-map` checks it).  The plug-in's title `TT_PLUGIN` opens
  `Main`: SD SETTINGS, SELECT SONG, SD JUKE BOX, SELECT C.L.S., CUSTOM LYRICS screens and the
  942 titles CUSTOM STYLE LOAD/SAVE and SD-AUDIO PLAY.

What the generator does differently for this profile (all profile-gated, so the program builds and the
siblings are unchanged):

| key / pass             | what it does                                                                                                                     |
|------------------------|----------------------------------------------------------------------------------------------------------------------------------|
| `host_model`           | the host's Function table is registry slot 1 for a KN7000-scheme host (0x100 for the NAKA scheme)                                |
| `header_funcs`         | reader citations take the function name from the code's `# Name  (CPU ...)` headers (the plug-in code has no labels)             |
| `residue`              | the bytes no other pass typed, piece by piece: pointer words by name, text, NULs and pads, RAM-image words, the cleared work RAM |
| `bss`, `raminit_label` | `KssWorkRam` (0x50299498, 0xA48 bytes) for pointers into the cleared RAM; `KssRamImage`, the RAM image's flash copy              |

`tools/gen_table_s.py --plugin-data src/sp7001/plugin/data` includes that `data.s` in place of the old
gaps, spells the plug-in code's data operands with its labels (`mov 0x483f8db8, d0` -> `mov
PLUG_Classes, d0`; an operand inside an item as `Item+N`), and equates the code addresses the data
names (`code_refs.txt`).  The two generators read each other's output, so `make plugin-src` runs them
twice (a fixpoint: a third run changes nothing).

Readability (`tools/gui_readability.py`, row `kn7000-sp7001plugin`; "before" counted the same way on
fd73a97fa's `table.s`, whose plug-in data had no widget record typed):

| measure                                            | before  | after   |
|----------------------------------------------------|---------|---------|
| widget records typed / in blobs                    | 0 / 479 | 479 / 0 |
| raw class ids, numeric links, unnamed fields       | -       | 0, 0, 0 |
| numeric data addresses in the plug-in's data rows  | 328     | 0       |
| numeric data / RAM addresses in the plug-in's code | 1,293   | 3       |

What stays open in the plug-in: `image_id=32872` and `icon=1` of the `KssBgScreen` records are numbers
(a resource id of the host, not traced); the RAM words the `str_adr` / `extension` fields point at
hold values like 0x00C5CF2D / 0x01514568 that are no address of this image or of the program
([INFERENCE] initial values the code overwrites; written `.long` with "initial value").

## Open questions

- The `KssBgScreen` `image_id` / `icon` numbers of the plug-in (a host resource id: not traced).
- Recursive structures besides the resource-id trie are typed one level deep: the walk sees one loop
  iteration; a "same kind" closure (a field of kind K pointing at kind K) would type the rest.
- 4-byte demo-stream events (func_485831BA_Table's three streams) are u8 rows: the reader indexes +0 of
  every 4-byte step (`asl2`), the other three bytes' readers were not traced.
- Records whose pointer fields point into their own tail (the switch descriptors, 30-byte pieces) want a
  "record + inline payload" representation.

## Shared files touched

`kn7000/tools/data_readers.py`, `gen_data_s.py`, `data_structs.py`, `gen_table_s.py`, `gui_menu_map.py`,
`gui_readability.py`, `kn7000/src/include/data_tables.inc` (macros SUPPORT_CLASS, RES_TRIE_ENTRY),
`kn7000/Makefile` (plugin-src, data-src-sp7001plugin, verify-gui-map, table 83 built with --labels),
`kn7000/kn7000_sp7001_table_manual.sym` (KssKeyStringsPtr).  Every change to the shared tools is gated:
`readers_ext` (the four KN7000 program builds), `header_funcs` / `residue` / `bss` / `raminit_label` (the
SP7001 plug-in profile).  `make -C <kn6000|kn6500|kn2400|hdsx3> data-and-code-src` after merging main
(lane siblings-final) changes no line of the siblings' sources.

## Website page draft

(For `kn7000-data-region.md` and a new `kn7000-sp7001-plugin.md` in technics-docs, to be added by the
website sync.)

> **The SP7001 plug-in's screens.**  The SP7001 upgrade puts a second program in the KN7000's table
> flash: Key Soft Service's XAPR plug-in, which the main program finds at start-up and runs.  It brings
> 10 widget classes of its own and 479 widgets on 31 screens: SD SETTINGS, SELECT SONG, SD JUKE BOX,
> SELECT C.L.S., CUSTOM LYRICS, the naming and load/save windows.  In the disassembly each widget is
> one line named by its class (`AcKssList Lst_SelDir, super=SelDir, X=26, Y=38, W=510, H=172,
> ap_func=FN_Ap_Lst_SelDir, ...`), and a generated menu map lists every screen with what leads to it.
>
> **Reading the code's data more closely.**  The tool that types the program's data follows how the
> code reaches each byte.  It now also follows values the compiler parks on the stack, pointers that
> several branches choose between, and what a function returns: a 260-way switch that returns one
> MIDI-command descriptor, the resource-id trie (a nibble-indexed tree of 177 tables over 469
> parameter records), the demo-song event streams.  About 91% of the program's data region is typed;
> what is left is listed with the search that found no reader for it.

