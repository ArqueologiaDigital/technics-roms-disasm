#!/usr/bin/env python3
"""Per-offset value variety of the KN5000 .CMP style bank (= RAM image of RHYTHM_PATTERN_BUF_A 0x94800).
usage: cmp_var.py <dir> hdr|rec|pre LO HI   (rec offsets are relative to a 0x60-byte directory record)"""
import sys,pathlib,collections
banks=[(f'{f.parent.name}/{f.name}',f.read_bytes()) for f in sorted(pathlib.Path(sys.argv[1]).rglob('*.cmp'))]
mode=sys.argv[2]; lo,hi=int(sys.argv[3],0),int(sys.argv[4],0)
print('banks',len(banks))
for o in range(lo,hi):
    if mode=='rec': vals=[d[0x60+r*0x60+o] for _,d in banks for r in range(30)]
    else: vals=[d[o] for _,d in banks if len(d)>o]
    c=collections.Counter(vals)
    print(f'+0x{o:03x}: {len(c):3d} distinct  '+' '.join(f'{v:02x}x{k}' for v,k in c.most_common(10)))
