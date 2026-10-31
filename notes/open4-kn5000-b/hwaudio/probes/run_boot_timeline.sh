#!/bin/sh
# Measure the KN5000 boot milestones in MAME (see boot_timeline_tap.lua for the question and method).
# usage: run_boot_timeline.sh [MAME_BINARY] [OUTPUT]
# The machine boots cold: nvram/cfg go to a fresh scratch directory, so the firmware takes its
# no-saved-settings path ("ALL INITIAL SETTING!").
set -eu
HERE=$(cd "$(dirname "$0")" && pwd)
MAME=${1:-/home/fsanches/compartilhado/kn5000dsp_build/kn7000}
OUT=${2:-$HERE/boot_timeline.txt}
ROMS=${ROMS:-/home/fsanches/compartilhado/technics_roms/roms}
SCR=$(mktemp -d "${TMPDIR:-/home/fsanches/compartilhado/tmp}/kn5000-boot-tap.XXXXXX")
cd "$SCR"
BOOT_TAP_OUT="$OUT" "$MAME" kn5000 -rompath "$ROMS" -nvram_directory "$SCR/nvram" \
    -cfg_directory "$SCR/cfg" -video none -sound none -nothrottle -skip_gameinfo \
    -seconds_to_run 60 \
    -autoboot_script "$HERE/boot_timeline_tap.lua" -autoboot_delay 0 > "$SCR/mame.log" 2>&1 || true
echo "MAME log: $SCR/mame.log"
sha256sum "$MAME"
cat "$OUT"
