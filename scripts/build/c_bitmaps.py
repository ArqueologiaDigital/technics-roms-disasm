#!/usr/bin/env python3
"""c_bitmaps.py -- the pictures inside the KN5000 maincpu's compiled C <-> PNG files, ROUND TRIP.

QUESTION ANSWERED: the 38 bitmaps the NAKA GUI C of each maincpu revision holds as initializers (the
Technics and KN-5000 logos, the split-point keyboards, the MIDI connection diagrams, the fade buttons,
the welcome-screen letters ...) -- can each be a PNG a viewer opens, and the C be made from it?

Until 2026-10-30 (lane media-files) the pixels were hex rows in v*/maincpu/ui_widgets/naka_*.c, and the
PNGs of v10/maincpu/images/ (indexed_images.py) fed only table_data's copies.  Now `build` writes each
initializer's values from its PNG before clang compiles the C (the Makefile makes the five affected
`includes/generated/naka_*.bin` of every revision depend on it), the way mono_images.py writes the
committed images/*.bin: the PNG is the source, the C rows follow it, and an unchanged PNG leaves the C
file untouched byte for byte.  For v10 the PNG is the same file table_data's build reads.

FORMATS (the comment above each member in the C, and its readers)
  p8   H x W, one byte per pixel, a palette index (DrawBitmapSPFast and friends); PNG mode 'P', shown
       with the main palette v10/maincpu/images/Palette_8bit_RGBA.bin.  31 items + UserBitmapCheck_Bitmap24x24.
  b1   the welcome-screen letters: 16 x 17, 1 bpp, one big-endian word per row, rows stored BOTTOM-UP
       (DrawBitmapSP2_Impl; the op handlers after AcWelcomScreen_RenderBytecode pass 0x10 x 0x11).  The
       PNG is mode '1', upright; Bitmap_DigitL holds three letters (L, N, O), side by side in its PNG.
       `build` also rewrites the ASCII-art comment of each row.

    python3 scripts/build/c_bitmaps.py export   # C -> PNG where a PNG is missing (run once); checks the others
    python3 scripts/build/c_bitmaps.py build    # PNG -> C initializer values (build step)
    python3 scripts/build/c_bitmaps.py verify   # PNG == C == the bytes of the built includes/generated/*.bin
    python3 scripts/build/c_bitmaps.py list     # item, revision, size, PNG
"""
import pathlib
import re
import sys

from PIL import Image

REPO = pathlib.Path(__file__).resolve().parent.parent.parent
TREES = ['v5', 'v6', 'v7', 'v9', 'v10']
PALETTE = REPO / 'v10' / 'maincpu' / 'images' / 'Palette_8bit_RGBA.bin'
SPLIT = ['A', 'Ab', 'B', 'Bb', 'C', 'D', 'Db', 'E', 'Eb', 'F', 'G', 'Gb', 'no_split']
P8 = (['Bitmap_Accger16', 'Bitmap_Accita16', 'Bitmap_Bmphk'] +
      [f'Bitmap_DrawbarNumberedSlider_{i}' for i in (1, 2, 3)] +
      ['Bitmap_Dredt0d', 'Bitmap_Dredt0k', 'Bitmap_FadeInPicture', 'Bitmap_FadeInText', 'Bitmap_FadeOutPicture',
       'Bitmap_FadeOutText', 'Bitmap_KN5000_Logo'] +
      [f'Bitmap_MIDIConnections_{i}' for i in (1, 2, 3)] +
      ['Bitmap_Ntedt0d', 'Bitmap_Ntedt0k', 'Bitmap_SomeArrows'] +
      [f'Bitmap_SplitPoint_{s}' for s in SPLIT] +
      ['Bitmap_Technics_Logo', 'UserBitmapCheck_Bitmap24x24'])
B1 = ['WelcomeGlyph_C', 'Bitmap_Digit1', 'Bitmap_DigitR', 'Bitmap_DigitD', 'Bitmap_DigitL']
# the C object files whose source holds an item (the Makefile's dependency list says the same)
C_FILES = ['naka_technichord_strings.c', 'naka_style_bitmaps.c', 'naka_widget_tables_2.c', 'naka_widget_descriptors.c',
           'naka_disk_warning.c']
