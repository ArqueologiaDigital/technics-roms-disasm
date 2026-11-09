# Model ledger: 2026-11-09, model at the commit that adds this file version

Regenerate the rows with `sh model/ledger.sh` (from `scripts/analysis/cc900`).

| oracle                                                              | corpus               | exact                    |
|---------------------------------------------------------------------|----------------------|--------------------------|
| run 2026-11-08-7-micro, v423/none                                   | micro/*.c            | 674 / 674 exact (100.0%) |
| run 2026-11-08-7-micro, ide2003/none                                | micro/*.c            | 670 / 674 exact (99.4%)  |
| run 2026-11-08-7-micro, v110/none                                   | micro/*.c            | 667 / 674 exact (99.0%)  |
| run 2026-11-08-7-micro, v423/O3XS                                   | micro/*.c            | 674 / 674 exact (100.0%) |
| run 2026-11-08-7-micro, v423/Xr                                     | micro/*.c            | 674 / 674 exact (100.0%) |
| run 2026-11-08-7-micro, v423/O3XSXr                                 | micro/*.c            | 674 / 674 exact (100.0%) |
| run 2026-11-08-7-micro, ide2003/O3XS, --personality ide2003         | micro/*.c            | 672 / 674 exact (99.7%)  |
| run 2026-11-08-7-micro, ide2003/Xr, --personality ide2003           | micro/*.c            | 667 / 674 exact (99.0%)  |
| run 2026-11-08-7-micro, ide2003/O3XSXr, --personality ide2003       | micro/*.c            | 660 / 674 exact (97.9%)  |
| run 2026-11-08-8-micro-ra, v423/none                                | micro/ra_*.c         | 33 / 42 exact (78.6%)    |
| run 2026-11-08-8-micro-ra, v423/O3XSXr                              | micro/ra_*.c         | 23 / 42 exact (54.8%)    |
| run 2026-11-08-4-abi, v423/none                                     | abi/*.c              | 98 / 108 exact (90.7%)   |
| run 2026-11-08-4-abi, v423/O3XS                                     | abi/*.c              | 97 / 108 exact (89.8%)   |
| run 2026-11-08-6-abi-adecl, v423/Xr                                 | abi/*.c              | 73 / 80 exact (91.2%)    |
| run 2026-11-08-6-abi-adecl, v423/O3XSXr                             | abi/*.c              | 75 / 80 exact (93.8%)    |
| run 2026-11-09-4-micro-switch, v423/none                            | micro/switch.c       | 22 / 25 exact (88.0%)    |
| run 2026-11-09-4-micro-switch, v423/Xr                              | micro/switch.c       | 22 / 25 exact (88.0%)    |
| run 2026-11-09-4-micro-switch, v423/O3XS                            | micro/switch.c       | 22 / 25 exact (88.0%)    |
| run 2026-11-09-4-micro-switch, v423/O3XSXr                          | micro/switch.c       | 25 / 25 exact (100.0%)   |
| run 2026-11-09-5-micro-optparams, v423/O3XS                         | micro/opt_params.c   | 19 / 24 exact (79.2%)    |
| run 2026-11-09-5-micro-optparams, v423/O3XSXr                       | micro/opt_params.c   | 22 / 24 exact (91.7%)    |
| run 2026-11-09-6-micro-rahomes, v423/none                           | micro/ra_homes.c     | 13 / 25 exact (52.0%)    |
| run 2026-11-09-6-micro-rahomes, v423/O3XS                           | micro/ra_homes.c     | 9 / 25 exact (36.0%)     |
| run 2026-11-09-6-micro-rahomes, v423/Xr                             | micro/ra_homes.c     | 18 / 25 exact (72.0%)    |
| run 2026-11-09-6-micro-rahomes, v423/O3XSXr                         | micro/ra_homes.c     | 17 / 25 exact (68.0%)    |
| run 2026-11-09-7-micro-chains, v423/none                            | micro/ra_chains.c    | 28 / 33 exact (84.8%)    |
| run 2026-11-09-7-micro-chains, v423/O3XS                            | micro/ra_chains.c    | 26 / 33 exact (78.8%)    |
| run 2026-11-09-7-micro-chains, v423/Xr                              | micro/ra_chains.c    | 26 / 33 exact (78.8%)    |
| run 2026-11-09-7-micro-chains, v423/O3XSXr                          | micro/ra_chains.c    | 28 / 33 exact (84.8%)    |
| run 2026-11-09-8-micro-homes32, v423/none                           | micro/ra_homes32.c   | 7 / 17 exact (41.2%)     |
| run 2026-11-09-8-micro-homes32, v423/O3XS                           | micro/ra_homes32.c   | 8 / 17 exact (47.1%)     |
| run 2026-11-09-8-micro-homes32, v423/Xr                             | micro/ra_homes32.c   | 5 / 17 exact (29.4%)     |
| run 2026-11-09-8-micro-homes32, v423/O3XSXr                         | micro/ra_homes32.c   | 6 / 17 exact (35.3%)     |
| run 2026-11-09-14-micro-libshapes, v423/none                        | micro/ra_libshapes.c | 10 / 21 exact (47.6%)    |
| run 2026-11-09-14-micro-libshapes, v423/O3XS                        | micro/ra_libshapes.c | 16 / 21 exact (76.2%)    |
| run 2026-11-09-14-micro-libshapes, v423/Xr                          | micro/ra_libshapes.c | 12 / 21 exact (57.1%)    |
| run 2026-11-09-14-micro-libshapes, v423/O3XSXr                      | micro/ra_libshapes.c | 13 / 21 exact (61.9%)    |
| run 2026-11-09-15-micro-fporder, v423/none                          | micro/fp_order.c     | 10 / 18 exact (55.6%)    |
| run 2026-11-09-15-micro-fporder, v423/O3XS                          | micro/fp_order.c     | 8 / 18 exact (44.4%)     |
| run 2026-11-09-18-micro-fpprepass, v423/none                        | probes/fpp1.c        | 15 / 71 exact (21.1%)    |
| run 2026-11-09-19-micro-fpprepass2, v423/none                       | probes/fpp2.c        | 10 / 49 exact (20.4%)    |
| run 2026-11-09-18-micro-fpprepass, v423/O3XS                        | probes/fpp1.c        | 16 / 71 exact (22.5%)    |
| run 2026-11-09-19-micro-fpprepass2, v423/O3XS                       | probes/fpp2.c        | 10 / 49 exact (20.4%)    |
| run 2026-11-09-22-micro-condbits, v423/none                         | micro/cond_bits.c    | 111 / 117 exact (94.9%)  |
| run 2026-11-09-22-micro-condbits, v423/O3XS                         | micro/cond_bits.c    | 111 / 117 exact (94.9%)  |
| run 2026-11-09-22-micro-condbits, v423/Xr                           | micro/cond_bits.c    | 111 / 117 exact (94.9%)  |
| run 2026-11-09-22-micro-condbits, v423/O3XSXr                       | micro/cond_bits.c    | 110 / 117 exact (94.0%)  |
| run 2026-11-09-23-micro-assignexpr, v423/none                       | micro/assign_expr.c  | 30 / 43 exact (69.8%)    |
| run 2026-11-09-23-micro-assignexpr, v423/O3XS                       | micro/assign_expr.c  | 31 / 43 exact (72.1%)    |
| run 2026-11-09-23-micro-assignexpr, v423/Xr                         | micro/assign_expr.c  | 27 / 43 exact (62.8%)    |
| run 2026-11-09-23-micro-assignexpr, v423/O3XSXr                     | micro/assign_expr.c  | 36 / 43 exact (83.7%)    |
| run 2026-11-09-24-micro-arrindex, v423/none                         | micro/arr_index.c    | 50 / 66 exact (75.8%)    |
| run 2026-11-09-25-micro-arrindexsz, v423/none                       | micro/arr_index_sz.c | 51 / 66 exact (77.3%)    |
| run 2026-11-09-24-micro-arrindex, v423/O3XS                         | micro/arr_index.c    | 48 / 66 exact (72.7%)    |
| run 2026-11-09-25-micro-arrindexsz, v423/O3XS                       | micro/arr_index_sz.c | 48 / 66 exact (72.7%)    |
| run 2026-11-09-24-micro-arrindex, v423/Xr                           | micro/arr_index.c    | 47 / 66 exact (71.2%)    |
| run 2026-11-09-25-micro-arrindexsz, v423/Xr                         | micro/arr_index_sz.c | 48 / 66 exact (72.7%)    |
| run 2026-11-09-24-micro-arrindex, v423/O3XSXr                       | micro/arr_index.c    | 47 / 66 exact (71.2%)    |
| run 2026-11-09-25-micro-arrindexsz, v423/O3XSXr                     | micro/arr_index_sz.c | 47 / 66 exact (71.2%)    |
| run 2026-11-09-9-micro-fp, v423/none                                | micro/fp.c           | 108 / 108 exact (100.0%) |
| run 2026-11-09-9-micro-fp, v423/O3XS                                | micro/fp.c           | 108 / 108 exact (100.0%) |
| run 2026-11-09-10-micro-fptemps, v423/none                          | micro/fp_temps.c     | 33 / 33 exact (100.0%)   |
| run 2026-11-09-10-micro-fptemps, v423/O3XS                          | micro/fp_temps.c     | 33 / 33 exact (100.0%)   |
| run 2026-11-09-11-micro-opttemps, v423/Xr                           | micro/opt_temps.c    | 33 / 38 exact (86.8%)    |
| run 2026-11-09-11-micro-opttemps, v423/O3XSXr                       | micro/opt_temps.c    | 38 / 38 exact (100.0%)   |
| run 2026-11-09-12-micro-optcounted, v423/none                       | micro/opt_counted.c  | 24 / 32 exact (75.0%)    |
| run 2026-11-09-12-micro-optcounted, v423/O3XS                       | micro/opt_counted.c  | 29 / 32 exact (90.6%)    |
| run 2026-11-09-12-micro-optcounted, v423/Xr                         | micro/opt_counted.c  | 31 / 32 exact (96.9%)    |
| run 2026-11-09-12-micro-optcounted, v423/O3XSXr                     | micro/opt_counted.c  | 32 / 32 exact (100.0%)   |
| run 2026-11-09-13-micro-fpstmts, v423/none                          | micro/fp_stmts.c     | 14 / 16 exact (87.5%)    |
| run 2026-11-09-13-micro-fpstmts, v423/O3XS                          | micro/fp_stmts.c     | 9 / 16 exact (56.2%)     |
| run 2026-11-08-9-micro-optloops, v423/O3XS                          | micro/opt_loops.c    | 28 / 33 exact (84.8%)    |
| run 2026-11-08-5-libsrc97-O3XS, v423/O3XS, --personality v4.23      | 1997 LIB/SRC         | 161 / 248 exact (64.9%)  |
| run 2026-11-08-5-libsrc97-O3XS, v423/O3XS, --personality kn5000     | 1997 LIB/SRC         | 159 / 248 exact (64.1%)  |
| run 2026-11-08-5-libsrc97-O3XS, ide2003/O3XS, --personality ide2003 | 1997 LIB/SRC         | 152 / 248 exact (61.3%)  |
| run 2026-11-09-3-proxy-tiny, v423/O3XSXr                            | firmware/tiny.c      | 6 / 6 exact (100.0%)     |
| run 2026-11-08-8-micro-ra, v423/O3XS                                | micro/ra_*.c         | 20 / 42 exact (47.6%)    |
| run 2026-11-08-8-micro-ra, v423/Xr                                  | micro/ra_*.c         | 23 / 42 exact (54.8%)    |
| run 2026-11-08-9-micro-optloops, v423/none                          | micro/opt_loops.c    | 23 / 33 exact (69.7%)    |
| run 2026-11-08-9-micro-optloops, v423/Xr                            | micro/opt_loops.c    | 30 / 33 exact (90.9%)    |
| run 2026-11-08-9-micro-optloops, v423/O3XSXr                        | micro/opt_loops.c    | 29 / 33 exact (87.9%)    |

The library rows count listing pieces: since inline assembly is passed through (2026-11-09), an inline-assembly
label named `_x` / `.x` starts a piece of its own, as in Toshiba's listing, so the total rose from 79 to 144; anonymous typedef'd unions (FLOAT.H) then brought more files in (188), and on 2026-11-09 the files that include
`errno.h` (which ends in a DOS end-of-file byte; the front end now mirrors such include directories with the byte
cut) and unnamed local unions (`_ldexp`, `_frexp`, `_fint`) brought 248.
The two V4.23 library rows score against V4.23's listing, so the kn5000 personality's lower count is expected: it
differs from V4.23 where the firmware does (`_ldiv`, `_ultoa`).  The `ide2003` rows are the phase 7 by-product: the
2003 compiler's personality scored against that compiler's own listings.


The library row: `score.py ORACLE $C/libsrc/*.C -D__900__ -D__LARGE__ -DFLOAT -D__CDECL= '-D__ASM(x)=' -I$C/inc`, where `$C` is
a scratch copy of V4.23's `LIB/SRC` (`libsrc/`) and `INCLUDE` (`inc/`, with lower-case symlinks `ctype.h -> CTYPE.H`
so that clang finds Toshiba's headers before the host's), made from `upstream_repos/file_archive/devrs.com/ngpcbins`.
Routines written in inline assembly (`__ASM`, `__HL` pseudo-registers) are not counted.

The abi rows (runs 2026-11-08-4 and -6) read Toshiba's headers from the library scratch copy (`-I$C/inc`), as the
oracle did: `varargs.c` uses `stdarg.h`, whose macros differ from clang's builtin one.  Before 2026-11-09 that file
failed in the front end and counted as 0.
