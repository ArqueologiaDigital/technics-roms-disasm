#!/bin/bash
# corpus_r96.sh OUT: the oracle corpus of round 96 (2026-11-21): the staged run of round 95's FILE_Naming_Screen
# (all four trees) and LyricJumpEditCheck_Unregistered (v2.06i).  Run from the repository root; then
# run_oracle.sh with OUT/sources.txt and OUT/options.txt.
set -eu
O=${1:?OUT}
S=notes/cc900-c-hdae5000-2026-11-16
H="python3 -B $S/hd_v423.py --corpus $O Xr"
$H hdae5000/cc900-staged/hdae5000_jnext_r95.c
$H --tree hdae5000_v2_01i hdae5000_v2_01i/cc900-staged/hdae5000_jnext_r95.c
$H --tree hdae5000_v1_15i hdae5000_v1_15i/cc900-staged/hdae5000_jnext_r95.c
$H --tree hdae5000_v1_10i hdae5000_v1_10i/cc900-staged/hdae5000_jnext_r95.c
