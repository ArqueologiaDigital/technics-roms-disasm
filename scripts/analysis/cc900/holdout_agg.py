"""holdout_agg.py MODEL SET RANDOM_ORACLE_DIR RSTMT_ORACLE_DIR RANDOM_C... -- RSTMT_C...
Aggregates ONLY (no function name, no listing line is printed or written), for a blind corpus at one set:
  functions exact / refused / differing; rstmt statements exact; functions whose statements are all exact in the
  rstmt corpus and how many of those are exact (the context factor c); one-fix functions; functions by number of bad
  statements; the shape classes of analyse.py (REG / FRAME / PERM / OTHER).
Pairing: function rA_BB_CC <-> statements rs_A_BB_CC_k (gen_rstmt.py's naming).
Example (the coordinator fills in the real paths):
  CC900_CACHE=... python3 -I -B holdout_agg.py MODEL none ORACLE/out/v423/none/<dir> ORACLE/out/v423/none/<dir> \
      corpus/holdout/random5/*.c -- corpus/holdout/rstmt5.c"""
import sys, os, re, collections
a = sys.argv[1:]
mdir, SET, odir_r, odir_s = a[:4]
rest = a[4:]; k = rest.index('--'); rsrc, ssrc = rest[:k], rest[k + 1:]
sys.path.insert(0, os.path.abspath(mdir))
import listing, score, frontend, codegen
try: import cache
except ImportError: cache = None
def compile_(src):
    if cache: return cache.compile(src, [], [], opt, adecl)
    u = frontend.load(src, [], [], adecl=adecl); return u, codegen.compile_unit(u, opt=opt, adecl=adecl)
opt = 'O3XS' if 'O3' in SET else 'none'; adecl = 'Xr' in SET
REGS = r'\b(Q?X?(WA|BC|DE|HL|IX|IY|IZ|SP)|[WABCDEHL]|Q[WABCDEHL]|IXL|IYL|IZL)\b'
def regabs(l): return re.sub(REGS, 'R', l)
def frameabs(l): return re.sub(r'R\+0x[0-9a-f]+|R-0x[0-9a-f]+', 'R+d', regabs(l))
FRAMEOP = re.compile(r'^\t(push|pop|pushw|popw|link|unlk|lda\tR,R[-+]|dec\t0x[0-9a-f]+,R$|inc\t0x[0-9a-f]+,R$|ld\tR,R$)')
def status(odir, srcs):
    out = {}
    for src in srcs:
        want = listing.split(open(score.oracle_path(odir, src), encoding='latin-1').read())
        unit, got = compile_(src)
        for name, wl in want.items():
            W = listing.normalise_labels([l for l in wl if 'section' not in l])
            G = listing.normalise_labels([l for l in got.get(name, []) if 'section' not in l])
            if W == G: st = 'EXACT'
            elif not G or any('nsupported' in l or 'refus' in l.lower() for l in G): st = 'REFUSED'
            elif [regabs(x) for x in W] == [regabs(x) for x in G]: st = 'REG'
            elif [frameabs(x) for x in W if not FRAMEOP.match(frameabs(x))] == \
                 [frameabs(x) for x in G if not FRAMEOP.match(frameabs(x))]: st = 'FRAME'
            elif collections.Counter(W) == collections.Counter(G): st = 'PERM'
            else: st = 'OTHER'
            out[name.lstrip('._')] = st
    return out
F = status(odir_r, rsrc); S = status(odir_s, ssrc)
by = collections.defaultdict(list)
for n, st in S.items():
    m = re.match(r'rs_(\d)_(\d\d)_(\d\d)_(\d+)$', n)
    if m: by['r%s_%s_%s' % m.groups()[:3]].append(st)
cls = collections.Counter(F.values())
allok = [f for f in F if by.get(f) and all(s == 'EXACT' for s in by[f])]
nbad = collections.Counter((F[f] == 'EXACT', min(sum(s != 'EXACT' for s in by.get(f, [])), 4)) for f in F)
p = sum(s == 'EXACT' for s in S.values()) / max(1, len(S))
ns = [len(by.get(f, [])) for f in F]
print('%s: functions %d, exact %d, refused %d, differing %d (REG %d FRAME %d PERM %d OTHER %d)' % (
    SET, len(F), cls['EXACT'], cls['REFUSED'], len(F) - cls['EXACT'] - cls['REFUSED'], cls['REG'], cls['FRAME'],
    cls['PERM'], cls['OTHER']))
print('  statements %d, exact %d (p %.3f), refused %d; mean statements per function %.2f; sum p^n %.1f' % (
    len(S), sum(s == 'EXACT' for s in S.values()), p, sum(s == 'REFUSED' for s in S.values()),
    sum(ns) / max(1, len(ns)), sum(p ** n for n in ns)))
print('  all statements exact: %d functions, of which exact %d (c %.2f); exact with a bad statement %d' % (
    len(allok), sum(F[f] == 'EXACT' for f in allok), sum(F[f] == 'EXACT' for f in allok) / max(1, len(allok)),
    sum(1 for f in F if F[f] == 'EXACT' and f not in allok)))
print('  inexact functions by bad statements 0/1/2/3/4+: %s' % ' / '.join(str(nbad[(False, b)]) for b in range(5)))
