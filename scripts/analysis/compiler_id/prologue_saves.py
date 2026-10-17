# At function entries that allocate a frame (lda xsp,(xsp-N) or dec n,xsp right after a label),
# report which register the next instruction saves.  usage: python3 prologue_saves.py 'v10/maincpu/**/*.s'
import re, glob, sys, collections
c=collections.Counter()
for g in sys.argv[1:]:
    for f in glob.glob(g, recursive=True):
        L=open(f,'rb').read().decode('latin-1').split('\n')
        for i,l in enumerate(L):
            s=l.split(';',1)[0]
            if not re.match(r'^\s+(lda\s+xsp,\s*\(xsp\s*-\s*\d+\)|dec\s+\d,\s*xsp)\s*$',s,re.I): continue
            j=i-1
            while j>=0 and not L[j].split(';',1)[0].strip(): j-=1
            if not re.match(r'^[A-Za-z_][\w]*:',L[j]): continue
            k=i+1
            while k<len(L) and not L[k].split(';',1)[0].strip(): k+=1
            n=re.sub(r'\s+',' ',L[k].split(';',1)[0].strip().lower())
            c[n if re.match(r'(push|pushw)',n) else 'no save']+=1
for k,v in c.most_common(): print(v,k)
