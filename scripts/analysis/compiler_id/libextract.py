import subprocess, sys, json
# Extract byte ranges of named top-level routines from the v10 ROM using llvm-nm on the ELF.
NM='/home/fsanches/compartilhado/llvm-project/build/bin/llvm-nm'
ROOT='/home/fsanches/compartilhado/kn5000-roms-disasm'
elf=ROOT+'/rebuilt_ROMs/kn5000_v10_program.llvm.elf'
rom=open(ROOT+'/original_ROMs/kn5000_v10_program.rom','rb').read()
base=0xe00000
out=subprocess.run([NM,'--defined-only','-n',elf],capture_output=True,text=True).stdout.split('\n')
syms=[]
for l in out:
    p=l.split()
    if len(p)==3 and p[1]=='t':
        syms.append((int(p[0],16),p[2]))
names=sys.argv[1].split(',')
# a routine ends at the next symbol in the given "ends" list or at next name in names list order by address
starts={n:a for a,n in syms}
res={}
allstarts=sorted(set(starts[n] for n in names if n in starts))
for n in names:
    if n not in starts: print('missing',n); continue
    a=starts[n]
    nxt=[s for s in allstarts if s>a]
    e=nxt[0] if nxt else a+64
    res[n]=(a,e,rom[a-base:e-base].hex())
json.dump(res,open(sys.argv[2],'w'),indent=1)
for n,(a,e,h) in res.items(): print('%-26s %06x-%06x %4d bytes'%(n,a,e,(e-a)))
