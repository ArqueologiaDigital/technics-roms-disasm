# SP7001 firmware (program 942 / table 83) vs. the default build (941 / 84)

**2026-10-16.** Goal: disassemble the **SP7001** KN7000 firmware in this repo, reusing the
existing build-941/84 work and spending effort only on what genuinely differs.

> **Correction.** The first version of this note (commit `b826744`) called program 942 "an
> ~83% rebuild, not a clean relocation" and said byte-level reuse was not viable. That was
> wrong: the raw byte diff counts every relocated pointer and call displacement as a
> difference. The exact offset map below shows that 942 **is** build 941 plus a few small
> edits, so everything recovered for 941 ports to it.

## The firmware variants (from the merged MAME driver `matsushita/kn7000.cpp`)

Each KN7000 flash image is a program + table pair; each half is two 2 MiB EPROMs (IC17 even,
IC16 odd) word-interleaved into a 4 MiB image (program at `0x48400000`, table at `0x48000000`).

| BIOS     | program build | table build | note                                     |
|----------|---------------|-------------|------------------------------------------|
| `sp7001` | **942**       | **83**      | Key Soft Service SD PLUG-iN (2003-08-23) |
| `v16`    | 941           | 84          | **this repo's default target**           |
| `v15`    | 935           | 84          |                                          |
| `v14`    | 929 (partial) | 84          |                                          |

## Reproduce

    make verify-sp7001          # program 942, table 83 and BASEEXT.XAP rebuilt byte-for-byte
    make verify-sp7001-floppy   # table 83 vs the SP7001 update's two table disks (+ SMCKTB*.INF)
    make symbols-sp7001         # port the symbols (needs the 941/84 baserom too)
    make exports-941            # carry the plug-in export names back to build 941
    make program-src-sp7001     # regenerate src/sp7001/program.s   (needs unidasm)
    make table-src-sp7001       # regenerate src/sp7001/table.s     (needs unidasm)
    make xap-src-sp7001         # regenerate src/sp7001/baseext.s   (needs unidasm)
    python3 -I tools/offset_map.py baserom/kn7000_program.rom baserom/kn7000_program_sp7001.rom kn7000.sym kn7000_manual.sym
    python3 -I tools/offset_map.py baserom/kn7000_table.rom   baserom/kn7000_table_sp7001.rom

The SP7001 reference images are the de-interleaved raw EPROM dumps
(`tools/rom_from_eproms.py`, from the private romset). Sanity: the same de-interleave of the
v16 dumps is byte-identical to this repo's `baserom/kn7000_{program,table}.rom` over their full
extracted length (the extraction only trims the trailing 0xFF padding).

| tool                                      | question it answers                                                    |
|-------------------------------------------|------------------------------------------------------------------------|
| `tools/rom_from_eproms.py`                | IC17/IC16 halves -> the linear 4 MiB image the CPU sees                |
| `tools/diff_builds.py`                    | raw in-place byte diff (misleading across a shift; kept for reference) |
| `tools/offset_map.py`                     | where did every byte of the old build go; which bytes are new          |
| `tools/port_symbols.py`                   | which old names apply to the new build, and where                      |
| `tools/sp7001_exports.py`                 | what the firmware calls the services it exports to the plug-in         |
| `tools/gen_program_s.py --profile sp7001` | the 942 program source, ported from 941's                              |
| `tools/gen_table_s.py`                    | a table-image source, with the XAPR plug-in disassembled               |
| `tools/gen_xap_s.py`                      | an .XAP plug-in's source (linked at 0x5029B000)                        |
| `tools/fat12_extract.py`                  | one file off a FAT12 floppy image                                      |
| `tools/sfx_extract.py`                    | one member of a self-extracting ZIP update "disk" (never run)          |
| `tools/sld_decompress.py`                 | an update floppy's .SLD payload, decompressed (extraction repo's lzss) |
| `tools/smck_check.py`                     | is this image the one an SMCK*.INF describes; which blocks differ      |

## Program 941 -> 942: what actually changed

`tools/offset_map.py` aligns the two images with unique 24-byte anchors (every 0x100 bytes) and
difflib inside the gaps. Result: **42 insertions (7,692 B) and 30 deletions (306 B)**, net
+7,386 B = exactly the image growth (0x3F6F01 -> 0x3F8BDB). Everything else is the same bytes,
shifted:

