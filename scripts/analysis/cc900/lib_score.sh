#!/bin/sh
# lib_score.sh MODEL_DIR [SET...] -- the 1997 library's exact count (cc900 v4.23) at each option set: "SET: TOTAL n / m".
# Question it answers: the plan's library criterion (100 % at every option set).  Oracle runs:
#   O3XS               ~/compartilhado/cc900-oracle/runs/2026-11-08-5-libsrc97-O3XS
#   none, Xr, O3XSXr   ~/compartilhado/cc900-oracle/runs/2026-11-15-2-libsrc97-othersets
# Sources: ~/compartilhado/tmp/cc900-corpus-libsrc97 (libsrc/*.C, inc/).  At -Xr the headers must see __CDECL as
# __cdecl (cc900 is not __STDC__, so the headers' own #ifndef __CDECL gives __cdecl; clang defines __STDC__, so it is
# passed explicitly); without -Xr cdecl is the default and __CDECL is empty.  Under -Xr cc900 itself refuses 21 of the
# 123 sources (error 375 / 262: adecl / cdecl mismatches in the 1997 sources), so -Xr counts cover the 102 it compiles.
# Run from scripts/analysis/cc900.
M=${1:?model dir}; shift
[ $# -gt 0 ] || set -- none O3XS Xr O3XSXr
L=$HOME/compartilhado/tmp/cc900-corpus-libsrc97
R1=$HOME/compartilhado/cc900-oracle/runs/2026-11-08-5-libsrc97-O3XS/out/v423
R2=$HOME/compartilhado/cc900-oracle/runs/2026-11-15-2-libsrc97-othersets/out/v423
for s in "$@"; do
  case $s in
    none)   R=$R2; o="";                cd_=;;
    O3XS)   R=$R1; o="--opt O3XS";      cd_=;;
    Xr)     R=$R2; o="--adecl";         cd_=__cdecl;;
    O3XSXr) R=$R2; o="--opt O3XS --adecl"; cd_=__cdecl;;
    *) echo "unknown set $s"; exit 2;;
  esac
  echo "$s: $(python3 -I -B "$M/score.py" $R/$s/libsrc $L/libsrc/*.C $o -D__900__ -D__LARGE__ -DFLOAT -D__CDECL=$cd_ '-D__ASM(x)=' -I$L/inc 2>&1 | tail -1)" &
done
wait
