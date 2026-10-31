#!/usr/bin/env python3
"""fat12_media.py -- the standalone media files a disk's source `.incbin`s, copied into <model>/<disk>/media/.

QUESTION IT ANSWERS: "which files of this diskette does the source read as a picture or a MIDI file, and
are their committed copies the files on the disk?"  Set up 2026-10-31 (lane media-build) for the owner's
decision: "Images and wav files must be commited and the conversion must happen as a build step."  A
disk's BMP, JPEG and MIDI files (the census class `media`: the file IS its semantic representation) are
committed under <model>/<disk>/media/, which is on the disk's include path in front of build/<model>/<disk>/,
so the build reads the committed copy and never the reference image for them.

    python3 floppy/tools/fat12_media.py update MODEL DISK    # build/MODEL/DISK/<name> -> MODEL/DISK/media/<name>
    python3 floppy/tools/fat12_media.py check  MODEL DISK    # assert every media include has its committed file
    python3 floppy/tools/fat12_media.py list   MODEL DISK

Run from floppy/.  `update` is MAINTENANCE (`make -C floppy media-<model>`), not a build step: it needs the
reference image extracted (build/<model>/<disk>/extract.stamp) and any byte range cut out of a container
(KD_CUT, floppy/tools/kd/kd.mk).  It also deletes a file in media/ that no include names any more.
The names are the ones the `.incbin` lines use: the unit name with the extension lower-cased
(fat12_extract.py), plus a cut's own suffix (`DANCE___.mid.smf.mid`, `01BLLOON.hmp.bmp`).
"""
import argparse
import pathlib
import re
import shutil
import sys

MEDIA = {'jpg', 'jpeg', 'bmp', 'png', 'gif', 'tif', 'tiff', 'wav', 'aif', 'aiff', 'mid'}
INCBIN = re.compile(rb'^\s*(?:[A-Za-z_.][\w.]*:)?\s*\.incbin\s+"([^"]+)"', re.M)


def names(model, disk):
    """every media file name the disk's sources `.incbin`, sorted"""
    out = set()
    for s in sorted(pathlib.Path(model, disk).rglob('*.s')):
        for m in INCBIN.finditer(s.read_bytes()):
            n = m.group(1).decode('latin-1')
            if '/' not in n and n.rsplit('.', 1)[-1].lower() in MEDIA:
                out.add(n)
    return sorted(out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('cmd', choices=['update', 'check', 'list'])
    ap.add_argument('model')
    ap.add_argument('disk')
    a = ap.parse_args()
    want = names(a.model, a.disk)
    media = pathlib.Path(a.model, a.disk, 'media')
    if a.cmd == 'list':
        print('\n'.join(want))
        return 0
    if a.cmd == 'check':
        missing = [n for n in want if not (media / n).is_file()]
        for n in missing:
            print(f'MISSING  {media / n}')
        print(f'fat12_media.py check {a.model}/{a.disk}: {len(want) - len(missing)} of {len(want)} media files committed')
        return 1 if missing else 0
    build = pathlib.Path('build', a.model, a.disk)
    copied = removed = 0
    for n in want:
        src = build / n
        if not src.is_file():
            sys.exit(f'fat12_media.py: {src} is not there -- extract the reference first '
                     f'(make -C floppy media-{a.model} does)')
        media.mkdir(exist_ok=True)
        dst = media / n
        if not dst.exists() or dst.read_bytes() != src.read_bytes():
            shutil.copyfile(src, dst)
            copied += 1
    if media.is_dir():
        for f in sorted(media.iterdir()):
            if f.is_file() and f.name not in want:
                assert f.resolve().parent == media.resolve()
                f.unlink()
                removed += 1
    print(f'fat12_media.py update {a.model}/{a.disk}: {len(want)} media files, {copied} written, {removed} removed')
    return 0


if __name__ == '__main__':
    sys.exit(main())
