# cc900 phase 6 for the HD-AE5000 (lane_hd, 2026-11-16)

Goal: C for the HD-AE5000 expansion ROMs (`hdae5000/` = v2.06i, and the ported `hdae5000_v2_01i`,
`hdae5000_v1_15i`, `hdae5000_v1_10i`) that Toshiba cc900 V4.23 compiles to exactly the ROM's bytes.  The method is
lane_p6's (`notes/cc900-phase6-2026-11-16/README.md`): probe C goes through the oracle VM, each function of the
listing is compared with the ROM, and the C that matches is staged in `hdae5000/cc900-staged/`.

## Scripts

| script              | question it answers                                                                               | command (from the repository root)                                                                                                         |
|---------------------|---------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------|
| `survey.py`         | which v2.06i routines look like compiled C, how large they are, what they call                    | `python3 -B notes/cc900-c-hdae5000-2026-11-16/survey.py [--kind C?] [--max-bytes N]`                                                       |
|                     | the hand source of one function, as the survey delimits it                                        | `python3 -B notes/cc900-c-hdae5000-2026-11-16/survey.py --body LABEL [--comments]`                                                         |
| `hd_v423.py`        | prepare an oracle corpus from C files (local headers inlined)                                     | `python3 -B notes/cc900-c-hdae5000-2026-11-16/hd_v423.py --corpus DIR Xr FILE.c…`                                                          |
|                     | which functions of a V4.23 run give the ROM's bytes, in which C file and option set               | `python3 -B notes/cc900-c-hdae5000-2026-11-16/hd_v423.py --check RUN_DIR [--calr]`                                                         |
|                     | the same, written to `staged_v423.tsv` for the staged files (the dashboard reads it)              | `python3 -B notes/cc900-c-hdae5000-2026-11-16/hd_v423.py --check RUN_DIR --record`                                                         |
| `modules.py`        | where the original C modules (source files) were, from calr against near call (lane_sub's method) | `python3 -B notes/cc900-c-hdae5000-2026-11-16/modules.py --md modules.md`                                                                  |
| `gen_ws_header.py`  | the main CPU's workspace function tables as C structs (`hdae5000/cc900-staged/hdae_ws.h`)         | `python3 -B notes/cc900-c-hdae5000-2026-11-16/gen_ws_header.py > hdae5000/cc900-staged/hdae_ws.h`                                          |
| `gen_ids_header.py` | event codes and UI object ids as `#define`s (`hdae5000/cc900-staged/hdae_ids.h`)                  | `python3 -B notes/cc900-c-hdae5000-2026-11-16/gen_ids_header.py rebuilt_ROMs/hd-ae5000_v2_06i.llvm.elf > hdae5000/cc900-staged/hdae_ids.h` |

`survey.md` / `survey.tsv` are `survey.py --md survey.md --tsv survey.tsv` as of the commit that wrote them.

## The survey (v2.06i)

`survey.py` reads `hdae5000/*.s` and `symbols/hdae5000_symbols_reference.txt`.  A function is a column-0 label that
is called, whose address is taken, or that nothing reaches; the column-0 labels after it that only branches reach,
or that it falls into, are its inner blocks.  Its kind:

| kind   | functions | bytes   | meaning                                                                                       |
|--------|-----------|---------|-----------------------------------------------------------------------------------------------|
| C-calr | 148       | 46,544  | ends in a return, no hand sign, calls a function of the same module with `calr`               |
| hand?  | 28        | 33,156  | a sign of hand assembly (`ei`, `ldirw`, `djnz`, data among instructions; some are C)          |
| C?     | 254       | 29,652  | ends in a return, no hand sign, no `calr`: absolute `call`s and `call (xRR)` only             |
| other  | 444       | 24,400  | does not end in a return: switch arms, event-handler bodies that jump out, misdelimited parts |
| tail   | 41        | 11,618  | entered by falling through from the function before                                           |
| lib    | 31        | 1,713   | Toshiba library (`notes/toshiba-runtime-xref-2026-11-08`)                                     |
| total  | 946       | 147,083 |                                                                                               |

`calr`: asm900 shortens V4.23's `cal` to `calr` only for a target in the same source file, so the `calr` / `call`
choice also tells which functions shared a source file.  C-calr functions wait for lane_vmb's `cc900-module:`
marking; the C? ones can be checked now.

## Status (staged_v423.tsv, run `2026-11-16-60-hd-r9a`)

| tree              | functions | bytes | note                                                          |
|-------------------|-----------|-------|---------------------------------------------------------------|
| `hdae5000`        | 49        | 4,393 | 15 of them call a same-module routine (`cc900-module:` lists) |
| `hdae5000_v2_01i` | 36        | 3,609 | the v2.06i C unchanged (`port_staged.py`)                     |
| `hdae5000_v1_15i` | 26        | 2,822 | the same                                                      |
| `hdae5000_v1_10i` | 26        | 2,822 | the same                                                      |

The staged files are one per original module (a calr group, `survey.py --modules`): `hdae5000_lyrics.c`,
`hdae5000_pport_services.c`, `hdae5000_hd_tables.c`, `hdae5000_flsitem.c`, `hdae5000_song_io.c`; functions that call
nothing of their module are in `hdae5000_ui_display.c`, `hdae5000_hd_driver.c` and `hdae5000_song_check.c`.  A
module's relative calls are named in a `cc900-module:` comment (the build's rule since 7d0361673); `hd_v423.py`
reads it as the build does.  Before that rule, `hd_v423.py --calr` modelled the shortening from the ROM (a `call`
becomes `calr` where the ROM has a `calr` to the same target), and asm900's own object file of run 56 showed the
`calr`.

