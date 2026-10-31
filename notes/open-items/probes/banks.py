# Question: where (by 64 KB bank of the file) do a tree's census-opaque bytes lie?  Usage: banks.py opaque.txt <tree> <worktree>
import re,collections,sys
R=sys.argv[3].rstrip('/')+'/'
rows=[l.rstrip('\n').split('\t') for l in open(sys.argv[1]) if l.startswith(sys.argv[2]+'\t')]
cache={}; tot=collections.Counter(); n=collections.Counter()
for t,src,cnt,f,why in rows:
    p,ln=src.rsplit(':',1); ln=int(ln)
    if p not in cache: cache[p]=open(R+p,'rb').read().decode('latin1').split('\n')
    s=' '.join(cache[p][ln-2:ln+1])
    m=re.search(r'incbin_range "[^"]+", 0x([0-9A-Fa-f]+)',s)
    if not m: continue
    a=int(m.group(1),16)>>16
    k=why.split(';')[0].split(' of ')[-1][:40]
    tot[(a,k)]+=int(cnt); n[(a,k)]+=1
for (a,k),v in sorted(tot.items(), key=lambda x:-x[1])[:int(sys.argv[4]) if len(sys.argv)>4 else 15]: print(hex(a<<16), k, n[(a,k)], v)
