#!/usr/bin/env python3
"""c_bitmaps.py -- the pictures inside the KN5000 maincpu's compiled C <-> PNG files, ROUND TRIP.

QUESTION ANSWERED: the 38 bitmaps the NAKA GUI C of each maincpu revision holds as initializers (the
Technics and KN-5000 logos, the split-point keyboards, the MIDI connection diagrams, the fade buttons,
the welcome-screen letters ...) -- can each be a PNG a viewer opens, and the C be compiled from it?

Until 2026-10-30 (lane media-files) the pixels were hex rows in v*/maincpu/ui_widgets/naka_*.c.  Lane
media-files made each a PNG and had `build` rewrite the rows in the committed C from it.  Since 2026-10-31
(lane media-build, the owner: "Images and wav files must be commited and the conversion must happen as a
build step") the C holds no pixels at all: each initializer's body is one line

        .Bitmap_FadeInPicture = {
    #include "../includes/generated/pictures/Bitmap_FadeInPicture.inc"  /* ... images/BitmapFadeInPicture.png */
        },

and `build` writes that git-ignored .inc from the PNG before clang compiles the C (the Makefile makes the
five affected `includes/generated/naka_*.bin` of every revision depend on the tree's
`includes/generated/pictures/.stamp`, which depends on the PNGs).  The C keeps its declarations, its
header comment per picture and its layout; the PNG is the only committed copy of the pixels.  For v10 the
PNG is the same file table_data's build reads.

FORMATS (the comment above each member in the C, and its readers)
  p8   H x W, one byte per pixel, a palette index (DrawBitmapSPFast and friends); PNG mode 'P', shown
       with the main palette v10/maincpu/images/Palette_8bit_RGBA.bin.  31 items + UserBitmapCheck_Bitmap24x24.
  b1   the welcome-screen letters: 16 x 17, 1 bpp, one big-endian word per row, rows stored BOTTOM-UP
       (DrawBitmapSP2_Impl; the op handlers after AcWelcomScreen_RenderBytecode pass 0x10 x 0x11).  The
       PNG is mode '1', upright; WelcomeGlyph_L holds three letters (L, N, O), side by side in its PNG.
       The .inc carries an ASCII-art comment per row.

    python3 scripts/build/c_bitmaps.py build [TREE...]  # PNG -> includes/generated/pictures/*.inc (build step)
    python3 scripts/build/c_bitmaps.py verify   # PNG == .inc == the bytes of the built includes/generated/*.bin
    python3 scripts/build/c_bitmaps.py list     # item, revision, size, PNG
    python3 scripts/build/c_bitmaps.py respell  # (run once, 2026-10-31) hex rows in the C -> #include lines,
                                                # after checking every row equals its PNG
    python3 scripts/build/c_bitmaps.py export   # .inc -> PNG where a PNG is missing (adding a picture)
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
B1 = ['WelcomeGlyph_C', 'WelcomeGlyph_I', 'WelcomeGlyph_R', 'WelcomeGlyph_U', 'WelcomeGlyph_L']
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


def inc_path(tree, name):
    """the git-ignored file `build` writes: the initializer's body, from the PNG"""
    return REPO / tree / 'maincpu' / 'includes' / 'generated' / 'pictures' / f'{name}.inc'


INC_REL = '../includes/generated/pictures/%s.inc'      # as the C, in ui_widgets/, includes it


def include_line(tree, name):
    return (f'#include "{INC_REL % name}"  /* pixels: images/{png_stem(name)}.png, '
            f'written at build time by scripts/build/c_bitmaps.py */')


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
                    if not code.lstrip().startswith('#'):
                        depth += code.count('{') - code.count('}')
                    j += 1
                    if depth == 0:
                        return path, lines, i, j, d
        raise SystemExit(f'{tree}: {name} is declared in {fn} but has no initializer')
    raise SystemExit(f'{tree}: {name} is in none of {C_FILES}')


def is_included(lines, i, j):
    """True when the initializer's body is the one #include line `respell` wrote"""
    return j - i == 3 and lines[i + 1].startswith('#include "../includes/generated/pictures/')


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
        g = 3 if name == 'WelcomeGlyph_L' else 1
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


def body_lines(name, d, raw):
    """the initializer's body for `raw`, as `build` writes it into the .inc"""
    out = []
    if name in B1:
        def glyph(rows, ind):
            for r in range(17):
                w = rows[2 * r] << 8 | rows[2 * r + 1]
                art = ''.join('#' if w & (0x8000 >> x) else '.' for x in range(16))
                out.append(f'{ind}{{ 0x{rows[2 * r]:02X}, 0x{rows[2 * r + 1]:02X} }},  /* {r:2d} {art} */')
        if len(d) == 2:
            glyph(raw, ' ' * 8)
        else:
            for k in range(d[0]):
                out.append(f'        /* glyph {k} */ {{')
                glyph(raw[34 * k:34 * (k + 1)], ' ' * 12)
                out.append('        },')
        return out
    h, w = d
    for r in range(h):
        row = raw[r * w:(r + 1) * w]
        out.append(f'        /* {r:3d} */ {{')
        for k in range(0, w, 16):
            out.append('            ' + ' '.join(f'0x{b:02X},' for b in row[k:k + 16]))
        out.append('        },')
    return out


