"""floppy/kn5000/panel_fields.py -- panel records (LSW blocks, PMT memories) typed field by field.

The firmware's record lists (PanelTlv_Block0_Layout / _Block1_Layout) give each record its tag,
its length and its rule list (PanelTlv_Rules_*: per payload byte a rule type, mask and range,
applied by PanelTlv_ApplyFieldRule, audio/tonegen_fileio_handlers.s).  All three come from
v10/maincpu/ui_widgets/naka_extension_device.c.  One macro is generated per (rule list, length):
`ptlv_<kind>` with one named parameter per field.  The NAMES come, first, from the firmware's own
SndParam descriptor table (2026-10-31, lane kn5000-style): each of its 974 descriptors names one panel
parameter and gives the record (bank_index = the TLV tag), the payload byte and the bit mask that hold it
(v10/maincpu/audio/sndparam_records/run_*.c, the macro lines of v10/maincpu/extensions/extension_data.s;
notes/kn5000-style-2026-10-31/probes/panel_sndparam_map.py lists them).  A byte that holds several
parameters becomes a bit-field macro argument per parameter.  Where no descriptor covers a byte, the names
curated below from analysis/disk-format-probes/ (README-lsw-part-record-fields.md,
README-lsw-nonpart-records.md, README-lsw-drawbar-records.md, README-lsw-leftover-records.md) are kept; a
byte with neither and no direct reference in v5..v10 (notes/floppy-kn5000-2026-10-29/specs/
panel_field_refs.json, from notes/kn5000-style-2026-10-31/probes/panel_field_refs.py) is reserved_<offset>;
the rest keep a neutral name f<offset> with a TODO.

write_include(path) writes floppy/kn5000/include/kn5000_panel.inc; record_line() spells one record.
"""
import json
import pathlib
import re
import sys

REPO = pathlib.Path(__file__).resolve().parents[2]
PANEL_C = REPO / 'v10' / 'maincpu' / 'ui_widgets' / 'naka_extension_device.c'
RULE = {'RULE_KEEP_BITS': 'keep bits', 'RULE_CLEAR_BITS': 'clear bits', 'RULE_SET_BITS': 'set bits',
        'RULE_RANGE': 'range', 'RULE_NOT_RANGE': 'not in range', 'RULE_ONE_OF': 'one of',
        'RULE_NONE_OF': 'none of', 'RULE_STORE': 'store', 'RULE_ZERO': 'zeroed'}

