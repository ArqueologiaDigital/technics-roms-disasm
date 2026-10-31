#!/usr/bin/env python3
"""kn5000_image_outputs.py -- the .bin files the KN5000 picture converters write beside their PNGs.

QUESTION ANSWERED: which files does the build derive from images/*.png with indexed_images.py,
mono_images.py and se_bitmaps.py?  The Makefile names them as the real outputs of one grouped rule
(`KN5000_IMAGE_BINS`), so a changed or deleted PNG, or a deleted .bin, rebuilds them.  Since 2026-10-31
(lane media-build; the owner: "Images and wav files must be commited and the conversion must happen as
a build step") these .bin files are git-ignored build products and the PNGs are the only committed
copy of the pixels.  Every output's PNG has the same path with .png for .bin.

    python3 scripts/build/kn5000_image_outputs.py          # one path per line, relative to the repo
    python3 scripts/build/kn5000_image_outputs.py hdae     # hdae5000_images.py's outputs (includes/generated/)
    python3 scripts/build/kn5000_image_outputs.py tabledata  # ui_bitmaps / icon / font_images.py's outputs
"""
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent
REPO = HERE.parent.parent
sys.path.insert(0, str(HERE))
import indexed_images  # noqa: E402
import mono_images     # noqa: E402
import se_bitmaps      # noqa: E402


def hdae_outputs():
    """hdae5000_images.py build: hdae5000/includes/generated/ and each version tree's"""
    import hdae5000_images as H
    out = [str((H.GEN / f'{n}.bin').relative_to(REPO)) for n, _o, _l, _g in H.ASSETS]
    for tree, (_rom, assets, _pal) in H.VERSION_ASSETS.items():
        _art, gen = H.version_paths(tree)
        out += [str((gen / f'{n}.bin').relative_to(REPO)) for n, _a, _l, _g in assets]
    return out


def tabledata_outputs():
    """ui_bitmaps_images.py, icon_images.py, font_images.py build: table_data/includes/generated/"""
    import ui_bitmaps_images as U
    import icon_images as I
    import font_images as F
    out = [str((U.GEN / f"{e['label']}.bin").relative_to(REPO)) for e in U.manifest()]
    out += [str((I.GEN / f'IconPixels_{i:03d}.bin').relative_to(REPO)) for i in range(I.count())]
    out += [str((F.GEN / f'{label}.bin').relative_to(REPO)) for label, *_r in F.BANKS]
    out.append(str((F.GEN / 'Font5_Glyphs.bin').relative_to(REPO)))
    return out


def outputs():
    out = [raw for raw, _png, _w, _h, _s in indexed_images.MANIFEST]
    out += [str((d / f'{n}.bin').relative_to(REPO)) for d in mono_images.DIRS for n in mono_images.NAMES]
    out += [f'{t}/maincpu/images/{name}.bin' for t in se_bitmaps.TREES for name, _w, _h in se_bitmaps.ITEMS]
    assert len(out) == len(set(out)), 'two converters claim the same output'
    return out


if __name__ == '__main__':
    group = sys.argv[1] if len(sys.argv) > 1 else 'images'
    print('\n'.join({'images': outputs, 'hdae': hdae_outputs, 'tabledata': tabledata_outputs}[group]()))
