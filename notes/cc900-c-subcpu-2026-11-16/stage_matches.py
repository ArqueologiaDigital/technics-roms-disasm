#!/usr/bin/env python3
"""Stage every function a probe run matched at -Xr, in v142's staging directory.

QUESTION ANSWERED / WHY: sub_v423.py check --tsv lists, per function, the probe files and option sets that give the
ROM's bytes.  The payload was compiled with -Xr (README, run 2026-11-16-43-sub-r1), so a function that matches at
`-Xr` goes to v142/subcpu/cc900-staged/<hand source without its NN_ prefix>.c through stage_probe.py (the function,
its cc900-name comment and the declarations it uses).  A probe that uses #define is expanded first (gcc -E -P -C),
so that the staged C has no macros.  A function matching only at another set is reported, not staged.  Then run port_staged.py for v141 / v140 and check all three trees with V4.23 (sub_v423.py corpus / record).

usage: python3 -B notes/cc900-c-subcpu-2026-11-16/stage_matches.py VERDICTS.tsv [--dry-run] [--own-file]   (repo root)
    --own-file: stage into <hand source>_<probe>.c (e.g. dsp_control_routines_e_6a.c), so that a probe's own
    prototypes and cc900-module: list stay with the functions they were checked with
"""
import glob, os, re, subprocess, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
HERE = os.path.dirname(os.path.abspath(__file__))
TREE = os.path.join(REPO, 'v142', 'subcpu')
SCRATCH = os.path.join(os.environ.get('TMPDIR', os.path.expanduser('~/compartilhado/tmp')), 'cc900-tab', 'lane_sub',
                       'expanded')                       # probes with #define, macro-expanded by gcc -E (scratch)
FN_RE = re.compile(r'^[\w][\w\s\*]*?\b(\w+)\s*\([^;{)]*\)\s*\{', re.M)


def defined(paths):
    out = set()
    for p in paths:
        s = open(p, encoding='latin-1').read()
        lm = {m.group(1): m.group(2) for m in re.finditer(r'cc900-name:\s*(\w+)\s*=\s*(\w+)', s)}
        out |= {lm.get(n, n) for n in FN_RE.findall(s)}
    return out


def hand_source(label):
    r = subprocess.run(['bash', '-c', 'command grep -rlE --include=*.s "^%s:" %s' % (label, TREE)],
                       capture_output=True, text=True).stdout.split()
    r = [x for x in r if '/generated/' not in x and '/cc900' not in x]
    return os.path.relpath(r[0], TREE) if r else None


def main():
    a = sys.argv[1:]
    staged = defined(glob.glob(os.path.join(TREE, 'cc900-staged', '*.c')))
    plan = {}
    for l in open(a[0]):
        c = l.rstrip('\n').split('\t')
        if len(c) < 3 or c[2] in ('-', 'matches'):
            continue
        f = c[0]
        got = {}
        for x in c[2].split():
            form, s = x.split('@')
            got.setdefault(s, form)
        if f in staged:
            continue
        if 'Xr' not in got:
            print('%s matches only at %s: not staged' % (f, ' '.join(sorted(got)))); continue
        src = hand_source(f)
        if src is None:
            print('no hand source for %s' % f); continue
        base = re.sub(r'^\d+_', '', os.path.basename(src)[:-2])
        probe = os.path.join(REPO, 'scripts', 'analysis', 'cc900', 'corpus', 'firmware', got['Xr'] + '.c')
        txt = open(probe, encoding='latin-1').read()
        if re.search(r'^\s*#\s*define', txt, re.M):          # macros: stage from the macro-expanded text
            out = os.path.join(SCRATCH, os.path.basename(probe))
            os.makedirs(SCRATCH, exist_ok=True)
            subprocess.run(['gcc', '-E', '-P', '-C', '-std=c89', '-o', out, probe], check=True)
            probe, txt = out, open(out, encoding='latin-1').read()
        defs = set(FN_RE.findall(txt))                   # a short name may only declare a callee: take a defined one
        cname = next((m.group(1) for m in re.finditer(r'cc900-name:\s*(\w+)\s*=\s*(\w+)', txt)
                      if m.group(2) == f and m.group(1) in defs), f)
        if '--own-file' in a:            # one staging file per hand source AND probe: no clash with earlier rounds'
            base = '%s_%s' % (base, got['Xr'].replace('sub_', '').lower())   # prototypes or cc900-module: lists
        plan.setdefault((probe, base, src), []).append(cname)
    for (probe, name, src), fs in sorted(plan.items()):
        cmd = [sys.executable, os.path.join(HERE, 'stage_probe.py'), probe,
               os.path.join(TREE, 'cc900-staged', name + '.c'), src, '-Xr'] + fs
        if '--dry-run' in a:
            print('%s <- %s: %s' % (name, os.path.basename(probe), ' '.join(fs)))
        else:
            r = subprocess.run(cmd, capture_output=True, text=True)
            print((r.stdout + r.stderr).strip())


if __name__ == '__main__':
    main()
