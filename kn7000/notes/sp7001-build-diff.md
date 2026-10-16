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

    make verify-sp7001          # both SP7001 images rebuilt byte-for-byte
    make symbols-sp7001         # port the symbols (needs the 941/84 baserom too)
    make program-src-sp7001     # regenerate src/sp7001/program.s   (needs unidasm)
    make table-src-sp7001       # regenerate src/sp7001/table.s     (needs unidasm)
    python3 -I tools/offset_map.py baserom/kn7000_program.rom baserom/kn7000_program_sp7001.rom kn7000.sym kn7000_manual.sym
    python3 -I tools/offset_map.py baserom/kn7000_table.rom   baserom/kn7000_table_sp7001.rom

The SP7001 reference images are the de-interleaved raw EPROM dumps
(`tools/rom_from_eproms.py`, from the private romset). Sanity: the same de-interleave of the
v16 dumps is byte-identical to this repo's `baserom/kn7000_{program,table}.rom` over their full
extracted length (the extraction only trims the trailing 0xFF padding).

| tool                         | question it answers                                                    |
|------------------------------|------------------------------------------------------------------------|
| `tools/rom_from_eproms.py`   | IC17/IC16 halves -> the linear 4 MiB image the CPU sees                |
| `tools/diff_builds.py`       | raw in-place byte diff (misleading across a shift; kept for reference) |
| `tools/offset_map.py`        | where did every byte of the old build go; which bytes are new          |
| `tools/port_symbols.py`      | which old names apply to the new build, and where                      |
| `tools/sp7001_exports.py`    | what the firmware calls the services it exports to the plug-in         |
| `tools/gen_program_s.py --profile sp7001` | the 942 program source, ported from 941's                 |
| `tools/gen_table_s.py`       | a table-image source, with the XAPR plug-in disassembled               |

## Program 941 -> 942: what actually changed

`tools/offset_map.py` aligns the two images with unique 24-byte anchors (every 0x100 bytes) and
difflib inside the gaps. Result: **42 insertions (7,692 B) and 30 deletions (306 B)**, net
+7,386 B = exactly the image growth (0x3F6F01 -> 0x3F8BDB). Everything else is the same bytes,
shifted:

| 941 file range        | delta  | content                                   |
|-----------------------|--------|-------------------------------------------|
| `0x000000-0x02A601`   | +0     | boot header, code region 1 (start)        |
| `0x02A663-0x031CB6`   | +2     | code region 1                             |
| `0x031D21-0x18599C`   | -17    | code region 1 (to its last function)      |
| `0x18599C-0x2BCEC4`   | +1268  | data region                               |
| `0x2BCEC4-0x3B0B79`   | +4132  | DSP record pool, data                     |
| `0x3B0BA8-0x3BC6BB`   | +6060 / +6068 | data tail, library image start     |
| `0x3BC765-0x3F547E`   | +6158  | library                                   |
| `0x3F547E-0x3F6F01`   | +6470 .. +7386 | library tail (uITRON kernel)     |

The edit sites, with what each one is:

| site (942)                         | size       | what it is                                                        |
|------------------------------------|------------|-------------------------------------------------------------------|
| `InitializeObjectTable` (0x4842A5xx) | net +2 B | four small instruction rewrites                                   |
| `InitializeBlock30..47` stub run   | -3, -16 B  | the 3-byte `InitializeBlock46` stub removed; its name now points at new code |
| `0x4858598B..0x48585E90`           | **+1285 B**| **new code**: `InitializeBlock46`, the XAPR plug-in host, 35 export forwarders/accessors |
| `0x486BD3B8..0x486BDEE8`           | **+2864 B**| **export name block**: 'loc_cpu', 'unl_cpu', ... 'PlugHome'       |
| `0x487B1B9D..0x487B231D` (+8 B)    | **+1928 B**| `InitializeBlock46`'s object records + the **export table**       |
| just before `DspTypeRecordTable`   | +8 B       | the table itself is unchanged (compared as relocated pointers)    |
| library `0x4C0036EA`               | **+87 B**  | new C-library `rand` / `srand` (both exported)                     |
| library tail `0x4C03C507..`        | +1,289 / -61 B | uITRON kernel growth: `preq_sem`, `del_tsk`, `sta_tsk`, `get_tid`, `clr_flg` are new code |

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

