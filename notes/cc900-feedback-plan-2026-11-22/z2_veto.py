#!/usr/bin/env python3
"""Step Z2 of the feedback plan: the veto check of the reload-after-store rule on V4.23's firmware listings.

QUESTION ANSWERED: rules.md's only rule in the `kn5000` state "2003" is reload-after-store, final form: the
2003 / Technics compiler drops a load `ld R,(XSP+d)` that IMMEDIATELY follows a store `ld (XSP+d),R` of the same
register to the same slot (no label or other instruction between); V4.23 keeps it.  If that were how the firmware
was compiled, no function the build reproduces with V4.23 could contain the pair: a V4.23 listing whose function
matches the ROM byte for byte and contains the pair shows the ROM keeping that reload.  So:

  veto      functions built from C on main (V4.23 MATCH) whose matching listing has the pair inside the function;
  support   residual functions (NEAR / DIFF, never matched) whose best listing has the pair: the rule could be what
            they miss.  With --recompare the pair is removed from those listings (into scratch, never committed:
            derived from Toshiba output) and the function re-compared through the build's chain (nearmiss.py).

Only counts, function names and our own notation are printed; no listing text.

Inputs: notes/cc900-c-nearmiss/index.tsv, scripts/analysis/cc900/results/c_build_coverage.md, the private oracle
listings (~/compartilhado/cc900-oracle/runs/), and for --recompare the attempts' C (Z1's
~/compartilhado/cc900-attempts-c, else the index's c/ copies).

Usage, from technics-roms-disasm's root:
    python3 -B notes/cc900-feedback-plan-2026-11-22/z2_veto.py [--recompare] [--list N]
"""
import collections
import hashlib
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, 'scripts/analysis/cc900')
import residual  # noqa: E402
import nearmiss  # noqa: E402

ORACLE = os.path.expanduser('~/compartilhado/cc900-oracle')
ARCHIVE = os.path.expanduser('~/compartilhado/cc900-attempts-c')
NM_DIR = 'notes/cc900-c-nearmiss'
SCRATCH = os.path.join(os.environ.get('TMPDIR', os.path.expanduser('~/compartilhado/tmp')), 'cc900-tab', 'z2')
STORE = re.compile(r'^\tld\t(\(XSP(?:\+0x[0-9a-fA-F]+)?\)),(\w+)$')
LOAD = re.compile(r'^\tld\t(\w+),(\(XSP(?:\+0x[0-9a-fA-F]+)?\))$')


def pairs(lines):
    """indices (into lines) of loads that immediately follow a store of the same register to the same slot"""
    import listing
    clean = [(i, listing.clean(l)) for i, l in enumerate(lines)]
    clean = [(i, c) for i, c in clean if c]
    out = []
    for (i0, a), (i1, b) in zip(clean, clean[1:]):
        s, ld = STORE.match(a), LOAD.match(b)
        if s and ld and s.group(1) == ld.group(2) and s.group(2) == ld.group(1):
            out.append((i1, ld.group(1)))
    return out


def width(reg):
    return 'long' if reg.startswith('X') else ('word' if len(reg) == 2 else 'byte')


def table(head, rows):
    w = [max(len(str(x)) for x in c) for c in zip(head, *rows)] if rows else [len(h) for h in head]
    out = ['| ' + ' | '.join(str(h).ljust(n) for h, n in zip(head, w)) + ' |',
           '|' + '|'.join('-' * (n + 2) for n in w) + '|']
    out += ['| ' + ' | '.join(str(x).ljust(n) for x, n in zip(r, w)) + ' |' for r in rows]
    return '\n'.join(out)


def attempt_c(r):
    p = os.path.join(ARCHIVE, 'runs', r['run'], r['source'])
    if os.path.exists(p):
        b = open(p, 'rb').read()
        if hashlib.sha256(b).hexdigest() == r['c_sha256']:
            return b
    if r['c_copy'] and os.path.exists(os.path.join(NM_DIR, r['c_copy'])):
        return open(os.path.join(NM_DIR, r['c_copy']), 'rb').read()
    return b''


