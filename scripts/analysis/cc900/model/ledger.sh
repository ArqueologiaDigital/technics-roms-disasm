#!/bin/sh
# Regenerates the score rows of ../results/model_ledger.md: one score.py run per oracle directory.
# usage: sh model/ledger.sh   (from scripts/analysis/cc900; needs the private oracle runs and the library scratch copy)
# ORACLE (default ~/compartilhado/cc900-oracle/runs) and LIBCOPY (default ~/compartilhado/tmp/cc900-corpus-libsrc97,
# made as model_ledger.md describes) may be overridden.  Prints "oracle | corpus | TOTAL line" rows.
O=${ORACLE:-$HOME/compartilhado/cc900-oracle/runs}
C=${LIBCOPY:-$HOME/compartilhado/tmp/cc900-corpus-libsrc97}
row() { printf '%s | %s | ' "$1" "$2"; shift 2; python3 -I -B model/score.py "$@" 2>&1 | tail -1; }
for c in v423/none ide2003/none v110/none v423/O3XS v423/Xr v423/O3XSXr; do
  row "run 2026-11-08-7-micro, $c" "micro/*.c" "$O/2026-11-08-7-micro/out/$c" corpus/micro/*.c
done
for c in none O3XSXr; do
  row "run 2026-11-08-8-micro-ra, v423/$c" "micro/ra_*.c" "$O/2026-11-08-8-micro-ra/out/v423/$c" corpus/micro/ra_*.c
done
for c in Xr O3XSXr; do
  row "run 2026-11-08-6-abi-adecl, v423/$c" "abi/*.c" "$O/2026-11-08-6-abi-adecl/out/v423/$c" corpus/abi/*.c
done
for c in none Xr O3XS O3XSXr; do
  row "run 2026-11-09-4-micro-switch, v423/$c" "micro/switch.c" "$O/2026-11-09-4-micro-switch/out/v423/$c" corpus/micro/switch.c
done
row "run 2026-11-08-9-micro-optloops, v423/O3XS" "micro/opt_loops.c" "$O/2026-11-08-9-micro-optloops/out/v423/O3XS" corpus/micro/opt_loops.c
for p in v4.23 kn5000; do
  row "run 2026-11-08-5-libsrc97-O3XS, v423/O3XS, --personality $p" "1997 LIB/SRC" \
    "$O/2026-11-08-5-libsrc97-O3XS/out/v423/O3XS" "$C"/libsrc/*.C -D__900__ -D__LARGE__ -DFLOAT -D__CDECL= '-D__ASM(x)=' -I"$C"/inc --personality $p
done
row "run 2026-11-09-3-proxy-tiny, v423/O3XSXr" "firmware/tiny.c" "$O/2026-11-09-3-proxy-tiny/out/v423/O3XSXr" corpus/firmware/tiny.c
