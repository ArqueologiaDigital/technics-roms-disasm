#!/usr/bin/env python3
r"""render_ftdemo_slides.py -- draw the KN5000 Feature Presentation's slides to PNG files.

QUESTION ANSWERED
-----------------
"What does each <ACT> of the Feature Presentation put on the 320 x 240 LCD?"  (tracker kn5000-waa)

The presentation script (`Feature_Demo_XML`, table_data/kn5000_table_data.s) is 27 `<ACT NO=n><SHOW
OBJ="name">` steps.  Each name is a view object of the NAKA GUI: the 26 `ftdemoNN` TtlScreens of
Viewable slot 0xFD (v10/maincpu/ui_widgets/naka_perf_style.c) or one of the live screens
"Accordion", "Drawbar", "Sdmixer" (naka_technichord_part.c).  This script reads those records with
scripts/analysis/naka_gui_model.py, walks each screen's widget tree (sub, then next) and draws every
widget into an 8-bit index buffer the way the firmware's paint procedures do, then writes one PNG per
ACT (and, with --all, one per ftdemo screen, including the six no ACT shows).

WHAT IT READS (all tracked files; nothing from a private dump)
--------------------------------------------------------------
  * the widget records: <tree>/maincpu/ui_widgets/*.c through naka_gui_model.CFile;
  * the ACT list: the `.ascii` lines of Feature_Demo_XML in table_data/kn5000_table_data.s;
  * the system palette: v10/maincpu/images/Palette_8bit_RGBA.bin (what InitPaletteRGB copies to the
    palette table at RAM 0x324FC; byte order R, G, B, A);
  * the fonts: table_data/images/fonts/Font<n>_Glyphs.png (scripts/build/font_images.py's sheets) and the
    descriptor table of table_data/fonts.s;
  * the slide pictures: table_data/images/FTBMP0n.png (indexed, with each BMP's own palette);
  * caption text of AcLanguageText widgets: their ApFunction FtLangTextNN
    (v10/maincpu/storage/flash_floppy_handlers.s) returns a 6-entry language pointer table; entry 0
    (English) is read from the tracked original_ROMs/kn5000_v10_program.rom at the address that
    symbols/maincpu_v10_symbols_reference.txt gives the table's label.

HOW EACH CLASS IS DRAWN (firmware evidence; "approx." = not traced to the pixel)
--------------------------------------------------------------------------------
  TtlScreen, Screen  fill rect with `color`.
  Box                fill rect with `color` (CL_Transparent: no fill), then `border`.  approx.: the
                     border styles BD_3D_UP2 / BD_Double1 / BD_EditSwitch are drawn as 2 px bevels / a
                     double line / a 1 px outline + bevel; BoxProc's exact pixel pattern is kn5000-5dc.
  Label              LabelProc (ui/ui_window_procs.s) draws `str` at (x1 + 2, y1 + 1) with DrawString,
                     font = the `font` id (DrawString indexes FontDescriptor_Table, 0x945C00 + 16 * id, so
                     idCHARA1 = font 0 ... idCHARA5W = font 9), foreground `fontcolor`, background 0xF7
                     (transparent).  Fixed fonts advance by the descriptor width, font 5 by its kern table
                     (CalcTotalWidth, display/graphics_text_vga.s).
  AcLanguageText     box as above, then the English text word-wrapped (WordwrapStrings breaks at spaces)
                     into at most `lines` lines, aligned by `alignment`.  approx.: lines are stacked at the
                     font height and the block is centred vertically in the rect.
  Line               from the rect's top-left to bottom-right (LM_RightDown) or bottom-left to top-right
                     (LM_RightUp), in `color`.
  Frame              a `width`-pixel outline in `color`.
  PsEditSwBox,       box as above; VwEditSwBox also draws its `str` centred.
  VwEditSwBox
  Bitmap             approx.: a dotted outline with the bitmap id's name (the icon pictures are not
                     looked up).
  VwUserBitmapByName the FTBMP picture at the rect's top-left, exactly as DrawBitmapFile_Impl
                     (ui/drawing_primitives.s) does it: the BMP is tiled into a 320 x 240 buffer, a 16-bit
                     (wrapping) histogram of its pixel values is taken, the BMP palette is comb-sorted by
                     that count, most used first (Gfx_DecodeImageToBuffer, ui/ui_window_procs.s: gap * 10/13,
                     9 and 10 -> 11), the pixels are remapped, the picture's width x height rows are copied to
                     the screen, and ChangePalette_Impl(3) loads palette entries 0x00-0xDF from the sorted
                     table at OFFSCREEN_BUFFER_4 (0x69400).  Entries 0xE0-0xFF (the UI colours CL_Gray ..
                     CL_White) keep their system values, so a widget drawn in CL_Black (0), CL_Silver (7),
                     CL_DarkGray (8) or CL_Orange (9) on a slide with a picture shows the picture's colour of
                     that rank -- as on the keyboard.
  any other class    approx.: a dotted outline with the class name; its children are still drawn.

  Screens without a picture use the system palette for 0x00-0xDF.  On the keyboard those entries are
  whatever the last ChangePalette left (normally the wallpaper's); that is an inference, not traced.

RUN
---
    python3 scripts/generators/render_ftdemo_slides.py [OUTDIR] [--tree v10] [--all] [--scale N]

OUTDIR defaults to rebuilt_ROMs/ftdemo_slides/ (git-ignored: the PNGs are build outputs, never commit
them).  Writes act01_ftdemo01.png .. act27_ftdemo25.png and index.txt (ACT, object, widget counts, any
class drawn only as an outline).
"""
import argparse
import os
import re
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'analysis'))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'build'))
import naka_gui_model as M  # noqa: E402

