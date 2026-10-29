import sys,collections
import os; sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from fatls import walk
import glob
for m in sys.argv[1:] or ['wsa1','kn6000','kn7000']:
    C=collections.defaultdict(lambda:[0,0,set()])
    for img in sorted(glob.glob(m+'/**/*.img',recursive=True)):
        L,rd=walk(img)
        for e in L:
            if e[0]!='FILE': continue
            ext=e[1].rsplit('.',1)[-1] if '.' in e[1].split('/')[-1] else ''
            c=C[ext]; c[0]+=1; c[1]+=e[2]; c[2].add(img.split('/')[-1][:-4])
    print('==',m)
    for k,v in sorted(C.items(),key=lambda kv:-kv[1][1]): print('  %-5s n=%3d bytes=%9d disks=%s'%(k,v[0],v[1],','.join(sorted(v[2]))))
