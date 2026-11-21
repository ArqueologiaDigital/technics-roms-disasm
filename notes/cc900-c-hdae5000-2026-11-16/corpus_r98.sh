#!/bin/bash
# corpus_r98.sh OUT: the oracle corpus of round 98 (2026-11-21): the staged run of round 97's FlsItem_Insert
# (form x of probes/hd_r97_fi.c) in all four trees.  Run from the repository root; then run_oracle.sh with
# OUT/sources.txt and OUT/options.txt.
set -eu
O=${1:?OUT}
S=notes/cc900-c-hdae5000-2026-11-16
H="python3 -B $S/hd_v423.py --corpus $O Xr"
$H hdae5000/cc900-staged/hdae5000_flsitem_insert_r97.c
$H --tree hdae5000_v2_01i hdae5000_v2_01i/cc900-staged/hdae5000_flsitem_insert_r97.c
$H --tree hdae5000_v1_15i hdae5000_v1_15i/cc900-staged/hdae5000_flsitem_insert_r97.c
$H --tree hdae5000_v1_10i hdae5000_v1_10i/cc900-staged/hdae5000_flsitem_insert_r97.c
