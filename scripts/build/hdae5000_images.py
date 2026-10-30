#!/usr/bin/env python3
"""hdae5000_images.py -- HD-AE5000 graphics <-> human-readable form, ROUND TRIP.

QUESTION ANSWERED: can the HD-AE5000's 313,076 bytes of graphics live in the repo as images
and palettes a human can look at, and still rebuild the ROM byte for byte?

Yes. That is the whole point: an extractor that only goes one way leaves the blob as the build
input, so the readable form is a view rather than a source. This goes both ways, and `export`
followed by `build` is required to be a no-op at the byte level (`verify` checks it).

WHAT IS IN THERE (offsets into hdae5000/includes/code_29af2d_2fffff.bin):

    off 54881    1024 B   palette, 256 x RGBX          -> HDAE5000_Palette_Logo.txt
    off 55905   76800 B   320x240 8bpp  Logo           -> HDAE5000_Logo.png
    off 132705   1024 B   palette                      -> HDAE5000_Palette_Hands.txt
    off 133729  76800 B   320x240 8bpp  Hands          -> HDAE5000_Hands.png
    off 210529   1024 B   palette                      -> HDAE5000_Palette_FilePanel.txt
    off 211553  76800 B   320x240 8bpp  FilePanel      -> HDAE5000_FilePanel.png
    off 288353   1024 B   palette                      -> HDAE5000_Palette_Icon.txt
    off 289377     756 B  27x27 8bpp, 28-byte stride   -> HDAE5000_Icon.png
    off 306849   1024 B   palette                      -> HDAE5000_Palette_Splash.txt
    off 307873  76800 B   320x240 8bpp  SplashScreen   -> HDAE5000_SplashScreen.png

THE PNGS STORE PALETTE INDICES, NOT COLOURS. They are written in PIL mode 'P', so a pixel's
byte value IS the ROM's byte value. Storing RGB instead would not round-trip: these palettes
contain duplicate colours, so RGB -> index is ambiguous.

THE ICON'S STRIDE IS LOAD-BEARING. It is 27 pixels wide in a 28-byte row. The 28th byte of
each row is padding and is preserved separately in the sidecar, because it is not always 0
and the ROM must come back exactly.

    python3 scripts/build/hdae5000_images.py export    # blob -> png + txt (run once)
    python3 scripts/build/hdae5000_images.py build     # png + txt -> raw bins (build step)
    python3 scripts/build/hdae5000_images.py verify    # assert the round trip is byte-exact

OTHER ROM VERSIONS. A version tree (hdae5000_v2_01i/) shares every picture that is the same
in its ROM -- its sources .incbin the bins above, found through `-I hdae5000` -- and keeps
only the ones that differ, in VERSION_ASSETS: art under <tree>/images/, bins under
<tree>/includes/generated/.  `build` builds those too (from the committed PNG / palette
text, no ROM needed); `verify` checks them against the version's ROM when its reference
copy original_ROMs/<rom> is present (make copies it there), and says so when it is not.

    python3 scripts/build/hdae5000_images.py export-version hdae5000_v2_01i   # ROM -> png + txt
"""
import json
import pathlib
import sys

from PIL import Image

REPO = pathlib.Path(__file__).resolve().parent.parent.parent
BLOB = REPO / 'hdae5000' / 'includes' / 'code_29af2d_2fffff.bin'
ART = REPO / 'hdae5000' / 'images'
GEN = REPO / 'hdae5000' / 'includes' / 'generated'

# name, offset, length, (width, height, stride) or None for a palette
ASSETS = [
    ('HDAE5000_Palette_Logo',      54881,  1024, None),
    ('HDAE5000_Logo',              55905, 76800, (320, 240, 320)),
    ('HDAE5000_Palette_Hands',    132705,  1024, None),
    ('HDAE5000_Hands',            133729, 76800, (320, 240, 320)),
    ('HDAE5000_Palette_FilePanel', 210529, 1024, None),
    ('HDAE5000_FilePanel',        211553, 76800, (320, 240, 320)),
    ('HDAE5000_Palette_Icon',     288353,  1024, None),
    ('HDAE5000_Icon',             289377,   756, (27, 27, 28)),
    ('HDAE5000_Palette_Splash',   306849,  1024, None),
    ('HDAE5000_SplashScreen',     307873, 76800, (320, 240, 320)),
]
PAL_FOR = {
    'HDAE5000_Logo': 'HDAE5000_Palette_Logo',
    'HDAE5000_Hands': 'HDAE5000_Palette_Hands',
    'HDAE5000_FilePanel': 'HDAE5000_Palette_FilePanel',
    'HDAE5000_Icon': 'HDAE5000_Palette_Icon',
    'HDAE5000_SplashScreen': 'HDAE5000_Palette_Splash',
}


