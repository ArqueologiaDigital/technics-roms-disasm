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
# QEMU_ROOT / BASE_IMAGE defaults below.
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
export LD_LIBRARY_PATH=$QEMU_ROOT/usr/lib/x86_64-linux-gnu
Q=$QEMU_ROOT/usr/bin

S=$WORK/serve; OUT=$WORK/out
rm -rf -- "$WORK/serve" "$WORK/out"
mkdir -p "$S" "$OUT"
[ -f "$WORK/disk.qcow2" ] || "$Q/qemu-img" create -q -f qcow2 -F qcow2 -b "$BASE_IMAGE" "$WORK/disk.qcow2" 8G

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
printf 'instance-id: cc900-%s\nlocal-hostname: cc900vm\n' "$(date +%s%N)" > "$S/meta-data"
: > "$S/vendor-data"
cat > "$S/user-data" <<EOF
#cloud-config
runcmd:
  - [sh, -c, "export PORT=$PORT; curl -sf http://10.0.2.2:$PORT/job.sh -o /root/job.sh && sh /root/job.sh >/root/job.log 2>&1; curl -sf -T /root/job.log http://10.0.2.2:$PORT/out/job.log; poweroff"]
EOF

python3 -I "$HERE/httpd.py" "$S" "$OUT" "$PORT" 2>"$OUT/httpd.log" &
HTTPD=$!
trap 'kill $HTTPD 2>/dev/null || true' EXIT
sleep 1
timeout 7200 "$Q/qemu-system-x86_64" -L "$QEMU_ROOT/usr/share/qemu" -L "$QEMU_ROOT/usr/share/seabios" \
    -machine q35,accel=kvm -cpu host -smp 4 -m 4096 -no-reboot \
    -drive file="$WORK/disk.qcow2",if=virtio,format=qcow2 \
    -netdev user,id=n0 -device virtio-net-pci,netdev=n0 \
    -smbios "type=1,serial=ds=nocloud;s=http://10.0.2.2:$PORT/" \
    -serial file:"$OUT/serial.log" -monitor none -display none

[ -f "$OUT/results.tar" ] || { echo "no results.tar; see $OUT/job.log and $OUT/serial.log" >&2; exit 1; }
tail -1 "$OUT/job.log" | grep -q JOB-OK || { echo "job did not finish; see $OUT/job.log" >&2; exit 1; }

day=$(date +%F); n=1
while compgen -G "$ORACLE/runs/$day-$(printf %d $n)-*" >/dev/null; do n=$((n + 1)); done
R=$ORACLE/runs/$day-$n-$RUN_NAME
mkdir -p "$R/out"
tar -xf "$OUT/results.tar" -C "$R/out" --no-same-owner
cp "$OUT/job.log" "$S/sources.txt" "$S/options.txt" "$S/compilers.txt" "$R/"
( cd "$OUT" && sha256sum results.tar ) > "$R/results.tar.sha256"
( cd "$S" && sha256sum cc-*.tar corpus.tar ) > "$R/inputs.sha256"
rm -rf -- "$WORK/serve" "$WORK/out"
echo "run filed: $R"
echo "commit it: git -C $ORACLE add runs/$(basename "$R") && git -C $ORACLE commit -m 'run $(basename "$R")'"
