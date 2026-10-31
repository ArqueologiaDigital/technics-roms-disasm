# Question: which statuses (and data lengths) do the WSA1R .SEQ chains hold, in the KN5000 demo-song grammar?
import glob, os, sys, struct, collections
FL = sys.argv[1]
sys.path.insert(0, os.path.join(FL, 'kn5000')); import events
c = collections.Counter()
for f in sorted(glob.glob(os.path.join(FL, 'build', 'wsa1', '*', '*.seq'))):
    d = open(f, 'rb').read(); n = len(d) // 256; cell = lambda x: (x - 1) * 256; owner = set()
    for h in range(1, n + 1):
        if struct.unpack_from('<H', d, cell(h) + 1)[0] != 0 or not d[cell(h)] & 0x80: continue
        seq, x = [], h
        while 1 <= x <= n and x not in owner and x not in seq:
            seq.append(x); x = struct.unpack_from('<H', d, cell(x) + 3)[0]
        owner.update(seq)
        s = b''.join(d[cell(x) + 5:cell(x) + 256] for x in seq)
        for p, m, t, _ in events.tokenize_seq(s):
            if t.startswith('sq_ev'): c[(s[p], m - 1)] += 1
            else: c[t.split('\t')[0]] += 1
for k, v in sorted(c.items(), key=str): print(k, v)
