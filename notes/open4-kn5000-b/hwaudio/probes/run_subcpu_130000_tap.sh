#!/bin/sh
# Record every sub-CPU access to the 0x130000 block over a cold boot (see subcpu_130000_write_tap.lua).
# usage: run_subcpu_130000_tap.sh [MAME_BINARY] [OUTPUT]
set -eu
HERE=$(cd "$(dirname "$0")" && pwd)
MAME=${1:-/home/fsanches/compartilhado/kn5000dsp_build/kn7000}
OUT=${2:-$HERE/subcpu_130000_writes.txt}
ROMS=${ROMS:-/home/fsanches/compartilhado/technics_roms/roms}
SCR=$(mktemp -d "${TMPDIR:-/home/fsanches/compartilhado/tmp}/kn5000-130000-tap.XXXXXX")
cd "$SCR"
TAP_OUT="$OUT" "$MAME" kn5000 -rompath "$ROMS" -nvram_directory "$SCR/nvram" \
    -cfg_directory "$SCR/cfg" -video none -sound none -nothrottle -skip_gameinfo \
    -seconds_to_run 60 \
    -autoboot_script "$HERE/subcpu_130000_write_tap.lua" -autoboot_delay 0 > "$SCR/mame.log" 2>&1 || true
echo "MAME log: $SCR/mame.log"
sha256sum "$MAME"
cat "$OUT"
