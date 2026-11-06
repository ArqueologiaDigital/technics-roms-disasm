"""Which records of a ported tree point (propdata letters m..s) into a block of the work-RAM image, and
at which cell offsets?  The evidence for port_todo_naka.py's work-cell typing.
RUN: python3 notes/v6v5-port-2026-11-06/probes/cells.py v6 Murai_SoundMenuWorkCells 696"""
import sys,os,collections
ROOT=__import__('os').path.dirname(__import__('os').path.dirname(__import__('os').path.dirname(__import__('os').path.dirname(__import__('os').path.abspath(__file__)))))
for d in ('converters','tools','analysis','generators'): sys.path.insert(0,ROOT+'/scripts/'+d)
import nakarest_objtab_map as O, gen_naka_gui_headers as H
tree=sys.argv[1]; lab=sys.argv[2]; n=int(sys.argv[3])
st=H.tree_syms(tree); im=H.work_ram_images(tree,st); print(im)
M=O.Map(tree)
a0=M.sym[lab]
(dst,src,sz)=[x for x in im if x[1]<=a0<x[1]+x[2]][0]
r0=a0-src+dst; print('ram %x..%x'%(r0,r0+n))
refs=collections.defaultdict(list)
def img(a):
    for d,s,z in im:
        if d<=a<d+z: return a-d+s
    return None
recs=[]
for a,lst in M.addr.items():
    for kind,r,k in lst:
        if kind=='record': recs.append((a,r,k))
for a,r,k in recs:
    ra=a if M.inrom(a) else img(a)
    if ra is None: continue
    c=M.record_class(ra)
    if not c: continue
    for off,f,ch in M.class_fields(c):
        if ch in 'mnopqrs':
            v=M.u32(ra+off)
            if r0<=v<r0+n: refs[v].append((ch,f,r['slot'],k,c['name'],M.name_of(ra)[1] if M.name_of(ra)[0]==ra else None))
for v in sorted(refs): print('%5x %s'%(v-r0,refs[v][:2]))
print(len(refs))
