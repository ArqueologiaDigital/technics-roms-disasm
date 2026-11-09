#!/usr/bin/env python3
"""Does the reload rule alone turn V4.23's library code into the firmware's?  The rule applied to oracle listings.

usage: python3 -I -B rule_on_listings.py RUN_OUT PAIRS_GROUPS.md
RUN_OUT is the out/ directory of an oracle run holding v423/O3XS/libsrc and ide2003/O3XS/libsrc (run
2026-11-08-5-libsrc97-O3XS).  For every function of every V4.23 listing, model/codegen.knowledge_pass(...,
'kn5000') -- the reload rule of notes/cc900-compat-plan-2026-11-08/rules.md -- is applied to V4.23's own
listing, and the result is compared with V4.23's listing and with the 2003 compiler's.  The functions are
then grouped by the pairs grouping (pairs_compare.py output): a function the firmware shares with 2003 only
should come out equal to 2003; one it shares with V4.23 only should come out unchanged.  Compiler temporaries
are not identified in a listing, so a store through a pointer erases nothing here (TEMP_SLOTS empty).
"""
import os, re, sys, glob
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, 'model'))
import listing, codegen

def groups(md):
    g = {}
    for l in open(md).read().splitlines():
        if not l.startswith('| ') or l.startswith('| reproduced'): continue
        c = [x.strip() for x in l.strip('|').split('|')]
        for name in re.findall(r'`([^`]+)`', c[2]): g[name] = c[0]
    return g

def main():
    out, md = sys.argv[1], sys.argv[2]
    grp = groups(md)
    codegen.TEMP_SLOTS.clear()
    rows = []
    for fa in sorted(glob.glob(os.path.join(out, 'v423', 'O3XS', 'libsrc', '*.asm'))):
        fb = os.path.join(out, 'ide2003', 'O3XS', 'libsrc', os.path.basename(fa))
        A = listing.split(open(fa, encoding='latin-1').read()); B = listing.split(open(fb, encoding='latin-1').read())
        for name, la in A.items():
            if name not in B: continue
            strip = lambda L: [l for l in L if 'section' not in l]
            ka = strip(codegen.knowledge_pass(la, 'kn5000')); va = strip(la); vb = strip(B[name])
            rows.append((name, grp.get(name, '-'), ka == va, ka == vb, va == vb))
    print('| function | firmware sides with | rule leaves V4.23 unchanged | rule gives 2003 | V4.23 = 2003 |')
    print('|---|---|---|---|---|')
    for r in rows:
        if r[1] in ('ide2003, v110', 'v423') or not r[4]:
            print('| `%s` | %s | %s | %s | %s |' % (r[0], r[1], 'yes' if r[2] else 'no', 'yes' if r[3] else 'no', 'yes' if r[4] else 'no'))
    n = len(rows); same = sum(1 for r in rows if r[4]); good = sum(1 for r in rows if (r[4] and r[2]) or (not r[4] and r[3]))
    print('\n%d functions; %d identical in V4.23 and 2003; the rule maps V4.23 to 2003 exactly for %d of %d.' % (n, same, good, n))

main()