# tree -> (ROM file in original_ROMs/, [(name, ROM address, length, geom)], {image: palette})
# v2.01i: only the file-selection backdrop differs (magenta marble background, five buttons in
# the bottom bar where v2.06i has three); the address is where v2.01i's copy code reads it
# (HDAE5000_Alloc_Memory_3, A1), its palette the 1,024 bytes in front of it.
VERSION_ASSETS = {
    'hdae5000_v2_01i': ('hd-ae5000_v2_01i.ic4', [
        ('HDAE5000_Palette_FilePanel_v2_01i', 0x2CDD9C, 1024, None),
        ('HDAE5000_FilePanel_v2_01i',         0x2CE19C, 76800, (320, 240, 320)),
    ], {'HDAE5000_FilePanel_v2_01i': 'HDAE5000_Palette_FilePanel_v2_01i'}),
    # v1.15i: no file-selection backdrop at all; its boot splash is its own (no "Version 2"
    # line, and "Startup !" for v2.x's "Start-up !"), palette and picture where
    # HDAE5000_Boot_Init reads them.  v1.10i has the same bytes
    # (0x2CD76E) and takes them from this tree through its build's -I hdae5000_v1_15i.
    'hdae5000_v1_15i': ('hd-ae5000_v1_15i.ic4', [
        ('HDAE5000_Palette_Splash_v1_15i', 0x2CD8FE, 1024, None),
        ('HDAE5000_SplashScreen_v1_15i',   0x2CDCFE, 76800, (320, 240, 320)),
    ], {'HDAE5000_SplashScreen_v1_15i': 'HDAE5000_Palette_Splash_v1_15i'}),
}


def read_palette_txt(path):
    vals = []
    for line in path.read_text().splitlines():
        line = line.split('#', 1)[0].strip()
        if line:
            vals.append(bytes(int(x, 0) for x in line.split()))
    return b''.join(vals)


def write_palette_txt(path, data, name):
    out = [f"# {name} -- 256 entries, 4 bytes each, as stored in the ROM.",
           "# Columns are the raw bytes; on this board the first three are R, G, B and the",
           "# fourth is unused padding. Values are decimal. Editing a line changes the ROM.",
           "#  R    G    B    X"]
    for i in range(0, len(data), 4):
        r, g, b, x = data[i:i + 4]
        out.append(f"{r:4d} {g:4d} {b:4d} {x:4d}   # index {i // 4}")
    path.write_text('\n'.join(out) + '\n')


def export():
    blob = BLOB.read_bytes()
    ART.mkdir(parents=True, exist_ok=True)
    pads = {}
    for name, off, ln, geom in ASSETS:
        data = blob[off:off + ln]
        assert len(data) == ln, name
        if geom is None:
            write_palette_txt(ART / f'{name}.txt', data, name)
            continue
        w, h, stride = geom
        pal = blob[dict((n, o) for n, o, _, _ in ASSETS)[PAL_FOR[name]]:][:1024]
        img = Image.new('P', (w, h))
        flat = bytearray()
        pad = []
        for y in range(h):
            row = data[y * stride:(y + 1) * stride]
            flat += row[:w]
            if stride > w:
                pad.append(list(row[w:]))
        img.frombytes(bytes(flat))
        img.putpalette(b''.join(pal[i:i + 3] for i in range(0, 1024, 4)))
        img.save(ART / f'{name}.png')
        if pad:
            pads[name] = pad
    (ART / 'row_padding.json').write_text(json.dumps(pads, separators=(',', ':')))
    print(f"exported {len(ASSETS)} assets to {ART.relative_to(REPO)}")


def rebuild_one(name, geom):
    if geom is None:
        return read_palette_txt(ART / f'{name}.txt')
    w, h, stride = geom
    img = Image.open(ART / f'{name}.png')
    assert img.mode == 'P', f"{name}: PNG must be palette-indexed, got {img.mode}"
    assert img.size == (w, h), f"{name}: expected {(w, h)}, got {img.size}"
    px = img.tobytes()
    pads = json.loads((ART / 'row_padding.json').read_text()).get(name)
    out = bytearray()
    for y in range(h):
        out += px[y * w:(y + 1) * w]
        if stride > w:
            out += bytes(pads[y])
    return bytes(out)


