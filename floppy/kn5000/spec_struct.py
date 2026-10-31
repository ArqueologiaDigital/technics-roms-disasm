"""floppy/kn5000/spec_struct.py -- typed records from a committed JSON field map.

A field map (notes/floppy-kn5000-2026-10-29/specs/*.json) tiles a region with fields
{off, size, name, kind, evidence, inference, todo, repeat?}.  From it this module generates one
llvm-mc macro per run of fields (named parameters, values in their domain) and spells a region of
a file as calls of those macros.  A field longer than BLOB bytes that is not text is spelled as
`.byte` rows under its name instead (a macro with hundreds of parameters reads no better).

kinds: dec, hex, signed (stored 64 + value), ascii (size bytes of text), u16 / u16be (one value),
bits (hex).  Anything else is read as hex bytes.
"""
import json
import pathlib

BLOB = 48
SPECS = pathlib.Path(__file__).resolve().parents[2] / 'notes' / 'floppy-kn5000-2026-10-29' / 'specs'


def load(name):
    p = SPECS / name
    return json.loads(p.read_text()) if p.is_file() else None


def expand(fields):
    out = []
    for f in fields:
        rep = f.get('repeat')
        if rep:
            for i in range(rep['count']):
                g = dict(f)
                g.pop('repeat')
                g['off'] = f['off'] + i * rep['stride']
                g['name'] = '%s_%d' % (f['name'], i)
                out.append(g)
        else:
            out.append(f)
    out.sort(key=lambda f: f['off'])
    return out


def ident(s):
    return ''.join(c if c.isalnum() or c == '_' else '_' for c in s)


def check_tiles(fields, size):
    p = 0
    for f in fields:
        assert f['off'] == p, ('gap or overlap at', p, f)
        p += f['size']
    assert p == size, ('fields cover', p, 'of', size)


MAXP = 64


def segments(fields):
    """Runs of macro fields, split at blobs and every MAXP parameters:
    [('macro', [fields]) | ('blob', field)]."""
    segs, run = [], []
    for f in fields:
        if f['size'] > BLOB and f.get('kind') != 'ascii':
            if run:
                segs.append(('macro', run))
                run = []
            segs.append(('blob', f))
        else:
            if run and sum(len(params(g)) for g in run) + len(params(f)) > MAXP:
                segs.append(('macro', run))
                run = []
            run.append(f)
    if run:
        segs.append(('macro', run))
    return segs


def params(f):
    k, n = f.get('kind', 'hex'), f['size']
    if k == 'ascii' or (k in ('u16', 'u16be') and n == 2):
        return [ident(f['name'])]
    if n == 1:
        return [ident(f['name'])]
    return ['%s_%d' % (ident(f['name']), i) for i in range(n)]


def macro_text(mname, run, title):
    L = ['; %s' % title]
    for f in run:
        note = f.get('evidence') or ''
        if f.get('inference'):
            note = '[INFERENCE] ' + note
        if f.get('todo'):
            note = (note + '; ' if note else '') + 'TODO: ' + f['todo']
        kind = f.get('kind', 'hex') + ('+64' if f.get('kind') == 'signed' and f.get('bias', 64) == 64 else '')
        L.append(';   +0x%03x %-24s %-6s %s' % (f['off'], f['name'], kind, note[:160]))
    ps = [p for f in run for p in params(f)]
    L.append('\t.macro\t%s %s' % (mname, ', '.join(ps)))
    for f in run:
        k = f.get('kind', 'hex')
        if k == 'ascii':
            L += ['.Lsa\\@_%s:' % ident(f['name']), '\t.ascii\t"\\%s"' % ident(f['name']),
                  '.Lsb\\@_%s:' % ident(f['name']),
                  '\t.if\t(.Lsb\\@_%s - .Lsa\\@_%s) - %d' % (ident(f['name']), ident(f['name']), f['size']),
                  '\t.error\t"%s: %s is not %d bytes"' % (mname, f['name'], f['size']), '\t.endif']
        elif k == 'u16' and f['size'] == 2:
            L.append('\t.short\t\\%s' % ident(f['name']))
        elif k == 'u16be' and f['size'] == 2:
            L.append('\t.byte\t(\\%s) >> 8, (\\%s) & 0xff' % (ident(f['name']), ident(f['name'])))
        elif k == 'signed' and f['size'] == 1 and f.get('bias', 64) == 64:
            L.append('\t.byte\t64 + (\\%s)' % ident(f['name']))
        elif k == 'signed' and f['size'] == 1:
            L.append('\t.byte\t(\\%s) & 0xff' % ident(f['name']))
        else:
            L.append('\t.byte\t' + ', '.join('\\' + p for p in params(f)))
    L += ['\t.endm', '']
    return L


def esc(b):
    return '"' + ''.join('\\' + chr(c) if c in (0x22, 0x5C) else chr(c) if 0x20 <= c < 0x7F
                         else '\\%03o' % c for c in b) + '"'


def values(f, b):
    k = f.get('kind', 'hex')
    if k == 'ascii':
        return [esc(b)]
    if k == 'u16' and len(b) == 2:
        return [str(b[0] | b[1] << 8)]
    if k == 'u16be' and len(b) == 2:
        return [str(b[0] << 8 | b[1])]
    if k == 'signed' and len(b) == 1:
        return [str(b[0] - 64)] if f.get('bias', 64) == 64 else [str(b[0] - 256 if b[0] & 0x80 else b[0])]
    if k == 'dec':
        return [str(x) for x in b]
    return ['0x%02x' % x if x else '0' for x in b]


