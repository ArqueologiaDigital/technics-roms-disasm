#!/bin/bash
# Promote a list of staged sub-CPU C files into the build (all three trees), splice v142, regenerate v141 / v140.
#
# QUESTION ANSWERED / WHY: the promotion sequence of README "Promotion into the build" as one reviewable script
# (no inline loops in the shell).  It only moves files (git mv) and edits the hand sources through the committed
# tools; it deletes nothing.
#
#   bash notes/cc900-c-subcpu-2026-11-16/promote_run.sh LIST.txt SIZES.tsv      (repository root)
#       LIST.txt   staged file names, one per line (promote.py list ...)
#       SIZES.tsv  function<TAB>bytes (promote.py sizes SIZES.tsv)
set -eu
LIST="${1:?list of staged file names}"
SIZES="${2:?sizes tsv}"
while read -r f; do
    [ -n "$f" ] || continue
    for t in v142 v141 v140; do
        if [ -e "$t/subcpu/cc900-staged/$f" ]; then          # a re-run after a stop: already moved
            git mv -- "$t/subcpu/cc900-staged/$f" "$t/subcpu/cc900/$f"
        fi
    done
done < "$LIST"
while read -r f; do
    [ -n "$f" ] || continue
    python3 scripts/tools/cc900_splice.py v142/subcpu "v142/subcpu/cc900/$f" \
        --symbols symbols/subcpu_symbols_reference.txt --sizes "$SIZES"
done < "$LIST"
python3 scripts/generators/create_v141_subcpu_source.py
python3 scripts/generators/create_v140_subcpu_source.py
