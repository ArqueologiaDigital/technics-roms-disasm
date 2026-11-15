"""val_agg.py -- aggregate-only score of the model on the validation corpus (corpus/validation/: random6-8 + rstmt6-8).

Question it answers: does a candidate model lose anything on code it was not tuned on?  Acceptance rule P11 (research-scratch
sessions/2026-11-10_cc900-refusals/strategy/report-02.md): 0 statements and 0 functions lost on validation.

It prints totals only -- never a function name, a statement name or a listing line -- so that the corpus stays a signal
nobody can fit.  Per-function status passes between processes through pipes and is never written to disk.

    python3 -I -B val_agg.py CAND_MODEL                      # totals for one model at all four sets
    python3 -I -B val_agg.py CAND_MODEL --base BASE_MODEL    # + statements / functions gained and lost against BASE
    options: --sets none,O3XS  --run DIR (the oracle run's out/v423; default micro-validation678's)  -j N

Run from scripts/analysis/cc900 (the corpus paths are relative).  CC900_CACHE, when set, is passed to the model's cache.
Output per set: functions exact / refused, statements exact / refused, the context factor c (functions whose statements
are all exact, and how many of those are exact); with --base, lost and gained counts (EXACT -> not EXACT is lost).
Exit status 1 when --base is given and anything is lost."""
import sys, os, re, glob, json, subprocess, collections
from concurrent.futures import ThreadPoolExecutor

RUN = os.path.expanduser('~/compartilhado/cc900-oracle/runs/2026-11-15-3-micro-validation678/out/v423')
PAIRS = [('corpus/validation/random%d' % k, 'corpus/validation/rstmt%d.c' % k) for k in (6, 7, 8)]

def child(mdir, SET, run):
    """Print {'F': {fn: status}, 'S': {stmt: status}} as JSON on stdout (to the parent's pipe only)."""
    sys.path.insert(0, os.path.abspath(mdir))
    import listing, score, frontend, codegen
    try: import cache
    except ImportError: cache = None
    opt = 'O3XS' if 'O3' in SET else 'none'; adecl = 'Xr' in SET
    def compile_(src):
        if cache: return cache.compile(src, [], [], opt, adecl)
        u = frontend.load(src, [], [], adecl=adecl); return u, codegen.compile_unit(u, opt=opt, adecl=adecl)
    def status(odir, srcs):
        out = {}
        for src in srcs:
            want = listing.split(open(score.oracle_path(odir, src), encoding='latin-1').read())
            try: unit, got = compile_(src)
            except Exception: got = {}
            for name, wl in want.items():
                W = listing.normalise_labels([l for l in wl if 'section' not in l])
                G = listing.normalise_labels([l for l in got.get(name, []) if 'section' not in l])
                if W == G: st = 'EXACT'
                elif not G or any('nsupported' in l or 'refus' in l.lower() for l in G): st = 'REFUSED'
                else: st = 'DIFF'
                out[name.lstrip('._')] = st
        return out
    F, S = {}, {}
    base = os.path.join(run, SET, 'validation')
    for rdir, rs in PAIRS:
        F.update(status(os.path.join(base, os.path.basename(rdir)), sorted(glob.glob(rdir + '/*.c'))))
        S.update(status(base, [rs]))
    json.dump({'F': F, 'S': S}, sys.stdout)

def run_child(mdir, SET, run):
    env = dict(os.environ)
    p = subprocess.run([sys.executable, '-I', '-B', os.path.abspath(__file__), '--child', mdir, SET, run],
                       capture_output=True, text=True, env=env)
    if p.returncode:
        sys.stderr.write(p.stderr[-2000:]); raise SystemExit('child failed: %s %s' % (mdir, SET))
    return json.loads(p.stdout)

def summary(d):
    F, S = d['F'], d['S']
    by = collections.defaultdict(list)
    for n, st in S.items():
        m = re.match(r'rs_(\d)_(\d\d)_(\d\d)_(\d+)$', n)
        if m: by['r%s_%s_%s' % m.groups()[:3]].append(st)
    allok = [f for f in F if by.get(f) and all(s == 'EXACT' for s in by[f])]
    ex = sum(F[f] == 'EXACT' for f in allok)
    return (len(F), sum(v == 'EXACT' for v in F.values()), sum(v == 'REFUSED' for v in F.values()),
            len(S), sum(v == 'EXACT' for v in S.values()), sum(v == 'REFUSED' for v in S.values()),
            len(allok), ex)

def main():
    a = sys.argv[1:]
    if a and a[0] == '--child':
        return child(*a[1:4])
    sets = ['none', 'O3XS', 'Xr', 'O3XSXr']; base = None; run = RUN; jobs = 8
    pos = []
    while a:
        x = a.pop(0)
        if x == '--sets': sets = a.pop(0).split(',')
        elif x == '--base': base = a.pop(0)
        elif x == '--run': run = a.pop(0)
        elif x == '-j': jobs = int(a.pop(0))
        else: pos.append(x)
    if len(pos) != 1: raise SystemExit(__doc__)
    cand = pos[0]
    work = [(m, s) for s in sets for m in ([cand] + ([base] if base else []))]
    with ThreadPoolExecutor(jobs) as ex:
        res = dict(zip(work, ex.map(lambda w: run_child(w[0], w[1], run), work)))
    lost_any = False
    for s in sets:
        c = res[(cand, s)]
        nf, fe, fr, ns, se, sr, na, ae = summary(c)
        print('%-6s  functions %d: exact %d, refused %d | statements %d: exact %d, refused %d | all-exact %d, exact %d (c %.2f)'
              % (s, nf, fe, fr, ns, se, sr, na, ae, ae / max(1, na)))
        if base:
            b = res[(base, s)]
            for k, what in (('F', 'functions'), ('S', 'statements')):
                lost = sum(1 for n, v in b[k].items() if v == 'EXACT' and c[k].get(n) != 'EXACT')
                gained = sum(1 for n, v in c[k].items() if v == 'EXACT' and b[k].get(n) != 'EXACT')
                print('        %-10s gained %d, lost %d' % (what, gained, lost))
                lost_any |= bool(lost)
    if base:
        print('VERDICT: %s' % ('LOSS -- not acceptable under P11' if lost_any else 'no loss'))
        return 1 if lost_any else 0

if __name__ == '__main__':
    sys.exit(main() or 0)
