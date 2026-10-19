#!/usr/bin/env python3
"""Question: how big is a BMP file of a given size/depth, and does it fit the debug loader's
fixed read length 0x18000 and the picture import's limit 0x4D800?  Also: how many 640-wide 8-bpp
rows fit in 0x18000 after the header+palette, and what end address a full 640x240 8-bpp draw reads.
File size = 14 + 40 + 4*colours (bpp <= 8) + rows * stride, stride = ceil(w*bpp/32)*4.
usage: python3 bmp_sizes.py"""
def size(w, h, bpp, colours=None):
    pal = 0 if bpp > 8 else 4 * (colours if colours else (1 << bpp))
    return 14 + 40 + pal + h * (((w * bpp + 31) // 32) * 4)
cases = [(640, 240, 8, None, 'full LCD 8 bpp'), (640, 240, 4, None, 'full LCD 4 bpp = LCDCAPnn.BMP in LCD mode 2'),
         (640, 240, 24, None, 'full LCD 24 bpp = LCDCAPnn.BMP in colour mode'), (640, 240, 1, None, 'full LCD 1 bpp'),
         (320, 240, 8, None, '320x240 8 bpp'), (640, 151, 8, None, '640x151 8 bpp'), (640, 152, 8, None, '640x152 8 bpp'),
         (160, 100, 8, None, 'homepage 160x100 8 bpp'), (640, 480, 8, None, '640x480 8 bpp')]
rows = [('image', 'bytes', 'hex', '<=0x18000', '<=0x4D800')]
for w, h, b, c, label in cases:
    n = size(w, h, b, c)
    rows.append(('%dx%d %d bpp (%s)' % (w, h, b, label), '{:,}'.format(n), hex(n), 'yes' if n <= 0x18000 else 'no', 'yes' if n <= 0x4D800 else 'no'))
wd = [max(len(r[i]) for r in rows) for i in range(5)]
for k, r in enumerate(rows):
    print('| ' + ' | '.join(r[i].ljust(wd[i]) for i in range(5)) + ' |')
    if k == 0: print('|' + '|'.join('-' * (wd[i] + 2) for i in range(5)) + '|')
print('640-wide 8-bpp rows wholly inside 0x18000 after 1078-byte header:', (0x18000 - 1078) // 640)
print('last byte read by a 640x240 8-bpp draw: %#x' % (0x502B8000 + size(640, 240, 8) - 1))
print('LCDCAP mode-2 header bfSize field 0x12C36 = %d; bytes actually written = %d' % (0x12C36, 14 + 40 + 64 + 30 * 0xA00))
