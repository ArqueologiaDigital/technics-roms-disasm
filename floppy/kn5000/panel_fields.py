"""floppy/kn5000/panel_fields.py -- panel records (LSW blocks, PMT memories) typed field by field.

The firmware's record lists (PanelTlv_Block0_Layout / _Block1_Layout) give each record its tag,
its length and its rule list (PanelTlv_Rules_*: per payload byte a rule type, mask and range,
applied by PanelTlv_ApplyFieldRule, audio/tonegen_fileio_handlers.s).  All three come from
v10/maincpu/ui_widgets/naka_extension_device.c.  One macro is generated per (rule list, length):
`ptlv_<kind>` with one named parameter per field.  The NAMES are curated below from the field
studies in analysis/disk-format-probes/ (README-lsw-part-record-fields.md,
README-lsw-nonpart-records.md, README-lsw-drawbar-records.md, README-lsw-leftover-records.md);
every other byte gets a neutral name f<offset> and its rule in the macro header.

write_include(path) writes floppy/kn5000/include/kn5000_panel.inc; record_line() spells one record.
"""
import pathlib
import re
import sys

REPO = pathlib.Path(__file__).resolve().parents[2]
PANEL_C = REPO / 'v10' / 'maincpu' / 'ui_widgets' / 'naka_extension_device.c'
RULE = {'RULE_KEEP_BITS': 'keep bits', 'RULE_CLEAR_BITS': 'clear bits', 'RULE_SET_BITS': 'set bits',
        'RULE_RANGE': 'range', 'RULE_NOT_RANGE': 'not in range', 'RULE_ONE_OF': 'one of',
        'RULE_NONE_OF': 'none of', 'RULE_STORE': 'store', 'RULE_ZERO': 'zeroed'}

PART_TAGS = set(range(0x00, 0x1A))
PART = [  # (offset, name, kind, note) -- README-lsw-part-record-fields.md; P = proven there, I = inference
    (0, 'sound', 'dec', 'P sound/program number (0..167; 128.. = MEMORY A/B)'),
    (1, 'bank', 'hex', 'P bank in bits 0..2, bit 7 a flag the recall keeps'),
    (2, 'voice_b2', 'hex', 'in the voice-parameter group; nothing reads it'),
    (3, 'dsp_level', 'dec', 'I a level the DSP-effect preset owns'),
    (4, 'fx_flags', 'hex', 'P bit 6 reverb on, bit 3 chorus on'),
    (5, 'voice_b5', 'hex', 'I 7-bit value the preset change zeroes, bit 7 a flag'),
    (6, 'reserved6', 'hex', 'P unused (the voice-group copy skips it)'),
    (7, 'level', 'dec', 'I part volume'),
    (8, 'pan', 'signed', 'I pan, 0 = centre (stored 64 + pan; sent as D1 04)'),
    (9, 'voice_b9', 'dec', 'I a centred control'),
    (10, 'b10', 'hex', 'TODO: no rule, no code; 0x80 in every saved record'),
    (11, 'b11', 'hex', 'TODO: declared 7-bit, no routine reads it'),
    (12, 'midi_channel', 'hex', 'P 0..15, 0xc0 = none (SndParamBank flash defaults)'),
    (13, 'status', 'hex', 'P packed: bits 0..3 an id, 5 audio gate, 6 event gate, 7 off'),
    (14, 'io_a', 'hex', 'P I/O port value, bit 7 = changed (parts 0..2)'),
    (15, 'io_b', 'hex', 'P second byte of the I/O group'),
    (16, 'b16', 'hex', 'TODO: no code; 0 in every saved record'),
    (17, 'io_c', 'hex', 'P I/O port value for ports 3..5, bit 7 = changed'),
    (18, 'b18', 'hex', 'TODO: no code'), (19, 'b19', 'hex', 'TODO: no code'),
    (20, 'b20', 'hex', 'TODO: no code'), (21, 'b21', 'hex', 'TODO: no code'),
    (22, 'bit22', 'hex', 'TODO: declared 1-bit field nothing touches'),
    (23, 'b23', 'hex', 'TODO: no code'),
]
CURATED = {
    'part': PART,
    'style_name': [(0, 'name', 'ascii16', 'CODE: EffectMode_DisplayName_Render copies the style name here'),
                   (16, 'b16', 'hex', 'TODO'), (17, 'b17', 'hex', 'TODO')],
    'drawbar': [(0, 'dsp_effect_shadow', 'dec', 'shadow of tag 0x61 +0'),
                (1, 'nib1', 'nib', 'params 0x82cc / 0x82cb, not named'),
                (2, 'nib2', 'nib', 'params 0x8293 / 0x8294, not named'),
                (3, 'db16_8', 'nib', "DRAWBAR 16' / 8'"), (4, 'db5_4', 'nib', "DRAWBAR 5 1/3' / 4'"),
                (5, 'db2_2', 'nib', "DRAWBAR 2 2/3' / 2'"), (6, 'db1_1', 'nib', "DRAWBAR 1 3/5' / 1 1/3'"),
                (7, 'db1_sw', 'nib', "DRAWBAR 1' / switches 0x10, 0x20"),
                (8, 'sw8', 'hex', 'a switch in bit 0'), (9, 'b9', 'hex', 'TODO')],
    'style_select': [(0, 'style', 'u16', 'CODE: 11-bit style number'),
                     (2, 'f2', 'dec', 'TODO'), (3, 'f3', 'dec', 'TODO'), (4, 'f4', 'dec', 'TODO'),
                     (5, 'acc_flags', 'hex', 'accompaniment pedal / run flags'),
                     (6, 'acc_flags2', 'hex', 'accompaniment flags'),
                     (7, 'f7', 'dec', 'TODO'), (8, 'tempo', 'u16', 'CODE: SeqTimer_PostTempoUpdate posts (0x48, 8)')],
    'dsp_slot': [(0, 'algorithm', 'dec', 'P DSP algorithm number (DSPCfg_SlotAcceptsAlgorithm)')] +
                [(i, 'p%d' % i, 'dec', 'TODO: algorithm parameter, pushed whole to the DSP') for i in range(1, 24)],
}
KIND_OF_TAG = {0x78: 'style_name', 0x44: 'drawbar', 0x45: 'drawbar', 0x46: 'drawbar', 0x48: 'style_select',
               0x61: 'dsp_slot', 0x63: 'dsp_slot', 0x64: 'dsp_slot', 0x65: 'dsp_slot', 0x66: 'dsp_slot'}
