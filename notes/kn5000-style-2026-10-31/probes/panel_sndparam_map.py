#!/usr/bin/env python3
"""Which panel parameter does each byte of a KN5000 panel record hold, according to the firmware's own
SndParam descriptor table (974 x 18 bytes, registered by SndParam_RegisterAllWidgets)?

A descriptor is {key, bank_index = the panel record's TLV tag, bank_offset = the payload byte, mask, clamp
min / max, shift, ...} (v10/maincpu/audio/sndparam_records/sndparam_types.h).  The records come from the
compiled C runs v10/maincpu/audio/sndparam_records/run_*.c (one name per descriptor in its comment) and the
20 `sndparam_descriptor` macro lines of v10/maincpu/extensions/extension_data.s (name = the label above).
usage: panel_sndparam_map.py [REPO] [--tag 0xTT ...] [--json OUT]
Output: per (tag, payload offset) the descriptors that hold a field of it: name, key, mask, clamp range."""
import collections, json, pathlib, re, sys
args = sys.argv[1:]
tags, out_json = None, None
if '--tag' in args:
    i = args.index('--tag'); j = i + 1
    while j < len(args) and not args[j].startswith('--'):
        j += 1
    tags = {int(x, 0) for x in args[i + 1:j]}; del args[i:j]
if '--json' in args:
    i = args.index('--json'); out_json = args[i + 1]; del args[i:i + 2]
repo = pathlib.Path(args[0]) if args else pathlib.Path(__file__).resolve().parents[3]
base = repo / 'v10' / 'maincpu'
desc = []
rx = re.compile(r'/\* \[\s*\d+\] 0x([0-9A-F]+)\s+(\w+) \*/\s*\{ \.key = 0x([0-9A-Fa-f]+), \.bank_index = 0x([0-9A-Fa-f]+), '
                r'\.bank_offset = 0x([0-9A-Fa-f]+),\s*\.mask = 0x([0-9A-Fa-f]+), \.clamp_min = 0x([0-9A-Fa-f]+), '
                r'\.clamp_max = 0x([0-9A-Fa-f]+), \.shift = 0x([0-9A-Fa-f]+)', re.S)
for f in sorted((base / 'audio' / 'sndparam_records').glob('run_*.c')):
    for m in rx.finditer(f.read_text(encoding='latin-1')):
        desc.append(dict(addr=int(m.group(1), 16), name=m.group(2), key=int(m.group(3), 16), tag=int(m.group(4), 16),
                         off=int(m.group(5), 16), mask=int(m.group(6), 16), lo=int(m.group(7), 16),
                         hi=int(m.group(8), 16), shift=int(m.group(9), 16), src=f.name))
lab = None
for l in (base / 'extensions' / 'extension_data.s').read_bytes().decode('latin-1').split('\n'):
    m = re.match(r'^([A-Za-z_]\w*):', l)
    if m:
        lab = m.group(1)
    m = re.match(r'\s*sndparam_descriptor (0x[0-9a-f]+), (\d+), (\d+), (0x[0-9a-f]+), (\d+), (\d+), (\d+)', l)
    if m:
        desc.append(dict(addr=None, name=lab, key=int(m.group(1), 16), tag=int(m.group(2)), off=int(m.group(3)),
                         mask=int(m.group(4), 16), lo=int(m.group(5)), hi=int(m.group(6)), shift=int(m.group(7)),
                         src='extension_data.s'))
by = collections.defaultdict(list)
for d in desc:
    by[(d['tag'], d['off'])].append(d)
print(f'# {len(desc)} descriptors, {len(by)} (tag, offset) pairs')
for (t, o) in sorted(by):
    if tags and t not in tags:
        continue
    for d in sorted(by[(t, o)], key=lambda d: d['mask']):
        print(f'tag 0x{t:02x} +{o:<3d} mask 0x{d["mask"]:02x} {d["lo"]}..{d["hi"]}  key 0x{d["key"]:05x}  {d["name"]}')
if out_json:
    json.dump({f'{t:02x}:{o}': by[(t, o)] for (t, o) in sorted(by)}, open(out_json, 'w'), indent=0)
