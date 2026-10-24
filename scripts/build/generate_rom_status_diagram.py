#!/usr/bin/env python3
"""ROM status diagram for the documentation website.

QUESTION ANSWERED: for every byte of the six KN5000 images shown on the site's
ROM-reconstruction page (main CPU v10, table data, sub-CPU boot IC30, sub-CPU
payload v1.42, custom data IC19, HD-AE5000), what kind of source emits it?
One pixel is 8 bytes, so each block's area is proportional to its ROM size.

WHERE THE CLASSES COME FROM
    The per-byte map is scripts/analysis/data_range_census.py's map, not a
    re-parse of the sources: that tool links a marked mirror of each LLVM tree,
    proves the mirror still byte-matches the dump, and puts every byte in exactly
    one bucket (it fails the run when the buckets do not add up to the dump).
    This script reuses its functions and adds one split of its own:

        Assembly code     census bucket CODE (instruction statements)
        Compiled C        a data region all of whose lines are `.incbin` of a file
                          that kn5000_source_coverage.classify_incbin() calls
                          'clang' (the byte-exact clang -target tlcs900 output
                          under <tree>/includes/generated/)
        Data, explained   census grade KNOWN-A (purpose stated, evidence cited)
        Data, named       census grade KNOWN-B (descriptive name and header)
        Data, unexplained census grade UNKNOWN
        Filler            census grade FILLER (verified uniform fill, >= 16 B)

    The census describes what the SOURCE claims; code spelled as `.byte` counts
    as data and data spelled as instructions counts as code.  See the census's
    own docstring for those limits.

    History: until 2026-10-24 this script parsed the ASL `.asm` files that were
    archived in 38e7d9f, found none of them, and painted every image
    "Undetermined"; it also wrote into scripts/kn5000-docs/ inside this repo.

DOCS PAGE (follow-up, not yet done)
    technics-docs rom-reconstruction.md still carries the old nine-colour legend
    (strings, pointer tables, binary includes, orange, yellow) and a "This image
    is stale" box.  The first commit in technics-docs that publishes a diagram
    from this script must replace both with this legend, which is CLASSES below:
        green = assembly code · light green = compiled C (clang `.incbin`) ·
        blue = data, purpose explained (census A) · cyan = data, named
        (census B) · red = data, purpose unexplained · gray = verified filler.

RUN (needs the pinned LLVM toolchain; about two minutes)
    python3 scripts/build/generate_rom_status_diagram.py --docs-dir ../technics-docs
    make rom-status DOCS_DIR=/path/to/technics-docs

    Writes <docs-dir>/assets/images/rom-status-diagram.png.  The docs directory
    must already exist: the script refuses rather than creating one.
"""
import argparse
import math
import os
import shutil
import sys
import tempfile

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, "scripts", "analysis"))
import data_range_census as drc          # noqa: E402
import kn5000_source_coverage as ksc     # noqa: E402
# kn5000_source_coverage takes its repo root from the first non-option argv
# entry AT IMPORT TIME, so `--docs-dir PATH` would become its REPO; pin it.
ksc.REPO = REPO

BYTES_PER_PIXEL = 8

# class id -> (legend text, RGB)
CLASSES = [
    ("Assembly code", (0, 150, 0)),
    ("Compiled C (clang .incbin)", (120, 210, 60)),
    ("Data, purpose explained (census A)", (0, 100, 220)),
    ("Data, named (census B)", (0, 190, 190)),
    ("Data, purpose unexplained", (220, 40, 40)),
    ("Filler (verified uniform)", (150, 150, 150)),
]
ASM, CC, KA, KB, UNK, FILL = range(len(CLASSES))
# Internal sentinel for "no census bucket yet"; class_map() refuses to return a
# map that still holds it, so it is never drawn and has no legend entry.
NONE = len(CLASSES)
GRADE_CLASS = {"CODE": ASM, "KNOWN-A": KA, "KNOWN-B": KB, "UNKNOWN": UNK, "FILLER": FILL}

# (census key, block title); the first two form the left column.
LAYOUT_LEFT = [("v10", "Main CPU v10"), ("tabledata", "Table Data")]
LAYOUT_RIGHT = [("subboot", "Sub CPU Boot IC30"), ("v142", "Sub CPU Payload v1.42"),
                ("hdae5000", "HD-AE5000 v2.06i"), ("customdata", "Custom Data IC19")]


