#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# find_fw.py -- does the loader's run-time firmware search find the right routines in every KN7000 program
# build we have? The same searches as Discover in loader.s, in Python:
#   * masked byte signatures of the fmm file layer (the drive switch SetExtMode/ResetExtMode and the
#     fmmopen/fmmclose/fmmread/fmmwrite dispatchers, whose only build-dependent bytes are the drive byte and
#     dispatch-table addresses), of raw SD sector read/write, sdfmmkdir/sdfmpath, the SOFT VERSION code that
#     loads the PROGRAM build number, and the kernel's millisecond tick;
#   * the fmm dispatch tables, found by their shape alone (find_tables), which give the SD backends without
#     any code signature -- the loader's way in when the dispatchers' code differs from every build we know.
# Prints what it finds per image, and whether the tables agree with fmmopen's table operand.
#   python3 -I find_fw.py                  # the images under ~/compartilhado/technics_romsets and baserom
import os
import struct
import zipfile

R = os.path.expanduser('~/compartilhado/technics_romsets')
B = os.path.expanduser('~/compartilhado/kn7000_disassembly/baserom')

# signatures: bytes, with None for a masked byte. 'D' = drive byte address, 'T' = table address
def sig(text):
    out = []
    for t in text.split():
        out += [None] * 4 if t in ('D', 'T', 'X') else [None] if t == '??' else [int(t, 16)]
    return out

SIGS = {
    # SetExtMode, ResetExtMode, CheckExtMode, back to back
    'ext':      sig('81 15 a5 03 c2 08 fc 82 D de 00 00 00 fc 82 D de 00 00 fc a8 D de 00 00'),
    'fmmopen':  sig('cf 30 f8 fe e4 97 fc de T 3d 21 10 85 f4 db f0 42 49 f0 51 45 44 d9 fc a8 D 3d 54 21 10 f3 a1 9d f0 f2 df 30 24'),
    'fmmclose': sig('f8 fe ec fc dd T 3c 20 08 85 f4 db f0 41 45 f0 50 41 44 d9 fc a8 D 3c 54 20 08 f3 80 f0 f0 df 00 14'),
    'fmmwrite': sig('cf a0 f8 fe e4 82 fc de T 3d 21 10 85 f4 db f0 42 49 f0 51 45 44 d9 fc a8 D 3d 54 21 10 f3 91 88 f0 f1 df a0 24'),
    'build':    sig('fc a4 X 0c fc 83 X fc a6 1c 00 00 48 fc c2 00 00 00 48'),
    # the kernel's 1 kHz tick handler (in the library image): mov (MS), d0; inc d0; mov d0, (MS) (941 lib 0x4C02BB05)
    'tick':     sig('cf 80 f8 fe f0 fc a4 X 40 fc 81 X f8 ec 01 c8 09 dd X 80 0c fa fc ff f7 cb cb '
                    'fc ac 18 01 00 34 fa e0 00 ff f8 e4 01 fc 83 18 01 00 34'),
    # raw SD sector read (d0 = sector, d1 = count, a1 = buffer) and write, back to back (941 0x48470348)
    'raw':      sig('cf 80 f8 fe e8 82 fc a8 X 10 a0 00 c8 15 80 01 fc 82 X 00 fc 82 X 80 06 ca 0e '
                    '1d 46 10 80 03 94 89 cd ?? ?? 00 1c df 80 1c cf 80 f8 fe e8 1d 46 10 81 94 80 04 '
                    'cd ?? ?? 00 1c df 80 1c'),
    # sdfmmkdir (a0 = "C:\\FOLDER") and sdfmpath (a0 = folder, or 0), back to back (941 0x48565D45)
    'sdfolder': sig('cf a0 f8 fe f4 92 08 dd X 00 1c 98 dd X a0 18 a8 c2 10 fc a4 X 8a f5 a0 1f c8 04 '
                    '8a fd fc ad X 19 84 a5 00 c0 04 88 18 fc 83 X 88 df a0 14 '
                    'f8 fe ec 91 b5 00 c9 16 fc dc X 00 2d 80 00 dd X 20 04 00 ca 10 fc dc X dd X 00 00 '
                    '00 df 00 14'),
}

def find(img, s):
    first = next(i for i, b in enumerate(s) if b is not None)
    hits, start = [], 0
    while True:
        i = img.find(bytes([s[first]]), start)
        if i < 0:
            return hits
        p = i - first
        if p >= 0 and p + len(s) <= len(img) and all(b is None or img[p + k] == b for k, b in enumerate(s)):
            hits.append(p)
        start = i + 1

def u32(img, o):
    return struct.unpack_from('<I', img, o)[0]

def interleave(even, odd):
    out = bytearray(len(even) * 2)
    out[0::4], out[1::4], out[2::4], out[3::4] = even[0::2], even[1::2], odd[0::2], odd[1::2]
    return bytes(out)

