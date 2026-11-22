#!/usr/bin/env python3
"""Check stage S4 against V4.23: s4.py's code for every function of job_i2.sh's `zimg` listings, from thc2's own
-zim dump and the -g registers of its parameters and locals, against the code lines thc2 wrote (listing2.py).

QUESTION ANSWERED: for how many functions does our instruction selection write V4.23's exact code (given V4.23's own
S3); refusals by reason and first differences by mnemonic, as a worklist.  Counts only.

    python3 -B scripts/analysis/cc900/stages/s4_check.py [--labels Xr,...] [--record] RUN_DIR [RUN_DIR ...]
"""
import collections
import glob
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import listing2  # noqa: E402
import s3_check  # noqa: E402
import s4  # noqa: E402


def one_file(z):
    c, first = collections.Counter(), collections.Counter()
    fs, tr = listing2.functions(z), s3_check.truth(z)
    if len(fs) != len(tr):
        c['unpaired files'] += 1
        return c, first
    frames = list(s3_check.FRAMES)
    s4.load_types(z)
    inter = z[:-len('_zimg.asm')] + '.inter'
    if os.path.exists(inter):
        s4.load_switches(inter)
    for k_, ((dmp, code), (fn, regs)) in enumerate(zip(fs, tr)):
        c['functions'] += 1
        _, offs, frame = frames[k_] if k_ < len(frames) else (fn, {}, 0)
        try:
            ours = s4.Fn(['FUNC_START'] + [d for d in dmp if 'FUNC_' not in d] + ['FUNC_END'], regs, offs,
                         frame, fn).gen()
        except s4.Unsupported as ex:
            c['refused'] += 1
            first[('refused', str(ex).split(' ')[0])] += 1
            continue
        except Exception as ex:
            c['error'] += 1
            first[('error', type(ex).__name__)] += 1
            continue
        if ours == code:
            c['exact'] += 1
            continue
        k = next(i for i in range(max(len(ours), len(code))) if i >= len(ours) or i >= len(code) or ours[i] != code[i])
        first[((code[k].split(' ')[0] if k < len(code) else '-'), (ours[k].split(' ')[0] if k < len(ours) else '-'))] += 1
    return c, first


def main():
    import multiprocessing
    a = sys.argv[1:]
    labels = None
    if '--labels' in a:
        i = a.index('--labels'); labels = set(a[i + 1].split(',')); a = a[:i] + a[i + 2:]
    record = '--record' in a
    a = [x for x in a if x != '--record']
    files = [z for r in a for z in sorted(glob.glob(os.path.join(r, 'out', '*', '*', '**', '*_zimg.asm'), recursive=True))
             if not labels or os.path.relpath(z, os.path.join(r, 'out')).split(os.sep)[1] in labels]
    c, first = collections.Counter(), collections.Counter()
    with multiprocessing.Pool(8) as pool:
        for c1, f1 in pool.imap_unordered(one_file, files, chunksize=4):
            c.update(c1)
            first.update(f1)
    print(' '.join('%s %d' % kv for kv in sorted(c.items())))
    if record:                                       # a point on the dashboard (results/stage_scores.tsv)
        import stage_scores
        stage_scores.record('S4', c['exact'], c['functions'], 'functions', 'refused %d' % c['refused'])
    print('\nrefusals and first differences (thc2, ours):')
    for k, v in first.most_common(25):
        print('  %5d %s' % (v, k))


if __name__ == '__main__':
    main()
