#!/usr/bin/env python3
"""fat12_extract.py -- copy every file of a FAT12 image into a directory, under its unit name.

QUESTION IT ANSWERS: "what are the files on this diskette, as files?"  The build uses it to give
format describers a standalone copy of a file when the census should see the file's own kind
(for example `ROSE.bmp`, which the census counts as media).  The copies are build products
(floppy/build/, git-ignored), never sources.

    python3 floppy/tools/fat12_extract.py IMAGE OUTDIR [--stamp FILE]

Unit names are fat12lib.unit_name(): the 8.3 name with the extension lower-cased, and every
character outside [A-Za-z0-9_-] spelled xHH, so that make and the shell can name them.
"""
import argparse
import os
import pathlib
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import fat12lib  # noqa: E402


def extracted_name(e):
    """The copy's path under OUTDIR: the unit path with the extension lower-cased."""
    u = e.unit_path()
    if '.' in u:
        b, x = u.rsplit('.', 1)
        return b + '.' + x.lower()
    return u


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('image')
    ap.add_argument('outdir')
    ap.add_argument('--stamp')
    a = ap.parse_args()
    img = fat12lib.Image(pathlib.Path(a.image).read_bytes())
    out = pathlib.Path(a.outdir)
    out.mkdir(parents=True, exist_ok=True)
    n = 0
    for e in img.files():
        if e.is_dir:
            continue
        dst = out / extracted_name(e)
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_bytes(img.file_bytes(e))
        n += 1
    if a.stamp:
        pathlib.Path(a.stamp).write_text('%d files\n' % n)


if __name__ == '__main__':
    main()
