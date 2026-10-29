#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""table_png.py -- the KN7000 table flash's raw pictures as lossless indexed PNG files.

QUESTION IT ANSWERS
  "What do the GUI bitmaps, frame pieces, icons, fonts, TCD pictures and USER HP menu
   pictures of the table flash look like, and how do I edit one and get the exact
   firmware bytes back?"

  Each item is kept in src/table/<subdir>/<name>.png, an indexed (palette) PNG whose
  pixel INDICES are the firmware's pixel values; the palette is only for viewing.
  `build` turns the PNGs back into the raw bytes the table source `.incbin`s from
  build/table_png/ (census: generated -- tools/table_png.py).  The format of each item
  is in the PNG's own tEXt chunk "kn7000-format", so a PNG says how it is packed.

FORMATS (evidence: annotations/gfx_draw.ann, the blitter docs of program 941)
  p8 W H     DrawBitmap_Impl 0x48423BBA / DrawFrameSP_Impl 0x48423F6E: one byte per
             pixel, a palette index, each row padded to an even length (the pad byte
             is 0 in every item of builds 83 and 84; `build` writes 0).  0xF7 is
             transparent, 0xF6 the template colour, 0xF4 copies the picture plane
             (frames only); the PNG marks 0xF7 transparent with tRNS.
  p4         DrawIcons_Impl 0x48423E31: 24 x 24, two 4-bit pixels per byte, high nibble
             left; nibble n is palette index n (n < 8) or 0xF0 + n (n >= 8) through
             DrawIcons_PixelPairTable 0x485A22B8.  PNG bit depth 4, same packing.
  b1 W H     DrawBitmapSP2_Impl 0x48424981: rows of MSB-first 1 bpp, padded to an even
             byte count; 1 = fg, 0 = bg.  PNG bit depth 1, same packing.
  p2 W H     DrawBitmapSPFast4_Impl 0x4842446C: rows of (W + 3) / 4 bytes, four 2-bit
             pixels per byte, leftmost in bits 7-6; pixel p -> palette first + p.  PNG
             bit depth 2, same packing.  W is the row length in pixels (a multiple of
             4); the drawn width comes from the caller's box.
  pk D W H   (SX-KN6000 / KN6500 bitmap resources, the procedures that answer
             MT_GetBitmapData / Width / Height / Palette / GetBitCount; see
             gen_data_s.py bitmaps()) D bits a pixel (1, 2, 4 or 8), MSB / high nibble
             leftmost, each row padded to an even byte count.  The PNG is as wide as a
             padded row (so its pad pixels keep whatever the bytes hold); W, the drawn
             width, is only recorded.  The palette is the bitmap's own when it has one.
  font C H N [columns=...]
             DrawString_Impl 0x48425467: a glyph is 1 bpp, column-major, C 8-pixel
             columns of H bytes, MSB leftmost; N glyphs from character 0x20.  The PNG
             is a sheet of 16 glyph cells per row, each 8*C x H.  A proportional font
             (descriptor columns = 0, kern table present) gives each glyph's column
             count in `columns=`; its cell is 8 * max(columns) wide and the unused
             columns must stay 0.

