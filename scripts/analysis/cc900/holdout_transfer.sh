#!/bin/sh
# holdout_transfer.sh OUTDIR HOLD_R_DIR_TEMPLATE HOLD_S_DIR_TEMPLATE 'RANDOM5_GLOB' RSTMT5_C COMMIT...
# For each commit: extract that tree's model (git archive, read-only on the repo) into OUTDIR/m-COMMIT and print
# holdout_agg.py's aggregates at all four sets.  Templates contain SET, e.g. .../out/v423/SET/holdout5.
# Run from scripts/analysis/cc900.  Aggregates only.  Scratch (caches, pyc): $CC900_SCRATCH, default
# ~/compartilhado/tmp/cc900-tab/strategist.  P9 of research-scratch sessions/2026-11-10_cc900-refusals/strategy/.
set -e
OUT=${1:?}; HR=${2:?}; HS=${3:?}; RG=${4:?}; RS=${5:?}; shift 5
D=${CC900_SCRATCH:-$HOME/compartilhado/tmp/cc900-tab/strategist}
H=$(cd "$(dirname "$0")" && pwd)/holdout_agg.py
mkdir -p "$OUT"
export CC900_CACHE="$D/cache"
for c in "$@"; do
  M="$OUT/m-$c"; mkdir -p "$M"
  git -C "$(git rev-parse --show-toplevel)" archive "$c" scripts/analysis/cc900/model | tar -x -C "$M" --strip-components=4
  for s in none O3XS Xr O3XSXr; do
    hr=$(echo "$HR" | sed "s/SET/$s/"); hs=$(echo "$HS" | sed "s/SET/$s/")
    echo "== $c $s"; python3 -I -X pycache_prefix="$D/pyc" "$H" "$M" $s "$hr" "$hs" $RG -- "$RS" 2>&1 | tail -4
  done
done
