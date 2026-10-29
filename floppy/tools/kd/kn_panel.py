"""kn_panel.py -- the payload describer of the KN6000 / KN7000 panel-memory files (.PMT, .LSW part 1).

QUESTION IT ANSWERS
  "How are the saved panel memories laid out?"  Measured on the 27 disks (probes/pmt_banks.py in
  notes/floppy-others-2026-10-29); no KN6000 / KN7000 routine that reads them is traced yet ([INFERENCE]).
    .PMT   +0x00 'IK \\0' / 'JK \\0', +0x04 8 zero bytes, +0x0C a model byte (0 KN6000, 0x50 KN7000),
           +0x0D 7, +0x0E u16le the memory count (24; 104 in organs); then per bank of 8 memories its
           16-character name and its 8 memories.  All 72 files tile exactly that way.
    .LSW   part 1: 'ZZ' 00 00, the same signature, zeros to +0x20, then two record lists: the panel
           (tags 0x00-0x4D, as a memory) and a second block (tags 0x60-0x98).
  A memory is a list of tag/length records ended by FF FF (the KN5000 PanelTlv shape): 42 records on the
  KN6000, 43 on the KN7000 (1,808 memories, no exception).  Record payloads other than the name are spelled
  as bytes: their fields are not traced.
"""


def rows(b, w=24):
    return ['\t.byte\t' + ', '.join(str(x) for x in b[k:k + w]) for k in range(0, len(b), w)]


def s_esc(b):
    return '"' + ''.join(chr(c) if 0x20 <= c < 0x7F and c not in (0x22, 0x5C) else '\\%03o' % c for c in b) + '"'


def block(p, o):
    """The records of the tag/length list at o: ([(offset, tag, len)], offset after FF FF) or (None, None)."""
    recs, q = [], o
    while q + 2 <= len(p):
        t, n = p[q], p[q + 1]
        if t == 0xFF and n == 0xFF:
            return recs, q + 2
        if q + 2 + n > len(p):
            return None, None
        recs.append((q, t, n))
        q += 2 + n
    return None, None


import gen_panel_macros  # noqa: E402

PARTS = set(range(0x13)) | {0x1B, 0x1C, 0x1F}
OTHER = set(gen_panel_macros.OTHER)


def block_lines(p, recs, what):
    """One PMR_* line per record (kn7000/src/include/panel_memory.inc, shared with the CUSTOM banks)."""
    L = ['; %s: %d records' % (what, len(recs))]
    for q, t, n in recs:
        pay = p[q + 2:q + 2 + n]
        v = ', '.join(str(x) for x in pay)
        if t == 0x40 and n == 18:
            L += ['\tPMR_NAME_HEAD', '\t.ascii\t%s' % s_esc(pay[:16]), '\tPMR_NAME_TAIL\t%d, %d' % (pay[16], pay[17])]
        elif t in PARTS and n == 72:
            L.append('\tPMR_PART\t0x%02x, %s' % (t, v))
        elif 0x13 <= t <= 0x1A and n == 4:
            L.append('\tPMR_ENTRY\t0x%02x, %s' % (t, v))
        elif (t, n) in OTHER:
            L.append('\tPMR_%02X_%d\t%s' % (t, n, v))
        else:
            L.append('\tkp_tlv\t0x%02x, %d' % (t, n))
            L += rows(pay)
    L.append('\tPMR_END')
    return L


def pmt(ctx, part, p, ref, lab):
    if part != 1 or len(p) < 0x40 or p[1:4] != b'K \0':
        return None
    n = p[0x0E] | p[0x0F] << 8
    L = ['\t.include\t"kn_panel.inc"', '\t.include\t"panel_memory.inc"', '', lab + ':',
         '\t.ascii\t%s\t; signature' % s_esc(p[:4]), '\t.byte\t' + ', '.join(str(x) for x in p[4:12]),
         '\t.byte\t0x%02x, %d\t; model byte, 7' % (p[12], p[13]), '\t.short\t%d\t; memories' % n]
    o, k = 0x10, 0
    while o < len(p):
        if o + 16 > len(p):
            return None
        L.append('\t.ascii\t%s\t; bank %d name' % (s_esc(p[o:o + 16]), k // 8 + 1))
        o += 16
        for j in range(8):
            recs, e = block(p, o)
            if recs is None:
                return None
            L.append('%s_M%d_%d:' % (lab, k // 8 + 1, j + 1))
            L += block_lines(p, recs, 'bank %d memory %d' % (k // 8 + 1, j + 1))
            o, k = e, k + 1
    return L if k == n else None


def lsw1(ctx, part, p, ref, lab):
    if part != 1 or p[:4] != b'ZZ\0\0' or p[5:8] != b'K \0' or any(p[8:0x20]):
        return None
    r0, e0 = block(p, 0x20)
    r1, e1 = block(p, e0) if r0 is not None else (None, None)
    if r1 is None or e1 != len(p):
        return None
    return (['\t.include\t"kn_panel.inc"', '\t.include\t"panel_memory.inc"', '', lab + ':', '\t.ascii\t"ZZ"', '\t.byte\t0, 0',
             '\t.ascii\t%s\t; the panel-memory signature' % s_esc(p[4:8]), '\t.fill\t24, 1, 0']
            + block_lines(p, r0, 'the current panel') + block_lines(p, r1, 'the second block'))
