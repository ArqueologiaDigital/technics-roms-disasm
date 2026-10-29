import sys,itertools
import os; sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from fatls import walk
L,rd=walk('kn7000/ca7001/ca7001.img')
d=[rd(e[6],e[2]) for e in L if e[0]=='FILE' and e[1]=='01SLWLTZ.CMP'][0]
c=d[0x10:]
# tokenise first 12 flag groups
toks=[];i=0
while len(toks)<90:
    f=c[i];i+=1
    for b in range(8):
        if f>>b&1: toks.append(('L',c[i]));i+=1
        else: toks.append(('R',c[i],c[i+1]));i+=2
print(toks[34:80])
exp={}
for k in range(13,16): exp[k]=0
for k in range(0x31,0x6f): exp[k]=0x20
for k,ch in enumerate(b'Slow Waltz'): exp[0x70+k]=ch
def run(be,sl,x,T,mode,S):
    w=bytearray(4096); out=bytearray(); wp=S
    for t in toks:
        if len(out)>0x7a: break
        if t[0]=='L': out.append(t[1]); w[wp]=t[1]; wp=(wp+1)&0xfff; continue
        v=(t[1]<<8|t[2]) if be else (t[2]<<8|t[1])
        f=(v>>sl)&0xf; rest=((v>>(sl+4))<<sl | (v & ((1<<sl)-1)))&0xfff
        ln=(f^x)+T
        if mode==0: src=rest
        elif mode==1: src=(wp-rest)&0xfff
        elif mode==2: src=(wp-rest-1)&0xfff
        for k in range(ln):
            b=w[(src+k)&0xfff]; out.append(b); w[wp]=b; wp=(wp+1)&0xfff
    return out
best=[]
for be in ():
 for sl in (0,4,8,12):
  for x in (0,8,15,7):
   for T in (1,2,3):
    for mode in (0,1,2):
     for S in (range(4096) if mode==0 else [0]):
        o=run(be,sl,x,T,mode,S)
        sc=sum(1 for k,v in exp.items() if k<len(o) and o[k]==v)
        if sc>=len(exp)-3: print('HIT',be,sl,x,T,mode,hex(S),sc,len(exp))
        best.append((sc,be,sl,x,T,mode,S))
best.sort(reverse=True); print(best[:5],len(exp))
o=run(0,8,8,3,0,0xff6)
for i in range(0,len(o),16): print('%04x'%i,o[i:i+16].hex(' '))