USAGE
  table_png.py build --out-dir build/table_png src/table/gui/*.png ...
      writes build/table_png/<subdir>/<name>.bin for src/table/<subdir>/<name>.png
  table_png.py dump FILE.png       prints the format and size of a PNG and its raw size
  (extraction: tools/gen_table_s.py imports write_item(); `make table-src`.)
"""
import os
import struct
import sys
import zlib

# The CLUT the firmware seeds the palette with: display_palette in
# src/program/region1_0C.s (ClutPaletteSeedTable 0x4872573C, 0x00BBGGRR).  Entries
# 0x1D..0xF3 are all 0x80FF80 (a placeholder the firmware overwrites at run time).
_SEED_LO = [0x000000, 0x000080, 0x008000, 0x008080, 0x800000, 0x800080, 0x808000, 0x808080,
            0x303030, 0x0080FF, 0x0048FF, 0x004080, 0x38FF68, 0x000000, 0xC8C8C8, 0x808080,
            0x0048FF, 0x0048FF, 0x000000, 0x60FFFF, 0xFFFF90, 0xFF90FF, 0x60FF60, 0x800000,
            0x808080, 0x00FFFF, 0x0048FF, 0x00FFFF, 0x0048FF]
_SEED_HI = [0x808080, 0x000000, 0xC0FFC0, 0x408040, 0x585858, 0x0000FF, 0x00FF00, 0x00FFFF,
            0xFF0000, 0xFF00FF, 0xFFFF00, 0xC8C8C8]                     # 0xF4..0xFF
SEED = _SEED_LO + [0x80FF80] * (0xF4 - len(_SEED_LO)) + _SEED_HI
assert len(SEED) == 256


def bgr(v):
    return (v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF)


PAL8 = [bgr(v) for v in SEED]
PAL4 = [bgr(SEED[n if n < 8 else 0xF0 + n]) for n in range(16)]
PAL2 = [bgr(v) for v in (0xC0C0C0, 0x808080, 0x404040, 0x000000)]   # 0x485FA224, AcUserHpMenuProc
PAL1_TCD = [(0, 0, 0), bgr(SEED[0xFF])]                                 # bg 0, fg 0xFF (AcTcdImageProc)
PAL1_FONT = [(255, 255, 255), (0, 0, 0)]                                # paper, ink
KEY = "kn7000-format"


# ---- minimal PNG writer / reader (colour type 3 only) ----------------------------------

def _chunk(t, data):
    return struct.pack(">I", len(data)) + t + data + struct.pack(">I", zlib.crc32(t + data) & 0xFFFFFFFF)


def png_bytes(width, height, depth, palette, rows, fmt, trns=None):
    out = b"\x89PNG\r\n\x1a\n"
    out += _chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, depth, 3, 0, 0, 0))
    out += _chunk(b"tEXt", KEY.encode() + b"\0" + fmt.encode())
    out += _chunk(b"PLTE", b"".join(bytes(c) for c in palette))
    if trns is not None:
        out += _chunk(b"tRNS", trns)
    raw = b"".join(b"\0" + r for r in rows)
    out += _chunk(b"IDAT", zlib.compress(raw, 9))
    return out + _chunk(b"IEND", b"")


def _paeth(a, b, c):
    p = a + b - c
    pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
    return a if pa <= pb and pa <= pc else b if pb <= pc else c


def png_read(path):
    """-> (width, height, indices: list of rows of ints, text: dict).  Indexed PNGs of
    any bit depth (1/2/4/8) are accepted, so a file an editor re-saved still works."""
    data = open(path, "rb").read()
    assert data[:8] == b"\x89PNG\r\n\x1a\n", f"{path}: not a PNG"
    i, idat, text = 8, b"", {}
    while i < len(data):
        n, t = struct.unpack_from(">I4s", data, i)
        body = data[i + 8:i + 8 + n]
        if t == b"IHDR":
            w, h, depth, ctype, _c, _f, interlace = struct.unpack(">IIBBBBB", body)
        elif t == b"IDAT":
            idat += body
        elif t == b"tEXt":
            k, v = body.split(b"\0", 1)
            text[k.decode("latin-1")] = v.decode("latin-1")
        i += 12 + n
    if ctype != 3 or interlace:
        sys.exit(f"{path}: must be an indexed (palette), non-interlaced PNG "
                 f"(colour type {ctype}, interlace {interlace})")
    raw = zlib.decompress(idat)
    stride = (w * depth + 7) // 8
    bpp = 1
    prev = bytearray(stride)
    rows, o = [], 0
    for _ in range(h):
        ft, line = raw[o], bytearray(raw[o + 1:o + 1 + stride])
        o += 1 + stride
        for x in range(stride):
            a = line[x - bpp] if x >= bpp else 0
            b, c = prev[x], (prev[x - bpp] if x >= bpp else 0)
            line[x] = (line[x] + (0, a, b, (a + b) >> 1, _paeth(a, b, c))[ft]) & 0xFF
        prev = line
        per = 8 // depth
        idx = []
        for x in range(w):
            byte = line[x // per]
            sh = 8 - depth * (x % per + 1)
            idx.append((byte >> sh) & ((1 << depth) - 1))
        rows.append(idx)
    return w, h, rows, text


def pack(idx, depth):
    """Indices -> packed bytes at `depth` bits, MSB first, last byte zero-padded."""
    per = 8 // depth
    out = bytearray((len(idx) + per - 1) // per)
    for x, v in enumerate(idx):
        assert v < (1 << depth), f"pixel value {v} does not fit {depth} bits"
        out[x // per] |= v << (8 - depth * (x % per + 1))
    return bytes(out)


def unpack(bs, depth, n):
    per = 8 // depth
    return [(bs[x // per] >> (8 - depth * (x % per + 1))) & ((1 << depth) - 1) for x in range(n)]


# ---- formats -------------------------------------------------------------------------

def parse_fmt(fmt):
    parts = fmt.split()
    kind, nums, kw = parts[0], [], {}
    for p in parts[1:]:
        if "=" in p:
            k, v = p.split("=", 1)
            kw[k] = v
        else:
            nums.append(int(p))
    return kind, nums, kw


def pk_stride(depth, w):
    """Bytes a row of a `pk` bitmap: W pixels at `depth` bits, padded to an even count."""
    st = (w * depth + 7) // 8
    return st + (st & 1)


def to_png(fmt, raw, palette=None):
    """raw item bytes -> PNG file bytes, for the format string `fmt`."""
    kind, n, kw = parse_fmt(fmt)
    if kind == "p8":
        w, h = n
        st = w + (w & 1)
        assert len(raw) == st * h, f"p8 {w}x{h}: {len(raw)} bytes, not {st * h}"
        rows = [raw[r * st:r * st + w] for r in range(h)]
        assert all(raw[r * st + w:(r + 1) * st] == bytes(st - w) for r in range(h)), "p8: non-zero row pad"
        trns = bytes([255] * 0xF7 + [0])
        return png_bytes(w, h, 8, palette or PAL8, rows, fmt, trns)
    if kind == "p4":
        w, h = n
        assert w % 2 == 0 and len(raw) == w // 2 * h
        return png_bytes(w, h, 4, PAL4, [raw[r * w // 2:(r + 1) * w // 2] for r in range(h)], fmt)
    if kind in ("b1", "p2"):
        w, h = n
        depth = 1 if kind == "b1" else 2
        st = w * depth // 8
        assert w * depth % 8 == 0 and len(raw) == st * h, f"{fmt}: {len(raw)} bytes"
        pal = palette or (PAL1_TCD if kind == "b1" else PAL2)
        return png_bytes(w, h, depth, pal, [raw[r * st:(r + 1) * st] for r in range(h)], fmt)
    if kind == "pk":
        depth, w, h = n
        st = pk_stride(depth, w)
        assert len(raw) == st * h, f"{fmt}: {len(raw)} bytes, not {st * h}"
        pal = palette or ([(0, 0, 0), (255, 255, 255)] if depth == 1 else
                          [(v * 255 // ((1 << depth) - 1),) * 3 for v in range(1 << depth)] if depth < 8 else PAL8)
        return png_bytes(st * 8 // depth, h, depth, pal, [raw[r * st:(r + 1) * st] for r in range(h)], fmt)
    if kind == "font":
        cols, h, count = n
        widths = [int(c) for c in kw["columns"].split(",")] if "columns" in kw else [cols] * count
        assert len(widths) == count and sum(widths) * h == len(raw), f"{fmt}: {len(raw)} bytes"
        cw = 8 * max(widths)
        gw = (count + 15) // 16
        sheet = [[0] * (16 * cw) for _ in range(gw * h)]
        o = 0
        for g, nc in enumerate(widths):
            gx, gy = (g % 16) * cw, (g // 16) * h
            for c in range(nc):
                for y in range(h):
                    b = raw[o]
                    o += 1
                    for bit in range(8):
                        sheet[gy + y][gx + 8 * c + bit] = (b >> (7 - bit)) & 1
        return png_bytes(16 * cw, gw * h, 1, PAL1_FONT, [pack(r, 1) for r in sheet], fmt)
    raise SystemExit(f"unknown format {fmt!r}")


def from_png(path):
    """PNG file -> the item's raw bytes (inverse of to_png)."""
    w, h, rows, text = png_read(path)
    if KEY not in text:
        sys.exit(f"{path}: no '{KEY}' tEXt chunk: cannot tell how to pack it")
    fmt = text[KEY]
    kind, n, kw = parse_fmt(fmt)
    if kind == "pk":
        depth, fw, fh = n
        assert (w, h) == (pk_stride(depth, fw) * 8 // depth, fh), f"{path}: {w}x{h}, but its format says {fmt}"
        return b"".join(pack(r, depth) for r in rows)
    if kind != "font":
        assert (w, h) == tuple(n[:2]), f"{path}: {w}x{h}, but its format says {fmt}"
    if kind == "p8":
        return b"".join(bytes(r) + bytes(w & 1) for r in rows)
    if kind in ("p4", "b1", "p2"):
        return b"".join(pack(r, {"p4": 4, "b1": 1, "p2": 2}[kind]) for r in rows)
    if kind == "font":
        cols, gh, count = n
        widths = [int(c) for c in kw["columns"].split(",")] if "columns" in kw else [cols] * count
        cw = 8 * max(widths)
        out = bytearray()
        for g, nc in enumerate(widths):
            gx, gy = (g % 16) * cw, (g // 16) * gh
            for c in range(max(widths)):
                if c >= nc:
                    assert not any(rows[gy + y][gx + 8 * c + b] for y in range(gh) for b in range(8)), \
                        f"{path}: glyph {g} has ink outside its {nc} columns"
                    continue
                for y in range(gh):
                    out.append(sum(rows[gy + y][gx + 8 * c + b] << (7 - b) for b in range(8)))
        return bytes(out)
    raise SystemExit(f"{path}: unknown format {fmt!r}")


def write_item(path, fmt, raw, palette=None):
    """Write `raw` as the PNG `path` (used by tools/gen_table_s.py).  A PNG already there
    must decode to the same bytes, so two table builds share one file."""
    if os.path.exists(path):
        if from_png(path) != raw:
            sys.exit(f"table_png: {path} exists and decodes to other bytes than this build's item")
        return
    os.makedirs(os.path.dirname(path), exist_ok=True)
    png = to_png(fmt, raw, palette)
    open(path, "wb").write(png)
    assert from_png(path) == raw, f"{path}: round trip failed"


def main(argv):
    if len(argv) >= 2 and argv[0] == "build":
        args = argv[1:]
        assert args[0] == "--out-dir"
        out_dir, pngs = args[1], args[2:]
        src_root = None
        if pngs and pngs[0] == "--src-root":        # <src-root>/<rel>.png -> <out-dir>/<rel>.bin
            src_root, pngs = pngs[1], pngs[2:]
        for p in pngs:
            parts = os.path.normpath(p).split(os.sep)
            rel = (os.path.relpath(p, src_root) if src_root else
                   os.path.join(*parts[parts.index("table") + 1:]))       # <subdir>/<name>.png
            dst = os.path.join(out_dir, os.path.splitext(rel)[0] + ".bin")
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            raw = from_png(p)
            if not (os.path.exists(dst) and open(dst, "rb").read() == raw):
                open(dst, "wb").write(raw)
        print(f"table_png: {len(pngs)} PNG -> {out_dir}")
        return 0
    if len(argv) == 2 and argv[0] == "dump":
        w, h, _rows, text = png_read(argv[1])
        print(f"{argv[1]}: {w}x{h}, {text.get(KEY)!r}, {len(from_png(argv[1]))} raw bytes")
        return 0
    print(__doc__)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
