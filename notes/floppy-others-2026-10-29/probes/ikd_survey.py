import sys,glob,zlib,collections
import os; sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from fatls import walk
H=collections.Counter()
for m in sys.argv[1:]:
  for img in sorted(glob.glob(m+'/**/*.img',recursive=True)):
    L,rd=walk(img)
    for e in L:
        if e[0]!='FILE' or e[2]==0: continue
        d=rd(e[6],e[2]); ext=e[1].rsplit('.',1)[-1]
        H[(m,ext,d[:4],d[4:8].hex())]+=1
for k,v in sorted(H.items()): print(k,v)