def build():
    GEN.mkdir(parents=True, exist_ok=True)
    tot = 0
    for name, off, ln, geom in ASSETS:
        data = rebuild_one(name, geom)
        assert len(data) == ln, f"{name}: rebuilt {len(data)} B, expected {ln}"
        (GEN / f'{name}.bin').write_bytes(data)
        tot += len(data)
    print(f"hdae5000_images: rebuilt {len(ASSETS)} assets, {tot:,} B from images and palettes")


def verify():
    blob = BLOB.read_bytes()
    bad = 0
    for name, off, ln, geom in ASSETS:
        want = blob[off:off + ln]
        got = rebuild_one(name, geom)
        if got != want:
            bad += 1
            n = sum(1 for a, b in zip(got, want) if a != b) if len(got) == len(want) else -1
            print(f"  *** {name}: MISMATCH ({n} bytes)" if n >= 0 else f"  *** {name}: LENGTH {len(got)} vs {ln}")
        else:
            print(f"  ok  {name:<28} {ln:>7,} B")
    if bad:
        sys.exit(f"{bad} asset(s) do not round-trip")
    print("ROUND TRIP EXACT: images and palettes rebuild the ROM bytes")


def version_paths(tree):
    return REPO / tree / 'images', REPO / tree / 'includes' / 'generated'


def rebuild_version_one(art, name, geom):
    if geom is None:
        return read_palette_txt(art / f'{name}.txt')
    w, h, stride = geom
    assert stride == w, f"{name}: a padded stride needs a row_padding sidecar"
    img = Image.open(art / f'{name}.png')
    assert img.mode == 'P' and img.size == (w, h), f"{name}: expected a {w}x{h} palette PNG"
    return img.tobytes()


def export_version(tree):
    rom_name, assets, pal_for = VERSION_ASSETS[tree]
    rom = (REPO / 'original_ROMs' / rom_name).read_bytes()
    art, _ = version_paths(tree)
    art.mkdir(parents=True, exist_ok=True)
    at = {n: a for n, a, _, _ in assets}
    for name, addr, ln, geom in assets:
        data = rom[addr - 0x280000:addr - 0x280000 + ln]
        if geom is None:
            write_palette_txt(art / f'{name}.txt', data, name)
            continue
        w, h, _ = geom
        pal = rom[at[pal_for[name]] - 0x280000:][:1024]
        img = Image.new('P', (w, h))
        img.frombytes(bytes(data))
        img.putpalette(b''.join(pal[i:i + 3] for i in range(0, 1024, 4)))
        img.save(art / f'{name}.png')
    print(f"exported {len(assets)} assets to {art.relative_to(REPO)}")


def build_versions():
    for tree, (rom_name, assets, _) in VERSION_ASSETS.items():
        art, gen = version_paths(tree)
        gen.mkdir(parents=True, exist_ok=True)
        for name, addr, ln, geom in assets:
            data = rebuild_version_one(art, name, geom)
            assert len(data) == ln, f"{name}: rebuilt {len(data)} B, expected {ln}"
            (gen / f'{name}.bin').write_bytes(data)
        print(f"hdae5000_images: {tree}: rebuilt {len(assets)} assets")


def verify_versions():
    bad = 0
    for tree, (rom_name, assets, _) in VERSION_ASSETS.items():
        p = REPO / 'original_ROMs' / rom_name
        if not p.exists():
            print(f"  --  {tree}: original_ROMs/{rom_name} absent (make copies it), not checked")
            continue
        rom = p.read_bytes()
        art, _ = version_paths(tree)
        for name, addr, ln, geom in assets:
            ok = rebuild_version_one(art, name, geom) == rom[addr - 0x280000:addr - 0x280000 + ln]
            bad += not ok
            print(f"  {'ok ' if ok else '***'} {name:<34} {ln:>7,} B  ({tree})")
    if bad:
        sys.exit(f"{bad} version asset(s) do not round-trip")


if __name__ == '__main__':
    cmd = sys.argv[1] if len(sys.argv) > 1 else 'verify'
    if cmd == 'export-version':
        export_version(sys.argv[2])
    elif cmd == 'build':
        build()
        build_versions()
    elif cmd == 'verify':
        verify()
        verify_versions()
    elif cmd == 'export':
        export()
    else:
        sys.exit(__doc__)
