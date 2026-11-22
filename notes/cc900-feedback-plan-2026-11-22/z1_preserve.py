#!/usr/bin/env python3
"""Step Z1 of the feedback plan: preserve the C that every oracle run compiled, and measure how much is retrievable.

QUESTION ANSWERED: an oracle run (~/compartilhado/cc900-oracle/runs/<run>/) keeps only the SHA-256 of its corpus.tar
(inputs.sha256), not the C it compiled.  The near-miss index (notes/cc900-c-nearmiss/index.tsv) found each attempt's C
in scratch (`tar-sha256`: a scratch directory whose tar has that hash), by name (`name+funcs`, likely) or not at all
(`none`); only 19,041 attempts had a committed copy (the index's c_copy column, notes/cc900-c-nearmiss/c/).  Scratch
is deleted when space runs short.  This script copies every corpus directory that still reproduces a run's recorded
tar hash into a git repository of its own, then counts, per provenance, the compared attempts whose C is retrievable
from git by its SHA-256.

ARCHIVE (default ~/compartilhado/cc900-attempts-c, a local git repository with no remote, our own C only; no Toshiba
output is copied: the corpora hold the C, two headers and the run's sources.txt / options.txt / manifest lists):
    runs/<run>/...       the corpus directory as run_oracle.sh tarred it
    MANIFEST.tsv         run, corpus.tar sha256, file, file sha256, size; one row per file

The corpus directories are found as nearmiss.py finds them (corpus_hashes(): every directory up to depth 3 under
$TMPDIR/cc900-tab, tar-hashed the way run_oracle.sh tars it, cached in lane_nmx/corpus_hashes.json).  Nothing is
deleted or overwritten: a run already in the archive is kept as it is.

Usage, from technics-roms-disasm's root:
    python3 -B notes/cc900-feedback-plan-2026-11-22/z1_preserve.py [--archive DIR] [--copy]
Without --copy it only measures.  Prints Markdown.  Commit the archive afterwards (git -C ARCHIVE add -A; commit).
"""
import collections
import hashlib
import os
import shutil
import sys

sys.path.insert(0, 'scripts/analysis/cc900')
import nearmiss  # noqa: E402

ORACLE_RUNS = os.path.expanduser('~/compartilhado/cc900-oracle/runs')
INDEX = 'notes/cc900-c-nearmiss/index.tsv'
NEARMISS_DIR = 'notes/cc900-c-nearmiss'
COMPARED = ('MATCH', 'NEAR', 'DIFF')


def run_corpus_sha(run):
    p = os.path.join(ORACLE_RUNS, run, 'inputs.sha256')
    if not os.path.exists(p):
        return ''
    for line in open(p):
        f = line.split()
        if f and f[-1] == 'corpus.tar':
            return f[0]
    return ''


def sha256(p):
    return hashlib.sha256(open(p, 'rb').read()).hexdigest()


def table(head, rows):
    w = [max(len(str(x)) for x in c) for c in zip(head, *rows)]
    out = ['| ' + ' | '.join(str(h).ljust(n) for h, n in zip(head, w)) + ' |',
           '|' + '|'.join('-' * (n + 2) for n in w) + '|']
    out += ['| ' + ' | '.join(str(x).ljust(n) for x, n in zip(r, w)) + ' |' for r in rows]
    return '\n'.join(out)


def main():
    a = sys.argv[1:]
    archive = os.path.expanduser(a[a.index('--archive') + 1] if '--archive' in a else '~/compartilhado/cc900-attempts-c')
    copy = '--copy' in a
    runs = sorted(r for r in os.listdir(ORACLE_RUNS) if os.path.isdir(os.path.join(ORACLE_RUNS, r)))
    hashes = nearmiss.corpus_hashes(nearmiss.CORPUS_ROOTS)
    state = {}
    copied = 0
    for run in runs:
        sha = run_corpus_sha(run)
        dst = os.path.join(archive, 'runs', run)
        if os.path.isdir(dst):
            state[run] = 'archived'
        elif sha and sha in hashes:
            state[run] = 'in scratch'
            if copy:
                shutil.copytree(hashes[sha], dst, symlinks=False)
                state[run] = 'archived'
                copied += 1
        else:
            state[run] = 'lost' if sha else 'no corpus hash'
    if copy:
        rows = []
        for run in runs:
            d = os.path.join(archive, 'runs', run)
            if not os.path.isdir(d):
                continue
            for dp, dn, fn in os.walk(d):
                dn.sort()
                for f in sorted(fn):
                    p = os.path.join(dp, f)
                    rows.append('\t'.join((run, run_corpus_sha(run), os.path.relpath(p, d), sha256(p),
                                           str(os.path.getsize(p)))))
        with open(os.path.join(archive, 'MANIFEST.tsv'), 'w') as f:
            f.write('run\tcorpus_tar_sha256\tfile\tsha256\tsize\n' + '\n'.join(rows) + '\n')

    # every archived file by its sha256, and every committed c_copy
    have = {}
    for run in runs:
        d = os.path.join(archive, 'runs', run)
        if os.path.isdir(d):
            for dp, dn, fn in os.walk(d):
                for f in fn:
                    if f.endswith('.c'):
                        have[(run, os.path.relpath(os.path.join(dp, f), d))] = sha256(os.path.join(dp, f))
    f = open(INDEX, encoding='utf-8')
    head = f.readline().rstrip('\n').split('\t')
    col = {n: i for i, n in enumerate(head)}
    cnt = collections.Counter()
    shas = collections.defaultdict(set)
    for line in f:
        r = line.rstrip('\n').split('\t')
        if r[col['status']] not in COMPARED:
            continue
        prov = r[col['c_provenance']]
        in_archive = have.get((r[col['run']], r[col['source']])) == r[col['c_sha256']] != ''
        in_copy = bool(r[col['c_copy']]) and os.path.exists(os.path.join(NEARMISS_DIR, r[col['c_copy']]))
        where = 'archive' if in_archive else ('c_copy only' if in_copy else 'not retrievable')
        cnt[(prov, where)] += 1
        shas[where].add(r[col['c_sha256']])
    print('## Z1: oracle runs by corpus state\n')
    print(table(('state', 'runs'), sorted(collections.Counter(state.values()).items())))
    print('\nCopied now: %d.  Archive: `%s`.\n' % (copied, archive))
    print('## Z1: compared attempts (MATCH / NEAR / DIFF rows of index.tsv) by where their C is\n')
    print(table(('C provenance', 'where the C is', 'attempts'), sorted((p, w, n) for (p, w), n in cnt.items())))
    print('\n`archive`: the run\'s corpus, tar hash checked, holds the file with the index\'s SHA-256.  `c_copy only`: only the near-miss index\'s'
          ' copy (`c/`; `name+funcs` copies are likely, not proven).  Distinct C SHA-256 values: %s.'
          % ', '.join('%s %d' % (w, len(s)) for w, s in sorted(shas.items())))


if __name__ == '__main__':
    main()