def region_is_clang(img, region):
    """True when every line of a census region is an .incbin of clang output."""
    srcroot = os.path.join(REPO, img["mirror"])
    s_file = os.path.join(srcroot, region["rel"])
    with open(s_file, "rb") as fh:
        lines = fh.read().decode("latin-1").split("\n")
    for li in region["lines"]:
        m = ksc.INC.search(ksc.strip_comment(lines[li]))
        if not m:
            return False
        if ksc.classify_incbin(srcroot, s_file, m.group(1))[0] != "clang":
            return False
    return True


def class_map(img, tmp):
    """-> bytearray, one class id per ROM byte."""
    c = drc.census_image(img, tmp)
    if not c["inert"]:
        sys.exit("%s: the marked mirror no longer matches the dump; refusing to draw" % img["key"])
    ctrl, index = drc.scan_refs(os.path.join(REPO, img["mirror"]))
    regions = drc.build_regions(c)
    recs = drc.annotate(c, regions, ctrl, index)
    assert len(recs) == len(regions)
    cls = bytearray([NONE]) * img["size"]
    for reg, rec in zip(regions, recs):
        k = GRADE_CLASS[rec["grade"]]
        if k in (KA, KB, UNK) and ".incbin" in reg["details"] and region_is_clang(img, reg):
            k = CC
        cls[rec["lo"]:rec["hi"]] = bytes([k]) * (rec["hi"] - rec["lo"])
    unmapped = cls.count(NONE)
    if unmapped:
        sys.exit("%s: %d bytes fell in no census bucket; refusing to draw" % (img["key"], unmapped))
    return cls


def pixels(cls, width):
    """Majority class of each 8-byte cell, row-major."""
    out = []
    for i in range(0, len(cls), BYTES_PER_PIXEL):
        cell = cls[i:i + BYTES_PER_PIXEL]
        first = cell[0]
        if cell.count(first) == len(cell):
            out.append(first)
        else:
            out.append(max(set(cell), key=cell.count))
    height = (len(out) + width - 1) // width
    return out, height


