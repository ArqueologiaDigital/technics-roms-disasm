#!/usr/bin/env python3
"""Where are the non-mutual cell links and the undecodable chains of the KN5000 floppy style banks and SQT event
memories?  For each one: is the cell reachable from what the firmware starts from?
  style bank (.CMP, .RCM sections 0..6): a chain is reachable when its head is a part cell of a directory record
     (the five cell words of each of the 30 section records, MapBitFlagsToChannelOffset's offsets 0/4/6/8/10);
  SQT: a cell is reachable when it lies on the chain of a present track (+0xd0 track table: bit 7 of the flag
     byte, first cell word at +0xd1 + 3*t) or on the free list (+0xaf free_list_head, next links).
usage: style_links.py EXTRACTED_DIR      (the floppy files, from floppy/tools/fat12_extract.py)
Output: one line per non-mutual link / bad chain, then counts by reachability."""
import collections, pathlib, struct, sys
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[3] / 'floppy' / 'kn5000'))
import formats  # noqa: E402
ARGS = {0x90: 5, 0x91: 7, 0x81: 0, 0xD1: 2, 0xD2: 2, 0xD3: 2, 0xD4: 2, 0xD5: 2}
cnt = collections.Counter()


def style_bank(d, base, end, tag):
    # every cell-shaped block, as notes/floppy-kn5000-2026-10-29/probes/kn5000_floppy_formats.py counts them: from
    # the bank start, so the stale cell-shaped blocks 12..19 of three CMPs (below the cell area +0x1400) are in
    blocks = [o for o in range(base, end - 255, 256) if formats.is_cell(d[o:o + 256])]
    cs = set(blocks)

    def at(v):
        return base + ((v & 0xFFF) + 20) * 256
    heads = set()
    for k in range(30):
        r = base + 0x60 + 0x60 * k
        for w in (0, 4, 6, 8, 10):
            v = struct.unpack_from('<H', d, r + w)[0]
            if v != 0xFFFF and at(v) in cs:
                heads.add(at(v))
    reach = set()
    for h in heads:
        o = h
        while o in cs and o not in reach:
            reach.add(o)
            n = struct.unpack_from('<H', d, o + 3)[0]
            o = at(n) if n != 0xFFFF else None
    for o in blocks:
        prev, nxt = struct.unpack_from('<HH', d, o + 1)
        if nxt != 0xFFFF and at(nxt) in cs and at(struct.unpack_from('<H', d, at(nxt) + 1)[0]) != o:
            t = at(nxt)
            r = ('reachable' if o in reach else 'unreachable') + (', below +0x1400' if o - base < 0x1400 else '')
            cnt['style link not mutual, source %s, mark %02x' % (r, d[o])] += 1
            print('STYLE-LINK %s block %d (mark %02x prev %04x next %04x) -> block %d (mark %02x prev %04x): %s' % (
                tag, (o - base) >> 8, d[o], prev, nxt, (t - base) >> 8, d[t], struct.unpack_from('<H', d, t + 1)[0], r))
    for h in [o for o in blocks if struct.unpack_from('<H', d, o + 1)[0] == 0xFFFF and d[o] == 0x80]:
        stream, o, seen = b'', h, []
        while o is not None and o in cs and o not in seen:
            seen.append(o)
            stream += d[o + 6:o + 255]
            n = struct.unpack_from('<H', d, o + 3)[0]
            o = at(n) if n != 0xFFFF else None
        p = 0
        while p < len(stream) and stream[p] != 0x83 and stream[p] in ARGS:
            p += 1 + ARGS[stream[p]]
        if p < len(stream) and stream[p] != 0x83:
            r = ('reachable' if h in heads else 'unreachable') + (', head below +0x1400' if h - base < 0x1400 else '')
            cnt['style chain stops at 0x%02x, head %s' % (stream[p], r)] += 1
            print('STYLE-CHAIN %s head block %d, %d cells, stops at byte %d (0x%02x) of the stream, cell %d: %s; '
                  'bytes there %s' % (tag, (h - base) >> 8, len(seen), p, stream[p], p // 249, r,
                                      stream[max(0, p - 8):p + 8].hex(' ')))


for f in sorted(x for x in pathlib.Path(sys.argv[1]).rglob("*") if x.is_file()):
    ext = f.suffix.lower()
    d = f.read_bytes()
    tag = '%s/%s' % (f.parent.name, f.name)
    if ext == '.cmp' and d[:4] == b'H\0K\0':
        style_bank(d, 0, len(d), tag)
    elif ext == '.rcm' and len(d) == 0x72C00:
        lens = struct.unpack_from('<9I', d, 0x40)
        o = 0x400
        for k in range(7):
            style_bank(d, o, o + lens[k + 1], '%s section %d' % (tag, k))
            o += lens[k + 1]
    elif ext == '.sqt' and d[:4] == b'ZZZZ':
        ns = 10 if d[4] == 1 else 1
        base = ns * 0x800
        n = (len(d) - base) // 256

        def cell(c):
            return base + (c - 1) * 256
        reach = {}
        for s in range(ns):
            b = s * 0x800
            for t in range(16):
                fl, first = d[b + 0xD0 + 3 * t], struct.unpack_from('<H', d, b + 0xD1 + 3 * t)[0]
                if fl & 0x80:
                    c = first
                    while 1 <= c <= n and c not in reach:
                        reach[c] = 'song %d track %d' % (s + 1, t + 1)
                        c = struct.unpack_from('<H', d, cell(c) + 3)[0]
            c = struct.unpack_from('<H', d, b + 0xAF)[0]
            while 1 <= c <= n and c not in reach:
                reach[c] = 'song %d free list' % (s + 1)
                c = struct.unpack_from('<H', d, cell(c) + 3)[0]
        for i in range(1, n + 1):
            prev, nxt = struct.unpack_from('<HH', d, cell(i) + 1)
            if nxt != 0xFFFF and 1 <= nxt <= n and struct.unpack_from('<H', d, cell(nxt) + 1)[0] != i:
                r = reach.get(i, 'unreachable')
                cnt['SQT link not mutual, source %s' % ('unreachable' if r == 'unreachable' else r.split()[-1] if 'free' in r else 'track')] += 1
                print('SQT-LINK %s cell %d (flags %02x prev %d next %d) -> cell %d (prev %d): %s' % (
                    tag, i, d[cell(i)], prev, nxt, nxt, struct.unpack_from('<H', d, cell(nxt) + 1)[0], r))
for k, v in sorted(cnt.items()):
    print('%-60s %d' % (k, v))
