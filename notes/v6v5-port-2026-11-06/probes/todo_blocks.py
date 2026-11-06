#!/usr/bin/env python3
"""Which `; TODO(port)` row blocks does a ported tree (v6, v5) still have?

For every block (the porter's marker and its `\t.byte\t0x..` rows, as
scripts/analysis/kn5000_source_coverage.py port_todo_bytes reads them): file:line, its byte count, the
label before it, the labels inside it, and the first bytes as hex and ASCII.
RUN (repository root): python3 notes/v6v5-port-2026-11-06/probes/todo_blocks.py v6
"""
import os
os.chdir(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))))
import re,glob,sys
PORT_TODO = re.compile(r';\s*TODO\(port\)')
PORT_ROW = re.compile(r'^\t\.byte\t(0x[0-9a-f]{2}(?:, 0x[0-9a-f]{2}){0,7})\s*$')
LABELS_ONLY = re.compile(r'^\s*(?:[A-Za-z_.$][\w.$]*\s*:\s*)+$')
tree=sys.argv[1]
for f in sorted(glob.glob(f'{tree}/maincpu/**/*.s',recursive=True)):
    L=open(f,encoding='latin-1').read().split('\n')
    i=0
    while i<len(L):
        if PORT_TODO.search(L[i]):
            start=i; bs=[]; lab=None
            # label before
            for k in range(i-1,max(0,i-30),-1):
                m=re.match(r'^([A-Za-z_.$][\w.$]*):',L[k])
                if m: lab=m.group(1);break
            j=i+1; inner=[]
            while j<len(L):
                m=PORT_ROW.match(L[j])
                if m: bs+= [int(x,16) for x in m.group(1).split(', ')]
                elif not L[j].split(';')[0].strip() or LABELS_ONLY.match(L[j].split(';')[0]):
                    mm=re.match(r'^([A-Za-z_.$][\w.$]*):',L[j])
                    if mm: inner.append((len(bs),mm.group(1)))
                else: break
                j+=1
            nxt=L[j][:90] if j<len(L) else ''
            asc=''.join(chr(b) if 32<=b<127 else '.' for b in bs[:48])
            print(f"{f}:{start+1}\t{len(bs)}\tafter={lab}\tinner={inner[:4]}{'...' if len(inner)>4 else ''}")
            print(f"    {L[i].strip()[:100]}")
            print(f"    hex {' '.join('%02x'%b for b in bs[:24])}")
            print(f"    asc {asc}")
            print(f"    next {nxt}")
            i=j
        else: i+=1
