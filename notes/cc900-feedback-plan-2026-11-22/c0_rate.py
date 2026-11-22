#!/usr/bin/env python3
"""Step C0 of the feedback plan: how fast did the reference model gain, and how many batches would firmware parity take?

QUESTION ANSWERED: phase 3a's batches (1-366, 2026-11-10..16) were judged on micro corpora.  Before resuming them on
the firmware (decision E1), estimate the effort: score model snapshots taken from git along phase 3a on
  - validation: corpus/validation (random6-8 + rstmt6-8, 600 functions, never tuned on), functions exact per option
    set, through val_agg.py (totals only);
  - firmware: every function of the v10 C files (v10/maincpu/cc900/*.c, as on main now) that the build makes from C
    (V4.23 MATCH), compiled by that snapshot as the build compiles firmware C (cc900_firmware_c.compile_c through
    c_build_coverage.firmware) and compared with the ROM; MATCH count and bytes;
and fit the gain per batch.  The batch number of a snapshot is the last "Batch N" heading of
notes/cc900-compat-plan-2026-11-08/phase3a-status.md at that commit.

Snapshots are extracted with `git archive` into $TMPDIR/cc900-tab/c0/<commit>/ (scratch, regenerable); a snapshot that
cannot compile the current firmware C (front end refuses) simply scores lower: that is what it could do.

Usage, from technics-roms-disasm's root:
    python3 -B notes/cc900-feedback-plan-2026-11-22/c0_rate.py [COMMIT ...]      (default: the SNAPSHOTS below)
Prints Markdown.
"""
import json
import os
import re
import subprocess
import sys

REPO = os.path.abspath('.')
CC = os.path.join(REPO, 'scripts', 'analysis', 'cc900')
SCRATCH = os.path.join(os.environ.get('TMPDIR', os.path.expanduser('~/compartilhado/tmp')), 'cc900-tab', 'c0')
STATUS = 'notes/cc900-compat-plan-2026-11-08/phase3a-status.md'
SNAPSHOTS = ['3a3c757b6', '1110bb9cc', '7fdb72f60', 'd0515aa3a', 'aa41a61c7', '73c97b315', '2930d4097', 'ec9388439',
             'f5d9663ce']
MODEL_MODULES = ('frontend', 'codegen', 'to_llvm', 'listing', 'cache', 'interp', 'score', 'check_bytes')


def git(*a):
    return subprocess.run(('git',) + a, capture_output=True, text=True, check=True).stdout


def extract(commit):
    d = os.path.join(SCRATCH, commit)
    if not os.path.isdir(os.path.join(d, 'scripts', 'analysis', 'cc900', 'model')):
        os.makedirs(d, exist_ok=True)
        tar = subprocess.run(['git', 'archive', commit, 'scripts/analysis/cc900/model'], capture_output=True,
                             check=True).stdout
        subprocess.run(['tar', '-x', '-C', d], input=tar, check=True)
    return os.path.join(d, 'scripts', 'analysis', 'cc900', 'model')


def batch_at(commit):
    try:
        text = git('show', '%s:%s' % (commit, STATUS))
    except subprocess.CalledProcessError:
        return None
    nums = [int(n) for n in re.findall(r'\*\*Batch (\d+)', text)]
    return max(nums) if nums else None


def validation(mdir):
    r = subprocess.run([sys.executable, '-I', '-B', 'val_agg.py', mdir, '-j', '8'], cwd=CC, capture_output=True,
                       text=True)
    out = {}
    for line in r.stdout.splitlines():
        m = re.match(r'^(\w+)\s+functions (\d+): exact (\d+)', line)
        if m:
            out[m.group(1)] = int(m.group(3))
    return out


def child(mdir):
    """in a fresh process: c_build_coverage.firmware('v10', ...) with the snapshot's model modules"""
    sys.path.insert(0, CC)
    import c_build_coverage as cbc
    sys.path.insert(0, os.path.join(CC, 'model'))
    import check_bytes  # noqa: F401  the current comparison helper (older snapshots' was a script that ran on import)
    sys.path.pop(0)
    for m in MODEL_MODULES:                       # the build's helpers stay; the model's modules come from mdir
        if m != 'check_bytes':
            sys.modules.pop(m, None)
    sys.path.insert(0, mdir)
    import codegen
    for flag in ('KN_LOOP_INVERT', 'KN_SHIFT_UNSIGNED_SLL', 'KN_MEM_TO_MEM'):
        if not hasattr(codegen, flag):
            setattr(codegen, flag, False)        # an older snapshot without the switch: off, as it then behaved
    key, title, tree, rom, sym = [i for i in cbc.IMAGES if i[0] == 'v10'][0]
    rows = cbc.firmware(key, tree, rom, sym)
    built = [r for r in rows if r['built'] and r.get('V4.23') is True]
    print(json.dumps(dict(built=len(built), built_b=sum(r['bytes'] for r in built),
                          model=sum(1 for r in built if r['model']),
                          model_b=sum(r['bytes'] for r in built if r['model']))))


