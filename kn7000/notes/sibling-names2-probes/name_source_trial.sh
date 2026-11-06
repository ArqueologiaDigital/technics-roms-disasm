#!/bin/bash
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# name_source_trial.sh SCRATCH B SOURCE [port_names_by_alignment.py options]
#
# Question: "how many names would port_names_by_alignment.py carry onto sibling B from
# SOURCE, and how often is it wrong where the answer is known?"  SOURCE is
#   kn7000  KN7000 941, exactly as B's `make aligned-names` runs it (the output is seeded
#           with B's committed <B>_aligned.sym, so its names count as unnamed again)
#   b893    KN7000 893 (v1.3), with its own and ported names (kn7000_b893*.sym)
#   kn6000 / kn6500 / kn2400   another sibling, with its reflection, hand, ported,
#           aligned and MILK-function names; B's own aligned names are B names here
# Nothing tracked is written: the .sym, maps and report go to SCRATCH/trial-<B>-<SOURCE>*.
# Needs the reference images (make -C <model> baserom; make -C kn7000 baserom) and unidasm
# (UNIDASM, default /home/fsanches/compartilhado/mame-sony-video/unidasm).  Run from the
# repo root.  Extra options go to the tool (e.g. --no-pointers, --no-ram-runs, --table-agree -1).
set -e
S=$1; B=$2; SRC=$3; shift 3
U=${UNIDASM:-/home/fsanches/compartilhado/mame-sony-video/unidasm}
R=$(pwd)
mkdir -p "$S"
code() { sed -n 's/^CODE *:= *//p' "$R/$1/Makefile"; }
base() { sed -n 's/^BASE *:= *//p' "$R/$1/Makefile"; }
BCODE=$(code "$B" | sed 's/--code/--b-code/g')
K=$R/kn7000
OUT=$S/trial-$B-$SRC
BSYM="$B.sym ${B}_manual.sym ${B}_ported.sym src/program/data/functions.sym ${B}_ram.sym"
case $SRC in
  kn7000)
    A="--a-rom $K/baserom/kn7000_program.rom --a-code 0x80:0x186000 --a-code 0x3b8fd1:0x3f6f01:0x4c000000
       --a-sym $K/kn7000_manual.sym $K/kn7000_exports_from_942.sym $K/kn7000.sym"
    cp "$R/$B/${B}_aligned.sym" "$OUT.sym" ;;
  b893)
    A="--a-rom $K/baserom/kn7000_program_b893.rom --a-code 0x80:0x1846a0 --a-code 0x3b76b1:0x3f55cf:0x4c000000
       --a-sym $K/kn7000_b893_own.sym $K/kn7000_b893.sym $K/kn7000_b893_manual.sym $K/kn7000_b893_exports.sym
       $K/kn7000_b893_bycode.sym --a-label KN7000_893"
    BSYM="$BSYM ${B}_aligned.sym"; rm -f -- "$OUT.sym" ;;
  kn6000|kn6500|kn2400)
    A="--a-rom $R/$SRC/baserom/${SRC}_program.rom --a-base $(base "$SRC") $(code "$SRC" | sed 's/--code/--a-code/g')
       --a-sym $R/$SRC/$SRC.sym $R/$SRC/${SRC}_manual.sym $R/$SRC/${SRC}_ported.sym $R/$SRC/${SRC}_aligned.sym
       $R/$SRC/src/program/data/functions.sym --a-label ${SRC^^}"
    BSYM="$BSYM ${B}_aligned.sym"; rm -f -- "$OUT.sym" ;;
  *) echo "unknown SOURCE $SRC" >&2; exit 2 ;;
esac
cd "$R/$B"
# shellcheck disable=SC2086
python3 ../kn7000/tools/port_names_by_alignment.py $A --b-rom baserom/${B}_program.rom --b-base "$(base "$B")" $BCODE \
  --b-sym $BSYM --b-labels src/labels.inc --out "$OUT.sym" --ram-map "$OUT-ram.tsv" --routine-map "$OUT-routines.tsv" \
  --report "$OUT-report.md" --unidasm "$U" --cache "$S/cache" --title "trial: $B from $SRC" "$@"
