#!/usr/bin/env python3
"""ftbmp_images.py -- the six Feature Demo BMPs <-> palette-indexed PNGs, ROUND TRIP.

QUESTION ANSWERED: can table_data's FTBMP01..06.BMP (318,468 B, the last verbatim
.incbin debt in table_data) be built from PNGs a human can open and edit, and still
reproduce every ROM byte?

The ROM stores these six images as complete Windows BMP files: the Feature Demo
looks them up by file name ("FTBMP01" + ".BMP", see the comment block above each
Feature_Bitmap_N in table_data/kn5000_table_data.s), so the firmware reads the
BITMAPFILEHEADER and BITMAPINFOHEADER as well as the pixels. A BMP is already
viewable, but it is the ROM's container, not an editable source: its 256-entry
palette lives inside it, its rows are stored bottom-up, and its header fields
(biXPelsPerMeter, biClrUsed, biClrImportant, ...) are values the ROM happens to
hold. This splits each file into what an editor works on and what it does not:

    table_data/images/FTBMPnn.png      320 x H, PIL mode 'P': one byte per pixel is
                                       the BMP's palette index, and the PNG's PLTE is
                                       the BMP's 256 palette entries in their
                                       original order (RGB; the BMP stores B,G,R,0)
    table_data/images/ftbmp_headers.json
                                       every BITMAPFILEHEADER / BITMAPINFOHEADER field
                                       and the palette entries' 4th (reserved) byte

Like indexed_images.py, the PNG stores INDICES, not colours. RGB would not round-trip:
each palette holds duplicate entries (FTBMP01 has 192 distinct colours across its
256 slots), so colour -> index is ambiguous.

`build` writes table_data/images/FTBMPnn.BMP from those two inputs, in place, the way
indexed_images.py regenerates table_data/images/Wallpaper_*.bin: the .BMP stays in git
as a build cache, so the .incbin path and every tool that reads it are unchanged, and
it is rewritten only when its bytes would change (otherwise only its mtime is brought
forward, for the Makefile's FTBMP_BMPS rule). `build` refuses any header that is
not self-consistent with the PNG (sizes, offsets), so an edited PNG of a different
height cannot silently produce a malformed BMP.

    python3 scripts/build/ftbmp_images.py export --force
                                                   # BMP -> png + json (run once; without
                                                   # --force it refuses to overwrite)
    python3 scripts/build/ftbmp_images.py build    # png + json -> BMP (build step)
    python3 scripts/build/ftbmp_images.py verify   # assert the round trip is exact

`verify` rebuilds each BMP in memory and compares it with (1) the committed .BMP and
(2) the bytes at its .incbin address in original_ROMs/kn5000_table_data.rom. That
address is not written down here: the .incbin's label is found in
table_data/kn5000_table_data.s and its address in symbols/table_data_symbols_reference.txt.  Pass criterion:
"ROUND TRIP EXACT" and exit 0.
"""
import json
import os
import pathlib
import re
import struct
import sys

from PIL import Image

REPO = pathlib.Path(__file__).resolve().parent.parent.parent
IMAGES = REPO / 'table_data' / 'images'
HEADERS = IMAGES / 'ftbmp_headers.json'
ROM = REPO / 'original_ROMs' / 'kn5000_table_data.rom'
SOURCE = REPO / 'table_data' / 'kn5000_table_data.s'
SYMBOLS = REPO / 'symbols' / 'table_data_symbols_reference.txt'

NAMES = [f'FTBMP0{i}' for i in range(1, 7)]

TABLE_DATA_BASE = 0x800000


