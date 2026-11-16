# cc900 phase 6 for the HD-AE5000 (lane_hd, 2026-11-16)

Goal: C for the HD-AE5000 expansion ROMs (`hdae5000/` = v2.06i, and the ported `hdae5000_v2_01i`,
`hdae5000_v1_15i`, `hdae5000_v1_10i`) that Toshiba cc900 V4.23 compiles to exactly the ROM's bytes.  The method is
lane_p6's (`notes/cc900-phase6-2026-11-16/README.md`): probe C goes through the oracle VM, each function of the
listing is compared with the ROM, and the C that matches is staged in `hdae5000/cc900-staged/`.

## Scripts

| script         | question it answers                                                                                     | command (from the repository root)                                                     |
|----------------|---------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------|
| `survey.py`    | which v2.06i routines look like compiled C, how large they are, what they call                          | `python3 -B notes/cc900-c-hdae5000-2026-11-16/survey.py [--kind C?] [--max-bytes N]`   |
|                | the hand source of one function, as the survey delimits it                                              | `python3 -B notes/cc900-c-hdae5000-2026-11-16/survey.py --body LABEL [--comments]`     |
| `hd_v423.py`   | prepare an oracle corpus from C files                                                                   | `python3 -B notes/cc900-c-hdae5000-2026-11-16/hd_v423.py --corpus DIR O3Xr,Xr FILE.c…` |
|                | which functions of a V4.23 run give the ROM's bytes, in which C file and option set                     | `python3 -B notes/cc900-c-hdae5000-2026-11-16/hd_v423.py --check RUN_DIR [--tsv OUT]`  |

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

See below, one section per oracle run.
