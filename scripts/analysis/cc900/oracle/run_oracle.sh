#!/bin/bash
# Compile a C corpus with one or more Toshiba cc900 versions, inside the oracle VM, and file the outputs as a run of
# the private repository ~/compartilhado/cc900-oracle (never pushed: the outputs are Toshiba-generated).
#
# usage: run_oracle.sh RUN_NAME CORPUS_DIR SOURCES OPTIONS COMPILER [COMPILER ...]
#   RUN_NAME    short name; the run lands in $ORACLE/runs/<YYYY-MM-DD>-<NN>-<RUN_NAME>/ (NN = next free number)
#   CORPUS_DIR  directory of C files (and headers); SOURCES names files relative to it, one per line
#   OPTIONS     "label|cc900 flags" per line
#   COMPILER    a name from compilers.conf (v423, ide2003, v110)
# Environment: ORACLE (default ~/compartilhado/cc900-oracle), VM_POOL_SLOTS (vm_slot.sh, default 3), VM_EXCLUSIVE,
# and run_vm.sh's QEMU_ROOT / BASE_IMAGE defaults below.  vm_slot.sh picks a free slot of the VM pool (its own work
# directory vm/home/slot-N and HTTP port), run_vm.sh boots the VM; this script prepares the job and files the run.
# Several runs go at once, one per slot.
# ASMFLAGS=FILE (optional): job.sh's asmflags.txt, "label|ASM900 flags" per line -- every listing is also assembled
# with each of those (e.g. "lst|-l" for ASM900's list file with the final encodings); the file is filed with the run.
#
# Nothing Toshiba made runs on the host.  The guest (Debian 13 + Wine, disk overlay $ORACLE/vm/home/disk.qcow2) gets
# everything over HTTP from httpd.py, compiles (job.sh), PUTs results.tar back and powers off.
set -euo pipefail
# Take a slot of the VM pool first (vm_slot.sh; VM_EXCLUSIVE=1 waits until no slot is in use and makes the overlay
# writable, for a one-off such as the first Wine install).  Do not wrap this script in `flock vm/.runlock` any more:
# that still works (vm_slot.sh then runs in slot 0 under it) but holds every other run back.
if [ -z "${VM_SLOT:-}" ]; then
    exec bash "$(dirname "$(realpath "$0")")/vm_slot.sh" ${VM_EXCLUSIVE:+--exclusive} bash "$(realpath "$0")" "$@"
fi
RUN_NAME=${1:?RUN_NAME}; CORPUS=$(realpath "${2:?CORPUS_DIR}"); SOURCES=$(realpath "${3:?SOURCES}")
OPTIONS=$(realpath "${4:?OPTIONS}"); shift 4; [ $# -ge 1 ] || { echo "no compiler given" >&2; exit 2; }
HERE=$(dirname "$(realpath "$0")")
ORACLE=${ORACLE:-$HOME/compartilhado/cc900-oracle}
QEMU_ROOT=${QEMU_ROOT:-$ORACLE/vm/qemu}
BASE_IMAGE=${BASE_IMAGE:-$ORACLE/vm/debian-13-generic-amd64.qcow2}
SLOT=${VM_SLOT_DIR:?VM_SLOT_DIR}                 # $ORACLE/vm/home/slot-N, this slot's own work directory
. "$HERE/slot_ok.sh"                             # slot_ok: exactly $ORACLE/vm/home/slot-<digits>, resolved
slot_ok "$SLOT" || { echo "run_oracle.sh: refusing VM_SLOT_DIR $SLOT: not $ORACLE/vm/home/slot-<N>" >&2; exit 2; }

S=$SLOT/serve; OUT=$SLOT/out
slot_ok "$SLOT" && rm -rf -- "${SLOT:?}/serve" "${SLOT:?}/out"
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
[ -z "${ASMFLAGS:-}" ] || cp "$ASMFLAGS" "$S/asmflags.txt"

echo "run_oracle.sh: VM slot $VM_SLOT (port $VM_PORT)" >&2
ORACLE=$ORACLE QEMU_ROOT=$QEMU_ROOT BASE_IMAGE=$BASE_IMAGE bash "$HERE/run_vm.sh" "$S" "$OUT"

# the run's number: the next free one of the day, chosen and claimed under a lock, since slots finish concurrently
exec {numfd}>>"$ORACLE/vm/.runs-numbering.lock"
flock "$numfd"
day=$(date +%F); n=1
while compgen -G "$ORACLE/runs/$day-$(printf %d $n)-*" >/dev/null; do n=$((n + 1)); done
R=$ORACLE/runs/$day-$n-$RUN_NAME
mkdir -p "$R/out"
exec {numfd}>&-
tar -xf "$OUT/results.tar" -C "$R/out" --no-same-owner
cp "$OUT/job.log" "$S/sources.txt" "$S/options.txt" "$S/compilers.txt" "$R/"
[ ! -f "$S/asmflags.txt" ] || cp "$S/asmflags.txt" "$R/"
( cd "$OUT" && sha256sum results.tar ) > "$R/results.tar.sha256"
( cd "$S" && sha256sum cc-*.tar corpus.tar ) > "$R/inputs.sha256"
slot_ok "$SLOT" && rm -rf -- "${SLOT:?}/serve" "${SLOT:?}/out"
echo "run filed: $R"
echo "commit it: git -C $ORACLE add runs/$(basename "$R") && git -C $ORACLE commit -m 'run $(basename "$R")'"
