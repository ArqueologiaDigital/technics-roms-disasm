#!/bin/bash
# corpus_r91.sh OUT: the oracle corpus of round 91 (2026-11-20): the staged run of FormatDialog_CodeDigit (round 90's
# form w) in all four trees (v1.x with its digit buffer at 0x22ad54), and DbMemoClProc's probe hd_r91_pp.c.  Run from the repository root; then
# run_oracle.sh with OUT/sources.txt and OUT/options.txt.
set -eu
O=${1:?OUT}
S=notes/cc900-c-hdae5000-2026-11-16
H="python3 -B $S/hd_v423.py --corpus $O Xr"
$H hdae5000/cc900-staged/hdae5000_codedigit_r90.c $S/probes/hd_r91_pp.c
$H --tree hdae5000_v2_01i hdae5000_v2_01i/cc900-staged/hdae5000_codedigit_r90.c
$H --tree hdae5000_v1_15i hdae5000_v1_15i/cc900-staged/hdae5000_codedigit_v1_r90.c
$H --tree hdae5000_v1_10i hdae5000_v1_10i/cc900-staged/hdae5000_codedigit_v1_r90.c
