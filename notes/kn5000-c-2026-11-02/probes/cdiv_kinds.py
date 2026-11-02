#!/usr/bin/env python3
"""cdiv_kinds.py TREE NEEDDIR -- classify the raw bytes of TREE's json: inside a 32-bit value that is a
DRAM address (0x30000..0x3FFFF, the work-RAM cells) on both sides, inside a 32-bit ROM pointer on both
sides (unaligned), or other.  compiled = the C now; needed = NEEDDIR/<bin> (ported_c_rebase.py --need)."""
import collections, json, os, sys
sys.path.insert(0, os.path.join(os.getcwd(), 'scripts', 'converters'))
import ported_c_rebase as R
tree, nd = sys.argv[1], sys.argv[2]
d = json.load(open(R.json_path(tree)))
tot = collections.Counter()
for name, ent in sorted(d.items()):
    raw = ent.get('raw', {})
    if not raw: continue
    have = R.compile_bin(tree, name)
    if have is None: tot['noC'] += len(raw); continue
    want = open(os.path.join(nd, name), 'rb').read()
    have = have + b'\0' * max(0, len(want) - len(have))
    c = collections.Counter()
    for o in map(int, raw):
        kind = 'other'
        for k in range(4):
            a = o - k
            if a < 0 or a + 4 > len(want): continue
            v0 = int.from_bytes(have[a:a+4], 'little'); v1 = int.from_bytes(want[a:a+4], 'little')
            if 0x30000 <= v0 < 0x40000 and 0x30000 <= v1 < 0x40000 and abs(v0 - v1) < 0x400:
                kind = 'dram'; break
            if 0xE00000 <= v0 < 0x1000000 and 0xE00000 <= v1 < 0x1000000:
                kind = 'rom'; break
        c[kind] += 1
    tot.update(c)
    print('%-34s %5d  %s' % (name, len(raw), dict(c)))
print('total', dict(tot))
