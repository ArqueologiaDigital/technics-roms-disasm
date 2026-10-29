#!/usr/bin/env python3
"""For every call/jp to the song-slot accessors (Part_ReadByteDirect, Part_WriteByte, Part_ReadWord,
Part_WriteWord) in v10/maincpu, report the constant slot offset loaded into BC just before it."""
import re,pathlib,collections
acc=('Part_ReadByteDirect','Part_WriteByte','Part_ReadWord','Part_WriteWord')
rx=re.compile(rb'\b(?:call|jp|jrl?|calr)\s+('+b'|'.join(a.encode() for a in acc)+rb')\b')
bcrx=re.compile(rb'\bld[w]?\s+bc\s*,\s*(0x[0-9a-f]+|\d+)')
out=collections.defaultdict(list)
for f in sorted(pathlib.Path('v10/maincpu').rglob('*.s')):
    L=f.read_bytes().split(b'\n')
    for i,l in enumerate(L):
        c=l.split(b';')[0]
        m=rx.search(c)
        if not m: continue
        off=None
        for j in range(i-1,max(-1,i-8),-1):
            mm=bcrx.search(L[j].split(b';')[0])
            if mm: off=int(mm.group(1),0);break
            if re.match(rb'^[A-Za-z_]\w*:',L[j]): break
        # find enclosing label
        lab='?'
        for j in range(i,-1,-1):
            mm=re.match(rb'^([A-Za-z_]\w*):',L[j])
            if mm: lab=mm.group(1).decode();break
        out[off].append(f'{m.group(1).decode()} in {lab} ({f.name}:{i+1})')
for k in sorted(out,key=lambda x:(x is None,x or 0)):
    print(f'== off {k if k is None else hex(k)} ({len(out[k])})')
    for x in out[k][:8]: print('   ',x)
