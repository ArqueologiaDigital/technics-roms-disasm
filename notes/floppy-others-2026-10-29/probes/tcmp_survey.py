import sys,glob,collections
def ev_len(d,o):
    s=d[o]
    if s==0xF0: return d[o+1]+2
    return {0x90:6,0xB0:3,0xC0:4,0xD0:2,0xE0:3}.get(s&0xF0,1)
def u24(p,o): return p[o]<<16|p[o+1]<<8|p[o+2]
def fmt(d,o,n):
    c=d[o]; a=d[o+1:o+n]
    if c==0xF4: return '\tev_beat'
    if c==0xF5: return '\tev_end'
    if c<0x80: return '\tev_at\t%d'%c
    h=c&0xf0; p=c&15
    if h==0x90: return '\tev_note\t%d, %d, %d, %d, %d, %d'%(p,*a)
    if h==0xB0: return '\tev_cc\t%d, %d, %d'%(p,*a)
    if h==0xC0: return '\tev_pc\t%d, 0x%02x, 0x%02x, 0x%02x'%(p,*a)
    if h==0xE0: return '\tev_bend\t%d, %d, %d'%(p,*a)
    if h==0xD0: return '\tev_press\t%d, %d'%(p,*a)
    return '\t.byte\t'+', '.join('0x%02x'%x for x in d[o:o+n])
# Walk each heap as the firmware's objects: [variation index, u24BE length, events] (MemStyleAreaStreamsVerify).
tb=tt=0; C=collections.Counter(); bad=0
for f in sorted(glob.glob(sys.argv[1])):
    p=open(f,'rb').read()
    if p[:4]!=b'TCMP': C['notcmp']+=1; continue
    top=u24(p,0x13); o=0x3670
    while o<top:
        L=u24(p,o+1); s=o+4; e=s+L; q=s
        if p[s]!=0xF4 or p[e-1]!=0xF5: bad+=1; break
        while q<e:
            n=ev_len(p,q); line=fmt(p,q,n); tt+=len(line)+1; C[line.split('\t')[1]]+=1; q+=n
        if q!=e: bad+=1
        tb+=e-o; o=e
    if o!=top: bad+=1; print('BAD',f,hex(o),hex(top))
print('bytes',tb,'text',tt,'ratio %.2f'%(tt/tb),'bad',bad); print(C.most_common(12))
