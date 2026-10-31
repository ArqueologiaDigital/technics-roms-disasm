#!/usr/bin/env python3
"""compare_icon_renders.py -- do the deleted table_data/images/icons/ renders carry anything the
committed icon source does not?

The 191 PNGs under table_data/images/icons/ (deleted 2026-10-31) were one-way RGB renders written
from the ROM by the old scripts/analysis/extract_icons.py.  This reads each one back from git at
COMMIT (default 43242446d, the last commit that had them) and compares it, pixel by pixel, with what
the new extract_icons.py paints from table_data/images/icons_png/.  PASS means every Icon_NNN.png
and IconSpriteSheet.png is reproduced exactly; the 14 test_*.png format-exploration renders are
listed, not compared (they are deliberately wrong decodings).

    python3 notes/media-cleanup-2026-10-31/probes/compare_icon_renders.py [COMMIT]
"""
import io
import subprocess
import sys
from pathlib import Path

from PIL import Image

REPO = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(REPO / "scripts" / "analysis"))
import extract_icons  # noqa: E402

commit = sys.argv[1] if len(sys.argv) > 1 else "43242446d"
names = subprocess.run(["git", "-C", str(REPO), "ls-tree", "--name-only", commit, "table_data/images/icons/"],
                       capture_output=True, text=True, check=True).stdout.split()
same = bad = other = 0
for path in names:
    name = Path(path).name
    old = Image.open(io.BytesIO(subprocess.run(["git", "-C", str(REPO), "show", f"{commit}:{path}"],
                                               capture_output=True, check=True).stdout)).convert("RGB")
    if name == "IconSpriteSheet.png":
        new = extract_icons.sprite_sheet()
    elif name.startswith("Icon_"):
        new = extract_icons.render(int(name[5:8]))
    else:
        other += 1
        print(f"  --  {name}: format-exploration render, not compared")
        continue
    if old.size == new.size and old.tobytes() == new.tobytes():
        same += 1
    else:
        bad += 1
        print(f"  *** {name}: DIFFERS")
print(f"{len(names)} files at {commit}: {same} reproduced exactly, {bad} differ, {other} not compared")
sys.exit(1 if bad or not same else 0)
