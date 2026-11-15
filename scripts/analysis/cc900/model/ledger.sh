#!/bin/sh
# Regenerates the score rows of ../results/model_ledger.md: one score.py run per oracle directory.
# usage: sh model/ledger.sh   (from scripts/analysis/cc900; needs the private oracle runs and the library scratch copy)
# ORACLE (default ~/compartilhado/cc900-oracle/runs) and LIBCOPY (default ~/compartilhado/tmp/cc900-corpus-libsrc97,
# made as model_ledger.md describes) may be overridden.  The abi rows read Toshiba's headers from LIBCOPY/inc too
# (varargs.c's stdarg.h macros are what the oracle compiled; clang's builtin stdarg.h is not).  Prints "oracle | corpus | TOTAL line" rows.
O=${ORACLE:-$HOME/compartilhado/cc900-oracle/runs}
C=${LIBCOPY:-$HOME/compartilhado/tmp/cc900-corpus-libsrc97}
# The rows are independent: LEDGER_JOBS of them (default 8) run at a time, each into its own numbered file, and the
# files are printed in row order at the end (one core took about 7.5 minutes for the 247 rows on 2026-11-12).
PY=${CC900_PY:-python3 -I -B}      # e.g. "python3 -I -X pycache_prefix=$TMPDIR/cc900-pyc": the model's bytecode kept between rows
SCORE=${CC900_SCORE:-model/score.py}  # another copy's score.py scores that copy (the scratch-copy ledger)
J=${LEDGER_JOBS:-8}; LT=$(mktemp -d "${TMPDIR:-/tmp}/cc900-ledger-XXXXXX"); N=0
ledger_row() {
  N=$((N + 1)); f=$(printf '%s/%04d' "$LT" "$N")
  ( printf '%s | %s | ' "$1" "$2"; shift 2; $PY "$SCORE" "$@" 2>&1 | tail -1 ) > "$f" &
  [ $((N % J)) -eq 0 ] && wait
  return 0
}
# (semcheck.py reads this script's rows by replacing the one-line definition below: keep it on one line)
row() { ledger_row "$@"; }
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
for c in none O3XS; do    # a store whose value is a division or a remainder (corpus/probes/stdiv.c)
  row "run 2026-11-12-5-micro-stdiv, v423/$c" "probes/stdiv.c" "$O/2026-11-12-5-micro-stdiv/out/v423/$c/probes" corpus/probes/stdiv.c --opt $c
done
row "run 2026-11-12-5-micro-stdiv, v423/Xr" "probes/stdiv.c" "$O/2026-11-12-5-micro-stdiv/out/v423/Xr/probes" corpus/probes/stdiv.c --opt none --adecl
row "run 2026-11-12-5-micro-stdiv, v423/O3XSXr" "probes/stdiv.c" "$O/2026-11-12-5-micro-stdiv/out/v423/O3XSXr/probes" corpus/probes/stdiv.c --opt O3XS --adecl
for c in none O3XS; do    # long helpers with an element at a loop counter or local index (corpus/probes/lhidx.c)
  row "run 2026-11-12-6-micro-lhidx, v423/$c" "probes/lhidx.c" "$O/2026-11-12-6-micro-lhidx/out/v423/$c/probes" corpus/probes/lhidx.c --opt $c
done
row "run 2026-11-12-6-micro-lhidx, v423/Xr" "probes/lhidx.c" "$O/2026-11-12-6-micro-lhidx/out/v423/Xr/probes" corpus/probes/lhidx.c --opt none --adecl
row "run 2026-11-12-6-micro-lhidx, v423/O3XSXr" "probes/lhidx.c" "$O/2026-11-12-6-micro-lhidx/out/v423/O3XSXr/probes" corpus/probes/lhidx.c --opt O3XS --adecl
for c in none O3XS; do    # a bare-declared loop counter (corpus/probes/loopctr.c)
  row "run 2026-11-12-7-micro-loopctr, v423/$c" "probes/loopctr.c" "$O/2026-11-12-7-micro-loopctr/out/v423/$c/probes" corpus/probes/loopctr.c --opt $c
