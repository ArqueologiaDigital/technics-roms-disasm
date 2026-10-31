#!/usr/bin/env python3
"""fontid_table_writers.py -- does any code write the RAM copy of FontIDProc_FontNameTable?

QUESTION IT ANSWERS (open item N-d4782271)
  Boot_InitWorkRAM copies FontIDProc_FontNameTable (32 x u32 font-name pointers) to RAM FONTID_NAME_TABLE
  (0x3efac in v10/v9/v7, 0x3efa8 in v6/v5).  Are the names the firmware shows the boot image's, or does
  something rewrite the list at run time?
METHOD
  Linear-disassembles each rebuilt main-CPU image with MAME's unidasm and lists every instruction with an
  immediate or memory operand inside [table, table + 0x80).  A writer would show up as a store to such an
  address or as a load of the base into a register followed by stores through it; the listing is read by
  hand for the latter.  Coincidental byte patterns inside other instructions do not appear, because the
  operand has to be decoded as one.
SIGNAL
  2026-10-31: in every tree exactly three hits, all in FontIDProc: `ld xbc, table` (EVT_GET_PROP_DATA_SP),
  `ld xbc, table` (EVT_GET/DUMP_PROPERTY_EX) and `ld xwa, table` (EVT_SET_PROPERTY_EX's Strcmp loop), each
  followed only by reads of (xbc/xwa + 4n).  No store.  The four HD-AE5000 images: no hit.  So the list
  is the boot image's.
RUN (repository root, after `make all`)
  python3 notes/kn5000-a-2026-10-31/probes/fontid_table_writers.py [UNIDASM]
"""
import os
import re
import subprocess
import sys

UNIDASM = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser("~/compartilhado/mame-sony-video/unidasm")
IMAGES = [("v10", "kn5000_v10_program", 0xe00000, 0x3efac), ("v9", "kn5000_v9_program", 0xe00000, 0x3efac),
          ("v7", "kn5000_v7_program", 0xe00000, 0x3efac), ("v6", "kn5000_v6_program", 0xe00000, 0x3efa8),
          ("v5", "kn5000_v5_program", 0xe00000, 0x3efa8),
          # the HD-AE5000 runs beside v10 / v9 (and v7): does the expansion ROM touch the list?
          ("hdae v2.06i", "hd-ae5000_v2_06i", 0x280000, 0x3efac), ("hdae v2.01i", "hd-ae5000_v2_01i", 0x280000, 0x3efac),
          ("hdae v1.15i", "hd-ae5000_v1_15i", 0x280000, 0x3efac), ("hdae v1.10i", "hd-ae5000_v1_10i", 0x280000, 0x3efac)]
for tree, image, pc, base in IMAGES:
    rom = "rebuilt_ROMs/%s.llvm.rom" % image
    out = subprocess.run([UNIDASM, rom, "-arch", "tlcs900", "-basepc", hex(pc)], capture_output=True,
                         text=True, errors="replace").stdout
    hits = []
    for line in out.split("\n"):
        if ":" not in line:
            continue
        ins = line.split(":", 1)[1][20:]
        if any(base <= int(m, 16) < base + 0x80 for m in re.findall(r"0x([0-9a-fA-F]+)", ins)):
            hits.append(line.strip())
    print("%s  table 0x%x  %d operand hits" % (tree, base, len(hits)))
    for h in hits:
        print("    " + h)
