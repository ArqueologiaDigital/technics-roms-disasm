#!/bin/sh
# Rebuild hdae5000_v1_15i/ from scratch: the porting tool's passes and the hand edits of this
# folder, in the order they ran.  Run from anywhere; it works in the repo root.  It deletes
# and re-creates hdae5000_v1_15i/*.s (the committed images/ stay).
set -e
cd "$(dirname "$0")/../../.."
P="python3 scripts/tools/port_hdae5000_version.py"
E=notes/hdae5000-versions-2026-10-24/port-edits-v1_15i
rm -f -- hdae5000_v1_15i/*.s hdae5000_v1_15i/hdae5000.ld hdae5000_v1_15i/shared/event_codes.s
rmdir hdae5000_v1_15i/shared 2>/dev/null || true
rm -f -- hdae5000_v1_15i/includes/generated/*.bin
rmdir hdae5000_v1_15i/includes/generated hdae5000_v1_15i/includes 2>/dev/null || true
mv hdae5000_v1_15i/images "${TMPDIR:?}/replay_v1_15i_images.$$"
rmdir hdae5000_v1_15i
$P init v1_15i --from v2_01i
mv "${TMPDIR:?}/replay_v1_15i_images.$$" hdae5000_v1_15i/images
python3 scripts/build/hdae5000_images.py build >/dev/null
python3 $E/00_no_filepanel_picture.py
python3 $E/01_string_aliases_as_labels.py        # on the near-pristine v2.01i copy, where the offsets hold
python3 $E/02_boot_splash_picture.py
$P strings v1_15i | tail -1
$P uitables v1_15i | tail -1
python3 $E/03_absent_object_ids.py
# the hand edits 04..09 (removals first, so that no pass aligns code the target lacks)
for s in $(ls $E | grep -E '^0[4-9][a-z]?_.*\.py$' | LC_ALL=C sort); do
  python3 $E/$s
done
for r in 1 2 3; do
  $P afix v1_15i | tail -1
  $P code v1_15i --anchored | grep -v skipped | tail -1
  $P strings v1_15i | tail -1
done
$P afix v1_15i | tail -1
# the hand edits 10..89, made on the tree the passes above leave, then the passes again
for s in $(ls $E | grep -E '^[1-8][0-9][a-z]?_.*\.py$' | LC_ALL=C sort); do
  python3 $E/$s
done
for r in 1 2; do
  $P afix v1_15i | tail -1
  $P code v1_15i --anchored | grep -v skipped | tail -1
  $P strings v1_15i | tail -1
done
$P afix v1_15i | tail -1
# the clean-ups 90..99 (comments, labels and constants the passes leave; the zero tail)
for s in $(ls $E | grep -E '^9[0-9][a-z]?_.*\.py$' | LC_ALL=C sort); do
  python3 $E/$s
done
$P status v1_15i | head -1
