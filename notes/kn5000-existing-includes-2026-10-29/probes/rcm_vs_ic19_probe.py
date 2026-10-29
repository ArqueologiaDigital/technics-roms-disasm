#!/usr/bin/env python3
"""rcm_vs_ic19_probe.py -- are the Initial Data Disk's RCM sections in the same bank format as IC19's?

The floppy lane (floppy/kn5000/formats.py, branch data/floppy-kn5000) types .CMP / .RCM style banks; this
lane types the custom-data flash banks (scripts/build/style_events.py, listing format 2).  This probe takes
01CTMINI.RCM out of the idd5000 floppy image (found as the "H\\0K\\0" header whose chunk-length table at
+0x40 starts with 0x400, the rule of formats.py's describe_rcm) and, for each of its sections 0..6, checks
against IC19's bank of the same section:
  HDR    header +0x00..+0x2d byte-identical
  USED   +0x2e * 16 == the RCM chunk length (the field FileIO_SaveRcmFromFlash reads to make that table)
  PTRS   the directory's part pointers: low 12 bits as in style_events.py, high nibble 0 in the RCM and
         section + 1 in IC19 (FileIO_LoadRcmToFlash stamps it; floppy notes, Pack12BitValueWithBank)
  CELLS  every 256-byte block from +0x1400 to the chunk's end has the cell shape (0x80/0x00, 0x87 at 5 and 255)
  FILLIN +0x13c0 opens with the 6-byte cell header 80 ffff ffff 87
It also says how many bytes of the section differ from IC19 (the content is a different set of styles).

    python3 notes/kn5000-existing-includes-2026-10-29/probes/rcm_vs_ic19_probe.py \
        ~/compartilhado/disasm-lanes/data-floppy-kn5000/floppy/kn5000/baserom/idd5000.img
(the floppy lane's git-ignored reference image; original_ROMs/kn5000_custom_data.ic19 from this repo)
"""
import struct, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
img = Path(sys.argv[1]).read_bytes()
ic = (ROOT / 'original_ROMs' / 'kn5000_custom_data.ic19').read_bytes()
o = next(i for i in range(0, len(img) - 0x44, 0x200)
         if img[i:i + 4] == b'H\0K\0' and struct.unpack_from('<I', img, i + 0x40)[0] == 0x400)
lens = struct.unpack_from('<9I', img, o + 0x40)
print(f'01CTMINI.RCM at image offset {o:#x}; chunk lengths {[hex(x) for x in lens]}')
FLASH = [0x300000, 0x319800, 0x330000, 0x349800, 0x360000, 0x379800, 0x390000]
p = o + 0x400
for k in range(7):
    n = lens[k + 1]
    a, b = img[p:p + n], ic[FLASH[k] - 0x300000:FLASH[k] - 0x300000 + n]
    hdr = a[:0x2e] == b[:0x2e]
    used = struct.unpack_from('<H', a, 0x2e)[0] * 16 == n
    pa = [struct.unpack_from('<H', a, 0x60 + 0x60 * r + 2 * w)[0] for r in range(30) for w in (0, 2, 3, 4, 5)]
    pb = [struct.unpack_from('<H', b, 0x60 + 0x60 * r + 2 * w)[0] for r in range(30) for w in (0, 2, 3, 4, 5)]
    ptrs = all(x >> 12 == 0 for x in pa) and all(y >> 12 == k + 1 for y in pb) and \
        [x & 0xFFF for x in pa] == [y & 0xFFF for y in pb]
    cells = all(a[c] in (0x80, 0) and a[c + 5] == 0x87 and a[c + 255] == 0x87 for c in range(0x1400, n, 256))
    fill = a[0x13c0:0x13c6] == bytes.fromhex('80ffffffff87')
    nd = sum(1 for x, y in zip(a, b) if x != y)
    print(f'  section {k}: {n:#7x} B  HDR {hdr}  USED {used}  PTRS {ptrs}  CELLS {cells}  FILLIN {fill}  '
          f'differs from IC19 in {nd:,} B')
    p += n
