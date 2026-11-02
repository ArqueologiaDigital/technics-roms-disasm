#!/usr/bin/env python3
"""How are the parameter bytes of a KN5000 DSP slot record packed (panel tags 0x61 0x63 0x64 0x65 0x66, and the
24-byte DspFxSettingsPtrTable blocks): which payload byte(s) and bits hold parameter k of effect e?

The v10 reader is DSPCfg_ReadViaTableLookup -> DSPCfg_ReadMultiField -> DSPCfg_ReadField (audio/dsp_config_sysex.s):
byte +0 is the effect number e; DspFxRecListPtrTable[e] (0xEE75F6, u32 x100) gives e's parameter-write record list
(one record per parameter, next = rec + BE16 rec[0..1], end at a 0xF0 byte); ReadMultiField walks it with a pointer
into the payload (+1..), and ReadField returns, for each record, the parameter's value read at the pointer and
the WIDTH by which the pointer then advances.  DSPCfg_ReadField, by the op letter rec[+2] and the operand nibbles
of rec[+4] (DSPCfg_ExtractFieldSingle / DSPCfg_ExtractFieldPair: sub = rec[+4] & 0xF0, lo = rec[+4] & 0x0F), with
W = payload[ptr] << 8 | payload[ptr+1]:
  'v' sub 0x10, lo 2:  (W >> 8) & 0x3F      width 1
  'v' sub 0x10, lo!=2: W & 0x3F             width 2
  'v' sub other:       (W >> 6) & 0x1F      width 0
  'p' sub 0x20:        W & 0x3F             width 2
  'p' sub 0x10:        (W >> 11) & 0x1F     width 0
  'p' sub other:       (W >> 6) & 0x1F      width 2 if lo == 1 else 0
  'h':                 payload[ptr]          width 1 (unsigned)
  'g', 'd':            W                     width 2 (big-endian word)
  any other letter:    payload[ptr]          width 1 (signed byte)
Ranges {min, max} per parameter: DSPCfg_LookupAndExtract_PtrTable (0xEE6044, 6 bytes per parameter, BE min/max;
+4/+5 = DSPCfg_ExtractPairFromStruct's last two bytes, +5 = the DspParamName_Table index), count DspFxParamCountTable
(0xEE5FE0), names DspParamName_Table (0xE324C4, 86 x 17), effect names DspEffectName_PtrTable (0xE32A7A).

usage: dsp_slot_packing.py ROM [--json OUT] [--check-floppy REPO]
  prints per effect each parameter's {byte offset, bits}; --check-floppy decodes every ptlv_dsp_slot record of the
  generated KN5000 floppy sources (floppy/kn5000/**/*.s) and counts the records whose every value is in range;
  --json writes {effect: {name, params: [{name, pid, min, max, op, off, width, shift, bits, signed}], records,
  records_in_range}} (the spec floppy/kn5000/panel_fields.py reads)."""
import collections, json, pathlib, re, struct, sys
args = sys.argv[1:]
rom = pathlib.Path(args.pop(0)).read_bytes()
out_json = repo = None
if '--json' in args:
    i = args.index('--json'); out_json = args[i + 1]; del args[i:i + 2]
if '--check-floppy' in args:
    i = args.index('--check-floppy'); repo = pathlib.Path(args[i + 1]); del args[i:i + 2]
B = 0xE00000
u8 = lambda a: rom[a - B]
u32 = lambda a: struct.unpack_from('<I', rom, a - B)[0]
ok = lambda p: 0xE00000 <= p < 0x1000000
pname = [rom[0xE324C4 - B + 17 * i:0xE324C4 - B + 17 * i + 16].decode('latin-1').rstrip(': ').strip() for i in range(86)]


def records(e):
    p = u32(0xEE75F6 + 4 * e)
    out = []
    if not ok(p):
        return out
    while u8(p) != 0xF0 and len(out) < 40:
        n = u8(p) << 8 | u8(p + 1)
        out.append(dict(addr=p, op=chr(u8(p + 2)), b3=u8(p + 3), b4=u8(p + 4), b5=u8(p + 5)))
        p += n
    return out


