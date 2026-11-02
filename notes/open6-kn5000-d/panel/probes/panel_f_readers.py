#!/usr/bin/env python3
"""Every instruction in v5..v10 that names a given set of KN5000 panel-record bytes, by either spelling: an absolute
operand (hex / decimal / PANEL_NAME[+n]) equal to the byte's RAM address, or a base register loaded with a panel
address and then used as (xR [+/- d]) (the logic of panel_base_reads.py, run over every tree).  It answers, for the
bytes floppy/kn5000/panel_fields.py still calls f<offset>: does any instruction read or write the byte itself, or are
all its "references" the record's start used as a pointer?
usage: panel_f_readers.py [--bytes 60:0,72:0,...]   (default: every byte the generator names f<offset>)
Output: one block per byte: tag, offset, RAM address, then each hit "tree file:line  [abs|base]  instruction"."""
import collections, pathlib, re, sys
REPO = pathlib.Path(__file__).resolve().parents[4]
sys.path.insert(0, str(REPO / 'floppy' / 'kn5000'))
import panel_fields as pf
src = (REPO / 'v10/maincpu/ui_widgets/naka_extension_device.c').read_bytes().decode('latin-1')
fields = {}
for blk, base in (('PanelTlv_Block0_Layout', 0xF9A0), ('PanelTlv_Block1_Layout', 0xFD60)):
    body = src[src.index('.%s = {' % blk):]
    body = body[:body.index('\n    },')]
    for r in re.finditer(r'\{\s*(0x[0-9A-Fa-f]+),\s*SELF\((\w+)\),\s*0x([0-9A-Fa-f]+),\s*(0x[0-9A-Fa-f]+|\d+)\s*\}', body):
        pos, tag, n = int(r.group(1), 16), int(r.group(3), 16), int(r.group(4), 0)
        if tag != 0xFF:
            for o in range(n):
                fields[base + pos + 2 + o] = (tag, o)
want = None
if '--bytes' in sys.argv:
    want = {(int(t, 16), int(o)) for t, o in (x.split(':') for x in sys.argv[sys.argv.index('--bytes') + 1].split(','))}
else:
    by_tag, kinds = pf.model()
    want = {(t, f['off']) for k in kinds.values() for t in k['tags'] for f in k['fields'] if re.fullmatch(r'f\d+', f['name'])}
addr_of = {v: a for a, v in fields.items()}
targets = {addr_of[w]: w for w in want if w in addr_of}
NUM = re.compile(r'(?<![\w.])(0x[0-9a-fA-F]+|\d+)(?![\w])')
LOAD = re.compile(r'^\s*(ld|lda)\s+(x\w\w)\s*,\s*\(?\s*([\w+\- ]+?)(?::16|:24)?\s*\)?\s*$')
USE = re.compile(r'\((x\w\w)\s*(?:([+-])\s*(0x[0-9a-fA-F]+|\d+))?(?::8|:16)?\)')
hits = collections.defaultdict(list)
for tree in ('v10', 'v9', 'v7', 'v6', 'v5'):
    root = REPO / tree / 'maincpu'
    names = {}
    for f in root.glob('shared/*.s'):
        for l in f.read_bytes().split(b'\n'):
            m = re.match(rb'^\s*\.equ\s+(\w+)\s*,\s*(0x[0-9a-fA-F]+|\d+)', l)
            if m:
                names[m.group(1).decode()] = int(m.group(2), 0)
    def val(tok):
        m = re.fullmatch(r'\s*(\w+)\s*([+-]\s*(?:0x[0-9a-fA-F]+|\d+))?\s*', tok)
        if not m:
            return None
        b = m.group(1)
        v = int(b, 0) if re.fullmatch(r'0x[0-9a-fA-F]+|\d+', b) else names.get(b)
        if v is None:
            return None
        return v + (int(m.group(2).replace(' ', ''), 0) if m.group(2) else 0)
    namere = re.compile(r'\b(' + '|'.join(sorted((n for n in names if n.startswith('PANEL_')), key=len, reverse=True)) +
                        r')\b(?:\s*\+\s*(0x[0-9a-fA-F]+|\d+))?')
    for f in sorted(root.rglob('*.s')):
        rel = f.relative_to(REPO).as_posix()
        base = {}
        for n, raw in enumerate(f.read_bytes().decode('latin-1').split('\n'), 1):
            code = raw.split(';')[0].rstrip()
            if not code.strip() or '.incbin' in code or re.match(r'\s*\.(equ|set)\b', code):
                continue
            if re.match(r'^[A-Za-z_]\w*:', code):
                base = {}
                code = code.split(':', 1)[1]
                if not code.strip():
                    continue
            seen = set()
            for nm, plus in namere.findall(code):
                seen.add(names[nm] + (int(plus, 0) if plus else 0))
            if not namere.search(code):
                for t in NUM.findall(code):
                    seen.add(int(t, 16) if t[:2] in ('0x', '0X') else int(t))
            for a in seen & set(targets):
                hits[targets[a]].append('%s %s:%d  [abs]  %s' % (tree, rel, n, raw.strip()[:90]))
            for r, s, d in USE.findall(code):
                r = r.lower()
                if r in base:
                    a = base[r] + (int(d, 0) * (-1 if s == '-' else 1) if d else 0)
                    if a in targets:
                        hits[targets[a]].append('%s %s:%d  [base]  %s' % (tree, rel, n, raw.strip()[:90]))
            m = LOAD.match(code)
            c = code.strip().lower()
            if m:
                r, v = m.group(2).lower(), val(m.group(3))
                if v is not None and 0xF9A0 <= v <= 0xFFBE:
                    base[r] = v
                else:
                    base.pop(r, None)
            else:
                mm = re.match(r'^\s*\w+\s+(x\w\w)\s*,', code)
                if mm and not c.startswith(('cp', 'push', 'bit')):
                    base.pop(mm.group(1).lower(), None)
            if re.match(r'^(ret|reti|retd|jp\s|jrl\s+[a-z_]|jr\s+[a-z_.]\w*$|call)', c) and \
                    not re.match(r'^(jr|jp|jrl)\s+(z|nz|c|nc|ugt|ule|gt|lt|ge|le|mi|pl|ov|nov|eq|ne|t|f)\s*,', c):
                if c.startswith('call'):
                    for r in ('xwa', 'xbc', 'xde', 'xhl'):
                        base.pop(r, None)
                else:
                    base = {}
for w in sorted(targets.values()):
    a = addr_of[w]
    print('tag 0x%02x +%-2d RAM 0x%05x  %d hits' % (w[0], w[1], a, len(hits[w])))
    for h in hits[w]:
        print('    ' + h)
