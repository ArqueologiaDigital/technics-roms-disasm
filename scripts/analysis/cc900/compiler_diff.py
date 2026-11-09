#!/usr/bin/env python3
"""Where do two dev-kit compilers differ on the same C?  The raw material of the phase 4 rule list.

usage: python3 -I -B compiler_diff.py RUN_OUT A B OPTIONS [--md]
RUN_OUT is an oracle run's out/ directory (holding <compiler>/<options>/...); A and B are compiler names (v423,
ide2003, v110); OPTIONS an option label of the run (none, O3XS, Xr, O3XSXr).  Every listing present for both is
split into functions (model/listing.py, labels normalised); for each function that differs, prints the file, the
function, and the first differing line of each (A | B).  Ends with the count of differing functions per file.  A
behaviour that differs between V4.23 and the 2003 compiler is a candidate rule for the Technics compiler
(notes/cc900-compat-plan-2026-11-08/PLAN.md, section 2, step 2).
"""
import os, sys, glob, collections
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), 'model'))
import listing

def main():
    out, a, b, opt = sys.argv[1:5]
    md = '--md' in sys.argv
    rows = []; per = collections.Counter(); tot = collections.Counter()
    for fa in sorted(glob.glob(os.path.join(out, a, opt, '**', '*.asm'), recursive=True)):
        rel = os.path.relpath(fa, os.path.join(out, a, opt))
        fb = os.path.join(out, b, opt, rel)
        if not os.path.exists(fb): continue
        A = listing.split(open(fa, encoding='latin-1').read()); B = listing.split(open(fb, encoding='latin-1').read())
        for name in A:
            if name not in B: continue
            la = listing.normalise_labels([l for l in A[name] if 'section' not in l])
            lb = listing.normalise_labels([l for l in B[name] if 'section' not in l])
            tot[rel] += 1
            if la == lb: continue
            per[rel] += 1
            i = listing.diff_first(la, lb) or 0
            rows.append((rel, name, (la[i] if i < len(la) else '(end)').strip(), (lb[i] if i < len(lb) else '(end)').strip()))
    head = ('file', 'function', 'first difference: ' + a, b)
    if md:
        w = [max(len(r[k]) for r in rows + [head]) for k in range(4)]
        print('| ' + ' | '.join(h.ljust(x) for h, x in zip(head, w)) + ' |')
        print('|' + '|'.join('-' * (x + 2) for x in w) + '|')
        for r in rows: print('| ' + ' | '.join(c.replace('|', '/').replace('\t', ' ').ljust(x) for c, x in zip(r, w)) + ' |')
        print()
    else:
        for r in rows: print('\t'.join(r))
    for rel in sorted(tot): print('%s: %d of %d functions differ' % (rel, per[rel], tot[rel]))
    print('TOTAL %d of %d functions differ (%s vs %s, %s)' % (sum(per.values()), sum(tot.values()), a, b, opt))

main()
