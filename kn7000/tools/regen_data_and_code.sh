#!/bin/bash
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# regen_data_and_code.sh -- regenerate the typed data regions and the program
# sources of every program build until they agree.
#
# QUESTION ANSWERED: "after a change to tools/gen_data_s.py or a symbol file,
# what are the committed data and code sources?"  gen_data_s.py writes each
# build's src/<build>/program/data/ (and its labels.sym) from the converted
# code; gen_program_s.py spells the code's data addresses with labels.sym.
# Each reads the other's output, so they are run alternately until no build's
# labels.sym changes (2026-10-29: three rounds).  Needs UNIDASM (MAME's
# unidasm) for gen_program_s.py and a built tree (build/*.labels).
#
# RUN (from kn7000/):  UNIDASM=/path/to/unidasm tools/regen_data_and_code.sh [builds...]
set -e
cd "$(dirname "$0")/.."
BUILDS=${*:-941 b935 b893 sp7001}
TMP=$(mktemp -d "${TMPDIR:-/tmp}/regen_data_and_code.XXXXXX")
dir() { if [ "$1" = 941 ]; then echo src/program/data; else echo "src/$1/program/data"; fi; }
for round in 1 2 3 4 5 6; do
    changed=0
    for b in $BUILDS; do
        [ -f "$(dir $b)/labels.sym" ] && cp "$(dir $b)/labels.sym" "$TMP/$b.before" || : > "$TMP/$b.before"
        python3 tools/gen_data_s.py --profile "$b" | head -1
        n=$(diff "$TMP/$b.before" "$(dir $b)/labels.sym" | grep -c '^[<>]' || true)
        echo "round $round $b: $n labels changed"
        [ "$n" -gt 0 ] && changed=1
    done
    if [ $changed = 0 ]; then echo "fixpoint after $round rounds"; rm -r -- "${TMP:?}"; exit 0; fi
    for b in $BUILDS; do python3 tools/gen_program_s.py --profile "$b" | head -1; done
done
rm -r -- "${TMP:?}"
echo "regen_data_and_code: no fixpoint after 6 rounds" >&2
exit 1
