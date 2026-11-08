# Model ledger: 2026-11-08, model at the commit that adds this file version

| oracle                    | corpus          | options | exact                    |
|---------------------------|-----------------|---------|--------------------------|
| run 7-micro, v423/none    | micro/binop_*.c | cdecl   | 300 / 300 exact (100.0%) |
| run 7-micro, v423/none    | micro/unop_*.c  | cdecl   | 78 / 78 exact (100.0%)   |
| run 7-micro, v423/none    | micro/cmp_*.c   | cdecl   | 180 / 180 exact (100.0%) |
| run 7-micro, v423/none    | micro/assign.c  | cdecl   | 60 / 60 exact (100.0%)   |
| run 7-micro, v423/none    | micro/mem.c     | cdecl   | 18 / 21 exact (85.7%)    |
| run 7-micro, v423/none    | micro/call.c    | cdecl   | 8 / 14 exact (57.1%)     |
| run 7-micro, v423/none    | micro/ctrl.c    | cdecl   | 6 / 21 exact (28.6%)     |
| run 7-micro, v423/none    | micro/*.c       | cdecl   | 650 / 674 exact (96.4%)  |
| run 8-micro-ra, v423/none | micro/ra_leaf.c | cdecl   | 21 / 23 exact (91.3%)    |
| run 8-micro-ra, v423/none | micro/ra_call.c | cdecl   | 2 / 19 exact (10.5%)     |
| run 7-micro, ide2003/none | micro/*.c       | cdecl   | 647 / 674 exact (96.0%)  |
| run 7-micro, v110/none    | micro/*.c       | cdecl   | 646 / 674 exact (95.8%)  |
| run 7-micro, v423/O3XS    | micro/*.c       | cdecl   | 556 / 674 exact (82.5%)  |
| run 7-micro, v423/Xr      | micro/*.c       | --adecl | 518 / 674 exact (76.9%)  |
| run 7-micro, v423/O3XSXr  | micro/*.c       | --adecl | 437 / 674 exact (64.8%)  |
