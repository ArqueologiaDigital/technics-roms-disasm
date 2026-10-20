#!/bin/bash
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# run_test.sh MAME_BINARY OUTDIR [--fast] [--no-prefill] [--loader-test N] [--safe|--ic19|--wave|--survey|--survey2]
# [--bios NAME] [--rompath DIR] -- end to end in MAME, then verify_dump.py.
#   Builds KN7LOAD.CNV (on a floppy the KN7000 formatted) and KN7APP.BIN (put in the root of a copy of the
#   real KN7000's SD card), boots the kn7000 with both, fills the undumped ROMs with test data (prefill.lua),
#   runs DISK MENU > STYLE CONVERT > OK, waits until the dumper has finished and checks every file it wrote.
#   --fast: every ROM cut to 64 KB (a quick check of the whole path; the verifier then checks prefixes).
#   --loader-test N: the loader with its LoaderTest word set to N, which switches searches off (1 file code
#     signatures, 2 fmm tables, 4 raw sectors, 8 SD folders, 0x10 build number, 0x20 ms counter), to run the
#     fallbacks a firmware we have never seen might need; the verifier then allows missing long names/builds.
#   --safe: the SAFE build (build/safe/KN7APP.BIN: program, table, IC21; 8.3 files in the root, nothing else).
#   --ic19: the IC19 build (build/ic19/KN7APP.BIN: the picture window alone, the same way).
#   --wave: the WAVE build (build/wave/KN7APP.BIN: the four wave ROMs alone, the same way).
#   --survey: the SURVEY build (build/survey/KN7APP.BIN: six 8 MB CPU windows, where the rhythm ROM may be).
#   --survey2: the SURVEY2 build (build/survey2/KN7APP.BIN: Survey2Table's 14 windows). Its test data is
#     prefill_survey2.lua, installed after the boot instead of prefill.lua; it also saves what the CPU reads in
#     the three RAM windows at the end, and the words written there during the run (ref_*.bin, writes_*.txt).
#   --bios NAME: passed to MAME as -bios NAME (the overlay's v13 is program 893, the owner's instrument).
#   --rompath DIR: MAME's ROM path (default ~/compartilhado/technics_romsets; the overlay binary needs its own
#     roms/ folder, ~/compartilhado/kn7000-emulator/roms).
#   MAME_BINARY: a build of upstream MAME with the kn7000 driver (e.g. the technics-kn-flop-rebuild worktree's),
#     or the kn7000_mame overlay (~/compartilhado/kn7000-emulator/kn7000).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; SRC="$HERE/.."
BIN="$(readlink -f "$1")"; O="$(mkdir -p "$2" && cd "$2" && pwd)"; shift 2
FAST=0; PREFILL=1; LTEST=0; SAFE=0; BIOS=(); ROMPATH="$HOME/compartilhado/technics_romsets"
while [ $# -gt 0 ]; do
  case "$1" in --fast) FAST=1;; --no-prefill) PREFILL=0;; --loader-test) LTEST="$2"; shift;; --safe) SAFE=1;;
    --ic19) SAFE=2;; --wave) SAFE=3;; --survey) SAFE=4;; --survey2) SAFE=5;;
    --bios) BIOS=(-bios "$2"); shift;; --rompath) ROMPATH="$(readlink -f "$2")"; shift;; esac
  shift
done
MKAPP=(); [ "$SAFE" = 1 ] && MKAPP=(--options 0x303E0 --name "KN7000 ROM DUMPER 1.0 SAFE")
[ "$SAFE" = 2 ] && MKAPP=(--options 0x301FF --name "KN7000 ROM DUMPER 1.0 IC19")
[ "$SAFE" = 3 ] && MKAPP=(--options 0x3021F --name "KN7000 ROM DUMPER 1.0 WAVE")
[ "$SAFE" = 4 ] && MKAPP=(--options 0x703C0 --name "KN7000 ROM DUMPER 1.0 SURVEY")
[ "$SAFE" = 5 ] && MKAPP=(--options 0xB0000 --name "KN7000 ROM DUMPER 1.0 SURVEY2")
TOOLS="$HOME/compartilhado/kn7000_mame/tools/floppy-images"
make -s -C "$SRC" OUT="$O/build" FLOPPY_TOOLS="$TOOLS"
FLOPPY="$O/build/kn7load_floppy.img"
if [ "$LTEST" != 0 ]; then              # patch LoaderTest (its address from the map) and make a floppy of that
  python3 -I - "$O/build/loader.map" "$O/build/KN7LOAD.CNV" "$O/build/KN7LOAD_TEST.CNV" "$LTEST" <<'EOF'
