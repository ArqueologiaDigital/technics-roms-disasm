#!/usr/bin/env python3
"""Apply the kn5000 reload rule to raw V4.23 listings, keeping every other line, so asm900 can assemble them.

usage: python3 -I -B rule_transform.py IN_DIR OUT_DIR [--personality kn5000]
Every IN_DIR/*.asm (a thc2 listing, e.g. an oracle run's out/v423/O3XS/libsrc) is written to OUT_DIR with the
loads that model/codegen.knowledge_pass drops for the personality removed (rules.md, "The reload rule, stated
precisely").  Nothing else changes: comments, sections, data and labels stay as they are.  The output is derived
from Toshiba's output, so OUT_DIR belongs in scratch or in the private oracle repository, never in this one.
Prints the number of loads removed per file.
"""
import os, sys, glob
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, 'model'))
import listing, codegen

def main():
    src, dst = sys.argv[1], sys.argv[2]
    pers = sys.argv[sys.argv.index('--personality') + 1] if '--personality' in sys.argv else 'kn5000'
    os.makedirs(dst, exist_ok=True)
    codegen.TEMP_SLOTS.clear()
    total = 0
    for f in sorted(glob.glob(os.path.join(src, '*.asm'))):
        raw = open(f, encoding='latin-1', newline='').read().split('\n')
        clean = [listing.clean(l) for l in raw]
        idx = [i for i, c in enumerate(clean) if c]           # analysed lines, in order
        kept = codegen.knowledge_pass([clean[i] for i in idx], pers)
        drop = set(); j = 0
        for i in idx:                                         # knowledge_pass only removes lines
            if j < len(kept) and kept[j] == clean[i]: j += 1
            else: drop.add(i)
        open(os.path.join(dst, os.path.basename(f)), 'w', encoding='latin-1', newline='').write(
            '\n'.join(l for i, l in enumerate(raw) if i not in drop))
        if drop: print('%-16s %d load(s) removed' % (os.path.basename(f), len(drop)))
        total += len(drop)
    print('total %d loads removed' % total)

main()
