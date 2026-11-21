#!/bin/bash
# corpus_r97.sh OUT: the oracle corpus of round 97 (written 2026-11-21 while the VM was blocked; UNRUN):
#   probes/hd_r97_pp.c  DbMemoClProc: the XHL-to-XWA copy as a second, short-lived register local w (forms t, w)
#   probes/hd_r97_fi.c  FlsItem_Insert: the copy destination as a block-local of each copy (forms x, y, z)
# Run from the repository root; then run_oracle.sh hd-r97 OUT OUT/sources.txt OUT/options.txt v423, and
# hd_v423.py --check RUN --dir hd.
set -eu
O=${1:?OUT}
S=notes/cc900-c-hdae5000-2026-11-16
python3 -B $S/hd_v423.py --corpus $O Xr $S/probes/hd_r97_pp.c $S/probes/hd_r97_fi.c
