#!/bin/sh
# val_sem.sh [MODEL_DIR] [--contract] -- wrong-code count on the validation corpus: semcheck DIFFERENT functions per
# option set, counts only (no names are printed), for random6-8 and rstmt6-8 against oracle run
# 2026-11-15-3-micro-validation678.  With --contract it prints the default mode's counts and the contract mode's
# (semcheck.md, "Contract mode": in-range indexes, fall-off functions apart), two option sets at a time.
# Question it answers: how often does the model compute something other than cc900 on code nobody tuned it for?
# The plan's "no wrong code" criterion; the committed corpora's semcheck count (results/semcheck.md) only covers shapes
# already checked.  Run from scripts/analysis/cc900; ~10 min.
M=model; K=
for x in "$@"; do case $x in --contract) K=1;; *) M=$x;; esac; done
V=$HOME/compartilhado/cc900-oracle/runs/2026-11-15-3-micro-validation678/out/v423
count() {   # count SET MODE-FLAG: DIFFERENT (and with --contract, fall-off) functions, counts only
  s=$1; case $s in none) a="--opt none";; O3XS) a="--opt O3XS";; Xr) a="--opt none --adecl";; O3XSXr) a="--opt O3XS --adecl";; esac
  d=0; c=0; fd=0; fc=0
  for k in 6 7 8; do
    o=$(python3 -I -B model/semcheck.py $V/$s/validation/random$k corpus/validation/random$k/*.c $a $2 --model-dir "$M" 2>&1)
    d=$((d + $(printf '%s\n' "$o" | grep -c 'DIFFERENT [._]')))
    fd=$((fd + $(printf '%s\n' "$o" | sed -n 's/.*fall-off *\([0-9]*\).*/\1/p' | awk '{t += $1} END {print t + 0}')))
    o=$(python3 -I -B model/semcheck.py $V/$s/validation corpus/validation/rstmt$k.c $a $2 --model-dir "$M" 2>&1)
    c=$((c + $(printf '%s\n' "$o" | grep -c 'DIFFERENT [._]')))
    fc=$((fc + $(printf '%s\n' "$o" | sed -n 's/.*fall-off *\([0-9]*\).*/\1/p' | awk '{t += $1} END {print t + 0}')))
  done
  if [ -n "$2" ]; then echo "$s contract: random6-8 DIFFERENT $d (fall-off $fd), rstmt6-8 DIFFERENT $c (fall-off $fc)"
  else echo "$s: random6-8 DIFFERENT $d, rstmt6-8 DIFFERENT $c"; fi
}
for pair in "none O3XS" "Xr O3XSXr"; do
  for s in $pair; do ( count $s; [ -n "$K" ] && count $s --contract ) & done
  wait
done
