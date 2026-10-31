# Question: what are the WSA1R .SEQ blocks that no chain reaches?
import glob, os, sys, struct, collections, hashlib
FL = sys.argv[1]
sys.path.insert(0, os.path.join(FL, 'kn5000')); import events
files = sorted(glob.glob(os.path.join(FL, 'build', 'wsa1', '*', '*.seq')))
allbodies = collections.defaultdict(list)
data = {}
for f in files:
    d = open(f, 'rb').read(); data[f] = d
    for c in range(1, len(d) // 256 + 1):
        allbodies[d[(c-1)*256+5:c*256]].append((f, c))
st = collections.Counter()
for f in files:
    d = data[f]; n = len(d) // 256; cell = lambda c: (c - 1) * 256
    owner = {}
    for h in range(1, n + 1):
        if struct.unpack_from('<H', d, cell(h) + 1)[0] != 0 or not d[cell(h)] & 0x80: continue
        seq, c = [], h
        while 1 <= c <= n and c not in owner and c not in seq:
            seq.append(c); c = struct.unpack_from('<H', d, cell(c) + 3)[0]
        for cc in seq: owner[cc] = h
    orph = [c for c in range(1, n + 1) if c not in owner and len(set(d[cell(c)+5:cell(c)+256])) > 1]
    for c in orph:
        b = d[cell(c):cell(c)+256]; fl, pv, nx = b[0], *struct.unpack_from('<HH', b, 1)
        body = b[5:]
        dup = [x for x in allbodies[body] if x != (f, c)]
        toks = events.tokenize_seq(body)
        kinds = collections.Counter(t[2].split('\t')[0] for t in toks)
        st['dup' if dup else 'unique'] += 1
        st['flag%02x' % fl] += 1
        print('%s blk %d fl %02x prev %d next %d | dup %s | prev-owner %s next-owner %s | %s' % (
            os.path.relpath(f, FL), c, fl, pv, nx, [(os.path.basename(os.path.dirname(x[0])) + '/' + os.path.basename(x[0]), x[1]) for x in dup[:3]],
            owner.get(pv), owner.get(nx), dict(kinds)))
print(st)

# second pass: classify each orphan by whether a chained block of the same file has its body
print('---- class')
cls = collections.Counter()
for f in files:
    d = data[f]; n = len(d) // 256; cell = lambda c: (c - 1) * 256
    owner = {}
    for h in range(1, n + 1):
        if struct.unpack_from('<H', d, cell(h) + 1)[0] != 0 or not d[cell(h)] & 0x80: continue
        seq, c = [], h
        while 1 <= c <= n and c not in owner and c not in seq:
            seq.append(c); c = struct.unpack_from('<H', d, cell(c) + 3)[0]
        for cc in seq: owner[cc] = h
    for c in range(1, n + 1):
        body = d[cell(c)+5:cell(c)+256]
        if c in owner or len(set(body)) == 1: continue
        same = [x for x in allbodies[body] if x[0] == f and x[1] in owner]
        other = [x for x in allbodies[body] if x[0] != f]
        k = 'chained copy' if same else ('other file' if other else ('orphan copy' if len(allbodies[body]) > 1 else 'unique'))
        cls[(os.path.basename(f), k)] += 1
        if k != 'chained copy':
            print(os.path.basename(f), c, k, body[:24].hex(' '), '...', body[-12:].hex(' '))
for k, v in sorted(cls.items()): print(k, v)
