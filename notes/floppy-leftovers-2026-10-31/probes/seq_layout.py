# Question: why does a WSA1R .SEQ hold blocks in no chain?  Compare the file's block count with its chained
# blocks, the free chain the .SQF names (+0xB8 head, +0xBA count, bank 0) and the kilobyte rounding.
import glob, os, sys, struct
FL = sys.argv[1]
for f in sorted(glob.glob(os.path.join(FL, 'build', 'wsa1', '*', '*.seq'))):
    d = open(f, 'rb').read(); n = len(d) // 256; cell = lambda x: (x - 1) * 256; owner = set()
    for h in range(1, n + 1):
        if struct.unpack_from('<H', d, cell(h) + 1)[0] != 0 or not d[cell(h)] & 0x80: continue
        x = h
        while 1 <= x <= n and x not in owner:
            owner.add(x); x = struct.unpack_from('<H', d, cell(x) + 3)[0]
    q = open(f[:-4] + '.sqf', 'rb').read()
    head, cnt = struct.unpack_from('<HH', q, 0xB8)
    free = []; x = head
    while 1 <= x <= n and x not in free and x not in owner:
        free.append(x); x = struct.unpack_from('<H', d, cell(x) + 3)[0]
    orph = [x for x in range(1, n + 1) if x not in owner]
    print('%-28s blocks %4d (%%4 = %d) chained %4d orphans %3d | sqf free head %4d count %4d (used+free %d) | free chain in file %d: %s' % (
        os.path.relpath(f, FL), n, n % 4, len(owner), len(orph), head, cnt, len(owner) + cnt, len(free),
        'orphans = chained-max+1..n' if orph == list(range(max(owner or [0]) + 1, n + 1)) else 'orphans %s..' % orph[:6]))
# and: does every block of the free chain that the file holds start with 0x82?
print('---- free-chain blocks: first payload byte')
import collections
fb = collections.Counter()
for f in sorted(glob.glob(os.path.join(FL, 'build', 'wsa1', '*', '*.seq'))):
    d = open(f, 'rb').read(); n = len(d) // 256
    q = open(f[:-4] + '.sqf', 'rb').read(); x = struct.unpack_from('<H', q, 0xB8)[0]; seen = set()
    while 1 <= x <= n and x not in seen:
        seen.add(x); fb[(os.path.basename(f), d[(x - 1) * 256 + 5])] += 1; x = struct.unpack_from('<H', d, (x - 1) * 256 + 3)[0]
for k, v in sorted(fb.items()): print(k, v)