import re, struct, sys
m, src, dst, n = sys.argv[1:]
a = int(re.search(r'0x([0-9A-Fa-f]+)\s+LoaderTest\b', open(m).read()).group(1), 16) - 0x502B8000
b = bytearray(open(src, 'rb').read()); assert b[a:a + 4] == bytes(4)
b[a:a + 4] = struct.pack('<I', int(n, 0)); open(dst, 'wb').write(b)
EOF
  mkdir -p "$O/build/ltest" && cp "$O/build/KN7LOAD_TEST.CNV" "$O/build/ltest/KN7LOAD.CNV"
  python3 -I "$SRC/mkfloppy.py" "$O/build/kn7load_test_floppy.img" KN7LOADER "$TOOLS" "$O/build/ltest/KN7LOAD.CNV"
  FLOPPY="$O/build/kn7load_test_floppy.img"
fi
APP="$O/build/KN7APP.BIN"; [ "$SAFE" = 1 ] && APP="$O/build/safe/KN7APP.BIN"
[ "$SAFE" = 2 ] && APP="$O/build/ic19/KN7APP.BIN"
[ "$SAFE" = 3 ] && APP="$O/build/wave/KN7APP.BIN"
[ "$SAFE" = 4 ] && APP="$O/build/survey/KN7APP.BIN"
[ "$SAFE" = 5 ] && APP="$O/build/survey2/KN7APP.BIN"
if [ "$FAST" = 1 ]; then
  sed -e 's/, 0x200000, /, 0x10000, /' -e 's/, 0x1000000, /, 0x10000, /' -e 's/, 0x800000, /, 0x10000, /' \
      -e 's/, 0x118000, /, 0x10000, /' -e 's/, 0x40000, /, 0x10000, /' \
      "$SRC/romdump.s" > "$O/build/romdump_fast.s"
  cp "$SRC/kn7cnv.inc" "$SRC/romdump.inc" "$O/build/"
  python3 "$SRC/../xapasm.py" "$O/build/romdump_fast.s" -o "$O/build/fast.bin" -m "$O/build/fast.map" > /dev/null
  python3 -I "$SRC/mkapp.py" "$O/build/fast.bin" "$O/build/KN7APP_FAST.BIN" "${MKAPP[@]}" > /dev/null
  APP="$O/build/KN7APP_FAST.BIN"
fi
cp "$HOME/compartilhado/kn7000-emulator/sdcard_from_real_kn7000.img" "$O/sd.img"; chmod u+w "$O/sd.img"
python3 "$SRC/../sd_addfile.py" "$O/sd.img" 'KN7APP.BIN' "$APP" > /dev/null
cp "$FLOPPY" "$O/floppy.img"
P=""; [ "$PREFILL" = 1 ] && [ "$SAFE" != 5 ] && P="lua dofile(\"$HERE/prefill.lua\")"
PL=""; [ "$PREFILL" = 1 ] && [ "$SAFE" = 5 ] && PL="lua dofile(\"$HERE/prefill_survey2.lua\")"
sed -e "s|@PREFILL@|$P|" -e "s|@PREFILL_LATE@|$PL|" -e "s|@OUT@|$O|g" "$HERE/dump.cmd.in" > "$O/cmd.txt"
echo exit >> "$O/cmd.txt"; rm -f -- "${O:?}/cmd.txt.log"
mkdir -p "$O/snap" "$O/cfg" "$O/nv"
cd "$(dirname "$BIN")" && REMOTE_CMD="$O/cmd.txt" DISPLAY="${DISPLAY:-:0}" timeout 10800 "$BIN" kn7000 "${BIOS[@]}" \
  -rompath "$ROMPATH" -window -nothrottle -skip_gameinfo \
  -cfg_directory "$O/cfg" -nvram_directory "$O/nv" -snapshot_directory "$O/snap" \
  -autoboot_script "$HOME/compartilhado/kn7000_mame/tools/rigs/remote.lua" \
  -flop "$O/floppy.img" -harddisk "$O/sd.img" > "$O/run.log" 2>&1 || true
grep -E '^(PROBE|PREFILL)' "$O/run.log" | tail -4
ARGS=(); [ "$FAST" = 1 ] && ARGS=(--prefix 65536); [ "$PREFILL" = 0 ] && ARGS+=(--no-prefill)
[ "$LTEST" != 0 ] && ARGS+=(--degraded)
[ "$SAFE" = 1 ] && ARGS+=(--degraded --skip-mask 0x3E0)
[ "$SAFE" = 2 ] && ARGS+=(--degraded --skip-mask 0x1FF)
[ "$SAFE" = 3 ] && ARGS+=(--degraded --skip-mask 0x21F)
[ "$SAFE" = 4 ] && ARGS+=(--degraded --survey)
[ "$SAFE" = 5 ] && ARGS+=(--degraded --survey2 --refdir "$O")
python3 -I "$HERE/verify_dump.py" "$O/sd.img" --ic21-ref "$O/ref_ic21.bin" "${ARGS[@]}"
