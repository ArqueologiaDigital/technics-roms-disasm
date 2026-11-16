#!/usr/bin/env python3
"""Which staged firmware C does Toshiba V4.23 turn into the ROM's bytes, in every tree?

QUESTION ANSWERED: <tree>/cc900-staged/*.c holds firmware C that V4.23 reproduces but that `make` cannot build yet
(it builds with the cc900 reference model until the V4.23 build lands).  For each tree (v10, v9, v7, v6, v5) and each
staged file, compile it with V4.23 at the file's own option set (its `cc900-options:` comment, default
-O3 -XS -Xr) and compare each function with the tree's ROM through asm_vs_rom.py.  A function is done when it MATCHes
in every tree that has it.

    python3 -B notes/cc900-phase6-2026-11-16/staged_v423.py --corpus DIR
        copies every tree's staged C into DIR/<tree>/, writes sources.txt / options.txt / manifest.tsv, and prints the
        oracle run command (one VM run for all of them)
    python3 -B notes/cc900-phase6-2026-11-16/staged_v423.py --check RUN_DIR DIR [--record]
        one line per tree, file and function: MATCH or the first differing offset.  --record rewrites
        notes/cc900-phase6-2026-11-16/staged_v423.tsv (tree, C file, SHA-256 of its text, options, run, function,
        bytes, result) for the staged files that RUN_DIR compiled.

No Toshiba text is printed or written: only names, sizes and verdicts.  Run from the repository root.
"""
import hashlib, os, re, shutil, subprocess, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts', 'build'))
import cc900_firmware_c as fw                                # noqa: E402

TREES = [('v10', 'kn5000_v10_program.rom'), ('v9', 'kn5000_v9_program.rom'), ('v7', 'kn5000_v7_program.rom'),
         ('v6', 'kn5000_v6_program.rom'), ('v5', 'kn5000_v5_program.rom')]
LABEL_OF_FLAGS = {'-O3 -XS -Xr': 'O3XSXr', '-Xr': 'Xr', '-O3 -XS': 'O3XS', '': 'none'}
LEDGER = os.path.join(REPO, 'notes', 'cc900-phase6-2026-11-16', 'staged_v423.tsv')
ORACLE = os.path.expanduser('~/compartilhado/cc900-oracle')


def sha256(p):
    return hashlib.sha256(open(p, 'rb').read()).hexdigest()


def staged():
    for t, rom in TREES:
        d = os.path.join(REPO, t, 'maincpu', 'cc900-staged')
        for f in sorted(os.listdir(d)) if os.path.isdir(d) else []:
            if f.endswith('.c'):
                yield t, rom, os.path.join(d, f)


def corpus(d):
    d = os.path.abspath(d)
    rows, labels = [], set()
    for t, _, p in staged():
        dst = '%s/%s' % (t, os.path.basename(p))
        os.makedirs(os.path.join(d, t), exist_ok=True)
        shutil.copyfile(p, os.path.join(d, dst))
        rows.append((os.path.relpath(p, REPO), dst))
        labels.add(LABEL_OF_FLAGS[fw.file_options(p)[0]])
    flags = {v: k for k, v in LABEL_OF_FLAGS.items()}
    open(os.path.join(d, 'sources.txt'), 'w').write(''.join(dst + '\n' for _, dst in rows))
    open(os.path.join(d, 'options.txt'), 'w').write(''.join('%s|%s\n' % (l, flags[l]) for l in sorted(labels)))
    open(os.path.join(d, 'manifest.tsv'), 'w').write(''.join('%s\t%s\n' % r for r in rows))
    print('%d staged C files in %s, option sets %s' % (len(rows), d, ' '.join(sorted(labels))))
    print('run (from scripts/analysis/cc900): flock %s/vm/.runlock bash oracle/run_oracle.sh p6-staged %s %s/sources.txt '
          '%s/options.txt v423' % (ORACLE, d, d, d))


def check(run_dir, d, record):
    run = os.path.basename(os.path.normpath(run_dir))
    out, bad = [], 0
    for line in open(os.path.join(d, 'manifest.tsv')):
        src, dst = line.rstrip('\n').split('\t')
        t = dst.split('/')[0]
        rom = dict(TREES)[t]
        label = LABEL_OF_FLAGS[fw.file_options(os.path.join(d, dst))[0]]
        lst = os.path.join(run_dir, 'out', 'v423', label, dst[:-2] + '.asm')
        if not os.path.exists(lst):
            print('%-4s %-28s no listing at %s' % (t, os.path.basename(src), label)); bad += 1
            continue
        r = subprocess.run([sys.executable, '-I', '-B', os.path.join(REPO, 'scripts', 'analysis', 'cc900', 'asm_vs_rom.py'),
                            lst, '--tree', '%s/maincpu' % t, '--rom', 'original_ROMs/' + rom,
                            '--symbols', 'symbols/maincpu_%s_symbols_reference.txt' % t, '--cfile', os.path.join(d, dst)],
                           capture_output=True, text=True, cwd=os.path.join(REPO, 'scripts', 'analysis', 'cc900'))
        for l in r.stdout.splitlines():
            m = re.match(r'^(\S+)\s+(\d+) B\s+(MATCH|DIFF at \+\d+)$', l)
            res = (m.group(1), m.group(2), m.group(3)) if m else (l.split()[0] if l.split() else '?', '-', l[32:].strip())
            bad += res[2] != 'MATCH'
            print('%-4s %-28s %-7s %-34s %4s  %s' % (t, os.path.basename(src), label, *res))
            out.append([t, src, sha256(os.path.join(d, dst)), label, run, *res])
    if record:
        keep = []
        if os.path.exists(LEDGER):
            done = {(r[1], r[3]) for r in out}
            keep = [l.rstrip('\n').split('\t') for l in open(LEDGER) if not l.startswith(('#', 'tree\t'))]
            keep = [k for k in keep if (k[1], k[3]) not in done]
        rows = sorted(keep + out, key=lambda r: (r[1], r[5]))
        with open(LEDGER, 'w') as fh:
            fh.write('# Staged firmware C (<tree>/maincpu/cc900-staged/) checked against the ROM with Toshiba V4.23, by\n'
                     '# notes/cc900-phase6-2026-11-16/staged_v423.py --check --record.  The listings stay in the private oracle repo.\n'
                     'tree\tc_file\tsha256\toptions\trun\tfunction\tbytes\tresult\n')
            for r in rows:
                fh.write('\t'.join(r) + '\n')
        print('%d rows in %s' % (len(rows), os.path.relpath(LEDGER, REPO)))
    return 1 if bad else 0


def main():
    a = sys.argv[1:]
    if '--corpus' in a:
        return corpus(a[a.index('--corpus') + 1])
    if '--check' in a:
        i = a.index('--check')
        return check(a[i + 1], a[i + 2], '--record' in a)
    sys.exit(__doc__)


if __name__ == '__main__':
    sys.exit(main())
