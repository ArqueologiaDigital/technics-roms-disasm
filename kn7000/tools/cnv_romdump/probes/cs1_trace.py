#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# cs1_trace.py SERVICE_MANUAL.pdf SCRATCH_DIR -- what does the MN103002A's chip select CS1 (pin 52, RAS1/CS1)
# drive on the KN7000 main board? The SURVEY2 build reads 2 MB of CS1 (at 0x84000000) on the strength of the
# answer: nothing but IC23, so the whole window is memory. Service manual (technics_sx-kn7000_keyboard.pdf):
# p.100 is MAIN 1/5 sheet 1/2 (the CPU), p.102 sheet 2/2 (the memories); the two pages join edge to edge.
#
# It renders, with pdftoppm at 400 dpi, a thin horizontal strip through the CS lines on each page and finds the
# lines that run across it. For each line it lists what touches it: a narrow mark above and below is a wire
# crossing it (no connection in this schematic's style); a wide mark (>= 6 px) is a junction dot; a mark on
# one side only is a wire that ends on it (a corner or a T).
#   page 100: three lines leave the CPU's bus-control pins, CS2 (thick), CS1, CS3. CS1 must have exactly one
#             dot, on CPU pin 52's column, and only crossings up to the right edge of the page;
#   page 102: CS1 comes in at the left edge and must run, with crossings only, to the one place where a wire
#             leaves it downwards: the emitter of Q3 (UN5216), whose collector is IC23's /CE (pin 6; R38 4.7K
#             pulls it up to the backup supply, so a powered-down CPU cannot select the chip).
# The pin and part labels are not read by this script. Look at them in the crops it also writes:
# cpu_pins.png (pins 51-54 CS0, RAS1/CS1, RAS2/CS2, RAS3/CS3 and the junction where CS1 turns right) and
# q3_ic23.png (Q3, R38 and IC23's /CE).
#   python3 -I cs1_trace.py ~/compartilhado/KN7000/service_manual/technics_sx-kn7000_keyboard.pdf $T
import os
import subprocess
import sys

from PIL import Image

pdf, out = sys.argv[1], sys.argv[2]
os.makedirs(out, exist_ok=True)


def render(page, x, y, w, h, name, gray=True):
    base = os.path.join(out, name)
    subprocess.run(['pdftoppm', '-f', str(page), '-l', str(page), '-r', '400', '-x', str(x), '-y', str(y),
                    '-W', str(w), '-H', str(h), '-singlefile', '-png'] + (['-gray'] if gray else []) + [pdf, base],
                   check=True)
    return base + '.png'


def runs(xs):
    out = []
    for x in xs:
        if out and x - out[-1][1] <= 1:
            out[-1][1] = x
        else:
            out.append([x, x])
    return out


def lines(path, x0):
    """The horizontal lines across the strip at path (whose left edge is page x x0, at 400 dpi)."""
    im = Image.open(path).convert('L')
    W, H = im.size
    px = im.load()
    dark = lambda x, y: 0 <= y < H and px[x, y] < 128                    # noqa: E731
    rows = [y for y in range(H) if sum(dark(x, y) for x in range(W)) > W * 0.4]
    found = []
    for r in runs(rows):
        top, bot = r
        xs = [x for x in range(W) if all(dark(x, y) for y in range(top, bot + 1))]
        seg = max(runs(xs), key=lambda s: s[1] - s[0])                      # the line itself
        up = runs([x for x in range(seg[0], seg[1] + 1) if dark(x, top - 4)])
        dn = runs([x for x in range(seg[0], seg[1] + 1) if dark(x, bot + 4)])
        marks = []
        for a, b in up + dn:
            other = dn if [a, b] in up else up
            both = any(c <= b and a <= d for c, d in other)
            wide = b - a + 1 >= 6
            kind = 'dot' if wide else ('crossing' if both else ('wire up' if [a, b] in up else 'wire down'))
            marks.append((a + x0, b + x0, kind))
        found.append((top, bot, seg[0] + x0, seg[1] + x0, sorted(set(marks))))
    return found


PAGE100 = (100, 3200, 3540, 3408, 100)        # the strip right of the CPU, through the three CS lines
PAGE102 = (102, 0, 3530, 6608, 100)           # the same height on the facing page
for (page, x, y, w, h) in (PAGE100, PAGE102):
    path = render(page, x, y, w, h, f'strip_p{page}')
    print(f'page {page}, strip x {x}-{x + w - 1}, y {y}-{y + h - 1} (400 dpi):')
    for top, bot, a, b, marks in lines(path, x):
        kinds = [m[2] for m in marks]
        print(f'  line at y {y + top}-{y + bot}, x {a}-{b}: {kinds.count("crossing")} crossings, '
              f'dots at {[m[:2] for m in marks if m[2] == "dot"]}, wires ending on it '
              f'{[m for m in marks if m[2].startswith("wire")]}')
render(100, 3000, 2700, 1100, 1100, 'cpu_pins', gray=False)
render(102, 4300, 3300, 1300, 1100, 'q3_ic23', gray=False)
print(f'crops for the labels: {os.path.join(out, "cpu_pins.png")}, {os.path.join(out, "q3_ic23.png")}')
