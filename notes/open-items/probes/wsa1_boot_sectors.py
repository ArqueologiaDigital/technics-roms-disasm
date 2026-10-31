#!/usr/bin/env python3
"""Question: are the nine WSA1R floppy boot sectors (census: opaque -- code, floppy/wsa1/*/boot.s) one and the same
Windows 9x boot sector?  Prints each image's OEM name (bytes 3..10) and the SHA-1 of its boot code, bytes
0x3E..0x1FD, from the git-ignored references in floppy/wsa1/baserom/.
Usage: python3 notes/open-items/probes/wsa1_boot_sectors.py [repo root]"""
import hashlib, sys
from pathlib import Path
root = Path(sys.argv[1] if len(sys.argv) > 1 else Path(__file__).resolve().parents[3])
codes = set()
for img in sorted((root / "floppy/wsa1/baserom").glob("*.img")):
    d = img.read_bytes()[:512]
    h = hashlib.sha1(d[0x3E:0x1FE]).hexdigest()
    codes.add(h)
    print(f"{img.name:16} OEM {d[3:11]!r:14} boot code sha1 {h}  signature {d[510:512].hex()}")
print("distinct boot codes:", len(codes))
