#!/bin/sh
# Phase 2 exit test (notes/cc900-compat-plan-2026-11-08/phase2.md): build test.c with our clang -mabi=cc900, bind the
# library calls to the Toshiba-compiled copies inside the KN5000 v10 firmware (results/pairs.tsv; C9H_divlu /
# C9H_remlu from notes/toshiba-runtime-xref-2026-11-08/results/xref.*.tsv), run it in MAME and compare the results.
# usage: sh run.sh            (MAME=..., ROMS=... override the defaults below; scratch goes to $TMPDIR)
# Prints the results and PASS / FAIL.  Needs the kn5000 romset (v10 program) under $ROMS.
set -eu
HERE=$(cd "$(dirname "$0")" && pwd)
B=${LLVM_BIN:-$HOME/compartilhado/llvm-project/build/bin}
MAME=${MAME:-$HOME/compartilhado/kn5000dsp_build/kn7000}
ROMS=${ROMS:-$HOME/compartilhado/technics_roms/roms}
S=$(mktemp -d "${TMPDIR:-$HOME/compartilhado/tmp}/cc900-phase2.XXXXXX")
"$B/clang" -target tlcs900 -mabi=cc900 -O1 -ffreestanding -fno-builtin -S "$HERE/test.c" -o "$S/test.s"
# our backend does not yet relax an out-of-range jr to jrl (a gap found by this test): relax it here
python3 -I -B -c "
import sys, subprocess; sys.path.insert(0, '$HERE/../model'); import to_llvm
def asm(t):
    open('$S/t.s', 'w').write(t)
    return subprocess.run(['$B/llvm-mc', '-triple=tlcs900', '-filetype=obj', '$S/t.s', '-o', '$S/test.o'],
                          capture_output=True, text=True).stderr
t = to_llvm.relax(open('$S/test.s').read(), asm); e = asm(t)
sys.exit(e) if e else None"
"$B/llvm-mc" -triple=tlcs900 -filetype=obj "$HERE/start.s" -o "$S/start.o"
"$B/ld.lld" -Ttext=0xe0000 -e _start --image-base=0 "$S/start.o" "$S/test.o" -o "$S/test.elf" \
  --defsym=strlen=0xff0fa0 --defsym=strcpy=0xff0f4d --defsym=strcat=0xff0dc1 --defsym=strncmp=0xff0cc1 \
  --defsym=strchr=0xff0e6d --defsym=memset=0xff0ffa --defsym=memcpy=0xff0d99 --defsym=ultoa=0xff27f7 \
  --defsym=C9H_divlu=0xff0c18 --defsym=C9H_remlu=0xff0c12
"$B/llvm-objcopy" -O binary "$S/test.elf" "$S/test.bin"
RES=$("$B/llvm-nm" "$S/test.elf" | awk '$3 == "R" {print "0x" $1}')
cd "$S"
CC900_TEST_BIN="$S/test.bin" CC900_LOAD_AT=0xe0000 CC900_RESULTS_AT=$RES CC900_OUT="$S/results.txt" \
  "$MAME" kn5000 -rompath "$ROMS" -nvram_directory "$S/nvram" -cfg_directory "$S/cfg" -video none -sound none \
  -nothrottle -skip_gameinfo -seconds_to_run 60 -autoboot_script "$HERE/harness.lua" -autoboot_delay 0 \
  > "$S/mame.log" 2>&1 || true
cat "$S/results.txt"
EXPECT="len5 5
len3 3
cmp_lt 1
cmp_eq 1
chr_off 4
quot 142857
rem 1
cat abcdef
hex 123456
fill xxxx"
if [ "$(cat "$S/results.txt")" = "$EXPECT" ]; then echo PASS; else echo "FAIL (expected:"; echo "$EXPECT"; echo ")"; fi
echo "scratch: $S"
