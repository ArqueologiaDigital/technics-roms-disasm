#!/bin/bash
# Compile Toshiba library sources with the TLCS-900 C Compiler V4.23 inside a throwaway QEMU/KVM VM.
#
# usage: run_vm.sh WORK SOURCES OPTIONS
#   WORK     the VM's home (normally ~/compartilhado/cc900-oracle/vm/home); holds the disk overlay, kept between runs so
#            Wine is installed only once, and out/ (results.tar, job.log, serial.log)
#   SOURCES  file naming LIB/SRC files to compile, one per line
#   OPTIONS  file of option sets, "label|cc900 flags" per line
# Environment:
#   QEMU_ROOT   a qemu-system-x86 / qemu-utils tree (default ~/compartilhado/cc900-oracle/vm/qemu, made with
#               `apt-get download` + `dpkg -x`, see README.md)
#   BASE_IMAGE  Debian 13 generic cloud image (default ~/compartilhado/cc900-oracle/vm/debian-13-generic-amd64.qcow2)
#   T900        the V4.23 tree (default: upstream_repos devrs.com/ngpcbins, unpacked/zip/T900)
#   PORT        host port for httpd.py (default 8931)
#
# No Toshiba program runs on the host.  The guest gets the compiler as a tarball over HTTP from httpd.py, compiles
# under Wine, sends results.tar back with HTTP PUT and powers off.  The base image is never written (overlay).
set -euo pipefail
WORK=$(realpath "${1:?WORK}"); SOURCES=$(realpath "${2:?SOURCES}"); OPTIONS=$(realpath "${3:?OPTIONS}")
HERE=$(dirname "$(realpath "$0")")
QEMU_ROOT=${QEMU_ROOT:-$HOME/compartilhado/cc900-oracle/vm/qemu}
BASE_IMAGE=${BASE_IMAGE:-$HOME/compartilhado/cc900-oracle/vm/debian-13-generic-amd64.qcow2}
T900=${T900:-$HOME/compartilhado/upstream_repos/file_archive/devrs.com/ngpcbins/unpacked/zip/T900}
PORT=${PORT:-8931}
export LD_LIBRARY_PATH=$QEMU_ROOT/usr/lib/x86_64-linux-gnu
Q=$QEMU_ROOT/usr/bin

mkdir -p "$WORK/serve" "$WORK/out"
rm -f -- "$WORK/out/results.tar" "$WORK/out/job.log" "$WORK/out/serial.log"
[ -f "$WORK/disk.qcow2" ] || { "$Q/qemu-img" create -q -f qcow2 -F qcow2 -b "$BASE_IMAGE" "$WORK/disk.qcow2" 8G; }

S=$WORK/serve
tar -cf "$S/t900.tar" -C "$(dirname "$T900")" --exclude=SAMPLE "$(basename "$T900")"
cp "$HERE/job.sh" "$S/job.sh"; cp "$SOURCES" "$S/sources.txt"; cp "$OPTIONS" "$S/options.txt"
printf 'instance-id: cc900-%s\nlocal-hostname: cc900vm\n' "$(date +%s)" > "$S/meta-data"
: > "$S/vendor-data"
cat > "$S/user-data" <<EOF
#cloud-config
runcmd:
  - [sh, -c, "export PORT=$PORT; curl -sf http://10.0.2.2:$PORT/job.sh -o /root/job.sh && sh /root/job.sh >/root/job.log 2>&1; curl -sf -T /root/job.log http://10.0.2.2:$PORT/out/job.log; poweroff"]
EOF

python3 -I "$HERE/httpd.py" "$S" "$WORK/out" "$PORT" 2>"$WORK/out/httpd.log" &
HTTPD=$!
trap 'kill $HTTPD 2>/dev/null || true' EXIT
sleep 1

timeout 3600 "$Q/qemu-system-x86_64" -L "$QEMU_ROOT/usr/share/qemu" -L "$QEMU_ROOT/usr/share/seabios" \
    -machine q35,accel=kvm -cpu host -smp 4 -m 4096 -no-reboot \
    -drive file="$WORK/disk.qcow2",if=virtio,format=qcow2 \
    -netdev user,id=n0 -device virtio-net-pci,netdev=n0 \
    -smbios "type=1,serial=ds=nocloud;s=http://10.0.2.2:$PORT/" \
    -serial file:"$WORK/out/serial.log" -monitor none -display none

ls -l "$WORK/out"
[ -f "$WORK/out/results.tar" ] && tail -3 "$WORK/out/job.log"
