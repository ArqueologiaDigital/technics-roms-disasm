#!/bin/bash
# Run a command in a slot of the oracle VM pool, holding that slot for the command's whole life.
#
# usage: vm_slot.sh [--exclusive] COMMAND [ARG ...]
#
# The pool has VM_POOL_SLOTS slots (default 3).  Slot k has its own lock $ORACLE/vm/.runlock.k, its own work directory
# $ORACLE/vm/home/slot-k (serve/ and out/ for run_vm.sh) and its own HTTP port 8931 + k.  Every slot boots the shared
# disk overlay vm/home/disk.qcow2 with -snapshot (run_vm.sh, VM_SNAPSHOT=1): the guests only read it, so several run
# at once.
#
# $ORACLE/vm/.runlock, the lock every VM user took before the pool, is now a readers-writer lock over the overlay:
#   - a pool user holds it SHARED for as long as it holds its slot;
#   - a writer holds it EXCLUSIVE: `vm_slot.sh --exclusive` (VM_SNAPSHOT=0, the overlay writable; for a one-off such as
#     the first Wine install), and any old-style `flock vm/.runlock ...` caller, which boots the overlay writable.
# So a writer waits until no slot is in use, and no slot starts while a writer runs; QEMU's own image locking would
# otherwise fail the later of a writer and a -snapshot reader of the same overlay.
#
# A pool user then tries each slot lock without blocking and takes the first free one; when all are busy it says so
# and retries every 2 s.  The command gets, in its environment: VM_SLOT (k), VM_PORT (8931 + k), VM_SLOT_DIR
# ($ORACLE/vm/home/slot-k, created), VM_SNAPSHOT (1, or 0 when exclusive), ORACLE.  The locks are flocks on open file
# descriptors that the command and its children (qemu) inherit, so they are released only when all of them exit.
set -euo pipefail
ORACLE=${ORACLE:-$HOME/compartilhado/cc900-oracle}
N=${VM_POOL_SLOTS:-3}
EXCLUSIVE=0
if [ "${1:-}" = --exclusive ]; then EXCLUSIVE=1; shift; fi
[ $# -ge 1 ] || { echo "usage: vm_slot.sh [--exclusive] COMMAND [ARG ...]" >&2; exit 2; }
[ -d "$ORACLE/vm" ] || { echo "vm_slot.sh: no VM directory $ORACLE/vm" >&2; exit 2; }
. "$(dirname "$(realpath "$0")")/slot_ok.sh"     # slot_ok: exactly $ORACLE/vm/home/slot-<digits>, resolved

run_in() {                       # run_in SLOT SNAPSHOT COMMAND...: the lock fds are open; exec the command
    local k=$1 snap=$2; shift 2
    [[ $k =~ ^[0-9]+$ ]] || { echo "vm_slot.sh: bad slot number $k" >&2; exit 2; }
    export ORACLE VM_SLOT=$k VM_PORT=$((8931 + k)) VM_SLOT_DIR="$ORACLE/vm/home/slot-$k" VM_SNAPSHOT=$snap
    slot_ok "$VM_SLOT_DIR" || { echo "vm_slot.sh: refusing slot directory $VM_SLOT_DIR" >&2; exit 2; }
    mkdir -p "$VM_SLOT_DIR"
    exec "$@"
}

# The old habit, `flock vm/.runlock bash run_oracle.sh ...`, holds .runlock EXCLUSIVE in our parent; taking it again
# here (another open file) would wait for ever.  The parent's lock already excludes every slot and writer, so run in
# slot 0 under it.
if tr '\0' ' ' < "/proc/$PPID/cmdline" 2>/dev/null | grep -Eq "^(/usr/bin/)?flock .*vm/\.runlock( |$)"; then
    echo "vm_slot.sh: the parent holds vm/.runlock (old-style flock): running in slot 0 under it; drop the flock to let runs go in parallel" >&2
    exec {fd}>>"$ORACLE/vm/.runlock.0"
    flock "$fd"
    run_in 0 1 "$@"
fi

exec {rw}>>"$ORACLE/vm/.runlock"
if [ $EXCLUSIVE = 1 ]; then
    flock -n -x "$rw" || { echo "vm_slot.sh: waiting until no VM slot is in use (exclusive mode) ..." >&2; flock -x "$rw"; }
    exec {fd}>>"$ORACLE/vm/.runlock.0"
    flock "$fd"                  # free: every slot holder also holds .runlock shared
    echo "vm_slot.sh: exclusive: the overlay is writable, no slot runs beside this one" >&2
    run_in 0 0 "$@"
fi

flock -n -s "$rw" || { echo "vm_slot.sh: waiting for a writer of the VM overlay to finish (vm/.runlock) ..." >&2
                       flock -s "$rw"; }
waited=0
while :; do
    for ((k = 0; k < N; k++)); do
        exec {fd}>>"$ORACLE/vm/.runlock.$k"
        if flock -n "$fd"; then
            [ $waited = 0 ] || echo "vm_slot.sh: got slot $k" >&2
            run_in $k 1 "$@"
        fi
        exec {fd}>&-
    done
    [ $waited = 1 ] || echo "vm_slot.sh: all $N VM slots are busy; waiting ..." >&2
    waited=1
    sleep 2
done