def inc_bytes(path):
    text = path.read_text(encoding='latin-1')
    return bytes(int(t, 16) for line in text.split('\n') for t in HEX.findall(COMMENT.sub('', line)))


def items(trees=None):
    for t in trees or TREES:
        for name in P8 + B1:
            yield t, name


def size(d):
    n = 1
    for x in d:
        n *= x
    return n


def respell():
    """the C's hex rows -> one #include line per picture; refuses unless every row equals its PNG"""
    files = {}
    done = 0
    for t, name in items():
        path, lines, i, j, d = find(t, name)
        if path in files:
            lines, i, j, d = find_in(files[path], name, path)
        if is_included(lines, i, j):
            continue
        raw = c_bytes(lines, i, j)
        assert len(raw) == size(d), f'{t} {name}: {len(raw)} values, {d} declared'
        assert from_png(name, d, png_path(t, name)) == raw, f'{t} {name}: the C rows differ from the PNG'
        lines[i + 1:j - 1] = [include_line(t, name)]
        files[path] = lines
        done += 1
    for path, lines in files.items():
        path.write_bytes('\n'.join(lines).encode('latin-1'))
    print(f'c_bitmaps.py respell: {done} initializer(s) now #include their PNG\'s .inc ({len(files)} C files)')


def find_in(lines, name, path):
    for i, l in enumerate(lines):
        if l.strip() == f'.{name} = {{':
            depth, j = 0, i
            while True:
                code = COMMENT.sub('', lines[j])
                if not code.lstrip().startswith('#'):
                    depth += code.count('{') - code.count('}')
                j += 1
                if depth == 0:
                    return lines, i, j, dims('\n'.join(lines), name)
    raise SystemExit(f'{path}: no initializer for {name}')


def build(trees=None):
    wrote = 0
    for t, name in items(trees):
        path, lines, i, j, d = find(t, name)
        if not is_included(lines, i, j):
            sys.exit(f'{t} {name}: {path.name} still holds hex rows -- run `c_bitmaps.py respell` once')
        raw = from_png(name, d, png_path(t, name))
        assert len(raw) == size(d), f'{t} {name}: the PNG gives {len(raw)} bytes, {d} declared'
        text = '\n'.join(body_lines(name, d, raw)) + '\n'
        out = inc_path(t, name)
        out.parent.mkdir(parents=True, exist_ok=True)
        if not out.exists() or out.read_text(encoding='latin-1') != text:
            out.write_bytes(text.encode('latin-1'))
            wrote += 1
    n = len(list(items(trees)))
    print(f'c_bitmaps.py: {n} pictures from PNG ({", ".join(trees or TREES)}); {wrote} .inc file(s) written')


def export():
    made = 0
    for t, name in items():
        p = png_path(t, name)
        if p.exists():
            continue
        path, lines, i, j, d = find(t, name)
        raw = inc_bytes(inc_path(t, name)) if is_included(lines, i, j) else c_bytes(lines, i, j)
        to_png(name, d, raw, p)
        assert from_png(name, d, p) == raw
        made += 1
    print(f'c_bitmaps.py export: {made} PNG(s) written')


def verify():
    bad = 0
    for t, name in items():
        path, lines, i, j, d = find(t, name)
        png = from_png(name, d, png_path(t, name))
        if not is_included(lines, i, j):
            print(f'FAIL  {t} {name}: {path.name} holds hex rows, not the #include line')
            bad += 1
            continue
        inc = inc_path(t, name)
        if not inc.exists() or inc_bytes(inc) != png:
            print(f'FAIL  {t} {name}: {inc.relative_to(REPO)} is missing or differs from the PNG (run `make`)')
            bad += 1
            continue
        raw = png
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
    print(f'c_bitmaps.py verify: {n - bad} of {n} pictures: PNG == .inc == built bytes')
    return 1 if bad else 0


def listing():
    for t, name in items():
        path, lines, i, j, d = find(t, name)
        print(f'{t}\t{name}\t{"x".join(map(str, d))}\t{path.relative_to(REPO)}\t{png_path(t, name).relative_to(REPO)}')


if __name__ == '__main__':
    cmd = sys.argv[1] if len(sys.argv) > 1 else ''
    if cmd == 'build':
        sys.exit(build(sys.argv[2:] or None) or 0)
    fn = {'export': export, 'respell': respell, 'verify': verify, 'list': listing}.get(cmd)
    if fn is None:
        sys.exit(__doc__)
    sys.exit(fn() or 0)
