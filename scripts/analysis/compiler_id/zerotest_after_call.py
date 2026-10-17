# Count, in a set of .s files, the instruction right after each call/calr when it is a zero-test
# of L/HL/XHL versus A/WA/XWA.  usage: python3 zerotest_after_call.py 'v10/maincpu/**/*.s'
import re, glob, sys, collections
files=[]
for g in sys.argv[1:]: files+=glob.glob(g, recursive=True)
cnt=collections.Counter()
call=re.compile(r'^\s+(call|calr)\b', re.I)
tests={'cp l,0':r'cp\s+l,\s*(0|0:i3|0x0)','cp hl,0':r'cp\s+hl,\s*(0|0:i3|0x0)','or xhl,xhl|cp xhl,0':r'(or\s+xhl,\s*xhl|cp\s+xhl,\s*(0|0:i3|0x0))',
       'cp a,0':r'cp\s+a,\s*(0|0:i3|0x0)','cp wa,0':r'cp\s+wa,\s*(0|0:i3|0x0)','or xwa,xwa|cp xwa,0':r'(or\s+xwa,\s*xwa|cp\s+xwa,\s*(0|0:i3|0x0))'}
for f in files:
    L=open(f,'rb').read().decode('latin-1').split('\n')
    for i,l in enumerate(L):
        if not call.match(l.split(';',1)[0]): continue
        j=i+1
        while j<len(L) and not L[j].split(';',1)[0].strip(): j+=1
        if j>=len(L): continue
        n=L[j].split(';',1)[0]
        for k,p in tests.items():
            if re.match(r'^\s+'+p+r'\s*$',n,re.I): cnt[k]+=1
for k in tests: print('%-22s %d'%(k,cnt[k]))
