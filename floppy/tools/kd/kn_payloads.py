"""kn_payloads.py -- what the KN6000 / KN7000 disk files hold, inflated: one payload describer per kind.

TYPERS maps an extension to typer(ctx, part, payload, refname, label) -> source lines | None (None: the
payload stays one generic .incbin of the reference payload).  note(ctx, ext) is the comment put on the unit.
"""

KIND = {
    'CMP': 'a style ("TCMP" container: style records, variation records, event streams)',
    'MSP': 'a music-stylist pad set ("TPAD" container)',
    'PMT': 'a panel-memory bank (registrations)',
    'LSW': 'one-touch / panel settings, two parts',
    'SQT': 'a composer song, two parts (song records, then the 256-byte event cells)',
    'TM': 'a sound (tone) edit file',
    'EFC': 'an effect (DSP) settings file',
    'CST': 'a custom style',
}

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import kn_tcmp  # noqa: E402
import kn_sqt  # noqa: E402
import kn_panel  # noqa: E402
import kn_soundram  # noqa: E402
import kn_cst  # noqa: E402
import kn_tpad  # noqa: E402



def _lsw(ctx, part, p, ref, lab):
    return kn_panel.lsw1(ctx, part, p, ref, lab) if part == 1 else kn_panel.lsw2(ctx, part, p, ref, lab)


TYPERS = {'CMP': kn_tcmp.typer, 'SQT': kn_sqt.typer, 'PMT': kn_panel.pmt, 'LSW': _lsw, 'TM': kn_soundram.typer, 'CST': kn_cst.typer, 'MSP': kn_tpad.typer}


def note(ctx, ext):
    k = KIND.get(ext)
    return ['%s: %s.' % (ctx.path, k)] if k else None


def _efc(ctx, part, p, ref, lab):
    """.EFC (an effect file, ca6tm01/02): 'IK' 00 00, then 55 records of 0x42 bytes, a 16-character name first:
    the CUSTOM record's five 0x42-byte record kinds (items 0-9, 10-14, 15-34, 35-44, 45-54;
    kn7000/notes/custom-data-ic21.md, "The slot record").  Fields past the name are not traced."""
    if part != 1 or p[:4] != b'IK\0\0' or (len(p) - 4) % 0x42:
        return None
    n = (len(p) - 4) // 0x42
    L = ['', lab + ':', '\t.ascii\t"IK"', '\t.byte\t0, 0']
    for k in range(n):
        r = p[4 + 0x42 * k:4 + 0x42 * (k + 1)]
        nm = '"' + ''.join(chr(c) if 0x20 <= c < 0x7F and c not in (0x22, 0x5C) else '\\%03o' % c for c in r[:16]) + '"'
        L += ['\t.ascii\t%s\t; item %d' % (nm, k)] + ['\t.byte\t' + ', '.join(str(x) for x in r[16 + j:16 + j + 25]) for j in (0, 25)]
    return L


TYPERS['EFC'] = _efc
