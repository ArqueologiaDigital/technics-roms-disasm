#!/usr/bin/env python3
"""retired_blobs.py -- the old verbatim ROM blobs, read from the tracked reference images instead.

QUESTION ANSWERED: where are the bytes that `table_data/includes/{icon_pixel_data,icons_to_strings,
wallpaper1_to_icons}.bin` and `hdae5000/includes/code_*.bin` used to hold, now that those files are
gone?

Each of them was a byte-for-byte slice of a reference image that git already tracks
(`original_ROMs/kn5000_table_data.rom`, `original_ROMs/hd-ae5000_v2_06i.ic4`); no assembly source
`.incbin`s any of them (lane media-cleanup, 2026-10-31, `notes/media-cleanup-2026-10-31/`).  Only the
maintenance commands of the picture converters (`export`, `verify`), a few one-shot analysis tools and
the archived ASL mirror read them.  Those now call `read(name)`, which returns the same bytes from the
reference image, and SHA-256-checks them against the value the deleted file had, so a wrong range can
never pass silently.

The bytes a build ASSEMBLES never come from here: the pictures are built from their PNGs.

    python3 scripts/build/retired_blobs.py            # check every range against its recorded SHA-256
    python3 scripts/build/retired_blobs.py write NAME OUT   # write one range to OUT (the ASL mirror's input)
"""
import hashlib
import pathlib
import sys

REPO = pathlib.Path(__file__).resolve().parent.parent.parent
TABLE = 'original_ROMs/kn5000_table_data.rom'      # CPU 0x800000
HDAE = 'original_ROMs/hd-ae5000_v2_06i.ic4'        # CPU 0x280000

# name -> (reference image, CPU address of the first byte, CPU base of the image, length, SHA-256 of
# the deleted file).  The SHA-256 values were measured on the files as tracked at main 43242446d.
BLOBS = {
    'icon_pixel_data':     (TABLE, 0x938588, 0x800000,  51184,
                           'c9be07f9bfa97b4a5242f037cc9a72dc25b9f62fdfd0dc1c2f525009cf053f94'),
    'icons_to_strings':    (TABLE, 0x944D78, 0x800000, 742024,
                           '0df126455434ccc35a9f40609ec26dc68edc2a170910de602a6fbe814f31379d'),
    'wallpaper1_to_icons': (TABLE, 0x912C00, 0x800000, 152576,
                           '0f28633246d6959bb392cdf5e0fe6166d3dc5af8ecc4bc8a8b2a336bac8652ba'),
    'code_2803c2_28f542':  (HDAE, 0x2803C2, 0x280000,  61825,
                           '0cd8fb01690ca18e8c2c0f8e7e29f8c9785b0aee6dcd2d20cf8c41aa441daba6'),
    'code_28f90c_2953e1':  (HDAE, 0x28F90C, 0x280000,  23254,
                           'f52f0a0a56e5844f37a345388b0a43c70f5711bc52398f8e3be1f6fcce8e43ca'),
    'code_295642_2971a2':  (HDAE, 0x295642, 0x280000,   7009,
                           '6995499c790f5b04c4024e96eb9071f8cfdda71a3ef9ca26fd1a1e8eacbbca3d'),
    'code_2971b7_29ae9e':  (HDAE, 0x2971B7, 0x280000,  15592,
                           'a5ba9258d84149c04c7fd716daa61507fc64c057ddf2186d2b57023456700e37'),
    'code_29af2d_2fffff':  (HDAE, 0x29AF2D, 0x280000, 413907,
                           'cced198352c22295fd84bdccadc6c59814b35db7037277929c8cb58b3de2e868'),
}


def read(name):
    ref, addr, base, length, sha = BLOBS[name]
    data = (REPO / ref).read_bytes()[addr - base:addr - base + length]
    if len(data) != length:
        sys.exit(f"retired_blobs: {ref} is too short for {name}")
    if hashlib.sha256(data).hexdigest() != sha:
        sys.exit(f"retired_blobs: {name} from {ref} does not have the recorded SHA-256 {sha}")
    return data


def check():
    for name in BLOBS:
        d = read(name)
        ref, addr, _, length, _ = BLOBS[name]
        print(f"  ok  {name:<20} {length:>7,} B  {ref} @ 0x{addr:06X}  sha256 {hashlib.sha256(d).hexdigest()}")


if __name__ == '__main__':
    if len(sys.argv) == 4 and sys.argv[1] == 'write':
        pathlib.Path(sys.argv[3]).write_bytes(read(sys.argv[2]))
    elif len(sys.argv) == 1:
        check()
    else:
        sys.exit(__doc__)
