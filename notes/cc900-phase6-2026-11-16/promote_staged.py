#!/usr/bin/env python3
"""Move every tree's staged firmware C into the build, in one step, once `make` compiles firmware C with V4.23.

QUESTION ANSWERED / WHY: <tree>/maincpu/cc900-staged/*.c holds C that V4.23 reproduces (staged_v423.tsv) but that
the model-built `make` could not build.  After the V4.23 build lands, each staged file moves into <tree>/cc900/:
- if cc900/ has no file of that name, the staged file moves there as it is (its header says "STAGED"; the line is
  rewritten to say the C is built by V4.23);
- if it has one with the same option set, the staged declarations it lacks and the staged functions are appended;
- if it has one with another option set, the staged file goes to cc900/<name>_<label>.c instead (e.g. _o3xr).
Then scripts/tools/cc900_splice.py splices every moved function into its hand source, with --symbols (inner labels)
and --sizes staged_v423.tsv (the V4.23 sizes per tree: no reference model needed).  The staged files are removed
only by hand afterwards (one literal path per rm), once `make gate` passes.

usage: python3 notes/cc900-phase6-2026-11-16/promote_staged.py [--dry-run] [TREE ...]    (default: all five trees)
Run from the repository root; check with `make gate` and `staged_v423.py`-style V4.23 checks of cc900/ afterwards.
"""
import os, re, subprocess, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import stage_probe as sp                                     # noqa: E402
import staged_v423 as sv                                     # noqa: E402

TREES = {'v10': 'v10', 'v9': 'v9', 'v7': 'v7', 'v6': 'v6', 'v5': 'v5'}
SYMREF = 'symbols/maincpu_%s_symbols_reference.txt'


def main():
    a = sys.argv[1:]
    dry = '--dry-run' in a
    trees = [x for x in a if not x.startswith('--')] or list(TREES)
    ledger = os.path.join(HERE, 'staged_v423.tsv')
    for t in trees:
        sdir = os.path.join(REPO, t, 'maincpu', 'cc900-staged')
        cdir = os.path.join(REPO, t, 'maincpu', 'cc900')
        for fn in sorted(os.listdir(sdir)) if os.path.isdir(sdir) else []:
            if not fn.endswith('.c'):
                continue
            sp_path = os.path.join(sdir, fn)
            text = open(sp_path, encoding='latin-1').read()
            flags = sv.file_flags(sp_path)
            dst = os.path.join(cdir, fn)
            if os.path.exists(dst) and sv.file_flags(dst) != flags:
                dst = os.path.join(cdir, fn[:-2] + '_' + sv.LABEL_OF_FLAGS[flags].lower() + '.c')
            if os.path.exists(dst):
                old = open(dst, encoding='latin-1').read()
                if sv.file_flags(dst) != flags:
                    sys.exit('%s: option sets differ from %s' % (dst, sp_path))
                items = sp.items(text)
                add = [d for k, d in items if k == 'decl' and d not in old]
                body = [d for k, d in items if k in ('fn', 'name')]
                new = old.rstrip('\n') + '\n\n' + '\n'.join(add) + ('\n\n' if add else '') + '\n'.join(body) + '\n'
                what = 'append %d functions to' % sum(1 for k, _ in items if k == 'fn')
            else:
                new = text.replace('Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions\' ROM bytes\n'
                                   '   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.',
                                   'Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function\n'
                                   '   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).')
                what = 'create'
            print('%s: %s %s' % (t, what, os.path.relpath(dst, REPO)))
            if dry:
                continue
            open(dst, 'w', encoding='latin-1').write(new)
            r = subprocess.run([sys.executable, os.path.join(REPO, 'scripts', 'tools', 'cc900_splice.py'),
                                os.path.join(t, 'maincpu'), os.path.relpath(dst, REPO), '--symbols', SYMREF % t,
                                '--sizes', ledger], capture_output=True, text=True, cwd=REPO)
            print('   ' + (r.stdout + r.stderr).strip().replace('\n', '\n   '))
            if r.returncode:
                sys.exit('stopped: the splice failed')


if __name__ == '__main__':
    main()
