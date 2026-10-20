#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# fatscan.py -- what the program menu will list, worked out on the computer with the menu's own rules
# (menu_card.s), independently of its code: from a card folder tree, before it is copied, or from an SD
# card image (the MAME tests compare the menu's RAM and screen with this).
#   python3 -I fatscan.py DIR                 the programs a card with DIR's contents in its root will show
#   python3 -I fatscan.py --image SD.img      the same, from an image (the 8.3 names as that FAT holds them)
#   python3 -I fatscan.py --image SD.img --lua OUT.lua    and the expected list for test/menu_test.lua
# For each folder of the root: is it a program (a KN7APP.BIN in it), the name shown (MANIFEST.TXT NAME=, else
# the folder's long name, else its 8.3 name), the icon (MANIFEST.TXT ICON=, a 32x32 24/32-bit BMP, else the
# default), and whether RUN would start it (the loader's header checks and the CRC-32) or what it would say.
import os
import struct
import sys
import zlib

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from png2icon import check_bmp  # noqa: E402

MAX_PROG, MAN_MAX, LFN_MAX, BMP_MAX, STAGE_MAX = 64, 2047, 63, 0x3000, 0x502E7F00 - 0x502BA000
APP_BASE, ABI = 0x502BA000, 1
VALID83 = set("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!#$%&'()-@^_`{}~")


def ascii_name(s, n):
    return ''.join(c if 0x20 <= ord(c) < 0x7F else '?' for c in s)[:n]


def parse_manifest(data):
    """-> (NAME or None, ICON as 11 bytes or None, ICON= text or None)"""
    data = data[:MAN_MAX]
    if b'\0' in data:
        data = data[:data.index(b'\0')]
    if data[:3] == b'\xef\xbb\xbf':
        data = data[3:]
    name = icon11 = icontext = None
    for raw in data.replace(b'\r', b'\n').split(b'\n'):
        line = raw.lstrip(b' \t')
        if not line or line[:1] == b'#':
            continue
        for key in (b'NAME', b'ICON'):
            if line[:4].upper() == key:
                rest = line[4:].lstrip(b' \t')
                if rest[:1] != b'=':
                    continue
                val = rest[1:].lstrip(b' \t')
                maxc = LFN_MAX if key == b'NAME' else 15
                v = ''.join(' ' if b == 9 else (chr(b) if 0x20 <= b < 0x7F else '?') for b in val[:maxc])
                v = v.rstrip(' ')
                if key == b'NAME' and v:
                    name = v
                elif key == b'ICON' and make11(v):     # an invalid ICON= keeps an earlier valid one
                    icontext = v
                    icon11 = make11(v)
    return name, icon11, icontext


def make11(s):
    base, ext, part = '', '', 0
    for ch in s:
        if ch == '.':
            if part or not base:
                return None
            part = 1
            continue
        ch = ch.upper()
        if ch not in VALID83:
            return None
        if part == 0:
            if len(base) == 8:
                return None
            base += ch
        else:
            if len(ext) == 3:
                return None
            ext += ch
    if not base:
        return None
    return (base.ljust(8) + ext.ljust(3)).encode('ascii')


