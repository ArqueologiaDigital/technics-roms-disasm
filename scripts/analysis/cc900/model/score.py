#!/usr/bin/env python3
"""Score the cc900 reference model against oracle listings, function by function.

usage: python3 -I -B score.py ORACLE_DIR FILE.c [FILE.c ...] [--opt none|O3XS] [--adecl] [--show N] [--strict]
       [-DNAME[=V] ...] [-IDIR ...]   (passed to clang's front end)
ORACLE_DIR is one compiler/option directory of an oracle run, e.g.
~/compartilhado/cc900-oracle/runs/2026-11-08-7-micro/out/v423/none; each FILE.c is looked up there by its path
relative to the corpus root (the part from `micro/` or `abi/` on).  For every function the model compiles, its
lines are compared with the oracle's (listing.split; local labels renamed in order unless --strict).  Prints one
line per file (exact / total) and a total; --show N prints the first N mismatches with both listings from the first
differing line.
"""
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import frontend, listing, codegen

def oracle_path(odir, src):
    p = os.path.abspath(src).replace('\\', '/')
    for root in ('/micro/', '/abi/', '/libsrc/'):
        if root in p: return os.path.join(odir, root.strip('/') + '/' + os.path.basename(p)[:-2] + '.asm')
    return os.path.join(odir, os.path.basename(p)[:-2] + '.asm')

def main():
    a = sys.argv[1:]
    opt = a[a.index('--opt') + 1] if '--opt' in a else None
    show = int(a[a.index('--show') + 1]) if '--show' in a else 0
    strict = '--strict' in a; adecl = '--adecl' in a
    defines = [x[2:] for x in a if x.startswith('-D')]; incs = [x[2:] for x in a if x.startswith('-I')]
    a = [x for x in a if not x.startswith(('-D', '-I'))]
    pos = [x for i, x in enumerate(a) if not x.startswith('--') and (i == 0 or a[i - 1] not in ('--opt', '--show'))]
    odir, files = pos[0], pos[1:]
    base = os.path.basename(os.path.normpath(odir))          # infer from the oracle directory name
    if opt is None: opt = 'O3XS' if base.startswith('O3XS') else 'none'
    if base.endswith('Xr'): adecl = True
    tot = ok = 0; shown = 0
    for f in files:
        op = oracle_path(odir, f)
        if not os.path.exists(op): print('%-28s no oracle listing' % os.path.basename(f)); continue
        want = listing.split(open(op, encoding='latin-1').read())
        try: unit = frontend.load(f, defines, incs)
        except Exception as ex: print('%-28s front end failed: %s' % (os.path.basename(f), str(ex).splitlines()[-1][:80])); continue
        got = codegen.compile_unit(unit, opt=opt, adecl=adecl)
        n = good = 0
        for name, wl in want.items():
            gl = got.get(name, [])
            W = [l for l in wl if 'section' not in l]; G = [l for l in gl if 'section' not in l]
            if not strict: W, G = listing.normalise_labels(W), listing.normalise_labels(G)
            n += 1
            if W == G: good += 1
            elif shown < show:
                shown += 1; i = listing.diff_first(W, G) or 0
                print('---- %s %s (first difference at line %d)' % (os.path.basename(f), name, i))
                for k in range(max(0, i - 2), max(len(W), len(G))):
                    print('  %-34s | %s' % (W[k] if k < len(W) else '', G[k] if k < len(G) else ''))
        tot += n; ok += good
        print('%-28s %3d / %3d' % (os.path.basename(f), good, n))
    print('TOTAL %d / %d exact (%.1f%%)' % (ok, tot, 100.0 * ok / max(tot, 1)))

if __name__ == '__main__':
    main()
