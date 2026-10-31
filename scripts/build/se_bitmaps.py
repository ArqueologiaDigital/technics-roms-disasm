#!/usr/bin/env python3
"""se_bitmaps.py -- the SOUND EDIT screens' 13 one-bit bitmaps <-> PNGs, ROUND TRIP.

QUESTION ANSWERED: can the radio buttons, pattern tiles and envelope-curve pictures of the KN5000's
SOUND EDIT screens be PNG files a viewer opens, and still rebuild the ROM byte for byte?

Until 2026-10-30 (lane media-files) they were `.byte 0b........` rows in
<tree>/maincpu/audio/sound_editor_ui.s.  Now each is <tree>/maincpu/images/<label>.png and the source
`.incbin`s <tree>/maincpu/images/<label>.bin, which `build` writes from the PNG (the same flow as
mono_images.py).  Since 2026-10-31 (lane media-build) the .bin is a git-ignored build product, like its
siblings in images/; the PNG is the only committed copy.

FORMAT (the header comment above each label in sound_editor_ui.s): 1 bit per pixel, stored column by
column: W/8 byte-columns of H rows, each byte 8 horizontal pixels with bit 7 leftmost ("bit 7 is
tested first"); drawn by static op 03 through ColorBlit2_LargeCodeBlock, the static op03 records the
header names.  SeBitmap_Picture40x40 has no reader (its header says so) and is read the same way as
the six SeBitmap_EnvCurve* it follows.  The PNG is mode '1' (1 = ink).

    python3 scripts/build/se_bitmaps.py export    # .s rows -> PNG (run once, every revision)
    python3 scripts/build/se_bitmaps.py respell   # .s rows -> one .incbin line each (run once)
    python3 scripts/build/se_bitmaps.py build     # PNG -> .bin (build step, every revision)
    python3 scripts/build/se_bitmaps.py verify    # assert PNG -> .bin round-trips, every revision
"""
import pathlib
import re
import sys

from PIL import Image

REPO = pathlib.Path(__file__).resolve().parent.parent.parent
TREES = ['v5', 'v6', 'v7', 'v9', 'v10']
SRC = 'maincpu/audio/sound_editor_ui.s'
ITEMS = [('SeBitmap_Pattern24x10_1', 24, 10), ('SeBitmap_Pattern24x10_2', 24, 10),
         ('SeBitmap_Pattern24x10_3', 24, 10), ('SeBitmap_Pattern24x10_4', 24, 10),
         ('SeBitmap_RadioOn', 16, 12), ('SeBitmap_RadioOff', 16, 12),
         ('SeBitmap_EnvCurve1', 40, 40), ('SeBitmap_EnvCurve2', 40, 40), ('SeBitmap_EnvCurve3', 40, 40),
         ('SeBitmap_EnvCurve4', 40, 40), ('SeBitmap_EnvCurve5', 40, 40), ('SeBitmap_EnvCurve6', 40, 40),
         ('SeBitmap_Picture40x40', 40, 40)]
ROW = re.compile(rb'^\s*\.byte\s+0b([01]{8})\s*$')
COL = re.compile(rb'^\s*; column \d+')
MARK = b'; census: generated -- scripts/build/se_bitmaps.py, from the .png beside it'


def rows_block(lines, name):
    """(first, end, bytes) of the label line and its .byte rows in the source"""
    for i, l in enumerate(lines):
        if l.rstrip() == name.encode() + b':':
            out, j = bytearray(), i + 1
            while j < len(lines) and (ROW.match(lines[j]) or COL.match(lines[j])):
                m = ROW.match(lines[j])
                if m:
                    out.append(int(m.group(1), 2))
                j += 1
            return i, j, bytes(out)
    return None


def to_png(raw, w, h, path):
    img = Image.new('1', (w, h), 0)
    px = img.load()
    for c in range(w // 8):
        for y in range(h):
            b = raw[c * h + y]
            for bit in range(8):
                if b & (0x80 >> bit):
                    px[8 * c + bit, y] = 1
    img.save(path)


def from_png(path, w, h):
    img = Image.open(path).convert('1')
    assert img.size == (w, h), f'{path}: {img.size}, expected {(w, h)}'
    px = img.load()
    return bytes(sum((0x80 >> bit) for bit in range(8) if px[8 * c + bit, y])
                 for c in range(w // 8) for y in range(h))


def export():
    for t in TREES:
        lines = (REPO / t / SRC).read_bytes().split(b'\n')
        for name, w, h in ITEMS:
            blk = rows_block(lines, name)
            if blk is None:
                sys.exit(f'{t}: {name} is not .byte rows any more (already respelled?)')
            raw = blk[2]
            assert len(raw) == w // 8 * h, f'{t} {name}: {len(raw)} bytes, expected {w // 8 * h}'
            png = REPO / t / 'maincpu/images' / f'{name}.png'
            to_png(raw, w, h, png)
            assert from_png(png, w, h) == raw
            (REPO / t / 'maincpu/images' / f'{name}.bin').write_bytes(raw)
        print(f'exported {len(ITEMS)} bitmaps of {t}')


def respell():
    for t in TREES:
        path = REPO / t / SRC
        lines = path.read_bytes().split(b'\n')
        for name, w, h in ITEMS:
            blk = rows_block(lines, name)
            if blk is None:
                continue
            i, j, raw = blk
            assert raw == (REPO / t / 'maincpu/images' / f'{name}.bin').read_bytes(), f'{t} {name}: .bin differs'
            lines[i:j] = [b'%s:\t.incbin\t"images/%s.bin"\t%s' % (name.encode(), name.encode(), MARK)]
        path.write_bytes(b'\n'.join(lines))
        print(f'respelled {t}/{SRC}')


def build():
    for t in TREES:
        for name, w, h in ITEMS:
            d = REPO / t / 'maincpu/images'
            raw = from_png(d / f'{name}.png', w, h)
            out = d / f'{name}.bin'
            if not out.exists() or out.read_bytes() != raw:
                out.write_bytes(raw)
    print(f'se_bitmaps.py: {len(ITEMS)} bitmaps x {len(TREES)} revisions from PNG')


def verify():
    bad = 0
    for t in TREES:
        for name, w, h in ITEMS:
            d = REPO / t / 'maincpu/images'
            if from_png(d / f'{name}.png', w, h) != (d / f'{name}.bin').read_bytes():
                print(f'FAIL  {t} {name}')
                bad += 1
    print(f'se_bitmaps.py verify: {len(ITEMS) * len(TREES) - bad} of {len(ITEMS) * len(TREES)} round-trip')
    return 1 if bad else 0


if __name__ == '__main__':
    cmd = sys.argv[1] if len(sys.argv) > 1 else ''
    if cmd not in ('export', 'respell', 'build', 'verify'):
        sys.exit(__doc__)
    sys.exit({'export': export, 'respell': respell, 'build': build, 'verify': verify}[cmd]() or 0)
