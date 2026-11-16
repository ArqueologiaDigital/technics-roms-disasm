#!/bin/bash
# Compile a C corpus with one or more Toshiba cc900 versions, inside the oracle VM, and file the outputs as a run of
# the private repository ~/compartilhado/cc900-oracle (never pushed: the outputs are Toshiba-generated).
#
# usage: run_oracle.sh RUN_NAME CORPUS_DIR SOURCES OPTIONS COMPILER [COMPILER ...]
#   RUN_NAME    short name; the run lands in $ORACLE/runs/<YYYY-MM-DD>-<NN>-<RUN_NAME>/ (NN = next free number)
#   CORPUS_DIR  directory of C files (and headers); SOURCES names files relative to it, one per line
#   OPTIONS     "label|cc900 flags" per line
#   COMPILER    a name from compilers.conf (v423, ide2003, v110)
# Environment: ORACLE (default ~/compartilhado/cc900-oracle), PORT (default 8931), and run_vm.sh's
# QEMU_ROOT / BASE_IMAGE defaults below.  run_vm.sh boots the VM; this script prepares the job and files the run.
#
# Nothing Toshiba made runs on the host.  The guest (Debian 13 + Wine, disk overlay $ORACLE/vm/home/disk.qcow2) gets
# everything over HTTP from httpd.py, compiles (job.sh), PUTs results.tar back and powers off.
set -euo pipefail
RUN_NAME=${1:?RUN_NAME}; CORPUS=$(realpath "${2:?CORPUS_DIR}"); SOURCES=$(realpath "${3:?SOURCES}")
OPTIONS=$(realpath "${4:?OPTIONS}"); shift 4; [ $# -ge 1 ] || { echo "no compiler given" >&2; exit 2; }
HERE=$(dirname "$(realpath "$0")")
ORACLE=${ORACLE:-$HOME/compartilhado/cc900-oracle}
QEMU_ROOT=${QEMU_ROOT:-$ORACLE/vm/qemu}
BASE_IMAGE=${BASE_IMAGE:-$ORACLE/vm/debian-13-generic-amd64.qcow2}
PORT=${PORT:-8931}
WORK=$ORACLE/vm/home

S=$WORK/serve; OUT=$WORK/out
rm -rf -- "${WORK:?}/serve" "${WORK:?}/out"
mkdir -p "$S" "$OUT"

: > "$S/compilers.txt"
for c in "$@"; do
    tree=$(awk -F'|' -v n="$c" '$1==n {print $2}' "$HERE/compilers.conf")
    [ -n "$tree" ] || { echo "unknown compiler $c (compilers.conf)" >&2; exit 2; }
    tree=${tree/#\~/$HOME}
    tar -cf "$S/cc-$c.tar" -C "$tree" --exclude=SAMPLE --exclude=sample --exclude=manual --exclude=MANUAL .
    echo "$c|cc-$c.tar" >> "$S/compilers.txt"
done
tar -cf "$S/corpus.tar" -C "$CORPUS" .
cp "$HERE/job.sh" "$S/job.sh"; cp "$SOURCES" "$S/sources.txt"; cp "$OPTIONS" "$S/options.txt"

ORACLE=$ORACLE QEMU_ROOT=$QEMU_ROOT BASE_IMAGE=$BASE_IMAGE PORT=$PORT bash "$HERE/run_vm.sh" "$S" "$OUT"

day=$(date +%F); n=1
while compgen -G "$ORACLE/runs/$day-$(printf %d $n)-*" >/dev/null; do n=$((n + 1)); done
R=$ORACLE/runs/$day-$n-$RUN_NAME
mkdir -p "$R/out"
tar -xf "$OUT/results.tar" -C "$R/out" --no-same-owner
cp "$OUT/job.log" "$S/sources.txt" "$S/options.txt" "$S/compilers.txt" "$R/"
( cd "$OUT" && sha256sum results.tar ) > "$R/results.tar.sha256"
( cd "$S" && sha256sum cc-*.tar corpus.tar ) > "$R/inputs.sha256"
rm -rf -- "${WORK:?}/serve" "${WORK:?}/out"
echo "run filed: $R"
echo "commit it: git -C $ORACLE add runs/$(basename "$R") && git -C $ORACLE commit -m 'run $(basename "$R")'"
