#!/bin/bash
# Promote staged sub-CPU C whose functions carry cc900-data (jump-table switches): the splice checks each body and
# its table against the built image and splices both (cc900_splice.py --v423).
#
# QUESTION ANSWERED / WHY: promote_run.sh's sequence with the build as the size source, which the table splice
# needs.  Steps: git mv into cc900/ in the three trees; `make` the v142 payload so the V4.23 cache holds the new
# files; splice v142; regenerate v141 / v140.  It moves files and deletes nothing.
#
#   bash notes/cc900-c-subcpu-2026-11-16/promote_v423_run.sh LIST.txt WORKDIR      (repository root)
set -eu
LIST="${1:?list of staged file names}"
WORK="${2:?scratch directory for the generated bodies}"
mkdir -p "$WORK"
while read -r f; do
    [ -n "$f" ] || continue
    for t in v142 v141 v140; do
        if [ -e "$t/subcpu/cc900-staged/$f" ]; then
            git mv -- "$t/subcpu/cc900-staged/$f" "$t/subcpu/cc900/$f"
        fi
    done
done < "$LIST"
make -j2 rebuilt_ROMs/kn5000_subprogram_v142.llvm.rom
while read -r f; do
    [ -n "$f" ] || continue
    python3 scripts/tools/cc900_splice.py v142/subcpu "v142/subcpu/cc900/$f" \
        --symbols symbols/subcpu_symbols_reference.txt --v423 build/cc900-v423 --work "$WORK"
done < "$LIST"
python3 scripts/generators/create_v141_subcpu_source.py
python3 scripts/generators/create_v140_subcpu_source.py
