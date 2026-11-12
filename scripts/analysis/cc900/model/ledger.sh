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
  row "run 2026-11-10-2-micro-fpe3a, v423/$c" "probes/fpp10.c" "$O/2026-11-10-2-micro-fpe3a/out/v423/$c/probes" corpus/probes/fpp10.c --opt $c
  row "run 2026-11-10-3-micro-fpe3b, v423/$c" "probes/fpp11.c" "$O/2026-11-10-3-micro-fpe3b/out/v423/$c/probes" corpus/probes/fpp11.c --opt $c
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
for c in none O3XS; do    # char indexes: element addresses and pointer sums whose index is a char (corpus/probes/chidx.c)
  row "run 2026-11-10-4-micro-chidx, v423/$c" "probes/chidx.c" "$O/2026-11-10-4-micro-chidx/out/v423/$c/probes" corpus/probes/chidx.c --opt $c
done
row "run 2026-11-10-4-micro-chidx, v423/Xr" "probes/chidx.c" "$O/2026-11-10-4-micro-chidx/out/v423/Xr/probes" corpus/probes/chidx.c --opt none --adecl
row "run 2026-11-10-4-micro-chidx, v423/O3XSXr" "probes/chidx.c" "$O/2026-11-10-4-micro-chidx/out/v423/O3XSXr/probes" corpus/probes/chidx.c --opt O3XS --adecl
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
for c in none O3XS; do    # random C89 programs, gen_random.py seed 1 (corpus/random/README.md)
  row "run 2026-11-10-1-micro-random1, v423/$c" "random/*.c" "$O/2026-11-10-1-micro-random1/out/v423/$c/random" corpus/random/*.c --opt $c
done
row "run 2026-11-10-1-micro-random1, v423/Xr" "random/*.c" "$O/2026-11-10-1-micro-random1/out/v423/Xr/random" corpus/random/*.c --opt none --adecl
row "run 2026-11-10-1-micro-random1, v423/O3XSXr" "random/*.c" "$O/2026-11-10-1-micro-random1/out/v423/O3XSXr/random" corpus/random/*.c --opt O3XS --adecl
for c in none O3XS; do    # the second random corpus, gen_random.py seed 2 (corpus/random/README.md)
  row "run 2026-11-10-5-micro-random2, v423/$c" "random2/*.c" "$O/2026-11-10-5-micro-random2/out/v423/$c/random2" corpus/random2/*.c --opt $c
done
row "run 2026-11-10-5-micro-random2, v423/Xr" "random2/*.c" "$O/2026-11-10-5-micro-random2/out/v423/Xr/random2" corpus/random2/*.c --opt none --adecl
row "run 2026-11-10-5-micro-random2, v423/O3XSXr" "random2/*.c" "$O/2026-11-10-5-micro-random2/out/v423/O3XSXr/random2" corpus/random2/*.c --opt O3XS --adecl
for c in none O3XS; do    # the third random corpus, gen_random.py seed 3
  row "run 2026-11-10-6-micro-random3, v423/$c" "random3/*.c" "$O/2026-11-10-6-micro-random3/out/v423/$c/random3" corpus/random3/*.c --opt $c
done
row "run 2026-11-10-6-micro-random3, v423/Xr" "random3/*.c" "$O/2026-11-10-6-micro-random3/out/v423/Xr/random3" corpus/random3/*.c --opt none --adecl
row "run 2026-11-10-6-micro-random3, v423/O3XSXr" "random3/*.c" "$O/2026-11-10-6-micro-random3/out/v423/O3XSXr/random3" corpus/random3/*.c --opt O3XS --adecl
for c in none O3XS; do    # the fourth random corpus, gen_random.py seed 4
  row "run 2026-11-10-7-micro-random4, v423/$c" "random4/*.c" "$O/2026-11-10-7-micro-random4/out/v423/$c/random4" corpus/random4/*.c --opt $c
done
row "run 2026-11-10-7-micro-random4, v423/Xr" "random4/*.c" "$O/2026-11-10-7-micro-random4/out/v423/Xr/random4" corpus/random4/*.c --opt none --adecl
row "run 2026-11-10-7-micro-random4, v423/O3XSXr" "random4/*.c" "$O/2026-11-10-7-micro-random4/out/v423/O3XSXr/random4" corpus/random4/*.c --opt O3XS --adecl
for c in none O3XS; do    # the order of evaluation of binary operands, by operand kind (corpus/probes/evorder.c)
  row "run 2026-11-10-9-micro-evorder, v423/$c" "probes/evorder.c" "$O/2026-11-10-9-micro-evorder/out/v423/$c/probes" corpus/probes/evorder.c --opt $c
done
row "run 2026-11-10-9-micro-evorder, v423/Xr" "probes/evorder.c" "$O/2026-11-10-9-micro-evorder/out/v423/Xr/probes" corpus/probes/evorder.c --opt none --adecl
row "run 2026-11-10-9-micro-evorder, v423/O3XSXr" "probes/evorder.c" "$O/2026-11-10-9-micro-evorder/out/v423/O3XSXr/probes" corpus/probes/evorder.c --opt O3XS --adecl
for c in none O3XS; do    # the order probe as a stored value and as an argument (corpus/probes/evorder_st.c)
  row "run 2026-11-10-10-micro-evorder2, v423/$c" "probes/evorder_st.c" "$O/2026-11-10-10-micro-evorder2/out/v423/$c/probes" corpus/probes/evorder_st.c --opt $c
done
row "run 2026-11-10-10-micro-evorder2, v423/Xr" "probes/evorder_st.c" "$O/2026-11-10-10-micro-evorder2/out/v423/Xr/probes" corpus/probes/evorder_st.c --opt none --adecl
row "run 2026-11-10-10-micro-evorder2, v423/O3XSXr" "probes/evorder_st.c" "$O/2026-11-10-10-micro-evorder2/out/v423/O3XSXr/probes" corpus/probes/evorder_st.c --opt O3XS --adecl
for c in none O3XS; do    # the order probe with long operands (corpus/probes/evorder_l.c)
  row "run 2026-11-10-10-micro-evorder2, v423/$c" "probes/evorder_l.c" "$O/2026-11-10-10-micro-evorder2/out/v423/$c/probes" corpus/probes/evorder_l.c --opt $c
done
row "run 2026-11-10-10-micro-evorder2, v423/Xr" "probes/evorder_l.c" "$O/2026-11-10-10-micro-evorder2/out/v423/Xr/probes" corpus/probes/evorder_l.c --opt none --adecl
row "run 2026-11-10-10-micro-evorder2, v423/O3XSXr" "probes/evorder_l.c" "$O/2026-11-10-10-micro-evorder2/out/v423/O3XSXr/probes" corpus/probes/evorder_l.c --opt O3XS --adecl
for c in none O3XS; do    # the order probe for / and % (corpus/probes/evorder_d.c)
  row "run 2026-11-10-11-micro-evorder3, v423/$c" "probes/evorder_d.c" "$O/2026-11-10-11-micro-evorder3/out/v423/$c/probes" corpus/probes/evorder_d.c --opt $c
done
row "run 2026-11-10-11-micro-evorder3, v423/Xr" "probes/evorder_d.c" "$O/2026-11-10-11-micro-evorder3/out/v423/Xr/probes" corpus/probes/evorder_d.c --opt none --adecl
row "run 2026-11-10-11-micro-evorder3, v423/O3XSXr" "probes/evorder_d.c" "$O/2026-11-10-11-micro-evorder3/out/v423/O3XSXr/probes" corpus/probes/evorder_d.c --opt O3XS --adecl
for c in none O3XS; do    # compare operands by kind: order, registers and the cp form (corpus/probes/cmpord.c)
  row "run 2026-11-10-12-micro-cmpord, v423/$c" "probes/cmpord.c" "$O/2026-11-10-12-micro-cmpord/out/v423/$c/probes" corpus/probes/cmpord.c --opt $c
done
row "run 2026-11-10-12-micro-cmpord, v423/Xr" "probes/cmpord.c" "$O/2026-11-10-12-micro-cmpord/out/v423/Xr/probes" corpus/probes/cmpord.c --opt none --adecl
row "run 2026-11-10-12-micro-cmpord, v423/O3XSXr" "probes/cmpord.c" "$O/2026-11-10-12-micro-cmpord/out/v423/O3XSXr/probes" corpus/probes/cmpord.c --opt O3XS --adecl
for c in none O3XS; do    # the arguments of the long * / % helpers by operand kind (corpus/probes/evorder_lh.c)
  row "run 2026-11-10-13-micro-evorder4, v423/$c" "probes/evorder_lh.c" "$O/2026-11-10-13-micro-evorder4/out/v423/$c/probes" corpus/probes/evorder_lh.c --opt $c
done
row "run 2026-11-10-13-micro-evorder4, v423/Xr" "probes/evorder_lh.c" "$O/2026-11-10-13-micro-evorder4/out/v423/Xr/probes" corpus/probes/evorder_lh.c --opt none --adecl
row "run 2026-11-10-13-micro-evorder4, v423/O3XSXr" "probes/evorder_lh.c" "$O/2026-11-10-13-micro-evorder4/out/v423/O3XSXr/probes" corpus/probes/evorder_lh.c --opt O3XS --adecl
for c in none O3XS; do    # where a local with an initialiser lives (corpus/probes/loc0.c, plan_regtemps)
  row "run 2026-11-10-14-micro-loc0, v423/$c" "probes/loc0.c" "$O/2026-11-10-14-micro-loc0/out/v423/$c/probes" corpus/probes/loc0.c --opt $c
done
row "run 2026-11-10-14-micro-loc0, v423/Xr" "probes/loc0.c" "$O/2026-11-10-14-micro-loc0/out/v423/Xr/probes" corpus/probes/loc0.c --opt none --adecl
row "run 2026-11-10-14-micro-loc0, v423/O3XSXr" "probes/loc0.c" "$O/2026-11-10-14-micro-loc0/out/v423/O3XSXr/probes" corpus/probes/loc0.c --opt O3XS --adecl
for c in none O3XS; do    # the order and registers of a store's address and value (corpus/probes/stord.c)
  row "run 2026-11-10-15-micro-stord, v423/$c" "probes/stord.c" "$O/2026-11-10-15-micro-stord/out/v423/$c/probes" corpus/probes/stord.c --opt $c
done
row "run 2026-11-10-15-micro-stord, v423/Xr" "probes/stord.c" "$O/2026-11-10-15-micro-stord/out/v423/Xr/probes" corpus/probes/stord.c --opt none --adecl
row "run 2026-11-10-15-micro-stord, v423/O3XSXr" "probes/stord.c" "$O/2026-11-10-15-micro-stord/out/v423/O3XSXr/probes" corpus/probes/stord.c --opt O3XS --adecl
for c in none O3XS; do    # the operands of long and char compares (corpus/probes/cmpordl.c)
  row "run 2026-11-10-16-micro-cmpordl, v423/$c" "probes/cmpordl.c" "$O/2026-11-10-16-micro-cmpordl/out/v423/$c/probes" corpus/probes/cmpordl.c --opt $c
done
row "run 2026-11-10-16-micro-cmpordl, v423/Xr" "probes/cmpordl.c" "$O/2026-11-10-16-micro-cmpordl/out/v423/Xr/probes" corpus/probes/cmpordl.c --opt none --adecl
row "run 2026-11-10-16-micro-cmpordl, v423/O3XSXr" "probes/cmpordl.c" "$O/2026-11-10-16-micro-cmpordl/out/v423/O3XSXr/probes" corpus/probes/cmpordl.c --opt O3XS --adecl
for c in none O3XS; do    # the order of evaluation with addressed operands and calls (corpus/probes/evorder_ad.c)
  row "run 2026-11-10-17-micro-evorder_ad, v423/$c" "probes/evorder_ad.c" "$O/2026-11-10-17-micro-evorder_ad/out/v423/$c/probes" corpus/probes/evorder_ad.c --opt $c
done
row "run 2026-11-10-17-micro-evorder_ad, v423/Xr" "probes/evorder_ad.c" "$O/2026-11-10-17-micro-evorder_ad/out/v423/Xr/probes" corpus/probes/evorder_ad.c --opt none --adecl
row "run 2026-11-10-17-micro-evorder_ad, v423/O3XSXr" "probes/evorder_ad.c" "$O/2026-11-10-17-micro-evorder_ad/out/v423/O3XSXr/probes" corpus/probes/evorder_ad.c --opt O3XS --adecl
for c in none O3XS; do    # compare operands of the second wave: casts, pointer indexes, local indexes (corpus/probes/cmpordl2.c)
  row "run 2026-11-10-18-micro-cmpordl2, v423/$c" "probes/cmpordl2.c" "$O/2026-11-10-18-micro-cmpordl2/out/v423/$c/probes" corpus/probes/cmpordl2.c --opt $c
done
row "run 2026-11-10-18-micro-cmpordl2, v423/Xr" "probes/cmpordl2.c" "$O/2026-11-10-18-micro-cmpordl2/out/v423/Xr/probes" corpus/probes/cmpordl2.c --opt none --adecl
row "run 2026-11-10-18-micro-cmpordl2, v423/O3XSXr" "probes/cmpordl2.c" "$O/2026-11-10-18-micro-cmpordl2/out/v423/O3XSXr/probes" corpus/probes/cmpordl2.c --opt O3XS --adecl
for c in none O3XS; do    # a store whose value is an assignment (corpus/probes/stchain.c)
  row "run 2026-11-12-1-micro-stchain, v423/$c" "probes/stchain.c" "$O/2026-11-12-1-micro-stchain/out/v423/$c/probes" corpus/probes/stchain.c --opt $c
done
row "run 2026-11-12-1-micro-stchain, v423/Xr" "probes/stchain.c" "$O/2026-11-12-1-micro-stchain/out/v423/Xr/probes" corpus/probes/stchain.c --opt none --adecl
row "run 2026-11-12-1-micro-stchain, v423/O3XSXr" "probes/stchain.c" "$O/2026-11-12-1-micro-stchain/out/v423/O3XSXr/probes" corpus/probes/stchain.c --opt O3XS --adecl
for c in none O3XS; do    # an assignment as a return value, char chained stores (corpus/probes/stret.c)
  row "run 2026-11-12-2-micro-stret, v423/$c" "probes/stret.c" "$O/2026-11-12-2-micro-stret/out/v423/$c/probes" corpus/probes/stret.c --opt $c
done
row "run 2026-11-12-2-micro-stret, v423/Xr" "probes/stret.c" "$O/2026-11-12-2-micro-stret/out/v423/Xr/probes" corpus/probes/stret.c --opt none --adecl
row "run 2026-11-12-2-micro-stret, v423/O3XSXr" "probes/stret.c" "$O/2026-11-12-2-micro-stret/out/v423/O3XSXr/probes" corpus/probes/stret.c --opt O3XS --adecl
for c in none O3XS; do    # an element at a local index (corpus/probes/idxloc.c)
  row "run 2026-11-12-3-micro-idxloc, v423/$c" "probes/idxloc.c" "$O/2026-11-12-3-micro-idxloc/out/v423/$c/probes" corpus/probes/idxloc.c --opt $c
done
row "run 2026-11-12-3-micro-idxloc, v423/Xr" "probes/idxloc.c" "$O/2026-11-12-3-micro-idxloc/out/v423/Xr/probes" corpus/probes/idxloc.c --opt none --adecl
row "run 2026-11-12-3-micro-idxloc, v423/O3XSXr" "probes/idxloc.c" "$O/2026-11-12-3-micro-idxloc/out/v423/O3XSXr/probes" corpus/probes/idxloc.c --opt O3XS --adecl
for c in none O3XS; do    # an assignment whose value is read through an address (corpus/probes/stval.c)
  row "run 2026-11-12-4-micro-stval, v423/$c" "probes/stval.c" "$O/2026-11-12-4-micro-stval/out/v423/$c/probes" corpus/probes/stval.c --opt $c
done
row "run 2026-11-12-4-micro-stval, v423/Xr" "probes/stval.c" "$O/2026-11-12-4-micro-stval/out/v423/Xr/probes" corpus/probes/stval.c --opt none --adecl
row "run 2026-11-12-4-micro-stval, v423/O3XSXr" "probes/stval.c" "$O/2026-11-12-4-micro-stval/out/v423/O3XSXr/probes" corpus/probes/stval.c --opt O3XS --adecl
row "run 2026-11-09-3-proxy-tiny, v423/O3XSXr" "firmware/tiny.c" "$O/2026-11-09-3-proxy-tiny/out/v423/O3XSXr" corpus/firmware/tiny.c
# counted loops (rule U1, 2026-11-09): the other option sets of runs 2026-11-08-8 and 2026-11-08-9
for c in O3XS Xr; do
  row "run 2026-11-08-8-micro-ra, v423/$c" "micro/ra_*.c" "$O/2026-11-08-8-micro-ra/out/v423/$c" corpus/micro/ra_*.c
done
for c in none Xr O3XSXr; do
  row "run 2026-11-08-9-micro-optloops, v423/$c" "micro/opt_loops.c" "$O/2026-11-08-9-micro-optloops/out/v423/$c" corpus/micro/opt_loops.c
done