| routine                 | does                                                                           |
|-------------------------|--------------------------------------------------------------------------------|
| `PlugInProbe`           | 4-byte 'XAPR' at `0x483E8000` and at `*(0x483E8004)` (the footer) -> `PlugInPresent` (RAM `0x500066D0`) |
| `PlugInProbeCallSlot08` | re-probe, then call header slot `+0x08` with `a0 = 0x5011FABC`; called from `0x4854AC83` |
| `PlugInCallSlot0C`      | call slot `+0x0C`; called once per pass of the library main loop (`0x4C02BE74`) |
| `PlugInCallSlot10`      | call slot `+0x10` with `d0`/`d1`, else return -1; reached via a pointer at `0x48732EA0` |

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

| segment | 84                 | 83                   | note                                     |
|---------|--------------------|----------------------|------------------------------------------|
| seg07   | '84'               | '83'                 | the table's 4-byte build marker          |
| seg59   | data, 0x13980c B   | data, 0x131bdc B     | 31,789 B removed at its end (+ a 3-byte edit at its start) |
| seg68-70| '84' x3            | '80' x3              | three more 4-byte markers                |
| seg83   | 'Tech', 0x1248 B   | 'DMY', 4 B           | asset replaced by a stub (`TechnicsRhythmsTable` was here) |

Then, past the directory image (`0x3E0660`): 0xFF up to `0x3E8000`, and **the XAPR plug-in,
`0x483E8000..0x483FB5A0` (79,264 B)**. The raw in-place diff reported "1.78 MB changed"; that
was the -31,792 B shift after seg59.

## The XAPR plug-in in table flash

| range (CPU)                 | content                                                                        |
|-----------------------------|--------------------------------------------------------------------------------|
| `0x483E8000-0x483E803C`     | header: 'XAPR', footer pointer, slots `+08 XapSlot08`, `+0C XapSlot0C`, `+10 XapSlot10`, ten unused slots -> `XapSlotDefault` (`rets`) |
| `0x483E803C-0x483EF6C5`     | **code** (30,345 B): 141 chunks, all emitted as MN10300 assembly              |
| `0x483EF6C8-0x483FB59C`     | data: field-name strings, widget/descriptor tables, messages, two MILK reflection tables (35 names), 27 keystream records |
| `0x483FB59C`                | footer 'XAPR'                                                                  |

Its own reflection tables name 35 routines -- the Key Soft Service ("KSS") UI: `Ap_CE_Main`,
`Ap_Ce_StartUp`, `Ap_Ce_Fd2Sd` (floppy -> SD), `Ap_Ce_JukeBox`, `AcKssScreenMenuProc`, ...
(`kn7000_sp7001_table.sym`). The activation gate reverse-engineered in
`research-scratch/kn7000-sp7001-activation/` is named in `kn7000_sp7001_table_manual.sym`:
`KssPasswordCheck`, `KssActivationApply`, `KssKeyCompare`, `KssKeyTransform`, `KssHash275`,
`KssBuildParam1`, ... (8 of those 10 addresses are direct `call` targets; `KssBuildParam1` starts
with a `movm` prologue; the traced OK-handler address is a point inside a dispatcher and is kept
as a label). Two string addresses in the RE notes point inside strings; the curated file labels
the real starts (`KssMsgPluginReleased` `0x483F89A8`, `KssActivationFilePath` `0x483F892C`).

`BASEEXT.XAP` on the SP7001 table floppy (`technics_roms/media/sp7001_table_2of2.img`, label
'SP7001 TB2', with `JKTBL2.SLD`, `SMCKTB2.INF`) is **not** this blob: it is a separate, larger
KSS application (118,784 B, code from its first byte, no 'XAPR'); of 181 sampled 32-byte chunks
1 occurs in the blob, 17 in program 942, 163 nowhere in either flash image.

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

## Open

- The export names apply to build 941 too wherever their targets exist there; porting them back
  (inverse map) would name ~190 more 941 functions.
- `0x4C00203C` (a byte-compare loop the probe uses) has no name in any source.
- `SMCKTB2.INF` on the TB2 floppy carries per-block sums; checking table 83 against it is not done.
