#!/usr/bin/env bash
# verify_toshiba_runtime.sh T900_DIR [SCRATCH] -- re-run every library match the original-toolchain finding rests on.
#
# QUESTION IT ANSWERS: do the KN5000 images still contain Toshiba's TLCS-900 C runtime (c900ml.lib), instruction for
# instruction?  T900_DIR is the T900/ directory of an extracted T900.zip (README.md: URL and sha256; the package is
# not committed).  Each line prints "<src> vs <rom>@<addr>: N of M instructions match"; a mismatch is a FAIL.
# Run from the repository root.
set -euo pipefail
T="${1:?usage: verify_toshiba_runtime.sh T900_DIR [SCRATCH]}"
S="${2:-${TMPDIR:-/home/fsanches/compartilhado/tmp}/compiler-id-snippets}"
H="$(dirname "$0")"
R=original_ROMs
SRC="$T/LIB/SRC"
python3 -I "$H/extract_toshiba_snippets.py" "$T" "$S" > /dev/null
fail=0
# library sources are compared with operand values (STRICT=1); the startup sample spells its operands symbolically
# (startof(f_area), __DataRAM) where the ROM has numbers, so it is compared by shape only (STRICT unset)
run() { out=$(STRICT=${STRICT_RUN-1} python3 -I "$H/srccmp.py" "$@"); echo "$out"; case "$out" in *" of "*) n=${out##*: }; [ "${n%% of*}" = "$(echo "$n" | sed -E 's/.* of ([0-9]+).*/\1/')" ] || fail=1;; *) fail=1;; esac; }
run "$SRC/LMULL.ASM" $R/kn5000_v10_program.rom e00000 ff0a5c
run "$SRC/LDIVL.ASM" $R/kn5000_v10_program.rom e00000 ff0bc3
run "$SRC/LDIVL.ASM" $R/kn5000_table_data.rom 800000 9ffc0e
run "$S/memcpy900.asm" $R/kn5000_v10_program.rom e00000 ff0d99
STRICT_RUN= run "$S/stc94ml_farea.asm" $R/kn5000_v10_program.rom e00000 ef0b46
STRICT_RUN= run "$S/stc94ml_fdata.asm" $R/kn5000_v10_program.rom e00000 ef0bb0
# sub-CPU payload v1.42 (file offset 0 = address 0xEF00): the 1996 floating-point compare routines, symbolic operands
STRICT_RUN= run "$SRC/CMP_D.MAC" $R/kn5000_subprogram_v142.rom ef00 3d2ac
STRICT_RUN= run "$SRC/CMP_F.MAC" $R/kn5000_subprogram_v142.rom ef00 3d306
python3 -I "$H/ctype_check.py" "$T" $R/kn5000_v10_program.rom 0xED778 || fail=1
[ "$fail" = 0 ] && echo "PASS: every Toshiba runtime match holds" || { echo "FAIL: a match did not hold"; exit 1; }
