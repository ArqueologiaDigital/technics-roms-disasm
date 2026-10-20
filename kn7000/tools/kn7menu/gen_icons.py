#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# gen_icons.py -- the icons this project ships, drawn by code (no image files in the repository):
#   python3 -I gen_icons.py --inc default_icon.inc     the menu's built-in default icon (RGB565 .word data)
#   python3 -I gen_icons.py --png NAME OUT.png          one card icon as a 32x32 PNG, for png2icon.py
#   python3 -I gen_icons.py --list                      the names
# NAME: default, aw (Another World), survey2, dspprobe, dspmem, dsprate, cputime (the ROM dumper's passes
# 5 to 9). The PNGs go through png2icon.py on their way to the card, as anyone's own icon would.
import struct
import sys
import zlib

W = 32

FONT5 = {  # 3x5 digits and a few letters, rows top to bottom, bit 2 = left
    '0': [7, 5, 5, 5, 7], '1': [2, 6, 2, 2, 7], '2': [7, 1, 7, 4, 7], '3': [7, 1, 7, 1, 7],
    '4': [5, 5, 7, 1, 1], '5': [7, 4, 7, 1, 7], '6': [7, 4, 7, 5, 7], '7': [7, 1, 2, 2, 2],
    '8': [7, 5, 7, 5, 7], '9': [7, 5, 7, 1, 7], 'A': [7, 5, 7, 5, 5], 'C': [7, 4, 4, 4, 7],
    'D': [6, 5, 5, 5, 6], 'M': [5, 7, 7, 5, 5], 'P': [7, 5, 7, 4, 4], 'R': [6, 5, 6, 5, 5],
    'S': [7, 4, 7, 1, 7], 'T': [7, 2, 2, 2, 2], 'U': [5, 5, 5, 5, 7], 'W': [5, 5, 7, 7, 5],
    'E': [7, 4, 6, 4, 7], 'V': [5, 5, 5, 5, 2], 'Y': [5, 5, 2, 2, 2], 'I': [7, 2, 2, 2, 7],
}


class Canvas:
    def __init__(self, bg):
        self.px = [[bg] * W for _ in range(W)]

    def put(self, x, y, c):
        if 0 <= x < W and 0 <= y < W:
            self.px[y][x] = c

    def rect(self, x, y, w, h, c):
        for j in range(y, y + h):
            for i in range(x, x + w):
                self.put(i, j, c)

    def disc(self, cx, cy, r, c):
        for j in range(W):
            for i in range(W):
                if (i - cx) ** 2 + (j - cy) ** 2 <= r * r:
                    self.put(i, j, c)

    def ring(self, cx, cy, r, c):
        for j in range(W):
            for i in range(W):
                d = (i - cx) ** 2 + (j - cy) ** 2
                if (r - 1) ** 2 <= d <= r * r:
                    self.put(i, j, c)

    def line(self, x0, y0, x1, y1, c):
        n = max(abs(x1 - x0), abs(y1 - y0), 1)
        for k in range(n + 1):
            self.put(round(x0 + (x1 - x0) * k / n), round(y0 + (y1 - y0) * k / n), c)

    def text(self, s, x, y, c, scale=1):
        for ch in s:
            for r, bits in enumerate(FONT5[ch]):
                for b in range(3):
                    if bits & (4 >> b):
                        self.rect(x + b * scale, y + r * scale, scale, scale, c)
            x += 4 * scale


def chip(cv, body, pins):
    cv.rect(6, 6, 20, 20, body)
    for k in range(4):
        p = 8 + k * 5
        cv.rect(p, 3, 2, 3, pins)
        cv.rect(p, 26, 2, 3, pins)
        cv.rect(3, p, 3, 2, pins)
        cv.rect(26, p, 3, 2, pins)


def icon(name):
    if name == 'default':                       # a window: title bar, two lines of text
        cv = Canvas((0, 0, 0))
        cv.rect(3, 4, 26, 24, (200, 200, 200))
        cv.rect(4, 5, 24, 5, (0, 0, 160))
        cv.rect(25, 6, 2, 2, (255, 255, 255))
        cv.rect(4, 10, 24, 17, (240, 240, 240))
        cv.rect(7, 14, 16, 2, (90, 90, 90))
        cv.rect(7, 19, 12, 2, (90, 90, 90))
        cv.rect(7, 23, 8, 2, (0, 160, 0))
        return cv
    if name == 'aw':                            # Another World: a dusk sky, its planet, black rock
        cv = Canvas((0, 0, 0))
        for y in range(W):
            cv.rect(0, y, W, 1, (40 + y * 4, 20 + y * 2, 90 - y))
        cv.disc(21, 10, 7, (250, 170, 60))
        cv.disc(21, 10, 5, (255, 210, 120))
        for x in range(W):
            top = 22 + int(3 * ((x * 7) % 5) / 4) - (4 if 8 <= x <= 13 else 0)
            cv.rect(x, top, 1, W - top, (10, 8, 12))
        cv.rect(10, 13, 2, 5, (10, 8, 12))      # a figure on the rock
        cv.rect(9, 15, 4, 1, (10, 8, 12))
        cv.text('AW', 1, 26, (250, 250, 250))
        return cv
    passes = {'survey2': ('5', (40, 90, 170)), 'dspprobe': ('6', (150, 60, 160)),
              'dspmem': ('7', (160, 90, 40)), 'dsprate': ('8', (40, 140, 90)),
              'cputime': ('9', (170, 50, 50))}
    if name in passes:                          # the ROM dumper's passes: a chip, its colour, its number
        digit, col = passes[name]
        cv = Canvas((0, 0, 0))
        chip(cv, (40, 40, 44), (190, 190, 190))
        cv.rect(8, 8, 16, 16, col)
        cv.text(digit, 10, 9, (255, 255, 255), scale=2)
        if name.startswith('dsp'):              # a wave under the number
            for x in range(8, 24):
                cv.put(x, 21 + (1 if (x // 2) % 2 else -1), (255, 255, 160))
        elif name == 'cputime':
            cv.ring(16, 16, 15, (255, 255, 255))
        else:
            cv.ring(24, 24, 5, (255, 255, 160))
            cv.line(27, 27, 30, 30, (255, 255, 160))
        return cv
    raise SystemExit(f'gen_icons: no icon named {name!r}')


NAMES = ['default', 'aw', 'survey2', 'dspprobe', 'dspmem', 'dsprate', 'cputime']


def png_bytes(cv):
    raw = b''.join(b'\0' + bytes(v for p in row for v in p) for row in cv.px)

    def chunk(t, d):
        return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', W, W, 8, 2, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b''))


def rgb565(p):
    r, g, b = p
    return ((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3)


def main():
    a = sys.argv[1:]
    if a[:1] == ['--list']:
        print(' '.join(NAMES))
    elif a[:1] == ['--png'] and len(a) == 3:
        open(a[2], 'wb').write(png_bytes(icon(a[1])))
    elif a[:1] == ['--inc'] and len(a) == 2:
        cv = icon('default')
        with open(a[1], 'w') as f:
            f.write('# generated by gen_icons.py --inc: the menu\'s default icon, 32x32 RGB565; do not edit\n')
            f.write('DefaultIcon:\n')
            for row in cv.px:
                f.write('    .word   ' + ', '.join(f'0x{rgb565(p):04x}' for p in row) + '\n')
    else:
        sys.exit(__doc__ if False else 'usage: gen_icons.py --inc OUT | --png NAME OUT.png | --list')


if __name__ == '__main__':
    main()
