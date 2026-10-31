#!/usr/bin/env python3
"""Which maincpu instructions name each payload byte of the KN5000 panel records directly?  One recorded
reader search per (tag, payload offset) of the firmware's record lists (PanelTlv_Block0_Layout at RAM 0xf9a0,
PanelTlv_Block1_Layout at RAM 0xfd60, v10/maincpu/ui_widgets/naka_extension_device.c), in every maincpu tree:
an absolute operand equal to the byte's RAM address (hex or decimal), or a `.equ` name of the tree's
shared/ram_panel_records.s (PANEL_*) spelled alone or as NAME+n.  Table-driven accesses (the SndParam
descriptors, PanelTlv_ApplyFieldRule, block copies) are not counted here: panel_sndparam_map.py lists the
descriptors, and floppy/kn5000/panel_fields.py takes the rules from the rule lists.
usage: panel_field_refs.py [REPO] [--trees v10,v9,v7,v6,v5] [--json OUT]
Output: "tag 0xTT +off  RAM 0xADDR  N refs  [first rows]"; --json writes {"TT:off": {"ram", "refs", "rows"}}."""
import collections, json, pathlib, re, sys
args = sys.argv[1:]
trees, out_json = 'v10,v9,v7,v6,v5', None
if '--trees' in args:
    i = args.index('--trees'); trees = args[i + 1]; del args[i:i + 2]
if '--json' in args:
    i = args.index('--json'); out_json = args[i + 1]; del args[i:i + 2]
repo = pathlib.Path(args[0]) if args else pathlib.Path(__file__).resolve().parents[3]
src = (repo / 'v10/maincpu/ui_widgets/naka_extension_device.c').read_bytes().decode('latin-1')
fields = {}                                  # ram address -> (tag, off)
for blk, base in (('PanelTlv_Block0_Layout', 0xF9A0), ('PanelTlv_Block1_Layout', 0xFD60)):
    body = src[src.index('.%s = {' % blk):]
    body = body[:body.index('\n    },')]
    for r in re.finditer(r'\{\s*(0x[0-9A-Fa-f]+),\s*SELF\((\w+)\),\s*0x([0-9A-Fa-f]+),\s*(0x[0-9A-Fa-f]+|\d+)\s*\}', body):
        pos, tag, n = int(r.group(1), 16), int(r.group(3), 16), int(r.group(4), 0)
        if tag == 0xFF:
            continue
        for o in range(n):
            fields[base + pos + 2 + o] = (tag, o)
num = re.compile(rb'(?<![\w.])(0x[0-9a-fA-F]+|\d+)(?![\w])')
equ = re.compile(rb'^\s*\.equ\s+(PANEL_\w+)\s*,\s*(0x[0-9a-fA-F]+|\d+)')
hits = collections.defaultdict(list)
for tree in trees.split(','):
    root = repo / tree / 'maincpu'
    names = {}
    for f in root.glob('shared/*.s'):
        for l in f.read_bytes().split(b'\n'):
            m = equ.match(l)
            if m:
                names[m.group(1)] = int(m.group(2), 0)
    namere = re.compile(rb'\b(' + b'|'.join(sorted(names, key=len, reverse=True)) + rb')\b(?:\s*\+\s*(0x[0-9a-fA-F]+|\d+))?') \
        if names else re.compile(rb'(?!x)x')
    for f in sorted(root.rglob('*.s')):
        rel = f.relative_to(repo).as_posix()
        for n, l in enumerate(f.read_bytes().split(b'\n'), 1):
            code = l.split(b';')[0]
            if not code.strip() or code.lstrip().startswith((b'.equ', b'.set')) or b'.incbin' in code:
                continue
            seen = set()
            for nm, plus in (namere.findall(code) if names else []):
                a = names[nm] + (int(plus, 0) if plus else 0)
                seen.add(a)
            if not namere.search(code):
                for t in num.findall(code):
                    seen.add(int(t, 16) if t[:2] in (b'0x', b'0X') else int(t))
            for a in seen:
                if a in fields:
                    hits[a].append(f'{tree} {rel}:{n} {l.strip().decode("latin-1")[:90]}')
out = {}
for a in sorted(fields):
    t, o = fields[a]
    out['%02x:%d' % (t, o)] = {'ram': '0x%05x' % a, 'refs': len(hits[a]), 'rows': hits[a][:4]}
    print('tag 0x%02x +%-3d RAM 0x%05x %4d refs  %s' % (t, o, a, len(hits[a]), ' | '.join(hits[a][:2])))
if out_json:
    json.dump(out, open(out_json, 'w'), indent=0)
    open(out_json, 'a').write('\n')
