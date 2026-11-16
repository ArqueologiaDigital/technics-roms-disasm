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

## Rounds

Every C file that went into a run is committed in `probes/` (or `hdae5000/cc900-staged/`) before the run.  The runs
are in the private oracle repository (`~/compartilhado/cc900-oracle/runs/`).

| run                    | C                                     | result                                                                     |
|------------------------|---------------------------------------|----------------------------------------------------------------------------|
| `2026-11-16-44-hd-r1`  | `hd_r1a.c`, `hd_r1b.c`, 3 option sets | 8 of 23 match, 263 B; the option set is `-Xr` without `-O`                 |
| `2026-11-16-46-hd-r2`  | `hd_r2_*.c`, staged                   | files with `#include` refused (THC1-Error-310); `TypeSel_BuildMask` again  |
| `2026-11-16-48-hd-r2b` | `hd_r2_l*/m*.c`, `hd_r2b_v.c`, staged | 3 more match (`SwapBytes16`, `Smf_SwapBytes16/32`); staged 8 recheck       |
| `2026-11-16-49-hd-r3`  | `hd_r3_*.c`, staged                   | 5 more match with cast table calls; 16 functions, 845 B                    |

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
- **Unsolved: address constants.**  The ROM folds a field offset into the symbol, `lda xwa,(sym+44:24)`, after
  computing an index.  V4.23 reassociates every spelling tried (`&arr[44] + ofs`, `arr + 44 + ofs`) to
  `ld xwa,sym` with the 44 added to the index (runs 46, 48).  For an array base, the ROM has `ld xhl,sym` (an
  immediate) where V4.23 writes `lda xhl,(sym)` (`DirName_Address`, five spellings, run 48).  This blocks the
  song-record family: `DeleteSongPart_*` matches its first 47 of 244 bytes, `LoadSong_*` its first 53.
