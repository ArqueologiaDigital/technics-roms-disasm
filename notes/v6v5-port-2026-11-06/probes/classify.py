"""Which NAKA object (scripts/analysis/nakarest_objtab_map.py Map: table, record, name, propnames,
classdef, text, ... or none) covers each `; TODO(port)` row byte of a ported tree?  The question that
decided what port_todo_naka.py should type.  RUN: python3 notes/v6v5-port-2026-11-06/probes/classify.py v6
(the tree built)."""
import sys,os,re,collections,bisect
ROOT=__import__('os').path.dirname(__import__('os').path.dirname(__import__('os').path.dirname(__import__('os').path.dirname(__import__('os').path.abspath(__file__)))))
sys.path[:0]=[ROOT+'/scripts/converters',ROOT+'/scripts/analysis',ROOT+'/scripts/tools',ROOT+'/scripts/generators']
import port_maincpu_version as P
import nakarest_objtab_map as O
tree=sys.argv[1]
order,syms,built=P.tree_map(tree)
TODO=re.compile(r'^;\s*TODO\(port\)'); ROW=re.compile(r'^\t\.byte\t(0x[0-9a-f]{2}(?:, 0x[0-9a-f]{2}){0,7})\s*$')
KEEP=re.compile(r"^\s*$|^\s*;|^\s*(?:[A-Za-z_.$][\w.$]*\s*:\s*)+$")
todo=[]  # (addr,n,file,line)
inb=False
for e in order:
    a,f,ln,txt=e[0],e[1],e[2],e[3]
    if TODO.match(txt): inb=True; continue
    if not inb: continue
    m=ROW.match(txt)
    if m: todo.append((a,len(m.group(1).split(', ')),f,ln))
    elif KEEP.match(txt): continue
    else: inb=False
print('todo bytes',sum(n for a,n,f,l in todo))
M=O.Map(tree)
objs=[]
for a,lst in M.addr.items():
    for kind,r,k in lst:
        ext=M.extent(kind,r,k,a)
        if ext: objs.append((a,a+ext,kind,r['slot'] if r else None,k))
objs.sort()
cnt=collections.Counter(); per=collections.defaultdict(collections.Counter)
for a,n,f,l in todo:
    for x in range(a,a+n):
        best=None
        for o in objs:
            if o[0]<=x<o[1]:
                if best is None or o[1]-o[0]<best[1]-best[0]: best=o
            if o[0]>x: break
        k=best[2] if best else 'none'
        cnt[k]+=1; per[f][k]+=1
print(cnt)
for f,c in sorted(per.items()): print(' ',f,dict(c))
