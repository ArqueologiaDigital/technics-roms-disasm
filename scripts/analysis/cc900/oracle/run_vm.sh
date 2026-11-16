#!/bin/bash
# Boot the cc900 oracle VM once on a prepared job, and return when it has powered off.  Used by run_oracle.sh (runs
# filed in the private oracle repo) and by the firmware-C build (scripts/build/cc900_v423.py, outputs kept in the
# build's git-ignored cache).  Run it through vm_slot.sh, which holds a slot of the VM pool and sets VM_SLOT,
# VM_PORT (the HTTP port), VM_SLOT_DIR and VM_SNAPSHOT; it refuses to start without VM_SLOT.
#
# usage: run_vm.sh SERVE_DIR OUT_DIR
#   SERVE_DIR  what the guest may fetch: job.sh and the inputs it reads (compilers.txt, cc-<name>.tar, corpus.tar,
#              sources.txt, options.txt).  The cloud-init files (meta-data, user-data, vendor-data) are written here.
#   OUT_DIR    an empty directory; the guest PUTs results.tar and job.log into it, and the serial console goes to
#              OUT_DIR/serial.log.
# Exits 0 only when OUT_DIR/results.tar exists and job.log ends with JOB-OK.
# Environment: ORACLE (default ~/compartilhado/cc900-oracle), QEMU_ROOT (default $ORACLE/vm/qemu), BASE_IMAGE
# (default $ORACLE/vm/debian-13-generic-amd64.qcow2), VM_PORT (from vm_slot.sh), VM_SNAPSHOT (1: boot the disk
# overlay with -snapshot, so this boot writes nothing to $ORACLE/vm/home/disk.qcow2 and several slots can share it;
# the overlay must exist already, with Wine installed by an earlier run; 0 only in vm_slot.sh --exclusive),
# VM_SMP / VM_MEM (default 2 CPUs, 3072 MB per VM).  QEMU's -snapshot temporary file goes to TMPDIR (default
# ~/compartilhado/tmp, never /tmp).
#
# Nothing Toshiba made runs on the host.  The guest (Debian 13 + Wine, disk overlay $ORACLE/vm/home/disk.qcow2) gets
# everything over HTTP from httpd.py, compiles (job.sh), PUTs results.tar back and powers off.
set -euo pipefail
S=$(realpath "${1:?SERVE_DIR}"); OUT=$(realpath "${2:?OUT_DIR}")
HERE=$(dirname "$(realpath "$0")")
ORACLE=${ORACLE:-$HOME/compartilhado/cc900-oracle}
QEMU_ROOT=${QEMU_ROOT:-$ORACLE/vm/qemu}
BASE_IMAGE=${BASE_IMAGE:-$ORACLE/vm/debian-13-generic-amd64.qcow2}
[ -n "${VM_SLOT:-}" ] || { echo "run_vm.sh: run it through vm_slot.sh (no VM_SLOT: no slot of the VM pool is held)" >&2; exit 2; }
PORT=${VM_PORT:?VM_PORT}
WORK=$ORACLE/vm/home
case "${TMPDIR:-/tmp}" in /tmp|/tmp/*) TMPDIR=$HOME/compartilhado/tmp ;; esac   # never the small tmpfs
export TMPDIR
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
    -machine q35,accel=kvm -cpu host -smp "${VM_SMP:-2}" -m "${VM_MEM:-3072}" -no-reboot "${SNAP[@]}" \
    -drive file="$WORK/disk.qcow2",if=virtio,format=qcow2 \
    -netdev user,id=n0 -device virtio-net-pci,netdev=n0 \
    -smbios "type=1,serial=ds=nocloud;s=http://10.0.2.2:$PORT/" \
    -serial file:"$OUT/serial.log" -monitor none -display none

[ -f "$OUT/results.tar" ] || { echo "no results.tar; see $OUT/job.log and $OUT/serial.log" >&2; exit 1; }
tail -1 "$OUT/job.log" | grep -q JOB-OK || { echo "job did not finish; see $OUT/job.log" >&2; exit 1; }
