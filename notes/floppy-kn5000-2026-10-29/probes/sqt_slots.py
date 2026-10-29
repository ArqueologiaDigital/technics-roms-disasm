#!/usr/bin/env python3
"""Per-offset value variety of the KN5000 .SQT song slots (0x800 B each), plus checks of the
slot fields against the event cells. usage: sqt_slots.py <dir with extracted disks>"""
import sys,pathlib,collections,struct
root=pathlib.Path(sys.argv[1])
slots=[]   # (file, idx, bytes, cells)
for f in sorted(root.rglob('*.sqt')):
    d=f.read_bytes()
    n=10 if d[4]==1 else 1
    cells=d[n*0x800:]
    for i in range(n):
        slots.append((f'{f.parent.name}/{f.name}',i,d[i*0x800:(i+1)*0x800],cells,n))
print('files',len(set(s[0] for s in slots)),'slots',len(slots))
print('10-slot files',len(set(s[0] for s in slots if s[4]==10)))
mode=sys.argv[2] if len(sys.argv)>2 else 'var'
if mode=='var':
    lo,hi=int(sys.argv[3],0),int(sys.argv[4],0)
    for o in range(lo,hi):
        c=collections.Counter(s[2][o] for s in slots)
        print(f'+0x{o:03x}: {len(c):3d} distinct  '+' '.join(f'{v:02x}x{k}' for v,k in c.most_common(8)))
elif mode=='dump':
    lo,hi=int(sys.argv[3],0),int(sys.argv[4],0)
    for s in slots:
        print(f'{s[0]:30s} {s[1]} {s[2][lo:hi].hex(" ")}')