class Struct:
    """One field map region: its macros, and how to spell an instance."""

    def __init__(self, prefix, region, title):
        self.prefix, self.size, self.title = prefix, region['size'], title
        self.fields = expand(region['fields'])
        check_tiles(self.fields, self.size)
        self.segs = segments(self.fields)

    def macros(self):
        L, k = [], 0
        for kind, x in self.segs:
            if kind == 'macro':
                L += macro_text('%s_%d' % (self.prefix, k), x, '%s, fields +0x%x..+0x%x' % (
                    self.title, x[0]['off'], x[-1]['off'] + x[-1]['size'] - 1))
                k += 1
        return L

    def lines(self, b):
        """[(line, nbytes)] spelling b (exactly self.size bytes)."""
        assert len(b) == self.size
        out, k = [], 0
        for kind, x in self.segs:
            if kind == 'macro':
                vals = [v for f in x for v in values(f, b[f['off']:f['off'] + f['size']])]
                out.append(('\t%s_%d\t%s' % (self.prefix, k, ', '.join(vals)),
                            sum(f['size'] for f in x)))
                k += 1
            else:
                f = x
                part = b[f['off']:f['off'] + f['size']]
                what = f['name'] + (' (TODO: %s)' % f['todo'] if f.get('todo') else '')
                if len(set(part)) == 1:
                    out.append(('\t.fill\t%d, 1, 0x%02x\t; %s' % (len(part), part[0], what[:120]), len(part)))
                    continue
                for i in range(0, len(part), 16):
                    row = part[i:i + 16]
                    out.append(('\t.byte\t' + ', '.join(values({'kind': f.get('kind', 'hex')}, row)) +
                                ('\t; %s' % what[:120] if i == 0 else ''), len(row)))
        return out


# ------------------------------------------------------------------------------------------------
# The KN5000 field maps used by formats.py, split where a describer types a stretch otherwise.

def _part(fields, lo, hi, rebase=0):
    out = []
    for f in fields:
        if lo <= f['off'] < hi:
            g = dict(f)
            g['off'] -= rebase
            out.append(g)
    return out


_S = None


def structs():
    global _S
    if _S is not None:
        return _S
    _S = {}
    tm = load('tm_sound_record.json')
    if tm:
        _S['tm_sound'] = Struct('tm_sound', {'size': tm['record_size'], 'fields': tm['fields']},
                                'SOUND MEMORY record (470 B)')
        kit = tm['kit']
        ent = [f for f in kit['fields'] if f.get('repeat', {}).get('stride') == 80]
        e0 = min(f['off'] for f in ent)
        entry = [dict({k: v for k, v in f.items() if k != 'repeat'}, off=f['off'] - e0) for f in ent]
        head = [f for f in kit['fields'] if f not in ent and f['off'] < e0]
        tail = [f for f in kit['fields'] if f not in ent and f['off'] >= e0 + 128 * 80]
        _S['tm_kit_head'] = Struct('tm_kit_head', {'size': e0, 'fields': head}, 'kit record header')
        _S['tm_kit_entry'] = Struct('tm_kit_entry', {'size': 80, 'fields': entry},
                                    'kit record: one of 128 user drum instruments (80 B)')
        _S['tm_kit_tail'] = Struct('tm_kit_tail', {'size': kit['size'] - e0 - 128 * 80,
                                                   'fields': _part(tail, 0, 1 << 30, e0 + 128 * 80)},
                                   'kit record tail')
        _S['tm_kit_tail'].base = e0 + 128 * 80
        _S['tm_kit_entry'].base = e0
    sq = load('sqt_slot_header.json')
    if sq:
        ra = [v for k, v in sq['regions'].items() if k.startswith('slot_a')][0]
        rb = [v for k, v in sq['regions'].items() if k.startswith('slot_b')][0]
        _S['sqt_slot_a'] = Struct('sqt_slot_a', ra, 'song slot +0x07..+0xff')
        blk = [f for f in rb['fields'] if f['name'] == 'song_panel_block0'][0]
        b0, b1 = blk['off'], blk['off'] + blk['size']
        _S['sqt_slot_b_head'] = Struct('sqt_slot_b_head', {'size': b0, 'fields': _part(rb['fields'], 0, b0)},
                                       'song slot +0x110 up to its panel block 0')
        # The song's copy of block 1's first records follows block 0; formats.py types it with the
        # panel record macros, so the tail struct starts after it.
        cp = [f for f in rb['fields'] if f['name'] == 'song_panel_block1_copy'][0]
        b2 = cp['off'] + cp['size']
        assert cp['off'] == b1
        _S['sqt_slot_b_tail'] = Struct('sqt_slot_b_tail', {'size': rb['size'] - b2,
                                                           'fields': _part(rb['fields'], b2, 1 << 30, b2)},
                                       'song slot after its panel copy, to +0x7ff')
        _S['sqt_slot_b_tail'].panel = (rb['base'] + b0, blk['size'])
        _S['sqt_slot_b_tail'].panel1 = (rb['base'] + b1, cp['size'])
    return _S


def write_include(path):
    L = ['; kn5000_specs.inc -- generated by floppy/kn5000/spec_struct.py from the field maps in',
         '; notes/floppy-kn5000-2026-10-29/specs/ (each field: name, kind, evidence, [INFERENCE], TODO).',
         '; Regenerate, do not edit.  "signed+64" is stored as 64 + value, "signed" as two\'s complement.', '']
    for name, st in structs().items():
        L += st.macros()
    pathlib.Path(path).write_text('\n'.join(L) + '\n')


if __name__ == '__main__':
    import sys
    write_include(sys.argv[1] if len(sys.argv) > 1 else pathlib.Path(__file__).parent / 'include' / 'kn5000_specs.inc')