PART_TAGS = set(range(0x00, 0x1A))
PART = [  # (offset, name, kind, note) -- README-lsw-part-record-fields.md; P = proven there, I = inference.
    # Only the bytes no SndParam descriptor covers are taken from here; +0, +1, +3..+5, +7..+13 and +22 are
    # named from the descriptors (pan keeps its signed spelling, 64 = centre).
    (2, 'reserved_2', 'hex', 'in the voice-parameter group; nothing reads it (README-lsw); no descriptor'),
    (6, 'reserved6', 'hex', 'P unused (the voice-group copy skips it)'),
    (8, 'pan', 'signed', 'I pan, 0 = centre (stored 64 + pan; sent as D1 04)'),
    (14, 'io_a', 'hex', 'P I/O port value, bit 7 = changed (parts 0..2)'),
    (15, 'io_b', 'hex', 'P second byte of the I/O group'),
    (17, 'io_c', 'hex', 'P I/O port value for ports 3..5, bit 7 = changed'),
]
CURATED = {
    'part': PART,
    'style_name': [(0, 'name', 'ascii16', 'CODE: EffectMode_DisplayName_Render copies the style name here')],
    'drawbar': [(0, 'dsp_effect_shadow', 'dec', 'shadow of tag 0x61 +0'),
                (1, 'nib1', 'nib', 'params 0x82cc / 0x82cb, not named'),
                (2, 'nib2', 'nib', 'params 0x8293 / 0x8294, not named'),
                (3, 'db16_8', 'nib', "DRAWBAR 16' / 8'"), (4, 'db5_4', 'nib', "DRAWBAR 5 1/3' / 4'"),
                (5, 'db2_2', 'nib', "DRAWBAR 2 2/3' / 2'"), (6, 'db1_1', 'nib', "DRAWBAR 1 3/5' / 1 1/3'"),
                (7, 'db1_sw', 'nib', "DRAWBAR 1' / switches 0x10, 0x20"),
                (8, 'sw8', 'hex', 'a switch in bit 0')],
    'style_select': [(5, 'acc_flags', 'hex', 'accompaniment pedal / run flags'),
                     (6, 'acc_flags2', 'hex', 'accompaniment flags'),
                     (8, 'tempo', 'u16', 'CODE: SeqTimer_PostTempoUpdate posts (0x48, 8); descriptors SndParam_Tempo '
                      '(+8, 40..255) and SndParam_Tempo_Bit8 (+9 bit 0): a 9-bit tempo')],
    'dsp_slot': [(0, 'algorithm', 'dec', 'P DSP algorithm number (DSPCfg_SlotAcceptsAlgorithm)')] +
                [(i, 'p%d' % i, 'dec', 'parameter byte %d of the algorithm: each record line names its effect\'s '
                  'parameters (specs/dsp_effect_params.json)' % i) for i in range(1, 24)],
}
# The companion ("VARI") records (2026-11-02, lane open6-kn5000-d/panel): one byte per SOUND GROUP button, the
# sound number (slot 0..39 of that group) the part last had in the group.  MIDI_DistributeParamToChannels
# (part, group, slot) stores companion[group] = slot when MainVariSet (EVT_VARI_WRITE) or Sound_SetSelection
# picks a sound; VoiceData_DistributeToChannels (part, group) reads it back when PanelButton_SoundGroup handles a
# SOUND GROUP button, so the button recalls the last sound of that group; PanelTlv_ResolvePartCompanions
# re-derives the current sound's byte after a load (SndParam_ResolveVoiceEntry -> {group, slot} from the
# bank map, descriptor slot +0x10).  The group index is SoundData_CategoryDesc's (SOUND_CATEGORY_NAMES, 18).
SOUND_GROUPS = ['piano', 'guitar', 'strings_vocal', 'brass', 'flute', 'sax_reed', 'mallet_orch_perc', 'world_perc',
                'organ_accordion', 'orchestral_pad', 'synth', 'bass', 'digital_drawbar', 'accordion_reg',
                'gm_special', 'drum_kits', 'memory_a', 'memory_b']
# The style record's companion (tag 0x49): the same per RHYTHM GROUP button (groups 0..15, PanelButton_RhythmGroup
# and its PanelButton_RhythmGroupCodes_LeftSeg0/1/6 maps; the group / number pair is AccStyle_LookupPanelRhythm's).
RHYTHM_GROUPS = ['standard_rock', 'r_roll_blues', 'pop_ballad', 'funk_fusion', 'soul_modern_dance', 'big_band_swing',
                 'jazz_combo', 'us_trad', 'country', 'latin', 'march_waltz', 'party_time', 'showtime_trad_dance',
                 'world', 'custom', 'memory']
CURATED['part_vari'] = [(i, 'vari_' + g, 'dec', 'SOUND GROUP %d (%s): the slot last selected in it'
                         % (i, g.upper().replace('_', ' '))) for i, g in enumerate(SOUND_GROUPS)]
CURATED['style_vari'] = [(i, 'vari_' + g, 'dec', 'RHYTHM GROUP %d (%s): the number last selected in it'
                          % (i, g.upper().replace('_', ' '))) for i, g in enumerate(RHYTHM_GROUPS)]
CURATED['tag71'] = [(0, 'pmemout_l_flags', 'hex', 'the PANEL MEMORY page grid PmemOutLGridCheck sets bit 1 of this '
                     'byte in a panel memory (0x1ed400 + 960 n); PanelMemory_Recall runs BitMapOut_DispatchIOChanges '
                     'when bit 1 of the live copy is set (ui/bitmap_out_routines.s); 0 in every saved panel')]
CURATED['tag98'] = [(12, 'reserved_12', 'hex', 'no reader: the 25 references to 0xfda2 (PANEL_PMEM_SETTINGS+12) are the '
                     'END bound of the 0xf980..0xfda1 block copies (BitMapOut_ComputeRegionDelta, '
                     'ToneGen_FileIO_SaveAndSync), not accesses of this byte; the load rule zeroes it')]