In the older images, the v2.06i C fails where it writes a v2.06i number: string addresses (`ram_2f...`, labels
longer than 31 characters that share their first 31), the RAM cell `ram_23085e`, a UI object id
(`Set_Menu_Visibility`).  `TypeSel_BuildMask` changed between v1.15i and v2.01i.  The lyrics functions do not exist
before v2.01i.

## Rounds

Every C file that went into a run is committed in `probes/` (or `hdae5000/cc900-staged/`) before the run.  The runs
are in the private oracle repository (`~/compartilhado/cc900-oracle/runs/`).

| run                             | C                                     | result                                                                    |
|---------------------------------|---------------------------------------|---------------------------------------------------------------------------|
| `2026-11-16-44-hd-r1`           | `hd_r1a.c`, `hd_r1b.c`, 3 option sets | 8 of 23 match, 263 B; the option set is `-Xr` without `-O`                |
| `2026-11-16-46-hd-r2`           | `hd_r2_*.c`, staged                   | files with `#include` refused (THC1-Error-310); `TypeSel_BuildMask` again |
| `2026-11-16-48-hd-r2b`          | `hd_r2_l*/m*.c`, `hd_r2b_v.c`, staged | 3 more match (`SwapBytes16`, `Smf_SwapBytes16/32`); staged 8 recheck      |
| `2026-11-16-49-hd-r3`           | `hd_r3_*.c`, staged                   | 5 more match with cast table calls; 16 functions, 845 B                   |
| `2026-11-16-50-hd-x1-compilers` | `hd_r2b_v.c`, IDE 2003 and V1.10      | the same bytes as V4.23: the spelling, not the compiler                   |
| `2026-11-16-52-hd-r4v`          | `hd_r4_v.c`                           | the integer-address idiom: `DeleteSongPart_Sqt`, `FlsItem_Clear` match    |
| `2026-11-16-54-hd-r5`           | `hd_r5_*.c`                           | all nine `DeleteSongPart_*` and `FlsItem_Clear`, 2,117 B                  |
| `2026-11-16-56-hd-r6`           | `hd_r4_pp*.c`, `hd_r6_l*.c`, staged   | the 26 staged functions recheck, 2,960 B (`staged_v423.tsv`); PPORT close |