def table(head, rows):
    w = [max(len(str(x)) for x in c) for c in zip(head, *rows)]
    out = ['| ' + ' | '.join(str(h).ljust(n) for h, n in zip(head, w)) + ' |',
           '|' + '|'.join('-' * (n + 2) for n in w) + '|']
    out += ['| ' + ' | '.join(str(x).ljust(n) for x, n in zip(r, w)) + ' |' for r in rows]
    return '\n'.join(out)


def main():
    a = sys.argv[1:]
    if a and a[0] == '--child':
        return child(a[1])
    commits = a or SNAPSHOTS
    rows, series = [], []
    for c in commits:
        mdir = extract(c)
        date = git('log', '-1', '--format=%ad', '--date=format:%Y-%m-%d %H:%M', c).strip()
        cache_p = os.path.join(SCRATCH, c, 'result.json')     # a snapshot's scores never change: kept per commit
        try:
            v, fwr = json.load(open(cache_p))
        except (OSError, ValueError):
            v = validation(mdir)
            r = subprocess.run([sys.executable, '-B', os.path.abspath(__file__), '--child', mdir], capture_output=True,
                               text=True)
            try:
                fwr = json.loads(r.stdout.strip().splitlines()[-1])
                json.dump([v, fwr], open(cache_p, 'w'))
            except (ValueError, IndexError):
                fwr = dict(built=0, built_b=0, model=0, model_b=0)
                sys.stderr.write('%s firmware: %s\n' % (c, r.stderr[-400:]))
        series.append((batch_at(c), sum(v.values()), fwr))
        rows.append((c, date, batch_at(c), v.get('none', ''), v.get('O3XS', ''), v.get('Xr', ''), v.get('O3XSXr', ''),
                     '%d / %d' % (fwr['model'], fwr['built']), '%d / %d' % (fwr['model_b'], fwr['built_b'])))
        sys.stderr.write('%s done\n' % c)
    print('## C0: the reference model along phase 3a\n')
    print(table(('commit', 'date', 'batch', 'val none', 'val O3XS', 'val Xr', 'val O3XSXr', 'v10 built fns', 'v10 built B'),
                rows))
    print('\nval: validation functions exact of 600 per option set (val_agg.py).  v10 built: functions the build makes '
          'from C with V4.23 that the snapshot also reproduces, of all such functions (the current C files).')
    series = [x for x in series if x[0] is not None and x[2]['built']]
    if len(series) >= 2:
        (b0, v0, f0), (b1, v1, f1) = series[0], series[-1]
        nb = b1 - b0
        fn_rate, b_rate, v_rate = (f1['model'] - f0['model']) / nb, (f1['model_b'] - f0['model_b']) / nb, (v1 - v0) / nb
        left_fn, left_b = f1['built'] - f1['model'], f1['built_b'] - f1['model_b']
        tail = [x for x in series if x[0] >= b1 - 30]
        tb = tail[-1][0] - tail[0][0]
        print('\n## C0: the estimate\n')
        print(table(('measure', 'batch %d' % b0, 'batch %d' % b1, 'gain per batch', 'left', 'batches at that rate'), [
            ('v10 built functions reproduced', f0['model'], f1['model'], '%.3f' % fn_rate, left_fn,
             '%.0f' % (left_fn / fn_rate) if fn_rate > 0 else 'never'),
            ('their ROM bytes', f0['model_b'], f1['model_b'], '%.2f' % b_rate, left_b,
             '%.0f' % (left_b / b_rate) if b_rate > 0 else 'never'),
            ('validation exact, four sets summed (of 2,400)', v0, v1, '%.3f' % v_rate, 2400 - v1,
             '%.0f' % ((2400 - v1) / v_rate) if v_rate > 0 else 'never')]))
        if tb > 0:
            print('\nOver the last %d batches (%d to %d) validation gained %.3f per batch and the firmware %.3f functions '
                  'per batch.' % (tb, tail[0][0], tail[-1][0], (tail[-1][1] - tail[0][1]) / tb,
                                  (tail[-1][2]['model'] - tail[0][2]['model']) / tb))


if __name__ == '__main__':
    main()