def block_width(size):
    if size >= 2 * 1024 * 1024:
        return 512
    w = int(math.sqrt(size // BYTES_PER_PIXEL * 1.5))
    return (w + 7) // 8 * 8


def load_fonts():
    try:
        b = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
        r = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
        return (ImageFont.truetype(b, 18), ImageFont.truetype(b, 13),
                ImageFont.truetype(r, 11), ImageFont.truetype(r, 12))
    except OSError:
        f = ImageFont.load_default()
        return f, f, f, f


def draw(blocks, out_path):
    margin, gap_h, gap_v, label_h, title_h = 25, 30, 20, 50, 45
    left = [blocks[k] for k, _ in LAYOUT_LEFT]
    right = [blocks[k] for k, _ in LAYOUT_RIGHT]
    col_h = lambda col: sum(b["height"] + label_h for b in col) + gap_v * (len(col) - 1)
    left_w = max(b["width"] for b in left)
    right_w = max(b["width"] for b in right)
    legend_rows = (len(CLASSES) + 2) // 3
    W = margin * 2 + left_w + gap_h + right_w
    H = title_h + max(col_h(left), col_h(right)) + margin * 2 + 40 + legend_rows * 24
    img = Image.new("RGB", (W, H), (255, 255, 255))
    d = ImageDraw.Draw(img)
    title_f, label_f, info_f, legend_f = load_fonts()

    def centred(text, y, font, fill, cx=None):
        bb = d.textbbox((0, 0), text, font=font)
        x = (W if cx is None else 2 * cx) // 2 - (bb[2] - bb[0]) // 2
        d.text((x, y), text, fill=fill, font=font)

    centred("KN5000 ROM Set - what the source emits, byte by byte", margin // 2 + 2, title_f, (0, 0, 0))
    centred("(1 pixel = %d bytes, area proportional to ROM size; classes from data_range_census.py)"
            % BYTES_PER_PIXEL, margin // 2 + 24, info_f, (80, 80, 80))

    def draw_block(b, x, y):
        colours = [CLASSES[k][1] for k in b["pixels"]]
        tile = Image.new("RGB", (b["width"], b["height"]), (40, 40, 40))
        tile.putdata(colours + [(40, 40, 40)] * (b["width"] * b["height"] - len(colours)))
        img.paste(tile, (x, y))
        d.rectangle([x - 1, y - 1, x + b["width"], y + b["height"]], outline=(0, 0, 0))
        cx = x + b["width"] // 2
        size_kb = b["size"] // 1024
        size = "%dMB" % (size_kb // 1024) if size_kb >= 1024 else "%dKB" % size_kb
        centred("%s (%s)" % (b["title"], size), y + b["height"] + 4, label_f, (0, 0, 0), cx)
        pct = lambda k: 100.0 * b["counts"][k] / b["size"]
        centred("code %.1f%% (asm %.1f%% + C %.1f%%)" % (pct(ASM) + pct(CC), pct(ASM), pct(CC)),
                y + b["height"] + 22, info_f, (0, 110, 0), cx)
        return b["height"] + label_h + gap_v

    y = title_h + margin
    for b in left:
        y += draw_block(b, margin, y)
    y = title_h + margin
    for b in right:
        y += draw_block(b, margin + left_w + gap_h, y)

    ly = title_h + max(col_h(left), col_h(right)) + margin + 15
    d.text((margin, ly), "Legend:", fill=(0, 0, 0), font=label_f)
    ly += 22
    iw = (W - margin * 2) // 3
    for i, (text, rgb) in enumerate(CLASSES):
        lx, yy = margin + (i % 3) * iw, ly + (i // 3) * 24
        d.rectangle([lx, yy, lx + 16, yy + 16], fill=rgb, outline=(0, 0, 0))
        d.text((lx + 22, yy + 1), text, fill=(0, 0, 0), font=legend_f)
    img.save(out_path, "PNG")
    return W, H


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--docs-dir", default=os.path.join(REPO, "..", "technics-docs"),
                    help="the documentation website checkout (default: ../technics-docs)")
    a = ap.parse_args()
    docs = os.path.abspath(a.docs_dir)
    if not os.path.isfile(os.path.join(docs, "_config.yml")):
        sys.exit("refusing: %s is not the documentation website checkout (no _config.yml); "
                 "pass --docs-dir / DOCS_DIR=" % docs)
    out_dir = os.path.join(docs, "assets", "images")
    if not os.path.isdir(out_dir):
        sys.exit("refusing: %s does not exist" % out_dir)
    out_path = os.path.join(out_dir, "rom-status-diagram.png")

    by_key = {img["key"]: img for img in drc.IMAGES}
    tmp = tempfile.mkdtemp(prefix="romstatus-")
    blocks = {}
    try:
        for key, title in LAYOUT_LEFT + LAYOUT_RIGHT:
            img = by_key[key]
            print("  %-12s building the census map ..." % key, flush=True)
            cls = class_map(img, tmp)
            w = block_width(img["size"])
            px, h = pixels(cls, w)
            blocks[key] = dict(title=title, size=img["size"], width=w, height=h, pixels=px,
                               counts=[cls.count(k) for k in range(len(CLASSES))])
    finally:
        assert os.path.dirname(os.path.abspath(tmp)) == os.path.abspath(tempfile.gettempdir())
        shutil.rmtree(tmp, ignore_errors=True)

    W, H = draw(blocks, out_path)
    print("\nwrote %s (%dx%d)\n" % (out_path, W, H))
    heads = ["image", "bytes"] + ["asm", "C", "data A", "data B", "data ?", "filler"]
    rows = []
    for key, title in LAYOUT_LEFT + LAYOUT_RIGHT:
        b = blocks[key]
        rows.append([title, "{:,}".format(b["size"])] +
                    ["%.1f%%" % (100.0 * b["counts"][k] / b["size"]) for k in range(len(CLASSES))])
    widths = [max(len(r[i]) for r in rows + [heads]) for i in range(len(heads))]
    fmt = lambda r: "| " + " | ".join(c.ljust(widths[i]) for i, c in enumerate(r)) + " |"
    print(fmt(heads))
    print("|" + "|".join("-" * (w + 2) for w in widths) + "|")
    for r in rows:
        print(fmt(r))


if __name__ == "__main__":
    main()