def decode_bmp(b):
    """-> 32x32 RGB565 values, or None (the menu's DecodeBmp)"""
    if check_bmp(b[:BMP_MAX]) is not None:
        return None
    off = struct.unpack_from('<I', b, 10)[0]
    h, bpp = struct.unpack_from('<i', b, 22)[0], struct.unpack_from('<H', b, 28)[0]
    step = bpp // 8
    out = []
    for y in range(32):
        row = (31 - y) if h > 0 else y
        for x in range(32):
            p = off + row * 32 * step + x * step
            bb, g, r = b[p], b[p + 1], b[p + 2]
            out.append(((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (bb >> 3))
    return out


def check_app(b):
    """-> None when the loader (and the menu) would start it, else what the menu says"""
    if not b or len(b) > STAGE_MAX:
        return 'size'
    if len(b) < 0x40:
        return 'header'
    magic, abi, size, entry, crc, base = struct.unpack_from('<4sIIIII', b, 0)
    if magic != b'KN7A':
        return 'header'
    if abi != ABI:
        return 'abi'
    if base != APP_BASE or size != len(b) or not APP_BASE + 0x40 <= entry < APP_BASE + len(b):
        return 'header'
    if zlib.crc32(b[0x20:]) & 0xffffffff != crc:
        return 'crc'
    return None


def programs(folders):
    """folders: [(8.3 name, long name or None, {8.3 file name: bytes})] in directory order"""
    out = []
    for i, (short, long_, files) in enumerate(folders[:MAX_PROG]):
        if 'KN7APP.BIN' not in files:
            continue
        p = {'index': i, 'dir': short, 'name': ascii_name(long_, LFN_MAX) if long_ else short,
             'manifest': 'MANIFEST.TXT' in files, 'icon': None, 'iconbad': False, 'mname': False,
             'appsize': len(files['KN7APP.BIN']), 'check': check_app(files['KN7APP.BIN'])}
        if p['manifest']:
            name, icon11, _ = parse_manifest(files['MANIFEST.TXT'])
            if name:
                p['name'], p['mname'] = name, True
            if icon11:
                fname = icon11[:8].decode().rstrip() + ('.' + icon11[8:].decode().rstrip() if icon11[8:].strip() else '')
                pix = decode_bmp(files[fname]) if fname in files else None
                p['icon'], p['iconbad'] = pix, pix is None
        out.append(p)
    out.sort(key=lambda p: p['name'].upper())
    return out


def from_dir(d):
    folders = []
    for n in sorted(os.listdir(d)):
        p = os.path.join(d, n)
        if os.path.isdir(p):
            files = {f.upper(): open(os.path.join(p, f), 'rb').read() for f in os.listdir(p)
                     if os.path.isfile(os.path.join(p, f))}
            folders.append((n.upper() if make11(n) else n, None if make11(n) and n == n.upper() else n, files))
    return folders


def from_image(img):
    from fatimg import Fat16, show83
    f = Fat16(img)
    folders = []
    for o, short, lng in f.entries(0):
        if not f.d[o + 11] & 0x10 or short[0] == 0x2E:
            continue
        cl = struct.unpack_from('<H', f.d, o + 26)[0]
        files = {}
        for o2, s2, _ in f.entries(cl):
            if f.d[o2 + 11] & 0x18:
                continue
            c2, size = struct.unpack_from('<HI', f.d, o2 + 26)
            data = b''.join(bytes(f.d[f.coff(c):f.coff(c) + f.cb]) for c in f.chain(c2))[:size]
            files[show83(s2)] = data
        folders.append((show83(short), lng, files))
    return folders


def main():
    a = sys.argv[1:]
    folders = from_image(a[a.index('--image') + 1]) if '--image' in a else from_dir(a[0])
    progs = programs(folders)
    for p in progs:
        note = [] if p['manifest'] else ['no MANIFEST.TXT']
        if p['iconbad']:
            note.append('icon file unusable')
        print(f"{p['name']:40} C:\\{p['dir']}\\KN7APP.BIN {p['appsize']:7} bytes  icon "
              f"{'own' if p['icon'] else 'default'}  RUN: {'starts it' if p['check'] is None else 'refused (' + p['check'] + ')'}"
              + (f"  ({'; '.join(note)})" if note else ''))
    print(f'fatscan: {len(progs)} program(s)')
    if '--lua' in a:
        with open(a[a.index('--lua') + 1], 'w') as f:
            f.write('-- generated by fatscan.py: what the menu must list\nreturn {\n')
            for p in progs:
                icon = '{' + ','.join(str(v) for v in p['icon']) + '}' if p['icon'] else 'nil'
                f.write(f"  {{ index = {p['index']}, dir = {lua(p['dir'])}, name = {lua(p['name'])}, "
                        f"appsize = {p['appsize']}, manifest = {str(p['manifest']).lower()}, "
                        f"mname = {str(p['mname']).lower()}, iconbad = {str(p['iconbad']).lower()}, "
                        f"check = {lua(p['check'] or 'ok')}, icon = {icon} }},\n")
            f.write('}\n')


def lua(s):
    return '"' + s.replace('\\', '\\\\').replace('"', '\\"') + '"'


if __name__ == '__main__':
    main()
