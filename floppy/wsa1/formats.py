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


def describe(ctx):
    ext = ctx.path.rsplit('.', 1)[-1].upper()
    if ext == 'MID':
        return describe_mid(ctx)
    return None
