# Sourced by run_oracle.sh and vm_slot.sh (and tests/slot_ok_test.sh); defines one function and does nothing else.
#
# slot_ok DIR: true when DIR, resolved (realpath -m), is exactly $ORACLE/vm/home/slot-<digits>, resolved, with
# nothing after it -- so that `slot-1/../..`, `slot-1x`, `slot-` or the home directory itself are refused.  Every
# creation or removal of a slot's work directory checks it first.
slot_ok() {
    local p base rest
    p=$(realpath -m -- "$1")
    base=$(realpath -m -- "$ORACLE/vm/home")
    rest=${p#"$base"/slot-}
    [[ $p != "$rest" && $rest =~ ^[0-9]+$ ]]
}
