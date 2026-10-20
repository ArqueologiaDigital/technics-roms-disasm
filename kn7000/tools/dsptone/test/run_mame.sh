#!/bin/bash
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# run_mame.sh OUT -- DSPTONE end to end in MAME, the light check of iteration 1 (README.md, "How it was checked"):
# is the sine audible in a -wavwrite recording, then the PCM sweep; does the firmware's "DSP dead" flag stay 0;
# does the firmware's own reverb run again after STOP?
#   * builds DSPTONE (make OUT=OUT/build card-dir) and the program menu (../kn7menu, OUT=OUT/menu);
#   * a card tree: the menu as the root KN7APP.BIN and DSPTONE\ (KN7APP.BIN, MANIFEST.TXT, ICON.BMP), copied into a
#     fresh copy of the real KN7000's SD card image (../kn7menu/fatimg.py put);
#   * boots the overlay emulator (EMU, default ~/compartilhado/kn7000-emulator; -bios v13, program 893: the owner's)
#     with the owner's loader floppy as released, -wavwrite OUT/run.wav, and drives it with the remote rig
#     (kn7000_mame tools/rigs/remote.lua) from tone_test.cmd.in; tone_tap.lua logs the DSP every 0.25 s (OUT/tap.txt);
#   * analyze.py reads the recording, the rig's log and the tap: OUT/report.txt, last line "analyze: N of M checks".
# OUT is scratch (~/compartilhado/tmp/..., never /tmp). The card and floppy copies are deleted afterwards.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="$(cd "$HERE/.." && pwd)"
MENU="$SRC/../kn7menu"
LOADER="$SRC/../cnv_romdump"
EMU="${EMU:-$HOME/compartilhado/kn7000-emulator}"
RIG="${RIG:-$HOME/compartilhado/kn7000_mame/tools/rigs/remote.lua}"
FLOPPY="$LOADER/releases/2026-10-19/floppy/kn7load_floppy.img"
BIOS="${BIOS:-v13}"
case "$BIOS" in v13) DEAD=0x500066D8 ;; v16) DEAD=0x500066CC ;; *) echo "unknown bios $BIOS" >&2; exit 2 ;; esac
O="$(mkdir -p "$1" && cd "$1" && pwd)"
make -s -C "$SRC" OUT="$O/build" card-dir > "$O/build.log" 2>&1 || { cat "$O/build.log"; exit 1; }
make -s -C "$MENU" OUT="$O/menu" > "$O/menu.log" 2>&1 || { cat "$O/menu.log"; exit 1; }
rm -rf -- "${O:?}/tree" "${O:?}/snap"; mkdir -p "$O/tree" "$O/snap" "$O/cfg" "$O/nv"
cp "$O/menu/KN7APP.BIN" "$O/tree/KN7APP.BIN"
cp -r "$O/build/card/DSPTONE" "$O/tree/DSPTONE"
cp "$EMU/sdcard_from_real_kn7000.img" "$O/sd.img"; chmod u+w "$O/sd.img"
python3 -I "$MENU/fatimg.py" "$O/sd.img" put "$O/tree" > "$O/fatimg.txt"
cp "$FLOPPY" "$O/floppy.img"; chmod u+w "$O/floppy.img"
sed -e "s|@TAP@|lua dofile(\"$HERE/tone_tap.lua\")|" "$HERE/tone_test.cmd.in" > "$O/cmd.txt"
rm -f -- "$O/cmd.txt.log" "$O/run.wav"
{
  echo "emulator md5 $(md5sum < "$EMU/kn7000" | cut -c1-32), bios $BIOS"
  echo "DSPTONE KN7APP.BIN $(sha1sum < "$O/build/KN7APP.BIN" | cut -c1-40), menu $(sha1sum < "$O/menu/KN7APP.BIN" | cut -c1-40)"
  echo "floppy $(sha1sum < "$FLOPPY" | cut -c1-40), card image $(sha1sum < "$EMU/sdcard_from_real_kn7000.img" | cut -c1-40)"
} > "$O/versions.txt"
( cd "$EMU" && env REMOTE_CMD="$O/cmd.txt" TT_OUT="$O" TT_DEAD="$DEAD" DISPLAY="${DISPLAY:-:0}" timeout 3600 \
    ./kn7000 kn7000 -bios "$BIOS" -rompath ./roms -pluginspath ./plugins -skip_gameinfo -window -nothrottle \
    -harddisk "$O/sd.img" -flop "$O/floppy.img" -wavwrite "$O/run.wav" \
    -nvram_directory "$O/nv" -cfg_directory "$O/cfg" -snapshot_directory "$O/snap" \
    -autoboot_script "$RIG" ) > "$O/run.log" 2>&1
rm -f -- "$O/sd.img" "$O/floppy.img"
python3 -I "$HERE/analyze.py" "$O" | tee "$O/report.txt"
