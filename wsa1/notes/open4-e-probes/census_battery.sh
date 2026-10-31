#!/bin/bash
# census_battery.sh OUTDIR -- run, read-only, every repo census that reads the KN5000 sub-CPU
# sources, and keep each one's output in OUTDIR.  Run it before and after a change that MOVES
# source text (the A4 split of v142/subcpu) and diff the two directories: a tool that silently
# stopped seeing a file shows up as a changed count.  Run from the repo root on a built tree
# (`make gate` first).  It writes no snapshot and no badge.
set -e
OUT=${1:?usage: census_battery.sh OUTDIR}
mkdir -p "$OUT"
python3 scripts/analysis/kn5000_source_coverage.py                         > "$OUT/source_coverage.txt"
python3 scripts/analysis/data_incbin_census.py                             > "$OUT/data_incbin.txt"
python3 scripts/analysis/data_range_census.py --images v142,v141,v140,subboot --json "$OUT/data_range.json" > "$OUT/data_range.txt"
python3 scripts/analysis/doc_quality_census.py --json "$OUT/doc_quality.json" > "$OUT/doc_quality.txt"
DISPATCH_CENSUS_DIR="$OUT/dispatch-work" python3 scripts/analysis/dispatch_table_census/build_maps.py > "$OUT/dispatch_maps.txt"
DISPATCH_CENSUS_DIR="$OUT/dispatch-work" python3 scripts/analysis/dispatch_table_census/census.py --json "$OUT/dispatch.json" --report > "$OUT/dispatch.txt"
# claims_lint.py is not run: on 2026-10-31 it crashed before any change (IsADirectoryError on scripts/renaming/naming_pipeline)
echo "battery written to $OUT"