done
row "run 2026-11-12-7-micro-loopctr, v423/Xr" "probes/loopctr.c" "$O/2026-11-12-7-micro-loopctr/out/v423/Xr/probes" corpus/probes/loopctr.c --opt none --adecl
row "run 2026-11-12-7-micro-loopctr, v423/O3XSXr" "probes/loopctr.c" "$O/2026-11-12-7-micro-loopctr/out/v423/O3XSXr/probes" corpus/probes/loopctr.c --opt O3XS --adecl
for c in none O3XS; do    # statement stores of a computed value read through an address (corpus/probes/stvx.c)
  row "run 2026-11-12-8-micro-stvx, v423/$c" "probes/stvx.c" "$O/2026-11-12-8-micro-stvx/out/v423/$c/probes" corpus/probes/stvx.c --opt $c
done
row "run 2026-11-12-8-micro-stvx, v423/Xr" "probes/stvx.c" "$O/2026-11-12-8-micro-stvx/out/v423/Xr/probes" corpus/probes/stvx.c --opt none --adecl
row "run 2026-11-12-8-micro-stvx, v423/O3XSXr" "probes/stvx.c" "$O/2026-11-12-8-micro-stvx/out/v423/O3XSXr/probes" corpus/probes/stvx.c --opt O3XS --adecl
for c in none O3XS; do    # stvx.c in the random corpora's forms: implicit char promotion, char-parameter indices (corpus/probes/stvxc.c)
  row "run 2026-11-12-9-micro-stvxc, v423/$c" "probes/stvxc.c" "$O/2026-11-12-9-micro-stvxc/out/v423/$c/probes" corpus/probes/stvxc.c --opt $c
done
row "run 2026-11-12-9-micro-stvxc, v423/Xr" "probes/stvxc.c" "$O/2026-11-12-9-micro-stvxc/out/v423/Xr/probes" corpus/probes/stvxc.c --opt none --adecl
row "run 2026-11-12-9-micro-stvxc, v423/O3XSXr" "probes/stvxc.c" "$O/2026-11-12-9-micro-stvxc/out/v423/O3XSXr/probes" corpus/probes/stvxc.c --opt O3XS --adecl
for c in none O3XS; do    # double compound assignments (corpus/probes/fpopa.c)
  row "run 2026-11-12-10-micro-fpopa, v423/$c" "probes/fpopa.c" "$O/2026-11-12-10-micro-fpopa/out/v423/$c/probes" corpus/probes/fpopa.c --opt $c
done
row "run 2026-11-12-10-micro-fpopa, v423/Xr" "probes/fpopa.c" "$O/2026-11-12-10-micro-fpopa/out/v423/Xr/probes" corpus/probes/fpopa.c --opt none --adecl
row "run 2026-11-12-10-micro-fpopa, v423/O3XSXr" "probes/fpopa.c" "$O/2026-11-12-10-micro-fpopa/out/v423/O3XSXr/probes" corpus/probes/fpopa.c --opt O3XS --adecl
for c in none O3XS; do    # one double argument temporary and the frame around it (corpus/probes/fpargf.c)
  row "run 2026-11-12-11-micro-fpargf, v423/$c" "probes/fpargf.c" "$O/2026-11-12-11-micro-fpargf/out/v423/$c/probes" corpus/probes/fpargf.c --opt $c
done
row "run 2026-11-12-11-micro-fpargf, v423/Xr" "probes/fpargf.c" "$O/2026-11-12-11-micro-fpargf/out/v423/Xr/probes" corpus/probes/fpargf.c --opt none --adecl
row "run 2026-11-12-11-micro-fpargf, v423/O3XSXr" "probes/fpargf.c" "$O/2026-11-12-11-micro-fpargf/out/v423/O3XSXr/probes" corpus/probes/fpargf.c --opt O3XS --adecl
for c in none O3XS; do    # the construct around one double temporary (corpus/probes/fpargg.c)
  row "run 2026-11-12-12-micro-fpargg, v423/$c" "probes/fpargg.c" "$O/2026-11-12-12-micro-fpargg/out/v423/$c/probes" corpus/probes/fpargg.c --opt $c
done
row "run 2026-11-12-12-micro-fpargg, v423/Xr" "probes/fpargg.c" "$O/2026-11-12-12-micro-fpargg/out/v423/Xr/probes" corpus/probes/fpargg.c --opt none --adecl
row "run 2026-11-12-12-micro-fpargg, v423/O3XSXr" "probes/fpargg.c" "$O/2026-11-12-12-micro-fpargg/out/v423/O3XSXr/probes" corpus/probes/fpargg.c --opt O3XS --adecl
for c in none O3XS; do    # the order of a double operation's addresses (corpus/probes/fpord.c; -Xr rejects its double results)
  row "run 2026-11-12-13-micro-fpord, v423/$c" "probes/fpord.c" "$O/2026-11-12-13-micro-fpord/out/v423/$c/probes" corpus/probes/fpord.c --opt $c
