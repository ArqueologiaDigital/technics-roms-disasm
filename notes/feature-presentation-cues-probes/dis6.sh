#!/bin/bash
# dis6.sh START END -- disassemble the linear KN6000 program image (base 0x48400000) with unidasm;
# copy of tmp/kn6000-pres/dis6.sh that slices into this directory instead of a shared path.
S=$(( $1 )); E=$(( $2 )); OUT=${TMPDIR:-$HOME/compartilhado/tmp}/dis6_slice.bin
python3 -I -c "
d=open('/home/fsanches/compartilhado/tmp/kn6000_prog.bin','rb').read()
open('$OUT','wb').write(d[$S-0x48400000:$E-0x48400000])"
/home/fsanches/compartilhado/kn7000_mame_build/unidasm $OUT -arch mn10300 -basepc $(printf '0x%x' $S)
