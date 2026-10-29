#!/usr/bin/env python3
"""kn5000_floppy_formats.py -- do the 14 KN5000 softlist disks hold the formats floppy/kn5000/formats.py says?

Each check prints its counts and the script exits 1 if any check fails.  Run after
`make -C floppy refs-kn5000`; the references are in floppy/kn5000/baserom/:

    python3 notes/floppy-kn5000-2026-10-29/probes/kn5000_floppy_formats.py floppy/kn5000/baserom/*.img

  BOOT  each boot sector's first 32 bytes == the firmware's FDC_Format2HD_BootSectorHead
        (v10 ROM 0xe450da, original_ROMs/kn5000_v10_program.rom), and the rest of the sector is 0.
  LSW   size 0xe40 (FileIO_SaveRegion0_VRAM: 0x640 + 0x800), "HK" at +4, block 0 / block 1 walk as
        exactly the tag/length lists PanelTlv_Block0_Layout / _Block1_Layout.
  PMT   +0x0d u16 = 960 and +0x0f = count, size 0xb0 + 960 * count, and every memory walks as the
        PanelTlv_Block0_Layout list.
  TM    size 0x72aa (FileIO_SaveRegion4_VRAM), "KN5000 SOUND RAM", 40 printable 16-byte names at
        16 + 470 k, and one more after them.
  CMP / RCM   every style bank: cell links resolve to cells and are mutual (next(A) = B <=> prev(B) = A,
        cell number = (v & 0xfff) + the bank's first cell block), and each chain's events parse under
        the IC19 grammar (scripts/build/style_events.py ARGS) up to END with no unknown status byte.
  SQT   song-slot count from +4, event cells with ONE-BASED links: every link resolves and is mutual.
"""
import pathlib
import struct
import sys

HERE = pathlib.Path(__file__).resolve()
REPO = HERE.parents[3]
sys.path.insert(0, str(REPO / 'floppy' / 'tools'))
sys.path.insert(0, str(REPO / 'floppy' / 'kn5000'))
import fat12lib  # noqa: E402
import formats  # noqa: E402

# style_events.py's grammar, plus 0xd4 / 0xd5 with two data bytes: measured here (with them every
# one of the 29 chains that stopped at 0xd4/0xd5 parses to END; 1 or 3 data bytes break 20+ chains).
ARGS = {0x90: 5, 0x91: 7, 0x81: 0, 0xD1: 2, 0xD2: 2, 0xD3: 2, 0xD4: 2, 0xD5: 2}
fails = []
count = {}


def bump(k, n=1):
    count[k] = count.get(k, 0) + n


def check(cond, what):
    if not cond:
        fails.append(what)
    return cond


def style_bank(d, base, end, tag):
    blocks = [o for o in range(base, end - 255, 256) if formats.is_cell(d[o:o + 256])]
    if not blocks:
        return
    first = formats.CELL_BASE_BLOCK
    cs = set(blocks)
    # BASE: the link base is the one block number that makes links mutual
    best = []
    for b0 in range(0, 64):
        ok = 0
        for o in blocks:
            n = struct.unpack_from('<H', d, o + 3)[0]
            t = base + ((n & 0xFFF) + b0) * 256
            if n != 0xFFFF and t in cs and base + ((struct.unpack_from('<H', d, t + 1)[0] & 0xFFF) + b0) * 256 == o:
                ok += 1
        best.append((ok, b0))
    top = max(best)
    if top[0]:
        second = sorted(best)[-2][0]
        check(top[1] == first and top[0] >= 10 * second, '%s: link base is %d, not %d' % (tag, top[1], first))
        bump('BASE banks where block 20 makes >= 10x the mutual links of any other base')

    def at(v):
        return base + ((v & 0xFFF) + first) * 256

    for o in blocks:
        prev, nxt = struct.unpack_from('<HH', d, o + 1)
        bump('style cells')
        if nxt != 0xFFFF:
            t = at(nxt)
            if t not in cs:
                bump('style next links landing off a cell')
            elif at(struct.unpack_from('<H', d, t + 1)[0]) == o:
                bump('style next links mutual')
            else:
                bump('style next links NOT mutual')
    for h in [o for o in blocks if struct.unpack_from('<H', d, o + 1)[0] == 0xFFFF and d[o] == 0x80]:
        stream, o, seen = b'', h, set()
        while o is not None and o not in seen:
            seen.add(o)
            stream += d[o + 6:o + 255]
            nxt = struct.unpack_from('<H', d, o + 3)[0]
            o = at(nxt) if nxt != 0xFFFF else None
        p, ok, n = 0, False, 0
        while p < len(stream):
            s = stream[p]
            if s == 0x83:
                ok = True
                break
            if s not in ARGS:
                break
            p += 1 + ARGS[s]
            n += 1
        bump('style chains')
        bump('style events', n)
        if not ok:
            bump('style chains NOT parsing to END (status %s)' % ('0x%02x' % stream[p] if p < len(stream) else 'eof'))


