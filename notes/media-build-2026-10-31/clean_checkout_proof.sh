#!/bin/bash
# clean_checkout_proof.sh -- does a clean checkout build every media conversion from the committed media
# alone, and do the gates pass and reproduce every converter output byte for byte?
#
#   notes/media-build-2026-10-31/clean_checkout_proof.sh SCRATCH [BRANCH]
#
# SCRATCH is an empty-or-absent directory (use ~/compartilhado/tmp/<something>, never /tmp); BRANCH
# defaults to the current branch of the repository this script lives in.  Phases:
#   A  clone BRANCH into SCRATCH/clone and build every converter output (MEDIA_TARGETS below) with no
#      reference image reachable: PROJECTS_ROOT and every romset/dump override point at an empty
#      directory, so any rule that needed a reference would fail.  SHA-256 of every output -> A.sha256.
#   B  copy nothing by hand; run every gate with the real references (the Makefiles copy them, SHA-1
#      checked, only where the byte compare needs them): make gate gate-wsa1 gate-floppy gate-kn7000
#      gate-kn6000 gate-kn6500 gate-kn2400 gate-hdsx3 and make -C kn7000 symbols-check.
#   C  `git status --porcelain` must be empty: no tracked file changed, nothing untracked and unignored.
#   D  delete every converter output, make every tracked file read-only (a converter that writes a
#      tracked file then fails), rerun the gates, and compare the outputs' SHA-256 with A.
#   E  the floppy media are read from <model>/<disk>/media/, not from the reference's extraction:
#      delete the extracted copies of every media file from floppy/build/ and rebuild the disks.
# Exit 0 only when every phase passes.  Logs in SCRATCH/logs/.
set -u
SCRATCH=${1:?usage: clean_checkout_proof.sh SCRATCH [BRANCH]}
HERE=$(cd "$(dirname "$0")/../.." && pwd)
BRANCH=${2:-$(git -C "$HERE" rev-parse --abbrev-ref HEAD)}
C=$HOME/compartilhado
mkdir -p "$SCRATCH/logs" "$SCRATCH/empty"
CLONE=$SCRATCH/clone
LOG=$SCRATCH/logs
EMPTY=$SCRATCH/empty
fail() { echo "FAIL: $*"; exit 1; }

[ -e "$CLONE" ] && fail "$CLONE exists; start from an empty SCRATCH"
git clone -q -b "$BRANCH" "$(git -C "$HERE" rev-parse --git-common-dir)" "$CLONE" || fail "clone"
cd "$CLONE" || exit 2
echo "clone: $(git log -1 --format='%h %s')"

