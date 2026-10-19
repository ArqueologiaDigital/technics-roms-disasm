#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# find_rhythm.py [--table T.bin] FILE[@BASE] ... -- where on a real KN7000 is the rhythm data ROM (IC18), and is
# what the SURVEY build read there whole? FILE is an image of CPU address space: a survey window R*.BIN, whose
# CPU base is in its 8.3 name (R5400000.BIN = 0x54000000), or any file with an explicit @BASE in hex.
# Images whose addresses are adjacent are joined first, so a 4 MB device straddling two 8 MB windows (one at
# 0x54E00000 runs to 0x551FFFFF) is seen whole. Per joined span:
#   * a map of its 1 MB slices: 'F' all FF, '0' all 00, 'x' one other repeated byte, '=' the same as an
#     earlier slice of the same span (a mirror), '#' data. A chip smaller than the window shows as data
#     followed by '='; an empty chip select as F, 0 or x;
#   * every 16-byte "Technics Rhythms" signature in it (string 0x4872980C), and for each:
#       - whether it is at one of the five addresses StyleResourceWindowProbe (0x4843D6DC) tries, in its
#         order: 0x48010000, 0x40610000, 0x40010000, 0x54E10000, 0x40810000 (else it returns 0x54E00000
#         without looking);
#       - the style count its directory declares (u24 BE offset at +0x18 -> block, u16 BE at block+2);
#       - the firmware's self-check, StyleResourceVerify (0x484338B4): u16 BE checksum at +0x10, u24 BE
#         offset at +0x12 and u24 BE word count at +0x15; the 16-bit sum of that many big-endian words from
#         the signature + offset must equal the checksum. All three zero (as in the table ROM's truncated
#         copy) declares no checksum, and is reported as such, not as a pass;
#       - the RHYTHM version SOFT VERSION would show for it: ASCII digits at signature - 0x10000 + 0x3FFFEC
#         (AcRhythmVerBoxProc 0x4848895F), i.e. 0x14 bytes below the top of a 4 MB device that starts
#         0x10000 below the signature;
#       - how many of its first bytes equal the truncated copy the table ROM carries (directory entry
#         *(0x4800014C), 0x483E828C in build 80/84, the last 0x17D74 bytes of the table). A real rhythm ROM
#         should agree with it over all of them.
# The table image (a joined 4 MB table, as find_fw.interleave makes it) defaults to the first table build in
# ~/compartilhado/technics_romsets/kn7000 whose entry holds the copy: b84. The b80 table, the one on the
# instrument the survey ran on, has only "DMY\n" and blank flash there.
#   python3 -I find_rhythm.py KN7DUMP/R4000000.BIN KN7DUMP/R4080000.BIN KN7DUMP/R5400000.BIN ...
#   python3 -I find_rhythm.py --self-test    # the checks on a made-up device split across two windows
import os
import re
import struct
import sys
from array import array

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import find_fw  # noqa: E402

SIG = b'Technics Rhythms'
PROBES = [0x48010000, 0x40610000, 0x40010000, 0x54E10000, 0x40810000]
FALLBACK = 0x54E00000
KNOWN = os.path.expanduser('~/compartilhado/technics_romsets/kn7000')
MB = 0x100000


def u24(b, o):
    return int.from_bytes(b[o:o + 3], 'big')


def default_table():
    """The first table build we have whose rhythm entry holds the signature. b80's entry is a "DMY" stub."""
    for e in sorted(n for n in os.listdir(KNOWN) if re.fullmatch(r'kn7000_table_even_b\d+\.ic17', n)):
        o = e.replace('_even_', '_odd_').replace('.ic17', '.ic16')
        if os.path.exists(os.path.join(KNOWN, o)):
            t = find_fw.interleave(*(open(os.path.join(KNOWN, n), 'rb').read() for n in (e, o)))
            if t[struct.unpack_from('<I', t, 0x14C)[0]:].startswith(SIG):
                return re.search(r'b\d+', e).group(0), t
    return None, None


def slice_map(b):
    out, seen = [], {}
    for i in range(0, len(b), MB):
        s = b[i:i + MB]
        if s.count(s[:1]) == len(s):
            out.append({0xFF: 'F', 0: '0'}.get(s[0], 'x'))
        elif s in seen:
            out.append('=')
        else:
            seen[s] = i
            out.append('#')
    return ''.join(out)


def self_check(b, h):
    cs, = struct.unpack_from('>H', b, h + 0x10)
    off, cnt = u24(b, h + 0x12), u24(b, h + 0x15)
    if cs == off == cnt == 0:
        return 'no checksum declared (+0x10..+0x17 all zero)'
    start = h + off
    if start + 2 * cnt > len(b):
        return f'checksum {cs:04x} over {cnt:#x} words from +{off:#x}: runs past the end of this image'
    words = array('H', b[start:start + 2 * cnt])
    if sys.byteorder == 'little':
        words.byteswap()
    s = sum(words) & 0xFFFF
    return f'checksum {cs:04x} over {cnt:#x} words from +{off:#x}: ' + ('OK' if s == cs else f'NG, the sum is {s:04x}')


def version(b, h):
    v = h - 0x10000 + 0x3FFFEC
    if not 0 <= v < len(b):
        return 'outside this image'
    m = re.match(rb'\d+', b[v:v + 8])
    return m.group(0).decode() if m else f'no digits ({b[v:v + 8].hex()})'


