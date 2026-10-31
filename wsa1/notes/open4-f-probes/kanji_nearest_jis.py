#!/usr/bin/env python3
"""kanji_nearest_jis.py -- which JIS X 0208 character is each 16x16 ideograph cell nearest to?

QUESTION IT ANSWERS (open item N-b6d3c4c7, 2026-10-31).  notes/fonts-kanji/kanji_transcription.txt
was read BY EYE, and one cell, set A 0x38, could not be settled.  This script replaces the eye
with a measurement: every defined cell of Font_Svc1A (set A, 0xF22840, codes 0x10-0xEF) and
Font_Svc1F (set B, 0xF24640, 0x10-0x3A) is compared, pixel by pixel, with every glyph of a
STANDARD 16x16 JIS X 0208 bitmap font -- the X11 `jiskan16` font (Debian package
xfonts-intl-japanese, /usr/share/fonts/X11/misc/jiskan16.pcf.gz) -- under every shift of up to
two pixels in each direction, and the glyph with the fewest differing pixels is reported.

★ CALIBRATED FIRST -- AND IT FAILED (2026-10-31).  The instrument is only believed for 0x38 because it can be checked on the
other 266 cells: `--calibrate` counts how often its nearest glyph IS the human reading.

    python3 notes/open4-f-probes/kanji_nearest_jis.py --calibrate     # agreement over 266 cells
    python3 notes/open4-f-probes/kanji_nearest_jis.py A 0x38          # top 8 for one cell
    python3 notes/open4-f-probes/kanji_nearest_jis.py --selftest      # exits 1 if the numbers drift

The PCF reader below is minimal (metrics, bitmaps, encodings) and is checked by the self test:
it must decode the 6,877 JIS X 0208 glyphs this font carries.

RESULT (2026-10-31): the nearest JIS glyph is the human reading for 16 of 266 cells (Hamming)
and 15 of 266 (blurred correlation) -- about 6%.  The instrument FAILS its calibration: the
ROM's face and jiskan16 are drawn too differently for pixel matching, so it can settle no
cell, 0x38 included.  It is kept so that negative is reproducible.  Takes ~7 minutes.
"""
import gzip
import pathlib
import struct
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
ROM_B = (ROOT / 'original_ROMs/wsa1_prom_b.ic13').read_bytes()
PCF = pathlib.Path('/usr/share/fonts/X11/misc/jiskan16.pcf.gz')
TRANS = ROOT / 'notes/fonts-kanji/kanji_transcription.txt'
SETS = {'A': (0xF22840, 0x10, 0xEF), 'B': (0xF24640, 0x10, 0x3A)}