| 941 file range      | delta          | content                              |
|---------------------|----------------|--------------------------------------|
| `0x000000-0x02A601` | +0             | boot header, code region 1 (start)   |
| `0x02A663-0x031CB6` | +2             | code region 1                        |
| `0x031D21-0x18599C` | -17            | code region 1 (to its last function) |
| `0x18599C-0x2BCEC4` | +1268          | data region                          |
| `0x2BCEC4-0x3B0B79` | +4132          | DSP record pool, data                |
| `0x3B0BA8-0x3BC6BB` | +6060 / +6068  | data tail, library image start       |
| `0x3BC765-0x3F547E` | +6158          | library                              |
| `0x3F547E-0x3F6F01` | +6470 .. +7386 | library tail (uITRON kernel)         |

The edit sites, with what each one is:

| site (942)                           | size           | what it is                                                                                                                                                                                                                               |
|--------------------------------------|----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `InitializeObjectTable` (0x4842A5xx) | net +2 B       | four small instruction rewrites                                                                                                                                                                                                          |
| `InitializeBlock30..47` stub run     | -3, -16 B      | the 3-byte `InitializeBlock46` stub removed; its name now points at new code                                                                                                                                                             |
| `0x4858598B..0x48585E90`             | **+1285 B**    | **new code**: `InitializeBlock46`, the XAPR plug-in host, 35 export forwarders/accessors                                                                                                                                                 |
| `0x486BD3B8..0x486BDEE8`             | **+2864 B**    | **export name block**: 'loc_cpu', 'unl_cpu', ... 'PlugHome'                                                                                                                                                                              |
| `0x487B1B9D..0x487B231D` (+8 B)      | **+1928 B**    | `InitializeBlock46`'s object records + the **export table**                                                                                                                                                                              |
| just before `DspTypeRecordTable`     | +8 B           | the table itself is unchanged (compared as relocated pointers)                                                                                                                                                                           |
| library `0x4C0036EA`                 | **+87 B**      | new C-library `rand` / `srand` (both exported)                                                                                                                                                                                           |
| library tail `0x4C03C507..`          | +1,289 / -61 B | uITRON kernel growth: `del_tsk`, `get_tid`, `clr_flg` are new code; `del_mbx`, `del_sem`, `del_flg`, `ext_tsk` enter service routines no 941 stub has; `preq_sem` and `sta_tsk` were already in 941 (`tools/itron_stubs.py`, 2026-10-18) |

(The byte-level edit list also shows ~30 tiny edits inside `DspTypeRecordTable`; those are
difflib aligning relocated pointers differently, not record changes -- compared word by word with
the pointers ported, the table is identical.)

**Addresses outside the image moved too.** Work-RAM variables shared by both builds moved by
0, +8 or +16 bytes (new globals); e.g. the framebuffer `0x500D4080` -> `0x500D4090`. The library
image (copied by the boot to `0x4C000000`) starts at program file `0x3BA785` instead of
`0x3B8FD1`, and library functions after the `rand`/`srand` insertion moved by +90 in `0x4C...`
space. `tools/port_symbols.py` translates each address in its own space (program, table,
library, RAM by majority vote over the references shared code makes).