done
for c in none O3XS; do    # stores of a division: more operand kinds (corpus/probes/stdiv2.c)
  row "run 2026-11-13-1-micro-stdiv2, v423/$c" "probes/stdiv2.c" "$O/2026-11-13-1-micro-stdiv2/out/v423/$c/probes" corpus/probes/stdiv2.c --opt $c
done
row "run 2026-11-13-1-micro-stdiv2, v423/Xr" "probes/stdiv2.c" "$O/2026-11-13-1-micro-stdiv2/out/v423/Xr/probes" corpus/probes/stdiv2.c --opt none --adecl
row "run 2026-11-13-1-micro-stdiv2, v423/O3XSXr" "probes/stdiv2.c" "$O/2026-11-13-1-micro-stdiv2/out/v423/O3XSXr/probes" corpus/probes/stdiv2.c --opt O3XS --adecl
for c in none O3XS; do    # long helpers: char / unsigned indices, more destinations, two helpers (corpus/probes/lhx.c)
  row "run 2026-11-13-2-micro-lhx, v423/$c" "probes/lhx.c" "$O/2026-11-13-2-micro-lhx/out/v423/$c/probes" corpus/probes/lhx.c --opt $c
done
row "run 2026-11-13-2-micro-lhx, v423/Xr" "probes/lhx.c" "$O/2026-11-13-2-micro-lhx/out/v423/Xr/probes" corpus/probes/lhx.c --opt none --adecl
row "run 2026-11-13-2-micro-lhx, v423/O3XSXr" "probes/lhx.c" "$O/2026-11-13-2-micro-lhx/out/v423/O3XSXr/probes" corpus/probes/lhx.c --opt O3XS --adecl
for c in none O3XS; do    # an element read beside a left value; an assignment used as a value (corpus/probes/elrd.c)
  row "run 2026-11-13-3-micro-elrd, v423/$c" "probes/elrd.c" "$O/2026-11-13-3-micro-elrd/out/v423/$c/probes" corpus/probes/elrd.c --opt $c
done
row "run 2026-11-13-3-micro-elrd, v423/Xr" "probes/elrd.c" "$O/2026-11-13-3-micro-elrd/out/v423/Xr/probes" corpus/probes/elrd.c --opt none --adecl
row "run 2026-11-13-3-micro-elrd, v423/O3XSXr" "probes/elrd.c" "$O/2026-11-13-3-micro-elrd/out/v423/O3XSXr/probes" corpus/probes/elrd.c --opt O3XS --adecl
for c in none O3XS; do    # compare operands: indexed elements, casts, computed operands (corpus/probes/cmpx.c)
  row "run 2026-11-13-4-micro-cmpx, v423/$c" "probes/cmpx.c" "$O/2026-11-13-4-micro-cmpx/out/v423/$c/probes" corpus/probes/cmpx.c --opt $c
done
row "run 2026-11-13-4-micro-cmpx, v423/Xr" "probes/cmpx.c" "$O/2026-11-13-4-micro-cmpx/out/v423/Xr/probes" corpus/probes/cmpx.c --opt none --adecl
row "run 2026-11-13-4-micro-cmpx, v423/O3XSXr" "probes/cmpx.c" "$O/2026-11-13-4-micro-cmpx/out/v423/O3XSXr/probes" corpus/probes/cmpx.c --opt O3XS --adecl
for c in none O3XS; do    # stores of a division by an element at a variable index (corpus/probes/stdiv3.c)
  row "run 2026-11-13-5-micro-stdiv3, v423/$c" "probes/stdiv3.c" "$O/2026-11-13-5-micro-stdiv3/out/v423/$c/probes" corpus/probes/stdiv3.c --opt $c
