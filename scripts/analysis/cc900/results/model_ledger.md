# Model ledger: 2026-11-09, model at the commit that adds this file version

Regenerate the rows with `sh model/ledger.sh` (from `scripts/analysis/cc900`).

| oracle                                                          | corpus             | exact                   |
|-----------------------------------------------------------------|--------------------|-------------------------|
| run 2026-11-08-7-micro, v423/none                               | micro/*.c          | 651 / 674 exact (96.6%) |
| run 2026-11-08-7-micro, ide2003/none                            | micro/*.c          | 648 / 674 exact (96.1%) |
| run 2026-11-08-7-micro, v110/none                               | micro/*.c          | 647 / 674 exact (96.0%) |
| run 2026-11-08-7-micro, v423/O3XS                               | micro/*.c          | 603 / 674 exact (89.5%) |
| run 2026-11-08-7-micro, v423/Xr                                 | micro/*.c          | 632 / 674 exact (93.8%) |
| run 2026-11-08-7-micro, v423/O3XSXr                             | micro/*.c          | 605 / 674 exact (89.8%) |
| run 2026-11-08-8-micro-ra, v423/none                            | micro/ra_*.c       | 23 / 42 exact (54.8%)   |
| run 2026-11-08-8-micro-ra, v423/O3XSXr                          | micro/ra_*.c       | 9 / 42 exact (21.4%)    |
| run 2026-11-08-6-abi-adecl, v423/Xr                             | abi/*.c            | 58 / 80 exact (72.5%)   |
| run 2026-11-08-6-abi-adecl, v423/O3XSXr                         | abi/*.c            | 58 / 80 exact (72.5%)   |
| run 2026-11-09-4-micro-switch, v423/none                        | micro/switch.c     | 2 / 25 exact (8.0%)     |
| run 2026-11-09-4-micro-switch, v423/Xr                          | micro/switch.c     | 22 / 25 exact (88.0%)   |
| run 2026-11-09-4-micro-switch, v423/O3XS                        | micro/switch.c     | 0 / 25 exact (0.0%)     |
| run 2026-11-09-4-micro-switch, v423/O3XSXr                      | micro/switch.c     | 20 / 25 exact (80.0%)   |
| run 2026-11-09-5-micro-optparams, v423/O3XS                     | micro/opt_params.c | 19 / 24 exact (79.2%)   |
| run 2026-11-09-5-micro-optparams, v423/O3XSXr                   | micro/opt_params.c | 0 / 24 exact (0.0%)     |
| run 2026-11-08-9-micro-optloops, v423/O3XS                      | micro/opt_loops.c  | 15 / 33 exact (45.5%)   |
| run 2026-11-08-5-libsrc97-O3XS, v423/O3XS, --personality v4.23  | 1997 LIB/SRC       | 111 / 147 exact (75.5%) |
| run 2026-11-08-5-libsrc97-O3XS, v423/O3XS, --personality kn5000 | 1997 LIB/SRC       | 109 / 147 exact (74.1%) |
| run 2026-11-09-3-proxy-tiny, v423/O3XSXr                        | firmware/tiny.c    | 6 / 6 exact (100.0%)    |

The library rows count listing pieces: since inline assembly is passed through (2026-11-09), an inline-assembly
label named `_x` / `.x` starts a piece of its own, as in Toshiba's listing, so the total rose from 79 to 144.
The two library rows score against V4.23's listing, so the kn5000 personality's lower count is expected: it
differs from V4.23 where the firmware does (`_ldiv`, `_ultoa`).


The library row: `score.py ORACLE $C/libsrc/*.C -D__900__ -D__LARGE__ -DFLOAT -D__CDECL= '-D__ASM(x)=' -I$C/inc`, where `$C` is
a scratch copy of V4.23's `LIB/SRC` (`libsrc/`) and `INCLUDE` (`inc/`, with lower-case symlinks `ctype.h -> CTYPE.H`
so that clang finds Toshiba's headers before the host's), made from `upstream_repos/file_archive/devrs.com/ngpcbins`.
Routines written in inline assembly (`__ASM`, `__HL` pseudo-registers) are not counted.