def re_cat(f):
    import re
    return re.sub(r'\b\d+\b|0x[0-9a-f]+', 'N', f.split(': ', 1)[-1])


def main():
    rom = (REPO / 'original_ROMs' / 'kn5000_v10_program.rom').read_bytes()
    head = rom[0x450DA:0x450FA]
    lay = formats.layout()
    for p in sys.argv[1:]:
        data = pathlib.Path(p).read_bytes()
        img = fat12lib.Image(data)
        disk = pathlib.Path(p).stem
        check(data[:32] == head and data[32:512] == bytes(480), '%s: boot sector' % disk)
        bump('BOOT disks')
        for e in img.files():
            d = img.file_bytes(e)
            ext = e.ext.decode('latin-1').strip()
            tag = '%s/%s' % (disk, e.path())
            if ext == 'LSW':
                bump('LSW files')
                check(len(d) == 0xE40 and d[4:6] == b'HK', tag + ': LSW size/signature')
                m0, _ = formats.match_layout(d, 0x20, 0x3E0, lay['PanelTlv_Block0_Layout'])
                m1, _ = formats.match_layout(d, 0x3E0, 0x640, lay['PanelTlv_Block1_Layout'])
                bump('LSW block 0 / block 1 opening with %d / %d of the 46 / 30 layout records' % (m0, m1))
            elif ext == 'PMT':
                bump('PMT files')
                slot, n = struct.unpack_from('<H', d, 0x0D)[0], d[0x0F]
                check(slot == 960 and len(d) == 0xB0 + n * 960, tag + ': PMT header')
                for k in range(n):
                    r, _ = formats.tlv_records(d, 0xB0 + 960 * k, 0xB0 + 960 * (k + 1))
                    m, _ = formats.match_layout(d, 0xB0 + 960 * k, 0xB0 + 960 * (k + 1), lay['PanelTlv_Block0_Layout'])
                    bump('PMT memories opening with %d of the 46 PanelTlv_Block0_Layout records' % m)
            elif ext == 'TM':
                bump('TM files')
                if d[:16] == b'KN5000 SOUND RAM' and check(len(d) == 0x72AA, tag + ': TM size'):
                    bump('TM names printable (of 41 per file)', sum(formats.printable(d[16 + 470 * k:32 + 470 * k]) for k in range(41)))
                else:
                    bump('TM files of another model: %r, %d B' % (d[:16].decode('latin-1'), len(d)))
            elif ext == 'CMP':
                bump('CMP files')
                style_bank(d, 0, len(d), tag)
            elif ext == 'RCM':
                bump('RCM files')
                lens = struct.unpack_from('<9I', d, 0x40)
                check(lens[0] == 0x400 and 0x400 + sum(lens[1:8]) + 0xF400 == len(d), tag + ': RCM lengths')
                o = 0x400
                for k in range(7):
                    style_bank(d, o, o + lens[k + 1], '%s section %d' % (tag, k))
                    o += lens[k + 1]
            elif ext == 'SQT':
                bump('SQT files')
                ns = 10 if d[4] == 1 else 1
                base = ns * 0x800
                n = (len(d) - base) // 256
                for i in range(n):
                    o = base + 256 * i
                    prev, nxt = struct.unpack_from('<HH', d, o + 1)
                    bump('SQT cells')
                    if nxt != 0xFFFF and nxt <= n:
                        if struct.unpack_from('<H', d, base + 256 * (nxt - 1) + 1)[0] == i + 1:
                            bump('SQT next links mutual')
                        else:
                            bump('SQT next links NOT mutual')
                    elif nxt != 0xFFFF:
                        bump('SQT next one past the end (free-list tail)')
                        check(nxt == n + 1, '%s: cell %d next %d out of range' % (tag, i + 1, nxt))
    for k in sorted(count):
        print('%-48s %d' % (k, count[k]))
    import collections
    for k, v in collections.Counter(re_cat(f) for f in fails).most_common():
        print('FAIL x%-5d %s' % (v, k))
    for f in fails[:10]:
        print('FAIL', f)
    print('%d failures' % len(fails))
    sys.exit(1 if fails else 0)


if __name__ == '__main__':
    main()
