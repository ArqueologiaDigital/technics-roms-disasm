#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""pieces.py -- the biggest generic pieces of a typed data region.

QUESTION IT ANSWERS
  "Which .incbin_range pieces of src/<build>/program/data/ are biggest, under which label, and what do
   their first bytes look like?"

RUN (from kn7000/):  python3 notes/data-rest-probes/pieces.py src/program/data baserom/kn7000_program.rom [N]
"""
import re,glob,sys,os
d=sys.argv[1]; rom=open(sys.argv[2],'rb').read()
out=[]
for f in sorted(glob.glob(os.path.join(d,"data_*.s"))):
    lines=open(f,encoding='latin-1').read().split('\n')
    lab=None; prevtyped=None
    for i,ln in enumerate(lines):
        m=re.match(r'^([A-Za-z_]\w*):',ln)
        if m: lab=m.group(1)
        m=re.match(r'\.incbin_range "[^"]+", 0x([0-9A-F]+), 0x([0-9A-F]+)',ln)
        if m:
            a,b=int(m.group(1),16),int(m.group(2),16)
            out.append((b-a,a,b,lab,os.path.basename(f),i+1))
out.sort(reverse=True)
N=int(sys.argv[3]) if len(sys.argv)>3 else 60
for s,a,b,lab,f,l in out[:N]:
    bs=rom[a:b]
    print(f"{s:7d} {0x48400000+a:08X}-{0x48400000+b:08X} {f}:{l} {lab}  {bs[:24].hex(' ')}")
