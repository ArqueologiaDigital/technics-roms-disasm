#!/bin/bash
# Round-trip the MN10300 encoder against MAME unidasm over the KN7000 program
# ROM's code region 1. Requires g++/python3, a unidasm with the mn10300 arch,
# and the extracted kn7000_program.rom.
#
#   ROM=/path/kn7000_program.rom UNIDASM=/path/unidasm ./validate_asm.sh
set -euo pipefail
cd "$(dirname "$0")"

ROM="${ROM:-../baserom/kn7000_program.rom}"
UNIDASM="${UNIDASM:-../../mame-sony-video/unidasm}"
BASE=0x48400000
START=0x80
END=0x186000

tmp="$(mktemp)"; trap 'rm -f "$tmp"' EXIT
BASEPC="$(printf '0x%x' $((BASE + START)))"    # unidasm needs hex -basepc
"$UNIDASM" "$ROM" -arch mn10300 -basepc "$BASEPC" -skip $START \
    -count $((END - START)) > "$tmp"
python3 validate_asm.py "$tmp" "$ROM"
