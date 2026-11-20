#!/bin/bash
# corpus_r89.sh OUT: the oracle corpus of round 89 (2026-11-20): v1.10i's staged Frame_Handler (its staged run) and
# the Svc13 probes for v1.15i / v1.10i written out in full.  Run from the repository root; then run_oracle.sh with
# OUT/sources.txt and OUT/options.txt.
set -eu
O=${1:?OUT}
S=notes/cc900-c-hdae5000-2026-11-16
H="python3 -B $S/hd_v423.py --corpus $O Xr"
$H --tree hdae5000_v1_15i $S/probes/hd_r89_pport_svc13__svc13_v115.c
$H --tree hdae5000_v1_10i hdae5000_v1_10i/cc900-staged/hdae5000_boot__framehandler_v110_r88.c \
    $S/probes/hd_r89_pport_svc13__svc13_v110.c
