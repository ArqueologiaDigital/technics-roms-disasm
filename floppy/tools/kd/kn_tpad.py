"""kn_tpad.py -- the payload describer of the KN7000 pad files (.MSP): the "TPAD" container.

Measured on the 10 .MSP files of ca7001 (all of them):
  +0x00  the TCMP-shaped header with "TPAD" (tpad_head): checksum, its descriptor (start 0xD0, 0x3A8
         halfwords: it recomputes equal), length, allocator top, the bank count 3, the template tail, spaces
  +0x70  two 0x30-byte records named "Compile Bank n": a name and six triples, not traced
  +0xD0  3 bank records of 0x30: name, six pad references {bank, pad, 0x10}, 14 zero bytes
  +0x160 18 pad records of 0x60 (tpad_pad; lane customdata's TPAD_PAD layout)
  +0x820 the heap: one stream per pad, [pad index, u24BE length, events] (kn_style.inc ev_*), tiling to the top
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import kn_tcmp  # noqa: E402

u16, u24, s_name, hb = kn_tcmp.u16, kn_tcmp.u24, kn_tcmp.s_name, kn_tcmp.hb


def triples(b):
    return ['\ttpad_ref\t%d, %d, 0x%02x' % (b[k], b[k + 1], b[k + 2]) for k in range(0, len(b), 3)]


def typer(ctx, part, p, ref, lab):
    if part != 1 or p[:6] != b'TPAD\0\0':
        return None
    nb, top = u16(p, 0x16), u24(p, 0x13)
    banks, pads = 0xD0, 0xD0 + 0x30 * nb
    heap = pads + 0x60 * 6 * nb
    if top != len(p) or u24(p, 8) != banks or u24(p, 0x0B) * 2 != heap - banks or p[0x30:0x70] != b' ' * 64:
        return None
    objs, o = [], heap
    while o < top:
        objs.append((o, p[o], o + 4 + u24(p, o + 1)))
        o = objs[-1][2]
    if o != top:
        return None
    at = {s: v for s, v, _ in objs}
    sl = lambda v: '%s_S%02d' % (lab, v)  # noqa: E731
    L = ['\t.include\t"kn_style.inc"', '', lab + ':',
         '\ttpad_head\t%s, 0x%04x, 0x%x, 0x%x, 0x%04x, 0x%x, %s_Top, %d'
         % (lab, u16(p, 6), u24(p, 8), u24(p, 0x0B), u16(p, 0x0E), u24(p, 0x10), lab, nb),
         '\t.byte\t%s' % hb(p[0x18:0x30]), '\t.fill\t0x40, 1, 0x20']
    for k in range(2):
        r = p[0x70 + 0x30 * k:0xA0 + 0x30 * k]
        L += ['; "Compile Bank" record %d (not traced)' % (k + 1), '\t.ascii\t%s' % s_name(r[:16])] + triples(r[16:34])
        L.append('\t.byte\t%s' % hb(r[34:48]))
    for b in range(nb):
        r = p[banks + 0x30 * b:banks + 0x30 * (b + 1)]
        L += ['%s_Bank%d:' % (lab, b + 1), '\t.ascii\t%s' % s_name(r[:16])] + triples(r[16:34])
        L.append('\t.byte\t%s' % hb(r[34:48]))
    for k in range(6 * nb):
        r = p[pads + 0x60 * k:pads + 0x60 * (k + 1)]
        so = u24(r, 0x1D)
        if so not in at or any(r[0x20:0x28]):
            return None
        L += ['%s_Pad%02d:' % (lab, k), '\t.ascii\t%s' % s_name(r[:16]),
              '\ttpad_pad\t%s, %s, %s' % (lab, hb(r[0x10:0x1D]), sl(at[so]))]
        for j in range(2):
            L.append('\ttcmp_part\t' + ', '.join(str(x) for x in r[0x28 + 0x18 * j:0x40 + 0x18 * j]))
        L.append('\t.byte\t%s' % hb(r[0x58:0x60]))
    for s, v, e in objs:
        L += ['%s:\ttcmp_stream\t%d, %s_Ev, %s_End' % (sl(v), v, sl(v), sl(v)), '%s_Ev:' % sl(v)]
        L += kn_tcmp.event_lines(p, s + 4, e)
        L.append('%s_End:' % sl(v))
    L.append('%s_Top:' % lab)
    return L
