#!/usr/bin/env python3
"""kn5000_image_outputs.py -- the .bin files the KN5000 picture converters write beside their PNGs.

QUESTION ANSWERED: which files does the build derive from images/*.png with indexed_images.py,
mono_images.py and se_bitmaps.py?  The Makefile names them as the real outputs of one grouped rule
(`KN5000_IMAGE_BINS`), so a changed or deleted PNG, or a deleted .bin, rebuilds them.  Since 2026-10-31
(lane media-build; the owner: "Images and wav files must be commited and the conversion must happen as
a build step") these .bin files are git-ignored build products and the PNGs are the only committed
copy of the pixels.  Every output's PNG has the same path with .png for .bin.

    python3 scripts/build/kn5000_image_outputs.py          # one path per line, relative to the repo
"""
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent
REPO = HERE.parent.parent
sys.path.insert(0, str(HERE))
import indexed_images  # noqa: E402
import mono_images     # noqa: E402
import se_bitmaps      # noqa: E402


def outputs():
    out = [raw for raw, _png, _w, _h, _s in indexed_images.MANIFEST]
    out += [str((d / f'{n}.bin').relative_to(REPO)) for d in mono_images.DIRS for n in mono_images.NAMES]
    out += [f'{t}/maincpu/images/{name}.bin' for t in se_bitmaps.TREES for name, _w, _h in se_bitmaps.ITEMS]
    assert len(out) == len(set(out)), 'two converters claim the same output'
    return out


if __name__ == '__main__':
    print('\n'.join(outputs()))
