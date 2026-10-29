"""kn_sqt.py -- the payload describer of the KN6000 / KN7000 song files (.SQT, two parts).

QUESTION IT ANSWERS
  "Which bytes of a saved song are its events, and does every track's chain parse?"
  Part 1 is 1 or 10 song records (0x870 bytes on the KN6000, 0x8E0 on the KN7000), "ZZZZ" first.  The KN7000
  keeps them at 0x501A5800 + n*0x8E0 (Rec8E0TablePtr 0x48456E49, 11 entries) and the cells in its song
  memory, 0x4D8 pages of 0x100 bytes at 0x501AB9A0 (SongPageStorePtr 0x48456E8B; nine song-file sites pass it
  with length 0x4D800), kn7000_manual.sym.
  Each record's +0xD0 is a directory of 16 tracks, {flags (bit 7 = in use), u16le first cell}
  (the KN5000 layout: notes/feature-presentation-cues-2026-10-18.md, Q4).  Part 2 is the event memory:
  256-byte cells, +0 flags, +1 u16le previous cell, +3 u16le next cell (one-based; 0 / 0xFFFF = none),
  +5..+0xFF events.  A track's events are its chain's payloads, joined.

  THE EVENT LENGTHS ARE THE FIRMWARE'S (KN7000 program 941; traced 2026-10-18 in
  kn7000/notes/presentation-control-probes/song-records.md, section 2): the per-status length table
  0x485B9328 (256 signed bytes, -1 = not an event), read by func_4845BC5B; the player tick 0x484595F0 steps
  each track with 0x4845979E, which reads an event at 0x48459C98; classifier 0x48458705, encoder 0x484582D5.
  The lengths (status byte included): 0x80 3 (tempo b1 + (b2 << 7)), 0x81 1 (next beat), 0x82 1 (end of
  track), 0x84 1 (bar), 0x85 1 / 0x86 1 (rhythm start / stop), 0x8A 3 (PIC), 0x90-0x9F 5 (note, velocity,
  u16 duration; 0x98 = recorded from MIDI IN), 0xA1-0xA3 7-9 (part parameter: part, flags, id(3), value(n)),
  0xB0 4 (part, cc, value), 0xC0 4 (prog, bank LSB, bank MSB), 0xD0 2, 0xE0 3, 0xF1-0xF4 6-9 (global
  parameter: flags, id(3), value(n)).  A byte below 0x80 is the position in the beat (96 PPQN) before an
  event.  LENGTHS below is that table (minus the status byte).  The tick-before-every-ticked-event shape is
  still the disks' (every one of the 422 tracks on the 27 disks parses to 0x82 with it): the reader also
  accepts an event without a tick, which no disk holds.
  A chain that parses to 0x82 is typed event by event (sq_* macros, kn_song.inc); one that does not is left
  as the reference bytes of its cells, and the unit says where parsing stopped.
"""
import collections
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# data bytes after the status, from the length table 0x485B9328 (func_4845BC5B)
LENGTHS = {0x80: 2, 0x81: 0, 0x82: 0, 0x84: 0, 0x85: 0, 0x86: 0, 0x8A: 2, **{0x90 + n: 4 for n in range(16)},
           0xA1: 6, 0xA2: 7, 0xA3: 8, 0xB0: 3, 0xC0: 3, 0xD0: 1, 0xE0: 2, 0xF1: 5, 0xF2: 6, 0xF3: 7, 0xF4: 8}
UNTICKED = (0x81, 0x82)     # written without a tick on the disks
SYSTEM = (0x84, 0x85, 0x86, 0xF1, 0xF2, 0xF3, 0xF4)
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
            if st in LENGTHS and st not in UNTICKED and st not in SYSTEM:
                n = LENGTHS[st]
                d = s[i + 2:i + 2 + n]
                # a note's last byte and a bend's second byte can have bit 7 set (5 events on the disks, each the
                # track's last before 0x82; what that bit means is not traced); no other data byte ever does
                free = {0x90: 3, 0xE0: 1}.get(st & 0xF0)
                if len(d) < n or any(b & 0x80 for k, b in enumerate(d) if k != free):
                    return out, 'status 0x%02x at +%d: a data byte >= 0x80' % (st, i + 1)
                out.append((i, 2 + n, '\t%s\t%d, %d%s' % (MAC[st & 0xF0], x, st & 15, ''.join(', %d' % b for b in d))))
                i += 2 + n
            elif st in SYSTEM:
                n = LENGTHS[st]
                d = s[i + 2:i + 2 + n]
                if len(d) < n or any(b & 0x80 for b in d):
                    return out, 'status 0x%02x at +%d: a data byte >= 0x80' % (st, i + 1)
                out.append((i, 2 + n, '\tsq_sys\t%d, 0x%02x%s' % (x, st, ''.join(', %d' % b for b in d))))
                i += 2 + n
            else:
                return out, 'status 0x%02x after a tick at +%d is not a song event (table 0x485B9328)' % (st, i + 1)
        else:
            return out, 'status 0x%02x at +%d without a tick' % (x, i)
    return out, 'the chain ends before 0x82'


