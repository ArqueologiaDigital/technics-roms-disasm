# Model ledger: 2026-11-10, model at the commit that adds this file version (HOMES2 = fallback-noloop)

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
| run 2026-11-08-8-micro-ra, v423/none                                | micro/ra_*.c         | 34 / 42 exact (81.0%)    |
| run 2026-11-08-8-micro-ra, v423/O3XSXr                              | micro/ra_*.c         | 24 / 42 exact (57.1%)    |
| run 2026-11-08-4-abi, v423/none                                     | abi/*.c              | 102 / 108 exact (94.4%)  |
| run 2026-11-08-4-abi, v423/O3XS                                     | abi/*.c              | 100 / 108 exact (92.6%)  |
| run 2026-11-08-6-abi-adecl, v423/Xr                                 | abi/*.c              | 75 / 80 exact (93.8%)    |
| run 2026-11-08-6-abi-adecl, v423/O3XSXr                             | abi/*.c              | 77 / 80 exact (96.2%)    |
| run 2026-11-09-4-micro-switch, v423/none                            | micro/switch.c       | 23 / 25 exact (92.0%)    |
| run 2026-11-09-4-micro-switch, v423/Xr                              | micro/switch.c       | 23 / 25 exact (92.0%)    |
| run 2026-11-09-4-micro-switch, v423/O3XS                            | micro/switch.c       | 22 / 25 exact (88.0%)    |
| run 2026-11-09-4-micro-switch, v423/O3XSXr                          | micro/switch.c       | 25 / 25 exact (100.0%)   |
| run 2026-11-09-5-micro-optparams, v423/O3XS                         | micro/opt_params.c   | 21 / 24 exact (87.5%)    |
| run 2026-11-09-5-micro-optparams, v423/O3XSXr                       | micro/opt_params.c   | 22 / 24 exact (91.7%)    |
| run 2026-11-09-6-micro-rahomes, v423/none                           | micro/ra_homes.c     | 14 / 25 exact (56.0%)    |
| run 2026-11-09-6-micro-rahomes, v423/O3XS                           | micro/ra_homes.c     | 10 / 25 exact (40.0%)    |
| run 2026-11-09-6-micro-rahomes, v423/Xr                             | micro/ra_homes.c     | 21 / 25 exact (84.0%)    |
| run 2026-11-09-6-micro-rahomes, v423/O3XSXr                         | micro/ra_homes.c     | 23 / 25 exact (92.0%)    |
| run 2026-11-09-7-micro-chains, v423/none                            | micro/ra_chains.c    | 28 / 33 exact (84.8%)    |
| run 2026-11-09-7-micro-chains, v423/O3XS                            | micro/ra_chains.c    | 27 / 33 exact (81.8%)    |
| run 2026-11-09-7-micro-chains, v423/Xr                              | micro/ra_chains.c    | 29 / 33 exact (87.9%)    |
| run 2026-11-09-7-micro-chains, v423/O3XSXr                          | micro/ra_chains.c    | 29 / 33 exact (87.9%)    |
| run 2026-11-09-8-micro-homes32, v423/none                           | micro/ra_homes32.c   | 7 / 17 exact (41.2%)     |
| run 2026-11-09-8-micro-homes32, v423/O3XS                           | micro/ra_homes32.c   | 8 / 17 exact (47.1%)     |
| run 2026-11-09-8-micro-homes32, v423/Xr                             | micro/ra_homes32.c   | 5 / 17 exact (29.4%)     |
| run 2026-11-09-8-micro-homes32, v423/O3XSXr                         | micro/ra_homes32.c   | 13 / 17 exact (76.5%)    |
| run 2026-11-09-14-micro-libshapes, v423/none                        | micro/ra_libshapes.c | 12 / 21 exact (57.1%)    |
| run 2026-11-09-14-micro-libshapes, v423/O3XS                        | micro/ra_libshapes.c | 17 / 21 exact (81.0%)    |
| run 2026-11-09-14-micro-libshapes, v423/Xr                          | micro/ra_libshapes.c | 12 / 21 exact (57.1%)    |
| run 2026-11-09-14-micro-libshapes, v423/O3XSXr                      | micro/ra_libshapes.c | 13 / 21 exact (61.9%)    |
| run 2026-11-09-15-micro-fporder, v423/none                          | micro/fp_order.c     | 12 / 18 exact (66.7%)    |
| run 2026-11-09-15-micro-fporder, v423/O3XS                          | micro/fp_order.c     | 10 / 18 exact (55.6%)    |
| run 2026-11-09-18-micro-fpprepass, v423/none                        | probes/fpp1.c        | 32 / 71 exact (45.1%)    |
| run 2026-11-09-19-micro-fpprepass2, v423/none                       | probes/fpp2.c        | 25 / 49 exact (51.0%)    |
| run 2026-11-09-18-micro-fpprepass, v423/O3XS                        | probes/fpp1.c        | 31 / 71 exact (43.7%)    |
| run 2026-11-09-19-micro-fpprepass2, v423/O3XS                       | probes/fpp2.c        | 25 / 49 exact (51.0%)    |
| run 2026-11-09-26-micro-fpe2, v423/none                             | probes/fpp3.c        | 48 / 59 exact (81.4%)    |
| run 2026-11-09-28-micro-fpe2b, v423/none                            | probes/fpp4.c        | 55 / 59 exact (93.2%)    |
| run 2026-11-09-26-micro-fpe2, v423/O3XS                             | probes/fpp3.c        | 47 / 59 exact (79.7%)    |
| run 2026-11-09-28-micro-fpe2b, v423/O3XS                            | probes/fpp4.c        | 51 / 59 exact (86.4%)    |
| run 2026-11-09-36-micro-fpe2c, v423/none                            | probes/fpp5.c        | 91 / 100 exact (91.0%)   |
| run 2026-11-09-36-micro-fpe2c, v423/O3XS                            | probes/fpp5.c        | 86 / 100 exact (86.0%)   |
| run 2026-11-09-38-micro-fpe2d, v423/none                            | probes/fpp6.c        | 33 / 56 exact (58.9%)    |
| run 2026-11-09-38-micro-fpe2d, v423/O3XS                            | probes/fpp6.c        | 18 / 56 exact (32.1%)    |
| run 2026-11-09-39-micro-fpe2e, v423/none                            | probes/fpp7.c        | 44 / 79 exact (55.7%)    |
| run 2026-11-09-39-micro-fpe2e, v423/O3XS                            | probes/fpp7.c        | 44 / 79 exact (55.7%)    |
| run 2026-11-09-40-micro-fpe2f, v423/none                            | probes/fpp8.c        | 46 / 108 exact (42.6%)   |
| run 2026-11-09-40-micro-fpe2f, v423/O3XS                            | probes/fpp8.c        | 41 / 108 exact (38.0%)   |
| run 2026-11-09-41-micro-fpe2g, v423/none                            | probes/fpp9.c        | 8 / 60 exact (13.3%)     |
| run 2026-11-09-41-micro-fpe2g, v423/O3XS                            | probes/fpp9.c        | 8 / 60 exact (13.3%)     |
| run 2026-11-10-2-micro-fpe3a, v423/none                             | probes/fpp10.c       | 71 / 102 exact (69.6%)   |
| run 2026-11-10-2-micro-fpe3a, v423/O3XS                             | probes/fpp10.c       | 68 / 102 exact (66.7%)   |
| run 2026-11-10-3-micro-fpe3b, v423/none                             | probes/fpp11.c       | 45 / 99 exact (45.5%)    |
| run 2026-11-10-3-micro-fpe3b, v423/O3XS                             | probes/fpp11.c       | 40 / 99 exact (40.4%)    |
| run 2026-11-09-22-micro-condbits, v423/none                         | micro/cond_bits.c    | 114 / 117 exact (97.4%)  |
| run 2026-11-09-22-micro-condbits, v423/O3XS                         | micro/cond_bits.c    | 113 / 117 exact (96.6%)  |
| run 2026-11-09-22-micro-condbits, v423/Xr                           | micro/cond_bits.c    | 114 / 117 exact (97.4%)  |
| run 2026-11-09-22-micro-condbits, v423/O3XSXr                       | micro/cond_bits.c    | 113 / 117 exact (96.6%)  |
| run 2026-11-09-23-micro-assignexpr, v423/none                       | micro/assign_expr.c  | 36 / 43 exact (83.7%)    |
| run 2026-11-09-23-micro-assignexpr, v423/O3XS                       | micro/assign_expr.c  | 37 / 43 exact (86.0%)    |
| run 2026-11-09-23-micro-assignexpr, v423/Xr                         | micro/assign_expr.c  | 27 / 43 exact (62.8%)    |
| run 2026-11-09-23-micro-assignexpr, v423/O3XSXr                     | micro/assign_expr.c  | 41 / 43 exact (95.3%)    |
| run 2026-11-09-24-micro-arrindex, v423/none                         | micro/arr_index.c    | 57 / 66 exact (86.4%)    |
| run 2026-11-09-25-micro-arrindexsz, v423/none                       | micro/arr_index_sz.c | 58 / 66 exact (87.9%)    |
| run 2026-11-09-24-micro-arrindex, v423/O3XS                         | micro/arr_index.c    | 60 / 66 exact (90.9%)    |
| run 2026-11-09-25-micro-arrindexsz, v423/O3XS                       | micro/arr_index_sz.c | 60 / 66 exact (90.9%)    |
| run 2026-11-09-24-micro-arrindex, v423/Xr                           | micro/arr_index.c    | 56 / 66 exact (84.8%)    |
| run 2026-11-09-25-micro-arrindexsz, v423/Xr                         | micro/arr_index_sz.c | 57 / 66 exact (86.4%)    |
| run 2026-11-09-24-micro-arrindex, v423/O3XSXr                       | micro/arr_index.c    | 61 / 66 exact (92.4%)    |
| run 2026-11-09-25-micro-arrindexsz, v423/O3XSXr                     | micro/arr_index_sz.c | 61 / 66 exact (92.4%)    |
| run 2026-11-09-29-micro-adfp, v423/none                             | probes/adfp.c        | 15 / 15 exact (100.0%)   |
| run 2026-11-09-29-micro-adfp, v423/O3XS                             | probes/adfp.c        | 15 / 15 exact (100.0%)   |
| run 2026-11-09-29-micro-adfp, v423/Xr                               | probes/adfp.c        | 15 / 15 exact (100.0%)   |
| run 2026-11-09-29-micro-adfp, v423/O3XSXr                           | probes/adfp.c        | 15 / 15 exact (100.0%)   |
| run 2026-11-09-30-micro-chnarrow, v423/none                         | probes/chnarrow.c    | 19 / 20 exact (95.0%)    |
| run 2026-11-09-30-micro-chnarrow, v423/O3XS                         | probes/chnarrow.c    | 18 / 20 exact (90.0%)    |
| run 2026-11-09-30-micro-chnarrow, v423/Xr                           | probes/chnarrow.c    | 19 / 20 exact (95.0%)    |
| run 2026-11-09-30-micro-chnarrow, v423/O3XSXr                       | probes/chnarrow.c    | 18 / 20 exact (90.0%)    |
| run 2026-11-09-31-micro-lnr, v423/none                              | probes/lnr.c         | 28 / 50 exact (56.0%)    |
| run 2026-11-09-31-micro-lnr, v423/O3XS                              | probes/lnr.c         | 3 / 50 exact (6.0%)      |
| run 2026-11-09-31-micro-lnr, v423/Xr                                | probes/lnr.c         | 9 / 50 exact (18.0%)     |
| run 2026-11-09-31-micro-lnr, v423/O3XSXr                            | probes/lnr.c         | 7 / 50 exact (14.0%)     |
| run 2026-11-09-32-micro-lnr2, v423/none                             | probes/lnr2.c        | 22 / 43 exact (51.2%)    |
| run 2026-11-09-32-micro-lnr2, v423/O3XS                             | probes/lnr2.c        | 0 / 43 exact (0.0%)      |
| run 2026-11-09-32-micro-lnr2, v423/Xr                               | probes/lnr2.c        | 3 / 43 exact (7.0%)      |
| run 2026-11-09-32-micro-lnr2, v423/O3XSXr                           | probes/lnr2.c        | 5 / 43 exact (11.6%)     |
| run 2026-11-09-33-micro-lnr3, v423/none                             | probes/lnr3.c        | 12 / 25 exact (48.0%)    |
| run 2026-11-09-33-micro-lnr3, v423/O3XS                             | probes/lnr3.c        | 1 / 25 exact (4.0%)      |
| run 2026-11-09-33-micro-lnr3, v423/Xr                               | probes/lnr3.c        | 4 / 25 exact (16.0%)     |
| run 2026-11-09-33-micro-lnr3, v423/O3XSXr                           | probes/lnr3.c        | 4 / 25 exact (16.0%)     |
| run 2026-11-09-34-micro-lnr4, v423/none                             | probes/lnr4.c        | 6 / 18 exact (33.3%)     |
| run 2026-11-09-34-micro-lnr4, v423/O3XS                             | probes/lnr4.c        | 0 / 18 exact (0.0%)      |
| run 2026-11-09-34-micro-lnr4, v423/Xr                               | probes/lnr4.c        | 2 / 18 exact (11.1%)     |
| run 2026-11-09-34-micro-lnr4, v423/O3XSXr                           | probes/lnr4.c        | 1 / 18 exact (5.6%)      |
| run 2026-11-09-35-micro-regkw, v423/none                            | probes/regkw.c       | 0 / 12 exact (0.0%)      |
| run 2026-11-09-35-micro-regkw, v423/O3XS                            | probes/regkw.c       | 10 / 12 exact (83.3%)    |
| run 2026-11-09-35-micro-regkw, v423/Xr                              | probes/regkw.c       | 3 / 12 exact (25.0%)     |
| run 2026-11-09-35-micro-regkw, v423/O3XSXr                          | probes/regkw.c       | 0 / 12 exact (0.0%)      |
| run 2026-11-10-4-micro-chidx, v423/none                             | probes/chidx.c       | 50 / 50 exact (100.0%)   |
| run 2026-11-10-4-micro-chidx, v423/O3XS                             | probes/chidx.c       | 50 / 50 exact (100.0%)   |
| run 2026-11-10-4-micro-chidx, v423/Xr                               | probes/chidx.c       | 50 / 50 exact (100.0%)   |
| run 2026-11-10-4-micro-chidx, v423/O3XSXr                           | probes/chidx.c       | 50 / 50 exact (100.0%)   |
| run 2026-11-09-37-micro-homes2a, v423/none                          | probes/homes2a.c     | 22 / 204 exact (10.8%)   |
| run 2026-11-09-37-micro-homes2a, v423/O3XS                          | probes/homes2a.c     | 9 / 204 exact (4.4%)     |
| run 2026-11-09-37-micro-homes2a, v423/Xr                            | probes/homes2a.c     | 36 / 204 exact (17.6%)   |
| run 2026-11-09-37-micro-homes2a, v423/O3XSXr                        | probes/homes2a.c     | 32 / 204 exact (15.7%)   |
| run 2026-11-09-42-micro-homes2b, v423/none                          | probes/homes2b.c     | 12 / 90 exact (13.3%)    |
| run 2026-11-09-42-micro-homes2b, v423/O3XS                          | probes/homes2b.c     | 9 / 90 exact (10.0%)     |
| run 2026-11-09-42-micro-homes2b, v423/Xr                            | probes/homes2b.c     | 19 / 90 exact (21.1%)    |
| run 2026-11-09-42-micro-homes2b, v423/O3XSXr                        | probes/homes2b.c     | 16 / 90 exact (17.8%)    |
| run 2026-11-10-1-micro-random1, v423/none                           | random/*.c           | 28 / 200 exact (14.0%)   |
| run 2026-11-10-1-micro-random1, v423/O3XS                           | random/*.c           | 8 / 200 exact (4.0%)     |
| run 2026-11-10-1-micro-random1, v423/Xr                             | random/*.c           | 15 / 200 exact (7.5%)    |
| run 2026-11-10-1-micro-random1, v423/O3XSXr                         | random/*.c           | 7 / 200 exact (3.5%)     |
| run 2026-11-10-5-micro-random2, v423/none                           | random2/*.c          | 11 / 200 exact (5.5%)    |
| run 2026-11-10-5-micro-random2, v423/O3XS                           | random2/*.c          | 4 / 200 exact (2.0%)     |
| run 2026-11-10-5-micro-random2, v423/Xr                             | random2/*.c          | 8 / 200 exact (4.0%)     |
| run 2026-11-10-5-micro-random2, v423/O3XSXr                         | random2/*.c          | 3 / 200 exact (1.5%)     |
| run 2026-11-10-6-micro-random3, v423/none                           | random3/*.c          | 16 / 200 exact (8.0%)    |
| run 2026-11-10-6-micro-random3, v423/O3XS                           | random3/*.c          | 5 / 200 exact (2.5%)     |
| run 2026-11-10-6-micro-random3, v423/Xr                             | random3/*.c          | 11 / 200 exact (5.5%)    |
| run 2026-11-10-6-micro-random3, v423/O3XSXr                         | random3/*.c          | 5 / 200 exact (2.5%)     |
| run 2026-11-10-7-micro-random4, v423/none                            | random4/*.c          | 18 / 200 exact (9.0%)    |
| run 2026-11-10-7-micro-random4, v423/O3XS                            | random4/*.c          | 5 / 200 exact (2.5%)     |
| run 2026-11-10-7-micro-random4, v423/Xr                              | random4/*.c          | 13 / 200 exact (6.5%)    |
| run 2026-11-10-7-micro-random4, v423/O3XSXr                          | random4/*.c          | 6 / 200 exact (3.0%)     |
| run 2026-11-10-9-micro-evorder, v423/none                            | probes/evorder.c     | 442 / 507 exact (87.2%)  |
| run 2026-11-10-9-micro-evorder, v423/O3XS                            | probes/evorder.c     | 394 / 507 exact (77.7%)  |
| run 2026-11-10-9-micro-evorder, v423/Xr                              | probes/evorder.c     | 356 / 507 exact (70.2%)  |
| run 2026-11-10-9-micro-evorder, v423/O3XSXr                          | probes/evorder.c     | 315 / 507 exact (62.1%)  |
| run 2026-11-10-10-micro-evorder2, v423/none                          | probes/evorder_st.c  | 548 / 676 exact (81.1%)  |
| run 2026-11-10-10-micro-evorder2, v423/O3XS                          | probes/evorder_st.c  | 465 / 676 exact (68.8%)  |
| run 2026-11-10-10-micro-evorder2, v423/Xr                            | probes/evorder_st.c  | 420 / 676 exact (62.1%)  |
| run 2026-11-10-10-micro-evorder2, v423/O3XSXr                        | probes/evorder_st.c  | 458 / 676 exact (67.8%)  |
| run 2026-11-10-10-micro-evorder2, v423/none                          | probes/evorder_l.c   | 259 / 338 exact (76.6%)  |
| run 2026-11-10-10-micro-evorder2, v423/O3XS                          | probes/evorder_l.c   | 191 / 338 exact (56.5%)  |
| run 2026-11-10-10-micro-evorder2, v423/Xr                            | probes/evorder_l.c   | 206 / 338 exact (60.9%)  |
| run 2026-11-10-10-micro-evorder2, v423/O3XSXr                        | probes/evorder_l.c   | 148 / 338 exact (43.8%)  |
| run 2026-11-10-11-micro-evorder3, v423/none                          | probes/evorder_d.c   | 252 / 338 exact (74.6%)  |
| run 2026-11-10-11-micro-evorder3, v423/O3XS                          | probes/evorder_d.c   | 202 / 338 exact (59.8%)  |
| run 2026-11-10-11-micro-evorder3, v423/Xr                            | probes/evorder_d.c   | 214 / 338 exact (63.3%)  |
| run 2026-11-10-11-micro-evorder3, v423/O3XSXr                        | probes/evorder_d.c   | 180 / 338 exact (53.3%)  |
| run 2026-11-10-12-micro-cmpord, v423/none                           | probes/cmpord.c      | 433 / 507 exact (85.4%)  |
| run 2026-11-10-12-micro-cmpord, v423/O3XS                           | probes/cmpord.c      | 382 / 507 exact (75.3%)  |
| run 2026-11-10-12-micro-cmpord, v423/Xr                             | probes/cmpord.c      | 405 / 507 exact (79.9%)  |
| run 2026-11-10-12-micro-cmpord, v423/O3XSXr                         | probes/cmpord.c      | 353 / 507 exact (69.6%)  |
| run 2026-11-10-13-micro-evorder4, v423/none                         | probes/evorder_lh.c  | 286 / 507 exact (56.4%)  |
| run 2026-11-10-13-micro-evorder4, v423/O3XS                         | probes/evorder_lh.c  | 176 / 507 exact (34.7%)  |
| run 2026-11-10-13-micro-evorder4, v423/Xr                           | probes/evorder_lh.c  | 239 / 507 exact (47.1%)  |
| run 2026-11-10-13-micro-evorder4, v423/O3XSXr                       | probes/evorder_lh.c  | 159 / 507 exact (31.4%)  |
| run 2026-11-10-14-micro-loc0, v423/none                             | probes/loc0.c        | 510 / 512 exact (99.6%)  |
| run 2026-11-10-14-micro-loc0, v423/O3XS                             | probes/loc0.c        | 436 / 512 exact (85.2%)  |
| run 2026-11-10-14-micro-loc0, v423/Xr                               | probes/loc0.c        | 510 / 512 exact (99.6%)  |
| run 2026-11-10-14-micro-loc0, v423/O3XSXr                           | probes/loc0.c        | 380 / 512 exact (74.2%)  |
| run 2026-11-10-15-micro-stord, v423/none                            | probes/stord.c       | 354 / 432 exact (81.9%)  |
| run 2026-11-10-15-micro-stord, v423/O3XS                            | probes/stord.c       | 322 / 432 exact (74.5%)  |
| run 2026-11-10-15-micro-stord, v423/Xr                              | probes/stord.c       | 296 / 432 exact (68.5%)  |
| run 2026-11-10-15-micro-stord, v423/O3XSXr                          | probes/stord.c       | 282 / 432 exact (65.3%)  |
| run 2026-11-10-16-micro-cmpordl, v423/none                          | probes/cmpordl.c     | 674 / 680 exact (99.1%)  |
| run 2026-11-10-16-micro-cmpordl, v423/O3XS                          | probes/cmpordl.c     | 668 / 680 exact (98.2%)  |
| run 2026-11-10-16-micro-cmpordl, v423/Xr                            | probes/cmpordl.c     | 594 / 680 exact (87.4%)  |
| run 2026-11-10-16-micro-cmpordl, v423/O3XSXr                        | probes/cmpordl.c     | 588 / 680 exact (86.5%)  |
| run 2026-11-10-17-micro-evorder_ad, v423/none                       | probes/evorder_ad.c  | 1080 / 1116 exact (96.8%) |
| run 2026-11-10-17-micro-evorder_ad, v423/O3XS                       | probes/evorder_ad.c  | 1030 / 1116 exact (92.3%) |
| run 2026-11-10-17-micro-evorder_ad, v423/Xr                         | probes/evorder_ad.c  | 931 / 1116 exact (83.4%) |
| run 2026-11-10-17-micro-evorder_ad, v423/O3XSXr                     | probes/evorder_ad.c  | 873 / 1116 exact (78.2%) |
| run 2026-11-10-18-micro-cmpordl2, v423/none                         | probes/cmpordl2.c    | 396 / 572 exact (69.2%)  |
| run 2026-11-10-18-micro-cmpordl2, v423/O3XS                         | probes/cmpordl2.c    | 390 / 572 exact (68.2%)  |
| run 2026-11-10-18-micro-cmpordl2, v423/Xr                           | probes/cmpordl2.c    | 320 / 572 exact (55.9%)  |
| run 2026-11-10-18-micro-cmpordl2, v423/O3XSXr                       | probes/cmpordl2.c    | 349 / 572 exact (61.0%)  |
| run 2026-11-12-1-micro-stchain, v423/none                           | probes/stchain.c     | 321 / 392 exact (81.9%)  |
| run 2026-11-12-1-micro-stchain, v423/O3XS                           | probes/stchain.c     | 322 / 392 exact (82.1%)  |
| run 2026-11-12-1-micro-stchain, v423/Xr                             | probes/stchain.c     | 202 / 392 exact (51.5%)  |
| run 2026-11-12-1-micro-stchain, v423/O3XSXr                         | probes/stchain.c     | 200 / 392 exact (51.0%)  |
| run 2026-11-12-2-micro-stret, v423/none                             | probes/stret.c       | 264 / 280 exact (94.3%)  |
| run 2026-11-12-2-micro-stret, v423/O3XS                             | probes/stret.c       | 264 / 280 exact (94.3%)  |
| run 2026-11-12-2-micro-stret, v423/Xr                               | probes/stret.c       | 163 / 280 exact (58.2%)  |
| run 2026-11-12-2-micro-stret, v423/O3XSXr                           | probes/stret.c       | 163 / 280 exact (58.2%)  |
| run 2026-11-12-3-micro-idxloc, v423/none                            | probes/idxloc.c      | 82 / 108 exact (75.9%)   |
| run 2026-11-12-3-micro-idxloc, v423/O3XS                            | probes/idxloc.c      | 31 / 108 exact (28.7%)   |
| run 2026-11-12-3-micro-idxloc, v423/Xr                              | probes/idxloc.c      | 59 / 108 exact (54.6%)   |
| run 2026-11-12-3-micro-idxloc, v423/O3XSXr                          | probes/idxloc.c      | 36 / 108 exact (33.3%)   |
| run 2026-11-12-4-micro-stval, v423/none                             | probes/stval.c       | 208 / 221 exact (94.1%)  |
| run 2026-11-12-4-micro-stval, v423/O3XS                             | probes/stval.c       | 206 / 221 exact (93.2%)  |
| run 2026-11-12-4-micro-stval, v423/Xr                               | probes/stval.c       | 126 / 221 exact (57.0%)  |
| run 2026-11-12-4-micro-stval, v423/O3XSXr                           | probes/stval.c       | 126 / 221 exact (57.0%)  |
| run 2026-11-12-5-micro-stdiv, v423/none                             | probes/stdiv.c       | 750 / 750 exact (100.0%) |
| run 2026-11-12-5-micro-stdiv, v423/O3XS                             | probes/stdiv.c       | 694 / 750 exact (92.5%)  |
| run 2026-11-12-5-micro-stdiv, v423/Xr                               | probes/stdiv.c       | 162 / 750 exact (21.6%)  |
| run 2026-11-12-5-micro-stdiv, v423/O3XSXr                           | probes/stdiv.c       | 142 / 750 exact (18.9%)  |
| run 2026-11-12-6-micro-lhidx, v423/none                             | probes/lhidx.c       | 78 / 150 exact (52.0%)   |
| run 2026-11-12-6-micro-lhidx, v423/O3XS                             | probes/lhidx.c       | 68 / 150 exact (45.3%)   |
| run 2026-11-12-6-micro-lhidx, v423/Xr                               | probes/lhidx.c       | 0 / 150 exact (0.0%)     |
| run 2026-11-12-6-micro-lhidx, v423/O3XSXr                           | probes/lhidx.c       | 0 / 150 exact (0.0%)     |
| run 2026-11-12-7-micro-loopctr, v423/none                           | probes/loopctr.c     | 29 / 30 exact (96.7%)    |
| run 2026-11-12-7-micro-loopctr, v423/O3XS                           | probes/loopctr.c     | 2 / 30 exact (6.7%)      |
| run 2026-11-12-7-micro-loopctr, v423/Xr                             | probes/loopctr.c     | 14 / 30 exact (46.7%)    |
| run 2026-11-12-7-micro-loopctr, v423/O3XSXr                         | probes/loopctr.c     | 2 / 30 exact (6.7%)      |
| run 2026-11-12-8-micro-stvx, v423/none                              | probes/stvx.c        | 93 / 135 exact (68.9%)   |
| run 2026-11-12-8-micro-stvx, v423/O3XS                              | probes/stvx.c        | 93 / 135 exact (68.9%)   |
| run 2026-11-12-8-micro-stvx, v423/Xr                                | probes/stvx.c        | 41 / 135 exact (30.4%)   |
| run 2026-11-12-8-micro-stvx, v423/O3XSXr                            | probes/stvx.c        | 41 / 135 exact (30.4%)   |
| run 2026-11-12-9-micro-stvxc, v423/none                             | probes/stvxc.c       | 251 / 294 exact (85.4%)  |
| run 2026-11-12-9-micro-stvxc, v423/O3XS                             | probes/stvxc.c       | 250 / 294 exact (85.0%)  |
| run 2026-11-12-9-micro-stvxc, v423/Xr                               | probes/stvxc.c       | 82 / 294 exact (27.9%)   |
| run 2026-11-12-9-micro-stvxc, v423/O3XSXr                           | probes/stvxc.c       | 84 / 294 exact (28.6%)   |
| run 2026-11-12-10-micro-fpopa, v423/none                            | probes/fpopa.c       | 104 / 112 exact (92.9%)  |
| run 2026-11-12-10-micro-fpopa, v423/O3XS                            | probes/fpopa.c       | 82 / 112 exact (73.2%)   |
| run 2026-11-12-10-micro-fpopa, v423/Xr                              | probes/fpopa.c       | 104 / 112 exact (92.9%)  |
| run 2026-11-12-10-micro-fpopa, v423/O3XSXr                          | probes/fpopa.c       | 82 / 112 exact (73.2%)   |
| run 2026-11-12-11-micro-fpargf, v423/none                           | probes/fpargf.c      | 96 / 96 exact (100.0%)   |
| run 2026-11-12-11-micro-fpargf, v423/O3XS                           | probes/fpargf.c      | 48 / 96 exact (50.0%)    |
| run 2026-11-12-11-micro-fpargf, v423/Xr                             | probes/fpargf.c      | 24 / 96 exact (25.0%)    |
| run 2026-11-12-11-micro-fpargf, v423/O3XSXr                         | probes/fpargf.c      | 24 / 96 exact (25.0%)    |
| run 2026-11-12-12-micro-fpargg, v423/none                           | probes/fpargg.c      | 36 / 44 exact (81.8%)    |
| run 2026-11-12-12-micro-fpargg, v423/O3XS                           | probes/fpargg.c      | 32 / 44 exact (72.7%)    |
| run 2026-11-12-12-micro-fpargg, v423/Xr                             | probes/fpargg.c      | 36 / 44 exact (81.8%)    |
| run 2026-11-12-12-micro-fpargg, v423/O3XSXr                         | probes/fpargg.c      | 32 / 44 exact (72.7%)    |
| run 2026-11-09-9-micro-fp, v423/none                                | micro/fp.c           | 108 / 108 exact (100.0%) |
| run 2026-11-09-9-micro-fp, v423/O3XS                                | micro/fp.c           | 108 / 108 exact (100.0%) |
| run 2026-11-09-10-micro-fptemps, v423/none                          | micro/fp_temps.c     | 33 / 33 exact (100.0%)   |
| run 2026-11-09-10-micro-fptemps, v423/O3XS                          | micro/fp_temps.c     | 33 / 33 exact (100.0%)   |
| run 2026-11-09-11-micro-opttemps, v423/Xr                           | micro/opt_temps.c    | 35 / 38 exact (92.1%)    |
| run 2026-11-09-11-micro-opttemps, v423/O3XSXr                       | micro/opt_temps.c    | 38 / 38 exact (100.0%)   |
| run 2026-11-09-12-micro-optcounted, v423/none                       | micro/opt_counted.c  | 28 / 32 exact (87.5%)    |
| run 2026-11-09-12-micro-optcounted, v423/O3XS                       | micro/opt_counted.c  | 29 / 32 exact (90.6%)    |
| run 2026-11-09-12-micro-optcounted, v423/Xr                         | micro/opt_counted.c  | 31 / 32 exact (96.9%)    |
| run 2026-11-09-12-micro-optcounted, v423/O3XSXr                     | micro/opt_counted.c  | 32 / 32 exact (100.0%)   |
| run 2026-11-09-13-micro-fpstmts, v423/none                          | micro/fp_stmts.c     | 15 / 16 exact (93.8%)    |
| run 2026-11-09-13-micro-fpstmts, v423/O3XS                          | micro/fp_stmts.c     | 13 / 16 exact (81.2%)    |
| run 2026-11-08-9-micro-optloops, v423/O3XS                          | micro/opt_loops.c    | 28 / 33 exact (84.8%)    |
| run 2026-11-08-5-libsrc97-O3XS, v423/O3XS, --personality v4.23      | 1997 LIB/SRC         | 186 / 248 exact (75.0%)  |
| run 2026-11-08-5-libsrc97-O3XS, v423/O3XS, --personality kn5000     | 1997 LIB/SRC         | 184 / 248 exact (74.2%)  |
| run 2026-11-08-5-libsrc97-O3XS, ide2003/O3XS, --personality ide2003 | 1997 LIB/SRC         | 174 / 248 exact (70.2%)  |
| run 2026-11-09-3-proxy-tiny, v423/O3XSXr                            | firmware/tiny.c      | 6 / 6 exact (100.0%)     |
| run 2026-11-08-8-micro-ra, v423/O3XS                                | micro/ra_*.c         | 20 / 42 exact (47.6%)    |
| run 2026-11-08-8-micro-ra, v423/Xr                                  | micro/ra_*.c         | 23 / 42 exact (54.8%)    |
| run 2026-11-08-9-micro-optloops, v423/none                          | micro/opt_loops.c    | 28 / 33 exact (84.8%)    |
| run 2026-11-08-9-micro-optloops, v423/Xr                            | micro/opt_loops.c    | 30 / 33 exact (90.9%)    |
| run 2026-11-08-9-micro-optloops, v423/O3XSXr                        | micro/opt_loops.c    | 30 / 33 exact (90.9%)    |

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