def field(rec):
    """(width, shift, mask, signed) of DSPCfg_ReadField for one record; value = (W >> shift) & mask, where W is
    the big-endian word at the pointer (a 1-byte field: shift 8)."""
    op, sub, lo = rec['op'], rec['b4'] & 0xF0, rec['b4'] & 0x0F
    if op == 'v':
        if sub == 0x10:
            return (1, 8, 0x3F, False) if lo == 2 else (2, 0, 0x3F, False)
        return (0, 6, 0x1F, False)
    if op == 'p':
        if sub == 0x20:
            return (2, 0, 0x3F, False)
        if sub == 0x10:
            return (0, 11, 0x1F, False)
        return (2 if lo == 1 else 0, 6, 0x1F, False)
    if op == 'h':
        return (1, 8, 0xFF, False)
    if op in 'gd':
        return (2, 0, 0xFFFF, False)
    return (1, 8, 0xFF, True)


eff = {}
for e in range(100):
    cnt = u8(0xEE5FE0 + e)
    rp = u32(0xEE6044 + 4 * e)
    recs = records(e)
    if not recs or not ok(rp):
        continue
    np = u32(0xE32A7A + 4 * e)
    name = rom[np - B:np - B + 24].split(b'\0')[0].decode('latin-1').strip() if ok(np) else '?'
    ps, ptr = [], 1
    for k in range(min(cnt, len(recs))):
        lo, hi, x4, pid = struct.unpack_from('>HHBB', rom, rp + 6 * k - B)
        w, sh, m, sg = field(recs[k])
        bits = [(ptr * 8 + (15 - b)) for b in range(16) if (m << sh) >> b & 1] if sh < 16 else []
        ps.append(dict(name=pname[pid] if pid < 86 else '?', pid=pid, min=lo - 65536 if lo > hi else lo, max=hi,
                       op=recs[k]['op'], off=ptr, width=w, shift=sh, mask=m, signed=sg))
        ptr += w
    eff[e] = dict(name=name, params=ps, bytes=ptr - 1)


def decode(e, payload):
    """[values] of effect e's parameters from payload (payload[0] = e), or None past the record."""
    vals = []
    for q in eff[e]['params']:
        o = q['off']
        W = payload[o] << 8 | (payload[o + 1] if o + 1 < len(payload) else 0)
        v = (W >> q['shift']) & q['mask']
        if q['signed'] and v > 127:
            v -= 256
        vals.append(v)
    return vals


if repo:
    per = collections.defaultdict(lambda: [0, 0])
    for f in sorted((repo / 'floppy' / 'kn5000').rglob('*.s')):
        for l in f.read_bytes().decode('latin-1').split('\n'):
            m = re.match(r'\s*ptlv_dsp_slot\s+([^;]*)', l)
            if not m:
                continue
            payload = [int(x, 0) & 0xFF for x in m.group(1).split(',')[1:]]
            e = payload[0]
            if e not in eff:
                continue
            per[e][0] += 1
            if all(q['min'] <= v <= q['max'] for q, v in zip(eff[e]['params'], decode(e, payload))):
                per[e][1] += 1
    for e, (n, good) in per.items():
        eff[e]['records'], eff[e]['records_in_range'] = n, good
for e, v in sorted(eff.items()):
    rr = ' [%d/%d records in range]' % (v.get('records_in_range', 0), v['records']) if 'records' in v else ''
    print('%3d %-18s %2d B%s: %s' % (e, v['name'], v['bytes'], rr, '; '.join(
        '%s %s+%d%s' % (q['op'], q['name'] or '?', q['off'],
                        '' if (q['width'], q['shift'], q['mask']) in ((1, 8, 0xFF),) else
                        '-%d' % (q['off'] + 1) if (q['shift'], q['mask']) == (0, 0xFFFF) else
                        '[%d:%d]' % (q['shift'] + q['mask'].bit_length() - 1, q['shift']))
        for q in v['params'])))
if out_json:
    pathlib.Path(out_json).write_text(json.dumps({str(k): v for k, v in sorted(eff.items())}, indent=1) + '\n')
