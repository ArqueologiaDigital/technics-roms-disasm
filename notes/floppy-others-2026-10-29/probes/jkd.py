# J KD LZSS hypothesis: flags LSB-first (1 = literal); ref = lo, hi: offset13 = lo | (hi>>3)<<8, len = (hi&7)+3; 8 KB ring, start 0x1ff6, prefill 0
def unjkd(c, n=None, S=0x1ff6, pf=0):
    w=bytearray([pf])*0x2000; wp=S; out=bytearray(); i=0
    while i<len(c) and (n is None or len(out)<n):
        f=c[i]; i+=1
        for b in range(8):
            if (n is not None and len(out)>=n) or i>=len(c): break
            if f>>b&1:
                x=c[i]; i+=1; out.append(x); w[wp]=x; wp=(wp+1)&0x1fff
            else:
                lo,hi=c[i],c[i+1]; i+=2; off=lo|(hi>>3)<<8; ln=(hi&7)+3
                for k in range(ln):
                    x=w[(off+k)&0x1fff]; out.append(x); w[wp]=x; wp=(wp+1)&0x1fff
    return bytes(out), i
if __name__=='__main__':
    import sys
    import os; sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
    from fatls import walk
    L,rd=walk('kn7000/ca7001/ca7001.img')
    d=[rd(e[6],e[2]) for e in L if e[0]=='FILE' and e[1]=='01SLWLTZ.CMP'][0]
    o,i=unjkd(d[0x10:],0xbbdd); print(len(o),i,len(d)-0x10, d[0x10+i:].hex())
    for k in range(0,0x100,16): print('%04x'%k,o[k:k+16].hex(' '), bytes(x if 32<=x<127 else 46 for x in o[k:k+16]).decode())