# Descriptors whose label is a placeholder, named from the code that reads the key.
KEY_NAMES = {
    0x28800: ('msp_bank', 'MSP BANK (0..18): PanelButton_MspNumber turns MSP 1-6 into pedal functions when '
              'SndParam_LookupReadOnly(0x28800) is 17 or 18 (PanelButton_MspBank17FuncCodes / _MspBank18FuncCodes); '
              'VwVariBox_Init / _Match compare it with the box index; AccompSeq_HandleSpecialMode tests 13 / 14'),
    0x28403: ('composer_bend_range', 'the Composer RECORD SETTING page: CmpBndRng returns this key; '
              'DrumVoice_Handler7 steps it 0..12 (PANEL_TOUCH+4)'),
}
KIND_OF_TAG = {0x78: 'style_name', 0x44: 'drawbar', 0x45: 'drawbar', 0x46: 'drawbar', 0x48: 'style_select',
               0x61: 'dsp_slot', 0x63: 'dsp_slot', 0x64: 'dsp_slot', 0x65: 'dsp_slot', 0x66: 'dsp_slot',
               0x49: 'style_vari'}
KIND_OF_TAG.update({t: 'part_vari' for t in list(range(0xC0, 0xD5)) + [0xD7]})
EVIDENCE = {
    'part': 'analysis/disk-format-probes/README-lsw-part-record-fields.md (P proven, I inference)',
    'style_name': 'README-lsw-nonpart-records.md, tag 78',
    'drawbar': 'README-lsw-drawbar-records.md (parameter ids differ by 0x400 per part)',
    'style_select': 'README-lsw-nonpart-records.md, tag 48',
    'dsp_slot': 'README-lsw-leftover-records.md (slots 0x61 0x63 0x65 0x66 0x64 = 0..4)',
    'part_vari': 'companion of part 0xC0 + tag (PanelTlv_CompanionByPart); MIDI_DistributeParamToChannels writes, '
                 'VoiceData_DistributeToChannels reads (PanelButton_SoundGroup); notes/open6-kn5000-d/panel/README.md',
    'style_vari': 'companion of the style record 0x48 (PanelTlv_CompanionOfPart, part 72); the same two routines '
                  '(PanelButton_RhythmGroup); notes/open6-kn5000-d/panel/README.md',
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


SNDPARAM_DIR = REPO / 'v10' / 'maincpu' / 'audio' / 'sndparam_records'
EXT_DATA = REPO / 'v10' / 'maincpu' / 'extensions' / 'extension_data.s'
REFS_JSON = REPO / 'notes' / 'floppy-kn5000-2026-10-29' / 'specs' / 'panel_field_refs.json'
DSP_JSON = REPO / 'notes' / 'floppy-kn5000-2026-10-29' / 'specs' / 'dsp_effect_params.json'
_DSP = None


def dsp_spec():
    """{effect number: {name, params, bytes, records, records_in_range}} from specs/dsp_effect_params.json, written by
    notes/open6-kn5000-d/panel/probes/dsp_slot_packing.py from the v10 ROM: per parameter its name, range, the op
    letter of its DspFxRecListPtrTable record and where DSPCfg_ReadField finds it (payload offset `off`, and in the
    big-endian word W = payload[off] << 8 | payload[off + 1], value = (W >> shift) & mask; `width` = how far the
    reader's pointer then moves; `signed` = read as a signed byte)."""
    global _DSP
    if _DSP is None:
        _DSP = {int(k): v for k, v in json.loads(DSP_JSON.read_text()).items()} if DSP_JSON.exists() else {}
    return _DSP


def snake(t):
    return re.sub(r'[^a-z0-9]+', '_', t.lower()).strip('_')


def dsp_layout(e):
    """(macro name, [arg names], [byte expressions], used bytes) of effect e's DSP slot macro; None if the effect
    has no parameter-write record list.  A packed word (the 'p' / 'v' fields that share two bytes, width 0 until
    the field that moves the pointer by 2) becomes two .byte expressions of its fields."""
    v = dsp_spec().get(e)
    if not v:
        return None
    args, used, exprs, word, ptr = [], set(), [], [], 1
    for k, q in enumerate(v['params']):
        nm = snake(q['name']) or 'hidden_%d' % q['off']
        base, i = nm, 2
        while nm in used:
            nm = '%s_%d' % (base, i)
            i += 1
        used.add(nm)
        args.append(nm)
        assert q['off'] == ptr, (e, k)
        packed = q['width'] == 0 or (q['width'] == 2 and (q['shift'], q['mask']) != (0, 0xFFFF))
        if packed or word:
            word.append((nm, q['shift']))
            if q['width'] == 2:
                w = ' | '.join('((\\%s) << %d)' % (n, sh) if sh else '(\\%s)' % n for n, sh in word)
                exprs += ['((%s) >> 8) & 0xff' % w, '(%s) & 0xff' % w]
                word = []
            else:
                assert q['width'] == 0, (e, k)
        elif q['width'] == 2:
            exprs += ['((\\%s) >> 8) & 0xff' % nm, '(\\%s) & 0xff' % nm]
        else:
            exprs.append('(\\%s) & 0xff' % nm)
        ptr += q['width']
    assert not word, e
    return 'ptlv_dsp%d_%s' % (e, snake(v['name'])), args, exprs, ptr - 1


def dsp_values(e, payload):
    """The parameter values of effect e read from payload as DSPCfg_ReadField reads them, or None when a payload bit
    inside the effect's bytes belongs to no parameter (the macro could not spell it)."""
    v = dsp_spec()[e]
    cov, vals = [0] * 26, []
    for q in v['params']:
        o = q['off']
        W = payload[o] << 8 | payload[o + 1]
        x = (W >> q['shift']) & q['mask']
        vals.append(x - 256 if q['signed'] and x > 127 else x)
        m = q['mask'] << q['shift']
        cov[o] |= m >> 8
        cov[o + 1] |= m & 0xFF
    if any(payload[o] & ~cov[o] & 0xFF for o in range(1, v['bytes'] + 1)):
        return None
    return vals


def dsp_macros():
    """The per-effect DSP slot macros (lines for kn5000_panel.inc)."""
    L = ['; DSP slot records (tags 0x61 DSP EFFECT, 0x63 DIGITAL REVERB, 0x64 EQUALIZER, 0x65 ACOUSTIC ILLUSION,',
         '; 0x66 MIC REVERB), one macro per DSP effect: +0 is the effect number, then its parameters in the bytes',
         '; and bits where DSPCfg_ReadViaTableLookup -> DSPCfg_ReadMultiField -> DSPCfg_ReadField finds them',
         '; (audio/dsp_config_sysex.s; the op letter of each parameter\'s DspFxRecListPtrTable record decides',
         '; its width: \'g\' / \'d\' a big-endian word, \'p\' / \'v\' fields packed into a big-endian word, any other',
         '; letter a byte; notes/open6-kn5000-d/panel/README.md).  `tail` is the bytes after the last parameter,',
         '; up to +23: no reader (DSPCfg_RecordFieldToParamId maps payload bytes 1..16 only); kept as saved.',
         '; Ranges and names: DSPCfg_LookupAndExtract_PtrTable, DspParamName_Table (specs/dsp_effect_params.json).']
    for e in sorted(dsp_spec()):
        lay = dsp_layout(e)
        nm, args, exprs, n = lay
        v = dsp_spec()[e]
        L.append(';')
        L.append('; effect %d %s, %d parameter bytes:' % (e, v['name'], n))
        for a, q in zip(args, v['params']):
            if (q['shift'], q['mask']) == (8, 0xFF):
                where = '+%d' % q['off']
            elif (q['shift'], q['mask']) == (0, 0xFFFF):
                where = '+%d..+%d (big-endian)' % (q['off'], q['off'] + 1)
            else:
                hi = q['shift'] + q['mask'].bit_length() - 1
                where = '+%d bits %d:%d' % (q['off'], hi - 8, q['shift'] - 8) if q['shift'] >= 8 else \
                    '+%d..+%d bits %d:%d of the word' % (q['off'], q['off'] + 1, hi, q['shift'])
            L.append(';   %-22s %-30s %s, %d..%d (op \'%s\')' % (a, where, q['name'] or '(blank name, DspParamName_Table 85)',
                                                             q['min'], q['max'], q['op']))
        L.append('\t.macro\t%s tag, %s, tail:vararg' % (nm, ', '.join(args)))
        L.append('\t.byte\t\\tag, 24, %d' % e)
        for x in exprs:
            L.append('\t.byte\t' + x)
        L += ['.Ldt\\@:', '\t.byte\t\\tail', '.Lde\\@:', '\t.if\t(.Lde\\@ - .Ldt\\@) - %d' % (23 - n),
              '\t.error\t"%s: tail is not %d bytes"' % (nm, 23 - n), '\t.endif', '\t.endm']
    return L


def dsp_comment(payload):
    """The comment of a DSP slot record that no per-effect macro spells: why."""
    e = payload[0]
    v = dsp_spec().get(e)
    if not v:
        return 'effect %d: no parameter-write record list (DspFxRecListPtrTable), so no reader of p1..p23' % e
    return '%s: a bit outside every parameter field is set, so the bytes stay as saved' % v['name']


def descriptors():
    """{(tag, payload offset): [descriptor]} from the firmware's SndParam table (see the docstring)."""
    # The comment lists every label at or inside the descriptor ("NAME, OTHER(+2)"); the first is the
    # descriptor's own.  (Until 2026-11-02 the pattern took a single name only and dropped the 11 descriptors
    # with a list, among them the MSP bank 0x28800 and the MSP reverb 0x28802.)
    rx = re.compile(r'/\* \[\s*\d+\] 0x([0-9A-F]+)\s+(\w+)[^*]*\*/\s*\{ \.key = 0x([0-9A-Fa-f]+), \.bank_index = '
                    r'0x([0-9A-Fa-f]+), \.bank_offset = 0x([0-9A-Fa-f]+),\s*\.mask = 0x([0-9A-Fa-f]+), \.clamp_min = '
                    r'0x([0-9A-Fa-f]+), \.clamp_max = 0x([0-9A-Fa-f]+)', re.S)
    out = {}
    for f in sorted(SNDPARAM_DIR.glob('run_*.c')):
        for m in rx.finditer(f.read_text(encoding='latin-1')):
            d = dict(name=m.group(2), key=int(m.group(3), 16), mask=int(m.group(6), 16),
                     lo=int(m.group(7), 16), hi=int(m.group(8), 16), where='0x' + m.group(1))
            out.setdefault((int(m.group(4), 16), int(m.group(5), 16)), []).append(d)
    lab = None
    for l in EXT_DATA.read_bytes().decode('latin-1').split('\n'):
        m = re.match(r'^([A-Za-z_]\w*):', l)
        if m:
            lab = m.group(1)
        m = re.match(r'\s*sndparam_descriptor (0x[0-9a-f]+), (\d+), (\d+), (0x[0-9a-f]+), (\d+), (\d+)', l)
        if m:
            d = dict(name=lab, key=int(m.group(1), 16), mask=int(m.group(4), 16), lo=int(m.group(5)),
                     hi=int(m.group(6)), where='extension_data.s')
            out.setdefault((int(m.group(2)), int(m.group(3))), []).append(d)
    return out


def lsw_number(key):
    """SndParam_KeyToLswPartNumber's decode of a part-namespace key; None outside it."""
    if 0x8000 <= key < 0x18000:
        return key & 0x3FF
    if 0x18000 <= key < 0x28000:
        return (key & 0x3FF) + 0x400
    return None


def desc_name(d):
    """A descriptor's name as a field name: SndParam_Part13_ReverbSend -> reverb_send; a placeholder label
    (VoiceCtrlR1_Entry_011, WidgetParam_*_Entry) -> the key (lsw_<number> for a part key, key_<key>)."""
    nm = d['name'] or ''
    if d['key'] in KEY_NAMES:
        return KEY_NAMES[d['key']][0]
    if not nm.startswith('SndParam_'):
        n = lsw_number(d['key'])
        return 'lsw_%03x' % n if n is not None else 'key_%05x' % d['key']
    nm = re.sub(r'^Part[0-9A-F]{2}_', '', nm[len('SndParam_'):])
    return re.sub(r'(?<=[a-z0-9])(?=[A-Z])', '_', nm).lower()


def desc_note(d):
    ev = ('; named from its readers: ' + KEY_NAMES[d['key']][1]) if d['key'] in KEY_NAMES else ''
    return '%s (key 0x%05x, mask 0x%02x, %d..%d%s)' % (d['name'], d['key'], d['mask'], d['lo'], d['hi'], ev)


def lowbit(m):
    return (m & -m).bit_length() - 1


_P = None


def model():
    """{(tag, len): kind} and {kind: {len, lists, tags, fields, rules}}.  A field is a dict: off, size, name,
    typ (dec / hex / signed / u16 / ascii16 / bits), note, and for bits a list subs of (name, mask, note)."""
    global _P
    if _P:
        return _P
    rules, layout = parse()
    desc = descriptors()
    refs = json.loads(REFS_JSON.read_text()) if REFS_JSON.exists() else {}
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
        cur = {f[0]: f for f in CURATED.get(kind, [])}
        fields, used, off = [], set(), 0

        def uniq(nm):
            base, i = nm, 2
            while nm in used:
                nm = '%s_%d' % (base, i)
                i += 1
            used.add(nm)
            return nm
        while off < k['len']:
            c = cur.get(off)
            if c and c[2] in ('ascii16', 'u16'):
                sz = size_of(c[2])
                fields.append(dict(off=off, size=sz, name=uniq(c[1]), typ=c[2], note=c[3]))
                off += sz
                continue
            ds = []
            for t in k['tags']:                       # the first tag that has descriptors at this byte
                ds = desc.get((t, off), [])
                if ds:
                    break
            others = sorted({desc_name(d) for t in k['tags'][1:] for d in desc.get((t, off), [])} -
                            {desc_name(d) for d in ds})
            ds, seen, extra = sorted(ds, key=lambda d: (lowbit(d['mask']), d['key'])), 0, []
            keep = []
            for d in ds:
                if d['mask'] & seen:
                    extra.append(d)
                else:
                    keep.append(d)
                    seen |= d['mask']
            note_x = (' (also: %s)' % ', '.join(desc_note(d) for d in extra) if extra else '') + \
                     (' (other tags: %s)' % ', '.join(others) if others and kind != 'part' else '')
            if len(keep) == 1 and keep[0]['mask'] in (0xFF, 0x7F):
                d = keep[0]
                typ = c[2] if c else ('dec' if d['hi'] > 1 else 'hex')
                nm = c[1] if (c and others) else desc_name(d)
                fields.append(dict(off=off, size=1, name=uniq(nm), typ=typ,
                                   note='SndParam ' + desc_note(d) + note_x))
            elif keep:
                subs = [(uniq(desc_name(d)), d['mask'], desc_note(d)) for d in keep]
                if seen != 0xFF:
                    subs.append((uniq('bits%d_other' % off), 0xFF & ~seen, 'bits no descriptor names'))
                fields.append(dict(off=off, size=1, name='byte%d' % off, typ='bits', subs=subs,
                                   note='SndParam bit fields' + note_x))
            elif c:
                fields.append(dict(off=off, size=1, name=uniq(c[1]), typ=c[2], note=c[3]))
            else:
                nref = sum(refs.get('%02x:%d' % (t, off), {}).get('refs', 0) for t in k['tags'])
                dec = any(r.startswith('range') for r in per.get(off, set()))
                zeroed = any(r.startswith('zeroed') for r in per.get(off, set()))
                stored = sorted(r[len('store '):] for r in per.get(off, set()) if r.startswith('store '))
                if nref == 0 and (zeroed or stored):
                    fields.append(dict(off=off, size=1, name=uniq('reserved_%d' % off), typ='dec' if dec else 'hex',
                                       note='the load rule %s (PanelTlv_ApplyFieldRule); no SndParam descriptor '
                                            'and no direct reference in v5..v10 (panel_field_refs.json)' % (
                                                'zeroes it' if zeroed else 'overwrites it with ' + '/'.join(stored))))
                else:
                    fields.append(dict(off=off, size=1, name=uniq('f%d' % off), typ='dec' if dec else 'hex',
                                       note='TODO: not named; no SndParam descriptor, %d direct references in v5..v10 '
                                            '(panel_field_refs.json)' % nref))
            off += 1
        k['fields'], k['rules'] = fields, per
    _P = (by_tag, kinds)
    return _P


def size_of(kind):
    return 16 if kind == 'ascii16' else 2 if kind == 'u16' else 1


def params_of(f):
    return [s[0] for s in f['subs']] if f['typ'] == 'bits' else [f['name']]


def write_include(path):
    by_tag, kinds = model()
    L = ['; kn5000_panel.inc -- generated by floppy/kn5000/panel_fields.py from the firmware record lists',
         '; and rule lists (v10/maincpu/ui_widgets/naka_extension_device.c) and its SndParam descriptor table',
         '; (v10/maincpu/audio/sndparam_records/).  Regenerate, do not edit.',
         ';',
         '; One macro per panel record kind: tag, then the payload fields in order.  "signed" fields are',
         '; stored as 64 + value; a "bits" byte takes one argument per parameter it holds, each shifted to its',
         '; mask.  A field\'s rule (from PanelTlv_Rules_*) is listed beside it.  Names: the SndParam',
         '; descriptor of the byte (name, key, mask, range), else the curated field studies; reserved_<offset>',
         '; = no descriptor and no direct reference; f<offset> = not named (marked so).',
         '']
    for kind in sorted(kinds):
        k = kinds[kind]
        params = [p for f in k['fields'] for p in params_of(f)]
        L.append('; %s: tags %s, %d payload bytes; rule list %s.' % (
            kind, ' '.join('0x%02x' % t for t in k['tags']), k['len'], ', '.join(sorted(k['lists']))))
        if kind in EVIDENCE:
            L.append(';   curated names: ' + EVIDENCE[kind])
        for f in k['fields']:
            rr = '; '.join(sorted(k['rules'].get(f['off'], []))) or 'no rule'
            L.append(';   +%-2d %-22s %-7s %s [%s]' % (f['off'], f['name'], f['typ'], f['note'], rr))
            for nm, m, note in f.get('subs', []):
                L.append(';       %-22s 0x%02x    %s' % (nm, m, note))
        L.append('\t.macro\tptlv_%s tag, %s' % (kind, ', '.join(params)))
        L.append('\t.byte\t\\tag, %d' % k['len'])
        for f in k['fields']:
            typ, name = f['typ'], f['name']
            if typ == 'ascii16':
                L += ['.Lpn\\@:', '\t.ascii\t"\\%s"' % name, '.Lpe\\@:',
                      '\t.if\t(.Lpe\\@ - .Lpn\\@) - 16', '\t.error\t"ptlv: name is not 16 bytes"', '\t.endif']
            elif typ == 'u16':
                L.append('\t.short\t\\%s' % name)
            elif typ == 'signed':
                L.append('\t.byte\t64 + (\\%s)' % name)
            elif typ == 'bits':
                L.append('\t.byte\t' + ' | '.join('((\\%s) << %d)' % (nm, lowbit(m)) for nm, m, _ in f['subs']))
            else:
                L.append('\t.byte\t\\%s' % name)
        L += ['\t.endm', '']
    L += dsp_macros() + ['']
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
    for f in kinds[kind]['fields']:
        off, typ = f['off'], f['typ']
        if typ == 'ascii16':
            vals.append(esc(payload[off:off + 16]))
        elif typ == 'u16':
            vals.append(str(payload[off] | payload[off + 1] << 8))
        elif typ == 'signed':
            vals.append(str(payload[off] - 64))
        elif typ == 'bits':
            for nm, m, _ in f['subs']:
                v = (payload[off] & m) >> lowbit(m)
                vals.append('0x%x' % v if v > 9 else str(v))
        elif typ == 'dec':
            vals.append(str(payload[off]))
        else:
            vals.append('0x%02x' % payload[off] if payload[off] else '0')
    if kind == 'dsp_slot':
        lay = dsp_layout(payload[0])
        vv = dsp_values(payload[0], payload) if lay else None
        if vv is not None:
            nm, args, exprs, nb = lay
            return '\t%s\t0x%02x, %s, %s' % (nm, tag, ', '.join(str(x) for x in vv),
                                            ', '.join(str(x) for x in payload[nb + 1:24]))
        if comment is None:
            comment = dsp_comment(payload)
    return '\tptlv_%s\t0x%02x, %s%s' % (kind, tag, ', '.join(vals), ('\t; ' + comment) if comment else '')


def raw_line(tag, n, payload):
    return '\tptlv_raw\t0x%02x, %d%s' % (tag, n, ''.join(', 0x%02x' % x if x else ', 0' for x in payload))


if __name__ == '__main__':
    write_include(sys.argv[1] if len(sys.argv) > 1 else
                  pathlib.Path(__file__).parent / 'include' / 'kn5000_panel.inc')
