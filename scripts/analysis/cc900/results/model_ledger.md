# Model ledger: 2026-11-09, model at the commit that adds this file version

Regenerate the rows with `sh model/ledger.sh` (from `scripts/analysis/cc900`).

| oracle                                                              | corpus             | exact                   |
|---------------------------------------------------------------------|--------------------|-------------------------|
| run 2026-11-08-7-micro, v423/none                                   | micro/*.c          | 667 / 674 exact (99.0%) |
| run 2026-11-08-7-micro, ide2003/none                                | micro/*.c          | 664 / 674 exact (98.5%) |
| run 2026-11-08-7-micro, v110/none                                   | micro/*.c          | 663 / 674 exact (98.4%) |
| run 2026-11-08-7-micro, v423/O3XS                                   | micro/*.c          | 632 / 674 exact (93.8%) |
| run 2026-11-08-7-micro, v423/Xr                                     | micro/*.c          | 637 / 674 exact (94.5%) |
| run 2026-11-08-7-micro, v423/O3XSXr                                 | micro/*.c          | 612 / 674 exact (90.8%) |
| run 2026-11-08-7-micro, ide2003/O3XS, --personality ide2003         | micro/*.c          | 631 / 674 exact (93.6%) |
| run 2026-11-08-7-micro, ide2003/Xr, --personality ide2003           | micro/*.c          | 631 / 674 exact (93.6%) |
| run 2026-11-08-7-micro, ide2003/O3XSXr, --personality ide2003       | micro/*.c          | 605 / 674 exact (89.8%) |
| run 2026-11-08-8-micro-ra, v423/none                                | micro/ra_*.c       | 29 / 42 exact (69.0%)   |
| run 2026-11-08-8-micro-ra, v423/O3XSXr                              | micro/ra_*.c       | 11 / 42 exact (26.2%)   |
| run 2026-11-08-6-abi-adecl, v423/Xr                                 | abi/*.c            | 69 / 80 exact (86.2%)   |
| run 2026-11-08-6-abi-adecl, v423/O3XSXr                             | abi/*.c            | 65 / 80 exact (81.2%)   |
| run 2026-11-09-4-micro-switch, v423/none                            | micro/switch.c     | 13 / 25 exact (52.0%)   |
| run 2026-11-09-4-micro-switch, v423/Xr                              | micro/switch.c     | 22 / 25 exact (88.0%)   |
| run 2026-11-09-4-micro-switch, v423/O3XS                            | micro/switch.c     | 0 / 25 exact (0.0%)     |
| run 2026-11-09-4-micro-switch, v423/O3XSXr                          | micro/switch.c     | 20 / 25 exact (80.0%)   |
| run 2026-11-09-5-micro-optparams, v423/O3XS                         | micro/opt_params.c | 19 / 24 exact (79.2%)   |
| run 2026-11-09-5-micro-optparams, v423/O3XSXr                       | micro/opt_params.c | 0 / 24 exact (0.0%)     |
| run 2026-11-09-6-micro-rahomes, v423/none                           | micro/ra_homes.c   | 9 / 25 exact (36.0%)    |
| run 2026-11-09-6-micro-rahomes, v423/O3XS                           | micro/ra_homes.c   | 7 / 25 exact (28.0%)    |
| run 2026-11-09-6-micro-rahomes, v423/Xr                             | micro/ra_homes.c   | 16 / 25 exact (64.0%)   |
| run 2026-11-09-6-micro-rahomes, v423/O3XSXr                         | micro/ra_homes.c   | 13 / 25 exact (52.0%)   |
| run 2026-11-09-7-micro-chains, v423/none                            | micro/ra_chains.c  | 28 / 33 exact (84.8%)   |
| run 2026-11-09-7-micro-chains, v423/O3XS                            | micro/ra_chains.c  | 26 / 33 exact (78.8%)   |
| run 2026-11-09-7-micro-chains, v423/Xr                              | micro/ra_chains.c  | 25 / 33 exact (75.8%)   |
| run 2026-11-09-7-micro-chains, v423/O3XSXr                          | micro/ra_chains.c  | 27 / 33 exact (81.8%)   |
| run 2026-11-09-8-micro-homes32, v423/none                           | micro/ra_homes32.c | 7 / 17 exact (41.2%)    |
| run 2026-11-09-8-micro-homes32, v423/O3XS                           | micro/ra_homes32.c | 4 / 17 exact (23.5%)    |
| run 2026-11-09-8-micro-homes32, v423/Xr                             | micro/ra_homes32.c | 4 / 17 exact (23.5%)    |
| run 2026-11-09-8-micro-homes32, v423/O3XSXr                         | micro/ra_homes32.c | 5 / 17 exact (29.4%)    |
| run 2026-11-09-9-micro-fp, v423/none                                | micro/fp.c         | 104 / 108 exact (96.3%) |
| run 2026-11-09-9-micro-fp, v423/O3XS                                | micro/fp.c         | 102 / 108 exact (94.4%) |
| run 2026-11-09-10-micro-fptemps, v423/none                          | micro/fp_temps.c   | 32 / 33 exact (97.0%)   |
| run 2026-11-09-10-micro-fptemps, v423/O3XS                          | micro/fp_temps.c   | 31 / 33 exact (93.9%)   |
| run 2026-11-08-9-micro-optloops, v423/O3XS                          | micro/opt_loops.c  | 15 / 33 exact (45.5%)   |
| run 2026-11-08-5-libsrc97-O3XS, v423/O3XS, --personality v4.23      | 1997 LIB/SRC       | 126 / 188 exact (67.0%) |
| run 2026-11-08-5-libsrc97-O3XS, v423/O3XS, --personality kn5000     | 1997 LIB/SRC       | 124 / 188 exact (66.0%) |
| run 2026-11-08-5-libsrc97-O3XS, ide2003/O3XS, --personality ide2003 | 1997 LIB/SRC       | 125 / 188 exact (66.5%) |
| run 2026-11-09-3-proxy-tiny, v423/O3XSXr                            | firmware/tiny.c    | 6 / 6 exact (100.0%)    |

The library rows count listing pieces: since inline assembly is passed through (2026-11-09), an inline-assembly
label named `_x` / `.x` starts a piece of its own, as in Toshiba's listing, so the total rose from 79 to 144; anonymous typedef'd unions (FLOAT.H) then brought more files in (188).
The two V4.23 library rows score against V4.23's listing, so the kn5000 personality's lower count is expected: it
differs from V4.23 where the firmware does (`_ldiv`, `_ultoa`).  The `ide2003` rows are the phase 7 by-product: the
2003 compiler's personality scored against that compiler's own listings.


The library row: `score.py ORACLE $C/libsrc/*.C -D__900__ -D__LARGE__ -DFLOAT -D__CDECL= '-D__ASM(x)=' -I$C/inc`, where `$C` is
a scratch copy of V4.23's `LIB/SRC` (`libsrc/`) and `INCLUDE` (`inc/`, with lower-case symlinks `ctype.h -> CTYPE.H`
so that clang finds Toshiba's headers before the host's), made from `upstream_repos/file_archive/devrs.com/ngpcbins`.
Routines written in inline assembly (`__ASM`, `__HL` pseudo-registers) are not counted.
