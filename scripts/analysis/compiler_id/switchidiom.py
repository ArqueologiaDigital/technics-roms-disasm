import re, os, sys
# Count the compiled-switch idiom:  add wa,wa ; lda xix,(T:24) ; ld wa,(xix+wa) ; lda xix,(B:24) ; jp t,(xix+wa)
# and check that B (the jump base) == the address of the byte after the jp.
pat=re.compile(rb'\xd8\x80\xf2(...)\x34\xd3\x07\xf0\xe0\x20\xf2(...)\x34\xf3\x07\xf0\xe0\xd8', re.S)
# 32-bit-index variant used by the KN5000:  add xwa,xwa ; add xwa,T ; ld wa,(xwa) ; lda xix,(B:24) ; jp t,(xix+wa)
pat32=re.compile(rb'\xe8\x80\xe8\xc8(....)\x90\x20\xf2(...)\x34\xf3\x07\xf0\xe0\xd8', re.S)
for spec in sys.argv[1:]:
    p,base=spec.split('@'); base=int(base,16)
    d=open(p,'rb').read()
    n=ok=0
    for m in pat.finditer(d):
        n+=1
        B=int.from_bytes(m.group(2),'little')
        jp_end=base+m.end()
        if (B & 0xffffff)==(jp_end & 0xffffff): ok+=1
    n32=ok32=0
    for m in pat32.finditer(d):
        n32+=1
        B=int.from_bytes(m.group(2),'little')
        if (B & 0xffffff)==((base+m.end()) & 0xffffff): ok32+=1
    print('%-48s 16-bit-index idiom: %4d (base==after-jp: %4d)   32-bit-index idiom: %4d (%d)'%(os.path.basename(p)[:46],n,ok,n32,ok32))
