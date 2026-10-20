#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# png2icon.py -- a program's icon for the KN7000 program menu, from a PNG (README.md, "The icon").
#   python3 -I png2icon.py IN.png ICON.BMP      convert: any size, scaled to 32x32 (area average when it
#                                               is larger, nearest pixel when smaller); transparency drawn
#                                               over black, the list's background
#   python3 -I png2icon.py --check ICON.BMP     would the menu take this file? (the same rules as its
#                                               DecodeBmp: "BM", a 40-byte or larger info header, 32 x 32
#                                               or 32 x -32, one plane, 24 or 32 bits, BI_RGB, long enough)
#   python3 -I png2icon.py --self-test
# The output is what the menu reads best: 32 x 32, 24 bits per pixel, uncompressed, bottom-up, a plain
# 40-byte BITMAPINFOHEADER: 3,126 bytes. No library is needed (the PNG is decoded here: 8- and 16-bit
# grey, RGB, palette (1, 2, 4, 8 bits), grey + alpha, RGBA; not interlaced).
import struct
import sys
import zlib

W = 32


def read_png(data):
    """-> (width, height, rows of (r, g, b, a) tuples)"""
    if data[:8] != b'\x89PNG\r\n\x1a\n':
        raise ValueError('not a PNG file')
    pos, idat, plte, trns, hdr = 8, b'', None, None, None
    while pos < len(data):
        n, t = struct.unpack_from('>I4s', data, pos)
        body = data[pos + 8:pos + 8 + n]
        pos += 12 + n
        if t == b'IHDR':
            hdr = struct.unpack('>IIBBBBB', body)
        elif t == b'PLTE':
            plte = [tuple(body[i:i + 3]) for i in range(0, len(body), 3)]
        elif t == b'tRNS':
            trns = body
        elif t == b'IDAT':
            idat += body
        elif t == b'IEND':
            break
    w, h, depth, ctype, _c, _f, interlace = hdr
    if interlace:
        raise ValueError('interlaced PNGs are not read: save it without interlacing')
    chans = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}[ctype]
    bpp = max(1, chans * depth // 8)                  # bytes per pixel, for the filters
    stride = (w * chans * depth + 7) // 8
    raw = zlib.decompress(idat)
    rows, prev, p = [], bytearray(stride), 0
    for _ in range(h):
        f, line = raw[p], bytearray(raw[p + 1:p + 1 + stride])
        p += 1 + stride
        for i in range(stride):
            a = line[i - bpp] if i >= bpp else 0
            b = prev[i]
            c = prev[i - bpp] if i >= bpp else 0
            if f == 1:
                line[i] = (line[i] + a) & 0xFF
            elif f == 2:
                line[i] = (line[i] + b) & 0xFF
            elif f == 3:
                line[i] = (line[i] + (a + b) // 2) & 0xFF
            elif f == 4:
                pa, pb, pc = abs(b - c), abs(a - c), abs(a + b - 2 * c)
                line[i] = (line[i] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 0xFF
        prev = line
        samples = []
        if depth < 8:
            for byte in line:
                for k in range(8 // depth - 1, -1, -1):
                    samples.append((byte >> (k * depth)) & ((1 << depth) - 1))
        elif depth == 8:
            samples = list(line)
        else:
            samples = [line[i] for i in range(0, len(line), 2)]   # 16-bit: the high byte
        px = []
        for x in range(w):
            s = samples[x * chans:(x + 1) * chans]
            if ctype == 3:
                r, g, b = plte[s[0]]
                a = trns[s[0]] if trns and s[0] < len(trns) else 255
            else:
                if depth < 8:
                    s = [v * 255 // ((1 << depth) - 1) for v in s]
                if ctype == 0:
                    r = g = b = s[0]
                    a = 255
                elif ctype == 4:
                    r = g = b = s[0]
                    a = s[1]
                elif ctype == 2:
                    r, g, b = s
                    a = 255
                else:
                    r, g, b, a = s
            px.append((r, g, b, a))
        rows.append(px)
    return w, h, rows


def to_icon(w, h, rows):
    """-> 32 x 32 (r, g, b), transparency over black"""
    out = []
    for y in range(W):
        line = []
        for x in range(W):
            if w >= W and h >= W:                       # area average
                x0, x1 = x * w // W, max(x * w // W + 1, (x + 1) * w // W)
                y0, y1 = y * h // W, max(y * h // W + 1, (y + 1) * h // W)
                acc, n = [0, 0, 0], 0
                for yy in range(y0, y1):
                    for xx in range(x0, x1):
                        r, g, b, a = rows[yy][xx]
                        acc[0] += r * a
                        acc[1] += g * a
                        acc[2] += b * a
                        n += 1
                line.append(tuple(v // (255 * n) for v in acc))
            else:                                       # nearest
                r, g, b, a = rows[y * h // W][x * w // W]
                line.append((r * a // 255, g * a // 255, b * a // 255))
        out.append(line)
    return out


def write_bmp(px):
    stride = W * 3
    pixels = b''.join(bytes(v for p in row for v in (p[2], p[1], p[0]))
                      for row in reversed(px))
    assert len(pixels) == stride * W
    off = 14 + 40
    return (b'BM' + struct.pack('<IHHI', off + len(pixels), 0, 0, off)
            + struct.pack('<IiiHHIIiiII', 40, W, W, 1, 24, 0, len(pixels), 2835, 2835, 0, 0) + pixels)


def check_bmp(b):
    """-> None when the menu takes it, else why not (menu_card.s DecodeBmp)"""
    if len(b) < 54 or b[:2] != b'BM':
        return 'not a BMP file'
    off, hsize = struct.unpack_from('<II', b, 10)
    w, h, planes, bpp, comp = struct.unpack_from('<iiHHI', b, 18)
    if hsize < 40:
        return f'an old {hsize}-byte header (needs BITMAPINFOHEADER or later)'
    if w != W or h not in (W, -W):
        return f'{w} x {h} pixels (needs 32 x 32)'
    if planes != 1 or bpp not in (24, 32):
        return f'{bpp} bits per pixel (needs 24 or 32)'
    if comp != 0:
        return f'compression {comp} (needs BI_RGB, uncompressed)'
    if off >= len(b) or off + W * W * bpp // 8 > len(b):
        return 'too short for its pixels'
    if len(b) > 0x3000 and off + W * W * bpp // 8 > 0x3000:
        return 'its pixels end past the 12 KB the menu reads'
    return None


def self_test():
    import io
    import random
    rng = random.Random(7)
    src = [[(rng.randrange(256), rng.randrange(256), rng.randrange(256), 255) for _ in range(64)] for _ in range(64)]

    def png(rows, ctype=6):
        w, h = len(rows[0]), len(rows)
        raw = b''.join(b'\0' + bytes(v for p in r for v in (p if ctype == 6 else p[:3])) for r in rows)

        def chunk(t, d):
            return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
        return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, ctype, 0, 0, 0))
                + chunk(b'IDAT', zlib.compress(raw)) + chunk(b'IEND', b''))
    w, h, rows = read_png(png(src))
    assert (w, h) == (64, 64) and rows[5][9] == src[5][9]
    bmp = write_bmp(to_icon(w, h, rows))
    assert len(bmp) == 3126 and check_bmp(bmp) is None
    exp = tuple(sum(src[2 * 3 + dy][2 * 4 + dx][k] for dy in (0, 1) for dx in (0, 1)) // 4 for k in range(3))
    o = 54 + (W - 1 - 3) * 96 + 4 * 3
    assert tuple(bmp[o:o + 3][::-1]) == exp, (bmp[o:o + 3], exp)
    try:
        from PIL import Image                              # the same through Pillow, when it is there
        im = Image.new('RGBA', (20, 20))
        for y in range(20):
            for x in range(20):
                im.putpixel((x, y), (x * 12, y * 12, 99, 255 if x < 10 else 0))
        for mode in ('RGBA', 'RGB', 'P', 'L'):
            f = io.BytesIO()
            im.convert(mode).save(f, 'PNG')
            w, h, rows = read_png(f.getvalue())
            ref = im.convert(mode).convert('RGBA')
            assert all(rows[y][x] == ref.getpixel((x, y)) for y in range(20) for x in range(20)), mode
        bmp2 = io.BytesIO()
        Image.open(io.BytesIO(bmp)).save(bmp2, 'BMP')
        assert check_bmp(bmp2.getvalue()) is None
        print('png2icon: self-test passed (with Pillow: RGBA, RGB, palette, grey decoded as Pillow does)')
    except ImportError:
        print('png2icon: self-test passed (Pillow not installed: its cross-check skipped)')


def main():
    a = sys.argv[1:]
    if a == ['--self-test']:
        self_test()
    elif len(a) == 2 and a[0] == '--check':
        why = check_bmp(open(a[1], 'rb').read())
        print(f'{a[1]}: ' + ('the menu takes it' if why is None else f'the menu would use its default icon: {why}'))
        sys.exit(0 if why is None else 1)
    elif len(a) == 2:
        w, h, rows = read_png(open(a[0], 'rb').read())
        open(a[1], 'wb').write(write_bmp(to_icon(w, h, rows)))
        print(f'{a[1]}: 32 x 32, 24-bit, 3126 bytes, from {a[0]} ({w} x {h})')
    else:
        sys.exit('usage: png2icon.py IN.png ICON.BMP | --check ICON.BMP | --self-test')


if __name__ == '__main__':
    main()
