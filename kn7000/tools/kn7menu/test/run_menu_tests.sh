#!/bin/bash
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# run_menu_tests.sh OUT CASE... -- the program menu in MAME (README.md, "How it was tested"). Every run boots the
# overlay emulator (-bios v13, program 893: the owner's) with the owner's loader floppy as released
# (../cnv_romdump/releases/2026-10-19/floppy/kn7load_floppy.img, KN7LOAD.CNV 6b81f382...) and a fresh copy of the
# real KN7000's SD card with a card tree copied into its root (fatimg.py put); menu_test.lua drives it and prints
# "menu_test: <check> PASS|FAIL detail" (appended to OUT/summary.txt). The card copy is deleted after each run.
# OUT is a scratch directory (~/compartilhado/tmp/..., never /tmp). CASEs:
#   guard      guard.py on the menu (clean), and on test/guard_selftest.s (must find each planted reference)
#   card       the card `make card` builds (the menu, Another World, passes 5-9): the list, the screen,
#              the buttons, the redraw, EXIT / YES / LEAVE / NO (menu_test.lua MT_MODE=card)
#   fallback   test/mkfallback.py's card: missing and malformed manifests and icons, a long-named folder, a
#              folder without a program, a damaged and a foreign KN7APP.BIN (refused, with the message)
#   buttons    a menu that reads no button (-D BUTTONS_USED=0) on the card: what each candidate button does to
#              IC23 (the panel settings), to the LCD and to the converter calls
#   cputime    pass 9 started from its folder (CPUTIME): its file written to the card's root, checked by the
#              release's verifier (verify_dump.py --cputime with cpu_tap.lua's account, check_cpu_probe.py);
#              then "Continue Next?" YES brings the menu back
# Env: EMU (a copy of kn7000-emulator holding kn7000, roms/, plugins/; default ~/compartilhado/kn7000-emulator),
# CARD_IMG (default EMU's sdcard_from_real_kn7000.img), BIOS (v13), DISPLAY.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
MENU="$(cd "$HERE/.." && pwd)"
LOADER="$MENU/../cnv_romdump"
EMU="${EMU:-$HOME/compartilhado/kn7000-emulator}"
CARD_IMG="${CARD_IMG:-$EMU/sdcard_from_real_kn7000.img}"
[ -f "$CARD_IMG" ] || CARD_IMG="$HOME/compartilhado/kn7000-emulator/sdcard_from_real_kn7000.img"
FLOPPY="$LOADER/releases/2026-10-19/floppy/kn7load_floppy.img"
BIOS="${BIOS:-v13}"
case "$BIOS" in v13) PANEL=0x5006BE4C ;; v16) PANEL=0x5006BE50 ;; *) echo "unknown bios $BIOS" >&2; exit 2 ;; esac
OUT="$(mkdir -p "$1" && cd "$1" && pwd)"; shift
say() { echo "run_menu_tests: $*" | tee -a "$OUT/summary.txt"; }

build() {                             # the menu into OUT/build, its symbols for the scripts
  make -s -C "$MENU" OUT="$OUT/build" > "$OUT/build.log" 2>&1 || { cat "$OUT/build.log"; exit 1; }
  python3 -I "$HERE/syms.py" "$LOADER" "$OUT/build" "$OUT/build/syms.lua"
}

# mame RUNDIR TREE MODE [ENV=VALUE...]: one boot with TREE copied into a fresh copy of the card; results in RUNDIR
mame() {
  local R="$1" TREE="$2" M="$3"; shift 3
  rm -rf -- "${R:?}"; mkdir -p "$R/snap"
  cp "$CARD_IMG" "$R/sd.img"; chmod u+w "$R/sd.img"
  python3 -I "$MENU/fatimg.py" "$R/sd.img" put "$TREE"
  python3 -I "$MENU/fatscan.py" --image "$R/sd.img" --lua "$R/expect.lua" > "$R/fatscan.txt"
  cp "$FLOPPY" "$R/floppy.img"; chmod u+w "$R/floppy.img"
  ( cd "$EMU" && env MT_MODE="$M" MT_OUT="$R" MT_SYMS="${SYMS:-$OUT/build/syms.lua}" MT_EXPECT="$R/expect.lua" \
      MT_PANEL="$PANEL" "$@" DISPLAY="${DISPLAY:-:0}" timeout 5400 ./kn7000 kn7000 -bios "$BIOS" -rompath ./roms \
      -pluginspath ./plugins -skip_gameinfo -window -nothrottle -harddisk "$R/sd.img" -flop "$R/floppy.img" \
      -nvram_directory "$R/nv" -cfg_directory "$R/cfg" -snapshot_directory "$R/snap" \
      -autoboot_script "${SCRIPT:-$HERE/menu_test.lua}" ) > "$R/run.log" 2>&1
  grep '^menu_test:' "$R/run.log" > "$R/session.txt"
  local nf np
  nf=$(grep -c ' FAIL ' "$R/session.txt"); np=$(grep -c ' PASS ' "$R/session.txt")
  sed 's/^/  /' "$R/session.txt" >> "$OUT/summary.txt"
  say "$M $([ "$nf" = 0 ] && [ "$np" -gt 0 ] && echo PASS || echo FAIL)  $np checks passed, $nf failed ($R/session.txt)"
}