EVIDENCE = {
    'part': 'analysis/disk-format-probes/README-lsw-part-record-fields.md (P proven, I inference)',
    'style_name': 'README-lsw-nonpart-records.md, tag 78',
    'drawbar': 'README-lsw-drawbar-records.md (parameter ids differ by 0x400 per part)',
    'style_select': 'README-lsw-nonpart-records.md, tag 48',
    'dsp_slot': 'README-lsw-leftover-records.md (slots 0x61 0x63 0x65 0x66 0x64 = 0..4)',
}


def parse():
    src = PANEL_C.read_bytes().decode('latin-1')
    rules = {}
    for m in re.finditer(r'\.(PanelTlv_Rules_\w+) = \{(.*?)\n    \},', src, re.S):
        per = {}
        for r in re.finditer(r'(RULE_[A-Z_]+)\(([^)]*)\)', m.group(2)):
            args = [a.strip() for a in r.group(2).split(',')]
            per.setdefault(int(args[0], 0), []).append((RULE[r.group(1)], args[1:]))
        rules[m.group(1)] = per
    layout = []
    for blk in ('PanelTlv_Block0_Layout', 'PanelTlv_Block1_Layout'):
        body = src[src.index('.%s = {' % blk):]
        body = body[:body.index('\n    },')]
        for r in re.finditer(r'\{\s*0x[0-9A-Fa-f]+,\s*SELF\((\w+)\),\s*0x([0-9A-Fa-f]+),\s*(0x[0-9A-Fa-f]+|\d+)\s*\}', body):
            layout.append((int(r.group(2), 16), int(r.group(3), 0), r.group(1)))
    return rules, layout


_P = None


def model():
    """{(tag, len): kind} and {kind: (len, fields, rules list, tags)}."""
    global _P
    if _P:
        return _P
    rules, layout = parse()
    kinds, by_tag = {}, {}
    for tag, n, lst in layout:
        if tag == 0xFF:
            continue
        if tag in PART_TAGS and n == 24:
            kind = 'part'
        elif tag in KIND_OF_TAG:
            kind = KIND_OF_TAG[tag]
        else:
            kind = 'tag%02x' % tag
        k = kinds.setdefault(kind, {'len': n, 'lists': set(), 'tags': []})
        assert k['len'] == n, (kind, n)
        k['lists'].add(lst)
        k['tags'].append(tag)
        by_tag[(tag, n)] = kind
    for kind, k in kinds.items():
        per = {}
        for lst in k['lists']:
            for off, rr in rules.get(lst, {}).items():
                per.setdefault(off, set()).update('%s %s' % (t, '/'.join(a)) for t, a in rr)
        if kind in CURATED:
            fields = CURATED[kind]
        else:
            fields = []
            for off in range(k['len']):
                rr = per.get(off, set())
                dec = any(r.startswith('range') for r in rr)
                fields.append((off, 'f%d' % off, 'dec' if dec else 'hex', 'TODO: not named'))
        k['fields'], k['rules'] = fields, per
    _P = (by_tag, kinds)
    return _P


