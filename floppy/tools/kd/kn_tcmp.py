"""kn_tcmp.py -- the payload describer of the KN6000 / KN7000 style files (.CMP): the "TCMP" container.

QUESTION IT ANSWERS
  "Is every byte of a saved style a field the firmware reads?"  It types the header, the style and
  variation records and every event of every stream, one event per line (macros: floppy/tools/kn_style.inc,
  whose header cites the KN7000 routines that read each field).  Each heap object (one variation's
  stream) is its own include file, payload/<unit>.p1.vNN.s, in heap order.  The generator refuses a
  payload whose structure is not exactly the documented one: header fields, record strides, heap tiling,
  stream ownership, F4 first / F5 last and every event length.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import kd_describe  # noqa: E402

GEN = 'floppy/tools/kd/kn_tcmp.py'
SLOT = ['Var1', 'Var1Fill1', 'Var1Fill2', 'Var2', 'Var2Fill1', 'Var2Fill2', 'Var3', 'Var3Fill1', 'Var3Fill2',
        'Var4', 'Var4Fill1', 'Var4Fill2',
        # slots 12..19: INTRO 1 = 12 + major/minor, ENDING 1 = 14, INTRO 2 = 16, ENDING 2 = 18 (program 941
        # func_484437DA / func_484439EB, the half by ChordTypeIsMinor: kn7000/notes/ic18-rhythm-rom.md)
        'Intro1Major', 'Intro1Minor', 'Ending1Major', 'Ending1Minor',
        'Intro2Major', 'Intro2Minor', 'Ending2Major', 'Ending2Minor']


class Bad(Exception):
    pass


def u16(p, o):
    return p[o] << 8 | p[o + 1]


def u24(p, o):
    return p[o] << 16 | p[o + 1] << 8 | p[o + 2]


def ev_len(d, o):
    """RhyEventLenByStatus / RhySysexLen (KN7000 program 941 0x484403D5 / 0x484403CD)."""
    s = d[o]
    if s == 0xF0:
        return d[o + 1] + 2
    return {0x90: 6, 0xB0: 3, 0xC0: 4, 0xD0: 2, 0xE0: 3}.get(s & 0xF0, 1)


def event_lines(d, s, e):
    out = []
    o = s
    while o < e:
        c = d[o]
        n = ev_len(d, o)
        a = d[o + 1:o + n]
        h, part = c & 0xF0, c & 15
        if c == 0xF4:
            out.append('\tev_beat')
        elif c == 0xF5:
            out.append('\tev_end')
        elif c == 0xF0:
            out.append('\tev_sysex\t%d%s' % (a[0], ''.join(', 0x%02x' % x for x in a[1:])))
        elif c < 0x80:
            out.append('\tev_at\t%d' % c)
        elif h == 0x90:
            out.append('\tev_note\t%d, %d, %d, %d, %d, %d' % ((part,) + tuple(a)))
        elif h == 0xB0:
            out.append('\tev_cc\t%d, %d, %d' % ((part,) + tuple(a)))
        elif h == 0xC0:
            out.append('\tev_pc\t%d, 0x%02x, 0x%02x, 0x%02x' % ((part,) + tuple(a)))
        elif h == 0xD0:
            out.append('\tev_press\t%d, %d' % (part, a[0]))
        elif h == 0xE0:
            out.append('\tev_bend\t%d, %d, %d' % ((part,) + tuple(a)))
        else:
            out.append('\tev_byte\t0x%02x' % c)
        o += n
    if o != e:
        raise Bad('events overrun the stream end')
    return out


def s_name(b):
    return '"' + ''.join(chr(c) if 0x20 <= c < 0x7F and c not in (0x22, 0x5C) else '\\%03o' % c for c in b) + '"'


def name_line(p, o):
    pad = p[o + 13]
    if p[o + 14] or p[o + 15]:
        raise Bad('name field tail not 00 00')
    return '\ttcmp_name\t%s%s' % (s_name(p[o:o + 13]), ', %d' % pad if pad else '')


def hb(bs):
    return ', '.join('0x%02x' % x for x in bs)


def typer(ctx, part, p, ref, lab):
    if part != 1 or p[:6] != b'TCMP\0\0':
        return None
    try:
        return describe(ctx, p, lab)
    except (Bad, IndexError, KeyError) as e:
        sys.stderr.write('kn_tcmp: %s: %s; left generic\n' % (ctx.path, e))
        return None


def describe(ctx, p, lab):
    n = u16(p, 0x16)
    top = u24(p, 0x13)
    recs = 0x70 + n * 0x80
    heap = recs + n * 20 * 0xE0
    if top != len(p) or u24(p, 0x08) != 0x70 or u24(p, 0x0B) * 2 != heap - 0x70:
        raise Bad('header fields')
    # the heap: one object per variation, tiling heap..top
    objs = []
    o = heap
    while o < top:
        v, L = p[o], u24(p, o + 1)
        if p[o + 4] != 0xF4 or p[o + 4 + L - 1] != 0xF5:
            raise Bad('stream at 0x%x does not open F4 / close F5' % o)
        objs.append((o, v, o + 4 + L))
        o += 4 + L
    if o != top or sorted(v for _, v, _ in objs) != list(range(n * 20)):
        raise Bad('heap does not tile, or variations not each owning one stream')
    at = {s: v for s, v, _ in objs}
    sl = lambda v: '%s_S%02d' % (lab, v)  # noqa: E731
    csum = sum(u16(p, k) for k in range(0x70, heap, 2)) & 0xFFFF
    L = ['\t.include\t"kn_style.inc"', '',
         '; The "TCMP" style container (floppy/tools/kn_style.inc): %d styles, %d variations, a heap of %d streams.'
         % (n, n * 20, len(objs)),
         '; Checksum: SumU16BE of the record block = 0x%04x, the stored value %s.'
         % (csum, 'matches' if csum == u16(p, 6) else 'is 0x%04x (stale)' % u16(p, 6)),
         lab + ':',
         '\ttcmp_head\t%s, 0x%04x, 0x%x, 0x%x, 0x%04x, 0x%x, %s_Top, %d'
         % (lab, u16(p, 6), u24(p, 8), u24(p, 0x0B), u16(p, 0x0E), u24(p, 0x10), lab, n),
         '\t.byte\t%s\t; the fixed tail of the ROM template (MemStyleAreaHeaderRestamp)' % hb(p[0x18:0x30])]
    if p[0x30:0x70] == b' ' * 0x40:
        L.append('\t.fill\t0x40, 1, 0x20\t\t; padding, +0x30..+0x6F')
    else:
        raise Bad('header padding')
    for st in range(n):
        r = 0x70 + st * 0x80
        idx = p[r + 0x50:r + 0x64]
        L += ['', '%s_Style%d:' % (lab, st), name_line(p, r)]
        for k in range(4):
            L.append(name_line(p, r + 0x10 + 0x10 * k) + '\t; variation %d' % (k + 1))
        L.append('\t.byte\t%s\t; the variations it owns (MemStyleRecInit: 0..19 + style*20)' % hb(idx))
        L.append('\t.byte\t%s\t; +0x64..+0x6F, not read' % hb(p[r + 0x64:r + 0x70]))
        L.append('\t.short\t0x%04x, 0x%04x\t; +0x70, two little-endian u16 (template 0x0010, 0x0023; not traced)'
                 % (p[r + 0x70] | p[r + 0x71] << 8, p[r + 0x72] | p[r + 0x73] << 8))
        L.append('\t.byte\t%s\t; +0x74..+0x7F, not read' % hb(p[r + 0x74:r + 0x80]))
    for v in range(n * 20):
        r = recs + v * 0xE0
        so = u24(p, r + 0x15)
        if so not in at:
            raise Bad('variation %d: stream offset 0x%x is no heap object' % (v, so))
        b = p[r:r + 0x20]
        L += ['', '%s_Var%02d:\t\t; style %d, %s' % (lab, v, v // 20, SLOT[v % 20]),
              '\ttcmp_var\t%s, 0x%02x, 0x%02x, 0x%02x, 0x%02x, %s, %s, %d, 0x%02x, %s, %s, %s'
              % (lab, b[0], b[1], b[2], b[3], hb(b[4:12]), hb(b[12:16]), b[16] + 1, b[17], hb(b[18:21]),
                 sl(at[so]), hb(b[24:32]))]
        for k in range(8):
            q = p[r + 0x20 + 0x18 * k:r + 0x38 + 0x18 * k]
            L.append('\ttcmp_part\t' + ', '.join(str(x) for x in q))
    L.append('')
    for s, v, e in objs:
        name = '%s.p1.v%02d.s' % (ctx.unit, v)
        ev = event_lines(p, s + 4, e)
        beats = ev.count('\tev_beat')
        r = recs + v * 0xE0
        want = (p[r + 0x10] + 1) * ((p[r + 0x11] & 7) + 1)
        text = ['; Generated by %s from %s; regenerate rather than edit (floppy/README.md).' % (GEN, ctx.ref),
                '; %s: the event stream of variation %d (style %d, %s): %d bars of %d beats, %d beat markers%s.'
                % (ctx.path, v, v // 20, SLOT[v % 20], p[r + 0x10] + 1, (p[r + 0x11] & 7) + 1, beats,
                   '' if beats == want else ' (MemStyleVarBarCount wants %d)' % want), '',
                '%s:\ttcmp_stream\t%d, %s_Ev, %s_End' % (sl(v), v, sl(v), sl(v)),
                '%s_Ev:' % sl(v)] + ev + ['%s_End:' % sl(v)]
        kd_describe.extra_file(name, '\n'.join(text) + '\n')
        L.append('\t.include\t"%s"' % name)
    L.append('%s_Top:' % lab)
    return L