HEX = re.compile(r'0x[0-9A-Fa-f]{2}\b')
COMMENT = re.compile(r'/\*.*?\*/')
ART = re.compile(r'/\*\s*(\d+) ([.#]{16}) \*/')


def png_stem(name):
    """v10/maincpu/images/ already names most of these (indexed_images.py): BitmapAccita16.png ..."""
    if not name.startswith('Bitmap_') or name in B1:
        return name
    s = 'Bitmap' + name[len('Bitmap_'):]
    return s.replace('KN5000_Logo', 'KN5000Logo').replace('Technics_Logo', 'TechnicsLogo')


def dims(text, name):
    m = re.search(r'uint8_t %s((?:\[\d+\])+);' % re.escape(name), text)
    return [int(x) for x in re.findall(r'\d+', m.group(1))] if m else None


def find(tree, name):
    """(path, lines, first, end, dims) of `.name = {` ... its closing brace, in the tree's C"""
    for fn in C_FILES:
        path = REPO / tree / 'maincpu' / 'ui_widgets' / fn
        text = path.read_text(encoding='latin-1')
        d = dims(text, name)
        if d is None:
            continue
        lines = text.split('\n')
        for i, l in enumerate(lines):
            if l.strip() == f'.{name} = {{':
                depth, j = 0, i
                while True:
                    code = COMMENT.sub('', lines[j])
                    depth += code.count('{') - code.count('}')
                    j += 1
                    if depth == 0:
                        return path, lines, i, j, d
        raise SystemExit(f'{tree}: {name} is declared in {fn} but has no initializer')
    raise SystemExit(f'{tree}: {name} is in none of {C_FILES}')


def c_bytes(lines, i, j):
    return bytes(int(t, 16) for k in range(i, j) for t in HEX.findall(COMMENT.sub('', lines[k])))


def png_path(tree, name):
    return REPO / tree / 'maincpu' / 'images' / f'{png_stem(name)}.png'


def rgb_palette():
    p = PALETTE.read_bytes()
    return b''.join(p[i:i + 3] for i in range(0, 1024, 4))


def to_png(name, d, raw, path):
    if name in B1:
        g = len(raw) // 34
        img = Image.new('1', (16 * g, 17), 0)
        px = img.load()
        for k in range(g):
            for r in range(17):
                w = raw[34 * k + 2 * r] << 8 | raw[34 * k + 2 * r + 1]
                for x in range(16):
                    if w & (0x8000 >> x):
                        px[16 * k + x, 16 - r] = 1          # stored bottom-up
        img.save(path)
    else:
        h, w = d
        img = Image.new('P', (w, h))
        img.frombytes(raw)
        img.putpalette(rgb_palette())
        img.save(path)


def from_png(name, d, path):
    img = Image.open(path)
    if name in B1:
        g = 3 if name == 'Bitmap_DigitL' else 1
        img = img.convert('1')
        assert img.size == (16 * g, 17), f'{path}: {img.size}, expected {(16 * g, 17)}'
        px = img.load()
        out = bytearray()
        for k in range(g):
            for r in range(17):
                w = sum(0x8000 >> x for x in range(16) if px[16 * k + x, 16 - r])
                out += bytes([w >> 8, w & 0xFF])
        return bytes(out)
    h, w = d
    assert img.mode == 'P', f'{path}: must be palette-indexed, got {img.mode}'
    assert img.size == (w, h), f'{path}: {img.size}, expected {(w, h)}'
    return img.tobytes()