def rows(b, w=16):
    return ['\t.byte\t' + ', '.join(str(x) for x in b[k:k + w]) for k in range(0, len(b), w)]


# The song record's length by its model signature (+5, +6): KN6000 01 0A, KN7000 01 0D (the disks), and
# 01 0E, the SX-KN2400 / KN2600's 8 built-in demo songs (measured in its program image, v1.1: 0x8E0 bytes, the
# panel memory at +0x140 parses as on the KN7000).
RECORD_LEN = {b'\x01\x0a': 0x870, b'\x01\x0d': 0x8E0, b'\x01\x0e': 0x8E0}


def typer1(ctx, part, p, ref, lab):
    """Part 1: the song records.  +0x00 "ZZZZ", +0x04 the 10-song flag, +0x05 the model signature,
    +0x09 the file stem (as the KN5000 slot's +0x09, floppy/kn5000 sqt_slot_header.json), +0xD0 the track
    directory, +0x120.. the song's settings bank (the M3 "Sqf" bank: an image of backup SRAM 0x84000000..; lib
    func_4C01F153 mode bit 0 adds block - 0x84000000 to Rec8E0Field120Ptr(0)), whose +0x140 is the song's panel
    memory (the image of the live record 0x84000020; 42 / 43 records; measured: all 605 records of the 27 disks)
    and whose tail is block 0x52 (KN6000: 46 bytes, the record's end; KN7000: 40, then the images of blocks
    0x50, 0x51 and the start of 0x60, without their tag bytes).  The other bytes are not traced and are spelled
    as bytes with their offsets."""
    import kn_panel
    rl = RECORD_LEN.get(p[5:7])
    if part != 1 or p[:4] != b'ZZZZ' or not rl or len(p) % rl:
        return None
    L = ['\t.include\t"kn_song.inc"', '\t.include\t"panel_memory.inc"', '',
         '; %d song record(s) of 0x%x bytes.' % (len(p) // rl, rl), lab + ':']
    for s in range(len(p) // rl):
        r = p[s * rl:(s + 1) * rl]
        recs, e = kn_panel.block(r, 0x140)
        if recs is None:
            return None
        L += ['', '%s_Song%d:' % (lab, s + 1),
              '\t.ascii\t"ZZZZ"', '\t.byte\t%d, 0x%02x, 0x%02x\t; +4: 1 = a 10-song file; +5: the model signature'
              % (r[4], r[5], r[6]), '; +0x07..+0xCF, not traced'] + rows(r[7:0xD0])
        for t in range(16):
            e3 = 0xD0 + 3 * t
            L.append('\tsq_track\t0x%02x, %d\t; track %d' % (r[e3], u16(r, e3 + 1), t + 1))
        L += ['; +0x100..+0x11F, not traced'] + rows(r[0x100:0x120])
        L += ['; +0x120..+0x8DF / +0x86F: the song\'s settings bank, an image of backup SRAM 0x84000000 + (offset - 0x120):',
              '; GetM3Sqf / PutM3Sqf (kind 1) address a parameter at Rec8E0Field120Ptr(0) + (block - 0x84000000)',
              '; (lib func_4C01F153 / func_4C01F200, mode bit 0; KN7000).  +0x120..+0x13F mirror 0x84000000..0x8400001F,',
              '; which no parameter record covers'] + rows(r[0x120:0x140])
        L += kn_panel.block_lines(r, recs, 'the song\'s panel memory (+0x140, the image of the live record 0x84000020)')
        tail = r[e:]
        if len(tail) >= 2 and tail[0] == 0x52 and (0x52, tail[1]) in kn_panel.OTHER and len(tail) >= 2 + tail[1]:
            n52 = 2 + tail[1]
            L += ['; +0x%X: the image of 0x%08X, block 0x52 (as a panel record)' % (e, 0x84000000 + e - 0x120),
                  '\tPMR_52_%d\t%s' % (tail[1], ', '.join(str(x) for x in tail[2:n52]))]
            if len(tail) > n52:
                L += ['; +0x%X..+0x%X: the image of 0x%08X.. (blocks 0x50 at +0x%X, 0x51 at +0x%X, 0x60 at +0x%X on the KN7000;'
                      % (e + n52, rl - 1, 0x84000000 + e + n52 - 0x120, 0x79C + 0x120, 0x7A6 + 0x120, 0x7B6 + 0x120),
                      '; payload offsets, from the block table 0x4858D44C), whose tag / length bytes the song copy does',
                      '; not keep (measured)'] + rows(tail[n52:])
        else:
            L += ['; +0x%X..+0x%X, not traced' % (e, rl - 1)] + rows(tail)
    return L


def typer2(ctx, part, p2, ref, lab, p1):
    """Part 2: the event cells; p1 is part 1 (for the track directories)."""
    rl = RECORD_LEN.get(p1[5:7])
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