def size_of(kind):
    return 16 if kind == 'ascii16' else 2 if kind == 'u16' else 1


def write_include(path):
    by_tag, kinds = model()
    L = ['; kn5000_panel.inc -- generated by floppy/kn5000/panel_fields.py from the firmware record lists',
         '; and rule lists (v10/maincpu/ui_widgets/naka_extension_device.c).  Regenerate, do not edit.',
         ';',
         '; One macro per panel record kind: tag, then the payload fields in order.  "signed" fields are',
         '; stored as 64 + value; "nib" fields take two nibbles, low first.  A field\'s rule (from',
         '; PanelTlv_Rules_*) is listed beside it.  Neutral names (f<offset>, b<offset>) are fields nobody',
         '; has identified: TODO, tried the rule list and the probes of analysis/disk-format-probes/.',
         '']
    for kind in sorted(kinds):
        k = kinds[kind]
        params = []
        for off, name, typ, note in k['fields']:
            params += [name + '_lo', name + '_hi'] if typ == 'nib' else [name]
        L.append('; %s: tags %s, %d payload bytes; rule list %s.' % (
            kind, ' '.join('0x%02x' % t for t in k['tags']), k['len'], ', '.join(sorted(k['lists']))))
        if kind in EVIDENCE:
            L.append(';   names: ' + EVIDENCE[kind])
        for off, name, typ, note in k['fields']:
            rr = '; '.join(sorted(k['rules'].get(off, []))) or 'no rule'
            L.append(';   +%-2d %-18s %-7s %s [%s]' % (off, name, typ, note, rr))
        L.append('\t.macro\tptlv_%s tag, %s' % (kind, ', '.join(params)))
        L.append('\t.byte\t\\tag, %d' % k['len'])
        for off, name, typ, note in k['fields']:
            if typ == 'ascii16':
                L += ['.Lpn\\@:', '\t.ascii\t"\\%s"' % name, '.Lpe\\@:',
                      '\t.if\t(.Lpe\\@ - .Lpn\\@) - 16', '\t.error\t"ptlv: name is not 16 bytes"', '\t.endif']
            elif typ == 'u16':
                L.append('\t.short\t\\%s' % name)
            elif typ == 'signed':
                L.append('\t.byte\t64 + (\\%s)' % name)
            elif typ == 'nib':
                L.append('\t.byte\t(\\%s_lo) | ((\\%s_hi) << 4)' % (name, name))
            else:
                L.append('\t.byte\t\\%s' % name)
        L += ['\t.endm', '']
    L += ['; A record whose tag/length the v10 list does not have at its position (an older revision\'s',
          '; block): its header and payload bytes.  TODO: the older record lists are not dumped.',
          '\t.macro\tptlv_raw tag, len, data:vararg', '\t.byte\t\\tag, \\len', '\t.ifnb\t\\data',
          '\t.byte\t\\data', '\t.endif', '\t.endm', '']
    pathlib.Path(path).write_text('\n'.join(L))


def esc(b):
    out = []
    for c in b:
        out.append('\\' + chr(c) if c in (0x22, 0x5C) else chr(c) if 0x20 <= c < 0x7F else '\\%03o' % c)
    return '"' + ''.join(out) + '"'


def record_line(tag, n, payload, comment=None):
    """One record as a macro line; None if the (tag, len) has no kind."""
    by_tag, kinds = model()
    kind = by_tag.get((tag, n))
    if kind is None:
        return None
    vals = []
    for off, name, typ, note in kinds[kind]['fields']:
        if typ == 'ascii16':
            vals.append(esc(payload[off:off + 16]))
        elif typ == 'u16':
            vals.append(str(payload[off] | payload[off + 1] << 8))
        elif typ == 'signed':
            vals.append(str(payload[off] - 64))
        elif typ == 'nib':
            vals += [str(payload[off] & 15), str(payload[off] >> 4)]
        elif typ == 'dec':
            vals.append(str(payload[off]))
        else:
            vals.append('0x%02x' % payload[off] if payload[off] else '0')
    return '\tptlv_%s\t0x%02x, %s%s' % (kind, tag, ', '.join(vals), ('\t; ' + comment) if comment else '')


def raw_line(tag, n, payload):
    return '\tptlv_raw\t0x%02x, %d%s' % (tag, n, ''.join(', 0x%02x' % x if x else ', 0' for x in payload))


if __name__ == '__main__':
    write_include(sys.argv[1] if len(sys.argv) > 1 else
                  pathlib.Path(__file__).parent / 'include' / 'kn5000_panel.inc')