def rom_offsets():
    """FTBMPnn -> offset of its .incbin inside the table_data ROM image.

    Nothing is copied here: the label that carries each .incbin is read from the
    assembly source, and that label's address from the symbol reference file, which
    is regenerated from the linked ELF (scripts/analysis/l2_symbol_reference.py).
    """
    src = SOURCE.read_bytes()          # .s files hold raw high bytes: never read_text
    label_of = {m.group(2).decode(): m.group(1).decode() for m in re.finditer(
        rb'^(\w+):\s*\.incbin\s+"images/(FTBMP0\d)\.BMP"', src, re.M)}
    assert sorted(label_of) == NAMES, f"{SOURCE}: expected one .incbin per {NAMES}, found {sorted(label_of)}"
    addr = {}
    for line in SYMBOLS.read_bytes().decode('ascii').splitlines():
        parts = line.split()
        if len(parts) == 2 and not line.startswith('#'):
            addr[parts[0]] = int(parts[1], 16)
    missing = [lab for lab in label_of.values() if lab not in addr]
    assert not missing, f"{SYMBOLS}: no address for {missing}"
    return {name: addr[lab] - TABLE_DATA_BASE for name, lab in label_of.items()}

FILE_HDR = struct.Struct('<2sIHHI')          # BITMAPFILEHEADER, 14 B
INFO_HDR = struct.Struct('<IiiHHIIiiII')      # BITMAPINFOHEADER, 40 B
FILE_FIELDS = ('bfType', 'bfSize', 'bfReserved1', 'bfReserved2', 'bfOffBits')
INFO_FIELDS = ('biSize', 'biWidth', 'biHeight', 'biPlanes', 'biBitCount', 'biCompression',
               'biSizeImage', 'biXPelsPerMeter', 'biYPelsPerMeter', 'biClrUsed', 'biClrImportant')
PAL_OFF = FILE_HDR.size + INFO_HDR.size


def stride(width):
    return (width + 3) & ~3


def parse_bmp(data):
    """-> (header dict, rgb palette bytes, top-down pixel bytes)."""
    fh = dict(zip(FILE_FIELDS, FILE_HDR.unpack_from(data, 0)))
    ih = dict(zip(INFO_FIELDS, INFO_HDR.unpack_from(data, FILE_HDR.size)))
    fh['bfType'] = fh['bfType'].decode('ascii')
    hdr = {**fh, **ih}
    assert hdr['bfType'] == 'BM' and hdr['biSize'] == INFO_HDR.size, 'not a BITMAPINFOHEADER BMP'
    assert hdr['biBitCount'] == 8 and hdr['biCompression'] == 0, 'only uncompressed 8bpp is handled'
    assert hdr['biHeight'] > 0, 'only bottom-up BMPs are handled'
    ncol = hdr['biClrUsed'] or 256
    assert hdr['bfOffBits'] == PAL_OFF + 4 * ncol, 'unexpected gap between palette and pixels'
    w, h = hdr['biWidth'], hdr['biHeight']
    assert len(data) == hdr['bfOffBits'] + stride(w) * h, 'bytes after the pixel array'
    pal = data[PAL_OFF:hdr['bfOffBits']]
    reserved = set(pal[3::4])
    assert len(reserved) == 1, 'palette reserved bytes differ between entries'
    hdr['paletteReserved'] = reserved.pop()
    rgb = b''.join(bytes((pal[i + 2], pal[i + 1], pal[i])) for i in range(0, len(pal), 4))
    pix = data[hdr['bfOffBits']:]
    s = stride(w)
    assert all(not any(pix[y * s + w:(y + 1) * s]) for y in range(h)), 'non-zero row padding'
    rows = [pix[y * s:y * s + w] for y in range(h)]
    return hdr, rgb, b''.join(reversed(rows))