done
row "run 2026-11-13-5-micro-stdiv3, v423/Xr" "probes/stdiv3.c" "$O/2026-11-13-5-micro-stdiv3/out/v423/Xr/probes" corpus/probes/stdiv3.c --opt none --adecl
row "run 2026-11-13-5-micro-stdiv3, v423/O3XSXr" "probes/stdiv3.c" "$O/2026-11-13-5-micro-stdiv3/out/v423/O3XSXr/probes" corpus/probes/stdiv3.c --opt O3XS --adecl
for c in none O3XS; do    # constant folding with a negated constant against a literal in 128..255 (corpus/probes/negk.c)
  row "run 2026-11-13-6-micro-negk, v423/$c" "probes/negk.c" "$O/2026-11-13-6-micro-negk/out/v423/$c/probes" corpus/probes/negk.c --opt $c
done
row "run 2026-11-13-6-micro-negk, v423/Xr" "probes/negk.c" "$O/2026-11-13-6-micro-negk/out/v423/Xr/probes" corpus/probes/negk.c --opt none --adecl
row "run 2026-11-13-6-micro-negk, v423/O3XSXr" "probes/negk.c" "$O/2026-11-13-6-micro-negk/out/v423/O3XSXr/probes" corpus/probes/negk.c --opt O3XS --adecl
for c in none O3XS; do    # every statement line of the random corpora alone in its own function (corpus/probes/rstmt1..4.c)
  row "run 2026-11-13-7-micro-rstmt, v423/$c" "probes/rstmt*.c" "$O/2026-11-13-7-micro-rstmt/out/v423/$c/probes" corpus/probes/rstmt1.c corpus/probes/rstmt2.c corpus/probes/rstmt3.c corpus/probes/rstmt4.c --opt $c
done
row "run 2026-11-13-7-micro-rstmt, v423/Xr" "probes/rstmt*.c" "$O/2026-11-13-7-micro-rstmt/out/v423/Xr/probes" corpus/probes/rstmt1.c corpus/probes/rstmt2.c corpus/probes/rstmt3.c corpus/probes/rstmt4.c --opt none --adecl
row "run 2026-11-13-7-micro-rstmt, v423/O3XSXr" "probes/rstmt*.c" "$O/2026-11-13-7-micro-rstmt/out/v423/O3XSXr/probes" corpus/probes/rstmt1.c corpus/probes/rstmt2.c corpus/probes/rstmt3.c corpus/probes/rstmt4.c --opt O3XS --adecl
for c in none O3XS; do    # char arithmetic in an int context (corpus/probes/chararith.c)
  row "run 2026-11-13-8-micro-chararith, v423/$c" "probes/chararith.c" "$O/2026-11-13-8-micro-chararith/out/v423/$c/probes" corpus/probes/chararith.c --opt $c
done
row "run 2026-11-13-8-micro-chararith, v423/Xr" "probes/chararith.c" "$O/2026-11-13-8-micro-chararith/out/v423/Xr/probes" corpus/probes/chararith.c --opt none --adecl
row "run 2026-11-13-8-micro-chararith, v423/O3XSXr" "probes/chararith.c" "$O/2026-11-13-8-micro-chararith/out/v423/O3XSXr/probes" corpus/probes/chararith.c --opt O3XS --adecl
for c in none O3XS; do    # constant folding of byte-sized constants (corpus/probes/kfold.c)
  row "run 2026-11-13-9-micro-kfold, v423/$c" "probes/kfold.c" "$O/2026-11-13-9-micro-kfold/out/v423/$c/probes" corpus/probes/kfold.c --opt $c
done
row "run 2026-11-13-9-micro-kfold, v423/Xr" "probes/kfold.c" "$O/2026-11-13-9-micro-kfold/out/v423/Xr/probes" corpus/probes/kfold.c --opt none --adecl
row "run 2026-11-13-9-micro-kfold, v423/O3XSXr" "probes/kfold.c" "$O/2026-11-13-9-micro-kfold/out/v423/O3XSXr/probes" corpus/probes/kfold.c --opt O3XS --adecl
for c in none O3XS; do    # char arithmetic by operand kind and shift count (corpus/probes/chararith2.c)
  row "run 2026-11-13-10-micro-chararith2, v423/$c" "probes/chararith2.c" "$O/2026-11-13-10-micro-chararith2/out/v423/$c/probes" corpus/probes/chararith2.c --opt $c
