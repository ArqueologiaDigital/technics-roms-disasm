#!/usr/bin/env python3
"""Which tracked staging files are fully promoted, so that `git rm` may take them?

QUESTION ANSWERED / WHY: after promote_staged.py, a staged file whose every function is now defined in its tree's
cc900/ is redundant (two definitions of one function must not survive).  This prints, one per line, each tracked
<tree>/maincpu/cc900-staged/*.c whose functions all appear in <tree>/maincpu/cc900/*.c, and on stderr the staged
files that stay (with the functions still missing), so the `git rm -- <paths>` list is explicit and checked.
It deletes nothing.

usage: python3 -B notes/cc900-phase6-2026-11-16/list_promoted.py      (from the repository root)
"""
import os, re, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, HERE)
import stage_probe as sp                                     # noqa: E402
import promote_staged as ps                                  # noqa: E402


def main():
    for t in ('v10', 'v9', 'v7', 'v6', 'v5'):
        sdir = os.path.join(t, 'maincpu', 'cc900-staged')
        tracked = subprocess.run(['git', 'ls-files', '--', sdir], capture_output=True, text=True,
                                 cwd=REPO).stdout.split()
        have = ps.tree_functions(os.path.join(REPO, t, 'maincpu', 'cc900'))
        for rel in tracked:
            if not rel.endswith('.c'):
                continue
            text = open(os.path.join(REPO, rel), encoding='latin-1').read()
            lm = {m.group(1): m.group(2) for m in re.finditer(r'cc900-name:\s*(\w+)\s*=\s*(\w+)', text)}
            fns = [lm.get(sp.fn_name(d), sp.fn_name(d)) for k, d in sp.items(text) if k == 'fn']
            miss = [f for f in fns if f not in have]
            if fns and not miss:
                print(rel)
            else:
                print('stays %s: %s' % (rel, ' '.join(miss) or '(no function)'), file=sys.stderr)


if __name__ == '__main__':
    main()
