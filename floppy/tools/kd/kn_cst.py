"""kn_cst.py -- the payload describer of the KN7000 custom-style files (.CST).

A .CST payload is one CUSTOM slot record, byte for byte the record a CUSTOM bank holds (the u32 size at +0
is the payload size; kn7000/notes/custom-data-ic21.md, "The slot record").  It is typed by lane customdata's
own record emitter, kn7000/tools/gen_customdata_s.py gen_record(), so the two trees spell the record with one
macro set (src/customdata/customdata.inc, src/include/panel_memory.inc, src/include/voice_record.inc); the
payload source is therefore kn7asm syntax and is assembled by kn7asm (kd.mk KD_PART7).
"""
import os
import sys

KN7000 = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))), 'kn7000')
sys.path.insert(0, os.path.join(KN7000, 'tools'))


def typer(ctx, part, p, ref, lab):
    import gen_customdata_s as g
    if part != 1 or int.from_bytes(p[0:4], 'little') != len(p):
        return None
    model = 'kn7000' if ctx.data[:1] == b'J' else 'kn6000'
    o = g.Out(ref, p)
    try:
        g.gen_record(o, p, 0, lab, model, '%d, %d' % (p[0xA4], p[0xA5]), None,
                     '%s: a custom-style record (gen_customdata_s.gen_record)' % ctx.path)
    except (SystemExit, ValueError) as e:
        sys.stderr.write('kn_cst: %s: %s; left generic\n' % (ctx.path, e))
        return None
    if o.pos != len(p):
        return None
    return ('kn7asm', ['.include "src/customdata/customdata.inc"', '.include "src/include/panel_memory.inc"',
                       '.include "src/include/voice_record.inc"'] + o.lines)
