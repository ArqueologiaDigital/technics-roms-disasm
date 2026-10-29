#!/usr/bin/env python3
"""mark_census_generated.py -- append `; census: generated -- <generator>` to KN5000 .incbin lines
whose file a committed generator rebuilds from committed source.

QUESTION IT ANSWERS: which .incbin lines in the KN5000 trees name a build product (round-trip images,
LZSS/SLIDE8K payloads, style-event banks, the derived stale-help duplicate) rather than a raw blob,
so that scripts/analysis/data_incbin_census.py counts them as `generated` and not `generic`?

Each RULE pairs a regex on the .incbin path with the marker text: the generator and its source.  The
rules are only true because the Makefile rebuilds each file from that source before the object that
includes it (the tool's `verify` step asserts the round trip); a rule is added together with that
build rule, never instead of it.  Lines that already carry a `census:` marker are left alone, so the
script can be re-run.  Files are read and written as bytes (the .s files hold non-UTF-8 .ascii).

    python3 scripts/tools/mark_census_generated.py            # apply
    python3 scripts/tools/mark_census_generated.py --check    # exit 1 if a line would change
"""
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DIRS = ("v10/maincpu", "v9/maincpu", "v7/maincpu", "v6/maincpu", "v5/maincpu", "table_data", "custom_data")

RULES = [
    (rb'images/Bitmap_1bit_\w+\.bin$',
     b'scripts/build/mono_images.py, from the .png beside it'),
    (rb'(v10/maincpu/images/Bitmap\w+|images/Wallpaper_\d)\.bin$',
     b'scripts/build/indexed_images.py, from the .png beside it'),
    (rb'includes/demo_presets/demo_preset_(\d\d)_compressed\.bin$',
     b'midi_to_preset.py + compress_lzss.py --strict, from demo_presets/midi + sidecar (encoder decisions replayed from original_ROMs/demo_preset_NN_compressed.original.bin)'),
    (rb'includes/help_databases/help_db_\w+_compressed\.bin$',
     b'help_db_text.py + compress_slide8k.py --strict, from help_db_<lang>.txt (encoder decisions replayed from original_ROMs/help_db_<lang>_compressed.original.bin)'),
    (rb'includes/help_databases/stale_\w+\.bin$',
     b'scripts/generators/gen_stale_help_duplicate.py, from the live English+German SLIDE8K build products'),
    (rb'includes/section_\w+\.bin$',
     b'scripts/build/style_events.py, from custom_data/styles/*.styles'),
]
INC = re.compile(rb'^(?P<head>\s*(?:[A-Za-z_.$][\w.$]*:\s*)?\.incbin\s+"(?P<path>[^"]+)"[^;]*?)(?P<tail>\s*(?:;.*)?)$')


def tracked():
    out = subprocess.run(["git", "ls-files", "-z", "--", *DIRS], cwd=ROOT, capture_output=True, check=True).stdout
    return [p.decode() for p in out.split(b"\0") if p.endswith(b".s")]


def main():
    check = "--check" in sys.argv
    changed = 0
    for f in tracked():
        p = ROOT / f
        lines = p.read_bytes().split(b"\n")
        dirty = False
        for i, ln in enumerate(lines):
            m = INC.match(ln)
            if not m or b"census:" in ln:
                continue
            prev = next((l for l in reversed(lines[:i]) if l.strip()), b"")
            if b"census:" in prev and prev.lstrip().startswith(b";"):   # a marker comment line above
                continue
            for rx, text in RULES:
                if re.search(rx, m.group("path")):
                    tail = m.group("tail").strip()
                    mark = b"census: generated -- " + text
                    new = m.group("head").rstrip() + b"\t; " + (tail[1:].strip() + b"; " if tail else b"") + mark
                    lines[i] = new
                    dirty = True
                    changed += 1
                    break
        if dirty and not check:
            p.write_bytes(b"\n".join(lines))
    print(f"{'would mark' if check else 'marked'} {changed} .incbin lines")
    return 1 if (check and changed) else 0


if __name__ == "__main__":
    sys.exit(main())
