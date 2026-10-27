#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# mktoc.py CARD_DIR -- the program menu's table of contents, CARD_DIR/KN7MENU.TOC (README.md, "The table of
# contents"), from the card tree as it will be copied to the card: every folder of the root with a KN7APP.BIN, its
# MANIFEST.TXT's NAME=, ICON= (decoded here, as the menu's DecodeBmp decodes it) and FOLDER= (the menu folder it is
# listed in: "Games", or a path, "HW Probes/Pinball"; none: the top of the menu), and KN7APP.BIN's size. The menu
# then reads that one file and the root directory as it starts, instead of every folder's directory, manifest and
# icon; it finds KN7APP.BIN itself when the program is run. Run it last, on the whole tree (stage.sh, `make card`):
# a folder added to the card by hand afterwards is not in it, and the menu looks into that folder as before.
# Little-endian (menu.inc TH_*, TF_*, TP_*):
#   header, 32 bytes: "KTOC", u32 1, u32 the file's bytes, u32 CRC-32 of the file from byte 16, u32 the menu's
#     folders, u32 the programs, u32 the icons, u32 0;
#   each menu folder, 80 bytes: its name (64, NUL-padded), u32 its parent (0 the top, else 1 + its index), u32 its
#     icon (an index, or -1), 8 bytes 0;
#   each program, 96 bytes: the root folder's name (16, as the menu keeps it: "AW"), the name shown (64), u32 its
#     menu folder (as a folder's parent), u32 KN7APP.BIN's bytes, u32 its icon (or -1), 4 bytes 0;
#   each icon, 32 x 32 RGB565, the top row first: 2048 bytes.
import os
import struct
import sys
import zlib

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import gen_icons  # noqa: E402

MAX_PROG, MAX_FOLD, W = 64, 16, 32
FOLDER_ICON = {'games': 'folder-games', 'hw probes': 'folder-probes', 'other apps': 'folder-apps'}


def manifest(path):
    """{KEY: value} of a MANIFEST.TXT, as the menu's ParseManifest takes it: KEY=value lines, '#' comments"""
    keys = {}
    if os.path.isfile(path):
        for line in open(path, 'rb').read()[:2047].decode('ascii', 'replace').splitlines():
            line = line.strip()
            if line and not line.startswith('#') and '=' in line:
                k, v = line.split('=', 1)
                keys.setdefault(k.strip().upper(), v.strip())
    return keys


def bmp565(data):
    """a 32 x 32, 24 or 32-bit BI_RGB BMP -> 2048 bytes RGB565, top row first (menu_card.s DecodeBmp), or None"""
    if len(data) < 54 or data[:2] != b'BM':
        return None
    off, = struct.unpack_from('<I', data, 10)
    hsize, w, h, planes, bpp, comp = struct.unpack_from('<IiiHHI', data, 14)
    if hsize < 40 or w != W or h not in (W, -W) or planes != 1 or bpp not in (24, 32) or comp != 0:
        return None
    step = bpp // 8
    if off + W * W * step > len(data):
        return None
    out = bytearray()
    for y in range(W):
        row = off + ((W - 1 - y) if h > 0 else y) * W * step
        for x in range(W):
            b, g, r = data[row + x * step:row + x * step + 3]
            out += struct.pack('<H', ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3))
    return bytes(out)


def drawn(name):
    return b''.join(struct.pack('<H', gen_icons.rgb565(p)) for row in gen_icons.icon(name).px for p in row)


def main():
    card = sys.argv[1]
    folders, icons, progs = [], [], []        # folders: (path, name, parent)
    index = {}

    def folder(path):
        """1 + the index of the menu folder at path ("A/B"), made with its parents as needed; 0 for none"""
        if not path:
            return 0
        if path.lower() not in index:
            head, _, name = path.rpartition('/')
            parent = folder(head)
            if len(folders) == MAX_FOLD:
                sys.exit(f'mktoc: more than {MAX_FOLD} menu folders')
            kind = FOLDER_ICON.get(name.lower()) or FOLDER_ICON.get(path.split('/')[0].lower(), 'folder')
            icons.append(drawn(kind))
            folders.append((name, parent, len(icons) - 1))
            index[path.lower()] = len(folders)
        return index[path.lower()]

    for d in sorted(os.listdir(card)):
        app = os.path.join(card, d, 'KN7APP.BIN')
        if not os.path.isfile(app):
            continue
        if len(d) > 12 or len(progs) == MAX_PROG:
            sys.exit(f'mktoc: {d}: not an 8.3 folder name, or more than {MAX_PROG} programs')
        m = manifest(os.path.join(card, d, 'MANIFEST.TXT'))
        icon = -1
        if m.get('ICON'):
            f = os.path.join(card, d, m['ICON'])
            px = bmp565(open(f, 'rb').read()) if os.path.isfile(f) else None
            if px is None:
                print(f'mktoc: {d}: its icon {m["ICON"]} is missing or not a 32x32 24/32-bit BMP: the default one')
            else:
                icons.append(px)
                icon = len(icons) - 1
        where = '/'.join(p.strip() for p in m.get('FOLDER', '').split('/') if p.strip())
        progs.append((d.upper(), m.get('NAME') or d, folder(where), os.path.getsize(app), icon))
    if len(icons) > MAX_PROG:
        sys.exit(f'mktoc: {len(icons)} icons; the menu keeps {MAX_PROG}')
    body = struct.pack('<IIII', len(folders), len(progs), len(icons), 0)
    for name, parent, icon in folders:
        body += name.encode('ascii', 'replace')[:63].ljust(64, b'\0') + struct.pack('<Ii8x', parent, icon)
    for d, name, where, size, icon in progs:
        body += (d.encode('ascii')[:15].ljust(16, b'\0') + name.encode('ascii', 'replace')[:63].ljust(64, b'\0')
                 + struct.pack('<IIi4x', where, size, icon))
    body += b''.join(icons)
    size = 16 + len(body)
    toc = b'KTOC' + struct.pack('<II', 1, size) + struct.pack('<I', zlib.crc32(body)) + body
    with open(os.path.join(card, 'KN7MENU.TOC'), 'wb') as f:
        f.write(toc)
    top = sum(1 for p in progs if p[2] == 0)
    print(f'mktoc: {card}/KN7MENU.TOC, {size:,} bytes: {len(progs)} programs ({top} at the top), '
          f'{len(folders)} menu folders ({", ".join(f[0] for f in folders)}), {len(icons)} icons')


if __name__ == '__main__':
    main()
