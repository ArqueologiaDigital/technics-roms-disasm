"""floppy/kn5000/events.py -- the KN5000's two cell-chained event grammars, one event per line.

Used by formats.py for CMP / RCM style banks (the IC19 accompaniment grammar) and for SQT song
memory (the demo-song grammar).  Both store a byte stream in 256-byte cells linked into chains; an
event may straddle two cells, so a chain is tokenised as one stream and the events are then cut
back into the cells that hold them.  An event split by a cell boundary is spelled as `.byte` in
each cell, with the whole event in the comment.

Macros: floppy/kn5000/include/kn5000_files.inc (st_* and sq_*).
"""

# --- IC19 accompaniment grammar (docs/accompaniment-style-format.md; scripts/build/style_events.py)
# 0xd4 / 0xd5 (two data bytes each) are not in style_events.py: they occur only on these disks,
# and the argument count is measured (notes/floppy-kn5000-2026-10-29/probes/kn5000_floppy_formats.py).
ST_ARGS = {0x81: 0, 0x83: 0, 0x90: 5, 0x91: 7, 0xD1: 2, 0xD2: 2, 0xD3: 2, 0xD4: 2, 0xD5: 2}
ST_MACRO = {0x81: 'st_beat', 0x83: 'st_end', 0x90: 'st_note', 0x91: 'st_note2',
            0xD1: 'st_ctl1', 0xD2: 'st_ctl2', 0xD3: 'st_ctl3', 0xD4: 'st_ctl4', 0xD5: 'st_ctl5'}


def tokenize_style(s):
    """[(start, length, text)] over the stream s.  After END the rest is PAD; an unknown status
    stops decoding and the rest is UNDECODED."""
    out, p = [], 0
    while p < len(s):
        st = s[p]
        if st not in ST_ARGS:
            out.append((p, len(s) - p, 'RAW', 'not decoded: status 0x%02x is not in the IC19 grammar' % st))
            return out
        n = 1 + ST_ARGS[st]
        if p + n > len(s):
            out.append((p, len(s) - p, 'RAW', 'truncated %s at the end of the chain' % ST_MACRO[st]))
            return out
        args = ', '.join(str(x) for x in s[p + 1:p + n])
        out.append((p, n, ST_MACRO[st] + ('\t' + args if args else ''), None))
        p += n
        if st == 0x83:
            if p < len(s):
                out.append((p, len(s) - p, 'PAD', 'after st_end'))
            return out
    return out


# --- demo-song grammar (scripts/build/demo_preset_to_midi.py): a byte with bit 7 set is a status,
# the bytes after it with bit 7 clear are its data.  0x81 beat, 0x82 end of track (with data),
# 0x9n note with 5 data bytes; further groups of 5 repeat the note status (running status).

def tokenize_seq(s):
    out, p, n = [], 0, len(s)
    while p < n:
        st = s[p]
        if not st & 0x80:
            q = p
            while q < n and not s[q] & 0x80:
                q += 1
            out.append((p, q - p, 'sq_data\t' + ', '.join(str(x) for x in s[p:q]), None))
            p = q
            continue
        q = p + 1
        while q < n and not s[q] & 0x80:
            q += 1
        data = s[p + 1:q]
        if st == 0x81 and not data:
            out.append((p, 1, 'sq_beat', None))
        elif st & 0xF0 == 0x90 and len(data) >= 5:
            out.append((p, 6, 'sq_note\t0x%02x, %s' % (st, ', '.join(str(x) for x in data[:5])), None))
            r = p + 6
            while q - r >= 5:
                out.append((r, 5, 'sq_run\t' + ', '.join(str(x) for x in s[r:r + 5]), None))
                r += 5
            if r < q:
                out.append((r, q - r, 'sq_data\t' + ', '.join(str(x) for x in s[r:q]), None))
        else:
            out.append((p, q - p, 'sq_ev\t0x%02x' % st + ''.join(', %d' % x for x in data), None))
        p = q
        if st == 0x82:
            if p < n:
                out.append((p, n - p, 'PAD', 'after the end of track'))
            return out
    return out


def raw_lines(b, why):
    """Bytes with no event meaning (PAD, undecoded rest): fill when uniform, else .byte rows."""
    if not b:
        return []
    if len(set(b)) == 1:
        return [('\t.fill\t%d, 1, 0x%02x\t; %s' % (len(b), b[0], why), len(b))]
    rows = []
    for i in range(0, len(b), 16):
        part = b[i:i + 16]
        rows.append(('\t.byte\t' + ', '.join('0x%02x' % x for x in part) + ('\t; ' + why if i == 0 else ''), len(part)))
    return rows


def cut(stream, tokens, bounds):
    """Distribute tokens over cell payload ranges.  bounds = [(lo, hi)] per cell, in chain order,
    covering the stream.  Returns one list of (line, nbytes) per cell."""
    per = [[] for _ in bounds]

    def cell_of(x):
        for k, (lo, hi) in enumerate(bounds):
            if lo <= x < hi:
                return k
        raise ValueError(x)

    for (p, n, text, why) in tokens:
        if text in ('PAD', 'RAW'):
            q = p
            while q < p + n:
                k = cell_of(q)
                e = min(p + n, bounds[k][1])
                per[k] += raw_lines(stream[q:e], why)
                q = e
            continue
        k0, k1 = cell_of(p), cell_of(p + n - 1)
        if k0 == k1:
            per[k0].append(('\t' + text, n))
            continue
        q = p
        while q < p + n:
            k = cell_of(q)
            e = min(p + n, bounds[k][1])
            part = stream[q:e]
            where = 'first %d bytes of' % (e - q) if q == p else 'last %d bytes of' % (e - q)
            per[k].append(('\t.byte\t%s\t; %s %s (split by a cell boundary)' % (
                ', '.join('0x%02x' % x for x in part), where, text.replace('\t', ' ')), e - q))
            q = e
    return per
