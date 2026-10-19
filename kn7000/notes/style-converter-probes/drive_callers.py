#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# drive_callers.py -- does STYLE CONVERT ever point the fmm file layer at the SD card?
#
# The fmm layer (fmmopen/fmmread/... and the directory listing) dispatches on a drive byte
# (941: 0x5007125A; 0 floppy, 1 SD, 2 third backend). One leaf sets it, `cmp 3, d1; bge; movbu
# d0, (drive)`, followed by a twin that sets 0. This finds both in a program image by those
# bytes, lists every `call` to them, and counts the ones inside the STYLE CONVERT code
# (0x48478000-0x4847B000: the *.CNV listing, the load and the mailbox loop).
#   python3 -I drive_callers.py UNIDASM baserom/kn7000_program.rom [baserom/kn7000_program_sp7001.rom]
import collections
import os
import re
import subprocess
import sys

BASE = 0x48400000
LO, HI = 0x48478000, 0x4847B000
unidasm = sys.argv[1]
for rom in sys.argv[2:]:
    d = open(rom, "rb").read()
    m = re.search(rb"\x81\x15\xa5\x03\xc2\x08\xfc\x82(....)\xde\x00\x00\x00\xfc\x82", d, re.S)
    setter, drive = BASE + m.start(), int.from_bytes(m.group(1), "little")
    zero = setter + 15
    cnv = BASE + d.find(b"\x02\x00*.CNV")
    tmp = os.path.join(os.environ.get("TMPDIR", "."), f"drive_callers_{os.getpid()}.bin")
    try:
        open(tmp, "wb").write(d)
        txt = subprocess.run([unidasm, tmp, "-arch", "mn10300", "-basepc", hex(BASE)],
                             capture_output=True, text=True, check=True).stdout
    finally:
        os.remove(tmp)
    calls = collections.defaultdict(list)
    for l in txt.splitlines():
        if (mm := re.match(r"^([0-9a-f]{8}):.*\scall\s+0x([0-9a-f]{8}),", l)):
            t = int(mm.group(2), 16)
            if t in (setter, zero):
                calls[t].append(int(mm.group(1), 16))
    print(f"{os.path.basename(rom)}: drive byte 0x{drive:08X}, set 0x{setter:08X}, set-0 0x{zero:08X}, "
          f"'*.CNV' pattern 0x{cnv:08X}")
    for t, name in ((setter, "set"), (zero, "set-0")):
        by = collections.Counter(f"0x{a >> 16:04X}xxxx" for a in calls[t])
        inside = [a for a in calls[t] if LO <= a < HI]
        print(f"  {name:6} {len(calls[t]):3} callers {dict(sorted(by.items()))}; "
              f"inside STYLE CONVERT: {len(inside)}")
