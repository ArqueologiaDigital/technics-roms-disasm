#!/usr/bin/env python3
"""Stage every function a probe run matched, in v10's staging directory, choosing its file by option set.

QUESTION ANSWERED / WHY: probe_v423.py --tsv lists, per function, the probe forms and option sets that give the ROM's
bytes.  This puts each function not yet built (<tree>/cc900/*.c) or staged into
v10/maincpu/cc900-staged/<hand source>[_xr|_xs].c through stage_probe.py:
- a function that matches only at `-O3 -Xr` (O3Xr), only at `-Xr`, or only at `-O3 -XS -Xr` goes to that set's file;
- one that matches at both O3Xr and Xr joins its hand source's existing staging file (the O3Xr one first), and
  otherwise the file its hand source's -O marker suggests: 32-bit constants of 8..0xffff loaded with lda, which
  V4.23 writes only with -O (mem_copies.py's LDA_K).
Then run port_staged.py for the other trees and staged_v423.py to check every tree with V4.23.

usage: python3 notes/cc900-phase6-2026-11-16/stage_matches.py RESULT.tsv [--dry-run]    (from the repository root)
"""
import glob, os, re, subprocess, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
HERE = os.path.dirname(os.path.abspath(__file__))
V10 = os.path.join(REPO, 'v10', 'maincpu')
LDA_K = re.compile(r'^\s*lda\s+x(wa|bc|de|hl|ix|iy|iz)\s*,\s*\((0x[0-9a-f]+|\d+):(8|16)\)\s*$')
SUFFIX = {'O3Xr': ('', '-O3 -Xr'), 'Xr': ('_xr', '-Xr'), 'O3XSXr': ('_xs', '-O3 -XS -Xr')}
FN_RE = re.compile(r'^[\w][\w\s\*]*?\b(\w+)\s*\([^;{)]*\)\s*\{', re.M)


def defined(paths):
    out = set()
    for p in paths:
        s = open(p, encoding='latin-1').read()
        sys.path.insert(0, HERE)
        import stage_probe as sp                             # reads old-style definitions too
        names = {sp.fn_name(d) for k, d in sp.items(s) if k == 'fn'}
        lm = {m.group(1): m.group(2) for m in re.finditer(r'cc900-name:\s*(\w+)\s*=\s*(\w+)', s)}
        out |= {lm.get(n, n) for n in names}
    return out


def hand_source(label):
    r = subprocess.run(['bash', '-c', 'command grep -rlE --include=*.s "^%s:" %s' % (label, V10)],
                       capture_output=True, text=True).stdout.split()
    r = [x for x in r if '/generated/' not in x]
    return os.path.relpath(r[0], V10) if r else None


def marker(src):
    n = 0
    for l in open(os.path.join(V10, src), encoding='latin-1'):
        m = LDA_K.match(l.split(';')[0])
        n += bool(m and 8 <= int(m.group(2), 0) <= 0xffff)
    return n


def main():
    a = sys.argv[1:]
    built = defined(glob.glob(os.path.join(V10, 'cc900', '*.c')))
    staged = defined(glob.glob(os.path.join(V10, 'cc900-staged', '*.c')))
    plan = {}
    for l in open(a[0]):
        c = l.rstrip('\n').split('\t')
        if len(c) < 3 or c[2] in ('-', 'matches'):
            continue
        f, got = c[0], {}
        for x in c[2].split():
            form, s = x.split('@')
            got.setdefault(s, form)
        if f in built or f in staged:
            continue
        src = hand_source(f)
        if src is None:
            print('no hand source for %s' % f); continue
        base = os.path.basename(src)[:-2]
        have = [s for s in ('O3Xr', 'Xr') if os.path.exists(os.path.join(V10, 'cc900-staged', base + SUFFIX[s][0] + '.c'))]
        if 'O3Xr' in got and 'Xr' in got:
            s = have[0] if have else ('O3Xr' if marker(src) else 'Xr')
        else:
            s = next((x for x in ('O3Xr', 'Xr', 'O3XSXr') if x in got), None)
        if s is None:
            print('%s matches only at %s: not staged' % (f, ' '.join(sorted(got)))); continue
        probe = os.path.join(REPO, 'scripts', 'analysis', 'cc900', 'corpus', 'firmware', got[s] + '.c')
        txt = open(probe, encoding='latin-1').read()
        cname = next((m.group(1) for m in re.finditer(r'cc900-name:\s*(\w+)\s*=\s*(\w+)', txt) if m.group(2) == f), f)
        plan.setdefault((probe, base + SUFFIX[s][0], src, SUFFIX[s][1]), []).append(cname)
    for (probe, name, src, opts), fs in sorted(plan.items()):
        cmd = [sys.executable, os.path.join(HERE, 'stage_probe.py'), probe,
               os.path.join(V10, 'cc900-staged', name + '.c'), src, opts] + fs
        if '--dry-run' in a:
            print('%s <- %s: %s' % (name, os.path.basename(probe), ' '.join(fs)))
        else:
            r = subprocess.run(cmd, capture_output=True, text=True)
            print((r.stdout + r.stderr).strip())


if __name__ == '__main__':
    main()
