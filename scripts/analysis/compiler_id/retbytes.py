import re, os, sys
# Byte-level census: call imm24 (1d xx xx xx) or calr (1e xx xx) immediately followed by a compact
# zero-test of a register:  cp L,0 = cf d8 ; cp HL,0 = db d8 ; cp A,0 = c9 d8 ; cp WA,0 = d8 d8
# Approximate (linear scan, data can alias), but the same method is applied to every image.
tests={'L':b'\xcf\xd8','HL':b'\xdb\xd8','A':b'\xc9\xd8','WA':b'\xd8\xd8'}
for p in sys.argv[1:]:
    d=open(p,'rb').read()
    out=[]
    for k,t in tests.items():
        n=len(re.findall(rb'\x1d...'+re.escape(t),d,re.S))+len(re.findall(rb'\x1e..'+re.escape(t),d,re.S))
        out.append('%s=%d'%(k,n))
    print(os.path.basename(p)[:40].ljust(42),'  '.join(out))
