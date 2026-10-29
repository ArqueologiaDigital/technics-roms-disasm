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

TYPERS = {}


def note(ctx, ext):
    k = KIND.get(ext)
    return ['%s: %s.' % (ctx.path, k)] if k else None
