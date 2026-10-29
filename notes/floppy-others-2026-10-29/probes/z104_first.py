import sys,glob,zlib,subprocess,collections
import os; sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from fatls import walk
Z=os.environ.get('Z104', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'z104'))
def enc(p,lvl=6):
    return subprocess.run([Z,str(lvl)],input=p,capture_output=True,check=True).stdout
R=collections.Counter(); ex={}
for m in sys.argv[1:]:
  for img in sorted(glob.glob(m+'/**/*.img',recursive=True)):
    L,rd=walk(img)
    for e in L:
        if e[0]!='FILE' or e[2]==0: continue
        d=rd(e[6],e[2]); ext=e[1].rsplit('.',1)[-1]
        start=None
        for st in (0x10,0x18,0x20,0x14,0x1c,0x0c,0x08,0x28,0x30):
            try:
                o=zlib.decompressobj(-15); p=o.decompress(d[st:])
                if o.eof and len(p)>16: start=st; break
            except Exception: pass
        if start is None: R[(m,ext,'nostream')]+=1; continue
        end=len(d)-len(o.unused_data); raw=d[start:end]
        r=enc(p); body=r[2:-4]; ad=r[-4:]
        res=('body-ok' if body==raw else 'body-BAD')+(' adler-follows' if d[end:end+4]==ad else ' no-adler')
        R[(m,ext,'@%x'%start,res)]+=1; ex.setdefault((m,ext,res),(img,e[1]))
for k,v in sorted(R.items()): print(k,v)
for k,v in ex.items():
    if 'BAD' in k[2]: print(k,v)
