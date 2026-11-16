#!/bin/bash
# Checks slot_ok (../slot_ok.sh): only $ORACLE/vm/home/slot-<digits>, resolved, is accepted.  Read-only: it only prints.
# usage: bash scripts/analysis/cc900/oracle/tests/slot_ok_test.sh      exit 0 when every case gives its expected answer
ORACLE=${ORACLE:-$HOME/compartilhado/cc900-oracle}
. "$(dirname "$(realpath "$0")")/../slot_ok.sh"
H=$ORACLE/vm/home
fails=0
check() {                        # check EXPECTED PATH
    local got=refuse
    slot_ok "$2" && got=ACCEPT
    printf '%-7s %-7s %s\n' "$got" "($1)" "$2"
    [ "$got" = "$1" ] || fails=$((fails + 1))
}
check ACCEPT "$H/slot-1"
check ACCEPT "$H/slot-12"
check ACCEPT "$H/slot-2/"
check refuse "$H/slot-1/../.."
check refuse "$H/slot-1x"
check refuse "$H/slot-"
check refuse "$H"
check refuse "/"
echo "$fails failure(s)"
[ "$fails" = 0 ]