**Names.** All 2302 reflection-named functions of 941 are in 942 -- no name added or removed.
Ported through the map, **2291** land exactly where 942's own tables put them; 10 sit in the run
of byte-identical 3-byte `InitializeBlockNN` stubs (deleting one stub from such a run is
ambiguous; 942's table settles it), and `InitializeBlock46` was rewritten into the new code.
Of the 1623 hand-recovered names in `kn7000_manual.sym`, **1622** port (the miss is in table
83's removed `Tech` segment).

## The plug-in host and export table (new in 942)

The table-flash plug-in is validated and called by four new routines (`kn7000_sp7001_new.sym`):

| routine                 | does                                                                                                    |
|-------------------------|---------------------------------------------------------------------------------------------------------|
| `PlugInProbe`           | 4-byte 'XAPR' at `0x483E8000` and at `*(0x483E8004)` (the footer) -> `PlugInPresent` (RAM `0x500066D0`) |
| `PlugInProbeCallSlot08` | re-probe, then call header slot `+0x08` with `a0 = 0x5011FABC`; called from `0x4854AC83`                |
| `PlugInCallSlot0C`      | call slot `+0x0C`; called once per pass of the library main loop (`0x4C02BE74`)                         |
| `PlugInCallSlot10`      | call slot `+0x10` with `d0`/`d1`, else return -1; reached via a pointer at `0x48732EA0`                 |

The firmware also **exports services to the plug-in by name**: a code-pointer array at
`0x487B1BB8`, a NUL word, and a name-pointer array at `0x487B1F5C` (231 pairs). The pairing is
`name[k]` -> `code[k+1]`, verified against uITRON semantics on the MN10300 before use:
`loc_cpu` and `dis_int` clear PSW.IE (`and 0xf7ff, psw`), `ena_int` sets it
(`or 0x0800, psw`), and `Set*`/`Reset*`/`Check*` triples store 1 / 0 / read the same variable.
`tools/sp7001_exports.py` aborts if that check fails. The 231 exports: 64 library services
(the uITRON kernel calls, `rand`/`srand`, ...), 132 firmware functions (`ResetSdSavePM3Bank`,
`PutM3Non`, ...) and the 35 new forwarders/accessors, which the firmware itself calls
`cre_tsk_X`, `snd_msg_X`, `malloc_X`, `fopen_api`, `decomp`, `GetVRAMAddr` (the framebuffer),
`putstr`, ... -- **228 names build 941 never had** (`kn7000_sp7001_exports.sym`).

## Table 84 -> 83: what actually changed

`tools/offset_map.py` on the tables, and a per-segment comparison in `tools/gen_table_s.py`.
Table 83 has the same 84-segment directory layout; **78 segments are byte-identical** to 84's:

| segment  | 84               | 83               | note                                                       |
|----------|------------------|------------------|------------------------------------------------------------|
| seg07    | '84'             | '83'             | the table's 4-byte build marker                            |
| seg59    | data, 0x13980c B | data, 0x131bdc B | 31,789 B removed at its end (+ a 3-byte edit at its start) |
| seg68-70 | '84' x3          | '80' x3          | three more 4-byte markers                                  |
| seg83    | 'Tech', 0x1248 B | 'DMY', 4 B       | asset replaced by a stub (`TechnicsRhythmsTable` was here) |

Then, past the directory image (`0x3E0660`): 0xFF up to `0x3E8000`, and **the XAPR plug-in,
`0x483E8000..0x483FB5A0` (79,264 B)**. The raw in-place diff reported "1.78 MB changed"; that
was the -31,792 B shift after seg59.

## The XAPR plug-in in table flash

| range (CPU)             | content                                                                                                                                |
|-------------------------|----------------------------------------------------------------------------------------------------------------------------------------|
| `0x483E8000-0x483E803C` | header: 'XAPR', footer pointer, slots `+08 XapSlot08`, `+0C XapSlot0C`, `+10 XapSlot10`, ten unused slots -> `XapSlotDefault` (`rets`) |
| `0x483E803C-0x483EF6C5` | **code** (30,345 B): 141 chunks, all emitted as MN10300 assembly                                                                       |
| `0x483EF6C8-0x483FB59C` | data: field-name strings, widget/descriptor tables, messages, two MILK reflection tables (35 names), 27 keystream records              |
| `0x483FB59C`            | footer 'XAPR'                                                                                                                          |

Its own reflection tables name 35 routines -- the Key Soft Service ("KSS") UI: `Ap_CE_Main`,
`Ap_Ce_StartUp`, `Ap_Ce_Fd2Sd` (floppy -> SD), `Ap_Ce_JukeBox`, `AcKssScreenMenuProc`, ...
(`kn7000_sp7001_table.sym`). The activation gate reverse-engineered in
`research-scratch/kn7000-sp7001-activation/` is named in `kn7000_sp7001_table_manual.sym`:
`KssPasswordCheck`, `KssActivationApply`, `KssKeyCompare`, `KssKeyTransform`, `KssHash275`,
`KssBuildParam1`, ... (8 of those 10 addresses are direct `call` targets; `KssBuildParam1` starts
with a `movm` prologue; the traced OK-handler address is a point inside a dispatcher and is kept
as a label). Two string addresses in the RE notes point inside strings; the curated file labels
the real starts (`KssMsgPluginReleased` `0x483F89A8`, `KssActivationFilePath` `0x483F892C`).

`KssPluginLoad` (`0x483EEAA9`) is the loader for `.XAP` plug-ins: see "BASEEXT.XAP" below.

## Table 83 provenance: the SP7001 update disks

The SP7001 update was distributed as four self-extracting ZIP "disks"
(`nonfree/kn7000-sp7001/sp7001-kn7000-updates/`, read with `tools/sfx_extract.py`, never run):

| archive                   | members                                                               |
|---------------------------|-----------------------------------------------------------------------|
| `PROGR1_2v1.6PLUG-iN.exe` | `TECHNICS.PR1`, `SMCKPR1.INF`, `DUMMY.2`, `HAMA1.SLD`                 |
| `PROGR2_2v1.6PLUG-iN.exe` | `TECHNICS.PR2`, `SMCKPR2.INF`, `DUMMY.2`, `HAMA2.SLD`                 |
| `table1_2.exe`            | `TECHNICS.TB1`, `SMCKTB1.INF`, `DUMMY.2`, `JKT1.SLD`                  |
| `table2_2PLUG-iN.exe`     | `TECHNICS.TB2`, `SMCKTB2.INF`, `DUMMY.2`, `JKTBL2.SLD`, `BASEEXT.XAP` |

(`technics_roms/media/sp7001_table_2of2.img` is a FAT12 image built from table disk 2's
members for the emulator, `research-scratch/kn7000-sp7001/make_sp7001_tb2_floppy.py`; its
`JKTBL2.SLD` and `BASEEXT.XAP` are byte-identical to the archive's.) `make verify-sp7001-floppy`:

- **Both table payloads are byte-identical to the dump.** Disk 1's `JKT1.SLD` (`JKTB14K`)
  decompresses to exactly `0x000000..0x200000` and disk 2's `JKTBL2.SLD` (`JKTB24K`) to exactly
  `0x200000..0x400000` -- the XAPR plug-in and the 0xFF tail included. So table 83 is precisely
  what this update installs. (Disk 1 differs from the standard table-84 disk 1 in 57 bytes, from
  the directory entries on.)
- **`SMCKTB1.INF` = `SMCKTB2.INF`** (32-bit total + 16 x 16-bit block sums over 0x40000-byte
  blocks, format in `../../kn7000_extraction/FORMAT.md`) and they do **not** describe that payload.
  They match -- the total and all 16 blocks -- the 0x3E0660-byte directory image (no plug-in)
  **with seg68..70 reading '83' instead of '80'**. As shipped those three markers read '80'
  (block 14 off by exactly -9 = 3 x ('0' - '3')) and the plug-in is appended. That is what the
  MAME driver's "its SMCK checksum predates the final payload" amounts to, byte for byte.

## BASEEXT.XAP

Table disk 2 also carries `BASEEXT.XAP` (118,784 = 0x1D000 bytes), which the setup
copies to the SD card ("BaseExt.xap wurde auf der SD Card nicht gefunden!" is the resident
plug-in's error when it is missing). The resident plug-in's **`KssPluginLoad`** opens an
`.XAP` (`A:\%s.XAP` / `%s\%s.XAP`), rejects files over 0x1D000 bytes, reads exactly 0x1D000
bytes to the fixed work-RAM address **0x5029B000** and calls its first byte with
`a0` = framework object, `a1 = 0x502992E4`, `d0`/`d1` -> compile id / plug-in id; it then
checks both ("Compile id's dont match: base=%i != baseext=%i"). So the file is an absolute
image linked at 0x5029B000 (the code-pointer test peaks sharply there: 122 pointers land on
function prologues vs 1 at +/-0x10; a string-pointer vote that seemed to favour 0x5029E8C0 was
mostly one variable, `XapFrameworkObj` 0x502B4044, read 970 times -- `notes/sp7001-probes/`):

| file range        | content                                                                                                                         |
|-------------------|---------------------------------------------------------------------------------------------------------------------------------|
| `0x00000-0x1321E` | code (398 chunks, all emitted as MN10300 assembly); `XapEntry` at 0                                                             |
| `0x1321E-0x16B4C` | data: 391 strings (SD-card prompts, song/lyrics UI in German and English, printf runtime), 36 pointer tables, a C `ctype` table |
| `0x16B4C-0x1D000` | 0xFF: the space its variables occupy at run time (e.g. `XapFrameworkObj` 0x502B4044)                                            |

`XapEntry` saves `a0`/`a1`, initialises, and returns the plug-in object `0x502B1E50`, the
compile id from `0x502B2090` and **plug-in id 3**. It calls the firmware only through pointer
tables (no direct `call` reaches a firmware entry at any base); internal calls are PC-relative.
It links its own copy of the compiler runtime: 11 routines are byte-identical to named firmware
routines and take their names (`strncmp`, `memcpy`, `memset`, `strcpy`, `LibDiv32`, `LibF64Unpack`,
...; `src/sp7001/baseext.s`'s header gives the count). Four of them are copies of the body from the
firmware routine's register-save `call` entry on (`strncmp_entry` and the like), linked without the
`movm` prologue; `tools/gen_xap_s.py` has matched those since 2026-10-24.
`tools/gen_xap_s.py` -> `src/sp7001/baseext.s`; `make verify-sp7001` checks it byte-exact.

## How the SP7001 source is built

- **Program** (`src/sp7001/program.s`): `gen_program_s.py --profile sp7001` takes build 941's
  function split, its `CONVERT` set, `FUNC_END` caps, library-function list and `FUNC_DOC` notes,
  and ports all of them through the offset map; it converts all the code new in 942. Result:
  **544/544** region-1 functions (504 ported + 40 new) and **437/437** library functions as
  MN10300 assembly. Run against the 941 profile, the refactored generator still reproduces the
  committed `src/program.s` exactly.
- **Table** (`src/sp7001/table.s`): `gen_table_s.py` emits the directory as `.long` rows, each
  segment as `.incbin_range` marked unchanged/CHANGED vs 84, and the plug-in (code as assembly,
  header and reflection tables as `.long <name>`, keystream and strings as bytes with their
  text). The same generator also reproduces table 84 byte-for-byte.
- `make verify-sp7001`: both images 100% byte-identical; `make verify` (941/84) unaffected.

## Names carried back to build 941

- `0x4C00203C` is **`strncmp_entry`** (stops at a NUL in s1, returns the unsigned byte difference;
  callers pass n = `LibStrlen(...)`), now in `kn7000_manual.sym`; BASEEXT.XAP's own copy is
  byte-identical to it.
- The plug-in export table's names are ported back to 941 (`make exports-941`,
  `kn7000_exports_from_942.sym`): **184 land**; the 44 that don't are exactly the code only 942
  has (the 35 new routines, `rand`/`srand`, seven uITRON services). The interrupt services
  still check out in 941 (`loc_cpu`/`dis_int` clear PSW.IE, `ena_int` sets it).
- **Correction (2026-10-18).** This list said 186 / 42 until `tools/itron_stubs.py` checked the
  kernel entry stubs. They are near-identical byte runs, and the offset map had put four 942
  names on the wrong 941 stub. 941 `0x4C03D8AB` was named `ext_tsk` but is **`sta_tsk`**: it
  takes two arguments and enters the same service routine as 942's `sta_tsk`, and 941's program
  calls it from the call site where 942 calls `sta_tsk`. A style converter that starts its own
  task depends on it (kn5000-anotherworld `kn7000/README-CNV.md`). `0x4C03C959` was `del_flg`
  but is `preq_sem`. `0x4C03C470` and `0x4C03C5AF` were `del_mbx` and `del_sem`, but take
  three arguments where those take one; 942 leaves their twins unnamed. `make exports-941` now
  runs the check after porting.
- Names recovered after the function split no longer shrink the converted source: a boundary
  from such a file (`INHERIT_SYMS` in `gen_program_s.py`) inherits the converted state of the
  function it splits. 941 keeps exactly its converted bytes; 942's regained the ~2.4 KB the
  export boundaries had cut.

## How the plug-in is called, loaded and activated (2026-10-16)

Three of the open questions were answered from the byte-exact sources (no emulator); the probe is
`research-scratch/kn7000-sp7001-disasm/sp7001_q1q2.py`.

**What `BASEEXT.XAP` calls (Q1).** It never calls a fixed firmware address: at no load base does any
of its `call` instructions land on a known firmware routine. It is handed the firmware's MILK
framework object -- `*(0x50299298)`, saved in the `.XAP` as `XapFrameworkObj` (`0x502B4044`) -- and
calls the firmware through that object's method table. The object's `+0x1C` field points at a
**static method vtable in program flash at `0x487280D0`** (a MILK reflection table: a name-pointer
array, a NUL, then the code-pointer array the object indexes). That base is proven: `*(0x487280D0
+ 0xEC)` is `RegisterObjectTable` -- the very method the plug-in's init `func_483E8071` (run by
`XapSlot08`) calls to register its 11 classes (ids `0x00040004`..`0x00040011`, name tables
`0x483F8EC0` etc.), just as the KN5000's HD-AE5000 `Boot_Init` registers its titles -- and `+0x108`
/ `+0x10C` / `+0x27C` are `SendEvent` / `PostEvent` / `RegisterTitle`. Reading each slot of that
vtable names the calls: **639 of `BASEEXT.XAP`'s 1,340 indirect calls resolve to named MILK
methods** -- `SendEvent` (285), `PostEvent` (89), `InheritedProc` (76), `SetVisible` (65),
`GetViewInstance` (35), `SetApTimer`, `ApFuncCall`, `GetClientBox`, the drawing/dial/box helpers,
`SleepMainTask`/`WakeUpMainTask`. The remaining 701 go through other MILK objects it is given or
creates (view instances, its own objects), reached by pointer chains the probe does not follow.
So `BASEEXT.XAP` drives the instrument entirely through the firmware's MILK UI framework, and its
firmware calls are now named, not opaque (`research-scratch/kn7000-sp7001-disasm/sp7001_q1q2.py`).

**The other 701 (2026-11-02, lane mn10300-names).** Most of them go through two tables that the
first probe did not follow:

- **The "framework object" is program 942's MILK object-table registry.** `0x5011FABC` is where
  `RegisterObjectTable` (`0x4842A719`) copies each table's 16-byte header `{class, proc, count,
  table}`, at `0x5011FABC + 16 * slot` (`mov 0x5011fabc, a1` ... `mov (a0), d1; mov d1, (a1)` four
  times). So `*(XapFrameworkObj + 16 * slot + 0xC)` is the table registered in that slot. `+0x1C` is
  slot 1, `InitBlockTable` (the "static vtable" above). `+0x2E1C` is slot `0x2E1`, `PAPI_Functions`
  (942 `0x487B1BBC`, 231 entries): the plug-in export table, whose names `kn7000_sp7001_exports.sym`
  already gives (`sprintf`, `strcpy`, `SetExtMode`, `fopen_api`, `malloc_X`, ...).
- **The loader's `a1` is the base plug-in's service table.** `KssPluginLoad` passes `a1 =
  0x502992E4`, which `BASEEXT.XAP` keeps in `XapContext` (`0x502B4048`). It is a statically
  initialised table of 78 words in the table-flash plug-in's RAM image
  (`src/sp7001/plugin/data/data_00.s`, `ptr_502992E4`): code pointers into that plug-in and
  pointers into its work RAM. Its slots are the plug-in's exception scheme (throw, throw-bug,
  frame-exit trace, the unhandled-exception dialog), a log printf, a dialog box, chunked
  `fread`/`fwrite`, a file copy, an SD-card check, string helpers, and the constructors of two small
  C objects, `PtrStrList` and `StrList`. The table plug-in's class-name strings `'PtrStrList'` /
  `'StrList'` sit beside their vtables `0x502990C0` / `0x502990F0`.

`notes/mn10300-names-probes/oldbuilds_baseext_indirect_calls.py` decodes the `.XAP`. For each
`calls (aN)` it evaluates the register backwards through its block and through the block's
predecessors when they all agree. A call kills `d0`, `d1`, `a0` and `a1` there. Measured on the
committed images:

| where the 1,340 `calls (aN)` go                                         | calls | distinct targets |
|-------------------------------------------------------------------------|-------|------------------|
| registry slot 1, `InitBlockTable` (the MILK methods)                    | 643   | 30               |
| registry slot `0x2E1`, `PAPI_Functions` (the export table)              | 324   | 62               |
| the base plug-in's service table `0x502992E4` (`XapContext`)            | 329   | 23 slots         |
| the vtable of a `PtrStrList` the `.XAP` built (10 objects in its RAM)   | 20    | 3 methods        |
| a pointer read from a local structure on the stack                      | 11    | -                |
| a table indexed by a register (`add d0, a1`)                            | 6     | -                |
| a routine parameter (`a0` / `a1` on entry)                              | 5     | -                |
| a pointer chain through service-table slot `+0x04` (`KssWorkRam+0x9EC`) | 1     | -                |
| a routine's return value                                                | 1     | -                |

So 1,316 of the 1,340 (98.2 %) now have a known target. All 967 registry calls are firmware names.
The 23 service-table slots and the 3 `PtrStrList` methods are table-plug-in routines. Slot `+0xCC`
is `KssPad16`, which already had a name. The lane gives `kn7000_sp7001_table_manual.sym` names
for 17 more slots and the 3 methods, where the code is clear (`KssThrow`, `KssTraceForward`,
`KssFread`, `PtrStrListCreate`, ...). Slots `+0x80`, `+0x90`, `+0xE8`, `+0x10C` and `+0x130` are
described in the lane's findings but not named. [INFERENCE] `0x502992C4`, named
`KssActivationStatus`, is the base plug-in's *pending-exception code*: `KssThrow` stores the
thrown code there, `KssThrowBug` stores 1, `KssTraceForward` tests it for 1, and 72 instructions of
`table.s` read or write it. `KssPasswordCheck`, as it is in `table.s`, does not write it. Q2 below
still holds: the load comes first. But "activation status" is probably the wrong reading of that
word.

**Load before activation (Q2).** In `Ap_Ce_StartUp` (`0x483EA0A6`) the base-extension load case
reads a latch `KssBaseExtLoadedLatch` (`0x50299070`); when it is 0 it calls `KssPluginLoad(d0=3)`
to read `BASEEXT.XAP` to RAM `0x5029B000` and run it, then sets the latch to 1 (so it loads once).
Only *after* the load returns does it read `KssActivationStatus` (`0x502992C4`, 0 = ok). The
activation gate (`KssPasswordCheck`/`KssKeyCompare`) is on user-action paths, not on the load path.
So an `.XAP` on the SD card runs on a never-activated unit; activation releases features, it does
not gate the load. (This strengthens the dumper-plug-in dumping route: a dumper `.XAP` in place of
`BASEEXT.XAP` would execute at startup without activation.)

**Program 942 vs its disks (Q4).** `make verify-sp7001-progdisks`: `HAMA1.SLD` + `HAMA2.SLD`
decompress to exactly program 942 (`0x000000`-`0x3F8BDB`; the dump's tail is 0xFF). Their
`SMCKPR1.INF` = `SMCKPR2.INF`, total `0x18C91B13`, matches none of the images held (942, 941, 935)
in total or in any block, so like the table's it predates the final build -- but here there is no
earlier image on hand to match it against.

## Still open

- ~~Of `BASEEXT.XAP`'s 1,340 indirect calls, 701 go through MILK objects other than the framework
  object.~~ **Split 2026-11-02** (see "The other 701" above). 1,316 are resolved: 967 to firmware
  names through the registry, and 349 to table-plug-in routines (the service table and the
  `PtrStrList` vtable). That leaves **24** whose target the static evaluator cannot see:
  - 11 read a function pointer out of a structure on the stack, at `0x5029D437`, `0x5029D44D`,
    `0x502A1FFC`, `0x502A206E`, `0x502A2157`, `0x502A2184`, `0x502A29AE`, `0x502A53E1`,
    `0x502A540D`, `0x502A5476` and `0x502A54CE`;
  - 6 index a pointer table by a register, at `0x502A2BC1`, `0x502A88B2`, `0x502A88BB`,
    `0x502A88DE`, `0x502A88E9` and `0x502AB12A`;
  - 5 go through a parameter, at `0x502A6BF9`, `0x502AB0A4`, `0x502AB0B1`, `0x502AB104` and
    `0x502AB145`;
  - 1 goes through service-table slot `+0x04` (a pointer into `KssWorkRam`), at `0x502A1B78`;
  - 1 calls a returned pointer, at `0x502A2E38`.

  The next step for each is to trace the callers of its routine, or the store that fills the
  local structure. `oldbuilds_baseext_indirect_calls.py -v` lists every site. Five service-table
  slots are still unnamed: `+0x80` (a 12-way dispatch through `0x483F88C0`), `+0x90` (returns
  `*(0x50299084)`), `+0xE8` (MILK UI calls with id `0x00E30047`), `+0x10C` (activation, through
  `KssBuildParam1`) and `+0x130` (returns field `+0x18` of an object whose magic is `0x41DA4C8B`).
- The v1.4 program update's **disk 1** (`kn7-14_1.exe` -> `JK1.SLD`, build 929) is the one lost disk
  in this family (only a Wayback "page not found" stub), which is why MAME's `v14` BIOS has
  `NO_DUMP` for the lower half.
