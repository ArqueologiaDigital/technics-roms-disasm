#!/bin/sh
# Rebuild hdae5000_v1_10i/ from hdae5000_v1_15i/: the porting tool's passes and the hand edits
# of this folder (README.md).  Run from anywhere; it works in the repo root.
set -e
cd "$(dirname "$0")/../../.."
P="python3 scripts/tools/port_hdae5000_version.py"
E=notes/hdae5000-versions-2026-10-24/port-edits-v1_10i
rm -f -- hdae5000_v1_10i/*.s hdae5000_v1_10i/hdae5000.ld
rmdir hdae5000_v1_10i 2>/dev/null || true
$P init v1_10i --from v1_15i
python3 $E/00_tail_room.py
$P strings v1_10i | tail -1
$P uitables v1_10i | tail -1
python3 $E/03_absent_object_ids.py
for s in $(ls $E | grep -E '^0[4-9][a-z]?_.*\.py$' | LC_ALL=C sort); do
  python3 $E/$s
done
for r in 1 2 3; do
  $P afix v1_10i | tail -1
  $P code v1_10i --anchored | grep -v skipped | tail -1
  $P strings v1_10i | tail -1
done
for s in $(ls $E | grep -E '^[1-8][0-9][a-z]?_.*\.py$' | LC_ALL=C sort); do
  python3 $E/$s
done
$P afix v1_10i | tail -1
# the clean-ups 90..99 (../port-edits-v1_15i/ has the shared ones; this folder its own)
for s in 92_stale_comments.py 93_ram_numbers.py 96_piled_labels.py 97_unreferenced_orphans.py 98_unused_constants.py; do
  PORT_TREE=hdae5000_v1_10i python3 notes/hdae5000-versions-2026-10-24/port-edits-v1_15i/$s
done
for s in $(ls $E | grep -E '^9[0-9][a-z]?_.*\.py$' | LC_ALL=C sort); do
  python3 $E/$s
done
PORT_TREE=hdae5000_v1_10i python3 notes/hdae5000-versions-2026-10-24/port-edits-v1_15i/99_tail_fill.py
$P status v1_10i | head -1