What the runs showed:
- **Options: `-Xr` without `-O`** (run 44): `HD_GetBlockInfo` (a `switch`) and `SwapBytes32` (a `for` loop) match
  only at `-Xr`; at `-O3 -Xr` and `-O3 -XS -Xr` they differ.  This is also what lane_sub found for the sub-CPU
  payload.  The staged files say `cc900-options: -Xr`.
- **The main CPU's function tables.**  The HD-AE5000 calls the main CPU through `ws->tab[0x100].fns->F(...)` (and
  `tab[0x109]`); the ROM loads the pointer once, `ld xhl,(xwa+d16)`.  V4.23 writes `lda` and then `ld` for an
  array element (run 44) and for a struct member called directly (run 48).  Only a member read through a cast
  gives the single load (`UiObj_SetCaption`, run 44; all table calls, run 49).  `hdae_ws.h` therefore declares the
  members `void *`, and the C calls `CALLV(ROOT->SendEvent)(obj, ev, arg)` / `CALLR(int, HAMA->ref_sem_X)(1)`.
- **Headers in the VM.**  V4.23 could not open a header beside the C (run 46, THC1-Error-310), although `job.sh`
  passes `-I` with the source directory.  This was reported to lane_vmb.  Meanwhile `hd_v423.py --corpus` inlines
  `#include "..."` headers (only the `#define`s a file uses from `hdae_ids.h`).
- **Address constants** (runs 46, 48, 50, 52, 54): see "C idioms" below.  Toshiba IDE 2003 and V1.10 give the same
  bytes as V4.23 on the same probes (run 50), so nothing points to another compiler for the HD-AE5000.

## C idioms (V4.23 at -Xr) that give the ROM's code

Each was found by a run of several spellings; the run named is where the matching one was first seen.

| ROM shape                                                                             | C that gives it                                                               | run |
|---------------------------------------------------------------------------------------|-------------------------------------------------------------------------------|-----|
| index computed first, then `lda xR,(sym+field:24)`, `add xR,index`, access `(xR)`     | `*(T *)((unsigned long)&sym[field] + index)`: the address as an INTEGER       | 52  |
| function pointer from a table loaded once, `ld xhl,(xwa+d16)`, then `call (xhl)`      | member read through a cast to the function type: `((void (*)())tbl->F)(args)` | 49  |
| `switch` comparing cases in descending order, bodies in source order                  | an ordinary `switch` (`HD_GetBlockInfo`)                                      | 44  |
| a value returned in HL, built in a register local: `ld hl,wa; ld h,0; ...; add hl,wa` | statements on a local (`r = x & 0xff; x >>= 8; r <<= 8; r += x; return r;`)   | 48  |
| a parameter copied to XBC before use (`ld xbc,xwa`)                                   | a local copy of the parameter (`t = x;`), then work on `t`                    | 48  |

The integer-address idiom in detail.  The ROM's `DeleteSongPart_Sqt` computes the song record's offset
(`song*76 + dir*0x4c0 + 0x780`, the multiplies by the library's `C9H_mullu`) and then writes
`lda xwa,(HDAE5000_RAM_SongRecords-0x780+44:24); add xwa,xhl; ld xwa,(xwa)`: the field offset 44 is folded into the
symbol, the 0x780 stays in the index.  Every pointer spelling V4.23 was given reassociates the constant into the
index instead and loads the bare symbol (`add xhl,0x2c; ld xwa,sym`): `&a[44] + ofs`, `a + 44 + ofs`, a struct
member `p->slot[2]`, full struct indexing.  Only an integer sum keeps it with the symbol:

    #define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
    #define SLOT(k, d, s) (*(unsigned long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))

(`(unsigned long)a + 44 + ofs`, with the 44 added as an integer, differs again: run 52's `DelPartSqt_i1`.)  The same
gives `FlsItem_Clear`'s `lda xde,(HDAE5000_RAM_FlsRecords+16:24)`.

Still open: an array base loaded as an immediate, `ld xhl,sym; add xhl,xwa` (`DirName_Address`,
`FlsRecord_Address`).  V4.23 writes `lda xhl,(sym)` for every value spelling tried (runs 48, 52, 54), and the
integer form computes the index into XBC first.