say "emulator md5 $(md5sum < "$EMU/kn7000" | cut -c1-8); floppy $(sha1sum < "$FLOPPY" | cut -c1-16); card image $(sha1sum < "$CARD_IMG" | cut -c1-16); bios $BIOS"
build
say "menu KN7APP.BIN $(sha1sum < "$OUT/build/KN7APP.BIN" | cut -c1-40) ($(stat -c%s "$OUT/build/KN7APP.BIN") bytes)"
while [ $# -gt 0 ]; do
  CASE="$1"; shift
  case "$CASE" in
  guard)
    G="$OUT/guard"; mkdir -p "$G"
    python3 -I "$MENU/guard.py" "$MENU/.." "$LOADER" "$OUT/build" > "$G/menu.txt"; a=$?
    python3 -I "$MENU/guard.py" "$MENU/.." "$LOADER" "$OUT/build" --selftest "$HERE/guard_selftest.s" > "$G/selftest.txt"; s=$?
    want=$(grep -c '# PLANTED' "$HERE/guard_selftest.s"); got=$(grep -c '^guard: .*guard_selftest.s:[0-9]*:' "$G/selftest.txt")
    say "guard     $([ $a = 0 ] && [ $s = 1 ] && [ "$got" = "$want" ] && echo PASS || echo FAIL)  menu: $(tail -1 "$G/menu.txt"); self-test: $got of $want planted references found ($G/selftest.txt)"
    ;;
  card)
    make -s -C "$MENU" OUT="$OUT/build" card > "$OUT/card.log" 2>&1 || { tail -20 "$OUT/card.log"; say "card FAIL: make card"; continue; }
    say "card tree $OUT/build/card ($(find "$OUT/build/card" -type f | wc -l) files); its KN7APP.BINs: $(cd "$OUT/build/card" && sha1sum */KN7APP.BIN KN7APP.BIN | cut -c1-12 | tr '\n' ' ')"
    mame "$OUT/card" "$OUT/build/card" card
    rm -f -- "$OUT/card/sd.img" "$OUT/card/floppy.img"
    ;;
  fallback)
    python3 -I "$HERE/mkfallback.py" "$OUT/fallback-tree" "$OUT/build/KN7APP.BIN" "$LOADER/releases" > /dev/null
    mame "$OUT/fallback" "$OUT/fallback-tree" fallback
    rm -f -- "$OUT/fallback/sd.img" "$OUT/fallback/floppy.img"
    ;;
  buttons)
    B="$OUT/build-nobuttons"; mkdir -p "$B"
    cp "$OUT/build/tramp_bin.inc" "$OUT/build/tramp_syms.inc" "$OUT/build/default_icon.inc" "$OUT/build/tramp.map" "$B/"
    python3 "$MENU/../xapasm.py" "$MENU/menu.s" -I "$MENU" -I "$B" -I "$LOADER" -D BUTTONS_USED=0 -o "$B/menu.bin" -m "$B/menu.map" > /dev/null
    python3 -I "$LOADER/mkapp.py" "$B/menu.bin" "$B/KN7APP.BIN" > /dev/null
    python3 -I "$HERE/syms.py" "$LOADER" "$B" "$B/syms.lua"
    [ -d "$OUT/build/card" ] || make -s -C "$MENU" OUT="$OUT/build" card > "$OUT/card.log" 2>&1
    T="$OUT/buttons-tree"; rm -rf -- "${T:?}"; cp -r "$OUT/build/card" "$T"; cp "$B/KN7APP.BIN" "$T/KN7APP.BIN"
    SYMS="$B/syms.lua" mame "$OUT/buttons" "$T" buttons
    rm -f -- "$OUT/buttons/sd.img" "$OUT/buttons/floppy.img"; rm -rf -- "${T:?}"
    ;;
  cputime)
    [ -d "$OUT/build/card" ] || make -s -C "$MENU" OUT="$OUT/build" card > "$OUT/card.log" 2>&1
    R="$OUT/cputime"
    mame "$R" "$OUT/build/card" run MT_PROGRAM="Pass 9: CPU timing probe" \
      MT_DONE="0x502E0000=3" MT_TAP="$LOADER/test/cpu_tap.lua"
    mkdir -p "$R/card"
    python3 -I "$LOADER/fatls.py" "$R/sd.img" 'C:\CPUTIME.BIN' "$R/card/CPUTIME.BIN" > /dev/null 2>&1
    python3 -I "$LOADER/fatls.py" "$R/sd.img" > "$R/card-files.txt" 2>&1
    python3 -I "$LOADER/test/verify_dump.py" "$R/sd.img" --degraded --cputime --refdir "$R" > "$R/verify.txt" 2>&1; v=$?
    python3 -I "$LOADER/check_cpu_probe.py" "$R/card" > "$R/cpu_time_report.txt" 2>&1; c=$?
    say "cputime verify $([ $v = 0 ] && [ $c = 0 ] && echo PASS || echo FAIL)  verify_dump.py: $(tail -1 "$R/verify.txt"); check_cpu_probe.py: $(tail -1 "$R/cpu_time_report.txt"); C:\\CPUTIME.BIN in the root: $(grep -c '^C:\\CPUTIME.BIN' "$R/card-files.txt")"
    rm -f -- "$R/sd.img" "$R/floppy.img"
    ;;
  *) echo "unknown case $CASE" >&2; exit 2 ;;
  esac
done
