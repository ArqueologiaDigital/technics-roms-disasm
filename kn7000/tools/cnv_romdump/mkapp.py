#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# mkapp.py -- turn an assembled application into the file KN7LOAD.CNV loads from the SD card: fills
# the header's size (AH_SIZE, +8) and CRC-32 of the bytes from AH_NAME (+0x20) to the end (AH_CRC,
# +0x10), after checking the magic "KN7A", the loader ABI and the link address (kn7cnv.inc).
#   python3 -I mkapp.py app.bin KN7APP.BIN
import struct
import sys
import zlib

APP_BASE, APP_MAX, ABI = 0x502BA000, 0x502E8000 - 0x502BA000, 1
src, out = sys.argv[1:3]
img = bytearray(open(src, 'rb').read())
magic, abi, _, entry, _, base = struct.unpack_from('<4sIIIII', img, 0)
assert magic == b'KN7A', 'not an application (magic)'
assert abi == ABI and base == APP_BASE, f'ABI {abi} / base {base:#x}'
assert 0x40 <= len(img) <= APP_MAX and APP_BASE + 0x40 <= entry < APP_BASE + len(img), 'size or entry'
struct.pack_into('<I', img, 8, len(img))
struct.pack_into('<I', img, 0x10, zlib.crc32(bytes(img[0x20:])) & 0xffffffff)
open(out, 'wb').write(img)
print(f'{out}: {len(img)} bytes, entry {entry:#x}, crc32 {zlib.crc32(bytes(img[0x20:])) & 0xffffffff:08x}, '
      f'"{img[0x20:0x40].rstrip(bytes(1)).decode("latin1")}"')
