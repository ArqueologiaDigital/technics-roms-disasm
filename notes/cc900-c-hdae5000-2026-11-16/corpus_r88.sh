#!/bin/bash
# corpus_r88.sh OUT: the oracle corpus of round 88 (2026-11-20): round 87's staged per-tree files (their staged run)
# and round 88's probes (CodeDigit in v2.06i; Svc13 for v1.15i / v1.10i; v1.10i's Frame_Handler).  Run from the
# repository root; then run_oracle.sh with OUT/sources.txt and OUT/options.txt.
set -eu
O=${1:?OUT}
S=notes/cc900-c-hdae5000-2026-11-16
H="python3 -B $S/hd_v423.py --corpus $O Xr"
$H $S/probes/hd_r88_cd.c
$H --tree hdae5000_v2_01i hdae5000_v2_01i/cc900-staged/*_r87.c
$H --tree hdae5000_v1_15i hdae5000_v1_15i/cc900-staged/*_r87.c $S/probes/hd_r88_pport_svc13__svc13_v115.c
$H --tree hdae5000_v1_10i hdae5000_v1_10i/cc900-staged/*_r87.c $S/probes/hd_r88_pport_svc13__svc13_v110.c \
    $S/probes/hd_r88_boot__framehandler_v110.c
