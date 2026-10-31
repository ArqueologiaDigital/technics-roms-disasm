#!/usr/bin/env python3
"""
Render the KN5000 UI icons in colour, for the website gallery, from the committed source PNGs.

QUESTION ANSWERED: what do the 177 icons look like on screen?

The source of the icon pixels is table_data/images/icons_png/IconPixels_NNN.png: palette-indexed
PNGs whose pixel value is the ROM's 4-bit nibble (scripts/build/icon_images.py builds the ROM bytes
from them).  This script only paints those nibbles with the colours the firmware shows, writing
RGB renders and the sprite sheet into an output directory outside the source tree (`make gallery`
writes the sheet into the website's gallery).

Until 2026-10-31 this script read the reference ROM and wrote its renders into
table_data/images/icons/, which were committed: 176 one-way renders, the sprite sheet and 14
format-exploration renders (test_*.png).  They duplicated icons_png/ and were deleted (lane
media-cleanup; notes/media-cleanup-2026-10-31/).  Their pixels are reproduced exactly by this
script (notes/media-cleanup-2026-10-31/probes/compare_icon_renders.py).

Format facts (discovered via the DrawIcons routine):
- Icon table at 0x938000: 176 entries of {w16, h16, ptr32}, the w/h fields being UI hit-test
  dimensions, not pixel dimensions; IconPixels_176_Unreferenced, the 177th run, has no entry.
- ALL icons are 24x24 pixels at 4bpp (288 bytes each): DrawIcons has hardcoded loops,
  12 bytes/row x 24 rows.

Usage:
    python3 scripts/analysis/extract_icons.py OUTPUT_DIR          # Icon_NNN.png + IconSpriteSheet.png
    python3 scripts/analysis/extract_icons.py --sheet SHEET.png   # the sprite sheet only
"""

import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("Error: Pillow is required. Install with: pip install Pillow")
    sys.exit(1)

REPO = Path(__file__).resolve().parents[2]
SRC = REPO / "table_data" / "images" / "icons_png"
ICON_WIDTH = ICON_HEIGHT = 24
N_TABLE_ICONS = 176          # IconTable entries; the sheet shows these
N_ICONS = 177                # plus IconPixels_176_Unreferenced, the "E.L.S." signature


# 16-color palette for icons
# Nibble values 0-7 map to palette indices 0-7
# Nibble values 8-15 map to palette indices 248-255
# Colors extracted from main palette at 0xEB37DE
ICON_PALETTE = [
    # Nibbles 0-7 (palette indices 0-7)
    (0, 0, 0),        # 0: Black
    (128, 0, 0),      # 1: Dark Red
    (0, 128, 0),      # 2: Dark Green
    (128, 128, 0),    # 3: Dark Yellow/Olive
    (0, 0, 128),      # 4: Dark Blue
    (128, 0, 128),    # 5: Dark Magenta
    (0, 128, 128),    # 6: Dark Cyan
    (136, 136, 136),  # 7: Light Gray
    # Nibbles 8-15 (palette indices 248-255)
    (96, 96, 96),     # 8: Dark Gray
    (255, 0, 0),      # 9: Bright Red
    (0, 255, 0),      # 10: Bright Green
    (255, 255, 0),    # 11: Bright Yellow
    (0, 0, 255),      # 12: Bright Blue
    (255, 0, 255),    # 13: Bright Magenta
    (0, 255, 255),    # 14: Bright Cyan
    (255, 255, 255),  # 15: White
]


def render(i):
    """Icon i as an RGB image, painted from its committed indexed PNG."""
    src = Image.open(SRC / f"IconPixels_{i:03d}.png")
    assert src.mode == "P" and src.size == (ICON_WIDTH, ICON_HEIGHT), f"icon {i}: {src.mode} {src.size}"
    img = Image.new("RGB", (ICON_WIDTH, ICON_HEIGHT))
    img.putdata([ICON_PALETTE[v & 0x0F] for v in src.tobytes()])
    return img


def sprite_sheet():
    """The 176 table icons, 16 per row, on a mid-grey background (384x264)."""
    per_row = 16
    rows = (N_TABLE_ICONS + per_row - 1) // per_row
    sheet = Image.new("RGB", (per_row * ICON_WIDTH, rows * ICON_HEIGHT), (128, 128, 128))
    for i in range(N_TABLE_ICONS):
        sheet.paste(render(i), ((i % per_row) * ICON_WIDTH, (i // per_row) * ICON_HEIGHT))
    return sheet


def main():
    args = sys.argv[1:]
    if len(args) == 2 and args[0] == "--sheet":
        out = Path(args[1])
        out.parent.mkdir(parents=True, exist_ok=True)
        sprite_sheet().save(out)
        print(f"extract_icons: wrote {out}")
        return
    if len(args) != 1:
        sys.exit(__doc__)
    out_dir = Path(args[0]).resolve()
    if REPO / "table_data" in out_dir.parents or out_dir == REPO / "table_data":
        sys.exit("extract_icons: renders are not source; write them outside table_data/")
    out_dir.mkdir(parents=True, exist_ok=True)
    for i in range(N_ICONS):
        render(i).save(out_dir / f"Icon_{i:03d}.png")
    sprite_sheet().save(out_dir / "IconSpriteSheet.png")
    print(f"extract_icons: {N_ICONS} icons and IconSpriteSheet.png written to {out_dir}")


if __name__ == "__main__":
    main()