done
row "run 2026-11-13-10-micro-chararith2, v423/Xr" "probes/chararith2.c" "$O/2026-11-13-10-micro-chararith2/out/v423/Xr/probes" corpus/probes/chararith2.c --opt none --adecl
row "run 2026-11-13-10-micro-chararith2, v423/O3XSXr" "probes/chararith2.c" "$O/2026-11-13-10-micro-chararith2/out/v423/O3XSXr/probes" corpus/probes/chararith2.c --opt O3XS --adecl
for c in none O3XS; do    # long helpers with an element at an int or char index (corpus/probes/lhy.c)
  row "run 2026-11-13-11-micro-lhy, v423/$c" "probes/lhy.c" "$O/2026-11-13-11-micro-lhy/out/v423/$c/probes" corpus/probes/lhy.c --opt $c
done
row "run 2026-11-13-11-micro-lhy, v423/Xr" "probes/lhy.c" "$O/2026-11-13-11-micro-lhy/out/v423/Xr/probes" corpus/probes/lhy.c --opt none --adecl
row "run 2026-11-13-11-micro-lhy, v423/O3XSXr" "probes/lhy.c" "$O/2026-11-13-11-micro-lhy/out/v423/O3XSXr/probes" corpus/probes/lhy.c --opt O3XS --adecl
for c in none O3XS; do    # division / remainder stored into an element, through a pointer or a global (corpus/probes/stv.c)
  row "run 2026-11-13-12-micro-stv, v423/$c" "probes/stv.c" "$O/2026-11-13-12-micro-stv/out/v423/$c/probes" corpus/probes/stv.c --opt $c
done
row "run 2026-11-13-12-micro-stv, v423/Xr" "probes/stv.c" "$O/2026-11-13-12-micro-stv/out/v423/Xr/probes" corpus/probes/stv.c --opt none --adecl
row "run 2026-11-13-12-micro-stv, v423/O3XSXr" "probes/stv.c" "$O/2026-11-13-12-micro-stv/out/v423/O3XSXr/probes" corpus/probes/stv.c --opt O3XS --adecl
for c in none O3XS; do    # the second context of the store shapes: dividend gp->arr[c] (corpus/probes/stv2.c)
  row "run 2026-11-13-13-micro-stv2, v423/$c" "probes/stv2.c" "$O/2026-11-13-13-micro-stv2/out/v423/$c/probes" corpus/probes/stv2.c --opt $c
done
row "run 2026-11-13-13-micro-stv2, v423/Xr" "probes/stv2.c" "$O/2026-11-13-13-micro-stv2/out/v423/Xr/probes" corpus/probes/stv2.c --opt none --adecl
row "run 2026-11-13-13-micro-stv2, v423/O3XSXr" "probes/stv2.c" "$O/2026-11-13-13-micro-stv2/out/v423/O3XSXr/probes" corpus/probes/stv2.c --opt O3XS --adecl
for c in none O3XS; do    # when a cdecl parameter is cached in a register (corpus/probes/pc.c)
  row "run 2026-11-13-15-micro-pc, v423/$c" "probes/pc.c" "$O/2026-11-13-15-micro-pc/out/v423/$c/probes" corpus/probes/pc.c --opt $c
done
row "run 2026-11-13-15-micro-pc, v423/Xr" "probes/pc.c" "$O/2026-11-13-15-micro-pc/out/v423/Xr/probes" corpus/probes/pc.c --opt none --adecl
row "run 2026-11-13-15-micro-pc, v423/O3XSXr" "probes/pc.c" "$O/2026-11-13-15-micro-pc/out/v423/O3XSXr/probes" corpus/probes/pc.c --opt O3XS --adecl
for c in none O3XS; do    # a local in a frame slot across a long helper or a call (corpus/probes/lsl.c)
  row "run 2026-11-13-16-micro-lsl, v423/$c" "probes/lsl.c" "$O/2026-11-13-16-micro-lsl/out/v423/$c/probes" corpus/probes/lsl.c --opt $c
done
row "run 2026-11-13-16-micro-lsl, v423/Xr" "probes/lsl.c" "$O/2026-11-13-16-micro-lsl/out/v423/Xr/probes" corpus/probes/lsl.c --opt none --adecl
row "run 2026-11-13-16-micro-lsl, v423/O3XSXr" "probes/lsl.c" "$O/2026-11-13-16-micro-lsl/out/v423/O3XSXr/probes" corpus/probes/lsl.c --opt O3XS --adecl
for c in none O3XS; do    # ?: with one constant arm (lane_o3 rule 31) (corpus/probes/ternk.c, P11 evidence)
  row "run 2026-11-15-4-micro-ternk, v423/$c" "probes/ternk.c" "$O/2026-11-15-4-micro-ternk/out/v423/$c/probes" corpus/probes/ternk.c --opt $c
