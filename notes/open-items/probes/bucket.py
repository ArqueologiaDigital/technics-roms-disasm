# Question: how do a census listing's opaque declarations split by reason (numbers and addresses taken out) and by
# whether some word holds their address?  Usage: python3 bucket.py <opaque.txt>  (opaque.txt = the TSV of
# scripts/analysis/data_incbin_census.py --list opaque)
import re, sys, collections
rows=[l.rstrip('\n').split('\t') for l in open(sys.argv[1]) if l.count('\t')>=4]
g=collections.defaultdict(lambda: collections.Counter())
gb=collections.defaultdict(lambda: collections.Counter())
for t,src,n,f,why in rows:
    if not n.isdigit(): continue
    w=re.sub(r'\b\d[\d,]*\b','N',why)
    w=re.sub(r'0x[0-9a-fA-F]+','ADDR',w)
    m=re.match(r'(unknown-dump|code): (N bytes of )?(.*?)(;|\(|$)(.*)',w)
    kind=m.group(3).strip() if m else w[:80]
    tail=m.group(5) if m else ''
    sub='ptr-held' if 'holds their address' in why else ('no-ptr' if 'no address' in why else tail[:90])
    g[(t,kind)][sub]+=1; gb[(t,kind)][sub]+=int(n)
for k in sorted(g):
    print(k[0],'|',k[1][:100],'|',dict(g[k]),dict(gb[k]))
