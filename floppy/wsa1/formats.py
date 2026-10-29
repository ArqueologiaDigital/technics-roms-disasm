"""floppy/wsa1/formats.py -- the SX-WSA1R file-format describers (floppy/README.md).

The WSA1R's disk code (prom_a DiskLoad_ByContentType / DiskSave_ByContentType, wsa1/notes/
FINDINGS-prom_b-disk-and-file-menus.md) writes RAM images under fixed extensions; .MID files are
Standard MIDI Files written by prom_b's SMF writer (wsa1/notes/FINDINGS-prom_b-smf-writer.md).
"""
import os
import struct
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'tools', 'kd'))
import kd_describe  # noqa: E402

sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'kn5000'))
import events  # noqa: E402  (the KN5000 floppy tree's song tokenizer)

MODEL = 'wsa1'


def smf_length(d):
    """The length of the Standard MIDI File at the start of d: MThd, then its tracks' chunks."""
    if d[:4] != b'MThd':
        return None
    i = 8 + struct.unpack('>I', d[4:8])[0]
    ntrk = struct.unpack('>H', d[10:12])[0]
    for _ in range(ntrk):
        if d[i:i + 4] != b'MTrk':
            return None
        i += 8 + struct.unpack('>I', d[i + 4:i + 8])[0]
    return i if i <= len(d) else None


def describe_mid(ctx):
    n = smf_length(ctx.data)
    if n is None:
        return None
    kd_describe._reg(MODEL, ctx.disk)[1].append(
        '$(eval $(call KD_CUT,%s,%s,%s,smf.mid,0,%d))' % (MODEL, ctx.disk, ctx.extracted, n))
    L = ['; A Standard MIDI File (format %d, %d tracks, division %d), cut out as a .mid of its own.'
         % struct.unpack('>HHH', ctx.data[8:14]), '',
         '%s:\t.incbin\t"%s.smf.mid"' % (ctx.label, ctx.extracted)]
    if n < len(ctx.data):
        L += ['; The rest of the last 1024-byte output window.  The SMF writer flushes whole windows',
              '; (SmfOut_WindowsFlushed 0x126C counts them; the track length at 0xF7789A is computed from',
              '; it), so the file is a multiple of 1024 bytes and these bytes are what the window buffer',
              '; still held from earlier output.',
              '; census: opaque -- unknown-dump: stale SMF output-window bytes past the end of the file\'s last track',
              '\t.incbin\t"%s", 0x%x, %d' % (ctx.ref, ctx.offset + n, len(ctx.data) - n)]
    return L


def describe_seq(ctx):
    """SEQUENCER .SEQ: the song store's 256-byte blocks (DiskSave_Sequencer / SeqFile_WriteSeqCompacted,
    wsa1/notes/FINDINGS-prom_b-disk-and-file-menus.md), chains followed from blocks whose PREV is 0."""
    d = ctx.data
    if len(d) % 256 or not d:
        return None
    n = len(d) // 256
    cell = lambda c: (c - 1) * 256  # noqa: E731
    owner, plan = {}, {}
    for h in range(1, n + 1):
        if struct.unpack_from('<H', d, cell(h) + 1)[0] != 0 or not d[cell(h)] & 0x80:
            continue
        seq, c = [], h
        while 1 <= c <= n and c not in owner and c not in seq:
            seq.append(c)
            c = struct.unpack_from('<H', d, cell(c) + 3)[0]
        for k, cc in enumerate(seq):
            owner[cc] = (h, k, len(seq))
        stream = b''.join(d[cell(cc) + 5:cell(cc) + 256] for cc in seq)
        toks = events.tokenize_seq(stream)
        for cc, part in zip(seq, events.cut(stream, toks, [(251 * k, 251 * (k + 1)) for k in range(len(seq))])):
            plan[cc] = [line for line, _ in part]
    L = ['; SEQUENCER song blocks: the song store\'s heap of 256-byte blocks, written by DiskSave_Sequencer',
         '; (prom_b SeqFile_WriteSeqCompacted relinks each copied block: previous 0 at a chain\'s start, next',
         '; 0xFFFF at its end).  Each chain is one stream of events (macros: wsa1/include/wsa1_files.inc).', '',
         '\t.include\t"wsa1_files.inc"', ctx.label + ':']
    for c in range(1, n + 1):
        b = cell(c)
        prev, nxt = struct.unpack_from('<HH', d, b + 1)
        h = owner.get(c)
        L.append('\tseq_block\t0x%02x, %d, %s\t; block %d%s' % (d[b], prev, '0xffff' if nxt == 0xFFFF else nxt, c,
                 ': chain from block %d, %d of %d' % (h[0], h[1] + 1, h[2]) if h else ': in no chain'))
        body = d[b + 5:b + 256]
        if c in plan:
            L += plan[c]
        elif len(set(body)) == 1:
            L.append('\t.fill\t251, 1, 0x%02x' % body[0])
        else:
            L.append('\t; census: opaque -- unknown-dump: a block in no chain (left over in the heap)')
            L.append('\t.incbin\t"%s", 0x%x, 251' % (ctx.ref, ctx.offset + b + 5))
    return L


def describe(ctx):
    ext = ctx.path.rsplit('.', 1)[-1].upper()
    if ext == 'MID':
        return describe_mid(ctx)
    if ext == 'SEQ':
        return describe_seq(ctx)
    return None
