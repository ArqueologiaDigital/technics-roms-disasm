#!/usr/bin/env python3
"""List v10 maincpu source lines referencing RAM addresses in [lo,hi) by hex literal or by
names .equ'd there. usage: ramrefs.py lo hi [tree]"""
import re,sys,pathlib,collections
lo,hi=int(sys.argv[1],0),int(sys.argv[2],0)
tree=pathlib.Path(sys.argv[3] if len(sys.argv)>3 else 'v10/maincpu')
files=sorted(tree.rglob('*.s'))
names={}
eq=re.compile(rb'^\s*\.(?:equ|set)\s+([A-Za-z_][\w]*)\s*,\s*(0x[0-9a-fA-F]+|\d+)')
for f in files:
    for l in f.read_bytes().split(b'\n'):
        m=eq.match(l)
        if m:
            v=int(m.group(2),0)
            if lo<=v<hi: names[m.group(1).decode()]=v
hexre=re.compile(rb'0x([0-9a-fA-F]{3,6})\b')
out=collections.defaultdict(list)
for f in files:
    for i,l in enumerate(f.read_bytes().split(b'\n'),1):
        code=l.split(b';')[0]
        if not code.strip() or code.lstrip().startswith(b'.equ'): continue
        hit=None
        for m in hexre.finditer(code):
            v=int(m.group(1),16)
            if lo<=v<hi: hit=v;break
        if hit is None:
            for n,v in names.items():
                if re.search(rb'\b'+n.encode()+rb'\b',code): hit=v;break
        if hit is not None:
            out[hit].append(f'{f}:{i}: {l.decode("latin1").strip()}')
for v in sorted(out):
    print(f'== 0x{v:x} (+0x{v-lo:x}) {len(out[v])} refs')
    for x in out[v][:int(sys.argv[4]) if len(sys.argv)>4 else 6]: print('   ',x)
