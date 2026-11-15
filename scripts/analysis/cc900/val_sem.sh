#!/bin/sh
# val_sem.sh [MODEL_DIR] -- wrong-code count on the validation corpus: semcheck DIFFERENT functions per option set,
# counts only (no names are printed), for random6-8 and rstmt6-8 against oracle run 2026-11-15-3-micro-validation678.
# Question it answers: how often does the model compute something other than cc900 on code nobody tuned it for?
# The plan's "no wrong code" criterion; the committed corpora's semcheck count (results/semcheck.md) only covers shapes
# already checked.  Run from scripts/analysis/cc900; ~10 min.
M=${1:-model}
V=$HOME/compartilhado/cc900-oracle/runs/2026-11-15-3-micro-validation678/out/v423
for s in none O3XS Xr O3XSXr; do
  case $s in none) a="--opt none";; O3XS) a="--opt O3XS";; Xr) a="--opt none --adecl";; O3XSXr) a="--opt O3XS --adecl";; esac
  ( d=0; c=0; n=0; m=0
    for k in 6 7 8; do
      o=$(python3 -I -B model/semcheck.py $V/$s/validation/random$k corpus/validation/random$k/*.c $a --model-dir "$M" 2>&1)
      d=$((d + $(printf '%s\n' "$o" | grep -c 'DIFFERENT [._]')))
      o=$(python3 -I -B model/semcheck.py $V/$s/validation corpus/validation/rstmt$k.c $a --model-dir "$M" 2>&1)
      c=$((c + $(printf '%s\n' "$o" | grep -c 'DIFFERENT [._]')))
    done
    echo "$s: random6-8 DIFFERENT $d, rstmt6-8 DIFFERENT $c" ) &
done
wait
