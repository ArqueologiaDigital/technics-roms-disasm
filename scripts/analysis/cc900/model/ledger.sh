#!/bin/sh
# Regenerates the score rows of ../results/model_ledger.md: one score.py run per oracle directory.
# usage: sh model/ledger.sh   (from scripts/analysis/cc900; needs the private oracle runs and the library scratch copy)
# ORACLE (default ~/compartilhado/cc900-oracle/runs) and LIBCOPY (default ~/compartilhado/tmp/cc900-corpus-libsrc97,
# made as model_ledger.md describes) may be overridden.  The abi rows read Toshiba's headers from LIBCOPY/inc too
# (varargs.c's stdarg.h macros are what the oracle compiled; clang's builtin stdarg.h is not).  Prints "oracle | corpus | TOTAL line" rows.
O=${ORACLE:-$HOME/compartilhado/cc900-oracle/runs}
C=${LIBCOPY:-$HOME/compartilhado/tmp/cc900-corpus-libsrc97}
row() { printf '%s | %s | ' "$1" "$2"; shift 2; python3 -I -B model/score.py "$@" 2>&1 | tail -1; }
for c in v423/none ide2003/none v110/none v423/O3XS v423/Xr v423/O3XSXr; do
  row "run 2026-11-08-7-micro, $c" "micro/*.c" "$O/2026-11-08-7-micro/out/$c" corpus/micro/*.c
done
# the by-product personalities against their own compilers (phase 7, decision D6)
for c in O3XS Xr O3XSXr; do
  row "run 2026-11-08-7-micro, ide2003/$c, --personality ide2003" "micro/*.c" "$O/2026-11-08-7-micro/out/ide2003/$c" corpus/micro/*.c --personality ide2003
done
for c in none O3XSXr; do
  row "run 2026-11-08-8-micro-ra, v423/$c" "micro/ra_*.c" "$O/2026-11-08-8-micro-ra/out/v423/$c" corpus/micro/ra_*.c
done
for c in none O3XS; do
  row "run 2026-11-08-4-abi, v423/$c" "abi/*.c" "$O/2026-11-08-4-abi/out/v423/$c" corpus/abi/*.c -I"$C"/inc
done
for c in Xr O3XSXr; do
  row "run 2026-11-08-6-abi-adecl, v423/$c" "abi/*.c" "$O/2026-11-08-6-abi-adecl/out/v423/$c" corpus/abi/*.c -I"$C"/inc
done
for c in none Xr O3XS O3XSXr; do
  row "run 2026-11-09-4-micro-switch, v423/$c" "micro/switch.c" "$O/2026-11-09-4-micro-switch/out/v423/$c" corpus/micro/switch.c
done
for c in O3XS O3XSXr; do
  row "run 2026-11-09-5-micro-optparams, v423/$c" "micro/opt_params.c" "$O/2026-11-09-5-micro-optparams/out/v423/$c" corpus/micro/opt_params.c
done
for c in none O3XS Xr O3XSXr; do
  row "run 2026-11-09-6-micro-rahomes, v423/$c" "micro/ra_homes.c" "$O/2026-11-09-6-micro-rahomes/out/v423/$c" corpus/micro/ra_homes.c
done
for c in none O3XS Xr O3XSXr; do
  row "run 2026-11-09-7-micro-chains, v423/$c" "micro/ra_chains.c" "$O/2026-11-09-7-micro-chains/out/v423/$c" corpus/micro/ra_chains.c
done
for c in none O3XS Xr O3XSXr; do
  row "run 2026-11-09-8-micro-homes32, v423/$c" "micro/ra_homes32.c" "$O/2026-11-09-8-micro-homes32/out/v423/$c" corpus/micro/ra_homes32.c
done
for c in none O3XS; do
  row "run 2026-11-09-9-micro-fp, v423/$c" "micro/fp.c" "$O/2026-11-09-9-micro-fp/out/v423/$c" corpus/micro/fp.c
done
for c in none O3XS; do
  row "run 2026-11-09-10-micro-fptemps, v423/$c" "micro/fp_temps.c" "$O/2026-11-09-10-micro-fptemps/out/v423/$c" corpus/micro/fp_temps.c
done
for c in Xr O3XSXr; do
  row "run 2026-11-09-11-micro-opttemps, v423/$c" "micro/opt_temps.c" "$O/2026-11-09-11-micro-opttemps/out/v423/$c" corpus/micro/opt_temps.c
done
for c in none O3XS Xr O3XSXr; do
  row "run 2026-11-09-12-micro-optcounted, v423/$c" "micro/opt_counted.c" "$O/2026-11-09-12-micro-optcounted/out/v423/$c" corpus/micro/opt_counted.c
done
for c in none O3XS; do
  row "run 2026-11-09-13-micro-fpstmts, v423/$c" "micro/fp_stmts.c" "$O/2026-11-09-13-micro-fpstmts/out/v423/$c" corpus/micro/fp_stmts.c
done
row "run 2026-11-08-9-micro-optloops, v423/O3XS" "micro/opt_loops.c" "$O/2026-11-08-9-micro-optloops/out/v423/O3XS" corpus/micro/opt_loops.c
for p in v4.23 kn5000; do
  row "run 2026-11-08-5-libsrc97-O3XS, v423/O3XS, --personality $p" "1997 LIB/SRC" \
    "$O/2026-11-08-5-libsrc97-O3XS/out/v423/O3XS" "$C"/libsrc/*.C -D__900__ -D__LARGE__ -DFLOAT -D__CDECL= '-D__ASM(x)=' -I"$C"/inc --personality $p
done
row "run 2026-11-08-5-libsrc97-O3XS, ide2003/O3XS, --personality ide2003" "1997 LIB/SRC" \
  "$O/2026-11-08-5-libsrc97-O3XS/out/ide2003/O3XS" "$C"/libsrc/*.C -D__900__ -D__LARGE__ -DFLOAT -D__CDECL= '-D__ASM(x)=' -I"$C"/inc --personality ide2003
for c in none O3XS Xr O3XSXr; do
  row "run 2026-11-09-14-micro-libshapes, v423/$c" "micro/ra_libshapes.c" "$O/2026-11-09-14-micro-libshapes/out/v423/$c" corpus/micro/ra_libshapes.c
done
for c in none O3XS; do    # -Xr: a double return is THC1-Error-373 under adecl
  row "run 2026-11-09-15-micro-fporder, v423/$c" "micro/fp_order.c" "$O/2026-11-09-15-micro-fporder/out/v423/$c" corpus/micro/fp_order.c
done
for c in none O3XS; do    # FP slot probes of research-scratch sessions/2026-11-09_cc900-fp-prepass (corpus/probes/)
  row "run 2026-11-09-18-micro-fpprepass, v423/$c" "probes/fpp1.c" "$O/2026-11-09-18-micro-fpprepass/out/v423/$c/micro" corpus/probes/fpp1.c --opt $c
  row "run 2026-11-09-19-micro-fpprepass2, v423/$c" "probes/fpp2.c" "$O/2026-11-09-19-micro-fpprepass2/out/v423/$c/micro" corpus/probes/fpp2.c --opt $c
done
for c in none O3XS; do    # E2 probes of research-scratch sessions/2026-11-09_cc900-fp-e2 (corpus/probes/)
  row "run 2026-11-09-26-micro-fpe2, v423/$c" "probes/fpp3.c" "$O/2026-11-09-26-micro-fpe2/out/v423/$c/probes" corpus/probes/fpp3.c --opt $c
  row "run 2026-11-09-28-micro-fpe2b, v423/$c" "probes/fpp4.c" "$O/2026-11-09-28-micro-fpe2b/out/v423/$c/probes" corpus/probes/fpp4.c --opt $c
  row "run 2026-11-09-36-micro-fpe2c, v423/$c" "probes/fpp5.c" "$O/2026-11-09-36-micro-fpe2c/out/v423/$c/probes" corpus/probes/fpp5.c --opt $c
  row "run 2026-11-09-38-micro-fpe2d, v423/$c" "probes/fpp6.c" "$O/2026-11-09-38-micro-fpe2d/out/v423/$c/probes" corpus/probes/fpp6.c --opt $c
  row "run 2026-11-09-39-micro-fpe2e, v423/$c" "probes/fpp7.c" "$O/2026-11-09-39-micro-fpe2e/out/v423/$c/probes" corpus/probes/fpp7.c --opt $c
  row "run 2026-11-09-40-micro-fpe2f, v423/$c" "probes/fpp8.c" "$O/2026-11-09-40-micro-fpe2f/out/v423/$c/probes" corpus/probes/fpp8.c --opt $c
  row "run 2026-11-09-41-micro-fpe2g, v423/$c" "probes/fpp9.c" "$O/2026-11-09-41-micro-fpe2g/out/v423/$c/probes" corpus/probes/fpp9.c --opt $c
done
for c in none O3XS Xr O3XSXr; do
  row "run 2026-11-09-22-micro-condbits, v423/$c" "micro/cond_bits.c" "$O/2026-11-09-22-micro-condbits/out/v423/$c" corpus/micro/cond_bits.c
done
for c in none O3XS Xr O3XSXr; do
  row "run 2026-11-09-23-micro-assignexpr, v423/$c" "micro/assign_expr.c" "$O/2026-11-09-23-micro-assignexpr/out/v423/$c" corpus/micro/assign_expr.c
done
for c in none O3XS Xr O3XSXr; do
  row "run 2026-11-09-24-micro-arrindex, v423/$c" "micro/arr_index.c" "$O/2026-11-09-24-micro-arrindex/out/v423/$c" corpus/micro/arr_index.c
  row "run 2026-11-09-25-micro-arrindexsz, v423/$c" "micro/arr_index_sz.c" "$O/2026-11-09-25-micro-arrindexsz/out/v423/$c" corpus/micro/arr_index_sz.c
done
for c in none O3XS; do    # FP parameters and arguments under both conventions (corpus/probes/adfp.c)
  row "run 2026-11-09-29-micro-adfp, v423/$c" "probes/adfp.c" "$O/2026-11-09-29-micro-adfp/out/v423/$c/probes" corpus/probes/adfp.c --opt $c
done
row "run 2026-11-09-29-micro-adfp, v423/Xr" "probes/adfp.c" "$O/2026-11-09-29-micro-adfp/out/v423/Xr/probes" corpus/probes/adfp.c --opt none --adecl
row "run 2026-11-09-29-micro-adfp, v423/O3XSXr" "probes/adfp.c" "$O/2026-11-09-29-micro-adfp/out/v423/O3XSXr/probes" corpus/probes/adfp.c --opt O3XS --adecl
for c in none O3XS; do    # int arithmetic on a char done in the byte (corpus/probes/chnarrow.c)
  row "run 2026-11-09-30-micro-chnarrow, v423/$c" "probes/chnarrow.c" "$O/2026-11-09-30-micro-chnarrow/out/v423/$c/probes" corpus/probes/chnarrow.c --opt $c
done
row "run 2026-11-09-30-micro-chnarrow, v423/Xr" "probes/chnarrow.c" "$O/2026-11-09-30-micro-chnarrow/out/v423/Xr/probes" corpus/probes/chnarrow.c --opt none --adecl
row "run 2026-11-09-30-micro-chnarrow, v423/O3XSXr" "probes/chnarrow.c" "$O/2026-11-09-30-micro-chnarrow/out/v423/O3XSXr/probes" corpus/probes/chnarrow.c --opt O3XS --adecl
for c in none O3XS; do    # leaf-loop registers without options (rule LN1, model/leafnone.py): what loop bodies reserve (corpus/probes/lnr.c)
  row "run 2026-11-09-31-micro-lnr, v423/$c" "probes/lnr.c" "$O/2026-11-09-31-micro-lnr/out/v423/$c/probes" corpus/probes/lnr.c --opt $c
done
row "run 2026-11-09-31-micro-lnr, v423/Xr" "probes/lnr.c" "$O/2026-11-09-31-micro-lnr/out/v423/Xr/probes" corpus/probes/lnr.c --opt none --adecl
row "run 2026-11-09-31-micro-lnr, v423/O3XSXr" "probes/lnr.c" "$O/2026-11-09-31-micro-lnr/out/v423/O3XSXr/probes" corpus/probes/lnr.c --opt O3XS --adecl
for c in none O3XS; do    # LN1, second round: counter first, parameter order (corpus/probes/lnr2.c)
  row "run 2026-11-09-32-micro-lnr2, v423/$c" "probes/lnr2.c" "$O/2026-11-09-32-micro-lnr2/out/v423/$c/probes" corpus/probes/lnr2.c --opt $c
done
row "run 2026-11-09-32-micro-lnr2, v423/Xr" "probes/lnr2.c" "$O/2026-11-09-32-micro-lnr2/out/v423/Xr/probes" corpus/probes/lnr2.c --opt none --adecl
row "run 2026-11-09-32-micro-lnr2, v423/O3XSXr" "probes/lnr2.c" "$O/2026-11-09-32-micro-lnr2/out/v423/O3XSXr/probes" corpus/probes/lnr2.c --opt O3XS --adecl
for c in none O3XS; do    # LN1, third round: held addresses, pointer first references (corpus/probes/lnr3.c)
  row "run 2026-11-09-33-micro-lnr3, v423/$c" "probes/lnr3.c" "$O/2026-11-09-33-micro-lnr3/out/v423/$c/probes" corpus/probes/lnr3.c --opt $c
done
row "run 2026-11-09-33-micro-lnr3, v423/Xr" "probes/lnr3.c" "$O/2026-11-09-33-micro-lnr3/out/v423/Xr/probes" corpus/probes/lnr3.c --opt none --adecl
row "run 2026-11-09-33-micro-lnr3, v423/O3XSXr" "probes/lnr3.c" "$O/2026-11-09-33-micro-lnr3/out/v423/O3XSXr/probes" corpus/probes/lnr3.c --opt O3XS --adecl
for c in none O3XS; do    # LN1 held-out check (predictions recorded before the run) (corpus/probes/lnr4.c)
  row "run 2026-11-09-34-micro-lnr4, v423/$c" "probes/lnr4.c" "$O/2026-11-09-34-micro-lnr4/out/v423/$c/probes" corpus/probes/lnr4.c --opt $c
done
row "run 2026-11-09-34-micro-lnr4, v423/Xr" "probes/lnr4.c" "$O/2026-11-09-34-micro-lnr4/out/v423/Xr/probes" corpus/probes/lnr4.c --opt none --adecl
row "run 2026-11-09-34-micro-lnr4, v423/O3XSXr" "probes/lnr4.c" "$O/2026-11-09-34-micro-lnr4/out/v423/O3XSXr/probes" corpus/probes/lnr4.c --opt O3XS --adecl
for c in none O3XS; do    # does `register` move a home (corpus/probes/regkw.c)
  row "run 2026-11-09-35-micro-regkw, v423/$c" "probes/regkw.c" "$O/2026-11-09-35-micro-regkw/out/v423/$c/probes" corpus/probes/regkw.c --opt $c
done
row "run 2026-11-09-35-micro-regkw, v423/Xr" "probes/regkw.c" "$O/2026-11-09-35-micro-regkw/out/v423/Xr/probes" corpus/probes/regkw.c --opt none --adecl
row "run 2026-11-09-35-micro-regkw, v423/O3XSXr" "probes/regkw.c" "$O/2026-11-09-35-micro-regkw/out/v423/O3XSXr/probes" corpus/probes/regkw.c --opt O3XS --adecl
for c in none O3XS; do    # IZ / QIZ homes across calls, rule homes2 (corpus/probes/homes2a.c)
  row "run 2026-11-09-37-micro-homes2a, v423/$c" "probes/homes2a.c" "$O/2026-11-09-37-micro-homes2a/out/v423/$c/probes" corpus/probes/homes2a.c --opt $c
done
row "run 2026-11-09-37-micro-homes2a, v423/Xr" "probes/homes2a.c" "$O/2026-11-09-37-micro-homes2a/out/v423/Xr/probes" corpus/probes/homes2a.c --opt none --adecl
row "run 2026-11-09-37-micro-homes2a, v423/O3XSXr" "probes/homes2a.c" "$O/2026-11-09-37-micro-homes2a/out/v423/O3XSXr/probes" corpus/probes/homes2a.c --opt O3XS --adecl
for c in none O3XS; do    # IZ / QIZ homes across calls, rule homes2 (corpus/probes/homes2b.c)
  row "run 2026-11-09-42-micro-homes2b, v423/$c" "probes/homes2b.c" "$O/2026-11-09-42-micro-homes2b/out/v423/$c/probes" corpus/probes/homes2b.c --opt $c
done
row "run 2026-11-09-42-micro-homes2b, v423/Xr" "probes/homes2b.c" "$O/2026-11-09-42-micro-homes2b/out/v423/Xr/probes" corpus/probes/homes2b.c --opt none --adecl
row "run 2026-11-09-42-micro-homes2b, v423/O3XSXr" "probes/homes2b.c" "$O/2026-11-09-42-micro-homes2b/out/v423/O3XSXr/probes" corpus/probes/homes2b.c --opt O3XS --adecl
row "run 2026-11-09-3-proxy-tiny, v423/O3XSXr" "firmware/tiny.c" "$O/2026-11-09-3-proxy-tiny/out/v423/O3XSXr" corpus/firmware/tiny.c
# counted loops (rule U1, 2026-11-09): the other option sets of runs 2026-11-08-8 and 2026-11-08-9
for c in O3XS Xr; do
  row "run 2026-11-08-8-micro-ra, v423/$c" "micro/ra_*.c" "$O/2026-11-08-8-micro-ra/out/v423/$c" corpus/micro/ra_*.c
done
for c in none Xr O3XSXr; do
  row "run 2026-11-08-9-micro-optloops, v423/$c" "micro/opt_loops.c" "$O/2026-11-08-9-micro-optloops/out/v423/$c" corpus/micro/opt_loops.c
done
