import glob,collections,sys
LEN={0x90:4,0xA0:6,0xB0:3,0xC0:3,0xD0:1,0xE0:2}
SYS={0x81:0,0x82:0,0xF1:5,0xF2:6,0xF3:7,0x85:0,0x86:1}
def chains(p1,p2,rec0,nrec):
    n=len(p2)//256
    for s in range(nrec):
        r=rec0+s*RL
        for t in range(16):
            fl=p1[r+0xd0+3*t]; c=p1[r+0xd1+3*t]|p1[r+0xd2+3*t]<<8
            if fl&0x80 and c not in(0,0xffff): yield s,t,c
def walk(p2,c):
    out=bytearray(); seen=set(); cells=[]
    while c not in(0,0xffff) and c not in seen and c*256<=len(p2):
        seen.add(c); b=(c-1)*256; out+=p2[b+5:b+256]; cells.append(c); c=p2[b+3]|p2[b+4]<<8
    return bytes(out),cells
def tok(s):
    i=0; ev=collections.Counter()
    while i<len(s):
        x=s[i]
        if x<0x80:
            if i+1>=len(s): return 'tick at end',ev
            st=s[i+1]
            if st&0xf0 in LEN: n=LEN[st&0xf0]
            elif st in SYS: n=SYS[st]
            else: return 'unknown status after tick %02x at %d'%(st,i),ev
            if any(b&0x80 for b in s[i+2:i+2+n]): return 'data>=0x80 st %02x at %d'%(st,i),ev
            ev[st&0xf0 if st<0xf0 else st]+=1; i+=2+n
        elif x in SYS:
            ev[x]+=1
            if x==0x82: return 'END',ev
            i+=1+SYS[x]
        else: return 'unknown status %02x at %d'%(x,i),ev
    return 'ran off',ev
R=collections.Counter(); E=collections.Counter()
for f in glob.glob(sys.argv[1]):
    p1=open(f+'.p1.ref','rb').read(); p2=open(f+'.p2.ref','rb').read()
    RL=0x870 if b'\x01\x0a' in p1[5:7] else 0x8e0
    for s,t,c in chains(p1,p2,0,len(p1)//RL):
        st,cells=walk(p2,c); r,ev=tok(st); E+=ev
        R[r.split(' at ')[0]]+=1
        if r!='END' and R[r.split(' at ')[0]]<3: print(f,s,t,r)
print(R); print(E)
