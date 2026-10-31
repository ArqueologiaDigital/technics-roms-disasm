#!/usr/bin/env python3
"""Who reads or writes each field of the KN5000 current-song record (SEQ_SONG_RECORD 0xf180, saved as the .SQT
song slot), in every maincpu tree?  One recorded search per field of notes/floppy-kn5000-2026-10-29/specs/
sqt_slot_header.json, in five spellings:
  ABS   an absolute operand 0xf180 + off (hex or decimal), SEQ_SONG_RECORD+off, or any `.equ` name of the tree
        whose value lies in the record (SQEDT_QTZ_FROM, ...), alone or as NAME+n;
  DISP  a displacement (xRR + d) or `add xRR, d` / `lda xRR, (xRR + d)` within WINDOW lines after an instruction
        that names a song-record base: SEQ_SONG_RECORD, SEQ_SONG_SLOTS, 0xf180 / 61824, 0xab000 / 700416;
  PART  a call of a slot accessor (Part_ReadByteDirect, Part_WriteByte, Part_ReadWord, Part_WriteWord) with the
        constant offset loaded into BC within the 8 lines before it (notes/floppy-kn5000-2026-10-29/probes/
        partcalls.py's rule);
  BLOCK a block copy (ldir / ldirw / ldir85) whose source or destination is a song-record base, listed once per
        field it covers when its length is a constant;
  (DISP and BLOCK rows are candidates: the register may have been reloaded in between; every quoted row was read.)
usage: sqt_field_refs.py [REPO] [--trees v10,v9,v7,v6,v5] [--window N] [--field NAME ...] [--summary]
Output: per field "== name rec+0xOFF size" then its rows "KIND tree file:line routine | instruction", then
"   counts: ABS a DISP d PART p BLOCK b" (all trees)."""
import collections, json, pathlib, re, sys

args = sys.argv[1:]
def opt(name, default, conv=str, multi=False):
    if name not in args:
        return default
    i = args.index(name)
    if multi:
        vals = []
        j = i + 1
        while j < len(args) and not args[j].startswith('--'):
            vals.append(args[j]); j += 1
        del args[i:j]
        return vals
    v = conv(args[i + 1]); del args[i:i + 2]; return v
trees = opt('--trees', 'v10,v9,v7,v6,v5').split(',')
win = opt('--window', 16, int)
only = opt('--field', None, multi=True)
summary = '--summary' in args
if summary:
    args.remove('--summary')
repo = pathlib.Path(args[0]) if args else pathlib.Path(__file__).resolve().parents[3]
spec = json.load(open(repo / 'notes/floppy-kn5000-2026-10-29/specs/sqt_slot_header.json'))
fields = [(f['name'], r['base'] + f['off'], f['size']) for r in spec['regions'].values() for f in r['fields']]
if only:
    fields = [f for f in fields if f[0] in only]
BASE = 0xF180
num = re.compile(rb'(?<![\w.])(0x[0-9a-fA-F]+|\d+)(?![\w])')
symoff = re.compile(rb'SEQ_SONG_RECORD\s*\+\s*(0x[0-9a-fA-F]+|\d+)')
basere = re.compile(rb'SEQ_SONG_RECORD|SEQ_SONG_SLOTS|\b0x0*f180\b|\b61824\b|\b0x0*ab000\b|\b700416\b', re.I)
disp = re.compile(rb'\((x[a-z]{2,3})\s*\+\s*(0x[0-9a-fA-F]+|\d+)(?::8|:16)?\)|\badd\s+x[a-z]{2,3}\s*,\s*(0x[0-9a-fA-F]+|\d+)\s*$')
acc = re.compile(rb'\b(?:call|jp|jrl?|calr)\s+(Part_ReadByteDirect|Part_WriteByte|Part_ReadWord|Part_WriteWord)\b')
bcld = re.compile(rb'\bld[w]?\s+bc\s*,\s*(0x[0-9a-fA-F]+|\d+)')
label = re.compile(rb'^([A-Za-z_$][\w$]*):')
def val(t):
    return int(t, 16) if t[:2] in (b'0x', b'0X') else int(t)
hits = collections.defaultdict(list)       # rec offset -> [(kind, tree, where, routine, text)]
equ = re.compile(rb'^\s*\.(?:equ|set)\s+([A-Za-z_]\w*)\s*,\s*(0x[0-9a-fA-F]+|\d+)\s*(?:;|$)')
for tree in trees:
    root = repo / tree / 'maincpu'
    names = {}
    for f in root.rglob('*.s'):
        for l in f.read_bytes().split(b'\n'):
            m = equ.match(l)
            if m:
                v = int(m.group(2), 0)
                if BASE <= v < BASE + 0x800 and m.group(1) != b'SEQ_SONG_RECORD':
                    names[m.group(1)] = v - BASE
    namere = re.compile(rb'\b(' + b'|'.join(sorted(names, key=len, reverse=True)) + rb')\b(?:\s*\+\s*(0x[0-9a-fA-F]+|\d+))?') if names else None
    for f in sorted(root.rglob('*.s')):
        L = f.read_bytes().split(b'\n')
        rel = f.relative_to(repo).as_posix()
        rout, left = '?', 0
        for n, l in enumerate(L, 1):
            code = l.split(b';')[0]
            m = label.match(l)
            if m:
                rout = m.group(1).decode()
            if not code.strip() or code.lstrip().startswith((b'.equ', b'.set')):
                continue
            txt = l.strip().decode('latin-1')[:110]
            for t in symoff.findall(code):
                hits[val(t)].append(('ABS', tree, f'{rel}:{n}', rout, txt))
            if namere:
                for nm, plus in namere.findall(code):
                    hits[names[nm] + (val(plus) if plus else 0)].append(('ABS', tree, f'{rel}:{n}', rout, txt))
            if not symoff.search(code):
                for t in num.findall(code):
                    v = val(t)
                    if BASE <= v < BASE + 0x800 and b'.incbin' not in code:
                        hits[v - BASE].append(('ABS', tree, f'{rel}:{n}', rout, txt))
            ma = acc.search(code)
            if ma:
                for j in range(n - 2, max(-1, n - 10), -1):
                    mm = bcld.search(L[j].split(b';')[0])
                    if mm:
                        hits[val(mm.group(1))].append(('PART', tree, f'{rel}:{n}', rout, txt + '  [BC=' + mm.group(1).decode() + ']'))
                        break
                    if label.match(L[j]):
                        break
            if basere.search(code):
                left = win
                continue
            if left:
                left -= 1
                for g in disp.findall(code):
                    t = g[1] or g[2]
                    if t:
                        hits[val(t)].append(('DISP', tree, f'{rel}:{n}', rout, txt))
for name, off, size in fields:
    rows = [h for o in range(off, off + size) for h in hits.get(o, [])]
    c = collections.Counter(r[0] for r in rows)
    print(f'== {name} rec+0x{off:03x} size {size}')
    if not summary:
        for k, tree, where, rout, txt in rows:
            print(f'   {k:5s} {tree:4s} {where} {rout} | {txt}')
    print('   counts: ' + ' '.join(f'{k} {c.get(k, 0)}' for k in ('ABS', 'DISP', 'PART')))
