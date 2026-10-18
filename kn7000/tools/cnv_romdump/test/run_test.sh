#!/bin/bash
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# run_test.sh MAME_BINARY OUTDIR [--fast] [--no-prefill] -- the dumper end to end in MAME, then verify_dump.py.
#   Builds KN7LOAD.CNV (on a floppy the KN7000 formatted) and KN7APP.BIN (put in the root of a copy of the
#   real KN7000's SD card), boots the kn7000 with both, fills the undumped ROMs with test data (prefill.lua),
#   runs DISK MENU > STYLE CONVERT > OK, waits until the dumper has finished and checks every file it wrote.
#   --fast: every ROM cut to 64 KB (a quick check of the whole path; the verifier then checks prefixes).
#   MAME_BINARY: a build of upstream MAME with the kn7000 driver (e.g. the technics-kn-flop-rebuild worktree's).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; SRC="$HERE/.."
BIN="$(readlink -f "$1")"; O="$(mkdir -p "$2" && cd "$2" && pwd)"; shift 2
FAST=0; PREFILL=1
for a in "$@"; do case "$a" in --fast) FAST=1;; --no-prefill) PREFILL=0;; esac; done
TOOLS="$HOME/compartilhado/kn7000_mame/tools/floppy-images"
make -s -C "$SRC" OUT="$O/build" FLOPPY_TOOLS="$TOOLS"
APP="$O/build/KN7APP.BIN"
if [ "$FAST" = 1 ]; then
  sed -e 's/, 0x200000, /, 0x10000, /' -e 's/, 0x1000000, /, 0x10000, /' -e 's/, 0x800000, /, 0x10000, /' \
      "$SRC/romdump.s" > "$O/build/romdump_fast.s"
  cp "$SRC/kn7cnv.inc" "$SRC/romdump.inc" "$O/build/"
  python3 "$SRC/../xapasm.py" "$O/build/romdump_fast.s" -o "$O/build/fast.bin" -m "$O/build/fast.map" > /dev/null
  python3 -I "$SRC/mkapp.py" "$O/build/fast.bin" "$O/build/KN7APP_FAST.BIN" > /dev/null
  APP="$O/build/KN7APP_FAST.BIN"
fi
cp "$HOME/compartilhado/kn7000-emulator/sdcard_from_real_kn7000.img" "$O/sd.img"; chmod u+w "$O/sd.img"
python3 "$SRC/../sd_addfile.py" "$O/sd.img" 'KN7APP.BIN' "$APP" > /dev/null
cp "$O/build/kn7load_floppy.img" "$O/floppy.img"
P=""; [ "$PREFILL" = 1 ] && P="lua dofile(\"$HERE/prefill.lua\")"
sed -e "s|@PREFILL@|$P|" -e "s|@OUT@|$O|g" "$HERE/dump.cmd.in" > "$O/cmd.txt"; echo exit >> "$O/cmd.txt"; rm -f -- "$O/cmd.txt.log"
mkdir -p "$O/snap" "$O/cfg" "$O/nv"
cd "$(dirname "$BIN")" && REMOTE_CMD="$O/cmd.txt" DISPLAY="${DISPLAY:-:0}" timeout 10800 "$BIN" kn7000 \
  -rompath "$HOME/compartilhado/technics_romsets" -window -nothrottle -skip_gameinfo \
  -cfg_directory "$O/cfg" -nvram_directory "$O/nv" -snapshot_directory "$O/snap" \
  -autoboot_script "$HOME/compartilhado/kn7000_mame/tools/rigs/remote.lua" \
  -flop "$O/floppy.img" -harddisk "$O/sd.img" > "$O/run.log" 2>&1 || true
grep -E '^(PROBE|PREFILL)' "$O/run.log" | tail -4
ARGS=(); [ "$FAST" = 1 ] && ARGS=(--prefix 65536); [ "$PREFILL" = 0 ] && ARGS+=(--no-prefill)
python3 -I "$HERE/verify_dump.py" "$O/sd.img" --ic21-ref "$O/ref_ic21.bin" "${ARGS[@]}"
