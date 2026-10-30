#!/usr/bin/env python3
"""mark_tabledata_media_sources.py -- name the PNG or MIDI file behind each table_data include.

QUESTION ANSWERED: none; a one-shot, idempotent source edit (lane media-files, 2026-10-30).

table_data's icons, fonts and UI bitmaps are built from PNGs (scripts/build/icon_images.py,
font_images.py, ui_bitmaps_images.py) into includes/generated/, a path data_incbin_census.py reads as
"compiled C"; the demo-song presets are built from MIDI files whose names their marker did not give.
This appends `census: generated -- <tool>, from <file>` to every such `.incbin` line, so the census
counts them as made from a standalone media file (its "from media" column).  The bytes do not change.

The HD-AE5000 trees' pictures are the same case (scripts/build/hdae5000_images.py writes them into
includes/generated/); their `.incbin` lines get the marker too, from the "Built from <file> by <tool>."
comment above each.

    python3 scripts/converters/mark_tabledata_media_sources.py
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
FILES = ["table_data/kn5000_table_data.s", "table_data/fonts.s", "table_data/ui_bitmaps.s"]
TOOLS = {"icons_png": "scripts/build/icon_images.py", "fonts": "scripts/build/font_images.py",
         "ui_bitmaps": "scripts/build/ui_bitmaps_images.py"}
GEN = re.compile(rb'^(\w+:\s*\.incbin\s+"includes/generated/(\w+)\.bin"[^;]*?)(\s*;\s*(.*))?$')
DEMO = re.compile(rb'(\.incbin\s+"includes/demo_presets/demo_preset_(\d\d)_compressed\.bin".*census: generated -- '
                  rb'midi_to_preset\.py \+ compress_lzss\.py --strict, from )demo_presets/midi( \+ sidecar)')


def main():
    pngs = {}
    for sub in TOOLS:
        for p in (ROOT / "table_data/images" / sub).glob("*.png"):
            pngs[p.stem] = sub
    n = 0
    for f in FILES:
        path = ROOT / f
        out = []
        for line in path.read_bytes().split(b"\n"):
            m = GEN.match(line)
            if m and b"census:" not in line and m.group(2).decode() in pngs:
                stem = m.group(2).decode()
                sub = pngs[stem]
                mark = f"census: generated -- {TOOLS[sub]}, from table_data/images/{sub}/{stem}.png".encode()
                old = m.group(4)
                line = m.group(1).rstrip() + b"\t; " + (old.rstrip() + b"; " if old else b"") + mark
                n += 1
            else:
                line, k = DEMO.subn(lambda d: d.group(1) + b"demo_presets/midi/demo_preset_" + d.group(2) + b".mid"
                                    + d.group(3), line)
                n += k
            out.append(line)
        path.write_bytes(b"\n".join(out))
    built = re.compile(rb'Built from\s+(?:;\s*)?(\S+)\s+by\s+(?:;\s*)?(\S+?\.py)')
    inc = re.compile(rb'^(\s*\.incbin\s+"includes/generated/\w+\.bin")\s*$')
    for tree in ("hdae5000", "hdae5000_v2_01i"):
        path = ROOT / tree / "hdae5000_data_tables.s"
        lines = path.read_bytes().split(b"\n")
        for i, line in enumerate(lines):
            m = inc.match(line)
            if not m:
                continue
            for k in range(i - 1, max(i - 8, -1), -1):
                # the comment may wrap: join it with the lines below it, up to the .incbin
                b = built.search(b" ".join(lines[k:i]))
                if b:
                    # v2.01i takes the files it does not hold from hdae5000/ (its second -I)
                    rel = b.group(1).decode()
                    rel = rel.split("/", 1)[1] if rel.startswith(tree + "/") else rel
                    src = next((t + "/" + rel for t in (tree, "hdae5000") if (ROOT / t / rel).exists()), None)
                    if src is None:
                        raise SystemExit(f"{path}: {rel} is in neither tree")
                    lines[i] = m.group(1) + b"\t; census: generated -- " + b.group(2) + b", from " + src.encode()
                    n += 1
                    break
        path.write_bytes(b"\n".join(lines))
    print(f"marked {n} includes")


if __name__ == "__main__":
    main()