# Every converter output of the KN5000, SX-WSA1R, SX-KN7000 and MN10300-sibling trees (the floppy media
# are read directly; phase E covers them).
LLVM="LLVM_BIN=$C/llvm-project/build/bin"
media_targets() {
  make -s $LLVM "$@" media tabledata-images hdae5000-images \
    && make -s -C wsa1 "$@" $(cd wsa1 && python3 scripts/build/wsa1_bitmaps.py outputs) \
    && make -s -C kn7000 "$@" build/table_png/.stamp build/ic18_png/.stamp build/bitmaps/941/.stamp \
      build/bitmaps/sp7001/.stamp build/bitmaps/b935/.stamp build/bitmaps/b893/.stamp \
      build/wav_pcm/main.done build/wav_pcm/sub.done \
    && for m in kn2400 kn6000 kn6500 hdsx3; do make -s -C $m "$@" build/bitmaps/.stamp || return 1; done
}
OUTPUT_GLOBS="v*/maincpu/images/*.bin table_data/images/FTBMP0?.BMP hdae5000/images/HDAE5000_Bitmap_Button01.bin
  table_data/images/Wallpaper_*.bin v*/maincpu/includes/generated/pictures/*.inc waveform/build/pcm/*.pcm
  table_data/includes/generated/*.bin hdae5000*/includes/generated/HDAE5000_*.bin
  wsa1/prom_*/images/*.bin wsa1/prom_b/images/fonts/*.bin kn7000/build/table_png/*/*.bin kn7000/build/ic18_png/*.bin
  kn7000/build/bitmaps/*/*.bin kn7000/build/wav_pcm/*/*.pcm kn2400/build/bitmaps/*.bin kn6000/build/bitmaps/*.bin
  kn6500/build/bitmaps/*.bin hdsx3/build/bitmaps/*.bin"
hash_outputs() {   # every output that is not a tracked file (the palettes in images/ are tracked data)
  for f in $OUTPUT_GLOBS; do [ -f "$f" ] && ! git ls-files --error-unmatch "$f" >/dev/null 2>&1 && sha256sum "$f"; done | sort -k2
}

echo "== A: converter outputs with no reference reachable"
NOREF="PROJECTS_ROOT=$EMPTY ROMSET_DIR=$EMPTY CA_MIRROR=$EMPTY SOFTLIST_DIR=$EMPTY EXTRACT_DIR=$EMPTY DISKS_DIR=$EMPTY
  PICTURE_REF=$EMPTY/none WAVE_ROMSET=$EMPTY SP7001_UPDATES=$EMPTY UNIDASM=$EMPTY/none"
media_targets $NOREF > "$LOG/A.log" 2>&1 || { tail -20 "$LOG/A.log"; fail "phase A: a media conversion needed something not committed"; }
ls original_ROMs/kn5000_v8_program.rom kn7000/baserom/*.rom 2>/dev/null | grep . && fail "phase A copied a reference"
hash_outputs > "$SCRATCH/A.sha256"
echo "   $(wc -l < "$SCRATCH/A.sha256") outputs built, no reference image present"

OV="ROMSET_DIR=$C/technics_romsets/kn7000 CA_MIRROR=$C/ca-software-mirror/files SOFTLIST_DIR=$C/technics_romsets/floppy-rebuild-2026-10-18/roms
  SP7001_UPDATES=$C/nonfree/kn7000-sp7001/sp7001-kn7000-updates UNIDASM=$C/mame-sony-video/unidasm EXTRACT_DIR=$C/kn7000_extraction
  DISKS_DIR=$C/KN7000 PICTURE_REF=$C/technics_roms/roms/kn7000/real_dump_v1.3_b893/pass2-run1/IC19.BIN"
gates() {   # $1 = log prefix
  local rc=0
  rm -f -- kn7000/build/*.labels
  for g in gate gate-wsa1 gate-floppy gate-kn7000 gate-kn6000 gate-kn6500 gate-kn2400 gate-hdsx3; do
    make $g $OV > "$LOG/$1-$g.log" 2>&1; r=$?
    echo "   make $g: exit $r  $(grep -h 'PASS: every rebuilt ROM\|reproduced byte-for-byte' "$LOG/$1-$g.log" | tail -1)"
    [ $r -eq 0 ] || rc=1
  done
  make -C kn7000 symbols-check $OV > "$LOG/$1-symbols-check.log" 2>&1; r=$?
  echo "   make -C kn7000 symbols-check: exit $r"; [ $r -eq 0 ] || rc=1
  return $rc
}

echo "== B: every gate, references copied by the Makefiles"
gates B || fail "phase B gates"

echo "== C: the checkout is clean"
st=$(git status --porcelain)
[ -z "$st" ] || { echo "$st" | head; fail "phase C: git status not clean"; }
echo "   git status --porcelain: empty"

echo "== D: delete every converter output, tracked files read-only, gates again"
for f in $OUTPUT_GLOBS; do [ -f "$f" ] && ! git ls-files --error-unmatch "$f" >/dev/null 2>&1 && rm -f -- "$f"; done
rm -f -- v*/maincpu/includes/generated/pictures/.stamp waveform/build/pcm/.built kn7000/build/table_png/.stamp \
  kn7000/build/ic18_png/.stamp kn7000/build/bitmaps/*/.stamp kn7000/build/wav_pcm/*.done \
  kn2400/build/bitmaps/.stamp kn6000/build/bitmaps/.stamp kn6500/build/bitmaps/.stamp hdsx3/build/bitmaps/.stamp
left=$(hash_outputs | wc -l); [ "$left" -eq 0 ] || fail "phase D: $left outputs survived the delete"
# Every tracked file read-only, except two pre-existing kinds of tracked build state that are not media
# conversions (both listed in the lane README's open items):
#  - the MN10300 trees' src/constants.inc, which their Makefiles regenerate from the reference ROM
#    (gen_constants.py) whenever the reference copy is newer -- always, in a fresh clone;
#  - */maincpu/includes/generated/*.patched, apply_c_divergence.py's idempotency stamps (80, swept into git
#    by an unrelated commit).  Untracking them would make git delete them in every existing checkout, and a
#    patched bin without its stamp is patched a second time.
git ls-files -z | grep -zv '^\(kn7000\|kn2400\|kn6000\|kn6500\|hdsx3\)/src/constants\.inc$' \
  | grep -zv '/maincpu/includes/generated/.*\.patched$' | xargs -0 chmod a-w
gates D; rcD=$?
git ls-files -z | xargs -0 chmod u+w
[ $rcD -eq 0 ] || fail "phase D gates (a converter writing a tracked file fails here)"
# the same files as phase A (the gates also build outputs that are not media conversions)
(cd "$CLONE" && sed 's/^[0-9a-f]*  //' "$SCRATCH/A.sha256" | xargs sha256sum | sort -k2) > "$SCRATCH/D.sha256"
diff "$SCRATCH/A.sha256" "$SCRATCH/D.sha256" > "$LOG/A-vs-D.diff" || { head "$LOG/A-vs-D.diff"; fail "phase D: outputs differ from phase A"; }
echo "   $(wc -l < "$SCRATCH/D.sha256") outputs rebuilt, SHA-256 identical to phase A"

echo "== E: floppy media come from git"
n=0
for m in kn5000 wsa1 kn6000 kn7000; do
  for d in floppy/$m/*/media; do
    disk=$(basename "$(dirname "$d")")
    for f in "$d"/*; do [ -f "floppy/build/$m/$disk/$(basename "$f")" ] && rm -f -- "floppy/build/$m/$disk/$(basename "$f")" && n=$((n+1)); done
    rm -f -- "floppy/build/$m/$disk.o" "floppy/build/$m/$disk.img"
  done
done
make -C floppy gate $OV > "$LOG/E-gate-floppy.log" 2>&1 || fail "phase E: a disk needed the reference's copy of a media file"
echo "   $n extracted copies deleted; $(grep -c 'reproduced byte-for-byte' "$LOG/E-gate-floppy.log") models reproduced byte-for-byte"
echo "PASS: clean checkout of $BRANCH"
