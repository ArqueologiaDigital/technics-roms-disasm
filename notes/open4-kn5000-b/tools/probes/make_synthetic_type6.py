#!/usr/bin/env python3
"""make_synthetic_type6.py -- build a type-6 (HD-AE5000) update disc image to exercise
scripts/analysis/parse_update_disc.py's type-6 path, since no original type-6 disc image is on the machine.

It takes the original v10 update disc (a type-7 disc), replaces logical sector 33 with the TECHNICS.AE
signature text of system-update-discs.md and puts the tracked original_ROMs/hd-ae5000_v2_06i.ic4 at logical
sector 36, the two places HANDLE_UPDATE_FILE_TYPE_ID_006h's path reads.  The FAT is not rewritten (the
firmware does not read it), so the FAT view still lists the v10 disc's files.

    python3 notes/open4-kn5000-b/tools/probes/make_synthetic_type6.py V10_DISK.img OUT.img
    python3 scripts/analysis/parse_update_disc.py OUT.img
Expected: type 6, payload SHA-1 c4da28f0ad16b1288774af761b3729142e8050b3 = HD-AE5000 v2.06i, XAPR at +0x0.
Write OUT into a scratch directory; never commit it.
"""
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..', '..'))
src, out = sys.argv[1], sys.argv[2]
d = bytearray(open(src, 'rb').read())
sig = b"Technics KN5000 HD-AEPRG DATA FILE      by Nishino Teruhiko !!!\r\n\n"
d[0x4200:0x4400] = sig + bytes(512 - len(sig))
rom = open(os.path.join(ROOT, 'original_ROMs', 'hd-ae5000_v2_06i.ic4'), 'rb').read()
d[0x4800:0x4800 + len(rom)] = rom
open(out, 'wb').write(d)
