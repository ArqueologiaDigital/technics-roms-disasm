"""kn_sqt.py -- the payload describer of the KN6000 / KN7000 song files (.SQT, two parts).

QUESTION IT ANSWERS
  "Which bytes of a saved song are its events, and does every track's chain parse?"
  Part 1 is 1 or 10 song records (0x870 bytes on the KN6000, 0x8E0 on the KN7000), "ZZZZ" first.
  Each record's +0xD0 is a directory of 16 tracks, {flags (bit 7 = in use), u16le first cell}
  (the KN5000 layout: notes/feature-presentation-cues-2026-10-18.md, Q4).  Part 2 is the event memory:
  256-byte cells, +0 flags, +1 u16le previous cell, +3 u16le next cell (one-based; 0 / 0xFFFF = none),
  +5..+0xFF events.  A track's events are its chain's payloads, joined.

  THE EVENT GRAMMAR IS MEASURED, NOT TRACED (no KN6000/KN7000 song reader is named yet).
  [INFERENCE] from the byte statistics of every chain on the 27 disks (probes/README.md, sqt_grammar):
    tick status data...   a byte < 0x80 (the tick in the beat) precedes every channel event:
                          0x9n note +4, 0xAn +6, 0xBn controller +3, 0xCn program +3, 0xDn +1, 0xEn bend +2,
                          0x8n +2, and the system events 0xF1 +5, 0xF2 +6, 0xF3 +7, 0x85 +0, 0x86 +0
    0x81                  beat marker (no tick)
    0x82                  end of track (no tick)
  A chain that parses to 0x82 under these lengths is typed event by event (sq_* macros, kn_song.inc);
  one that does not is left as the reference bytes of its cells, and the unit says where parsing stopped.
"""
import collections
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

TICKED = {0x80: 2, 0x90: 4, 0xA0: 6, 0xB0: 3, 0xC0: 3, 0xD0: 1, 0xE0: 2}
SYSTEM = {0xF1: 5, 0xF2: 6, 0xF3: 7, 0x85: 0, 0x86: 0}
MAC = {0x80: 'sq_8n', 0x90: 'sq_note', 0xA0: 'sq_a', 0xB0: 'sq_cc', 0xC0: 'sq_pc', 0xD0: 'sq_press', 0xE0: 'sq_bend'}


def u16(p, o):
    return p[o] | p[o + 1] << 8


def tokens(s):
    """[(offset, length, line)] up to and including 0x82, or (tokens, stop reason) when it fails."""
    out, i = [], 0
    while i < len(s):
        x = s[i]
        if x == 0x81:
            out.append((i, 1, '\tsq_beat'))
            i += 1
        elif x == 0x82:
            out.append((i, 1, '\tsq_end'))
            return out, None
        elif x < 0x80:
            if i + 1 >= len(s):
                return out, 'a tick at the end of the chain'
            st = s[i + 1]
            if st & 0xF0 in TICKED and st < 0xF0 and st not in (0x81, 0x82, 0x85, 0x86):
                n = TICKED[st & 0xF0]
                d = s[i + 2:i + 2 + n]
                if len(d) < n or any(b & 0x80 for b in d):
                    return out, 'status 0x%02x at +%d: a data byte >= 0x80' % (st, i + 1)
                out.append((i, 2 + n, '\t%s\t%d, %d%s' % (MAC[st & 0xF0], x, st & 15, ''.join(', %d' % b for b in d))))
                i += 2 + n
            elif st in SYSTEM:
                n = SYSTEM[st]
                d = s[i + 2:i + 2 + n]
                if len(d) < n or any(b & 0x80 for b in d):
                    return out, 'status 0x%02x at +%d: a data byte >= 0x80' % (st, i + 1)
                out.append((i, 2 + n, '\tsq_sys\t%d, 0x%02x%s' % (x, st, ''.join(', %d' % b for b in d))))
                i += 2 + n
            else:
                return out, 'status 0x%02x after a tick at +%d has no measured length' % (st, i + 1)
        else:
            return out, 'status 0x%02x at +%d without a tick' % (x, i)
    return out, 'the chain ends before 0x82'