done
row "run 2026-11-15-4-micro-ternk, v423/Xr" "probes/ternk.c" "$O/2026-11-15-4-micro-ternk/out/v423/Xr/probes" corpus/probes/ternk.c --opt none --adecl
row "run 2026-11-15-4-micro-ternk, v423/O3XSXr" "probes/ternk.c" "$O/2026-11-15-4-micro-ternk/out/v423/O3XSXr/probes" corpus/probes/ternk.c --opt O3XS --adecl
for c in none O3XS; do    # element op= with computed values, truth values, char complements (corpus/probes/shp2.c, P11 evidence)
  row "run 2026-11-15-5-micro-shp2, v423/$c" "probes/shp2.c" "$O/2026-11-15-5-micro-shp2/out/v423/$c/probes" corpus/probes/shp2.c --opt $c
done
row "run 2026-11-15-5-micro-shp2, v423/Xr" "probes/shp2.c" "$O/2026-11-15-5-micro-shp2/out/v423/Xr/probes" corpus/probes/shp2.c --opt none --adecl
row "run 2026-11-15-5-micro-shp2, v423/O3XSXr" "probes/shp2.c" "$O/2026-11-15-5-micro-shp2/out/v423/O3XSXr/probes" corpus/probes/shp2.c --opt O3XS --adecl
for c in none O3XS; do    # verification of lane_o3 rules 19 / 21 / 22 / 26 (corpus/probes/o3v.c, P11 evidence)
  row "run 2026-11-15-6-micro-o3v, v423/$c" "probes/o3v.c" "$O/2026-11-15-6-micro-o3v/out/v423/$c/probes" corpus/probes/o3v.c --opt $c
done
row "run 2026-11-15-6-micro-o3v, v423/Xr" "probes/o3v.c" "$O/2026-11-15-6-micro-o3v/out/v423/Xr/probes" corpus/probes/o3v.c --opt none --adecl
row "run 2026-11-15-6-micro-o3v, v423/O3XSXr" "probes/o3v.c" "$O/2026-11-15-6-micro-o3v/out/v423/O3XSXr/probes" corpus/probes/o3v.c --opt O3XS --adecl
for c in none O3XS; do    # frame / context minimal pairs (lane_fpframe) (corpus/probes/fpctx1.c, P11 evidence)
  row "run 2026-11-15-7-micro-fpctx1, v423/$c" "probes/fpctx1.c" "$O/2026-11-15-7-micro-fpctx1/out/v423/$c/probes" corpus/probes/fpctx1.c --opt $c
done
row "run 2026-11-15-7-micro-fpctx1, v423/Xr" "probes/fpctx1.c" "$O/2026-11-15-7-micro-fpctx1/out/v423/Xr/probes" corpus/probes/fpctx1.c --opt none --adecl
row "run 2026-11-15-7-micro-fpctx1, v423/O3XSXr" "probes/fpctx1.c" "$O/2026-11-15-7-micro-fpctx1/out/v423/O3XSXr/probes" corpus/probes/fpctx1.c --opt O3XS --adecl
row "run 2026-11-09-3-proxy-tiny, v423/O3XSXr" "firmware/tiny.c" "$O/2026-11-09-3-proxy-tiny/out/v423/O3XSXr" corpus/firmware/tiny.c
# counted loops (rule U1, 2026-11-09): the other option sets of runs 2026-11-08-8 and 2026-11-08-9
for c in O3XS Xr; do
  row "run 2026-11-08-8-micro-ra, v423/$c" "micro/ra_*.c" "$O/2026-11-08-8-micro-ra/out/v423/$c" corpus/micro/ra_*.c
done
for c in none Xr O3XSXr; do
  row "run 2026-11-08-9-micro-optloops, v423/$c" "micro/opt_loops.c" "$O/2026-11-08-9-micro-optloops/out/v423/$c" corpus/micro/opt_loops.c
done
wait
for f in "${LT:?}"/*; do [ -f "$f" ] && cat "$f"; done
rm -rf -- "${LT:?}"
