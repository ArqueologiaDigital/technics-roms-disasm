# Question: are the WSA1R floppy stale tails (census: opaque) copies of earlier bytes of the same file?
# Usage: python3 stale_tails.py <wsa1_stale.tsv> <repo root>
import re, sys
tsv, root = sys.argv[1], sys.argv[2].rstrip('/') + '/'
for l in open(tsv):
    src, n, img = l.rstrip('\n').split('\t'); p, ln = src.rsplit(':', 1)
    L = open(root + p).read().split('\n')
    for x in L[int(ln)-1:int(ln)+3]:
        m = re.search(r'\.incbin\s+"([^"]+)",\s*(0x[0-9a-f]+|\d+),\s*(\d+)', x)
        if m: break
    disk, off, cnt = m.group(1), int(m.group(2), 0), int(m.group(3))
    d = open(root + 'floppy/wsa1/baserom/' + disk, 'rb').read()
    cur = d[off:off+cnt]
    best = max(((sum(a == b for a, b in zip(d[off-k:off-k+cnt], cur)), k) for k in range(1, min(off, 65536))), default=(0, 0))
    print(p.split('/')[-1], cnt, 'prev-1024 match', sum(a == b for a, b in zip(d[off-1024:off-1024+cnt], cur)), 'best back-shift', best)
