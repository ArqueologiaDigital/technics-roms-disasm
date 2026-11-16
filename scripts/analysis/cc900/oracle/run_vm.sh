#!/bin/bash
# Boot the cc900 oracle VM once on a prepared job, and return when it has powered off.  Used by run_oracle.sh (runs
# filed in the private oracle repo) and by the firmware-C build (scripts/build/cc900_v423.py, outputs kept in the
# build's git-ignored cache).  The caller holds the VM lock: flock $ORACLE/vm/.runlock.
#
# usage: run_vm.sh SERVE_DIR OUT_DIR
#   SERVE_DIR  what the guest may fetch: job.sh and the inputs it reads (compilers.txt, cc-<name>.tar, corpus.tar,
#              sources.txt, options.txt).  The cloud-init files (meta-data, user-data, vendor-data) are written here.
#   OUT_DIR    an empty directory; the guest PUTs results.tar and job.log into it, and the serial console goes to
#              OUT_DIR/serial.log.
# Exits 0 only when OUT_DIR/results.tar exists and job.log ends with JOB-OK.
# Environment: ORACLE (default ~/compartilhado/cc900-oracle), QEMU_ROOT (default $ORACLE/vm/qemu), BASE_IMAGE
# (default $ORACLE/vm/debian-13-generic-amd64.qcow2), PORT (default 8931), VM_SNAPSHOT (1: boot the disk overlay
# with -snapshot, so this boot writes nothing to $ORACLE/vm/home/disk.qcow2; the overlay must exist already, with
# Wine installed by an earlier run).
#
# Nothing Toshiba made runs on the host.  The guest (Debian 13 + Wine, disk overlay $ORACLE/vm/home/disk.qcow2) gets
# everything over HTTP from httpd.py, compiles (job.sh), PUTs results.tar back and powers off.
set -euo pipefail
S=$(realpath "${1:?SERVE_DIR}"); OUT=$(realpath "${2:?OUT_DIR}")
HERE=$(dirname "$(realpath "$0")")
ORACLE=${ORACLE:-$HOME/compartilhado/cc900-oracle}
QEMU_ROOT=${QEMU_ROOT:-$ORACLE/vm/qemu}
BASE_IMAGE=${BASE_IMAGE:-$ORACLE/vm/debian-13-generic-amd64.qcow2}
PORT=${PORT:-8931}
WORK=$ORACLE/vm/home
export LD_LIBRARY_PATH=$QEMU_ROOT/usr/lib/x86_64-linux-gnu
Q=$QEMU_ROOT/usr/bin

SNAP=()
if [ "${VM_SNAPSHOT:-0}" = 1 ]; then
    [ -f "$WORK/disk.qcow2" ] || { echo "VM_SNAPSHOT=1 needs the disk overlay $WORK/disk.qcow2" >&2; exit 2; }
    SNAP=(-snapshot)
else
    [ -f "$WORK/disk.qcow2" ] || "$Q/qemu-img" create -q -f qcow2 -F qcow2 -b "$BASE_IMAGE" "$WORK/disk.qcow2" 8G
fi

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
    -machine q35,accel=kvm -cpu host -smp 4 -m 4096 -no-reboot "${SNAP[@]}" \
    -drive file="$WORK/disk.qcow2",if=virtio,format=qcow2 \
    -netdev user,id=n0 -device virtio-net-pci,netdev=n0 \
    -smbios "type=1,serial=ds=nocloud;s=http://10.0.2.2:$PORT/" \
    -serial file:"$OUT/serial.log" -monitor none -display none

[ -f "$OUT/results.tar" ] || { echo "no results.tar; see $OUT/job.log and $OUT/serial.log" >&2; exit 1; }
tail -1 "$OUT/job.log" | grep -q JOB-OK || { echo "job did not finish; see $OUT/job.log" >&2; exit 1; }