W, H = 320, 240
TRANSPARENT = 0xF7


def rd(rel):
    return open(os.path.join(ROOT, rel), 'rb').read()


# ------------------------------------------------------------------ constants and resources
def header_values(tree):
    """name -> value of the #defines of naka_classes.h / naka_ids.h (CL_, BD_, idCHARA, LM_ ...)."""
    return M.ids_values(tree)


def system_palette():
    b = rd('v10/maincpu/images/Palette_8bit_RGBA.bin')
    return [tuple(b[4 * i:4 * i + 3]) for i in range(256)]


def font_descriptors():
    """[(width, height, d4, d6, kern?)] from FontDescriptor_Table in table_data/fonts.s."""
    src = rd('table_data/fonts.s').decode('latin1')
    seg = src[src.index('FontDescriptor_Table:'):]
    out = []
    for m in re.finditer(r'^\t\.short\t(\d+), (\d+), (\d+), (\d+)\n\t\.long\t(\w+), (\w+)', seg, re.M):
        out.append((int(m.group(1)), int(m.group(2)), int(m.group(3)), int(m.group(4)), m.group(6) != '0'))
        if len(out) == 10:
            break
    assert len(out) == 10, out
    return out


class Font:
    def __init__(self, n, desc):
        self.n = n
        self.w, self.h = desc[0], desc[1]
        self.sheet = Image.open(os.path.join(ROOT, 'table_data', 'images', 'fonts', 'Font%d_Glyphs.png' % n)).convert('1')
        if n == 5:
            import font_images
            self.widths = [w for w, _ in font_images.font5_widths()]
            self.cell = font_images.F5_CELL
        else:
            self.widths = [self.w] * 224
            self.cell = ((self.w + 7) // 8) * 8
        self.px = self.sheet.load()

    def width_of(self, ch):
        c = ch if 0x20 <= ch <= 0xFF else 0x20
        return self.widths[c - 0x20]

    def text_width(self, s):
        return sum(self.width_of(c) for c in s)

    def draw(self, buf, x, y, s, color, clip=(0, 0, W - 1, H - 1)):
        for ch in s:
            c = ch if 0x20 <= ch <= 0xFF else 0x20
            g = c - 0x20
            gx, gy = (g % 16) * self.cell, (g // 16) * self.h
            w = self.width_of(c)
            for yy in range(self.h):
                for xx in range(w):
                    if self.px[gx + xx, gy + yy]:
                        buf.put(x + xx, y + yy, color, clip)
            x += w
        return x


class Buf:
    def __init__(self, pal):
        self.px = bytearray([0xFF] * (W * H))
        self.pal = list(pal)

    def put(self, x, y, c, clip=(0, 0, W - 1, H - 1)):
        if c == TRANSPARENT or c is None:
            return
        if clip[0] <= x <= clip[2] and clip[1] <= y <= clip[3] and 0 <= x < W and 0 <= y < H:
            self.px[y * W + x] = c

    def fill(self, x, y, w, h, c):
        if c == TRANSPARENT or c is None:
            return
        for yy in range(max(0, y), min(H, y + h)):
            for xx in range(max(0, x), min(W, x + w)):
                self.px[yy * W + xx] = c

    def hline(self, x, y, w, c):
        self.fill(x, y, w, 1, c)

    def vline(self, x, y, h, c):
        self.fill(x, y, 1, h, c)

    def rect(self, x, y, w, h, c, t=1):
        for i in range(t):
            self.hline(x + i, y + i, w - 2 * i, c)
            self.hline(x + i, y + h - 1 - i, w - 2 * i, c)
            self.vline(x + i, y + i, h - 2 * i, c)
            self.vline(x + w - 1 - i, y + i, h - 2 * i, c)

    def dotted(self, x, y, w, h, c):
        for xx in range(x, x + w, 2):
            self.put(xx, y, c)
            self.put(xx, y + h - 1, c)
        for yy in range(y, y + h, 2):
            self.put(x, yy, c)
            self.put(x + w - 1, yy, c)

    def line(self, x0, y0, x1, y1, c):
        dx, dy = abs(x1 - x0), -abs(y1 - y0)
        sx, sy = (1 if x0 < x1 else -1), (1 if y0 < y1 else -1)
        err = dx + dy
        while True:
            self.put(x0, y0, c)
            if x0 == x1 and y0 == y1:
                return
            e2 = 2 * err
            if e2 >= dy:
                err += dy
                x0 += sx
            if e2 <= dx:
                err += dx
                y0 += sy

    def image(self, scale=1):
        im = Image.frombytes('P', (W, H), bytes(self.px))
        flat = []
        for rgb in self.pal:
            flat.extend(rgb)
        im.putpalette(flat)
        im = im.convert('RGB')
        if scale != 1:
            im = im.resize((W * scale, H * scale), Image.NEAREST)
        return im


# ------------------------------------------------------------------ FTBMP: DrawBitmapFile_Impl
def comb_sort_palette(counts):
    """Gfx_DecodeImageToBuffer's sort: returns order[k] = original index at rank k."""
    counts = list(counts)
    order = list(range(256))
    gap = 0x100
    while True:
        gap = gap * 1000000 // 1300000
        if gap in (9, 10):
            gap = 11
        elif gap == 0:
            gap = 1
        swaps = 0
        for i in range(256 - gap):
            if counts[i] < counts[i + gap]:
                counts[i], counts[i + gap] = counts[i + gap], counts[i]
                order[i], order[i + gap] = order[i + gap], order[i]
                swaps += 1
        if swaps == 0 and gap <= 1:
            return order


def draw_ftbmp(buf, key, x, y):
    """DrawBitmapFile_Impl + Gfx_DecodeImageToBuffer, step by step (see the module docstring)."""
    im = Image.open(os.path.join(ROOT, 'table_data', 'images', key + '.png'))
    assert im.mode == 'P', key
    bw, bh = im.size
    flat = im.getpalette()[:768]
    pal = [tuple(flat[3 * i:3 * i + 3]) for i in range(256)]
    pix = im.tobytes()
    # 1. tiled into 320 x 240 (TileRow / FillRemaining); 16-bit (wrapping) histogram; colours in use
    counts = [0] * 256
    for yy in range(H):
        row = pix[(yy % bh) * bw:(yy % bh) * bw + bw]
        for xx in range(W):
            v = row[xx % bw]
            counts[v] = (counts[v] + 1) & 0xFFFF
    used = sum(1 for c in counts if c)
    # 2. comb sort, most used first; 3. map[orig] = rank
    order = comb_sort_palette(counts)
    spal = [pal[o] for o in order]
    remap = [0] * 256
    for rank, orig in enumerate(order):
        remap[orig] = rank
    # 4. more than 0xC0 colours: ranks 0xC0.. go to the nearest of ranks 0..0xBF (squared RGB distance,
    #    first minimum wins)
    if used > 0xC0:
        for rank in range(0xC0, used):
            r0, g0, b0 = spal[rank]
            best, bi = 0x7FFFFFFF, 0
            for k in range(0xC0):
                r1, g1, b1 = spal[k]
                d = (g0 - g1) ** 2 + (r0 - r1) ** 2 + (b0 - b1) ** 2
                if best > d:
                    best, bi = d, k
            remap[order[rank]] = bi
    # 5./6. ranks 0..0xBF become palette entries and pixel values 0x20..0xDF
    for yy in range(bh):
        if y + yy >= H:
            break
        for xx in range(bw):
            v = remap[pix[yy * bw + xx]]
            v = v + 0x20 if v < 0xC0 else (0 if v < 0xE0 else v)
            buf.put(x + xx, y + yy, v, clip=(0, 0, 10 ** 6, H - 1))
    # 7. ChangePalette_Impl(3): entries 0x20-0xDF from OFFSCREEN_BUFFER_4
    for k in range(0xC0):
        buf.pal[0x20 + k] = spal[k]
    return bw, bh


def convert_string(s):
    """ConvertStrings (display/graphics_text_vga.s): '~' + two hex digits is that character code,
    control characters become spaces."""
    out, i = bytearray(), 0
    while i < len(s):
        c = s[i]
        if c == 0x7E and i + 2 < len(s) + 1:
            h = s[i + 1:i + 3]
            try:
                out.append(int(h.decode('latin1'), 16))
            except ValueError:
                out.append(c)
                i += 1
                continue
            i += 3
            continue
        out.append(0x20 if c < 0x20 else c)
        i += 1
    return bytes(out)


def draw_wall(buf, wallpaper):
    """Screen_Paint -> DrawWall: the current wallpaper fills the screen.  Its pixels use entries
    0xE0-0xEF, which the system palette already holds (Wallpaper_1's ramp)."""
    if wallpaper is None:
        return
    im = Image.open(os.path.join(ROOT, 'table_data', 'images', 'Wallpaper_%d.png' % wallpaper))
    buf.px[:] = im.tobytes()


# ------------------------------------------------------------------ captions (AcLanguageText)
def caption_texts():
    """ApFunction name (FtLangTextNN) -> English text, read from the tracked v10 ROM image."""
    syms = {}
    for ln in open(os.path.join(ROOT, 'symbols', 'maincpu_v10_symbols_reference.txt')):
        p = ln.split()
        if len(p) == 2 and not ln.startswith('#'):
            syms[p[0]] = int(p[1], 16)
    rom = rd('original_ROMs/kn5000_v10_program.rom')
    src = rd('v10/maincpu/storage/flash_floppy_handlers.s').decode('latin1')
    out = {}
    for m in re.finditer(r'^(FtLangText\w+):\n\tcp\txbc, EVT_GET_LANGUAGE_PTR\n\tjr\tnz, \w+\n'
                         r'\tlda\txhl, \((\w+):24\)', src, re.M):
        t = syms[m.group(2)] - 0xE00000
        p = int.from_bytes(rom[t:t + 4], 'little') - 0xE00000
        out[m.group(1)] = convert_string(rom[p:rom.index(b'\0', p)])
    return out


def wrap(font, s, maxw):
    words, lines, cur = s.split(b' '), [], b''
    for wd in words:
        cand = wd if not cur else cur + b' ' + wd
        if cur and font.text_width(cand) > maxw:
            lines.append(cur)
            cur = wd
        else:
            cur = cand
    if cur:
        lines.append(cur)
    return lines


# ------------------------------------------------------------------ the renderer
class Renderer:
    def __init__(self, tree, wallpaper=1):
        self.tree = tree
        self.wallpaper = wallpaper
        self.ids = header_values(tree)
        self.desc = font_descriptors()
        self.fonts = {}
        self.captions = caption_texts()
        self.files = [M.CFile(p) for p in M.tree_files(tree)]
        self.files = [f for f in self.files if f.records]
        self.strings = {f.name: M.file_strings(f) for f in self.files}
        self.by_name = {}
        for f in self.files:
            for r in f.records:
                if r['resname'] and r['cls'] in ('TtlScreen', 'Screen'):
                    self.by_name.setdefault(r['resname'], (f, r))

    def font(self, n):
        if n not in self.fonts:
            self.fonts[n] = Font(n, self.desc[n])
        return self.fonts[n]

    def val(self, f, r, field, default=None):
        v = r['fields'].get(field)
        if v is None:
            return default
        v = v.strip()
        if re.match(r'^-?(0x[0-9A-Fa-f]+|\d+)$', v):
            return int(v, 0)
        return self.ids.get(v, default)

    def rect(self, r):
        m = re.match(r'NAKA_XYWH\((-?\d+), (-?\d+), (-?\d+), (-?\d+)\)', r['fields'].get('rect', ''))
        return tuple(int(x) for x in m.groups()) if m else (0, 0, 0, 0)

    def text(self, f, r, field):
        mm = re.match(r'^SELF\((\w+)\)$', r['fields'].get(field, '').strip())
        if not mm:
            return None
        s = self.strings[f.name].get(mm.group(1))
        return convert_string(s.encode('latin1', 'replace')) if s is not None else None

    def border(self, buf, x, y, w, h, bd):
        n = {v: k for k, v in self.ids.items() if k.startswith('BD_')}.get(bd, '')
        white, dark, black = self.ids['CL_White'], self.ids['CL_DarkGray'], self.ids['CL_Black']
        if n in ('', 'BD_None'):
            return
        if n.startswith('BD_3D_UP') or n.startswith('BD_3D_DOWN') or n in ('BD_EditSwitch', 'BD_EditSwDown'):
            t = 2 if n.endswith('2') else 1
            hi, lo = (white, dark) if 'UP' in n or n == 'BD_EditSwitch' else (dark, white)
            if n.startswith('BD_Edit'):
                buf.rect(x, y, w, h, black)
                x, y, w, h = x + 1, y + 1, w - 2, h - 2
            for i in range(t):
                buf.hline(x + i, y + i, w - 2 * i, hi)
                buf.vline(x + i, y + i, h - 2 * i, hi)
                buf.hline(x + i, y + h - 1 - i, w - 2 * i, lo)
                buf.vline(x + w - 1 - i, y + i, h - 2 * i, lo)
        elif n == 'BD_Double1':
            buf.rect(x, y, w, h, black)
            buf.rect(x + 2, y + 2, w - 4, h - 4, black)
        else:
            buf.rect(x, y, w, h, black)

    def title_bar(self, buf, x, y, w, title):
        """DrawTitleBar (audio/presentation_sound_nav.s): the title in white, font 4 (font 1 when it does
        not fit), centred in the 28-pixel band below the screen's top edge, inset 4 px.  approx.: the
        vertical placement inside the band."""
        fn = self.font(4)
        if fn.text_width(title) > w - 8:
            fn = self.font(1)
        self.draw_text_block(buf, x + 4, y, w - 8, 28, [title], fn, self.ids['CL_White'], self.ids['AL_Center'])

    def draw_text_block(self, buf, x, y, w, h, lines, font, color, align):
        fh = font.h
        y0 = y + max(0, (h - fh * len(lines)) // 2)
        for i, ln in enumerate(lines):
            tw = font.text_width(ln)
            if align == self.ids['AL_LeftJustify']:
                tx = x + 2
            elif align == self.ids['AL_RightJustify']:
                tx = x + w - 2 - tw
            else:
                tx = x + (w - tw) // 2
            font.draw(buf, tx, y0 + i * fh, ln, color, clip=(x, y, x + w - 1, y + h - 1))

    def draw(self, buf, f, r, stats):
        cls = r['cls']
        x, y, w, h = self.rect(r)
        color = self.val(f, r, 'color')
        stats['widgets'] = stats.get('widgets', 0) + 1
        if cls in ('TtlScreen', 'Screen'):
            draw_wall(buf, self.wallpaper)
            title = self.text(f, r, 'title') if cls == 'TtlScreen' else None
            if title:
                self.title_bar(buf, x, y, w, title)
        elif cls in ('Box', 'PsEditSwBox', 'VwEditSwBox', 'AcLanguageText'):
            buf.fill(x, y, w, h, color)
            self.border(buf, x, y, w, h, self.val(f, r, 'border', 0))
            if cls == 'VwEditSwBox':
                s = self.text(f, r, 'str')
                if s:
                    fn = self.font(self.val(f, r, 'font', 0))
                    self.draw_text_block(buf, x, y, w, h, [s], fn, self.val(f, r, 'fontcolor'), self.ids['AL_Center'])
            if cls == 'AcLanguageText':
                func = r['fields'].get('func', '').replace('NAKA_APFUNC_', '')
                s = self.captions.get(func)
                if s is None:
                    stats.setdefault('missing_text', []).append(func)
                elif s:
                    fn = self.font(self.val(f, r, 'font', 0))
                    lines = wrap(fn, s, w - 4)[:max(1, self.val(f, r, 'lines', 1))]
                    self.draw_text_block(buf, x, y, w, h, lines, fn, self.val(f, r, 'fontcolor'),
                                         self.val(f, r, 'alignment', 0))
        elif cls == 'Label':
            s = self.text(f, r, 'str')
            if s:
                self.font(self.val(f, r, 'font', 0)).draw(buf, x + 2, y + 1, s, self.val(f, r, 'fontcolor'))
        elif cls == 'Line':
            lm = self.val(f, r, 'linemode', 1)
            if lm == self.ids['LM_RightUp']:
                buf.line(x, y + h - 1, x + w - 1, y, color)
            else:
                buf.line(x, y, x + w - 1, y + h - 1, color)
        elif cls == 'Frame':
            buf.rect(x, y, w, h, color, max(1, self.val(f, r, 'width', 1)))
        elif cls == 'VwUserBitmapByName':
            key = (self.text(f, r, 'file') or b'').decode('latin1')
            if os.path.exists(os.path.join(ROOT, 'table_data', 'images', key + '.png')):
                draw_ftbmp(buf, key, x, y)
                stats.setdefault('pictures', []).append(key)
            else:
                buf.dotted(x, y, w, h, self.ids['CL_Red'])
                stats.setdefault('outlined', []).append('%s(%s)' % (cls, key))
        else:
            buf.dotted(x, y, max(w, 1), max(h, 1), self.ids['CL_DarkGray'])
            label = r['fields'].get('bmp', cls).encode('latin1')
            self.font(3).draw(buf, x + 1, y + 1, label, self.ids['CL_DarkGray'], clip=(x, y, x + w - 1, y + h - 1))
            stats.setdefault('outlined', []).append(cls)
        for ck in self.children(f, r):
            self.draw(buf, f, ck, stats)

    def children(self, f, r):
        recs = {(q['slot'], q['elem']): q for q in f.records}
        out, k, seen = [], f.link_value(r['fields'].get('sub', 'NAKA_NONE')), set()
        while k not in (None, M.NONE) and k not in seen:
            seen.add(k)
            q = recs.get((r['slot'], k))
            if q is None:
                break
            out.append(q)
            k = f.link_value(q['fields'].get('next', 'NAKA_NONE'))
        return out

    def render(self, name):
        f, r = self.by_name[name]
        buf = Buf(system_palette())
        stats = {}
        self.draw(buf, f, r, stats)
        return buf, stats


def acts():
    src = rd('table_data/kn5000_table_data.s').decode('latin1')
    seg = src[src.index('Feature_Demo_XML:'):]
    seg = seg[:seg.index('</ACTION>')]
    return [(int(n), o) for n, o in re.findall(r'<ACT NO=(\d+)><SHOW OBJ=\\"(\w+)\\"></ACT>', seg)]


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[1])
    ap.add_argument('outdir', nargs='?', default=os.path.join(ROOT, 'rebuilt_ROMs', 'ftdemo_slides'))
    ap.add_argument('--tree', default='v10')
    ap.add_argument('--all', action='store_true', help='also render the ftdemo screens no ACT shows')
    ap.add_argument('--scale', type=int, default=1)
    ap.add_argument('--wallpaper', default='1', choices=['0', '1', 'none'],
                    help='the wallpaper DrawWall paints behind every screen (default 1, the factory one)')
    a = ap.parse_args()
    os.makedirs(a.outdir, exist_ok=True)
    R = Renderer(a.tree, None if a.wallpaper == 'none' else int(a.wallpaper))
    jobs = [('act%02d_%s' % (n, o), o, n) for n, o in acts()]
    if a.all:
        shown = {o for _, o, _ in jobs}
        jobs += [('screen_%s' % n, n, None) for n in sorted(R.by_name) if n.startswith('ftdemo') and n not in shown]
    index = []
    for stem, obj, n in jobs:
        buf, st = R.render(obj)
        path = os.path.join(a.outdir, stem + '.png')
        buf.image(a.scale).save(path)
        index.append('%-22s ACT %-4s %-10s widgets %3d  pictures %-10s outlined %s%s' % (
            stem + '.png', n if n is not None else '-', obj, st.get('widgets', 0), ','.join(st.get('pictures', [])) or '-',
            ','.join(sorted(set(st.get('outlined', [])))) or '-',
            ('  MISSING TEXT ' + ','.join(st['missing_text'])) if st.get('missing_text') else ''))
    with open(os.path.join(a.outdir, 'index.txt'), 'w') as fh:
        fh.write('\n'.join(index) + '\n')
    print('\n'.join(index))
    print('wrote %d PNGs to %s' % (len(jobs), a.outdir))


if __name__ == '__main__':
    main()
