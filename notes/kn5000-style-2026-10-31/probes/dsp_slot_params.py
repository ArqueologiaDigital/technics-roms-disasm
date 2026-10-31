#!/usr/bin/env python3
"""Which DSP parameter is each byte p1..p23 of a KN5000 panel DSP slot record (tags 0x61 0x63 0x64 0x65 0x66:
+0 the algorithm = DSP effect number, then its parameters), and do the saved values fit?

From the v10 program ROM (addresses as linked, file offset = address - 0xE00000):
  DspFxParamCountTable       0xEE5FE0  100 x u8   parameter count of effect e   (DSPCfg_GetSlotCount)
  DSPCfg_LookupAndExtract_PtrTable  0xEE6044  100 x u32 -> {min, max, param_id} big-endian u16 x count (`mul wa, 6`)
  DspParamName_Table         0xE324C4  86 x 17    parameter name (16 chars + ':'), indexed by param_id
  DspEffectName_PtrTable     0xE32A7A  128 x u32 -> effect name
The reading tested here: payload byte +k (k = 1..count) is parameter k-1 of the effect.  With --check DIR (the
extracted floppy files) it counts, per k, the saved values inside [min, max] over every DSP slot record of every
.LSW / .PMT / .SQT panel block.
usage: dsp_slot_params.py ROM [--json OUT] [--check EXTRACTED_DIR]   (with both, the json also gets each
effect's record counts: records, records_in_range)"""
import json, pathlib, struct, sys, collections
args = sys.argv[1:]
rom = pathlib.Path(args.pop(0)).read_bytes()
out_json = check = None
if '--json' in args:
    i = args.index('--json'); out_json = args[i + 1]; del args[i:i + 2]
if '--check' in args:
    i = args.index('--check'); check = args[i + 1]; del args[i:i + 2]
B = 0xE00000
def u8(a): return rom[a - B]
def u16(a): return struct.unpack_from('<H', rom, a - B)[0]
def u32(a): return struct.unpack_from('<I', rom, a - B)[0]
def cstr(a, n=24):
    b = rom[a - B:a - B + n]
    return b.split(b'\0')[0].decode('latin-1').rstrip()
pname = [rom[0xE324C4 - B + 17 * i:0xE324C4 - B + 17 * i + 16].decode('latin-1').rstrip(': ').rstrip() for i in range(86)]
eff = {}
for e in range(100):
    cnt = u8(0xEE5FE0 + e)
    p = u32(0xEE6044 + 4 * e)
    if not (0xE00000 <= p < 0x1000000) or cnt == 0:
        continue
    name = cstr(u32(0xE32A7A + 4 * e)) if 0xE00000 <= u32(0xE32A7A + 4 * e) < 0x1000000 else '?'
    ps = []
    for k in range(cnt):
        lo, hi, pid = struct.unpack_from('>HHH', rom, p + 6 * k - B)
        ps.append(dict(name=pname[pid] if pid < 86 else '?', pid=pid, min=lo, max=hi))
    eff[e] = dict(name=name, params=ps)
for e, v in sorted(eff.items()):
    print('%3d %-20s %s' % (e, v['name'], '; '.join('p%d %s %d..%d' % (k + 1, q['name'], q['min'], q['max'])
                                                     for k, q in enumerate(v['params']))))
if check:
    # The reading under test: parameter k follows parameter k-1; a parameter whose max is above 255 takes two
    # bytes, big-endian; a parameter whose min is negative (stored as u16 > max) is a signed byte.
    per = collections.defaultdict(lambda: [0, 0, 0])      # effect -> [records, records all in range, values out]
    for f in sorted(pathlib.Path(check).rglob('*')):
        if f.suffix.lower() not in ('.lsw', '.pmt', '.sqt'):
            continue
        d = f.read_bytes()
        for i in range(len(d) - 26):
            if d[i] in (0x61, 0x63, 0x64, 0x65, 0x66) and d[i + 1] == 24 and d[i + 26] in (0x63, 0x64, 0x65, 0x66, 0x68, 0x61):
                r, e, p, bad = d[i + 2:i + 26], d[i + 2], 1, 0
                for q in eff.get(e, {}).get('params', []):
                    lo, hi = q['min'], q['max']
                    sg = lo > hi
                    lo = lo - 65536 if sg else lo
                    if hi > 255:
                        v = struct.unpack_from('>H', r, p)[0]; p += 2
                    else:
                        v = r[p] - 256 if sg and r[p] > 127 else r[p]; p += 1
                    bad += not lo <= v <= hi
                per[e][0] += 1
                per[e][1] += bad == 0
                per[e][2] += bad
    print('effect  records  all-in-range  values-out')
    for e in sorted(per):
        print('%6d %8d %13d %11d  %s' % (e, per[e][0], per[e][1], per[e][2], eff.get(e, {}).get('name', '?')))
if out_json:
    if check:
        for e, v in eff.items():
            v['records'], v['records_in_range'] = (per[e][0], per[e][1]) if e in per else (0, 0)
    json.dump({str(e): v for e, v in sorted(eff.items())}, open(out_json, 'w'), indent=0)
    open(out_json, 'a').write('\n')
