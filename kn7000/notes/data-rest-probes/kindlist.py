#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""kindlist.py -- the generic pieces of one gap_kinds kind, biggest first, with a text preview.

QUESTION IT ANSWERS
  "Which pieces does gap_kinds.py count as text / pointers / small / other / tail, and what are they?"
  (the same classification as ../gui-data-region-probes/gap_kinds.py)

RUN (from kn7000/):  python3 notes/data-rest-probes/kindlist.py src/program/data baserom/kn7000_program.rom text 40
"""
# list generic pieces of one gap_kinds kind, biggest first, with a text preview
import re,glob,sys,os
d=sys.argv[1]; rom=open(sys.argv[2],'rb').read(); want=sys.argv[3]; N=int(sys.argv[4])
B=0x48400000; out=[]
for f in sorted(glob.glob(os.path.join(d,"data_*.s"))):
    prev="";lab=None
    for ln in open(f,encoding="latin-1"):
        mm=re.match(r'^([A-Za-z_]\w*):',ln)
        if mm: lab=mm.group(1)
        m=re.match(r'\.incbin_range "[^"]+", 0x([0-9A-F]+), 0x([0-9A-F]+)',ln)
        if m and "opaque" not in prev:
            a,b=int(m.group(1),16),int(m.group(2),16); bs=rom[a:b]
            words=[int.from_bytes(rom[k:k+4],"little") for k in range(a+(-a%4),b-3,4)]
            ptr=sum(1 for w in words if B<=w<B+len(rom) or 0x50000000<=w<0x50008000)
            pt=prev.strip() and not prev.startswith(".incbin") and not prev.strip().endswith(":")
            if b-a<8 and pt: k="tail"
            elif sum(1 for c in bs if 0x20<=c<0x7F)>=0.6*len(bs): k="text"
            elif words and 2*ptr>=len(words): k="pointers"
            elif all(c<0x80 for c in bs): k="small"
            else: k="other"
            if k==want: out.append((b-a,a,b,lab,prev.strip()[:50]))
        prev=ln
out.sort(reverse=True)
for s,a,b,lab,p in out[:N]:
    t=''.join(chr(c) if 0x20<=c<0x7f else '.' for c in rom[a:a+90])
    print(f"{s:6d} {B+a:08X} {lab} | {t}")
print(len(out), sum(o[0] for o in out))
