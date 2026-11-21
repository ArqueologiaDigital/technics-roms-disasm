#!/bin/bash
# corpus_r90.sh OUT: the oracle corpus of round 90 (2026-11-20): the staged run of round 89's Svc13 (v1.15i, v1.10i)
# and round 90's CodeDigit probe (v2.06i).  Run from the repository root; then run_oracle.sh with OUT/sources.txt and
# OUT/options.txt.
set -eu
O=${1:?OUT}
S=notes/cc900-c-hdae5000-2026-11-16
H="python3 -B $S/hd_v423.py --corpus $O Xr"
$H $S/probes/hd_r90_cd.c
$H --tree hdae5000_v1_15i hdae5000_v1_15i/cc900-staged/hdae5000_pport_svc13__v115_r89.c
$H --tree hdae5000_v1_10i hdae5000_v1_10i/cc900-staged/hdae5000_pport_svc13__v110_r89.c