def typer1(ctx, part, p, ref, lab):
    """Part 1: the song records."""
    rl = {b'\x01\x0a': 0x870, b'\x01\x0d': 0x8E0}.get(p[5:7])
    if part != 1 or p[:4] != b'ZZZZ' or not rl or len(p) % rl:
        return None
    L = ['\t.include\t"kn_song.inc"', '',
         '; %d song record(s) of 0x%x bytes; +0xD0 is the track directory, the rest is not decoded.' % (len(p) // rl, rl),
         lab + ':']
    for s in range(len(p) // rl):
        r = s * rl
        L += ['', '%s_Song%d:' % (lab, s + 1),
              '\t.ascii\t"ZZZZ"', '\t.byte\t%d, 0x%02x, 0x%02x\t; +4: 1 = a 10-song file; +5: the model signature'
              % (p[r + 4], p[r + 5], p[r + 6]),
              '\t.incbin\t"%s", 0x%x, %d\t; record +0x07..+0xCF, fields not established' % (ref, r + 7, 0xD0 - 7)]
        for t in range(16):
            e = r + 0xD0 + 3 * t
            L.append('\tsq_track\t0x%02x, %d\t; track %d' % (p[e], u16(p, e + 1), t + 1))
        L.append('\t.incbin\t"%s", 0x%x, %d\t; record +0x100..+0x%X, fields not established' % (ref, r + 0x100, rl - 0x100, rl - 1))
    return L


def typer2(ctx, part, p2, ref, lab, p1):
    """Part 2: the event cells; p1 is part 1 (for the track directories)."""
    rl = {b'\x01\x0a': 0x870, b'\x01\x0d': 0x8E0}.get(p1[5:7])
    if part != 2 or not rl or len(p2) % 256:
        return None
    n = len(p2) // 256
    owner = {}
    plan = {}       # cell -> list of lines
    status = []
    for s in range(len(p1) // rl):
        for t in range(16):
            e = s * rl + 0xD0 + 3 * t
            fl, c = p1[e], u16(p1, e + 1)
            if not fl & 0x80 or c in (0, 0xFFFF):
                continue
            cells = []
            while 1 <= c <= n and c not in owner and c not in cells:
                cells.append(c)
                c = u16(p2, (c - 1) * 256 + 3)
            for k, cc in enumerate(cells):
                owner[cc] = (s, t, k, len(cells))
            stream = b''.join(p2[(cc - 1) * 256 + 5:cc * 256] for cc in cells)
            toks, why = tokens(stream)
            if why:
                status.append('song %d track %d (%d cells from %d): not typed, %s' % (s + 1, t + 1, len(cells), cells[0] if cells else 0, why))
                continue
            end = toks[-1][0] + toks[-1][1]
            for k, cc in enumerate(cells):
                lo, hi = 251 * k, 251 * (k + 1)
                lines = []
                for (o, m, line) in toks:
                    a, b = max(o, lo), min(o + m, hi)
                    if a >= b:
                        continue
                    if a == o and b == o + m:
                        lines.append(line)
                    else:
                        part_bytes = stream[a:b]
                        lines.append('\t.byte\t%s\t; bytes %d..%d of `%s` (the event spans two cells)'
                                     % (', '.join('0x%02x' % x for x in part_bytes), a - o + 1, b - o, line.strip()))
                if end < hi:
                    rest = stream[max(end, lo):hi]
                    if rest:
                        if len(set(rest)) == 1:
                            lines.append('\t.fill\t%d, 1, 0x%02x\t; after the end of track' % (len(rest), rest[0]))
                        else:
                            lines.append('\t; census: opaque -- unknown-dump: cell bytes after the end of track (left over)')
                            lines.append('\t.incbin\t"%s", 0x%x, %d' % (ref, (cc - 1) * 256 + 5 + (max(end, lo) - lo), len(rest)))
                plan[cc] = lines
    L = ['\t.include\t"kn_song.inc"', '',
         '; %d cells of 256 bytes.  Tracks typed event by event: %d of %d.'
         % (n, len({owner[c][:2] for c in plan}), len({v[:2] for v in owner.values()}))]
    L += ['; ' + x for x in status]
    L.append(lab + ':')
    for c in range(1, n + 1):
        b = (c - 1) * 256
        hdr = '\tsq_cell\t0x%02x, %d, %d' % (p2[b], u16(p2, b + 1), u16(p2, b + 3))
        if c in owner:
            s, t, k, m = owner[c]
            hdr += '\t; cell %d: song %d track %d, %d of %d' % (c, s + 1, t + 1, k + 1, m)
        else:
            hdr += '\t; cell %d: in no track\'s chain' % c
        L.append(hdr)
        body = p2[b + 5:b + 256]
        if c in plan:
            L += plan[c]
        elif len(set(body)) == 1:
            L.append('\t.fill\t251, 1, 0x%02x' % body[0])
        elif c in owner:
            L.append('\t.incbin\t"%s", 0x%x, 251\t; events of a track not typed (see above)' % (ref, b + 5))
        else:
            L.append('\t; census: opaque -- unknown-dump: a free cell: bytes left from an earlier song')
            L.append('\t.incbin\t"%s", 0x%x, 251' % (ref, b + 5))
    return L


_P1 = {}


def typer(ctx, part, p, ref, lab):
    if part == 1:
        _P1[ctx.path] = p
        return typer1(ctx, part, p, ref, lab)
    return typer2(ctx, part, p, ref, lab, _P1.get(ctx.path, b''))