def read_pcf(path):
    d = gzip.open(path).read()
    assert d[:4] == b'\x01fcp'
    n = struct.unpack_from('<i', d, 4)[0]
    tabs = {}
    for i in range(n):
        t, fmt, size, off = struct.unpack_from('<iiii', d, 8 + 16 * i)
        tabs[t] = (fmt, off)

    def ints(fmt):
        return '>' if fmt & 4 else '<'
    # metrics
    fmt, off = tabs[4]
    fmt = struct.unpack_from('<i', d, off)[0]
    e = ints(fmt)
    mets = []
    if fmt & 0x100:
        cnt = struct.unpack_from(e + 'h', d, off + 4)[0]
        for i in range(cnt):
            l, r, w, a, de = (x - 0x80 for x in d[off + 6 + 5 * i: off + 11 + 5 * i])
            mets.append((l, r, w, a, de))
    else:
        cnt = struct.unpack_from(e + 'i', d, off + 4)[0]
        for i in range(cnt):
            mets.append(struct.unpack_from(e + 'hhhhh', d, off + 8 + 12 * i))
    # bitmaps
    fmt, off = tabs[8]
    fmt = struct.unpack_from('<i', d, off)[0]
    e = ints(fmt)
    cnt = struct.unpack_from(e + 'i', d, off + 4)[0]
    offs = struct.unpack_from(e + '%di' % cnt, d, off + 8)
    data0 = off + 8 + 4 * cnt + 16
    pad = 1 << (fmt & 3)
    msbit = bool(fmt & 8)
    glyphs = []
    for i in range(cnt):
        l, r, w, a, de = mets[i]
        gw, gh = r - l, a + de
        stride = ((gw + 7) // 8 + pad - 1) // pad * pad
        rows = []
        for y in range(gh):
            row = d[data0 + offs[i] + y * stride: data0 + offs[i] + y * stride + stride]
            bits = 0
            for x in range(gw):
                byte = row[x // 8]
                bit = (byte >> (7 - x % 8)) & 1 if msbit else (byte >> (x % 8)) & 1
                bits |= bit << (15 - (x + l))
            rows.append(bits & 0xFFFF)
        # place on a 16-row cell, baseline at row 14 (ascent 14 in this font)
        cell = [0] * 16
        top = 14 - a
        for y, v in enumerate(rows):
            if 0 <= top + y < 16:
                cell[top + y] = v
        glyphs.append(cell)
    # encodings
    fmt, off = tabs[32]
    fmt = struct.unpack_from('<i', d, off)[0]
    e = ints(fmt)
    min2, max2, min1, max1, _dflt = struct.unpack_from(e + 'hhhhh', d, off + 4)
    n2 = max2 - min2 + 1
    idx = struct.unpack_from(e + '%dH' % (n2 * (max1 - min1 + 1)), d, off + 14)
    out = {}
    for k, gi in enumerate(idx):
        if gi == 0xFFFF:
            continue
        b1, b2 = min1 + k // n2, min2 + k % n2
        try:
            ch = bytes([b1 | 0x80, b2 | 0x80]).decode('euc_jp')
        except UnicodeDecodeError:
            continue
        out[ch] = glyphs[gi]
    return out


def rom_cell(setname, code):
    base = SETS[setname][0]
    raw = ROM_B[base - 0xF00000 + 32 * code: base - 0xF00000 + 32 * code + 32]
    return [(raw[2 * y] << 8) | raw[2 * y + 1] for y in range(16)]


def dist(a, b):
    best = 1 << 30
    for dy in range(-2, 3):
        for dx in range(-2, 3):
            s = 0
            for y in range(16):
                yy = y + dy
                v = b[yy] if 0 <= yy < 16 else 0
                v = (v << dx if dx >= 0 else v >> -dx) & 0xFFFF
                s += bin(a[y] ^ v).count('1')
            best = min(best, s)
    return best


def _np(cell):
    import numpy as np
    return np.array([[(v >> (15 - x)) & 1 for x in range(16)] for v in cell], float)


def scores(cell, glyphs, metric):
    """Best score over shifts of -2..+2 px; 'hamming' (lower is better, as a negative) or
    'blur' (3x3 box blur, normalised correlation, higher is better)."""
    import numpy as np
    from numpy.lib.stride_tricks import sliding_window_view

    def prep(a):
        b = sliding_window_view(np.pad(a, ((0, 0),) * (a.ndim - 2) + ((1, 1), (1, 1))),
                                (3, 3), axis=(-2, -1)).mean(axis=(-2, -1))
        b = b - b.mean(axis=(-2, -1), keepdims=True)
        n = np.sqrt((b * b).sum(axis=(-2, -1), keepdims=True))
        return b / np.where(n == 0, 1, n)
    G = glyphs if metric == 'hamming' else prep(glyphs)
    a = _np(cell)
    best = np.full(len(glyphs), -1e9)
    for dy in range(-2, 3):
        for dx in range(-2, 3):
            sh = np.roll(np.roll(a, dy, 0), dx, 1)
            if metric == 'hamming':
                sc = -np.abs(G - sh).sum(axis=(1, 2))
            else:
                sc = (G * prep(sh)).sum(axis=(1, 2))
            best = np.maximum(best, sc)
    return best


def transcription():
    t = {}
    for ln in TRANS.read_text(encoding='utf-8').split('\n'):
        p = ln.split()
        if len(p) == 3 and p[0] in SETS:
            for i, ch in enumerate(p[2]):
                t[(p[0], int(p[1], 16) + i)] = ch
    return t


def is_kanji(ch):
    return 0x4E00 <= ord(ch) <= 0x9FFF


def calibrate(font):
    import numpy as np
    chars = [c for c in font if is_kanji(c)]
    G = np.stack([_np(font[c]) for c in chars])
    t = transcription()
    out = {}
    for metric in ('hamming', 'blur'):
        agree = 0
        for (s, c), ch in sorted(t.items()):
            if ch in '〓既':      # the cell under test is excluded from its own calibration
                if (s, c) == ('A', 0x38):
                    continue
            if chars[int(scores(rom_cell(s, c), G, metric).argmax())] == ch:
                agree += 1
        out[metric] = agree
    return out, len(t) - 1


def main(argv):
    font = read_pcf(PCF)
    if argv[:1] in (['--selftest'], ['--calibrate']):
        res, n = calibrate(font)
        print('JIS X 0208 glyphs read: %d' % len(font))
        for m, a in res.items():
            print('metric %-8s nearest JIS glyph = the human reading for %d of %d cells (%.1f%%)'
                  % (m, a, n, 100.0 * a / n))
        if argv[0] == '--selftest':
            ok = len(font) == 6877 and res == EXPECT
            print('FAILURES: %d' % (0 if ok else 1))
            return 0 if ok else 1
        return 0
    import numpy as np
    chars = [c for c in font if is_kanji(c)]
    G = np.stack([_np(font[c]) for c in chars])
    s, c = argv[0], int(argv[1], 16)
    sc = scores(rom_cell(s, c), G, 'blur')
    for i in np.argsort(-sc)[:8]:
        print('%.3f  %s  U+%04X' % (sc[i], chars[i], ord(chars[i])))
    return 0


# The measured result, 2026-10-31: the instrument FAILS calibration, so it settles nothing.
EXPECT = {'hamming': 16, 'blur': 15}

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
