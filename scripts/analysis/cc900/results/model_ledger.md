# Model ledger: 2026-11-09, model at the commit that adds this file version

| oracle                                     | corpus                                        | exact                   |
|--------------------------------------------|-----------------------------------------------|-------------------------|
| run 2026-11-08-7-micro, v423/none          | micro/*.c                                     | 650 / 674 exact (96.4%) |
| run 2026-11-08-8-micro-ra, v423/none       | micro/ra_*.c                                  | 23 / 42 exact (54.8%)   |
| run 2026-11-08-7-micro, ide2003/none       | micro/*.c                                     | 647 / 674 exact (96.0%) |
| run 2026-11-08-7-micro, v110/none          | micro/*.c                                     | 646 / 674 exact (95.8%) |
| run 2026-11-08-7-micro, v423/O3XS          | micro/*.c                                     | 590 / 674 exact (87.5%) |
| run 2026-11-08-7-micro, v423/Xr            | micro/*.c                                     | 552 / 674 exact (81.9%) |
| run 2026-11-08-7-micro, v423/O3XSXr        | micro/*.c                                     | 549 / 674 exact (81.5%) |
| run 2026-11-08-8-micro-ra, v423/O3XSXr     | micro/ra_*.c                                  | 0 / 42 exact (0.0%)     |
| run 2026-11-08-9-micro-optloops, v423/O3XS | micro/opt_loops.c                             | 15 / 33 exact (45.5%)   |
| run 2026-11-08-5-libsrc97-O3XS, v423/O3XS  | 1997 LIB/SRC (the files the front end parses) | 13 / 71 exact (18.3%)   |

The library row: `score.py ORACLE $C/libsrc/*.C -D__900__ -D__LARGE__ -DFLOAT -D__CDECL= '-D__ASM(x)=' -I$C/inc`, where `$C` is
a scratch copy of V4.23's `LIB/SRC` (`libsrc/`) and `INCLUDE` (`inc/`, with lower-case symlinks `ctype.h -> CTYPE.H`
so that clang finds Toshiba's headers before the host's), made from `upstream_repos/file_archive/devrs.com/ngpcbins`.
Routines written in inline assembly (`__ASM`, `__HL` pseudo-registers) are not counted.
