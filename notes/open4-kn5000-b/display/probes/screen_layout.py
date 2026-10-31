#!/usr/bin/env python3
"""The common KN5000 screen layout, from the widget records' rectangles  (kn5000-rq0).

Question answered: where on the 320 x 240 LCD does the firmware put the widgets that the panel's
soft buttons operate, and how much do the screens agree?  Every record of v10's NAKA GUI C
sources (<tree>/maincpu/ui_widgets/*.c, read with scripts/analysis/naka_gui_model.py) that has
both an `editsw` field (ES_Left1..5, ES_Right1..5, ES_Bottom1..8, ES_Exit: the switch that
operates it) and a `rect` is counted; for each switch the most common rectangles are printed
with their share.  Also printed: the TtlScreen rectangles (every title's root view) and the
classes of records whose top edge is in the title strip (y < 28).

The title strip itself is drawn by code, not by a record: TtlScreenProc's EVT_DRAW calls
DrawTitleBar, which takes the screen rectangle x1 + 4 .. x2 - 4, y1 .. y1 + 27
(audio/presentation_sound_nav.s).

Usage:
  python3 notes/open4-kn5000-b/display/probes/screen_layout.py [tree]
  python3 notes/open4-kn5000-b/display/probes/screen_layout.py v10 --png OUT.png
      (--png draws the modal zone of every switch and the title strip on a blank 320 x 240
       canvas, scaled 3x; needs Pillow.  The PNG is a derived output: do not commit it.)
"""
import collections
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'analysis'))
import naka_gui_model as M  # noqa: E402

RECT = re.compile(r'NAKA_XYWH\((\d+), (\d+), (\d+), (\d+)\)')
ORDER = ([f'ES_Left{i}' for i in range(1, 6)] + [f'ES_Right{i}' for i in range(1, 6)] +
         [f'ES_Bottom{i}' for i in range(1, 9)] + ['ES_Exit'])


def collect(tree):
    by_sw = collections.defaultdict(collections.Counter)
    ttl = collections.Counter()
    top = collections.Counter()
    for p in M.tree_files(tree):
        f = M.CFile(os.path.join(ROOT, p) if not os.path.isabs(p) else p)
        for r in f.records:
            m = RECT.search(r['fields'].get('rect', ''))
            if not m:
                continue
            rc = tuple(map(int, m.groups()))
            if r['cls'] == 'TtlScreen':
                ttl[rc] += 1
            elif rc[1] < 28 and rc[3] < 240:
                top[r['cls']] += 1
            es = r['fields'].get('editsw')
            if es:
                by_sw[es][rc] += 1
    return by_sw, ttl, top


def main():
    args = sys.argv[1:]
    png = None
    if '--png' in args:
        i = args.index('--png')
        png = args[i + 1]
        del args[i:i + 2]
    tree = args[0] if args else 'v10'
    by_sw, ttl, top = collect(tree)
    print(f'TtlScreen rectangles: {dict(ttl)}')
    print(f'records with top edge y < 28 (not full-screen), by class: {top.most_common(12)}')
    print()
    rows, modal = [], {}
    for sw in ORDER:
        c = by_sw.get(sw)
        if not c:
            continue
        tot = sum(c.values())
        (rc, n), *rest = c.most_common(3)
        modal[sw] = rc
        rows.append([sw, str(tot), '%d, %d, %d, %d' % rc, '%d%%' % (100 * n // tot),
                     '; '.join('%d, %d, %d, %d (x%d)' % (r + (k,)) for r, k in rest)])
    hdr = ['switch', 'records', 'most common x, y, w, h', 'share', 'next most common']
    w = [max(len(r[j]) for r in rows + [hdr]) for j in range(len(hdr))]
    line = lambda r: '| ' + ' | '.join(r[j].ljust(w[j]) for j in range(len(hdr))) + ' |'
    print(line(hdr))
    print('|' + '|'.join('-' * (x + 2) for x in w) + '|')
    for r in rows:
        print(line(r))
    if png:
        from PIL import Image, ImageDraw
        s = 3
        im = Image.new('RGB', (320 * s, 240 * s), 'white')
        d = ImageDraw.Draw(im)
        d.rectangle([4 * s, 0, 315 * s, 27 * s], outline='black', width=2)
        d.text((8 * s, 8 * s), 'title strip (DrawTitleBar): x 4..315, y 0..27', fill='black')
        for sw, (x, y, w, h) in modal.items():
            col = {'L': 'blue', 'R': 'green', 'B': 'red', 'E': 'purple'}[sw[3]]
            d.rectangle([x * s, y * s, (x + w - 1) * s, (y + h - 1) * s], outline=col, width=2)
            d.text((x * s + 4, y * s + 4), sw[3:], fill=col)
        im.save(png)
        print(f'\nwrote {png}')


if __name__ == '__main__':
    main()