def main():
    a = sys.argv[1:]
    nlist = int(a[a.index('--list') + 1]) if '--list' in a else 30
    nearmiss.setup_imports(os.path.abspath('.'), os.path.abspath('.'))
    nearmiss.Ctx.src_root = os.path.abspath('.')
    import cc900_firmware_c as fw
    built = residual.built_set()
    built_cut = {(i, f[:31]) for i, f in built}
    rows = nearmiss.read_index(NM_DIR)
    img = lambda r: residual.TREE_TO_IMAGE.get(r['tree'], r['tree'])  # noqa: E731
    match_rows = collections.defaultdict(list)
    best = {}
    for r in rows:
        k = (img(r), r['function'])
        if r['status'] == 'MATCH' and residual.is_built(k, built, built_cut):
            match_rows[k].append(r)
        try:
            pct = float(r['eq_pct'] or 0)
        except ValueError:
            pct = 0.0
        sc = (residual.RANK.get(r['status'], 0), pct)
        if k not in best or sc > best[k][0]:
            best[k] = (sc, r)
    resid = {k: r for k, (sc, r) in best.items()
             if r['status'] in ('NEAR', 'DIFF') and not residual.is_built(k, built, built_cut)}

    cache = {}

    def fn_pairs(r):
        lst = r['listing']
        if lst not in cache:
            text = open(os.path.join(ORACLE, lst), encoding='latin-1').read()
            cache[lst] = {k.lstrip('_.'): v for k, v in fw.listing_functions(text).items()}
        lines = cache[lst].get(r['listing_name']) or cache[lst].get(r['function'])
        return pairs(lines) if lines else None

    # veto: built functions; every matching attempt read (a function may match at several option sets)
    veto = {}
    for k, rs in sorted(match_rows.items()):
        hits = [(r, fn_pairs(r)) for r in rs]
        with_pair = [(r, p) for r, p in hits if p]
        if with_pair:
            veto[k] = (len(with_pair), len(hits), with_pair[0][0], with_pair[0][1])
    sup = {k: (r, fn_pairs(r)) for k, r in resid.items()}
    sup = {k: v for k, v in sup.items() if v[1]}

    nb = len(match_rows)
    print('## Z2: the reload-after-store rule against V4.23-built firmware functions\n')
    print('Built functions with a matching listing in the index: %d (of %d built).  Residual NEAR / DIFF functions: '
          '%d.\n' % (nb, len(built), len(resid)))
    print(table(('set', 'functions with the pair', 'ROM B of those', 'pairs'), [
        ('veto: built, a matching listing has the pair', len(veto), sum(built.get(k, 0) for k in veto),
         sum(len(v[3]) for v in veto.values())),
        ('veto, every matching listing has it', sum(1 for v in veto.values() if v[0] == v[1]),
         sum(built.get(k, 0) for k, v in veto.items() if v[0] == v[1]), ''),
        ('support: residual best listing has the pair', len(sup), sum(int(r['rom_size'] or 0) for r, p in sup.values()),
         sum(len(p) for r, p in sup.values()))]))
    by = collections.Counter((k[0], width(p[0][1])) for k, v in veto.items() for p in [v[3]])
    print('\n### Veto by image and register width (first pair of each function)\n')
    print(table(('image', 'width', 'functions'), sorted((i, w, n) for (i, w), n in by.items())))
    fl = collections.Counter(v[2]['flags'] for v in veto.values())
    print('\n### Veto by the option set of the first matching listing with the pair\n')
    print(table(('flags', 'functions'), sorted(fl.items(), key=lambda x: -x[1])))
    print('\n### Veto functions (first %d by ROM size)\n' % nlist)
    vr = sorted(veto.items(), key=lambda kv: -built.get(kv[0], 0))[:nlist]
    print(table(('image', 'function', 'ROM B', 'pairs', 'matching listings with / all', 'run', 'flags'), [
        (k[0], k[1], built.get(k, 0), len(v[3]), '%d / %d' % (v[0], v[1]), v[2]['run'], v[2]['flags'])
        for k, v in vr]))

    if '--recompare' in a and sup:
        jobs = []
        for k, (r, p) in sorted(sup.items()):
            src = os.path.join(ORACLE, r['listing'])
            raw = open(src, encoding='latin-1', newline='').read().split('\n')
            drop = {i for i, reg in pairs(raw)}           # every pair in the file: the rule is file-wide
            dst = os.path.join(SCRATCH, r['listing'])
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            open(dst, 'w', encoding='latin-1', newline='').write('\n'.join(l for i, l in enumerate(raw) if i not in drop))
            jobs.append(dict(asm=dst, tree=r['tree'], ctext=attempt_c(r), listing=r['listing'], derive_module=True,
                             want=r['listing_name'], key=k, old=r))
        res, errs = nearmiss.execute(jobs, 2)
        got = {}
        for r in res:
            got.setdefault(r.get('listing'), []).append(r)
        out = []
        for j in jobs:
            new = [x for x in got.get(j['listing'], []) if x.get('listing_name') == j['want']
                   or x.get('function') == j['old']['function']]
            n = new[0] if new else {}
            if n.get('status') == 'DIFF' and nearmiss.near(n, 70):
                n['status'] = 'NEAR'
            out.append((j['key'][0], j['key'][1], j['old']['status'], j['old']['eq_pct'], n.get('status', 'not read'),
                        n.get('eq_pct', ''), n.get('classes', '')))
        print('\n### Support re-compared with the pairs removed\n')
        print(table(('status after', 'functions'), sorted(collections.Counter(o[4] for o in out).items())))
        print()
        print(table(('image', 'function', 'before', 'eq % before', 'after', 'eq % after', 'classes after'),
                    sorted(out, key=lambda o: (o[4] != 'MATCH', o[0], o[1]))))
        for e in errs:
            print('\nnot read: %s' % e)


if __name__ == '__main__':
    main()
