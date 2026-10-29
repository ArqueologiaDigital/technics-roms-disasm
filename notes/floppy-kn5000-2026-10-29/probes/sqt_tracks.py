#!/usr/bin/env python3
"""Checks the SQT slot's per-track fields against the event cells:
 +0xd0 + 3t : {u8 flags (bit7 = track holds data), u16 first cell}
 +0x78 + 2t : u16 tail cell (the chain's last cell)
 +0x98 + t  : u8 write offset in the tail cell (5..0xff)
 +0x1e      : u16 track mask (bit t)
 +0x4e      : u16 used event memory / 16
 +0xaf/+0xb1: free-list head, free-block count
usage: sqt_tracks.py <dir>"""
import sys,pathlib,struct,collections
C=collections.Counter()
for f in sorted(pathlib.Path(sys.argv[1]).rglob('*.sqt')):
    d=f.read_bytes(); n=10 if d[4]==1 else 1
    cells=d[n*0x800:]; nc=len(cells)//256
    def cell(c): return cells[(c-1)*256:c*256]
    for i in range(n):
        s=d[i*0x800:(i+1)*0x800]
        mask=struct.unpack_from('<H',s,0x1e)[0]
        used=struct.unpack_from('<H',s,0x4e)[0]
        fh,fb=struct.unpack_from('<HH',s,0xaf)
        for t in range(16):
            fl=s[0xd0+3*t]; st=struct.unpack_from('<H',s,0xd1+3*t)[0]
            tail=struct.unpack_from('<H',s,0x78+2*t)[0]; off=s[0x98+t]
            present=bool(fl&0x80)
            if not present:
                C['absent']+=1
                if tail==0xffff and off==5: C['absent: tail ffff, off 5']+=1
                if (mask>>t)&1: C['absent but mask bit set']+=1
                continue
            C['present']+=1
            if (mask>>t)&1: C['present & mask bit']+=1
            if not(1<=st<=nc): C['start out of file']+=1; continue
            if struct.unpack_from('<H',cell(st),1)[0]==0: C['start PREV=0']+=1
            # walk
            c=st;seen=set();last=None
            while c!=0xffff and 1<=c<=nc and c not in seen:
                seen.add(c); last=c; c=struct.unpack_from('<H',cell(c),3)[0]
            if last==tail: C['tail == chain end']+=1
            else: C['tail != chain end']+=1
            tc=cell(tail) if 1<=tail<=nc else b''
            if tc and off<=255:
                # end marker 0x82 position
                p=tc.rfind(b'\x82',5,off+1)
                if off>=1 and tc[off-1]==0x82: C['byte before off == 0x82']+=1
                elif off<256 and tc[off]==0x82: C['byte at off == 0x82']+=1
                else: C['0x82 not next to off']+=1
        C['slots']+=1
        if used: 
            C['slot used!=0']+=1
            if used*16==len(cells): C['used*16 == cell bytes in file']+=1
            else: C[f'used*16 != cells']+=1
            if fh==nc+1: C['free head == cells+1']+=1
            if nc+fb==1240: C['cells + free == 1240']+=1
for k,v in C.items(): print(f'{v:6d}  {k}')
