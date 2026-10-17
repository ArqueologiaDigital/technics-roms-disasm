import json, sys, os
# For each routine in the json, report in each target image: exact match offsets, else the
# fraction of the routine covered by 8-byte k-grams that occur in the target, and the best
# contiguous match length found by extending a k-gram hit.
lib=json.load(open(sys.argv[1]))
targets=sys.argv[2:]
imgs={t:open(t,'rb').read() for t in targets}
K=8
def best_run(r, img):
    # longest common substring between r and img starting at k-gram hits (greedy extension)
    best=(0,None,None)
    seen=set()
    for i in range(0,len(r)-K+1):
        g=r[i:i+K]
        start=0
        while True:
            j=img.find(g,start)
            if j<0: break
            # extend backwards/forwards
            a,b=i,j
            while a>0 and b>0 and r[a-1]==img[b-1]: a-=1;b-=1
            e1,e2=i+K,j+K
            while e1<len(r) and e2<len(img) and r[e1]==img[e2]: e1+=1;e2+=1
            if e1-a>best[0]: best=(e1-a,a,b)
            start=j+1
            if start>len(img): break
            if best[0]==len(r): return best
    return best
for name,(a,e,h) in lib.items():
    r=bytes.fromhex(h)
    if len(r)<12: continue
    line=['%-26s %5d'%(name,len(r))]
    for t,img in imgs.items():
        j=img.find(r)
        if j>=0:
            line.append('%s:EXACT@%x'%(os.path.basename(t)[:14],j))
        else:
            n,ra,ia=best_run(r,img)
            line.append('%s:%d%%(run %d@%s)'%(os.path.basename(t)[:14], int(100*n/len(r)), n, hex(ia) if ia is not None else '-'))
    print('  '.join(line))
