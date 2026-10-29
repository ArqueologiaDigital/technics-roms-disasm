#!/bin/bash
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# regen_sibling_data_and_code.sh -- regenerate the typed data region and the
# program source of MN10300 sibling images (../kn2400, ...) until they agree.
#
# QUESTION ANSWERED: "after a change to tools/gen_data_s.py, tools/gen_image_s.py
# or a symbol file, what are a sibling tree's committed src/data/ and
# src/program.s?"  gen_data_s.py --profile <model> writes <model>/src/data/ (and
# its labels.sym) from the converted code; gen_image_s.py (the model's `make
# program-src`) names the code's data addresses with labels.sym.  Each reads the
# other's output, so they run alternately until labels.sym stops changing.
# The twin of tools/regen_data_and_code.sh, which does this for the KN7000's builds.
#
# RUN (from anywhere):  UNIDASM=/path/to/unidasm kn7000/tools/regen_sibling_data_and_code.sh kn2400
# Pass CA_MIRROR=... in the environment when the model's Makefile default does not
# reach the mirror (worktrees).
set -e
TOOLS=$(cd "$(dirname "$0")" && pwd)
REPO=$(dirname "$(dirname "$TOOLS")")
: "${UNIDASM:?set UNIDASM to the MAME unidasm}"
MODELS="${*:?name the sibling models, e.g. kn2400}"
TMP=$(mktemp -d "${TMPDIR:-/tmp}/regen_sibling.XXXXXX")
for round in 1 2 3 4 5 6; do
    changed=0
    for m in $MODELS; do
        L="$REPO/$m/src/data/labels.sym"
        [ -f "$L" ] && cp "$L" "$TMP/$m.before" || : > "$TMP/$m.before"
        python3 "$TOOLS/gen_data_s.py" --profile "$m" | head -1
        n=$(diff "$TMP/$m.before" "$L" | grep -c '^[<>]' || true)
        echo "round $round $m: $n labels changed"
        if [ "$n" -gt 0 ] || [ "$round" = 1 ]; then
            changed=1
            make -s -C "$REPO/$m" UNIDASM="$UNIDASM" ${CA_MIRROR:+CA_MIRROR="$CA_MIRROR"} program-src | head -1
        fi
    done
    if [ $changed = 0 ]; then echo "fixpoint after $round rounds"; rm -r -- "${TMP:?}"; exit 0; fi
done
rm -r -- "${TMP:?}"
echo "regen_sibling_data_and_code: no fixpoint after 6 rounds" >&2
exit 1
