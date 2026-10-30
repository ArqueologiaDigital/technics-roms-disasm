#!/bin/bash
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# regen_sibling_data_and_code.sh -- regenerate the typed data region and the
# program source of an MN10300 sibling (SX-KN6000, SX-KN6500) until they agree.
#
# QUESTION ANSWERED: "after a change to tools/gen_data_s.py, gen_image_s.py or a
# symbol file, what are the committed data and code sources of <model>?"
# gen_data_s.py --profile <model> writes <model>/src/program/data/ (and its
# labels.sym) from the converted code; gen_image_s.py (the model's `make
# program-src`) spells the code's data addresses with labels.sym.  Each reads the
# other's output, so they run alternately until labels.sym stops changing.
#
# RUN (from the model's directory, as its Makefile does):
#     ../kn7000/tools/regen_sibling_data_and_code.sh kn6000 "make program-src UNIDASM=..."
set -e
# (a generator that fails must stop the loop: its output goes through grep / tail)
set -o pipefail
MODEL=$1
PROGRAM_SRC=$2
HERE=$(cd "$(dirname "$0")" && pwd)
LAB=src/program/data/labels.sym
TMP=$(mktemp -d "${TMPDIR:-/tmp}/regen_sibling.XXXXXX")
for round in 1 2 3 4 5 6; do
    # what the code generator reads from the data: its labels, the code addresses its
    # tables name, the ids and the function names
    cat $LAB src/program/data/code_refs.txt src/program/data/gui_code_ids.inc \
        src/program/data/functions.sym > "$TMP/before" 2>/dev/null || true
    python3 "$HERE/gen_data_s.py" --profile "$MODEL" | grep -v "^  " | tail -1
    cat $LAB src/program/data/code_refs.txt src/program/data/gui_code_ids.inc \
        src/program/data/functions.sym > "$TMP/after" 2>/dev/null || true
    n=$(diff "$TMP/before" "$TMP/after" | grep -c '^[<>]' || true)
    echo "round $round $MODEL: $n lines of labels / code refs / ids / function names changed"
    if [ "$n" = 0 ] && [ "$round" -gt 1 ]; then echo "fixpoint after $round rounds"; rm -r -- "${TMP:?}"; exit 0; fi
    $PROGRAM_SRC | tail -1
done
rm -r -- "${TMP:?}"
echo "regen_sibling_data_and_code: no fixpoint after 6 rounds" >&2
exit 1
