#!/usr/bin/env python3
"""swap_framing_probe.py -- which of the two IC14 images the firmware's track pointers fit.

QUESTION: is the descrambled image (A19/A21 swap undone) the one the CPU sees?  For every record half,
part and slot, the target bank * 0x10000 + word (record +0x3D1, +0x118 + 0x26 * part + 2 * slot) should hold
a track header 80 FF FF FF FF 87.  Counts the hits in both images.  [Measured 2026-10-29: descrambled
46,056 of 46,056; raw read 17,608 of 46,056 -- headers are dense, so the raw figure is partly chance.]
USAGE: python3 notes/rhythm-data-ic14-2026-10-29/probes/swap_framing_probe.py
"""
import os
from ic14_common import REPO, u16

HDR = bytes.fromhex("80ffffffff87")
for name in ("kn5000_rhythm_data_rom.ic14", "kn5000_rhythm_data_rom.ic14.as-read-a19a21-swapped"):
    d = open(os.path.join(REPO, "original_ROMs", name), "rb").read()
    ok = n = 0
    for h in range(0, 0x65000, 0x400):
        b = d[h + 0x3d1]
        for part in range(6):
            for s in range(19):
                t = b * 0x10000 + u16(d, h + 0x118 + 0x26 * part + 2 * s)
                n += 1
                ok += d[t:t + 6] == HDR
    print("%-52s %6d of %d slot targets hold a track header" % (name, ok, n))
