#!/usr/bin/env python3
"""Which instructions reach a KN5000 panel-record byte through a base register?  panel_field_refs.py
(notes/kn5000-style-2026-10-31/probes) counts only absolute operands; this probe follows the other spelling:
a register loaded with an address inside the live panel (RAM 0xf9a0..0xffbe; `ld xR, ADDR`, `lda xR, (ADDR:16)`,
`ld xR, PANEL_NAME[+n]`, `lda xR, (PANEL_NAME[+n]:16)`) and then used as `(xR)` / `(xR + d)` / `(xR - d)` before
that register is written again or the routine ends (ret / jp / an unconditional jr / a column-0 label).
Each use is mapped to (tag, payload offset) through the firmware record lists (PanelTlv_Block0_Layout at
0xf9a0, PanelTlv_Block1_Layout at 0xfd60, v10/maincpu/ui_widgets/naka_extension_device.c).
usage: panel_base_reads.py [REPO] [--tree v10] [--tags 72,93,...]
Output: "tag 0xTT +off  file:line  instruction" per use, sorted by tag/offset.  A lower bound: a base passed
through the stack or a call is lost."""
import collections, pathlib, re, sys
args = sys.argv[1:]
tree, tags = 'v10', None
if '--tree' in args:
    i = args.index('--tree'); tree = args[i + 1]; del args[i:i + 2]
if '--tags' in args:
    i = args.index('--tags'); tags = {int(t, 16) for t in args[i + 1].split(',')}; del args[i:i + 2]
repo = pathlib.Path(args[0]) if args else pathlib.Path(__file__).resolve().parents[4]
src = (repo / 'v10/maincpu/ui_widgets/naka_extension_device.c').read_bytes().decode('latin-1')
fields = {}
for blk, base in (('PanelTlv_Block0_Layout', 0xF9A0), ('PanelTlv_Block1_Layout', 0xFD60)):
    body = src[src.index('.%s = {' % blk):]
    body = body[:body.index('\n    },')]
    for r in re.finditer(r'\{\s*(0x[0-9A-Fa-f]+),\s*SELF\((\w+)\),\s*0x([0-9A-Fa-f]+),\s*(0x[0-9A-Fa-f]+|\d+)\s*\}', body):
        pos, tag, n = int(r.group(1), 16), int(r.group(3), 16), int(r.group(4), 0)
        if tag != 0xFF:
            for o in range(n):
                fields[base + pos + 2 + o] = (tag, o)
root = repo / tree / 'maincpu'
names = {}
for f in root.glob('shared/*.s'):
    for l in f.read_bytes().split(b'\n'):
        m = re.match(rb'^\s*\.equ\s+(\w+)\s*,\s*(0x[0-9a-fA-F]+|\d+)', l)
        if m:
            names[m.group(1).decode()] = int(m.group(2), 0)
def val(tok):
    tok = tok.strip()
    m = re.fullmatch(r'(\w+)\s*([+-]\s*(?:0x[0-9a-fA-F]+|\d+))?', tok)
    if not m:
        return None
    b = m.group(1)
    if re.fullmatch(r'0x[0-9a-fA-F]+|\d+', b):
        v = int(b, 0)
    elif b in names:
        v = names[b]
    else:
        return None
    if m.group(2):
        v += int(m.group(2).replace(' ', ''), 0)
    return v
LOAD = re.compile(r'^\s*(ld|lda)\s+(x\w\w)\s*,\s*\(?\s*([\w+\- ]+?)(?::16|:24)?\s*\)?\s*$')
USE = re.compile(r'\((x\w\w)\s*(?:([+-])\s*(0x[0-9a-fA-F]+|\d+))?(?::8|:16)?\)')
hits = collections.defaultdict(list)
for f in sorted(root.rglob('*.s')):
    rel = f.relative_to(repo).as_posix()
    base = {}
    for n, raw in enumerate(f.read_bytes().decode('latin-1').split('\n'), 1):
        code = raw.split(';')[0].rstrip()
        if not code.strip():
            continue
        if re.match(r'^[A-Za-z_]\w*:', code):
            base = {}
            code = code.split(':', 1)[1]
            if not code.strip():
                continue
        c = code.strip().lower()
        m = LOAD.match(code)
        for r, s, d in USE.findall(code):
            r = r.lower()
            if r in base:
                a = base[r] + (int(d, 0) * (-1 if s == '-' else 1) if d else 0)
                if a in fields:
                    hits[fields[a]].append('%s:%d  %s' % (rel, n, raw.strip()[:80]))
        if m:
            r = m.group(2).lower()
            v = val(m.group(3))
            if v is not None and 0xF9A0 <= v <= 0xFFBE and '(' not in m.group(3):
                base[r] = v
            else:
                base.pop(r, None)
        else:
            mm = re.match(r'^\s*\w+\s+(x\w\w)\s*,', code)
            if mm and not c.startswith(('cp', 'push', 'bit')):
                base.pop(mm.group(1).lower(), None)
        if re.match(r'^(ret|reti|retd|jp\s|jrl\s+[a-z_]|jr\s+[a-z_.]\w*$|call)', c) and not re.match(r'^(jr|jp|jrl)\s+(z|nz|c|nc|ugt|ule|gt|lt|ge|le|mi|pl|ov|nov|eq|ne|t|f)\s*,', c):
            if c.startswith('call'):
                for r in ('xwa', 'xbc', 'xde', 'xhl'):
                    base.pop(r, None)
            else:
                base = {}
for k in sorted(hits):
    if tags and k[0] not in tags:
        continue
    for h in hits[k]:
        print('tag 0x%02x +%-2d  %s' % (k[0], k[1], h))