def rewrite(lines, i, j, name, raw):
    """put `raw` into the initializer's hex tokens, layout kept; b1 rows get their art redrawn"""
    it = iter(raw)
    for k in range(i, j):
        line = lines[k]
        parts = re.split(r'(/\*.*?\*/)', line)
        for n in range(0, len(parts), 2):
            parts[n] = HEX.sub(lambda m: f'0x{next(it):02X}', parts[n])
        line = ''.join(parts)
        if name in B1:
            v = [int(t, 16) for t in HEX.findall(COMMENT.sub('', line))]
            if len(v) == 2:
                w = v[0] << 8 | v[1]
                art = ''.join('#' if w & (0x8000 >> x) else '.' for x in range(16))
                line = ART.sub(lambda m: f'/* {m.group(1).rjust(2)} {art} */', line)
        lines[k] = line
    rest = list(it)
    assert not rest, f'{name}: {len(rest)} values left over'


def items():
    for t in TREES:
        for name in P8 + B1:
            yield t, name


def export():
    made = checked = 0
    for t, name in items():
        path, lines, i, j, d = find(t, name)
        raw = c_bytes(lines, i, j)
        n = 1
        for x in d:
            n *= x
        assert len(raw) == n, f'{t} {name}: {len(raw)} values, {d} declared'
        p = png_path(t, name)
        if p.exists():
            got = from_png(name, d, p)
            assert got == raw, f'{t} {name}: {p} exists and holds other pixels than the C'
            checked += 1
        else:
            to_png(name, d, raw, p)
            assert from_png(name, d, p) == raw
            made += 1
    print(f'c_bitmaps.py export: {made} PNG(s) written, {checked} existing PNG(s) equal to the C')


def build():
    changed = []
    files = {}
    for t, name in items():
        path, lines, i, j, d = find(t, name)
        if path in files:
            lines = files[path]
        raw = from_png(name, d, png_path(t, name))
        if c_bytes(lines, i, j) != raw:
            rewrite(lines, i, j, name, raw)
            changed.append(f'{t} {name}')
        files[path] = lines
    for path, lines in files.items():
        new = '\n'.join(lines)
        if path.read_text(encoding='latin-1') != new:
            path.write_text(new, encoding='latin-1')
    print(f'c_bitmaps.py: {len(P8 + B1)} pictures x {len(TREES)} revisions from PNG'
          + (f'; rewrote {", ".join(changed)}' if changed else ''))


def verify():
    bad = 0
    for t, name in items():
        path, lines, i, j, d = find(t, name)
        raw = c_bytes(lines, i, j)
        if from_png(name, d, png_path(t, name)) != raw:
            print(f'FAIL  {t} {name}: the PNG and the C differ')
            bad += 1
            continue
        # the built object's bytes at the asm label (post-divergence for the ported revisions)
        hit = None
        for s in (REPO / t / 'maincpu').rglob('*.s'):
            m = re.search(rb'^%s:\s*\.incbin\s+"([^"]+)",\s*(0x[0-9A-Fa-f]+),\s*(0x[0-9A-Fa-f]+)' % name.encode(),
                          s.read_bytes(), re.M)
            if m:
                hit = (REPO / t / 'maincpu' / m.group(1).decode(), int(m.group(2), 16), int(m.group(3), 16))
                break
        if hit and hit[0].exists():
            # the label's slice may cover only the head of the picture (more labels follow inside it)
            b = hit[0].read_bytes()[hit[1]:hit[1] + min(hit[2], len(raw))]
            if b != raw[:len(b)]:
                print(f'FAIL  {t} {name}: the built {hit[0].name} holds other bytes at the label')
                bad += 1
    n = len(TREES) * len(P8 + B1)
    print(f'c_bitmaps.py verify: {n - bad} of {n} pictures: PNG == C == built bytes')
    return 1 if bad else 0


def listing():
    for t, name in items():
        path, lines, i, j, d = find(t, name)
        print(f'{t}\t{name}\t{"x".join(map(str, d))}\t{path.relative_to(REPO)}\t{png_path(t, name).relative_to(REPO)}')


if __name__ == '__main__':
    cmd = sys.argv[1] if len(sys.argv) > 1 else ''
    fn = {'export': export, 'build': build, 'verify': verify, 'list': listing}.get(cmd)
    if fn is None:
        sys.exit(__doc__)
    sys.exit(fn() or 0)
