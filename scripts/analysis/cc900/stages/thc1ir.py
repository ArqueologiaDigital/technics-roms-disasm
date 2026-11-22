#!/usr/bin/env python3
"""Reader and writer of the intermediate file cc900's first pass (thc1) hands to its code generator (thc2).

Feedback plan decision E6 (notes/cc900-feedback-plan-2026-11-22/README.md, section 13): the model is rebuilt along
the compiler's own seam.  This module is the seam: the text format, as observed in the files job_i2.sh keeps (our
description; no Toshiba text is stored here).

The file is CRLF text, one item per line:
  - a line starting with a TAB is a declaration: a type (`<n>,<kind>,...`), a symbol (`@<asm name>,"<C name>",...`),
    a parameter of the function being declared (`,"<name>",...`), a local (`I<n>,"<name>",...`), a temporary
    (`T<n>,<type>`) and so on; fields are comma-separated, strings in double quotes;
  - any other line is an operation `<op>,<a>,<b>,<result>` (fewer fields for some operations) or a marker
    (`FILE,`, `LINE,`, `BEGIN,`, `END,`, `{,`, `}`).
Operands: `#<n>` a constant, `@<name>` a symbol, `I<n>` a local, `P<n>` a parameter, `T<n>` a temporary, `L<n>` a
label, a register name, and a leading `*` dereferences.

`parse(text)` gives a list of Line(kind, fields, raw) and `write(lines)` gives the text back; the round trip is exact
(`python3 -B thc1ir.py --roundtrip FILE...` checks it and prints counts only).
"""
import re
import sys

FIELD = re.compile(r'"(?:[^"\\]|\\.)*"|[^,]*')


class Line:
    __slots__ = ('kind', 'fields', 'raw')

    def __init__(self, kind, fields, raw):
        self.kind, self.fields, self.raw = kind, fields, raw

    @property
    def op(self):
        return self.fields[0] if self.kind == 'op' else None

    def __repr__(self):
        return 'Line(%s, %r)' % (self.kind, self.fields)


def split_fields(s):
    """comma-separated fields, double-quoted strings kept whole (with their quotes)"""
    out, i = [], 0
    while True:
        m = FIELD.match(s, i)
        out.append(m.group(0))
        i = m.end()
        if i >= len(s):
            break
        if s[i] != ',':                      # a quote inside an unquoted field: keep the rest as one field
            out[-1] += s[i:]
            break
        i += 1
        if i == len(s):
            out.append('')
            break
    return out


def parse(text):
    lines = []
    for raw in text.split('\r\n'):
        if raw.startswith('\t'):
            lines.append(Line('decl', split_fields(raw[1:]), raw))
        else:
            lines.append(Line('op', split_fields(raw), raw))
    return lines


def write(lines):
    return '\r\n'.join(('\t' if l.kind == 'decl' else '') + ','.join(l.fields) for l in lines)


def roundtrip(paths):
    import collections
    n = collections.Counter()
    for p in paths:
        t = open(p, 'rb').read().decode('latin-1')
        ok = write(parse(t)) == t
        n['files'] += 1
        n['exact' if ok else 'differs'] += 1
        if not ok:
            sys.stderr.write('round trip differs: %s\n' % p)
    print(' '.join('%s %d' % kv for kv in sorted(n.items())))
    return n['differs'] == 0


if __name__ == '__main__':
    if len(sys.argv) > 2 and sys.argv[1] == '--roundtrip':
        sys.exit(0 if roundtrip(sys.argv[2:]) else 1)
    sys.exit(__doc__)
