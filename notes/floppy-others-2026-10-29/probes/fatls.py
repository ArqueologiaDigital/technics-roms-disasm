import sys, struct
def walk(img, extract=None):
    b = open(img,'rb').read()
    bps, spc, rsv, nfat, nroot, tot, md, spf = struct.unpack_from('<HBHBHHBH', b, 11)
    fat = b[rsv*bps:(rsv+spf)*bps]
    def nxt(c):
        o = c*3//2; v = fat[o] | fat[o+1]<<8
        return (v>>4) if c&1 else (v&0xfff)
    rootoff = (rsv+nfat*spf)*bps; dataoff = rootoff + nroot*32
    def chain(c):
        out=[]
        while 2<=c<0xff8: out.append(c); c=nxt(c)
        return out
    def rd(c, size):
        return b''.join(b[dataoff+(x-2)*spc*bps:dataoff+(x-1)*spc*bps] for x in chain(c))[:size]
    def ents(raw, path):
        for i in range(0,len(raw),32):
            e=raw[i:i+32]
            if e[0]==0: break
            if e[0]==0xe5 or e[11]==0x0f: continue
            name=e[0:8].decode('latin-1').rstrip(); ext=e[8:11].decode('latin-1').rstrip()
            attr=e[11]; clus=struct.unpack_from('<H',e,26)[0]; size=struct.unpack_from('<I',e,28)[0]
            t,d=struct.unpack_from('<HH',e,22)
            n=name+('.'+ext if ext else '')
            if attr&8: yield ('LABEL',path+n,0,attr,d,t); continue
            if attr&0x10:
                if name in('.','..'): continue
                yield ('DIR',path+n,0,attr,d,t)
                yield from ents(b''.join(b[dataoff+(x-2)*spc*bps:dataoff+(x-1)*spc*bps] for x in chain(clus)), path+n+'/')
            else:
                yield ('FILE',path+n,size,attr,d,t,clus)
    return list(ents(b[rootoff:dataoff],'')), rd
if __name__=='__main__':
    for img in sys.argv[1:]:
        L,rd=walk(img)
        print('==',img)
        for e in L:
            d=e[4]; print(' %-5s %-30s %8d attr=%02x %04d-%02d-%02d'%(e[0],e[1],e[2],e[3],1980+(d>>9),(d>>5)&15,d&31))
