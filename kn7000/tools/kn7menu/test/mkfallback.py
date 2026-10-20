#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# mkfallback.py -- the "fallback" test card for the program menu (run_menu_tests.sh fallback): folders whose
# manifest or icon is missing or malformed, a long-named folder, a folder without a program, a damaged and a
# foreign KN7APP.BIN. What the menu must show for it is fatscan.py's (menu_test.lua compares).
#   python3 -I test/mkfallback.py OUTDIR MENU_KN7APP.BIN RELEASES_DIR
import os
import random
import shutil
import struct
import sys

out, menu, releases = sys.argv[1:4]
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from png2icon import W, write_bmp  # noqa: E402

out = os.path.abspath(out)
parent = os.path.dirname(out)
assert os.path.isdir(parent) and out != parent and os.path.basename(out).startswith('fallback'), out
if os.path.isdir(out):
    shutil.rmtree(out)
os.makedirs(out)
rel = lambda p: open(os.path.join(releases, p, 'KN7APP.BIN'), 'rb').read()   # noqa: E731
cpu = rel('2026-10-20-cputime/sdcard-pass9-CPUTIME')
rate = rel('2026-10-20-dsprate/sdcard-pass8-DSPRATE')


def put(folder, name, data):
    os.makedirs(os.path.join(out, folder), exist_ok=True)
    with open(os.path.join(out, folder, name), 'wb') as f:
        f.write(data if isinstance(data, bytes) else data.encode('latin1'))


def bmp_topdown32():
    """32x32, 32 bits per pixel, rows top-down (negative height), a 124-byte V5 header as GIMP writes"""
    px = b''.join(bytes((x * 8, y * 8, 255 - x * 8, 0)) for y in range(W) for x in range(W))   # B, G, R, X
    off = 14 + 124
    hdr = struct.pack('<IiiHHIIiiII', 124, W, -W, 1, 32, 0, len(px), 2835, 2835, 0, 0) + bytes(124 - 40)
    return b'BM' + struct.pack('<IHHI', off + len(px), 0, 0, off) + hdr + px


shutil.copyfile(menu, os.path.join(out, 'KN7APP.BIN'))
put('My Long Program Name', 'KN7APP.BIN', cpu)                     # a long name, no manifest
put('SHORTNM', 'KN7APP.BIN', rate)                                  # an 8.3 name, no manifest
put('BADMAN', 'KN7APP.BIN', rate)                                   # a manifest of nothing usable
put('BADMAN', 'MANIFEST.TXT', bytes(range(1, 32)) + b'\nNAME=\nNAME =   \nICON=bad*name.bmp\nICON=TOOLONGNAME.BMP\n')
put('MISSICON', 'KN7APP.BIN', rate)                                 # the icon it names is not there
put('MISSICON', 'MANIFEST.TXT', 'NAME=Missing icon file, and a name longer than a row has room for, by far\n'
    'ICON=NOPE.BMP\n')
put('WRONGBMP', 'KN7APP.BIN', rate)                                 # an icon of the wrong size
put('WRONGBMP', 'MANIFEST.TXT', 'NAME=Wrong-size icon\r\nICON=ICON.BMP\r\n')
small = write_bmp([[(255, 0, 0)] * W] * W)
small = small[:18] + struct.pack('<ii', 16, 16) + small[26:]        # says 16 x 16
put('WRONGBMP', 'ICON.BMP', small)
put('TOPDOWN', 'KN7APP.BIN', cpu)                                   # BOM, lower-case keys, blanks, a V5 BMP
put('TOPDOWN', 'MANIFEST.TXT', b'\xef\xbb\xbf# comment\r\n  name =  Top-down 32-bit icon  \r\n\ticon= topdown.bmp\r\n'
    b'OTHER=ignored\r\n')
put('TOPDOWN', 'TOPDOWN.BMP', bmp_topdown32())
put('NOAPP', 'MANIFEST.TXT', 'NAME=Not a program: no KN7APP.BIN here\n')   # not listed
put('NOAPP', 'README.TXT', 'nothing to run\n')
bad = bytearray(rate)
bad[0x1000] ^= 0xFF
put('BADCRC', 'KN7APP.BIN', bytes(bad))                             # damaged: CRC-32
put('BADCRC', 'MANIFEST.TXT', 'NAME=Damaged copy (one byte changed)\n')
put('BADHDR', 'KN7APP.BIN', bytes(random.Random(5).randrange(256) for _ in range(1000)))   # not an application
put('BADHDR', 'MANIFEST.TXT', 'NAME=Not an application at all\n')
print(f'mkfallback: {out}')
