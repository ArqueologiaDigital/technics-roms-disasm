#!/usr/bin/env python3
"""What values does each byte of a KN5000 panel record hold in the 14 floppy images' saved panels?
Reads the generated floppy sources (floppy/kn5000/<disk>/**/*.s): every `ptlv_<kind> tag, args...` line, and
decodes the args back to payload bytes through floppy/kn5000/panel_fields.py's model (so bit fields are rejoined).
usage: panel_byte_values.py [--tags 60,68,...] [--all]
Output per (tag, offset): records, records non-zero, distinct values (up to 12, with counts).  Default: only the
bytes the generator still names f<offset>."""
import collections, pathlib, re, sys
REPO = pathlib.Path(__file__).resolve().parents[4]
sys.path.insert(0, str(REPO / 'floppy' / 'kn5000'))
import panel_fields as pf
args = sys.argv[1:]
want_tags = None
if '--tags' in args:
    want_tags = {int(t, 16) for t in args[args.index('--tags') + 1].split(',')}
by_tag, kinds = pf.model()
vals = collections.defaultdict(collections.Counter)
for f in sorted((REPO / 'floppy' / 'kn5000').rglob('*.s')):
    for l in f.read_bytes().decode('latin-1').split('\n'):
        m = re.match(r'\s*ptlv_(\w+)\s+(.*?)(\t;|$)', l)
        if not m or m.group(1) == 'raw' or m.group(1) not in kinds:
            continue
        a = [x.strip() for x in re.findall(r'\s*("(?:[^"\\]|\\.)*"|[^,]+)', m.group(2))]
        tag, a = int(a[0], 0), a[1:]
        i = 0
        for fd in kinds[m.group(1)]['fields']:
            if fd['typ'] == 'ascii16':
                i += 1
                continue
            if fd['typ'] == 'bits':
                v = 0
                for nm, msk, _ in fd['subs']:
                    v |= int(a[i], 0) << pf.lowbit(msk); i += 1
            elif fd['typ'] == 'u16':
                v = int(a[i], 0); i += 1
                vals[(tag, fd['off'])][v & 0xff] += 1; vals[(tag, fd['off'] + 1)][v >> 8] += 1
                continue
            elif fd['typ'] == 'signed':
                v = int(a[i], 0) + 64; i += 1
            else:
                v = int(a[i], 0); i += 1
            vals[(tag, fd['off'])][v] += 1
names = {}
for kind, k in kinds.items():
    for t in k['tags']:
        for fd in k['fields']:
            names[(t, fd['off'])] = fd['name']
for (t, o), c in sorted(vals.items()):
    if want_tags is not None and t not in want_tags:
        continue
    if '--all' not in args and want_tags is None and not re.fullmatch(r'f\d+', names.get((t, o), '')):
        continue
    n = sum(c.values())
    nz = n - c.get(0, 0)
    top = ' '.join('%02x:%d' % (v, k) for v, k in sorted(c.items())[:12]) + (' ...' if len(c) > 12 else '')
    print('tag 0x%02x +%-2d %-14s %5d recs %5d nonzero %3d distinct  %s' % (t, o, names.get((t, o), '?'), n, nz, len(c), top))