def build_bmp(hdr, png_path):
    img = Image.open(png_path)
    assert img.mode == 'P', f"{png_path}: must be palette-indexed, got {img.mode}"
    w, h = img.size
    ncol = hdr['biClrUsed'] or 256
    rgb = bytes(img.getpalette('RGB'))
    assert len(rgb) == 3 * ncol, f"{png_path}: palette has {len(rgb) // 3} entries, header says {ncol}"
    # The header must describe the PNG it is paired with.
    s = stride(w)
    want = {'biWidth': w, 'biHeight': h, 'biSizeImage': s * h,
            'bfOffBits': PAL_OFF + 4 * ncol, 'bfSize': PAL_OFF + 4 * ncol + s * h}
    for k, v in want.items():
        assert hdr[k] == v, f"{png_path}: header {k}={hdr[k]} but the PNG implies {v}"
    fh = FILE_HDR.pack(hdr['bfType'].encode('ascii'), *(hdr[k] for k in FILE_FIELDS[1:]))
    ih = INFO_HDR.pack(*(hdr[k] for k in INFO_FIELDS))
    res = hdr['paletteReserved']
    pal = b''.join(bytes((rgb[i + 2], rgb[i + 1], rgb[i], res)) for i in range(0, len(rgb), 3))
    px = img.tobytes()
    pad = bytes(s - w)
    rows = [px[y * w:(y + 1) * w] + pad for y in range(h)]
    return fh + ih + pal + b''.join(reversed(rows))


def export(force=False):
    """BMP -> png + json.  The PNGs and the JSON are the committed SOURCES once
    exported, so this refuses to overwrite them unless --force is given: a stray
    `export` after a PNG was edited would otherwise undo the edit from the cache."""
    existing = [p for p in [HEADERS, *(IMAGES / f'{n}.png' for n in NAMES)] if p.exists()]
    if existing and not force:
        sys.exit("ftbmp_images export: refusing to overwrite the committed sources "
                 + ", ".join(str(p.relative_to(REPO)) for p in existing)
                 + "\n  (they are the build inputs; pass --force to regenerate them from the .BMP files)")
    headers = {}
    for name in NAMES:
        hdr, rgb, px = parse_bmp((IMAGES / f'{name}.BMP').read_bytes())
        img = Image.frombytes('P', (hdr['biWidth'], hdr['biHeight']), px)
        img.putpalette(rgb)
        img.save(IMAGES / f'{name}.png')
        headers[name] = hdr
        print(f"  exported {name}.png  {hdr['biWidth']}x{hdr['biHeight']}")
    HEADERS.write_text(json.dumps(headers, indent=2) + '\n')
    print(f"  wrote {HEADERS.relative_to(REPO)}")


def rebuilt():
    headers = json.loads(HEADERS.read_text())
    assert sorted(headers) == NAMES, f"{HEADERS}: expected entries {NAMES}"
    return {name: build_bmp(headers[name], IMAGES / f'{name}.png') for name in NAMES}


def build():
    tot = written = 0
    for name, data in rebuilt().items():
        out = IMAGES / f'{name}.BMP'
        if not out.exists() or out.read_bytes() != data:
            out.write_bytes(data)
            written += 1
        else:
            # Unchanged bytes, but make asked for this output because a source is
            # newer: bring its mtime forward so the Makefile rule settles.
            os.utime(out)
        tot += len(data)
    print(f"ftbmp_images: {len(NAMES)} BMPs, {tot:,} B from PNGs ({written} rewritten)")


def verify():
    rom = ROM.read_bytes() if ROM.exists() else None
    offsets = rom_offsets()
    bad = 0
    for name, got in rebuilt().items():
        committed = (IMAGES / f'{name}.BMP').read_bytes()
        ok_file = got == committed
        if rom is None:
            ok_rom, rom_note = True, 'ROM absent, not compared'
        else:
            off = offsets[name]
            ok_rom = rom[off:off + len(got)] == got
            rom_note = f"ROM 0x{TABLE_DATA_BASE + off:06x}"
        if ok_file and ok_rom:
            print(f"  ok  {name}.BMP  {len(got):>7,} B  == committed, == {rom_note}")
        else:
            bad += 1
            print(f"  *** {name}.BMP: MISMATCH (committed: {ok_file}, {rom_note}: {ok_rom})")
    if bad:
        sys.exit(f"{bad} image(s) do not round-trip")
    print("ROUND TRIP EXACT")


if __name__ == '__main__':
    args = sys.argv[1:]
    cmd = args[0] if args else 'verify'
    if cmd == 'export':
        export(force='--force' in args[1:])
    else:
        {'build': build, 'verify': verify}[cmd]()
