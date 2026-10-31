#!/bin/bash
# c_divergence_stamp_proof.sh -- with apply_c_divergence.py's stamps untracked, does a fresh clone build the
# ported main programs (v7, v6, v5) byte-identical, does a second build with no change leave every patched bin
# alone, and does a MISSING stamp cost only a recompile, never a second patch?
#
#   notes/media-cleanup-2026-10-31/probes/c_divergence_stamp_proof.sh SCRATCH [BRANCH]
#
# SCRATCH: empty or absent directory under ~/compartilhado/tmp/ (never /tmp).  The v6/v5 reference images are
# copied by the Makefile from the private romset (KN5000_V6_REF / KN5000_V5_REF), SHA-1 checked.
#   1  clone BRANCH; no *.bin.patched is tracked; build the three ROMs; each = its reference
#   2  build again: the ROMs are up to date, and running the patch steps by hand skips every bin
#   3  delete the stamps of the three bins with the most relocations (one per tree), touch nothing else:
#      the patch step must recompile exactly those, and the ROMs stay byte-identical
#   4  delete EVERY stamp (what `git pull` of this change does in an older checkout, whose bins are patched):
#      the patch steps recompile all and the ROMs stay byte-identical
#   5  negative control: the patcher as it was at 43242446d, run on a patched bin whose stamp is missing,
#      changes that bin (the double patch this change prevents); the current patcher then heals it
set -u
SCRATCH=${1:?usage: c_divergence_stamp_proof.sh SCRATCH [BRANCH]}
HERE=$(cd "$(dirname "$0")/../../.." && pwd)
BRANCH=${2:-$(git -C "$HERE" rev-parse --abbrev-ref HEAD)}
CLONE=$SCRATCH/clone
fail() { echo "FAIL: $*"; exit 1; }
[ -e "$CLONE" ] && fail "$CLONE exists; start from an empty SCRATCH"
mkdir -p "$SCRATCH"
git clone -q -b "$BRANCH" "$(git -C "$HERE" rev-parse --git-common-dir)" "$CLONE" || fail clone
cd "$CLONE" || exit 2
echo "clone: $(git log -1 --format='%h %s')"
ROMS="rebuilt_ROMs/kn5000_v7_program.llvm.rom rebuilt_ROMs/kn5000_v6_program.llvm.rom rebuilt_ROMs/kn5000_v5_program.llvm.rom"
REFS="original_ROMs/kn5000_v6_program.rom original_ROMs/kn5000_v5_program.rom"
same() {
  for v in v7 v6 v5; do cmp -s rebuilt_ROMs/kn5000_${v}_program.llvm.rom original_ROMs/kn5000_${v}_program.rom \
    || fail "$1: $v differs from its reference"; done
  echo "   $1: v7, v6, v5 byte-identical to their references"
}
steps() { make -s v7-extract-bins v6-c-bins v5-c-bins 2>&1 | grep -a 'apply_c_divergence '; }

n=$(git ls-files '*.bin.patched' | wc -l); [ "$n" -eq 0 ] || fail "$n stamps tracked"
echo "== 1 fresh build (0 stamps tracked)"
make -j8 $REFS $ROMS > "$SCRATCH/1.log" 2>&1 || { tail "$SCRATCH/1.log"; fail "build 1"; }
grep -a 'apply_c_divergence ' "$SCRATCH/1.log" | sed 's/^/   /'
same 1
echo "== 2 second build, no change"
make -q $ROMS && echo "   make -q: ROMs up to date" || fail "2: make -q says out of date"
steps | sed 's/^/   /'
steps | grep -v ' 0 recompiled first .* 0 patched' && fail "2: a patch step touched a bin"
make -s $ROMS > /dev/null 2>&1; same 2
echo "== 3 three stamps deleted"
for v in v7 v6 v5; do
  b=$(python3 -c "import json,sys; d=json.load(open('$v/maincpu/includes/${v}_c_divergence.json')); print(max(d, key=lambda k: len(d[k].get('reloc', []))))")
  echo "   $v: $b ($(python3 -c "import json; print(len(json.load(open('$v/maincpu/includes/${v}_c_divergence.json'))['$b']['reloc']))") relocations)"
  rm -f -- "$v/maincpu/includes/generated/${b:?}.patched"
done
steps | sed 's/^/   /'
make -s $ROMS > /dev/null 2>&1; same 3
echo "== 4 every stamp deleted (an older checkout after pulling this change)"
rm -f -- v7/maincpu/includes/generated/*.bin.patched v6/maincpu/includes/generated/*.bin.patched \
  v5/maincpu/includes/generated/*.bin.patched
steps | sed 's/^/   /'
make -s $ROMS > /dev/null 2>&1; same 4
echo "== 5 negative control: the old patcher"
B=v6/maincpu/includes/generated/naka_style_bitmaps.bin
before=$(sha256sum < $B)
# (it finds the tree from its own path, so it runs from scripts/build/ and is removed again)
git show 43242446d:scripts/build/apply_c_divergence.py > scripts/build/apply_c_divergence_old.py
rm -f -- "$B.patched"
python3 scripts/build/apply_c_divergence_old.py v6 | sed 's/^/   old: /'
rm -f -- scripts/build/apply_c_divergence_old.py
[ "$(sha256sum < $B)" != "$before" ] && echo "   old patcher changed $B: patched twice" || fail "5: the control saw no double patch"
steps | grep -a ' v6:' | sed 's/^/   new: /'
[ "$(sha256sum < $B)" = "$before" ] || fail "5: the current patcher did not restore $B"
make -s $ROMS > /dev/null 2>&1; same 5
st=$(git status --porcelain); [ -z "$st" ] || { echo "$st" | head; fail "git status not clean"; }
echo "   git status --porcelain: empty"
echo "PASS"
