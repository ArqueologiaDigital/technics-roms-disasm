import re, sys, glob, collections
# Count instruction-shape features in a set of .s files (latin-1 safe).
pats = {
 'link':        re.compile(r'^\s+link\b', re.I),
 'unlk':        re.compile(r'^\s+unlk\b', re.I),
 'retd':        re.compile(r'^\s+retd\b', re.I),
 'reti':        re.compile(r'^\s+reti\b', re.I),
 'ret':         re.compile(r'^\s+ret\s*$', re.I),
 'lda xsp,(xsp-N)': re.compile(r'^\s+lda\s+xsp,\s*\(xsp\s*-\s*\d+', re.I),
 'lda xsp,(xsp+N)': re.compile(r'^\s+lda\s+xsp,\s*\(xsp\s*\+\s*\d+', re.I),
 'inc N,xsp':   re.compile(r'^\s+inc\s+\d+,\s*xsp\b', re.I),
 'dec N,xsp':   re.compile(r'^\s+dec\s+\d+,\s*xsp\b', re.I),
 'add xsp,imm': re.compile(r'^\s+add\s+xsp,', re.I),
 'push xiz':    re.compile(r'^\s+push\s+xiz\b', re.I),
 'push xix':    re.compile(r'^\s+push\s+xix\b', re.I),
 'push xiy':    re.compile(r'^\s+push\s+xiy\b', re.I),
 'pushw iz':    re.compile(r'^\s+pushw\s+iz\b', re.I),
 'push QIZ (pushw_erp 0xfa)': re.compile(r'^\s+(pushw_erp\s+0xfa|push\s+qiz)\b', re.I),
 'pop QIZ (popw_erp 0xfa)':   re.compile(r'^\s+(popw_erp\s+0xfa|pop\s+qiz)\b', re.I),
 'any QIZ/QIZH/QIZL use (erp 0xf8-0xfb)': re.compile(r'_erp\w*\s.*0xf[89ab]\b|\bqiz\b', re.I),
 'ld xiz,xsp (frame ptr)': re.compile(r'^\s+ld\s+xiz,\s*xsp\b', re.I),
 'ld xix,xsp': re.compile(r'^\s+ld\s+xix,\s*xsp\b', re.I),
 'jp T,(xix+wa)-like': re.compile(r'^\s+jp\s+(t,\s*)?\(?x[a-z]+\s*\+\s*[a-z]+\)?\s*$', re.I),
 'call': re.compile(r'^\s+call\b', re.I),
 'calr': re.compile(r'^\s+calr\b', re.I),
 'pushw imm': re.compile(r'^\s+pushw\s+(0x[0-9a-f]+|\d+|[A-Za-z_]\w*@hi16|[A-Za-z_]\w*@lo16)\s*(;.*)?$', re.I),
 'pushm/pushdi (mem)': re.compile(r'^\s+pushm\b', re.I),
 'exts': re.compile(r'^\s+exts\b', re.I),
 'extz': re.compile(r'^\s+extz\b', re.I),
}
files = []
for g in sys.argv[1:]:
    files += glob.glob(g, recursive=True)
cnt = collections.Counter()
for f in files:
    for line in open(f, 'rb').read().decode('latin-1').split('\n'):
        code = line.split(';',1)[0]
        for k,p in pats.items():
            if p.search(code):
                cnt[k]+=1
print('files:', len(files))
for k in pats:
    print('%-40s %d' % (k, cnt[k]))