def style_count(b, h):
    blk = h + u24(b, h + 0x18)
    return struct.unpack_from('>H', b, blk + 2)[0] if blk + 4 <= len(b) else '? (directory past the end)'


def main(argv):
    table_name, table = None, None
    if argv[:1] == ['--table']:
        table_name, table, argv = argv[1], open(argv[1], 'rb').read(), argv[2:]
    else:
        table_name, table = default_table()
    copy = None
    if table:
        at = struct.unpack_from('<I', table, 0x14C)[0]
        copy = table[at:]
        print(f'table {table_name}: its rhythm header copy is at {0x48000000 + at:#010x}, {len(copy):#x} bytes'
              f' to the end of the table, declaring {style_count(table, at)} styles')
    images = []
    for arg in argv:
        path, _, base = arg.partition('@')
        m = re.search(r'R([0-9A-F]{7})\.BIN$', os.path.basename(path), re.I)
        if not base and not m:
            sys.exit(f'{path}: give its CPU base as {path}@BASE')
        images.append((int(base, 16) if base else int(m.group(1), 16) << 4, os.path.basename(path), open(path, 'rb').read()))
    # adjacent windows are joined, so a device that straddles two 8 MB files is seen whole
    spans = []
    for base, name, b in sorted(images):
        if spans and spans[-1][0] + len(spans[-1][2]) == base:
            spans[-1] = (spans[-1][0], spans[-1][1] + ' + ' + name, spans[-1][2] + b)
        else:
            spans.append((base, name, b))
    found = {}
    for base, name, b in spans:
        print(f'\n{name}: CPU {base:#010x}-{base + len(b) - 1:#010x}, FF {b.count(255) * 100 / len(b):.1f}%,'
              f' 00 {b.count(0) * 100 / len(b):.1f}%')
        print(f'   1 MB slices from {base:#010x}: {slice_map(b)}')
        hits = [i.start() for i in re.finditer(re.escape(SIG), b)]
        if not hits:
            print('   no "Technics Rhythms" signature')
        for h in hits[:16]:
            a = base + h
            rank = f'probe {PROBES.index(a) + 1} of 5' if a in PROBES else 'not a probed address'
            print(f'   signature at {a:#010x} ({rank}): {style_count(b, h)} styles; {self_check(b, h)};'
                  f' RHYTHM version {version(b, h)}')
            if copy:
                n = len(copy) if b[h:h + len(copy)] == copy else next(
                    (i for i, (x, y) in enumerate(zip(b[h:h + len(copy)], copy)) if x != y), min(len(copy), len(b) - h))
                print(f'      agrees with the table\'s copy over {n:#x} of its {len(copy):#x} bytes')
            if a in PROBES:
                found[a] = name
        if len(hits) > 16:
            print(f'   ... and {len(hits) - 16} more signatures, not listed')
    pick = next((a for a in PROBES if a in found), None)
    print('\nthe firmware would use:', f'{pick:#010x} ({found[pick]})' if pick else
          f'none of the five probes; it falls back to {FALLBACK:#010x} without checking for a signature'
          ' (as far as the images given show; 0x48010000 is the table ROM)')


def self_test():
    """A made-up 4 MB device at 0x54E00000 (signature at 0x54E10000, probe 4), split across two 8 MB survey
    windows R5480000.BIN and R5500000.BIN as the real one would be: the windows must be joined, the checksum
    must pass, a flipped bit inside the summed range must fail it, and the version digits must be found."""
    import contextlib
    import io
    import random
    import tempfile
    dev = bytearray(random.Random(7000).randbytes(0x400000))
    h, off, cnt = 0x10000, 0x40, 0x180000
    dev[h:h + 16] = SIG
    dev[h + 0x12:h + 0x15], dev[h + 0x15:h + 0x18] = off.to_bytes(3, 'big'), cnt.to_bytes(3, 'big')
    dev[h + 0x10:h + 0x12] = (sum(struct.unpack_from(f'>{cnt}H', dev, h + off)) & 0xFFFF).to_bytes(2, 'big')
    dev[0x3FFFEC:0x3FFFF0] = b'0042'
    space = bytearray(b'\xff' * 0x1000000)                          # 0x54800000-0x557FFFFF
    outs = []
    with tempfile.TemporaryDirectory() as d:
        paths = [os.path.join(d, n) for n in ('R5500000.BIN', 'R5480000.BIN')]
        for flip in (False, True):
            if flip:
                dev[h + off + 7] ^= 1
            space[0x600000:0xA00000] = dev
            open(paths[0], 'wb').write(space[0x800000:])
            open(paths[1], 'wb').write(space[:0x800000])
            with contextlib.redirect_stdout(io.StringIO()) as out:
                main(paths)
            outs.append(out.getvalue())
    ok, ng = outs
    assert 'R5480000.BIN + R5500000.BIN' in ok and 'FFFFFF####FFFFFF' in ok, ok
    assert ': OK;' in ok and 'RHYTHM version 0042' in ok and 'would use: 0x54e10000' in ok, ok
    assert ': NG, the sum is' in ng, ng
    print('self-test passed: two windows joined; OK on the intact device, NG after one flipped bit;'
          ' version 0042; the firmware would use probe 0x54E10000')


if __name__ == '__main__':
    self_test() if sys.argv[1:] == ['--self-test'] else main(sys.argv[1:])
