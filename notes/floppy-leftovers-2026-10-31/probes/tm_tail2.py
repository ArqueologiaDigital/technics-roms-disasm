# Question: the KN6000 checksum func_4C07D7C1 is ~(LE16 sum of 0x37A0 halfwords from RAM 0x8402F4F4); which file
# window (start offset) makes the most .TM tails match, and do the files that match differ from those that do not?
import glob, os, sys, collections
FL = sys.argv[1]
names = sorted(glob.glob(os.path.join(FL, 'build', 'kn6000', '*', '*.tm.p1.ref')))
fs = [(f, open(f, 'rb').read()) for f in names]
fs = [(f, p) for f, p in fs if p[:16] == b'KN6000 SOUND RAM']
c = collections.Counter(); match0 = []
for f, p in fs:
    t = p[0xB7F8] | p[0xB7F9] << 8
    w = [p[i] | p[i + 1] << 8 for i in range(0, len(p) - 1)]   # word at every byte offset
    pre = [0]
    for i in range(0, len(p) - 1):
        pre.append(pre[-1] + w[i])
    # sum of words at o, o+2, ...: build per-parity prefix sums
    par = [[0], [0]]
    for i in range(len(p) - 1):
        par[i & 1].append(par[i & 1][-1] + w[i])
    for o in range(0, 0xB7F8 - 2):
        k0 = o // 2
        q = par[o & 1]
        n = min(0x37A0, len(q) - 1 - k0)
        s = ~(q[k0 + n] - q[k0]) & 0xFFFF
        if s == t: c[o] += 1
    if (~(par[0][0x10 // 2 + 0x37A0] - par[0][0x10 // 2])) & 0xFFFF == t: match0.append(os.path.relpath(f, FL))
print(len(fs), 'files; window starts by matches:', c.most_common(6))
print('match at +0x10:', len(match0), match0)
