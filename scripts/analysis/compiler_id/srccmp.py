import sys, re, subprocess, os
# Compare a Toshiba runtime .ASM/.MAC source (instruction lines only) with MAME unidasm's
# disassembly of the same number of instructions taken from a ROM image.
# Normalisation: lower case; branch mnemonics j/jr/jrl/jp -> "j", cal/call/calr -> "cal";
# condition aliases unified; branch targets, labels, numbers dropped; "0x0f" vs "15" kept as numbers -> N.
# usage: srccmp.py SRC ROM FILEBASE ADDR [max_insns]
src, rom, base, addr = sys.argv[1], sys.argv[2], int(sys.argv[3],16), int(sys.argv[4],16)
UNIDASM=os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..', 'tools', 'unidasm')
CC={'eq':'z','z':'z','ne':'nz','nz':'nz','ult':'c','c':'c','uge':'nc','nc':'nc','ov':'ov','pe/ov':'ov','pe':'ov',
    'gt':'gt','lt':'lt','ge':'ge','le':'le','ugt':'ugt','ule':'ule','t':'','mi':'lt','m/mi':'lt',
    'nov':'nov','po':'nov','po/nov':'nov'}
def norm(mn, ops):
    mn=mn.lower(); ops=ops.lower().replace(' ','')
    if mn in ('ldirw','ldir','ldirb'): return {'ldirb':'ldir'}.get(mn,mn)
    if mn in ('ldi', 'ldd', 'ldib', 'lddb'): return mn[:3]   # Toshiba's byte forms; unidasm prints a bare ldi / ldd
    if mn in ('ldw','ldb'): mn='ld'
    ops=re.sub(r'\(xsp\+?','(xsp+',ops)
    if mn in ('j','jr','jrl','jp'):
        parts=ops.split(',')
        cc=CC.get(parts[0],None) if len(parts)>1 else ''
        if cc is None: cc=parts[0]
        return 'j '+cc
    if mn in ('cal','call','calr'): return 'cal'
    if mn=='djnz': return 'djnz '+ops.split(',')[0]
    if mn=='ret' and ops: return 'ret '+CC.get(ops,ops)
    if mn=='scc': p=ops.split(','); return 'scc %s,%s'%(CC.get(p[0],p[0]),p[1])
    if os.environ.get('STRICT'):
        ops=re.sub(r'0x[0-9a-f]+|\b\d+\b', lambda m: '#%d'%(int(m.group(0),16) if m.group(0).startswith('0x') else int(m.group(0))), ops)
    else:
        ops=re.sub(r'0x[0-9a-f]+|\b\d+\b','N',ops)
    REGS=set('a w b c d e h l wa bc de hl ix iy iz sp xwa xbc xde xhl xix xiy xiz xsp qwa qbc qde qhl qix qiy qiz qsp qw qa qb qc qd qe qh ql ixl ixh iyl iyh izl izh qixl qixh qiyl qiyh qizl qizh f sr'.split())
    ops=re.sub(r'[a-z_.][a-z0-9_.]*', lambda m: m.group(0) if m.group(0) in REGS or m.group(0)=='n' else 'N', ops)
    ops=re.sub(r'N\(N\)','N',ops)
    ops=re.sub(r'N([+-]N)+','N',ops)
    return mn+' '+ops
srcins=[]
for line in open(src,'rb').read().decode('latin-1').replace('\r','').split('\n'):
    s=line.split(';',1)[0].strip()
    if not s: continue
    s=re.sub(r'^[A-Za-z_.$][\w.$]*:\s*','',s)
    if not s or s.startswith(('$','#','public','extern','module','section','end')) or ' section ' in s or re.match(r'^(f_code|[A-Za-z_]\w*)\s+(section|equ)\b',s,re.I): continue
    if re.match(r'^(db|dw|dl|align)\b',s,re.I): continue
    m=re.match(r'([A-Za-z]+)\s*(.*)',s)
    srcins.append((s,norm(m.group(1),m.group(2))))
n=int(sys.argv[5]) if len(sys.argv)>5 else len(srcins)
data=open(rom,'rb').read()
off=addr-base
tmp=os.path.join(os.environ.get('TMPDIR','.'),'srccmp_%d.bin'%os.getpid())
open(tmp,'wb').write(data[off:off+8*n+64])
out=subprocess.run([UNIDASM,tmp,'-arch','tlcs900','-basepc',hex(addr)],capture_output=True,text=True).stdout.split('\n')
os.remove(tmp)
romins=[]
for l in out:
    m=re.match(r'^([0-9a-f]+):\s+((?:[0-9a-f]{2}\s)+)\s*([a-zA-Z]+)\s*(.*)$',l)
    if m: romins.append((m.group(1),m.group(3)+' '+m.group(4),norm(m.group(3),m.group(4))))
same=0
for i in range(min(n,len(srcins))):
    a=srcins[i][1]; b=romins[i][2]
    ok=(a==b)
    same+=ok
    if not ok: print('DIFF %3d  src: %-28s rom %s: %s'%(i,srcins[i][0],romins[i][0],romins[i][1]))
print('%s vs %s@%06x: %d of %d instructions match after normalisation'%(os.path.basename(src),os.path.basename(rom),addr,same,min(n,len(srcins))))
