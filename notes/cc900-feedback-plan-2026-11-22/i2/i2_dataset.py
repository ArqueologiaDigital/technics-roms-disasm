#!/usr/bin/env python3
"""Feedback plan step I2: prepare the firmware C for job_i2.sh, to get thc2's intermediate code (-zim) and storage
records (-g) for every firmware function V4.23 compiles.

QUESTION ANSWERED (with job_i2.sh and i2_registers.py): for every local and parameter of every firmware C function,
which register (or stack slot) V4.23's allocator gave it, next to the intermediate code it allocated from.

    python3 -B notes/cc900-feedback-plan-2026-11-22/i2/i2_dataset.py prepare OUTDIR NSHARDS

writes OUTDIR/shard-<k>/{corpus/, sources.txt, options.txt} and OUTDIR/manifest.tsv (shard, corpus path, label,
SHA-256 of the C, every repository path with that text).  The C files are every <tree>/cc900/*.c of the build
(scripts/build/cc900_v423.py's own file set: the Makefile's), one copy per distinct text and base name, each with its
local headers and at its own `cc900-options:` flags, as the build compiles it.  Run each shard with
    JOB=notes/cc900-feedback-plan-2026-11-22/i2/job_i2.sh ASMFLAGS=notes/cc900-feedback-plan-2026-11-22/i2/dataset.txt \\
      bash scripts/analysis/cc900/oracle/run_oracle.sh i2-fw-<k> OUTDIR/shard-<k>/corpus OUTDIR/shard-<k>/sources.txt \\
      OUTDIR/shard-<k>/options.txt v423
(i2_run_shards.sh does all of them, one VM slot each).  OUTDIR is scratch ($TMPDIR); the runs land in the private
cc900-oracle.
"""
import glob
import hashlib
import os
import shutil
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts', 'build'))
import cc900_v423 as v4  # noqa: E402  local_headers, flags_of, label_of: exactly the build's


def firmware_c():
    pats = ['*/maincpu/cc900/*.c', '*/subcpu/cc900/*.c', 'hdae5000*/cc900/*.c']
    return sorted({p for pat in pats for p in glob.glob(os.path.join(REPO, pat))})


def prepare(out, nshards):
    if os.path.exists(out):
        sys.exit('%s exists: give a new directory' % out)
    groups = {}
    for p in firmware_c():
        key = hashlib.sha256(os.path.basename(p).encode() + b'\0' + open(p, 'rb').read()).hexdigest()
        groups.setdefault(key, []).append(os.path.relpath(p, REPO))
    keys = sorted(groups)
    rows = []
    for i, key in enumerate(keys):
        k = i % nshards
        sd = os.path.join(out, 'shard-%d' % k)
        src = os.path.join(REPO, groups[key][0])
        sub = os.path.join(sd, 'corpus', key[:20])
        os.makedirs(sub)
        shutil.copyfile(src, os.path.join(sub, os.path.basename(src)))
        for n, b in v4.local_headers(src):
            os.makedirs(os.path.dirname(os.path.join(sub, n)), exist_ok=True)
            open(os.path.join(sub, n), 'wb').write(b)
        flags = v4.flags_of(src)
        label = v4.label_of(flags)
        rel = '%s/%s' % (key[:20], os.path.basename(src))
        with open(os.path.join(sd, 'sources.txt'), 'a') as f:
            f.write('%s|%s\n' % (rel, label))
        opts = os.path.join(sd, 'options.txt')
        have = open(opts).read().splitlines() if os.path.exists(opts) else []
        if '%s|%s' % (label, flags) not in have:
            with open(opts, 'a') as f:
                f.write('%s|%s\n' % (label, flags))
        rows.append((k, rel, label, key, ' '.join(groups[key])))
    with open(os.path.join(out, 'manifest.tsv'), 'w') as f:
        f.write('shard\tcorpus_path\tlabel\tkey\tpaths\n')
        for r in rows:
            f.write('\t'.join(str(x) for x in r) + '\n')
    print('%d distinct C texts from %d files, %d shards' % (len(keys), sum(len(v) for v in groups.values()), nshards))


if __name__ == '__main__':
    if len(sys.argv) == 4 and sys.argv[1] == 'prepare':
        prepare(sys.argv[2], int(sys.argv[3]))
    else:
        sys.exit(__doc__)
