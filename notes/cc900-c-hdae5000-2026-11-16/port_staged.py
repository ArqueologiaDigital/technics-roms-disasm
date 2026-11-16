#!/usr/bin/env python3
"""Which of the v2.06i staged C functions does V4.23 reproduce in the older HD-AE5000 images too, unchanged?  Stage
them per tree.

QUESTION ANSWERED: hdae5000_v2_01i, hdae5000_v1_15i and hdae5000_v1_10i are ported from hdae5000 and keep its
labels; the C names its RAM cells and routines by the trees' own names, which resolve to each tree's addresses.  So
one V4.23 listing of a staged file can be checked against each image (hd_v423.py --check RUN --image IMG).  This
writes <tree>/cc900-staged/<file>.c for each ported tree holding the functions of hdae5000/cc900-staged/<file>.c
that match that image (exact, or with calr when the calr targets match too), with all the file's declarations.
Functions that do not match there are left out: their C uses a v2.06i number (a `ram_<hex>` string address, a UI
object id) that the older build has elsewhere, or the function changed.

    python3 -B notes/cc900-c-hdae5000-2026-11-16/port_staged.py RUN_DIR
        RUN_DIR: an oracle run that compiled the current hdae5000/cc900-staged/*.c (their text must not have changed
        since).  Prints per tree and file what it staged.
Run from the repository root.  The per-tree files are then rechecked and recorded by a run of their own.
"""
import os, re, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, HERE)
import stage_from_probe as sp                                # noqa: E402

PORTS = [('v2.01i', 'hdae5000_v2_01i'), ('v1.15i', 'hdae5000_v1_15i'), ('v1.10i', 'hdae5000_v1_10i')]


def matches(run, image):
    """{(file stem, C name)} that MATCH in IMAGE, and the calr targets each needs"""
    if not os.environ.get('TMPDIR'):             # house rule: scratch goes under $TMPDIR, never /tmp
        sys.exit('port_staged.py: TMPDIR is not set (scratch goes to $TMPDIR, never /tmp)')
    tsv = os.path.join(os.environ['TMPDIR'], 'port_staged_%s.tsv' % image)
    subprocess.run([sys.executable, '-B', os.path.join(HERE, 'hd_v423.py'), '--check', run, '--calr', '--only',
                    'hdae5000_*', '--image', image, '--tsv', tsv], cwd=REPO, capture_output=True, check=True)
    ok = {}
    for l in open(tsv).read().split('\n')[1:]:
        f = l.split('\t')
        if len(f) == 5 and f[4].startswith('MATCH'):
            stem, _, cname = f[0].partition(':')
            calr = re.search(r'calr:(\S+)', f[4])
            ok[(stem, cname or f[2])] = (f[2], calr.group(1).split(',') if calr else [])
    os.remove(tsv)
    return ok


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    run = sys.argv[1]
    src_dir = os.path.join(REPO, 'hdae5000', 'cc900-staged')
    for image, tree in PORTS:
        ok = matches(run, image)
        ref = {}
        for l in open(os.path.join(REPO, 'symbols', '%s_symbols_reference.txt' % tree)):
            p = l.split()
            if len(p) == 2 and not l.startswith('#'):
                ref[int(p[1], 16)] = p[0]
        for f in sorted(os.listdir(src_dir)):
            if not f.endswith('.c'):
                continue
            stem = f[:-2]
            keep = {c for (s, c) in ok if s == stem}
            # a calr match needs its targets in the file, matching too
            labels = {ok[(stem, c)][0] for c in keep}
            changed = True
            while changed:
                changed = False
                for c in sorted(keep):
                    lab, targets = ok[(stem, c)]
                    if any(ref.get(int(t, 16)) not in labels for t in targets):
                        keep.discard(c); labels.discard(lab); changed = True
            if not keep:
                continue
            out_dir = os.path.join(REPO, tree, 'cc900-staged')
            os.makedirs(out_dir, exist_ok=True)
            what = ('%s: the functions of hdae5000/cc900-staged/%s that V4.23 reproduces unchanged in HD-AE5000 %s '
                    '(port_staged.py).' % (tree, f, image))
            sys.argv = ['x', os.path.join(src_dir, f), os.path.join(out_dir, f), what] + sorted(keep)
            sp.main()


if __name__ == '__main__':
    main()