def find_tables(img, base=0x48400000):
    """The fmm dispatch tables, found by their shape alone: eleven 12-byte records (error, open, close,
    remove, two more, read, write, seek, rewind, tell), each three code pointers (floppy, SD, third
    backend) into the program flash, the floppy and SD columns each in ascending order and each
    within 64 KB. Returns the offsets of every place that fits."""
    lo, hi = base, base + 0x400000
    hits = []
    for o in range(0, len(img) - 11 * 12, 4):
        rec = [struct.unpack_from('<3I', img, o + 12 * k) for k in range(11)]
        if not all(lo <= p < hi for r in rec for p in r):
            continue
        ok = True
        for col in (0, 1):
            c = [r[col] for r in rec]
            if any(c[k + 1] <= c[k] for k in range(10)) or c[-1] - c[0] > 0x10000:
                ok = False
                break
        if not ok:
            continue
        c0, c1, c2 = ([r[i] for r in rec] for i in range(3))
        # the three backends are three separate pieces of code: the columns' ranges do not overlap
        if not (max(c0) < min(c1) or max(c1) < min(c0)):
            continue
        if max(c2) - min(c2) > 0x10000 or not (max(c2) < min(c0) or min(c2) > max(c0)) \
                or not (max(c2) < min(c1) or min(c2) > max(c1)):
            continue
        hits.append(o)
    return hits


def analyse(name, img, base=0x48400000):
    print(f'== {name}: release byte {img[0xf]:#04x}')
    r = {}
    for k, s in SIGS.items():
        h = find(img, s)
        r[k] = h
        print(f'   {k:9} {len(h)} hit(s): ' + ', '.join(f'{base + x:#010x}' for x in h[:4]))
    if len(r['ext']) == 1:
        e = r['ext'][0]
        print(f'   drive byte {u32(img, e + 8):#010x}; SetExtMode {base + e:#x}, ResetExtMode {base + e + 0xf:#x}')
    if len(r['fmmopen']) == 1:
        o = r['fmmopen'][0]
        topen = u32(img, o + 8)
        print(f'   fmmopen table {topen:#010x}, drive byte {u32(img, o + 28):#010x}')
        # the dispatchers that share fmmclose's and fmmwrite's shape, told apart by their table
        for k, toff, doff, dist in (('fmmclose', 5, 25, 12), ('fmmread', 8, 28, 0x3c), ('fmmwrite', 8, 28, 0x48)):
            sk = 'fmmclose' if k == 'fmmclose' else 'fmmwrite'
            ok = [h for h in r[sk] if u32(img, h + toff) == topen + dist and u32(img, h + doff) == u32(img, o + 28)]
            print(f'   {k:9} ' + (f'{base + ok[0]:#x}' if len(ok) == 1 else f'{len(ok)} candidates'))
    if len(r['raw']) == 1:
        print(f"   raw read {base + r['raw'][0]:#x}, raw write {base + r['raw'][0] + 0x33:#x}")
    if len(r['sdfolder']) == 1:
        h = r['sdfolder'][0]
        print(f"   sdfmmkdir {base + h:#x}, sdfmpath {base + h + 0x3f:#x}, folder buffer {u32(img, h + 0x3f + 10):#x}")
    t = find_tables(img, base)
    print(f"   fmm tables by shape: {len(t)} hit(s) " + ', '.join(f'{base + x:#x}' for x in t[:3]))
    if len(t) == 1:
        rec = [struct.unpack_from('<3I', img, t[0] + 12 * k) for k in range(11)]
        print(f"   SD backends: open {rec[1][1]:#x}, close {rec[2][1]:#x}, read {rec[6][1]:#x}, write {rec[7][1]:#x}")
        print(f"   floppy backends: open {rec[1][0]:#x}, close {rec[2][0]:#x}, read {rec[6][0]:#x}")
        if len(r['fmmopen']) == 1:   # the loader uses the tables only when fmmopen's table = the tables + 12
            topen = u32(img, r['fmmopen'][0] + 8)
            print(f"   fmmopen's table operand {topen:#x}: {'agrees' if topen == base + t[0] + 12 else 'DISAGREES'}")
    if len(r['tick']) == 1:
        h = r['tick'][0]
        print(f"   kernel ms counter {u32(img, h + 7):#x} (twice: {u32(img, h + 7) == u32(img, h + 14)})")
    if len(r['build']) == 1:
        a = u32(img, r['build'][0] + 2)
        o = a - base
        print(f'   build number u16 at {a:#010x} = {struct.unpack_from("<H", img, o)[0] if 0 <= o < len(img) else "?"}')

if __name__ == '__main__':
    z = zipfile.ZipFile(f'{R}/kn7000.zip')
    analyse('941 (kn7000.zip)', interleave(z.read('kn7000_program_even.ic17'), z.read('kn7000_program_odd.ic16')))
    analyse('942 (baserom)', open(f'{B}/kn7000_program_sp7001.rom', 'rb').read())
    analyse('935', interleave(open(f'{R}/kn7000/kn7000_program_even_v1.5_b935.ic17', 'rb').read(),
                              open(f'{R}/kn7000/kn7000_program_odd_v1.5_b935.ic16', 'rb').read()))
    up = interleave(open(f'{R}/kn7000/kn7000_program_even_v1.4_b929_upper.ic17', 'rb').read(),
                    open(f'{R}/kn7000/kn7000_program_odd_v1.4_b929_upper.ic16', 'rb').read())
    analyse('929 (upper half only)', bytes(0x200000) + up)
