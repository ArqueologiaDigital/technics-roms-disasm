#!/bin/bash
# show.sh LABEL FILE N: N code lines from LABEL, comments and blank lines dropped (run in v10/maincpu)
s=$(command grep -n "^$1:" "$2" | head -1 | cut -d: -f1)
tail -n +"$s" "$2" | sed 's/;.*//' | command grep -v '^[[:space:]]*$' | head -"$3"
echo ----
