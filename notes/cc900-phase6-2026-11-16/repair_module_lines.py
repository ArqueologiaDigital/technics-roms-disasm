#!/usr/bin/env python3
"""Give back the `cc900-module:` names that promote_staged.py dropped when it APPENDED staged functions to a
built cc900/ file (fixed in promote_staged.py on 2026-11-16 after run r18's promotion).

QUESTION ANSWERED / WHY: the r18 gate stopped at `.org 0xf97d8d` because BmDrEdit_CalcBeatMeasure ended in
`jp BmDrEdit_CalcSongPosition` (4 bytes) instead of the ROM's `jr` (2 bytes): its staged file named the callee in a
`cc900-module:` comment and the append did not carry it.  For every tree's cc900/*.c that git reports modified, this
takes each staged file (cc900-staged/*.c of the same tree) that defines one of its functions, and adds the staged
module names the built file lacks, as one more `/* cc900-module: ... */` comment (the build reads any number).

usage: python3 -B notes/cc900-phase6-2026-11-16/repair_module_lines.py [--dry-run]   (from the repository root)
"""
import os, re, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, HERE)
import stage_probe as sp                                     # noqa: E402
MOD_RE = re.compile(r'cc900-module:([^*\n]*)')
TREES = ('v10', 'v9', 'v7', 'v6', 'v5')


def names(text):
    return set(' '.join(MOD_RE.findall(text)).replace(',', ' ').split())


def fns(text):
    return {sp.fn_name(d) for k, d in sp.items(text) if k == 'fn'}


def main():
    dry = '--dry-run' in sys.argv
    for t in TREES:
        cdir = os.path.join(REPO, t, 'maincpu', 'cc900')
        sdir = os.path.join(REPO, t, 'maincpu', 'cc900-staged')
        changed = subprocess.run(['git', 'diff', '--name-only', 'HEAD', '--', cdir], capture_output=True,
                                 text=True, cwd=REPO).stdout.split()
        staged = {}
        if os.path.isdir(sdir):
            for f in sorted(os.listdir(sdir)):
                if f.endswith('.c'):
                    s = open(os.path.join(sdir, f), encoding='latin-1', newline='').read()
                    staged[f] = (fns(s), names(s))
        for rel in changed:
            path = os.path.join(REPO, rel)
            if not os.path.exists(path):
                continue
            text = open(path, encoding='latin-1', newline='').read()
            mine, have = fns(text), names(text)
            want = set()
            for f, (sf, sm) in staged.items():
                if sf & mine:
                    want |= sm
            miss = sorted(want - have)
            if not miss:
                continue
            print('%s: add cc900-module: %s' % (rel, ' '.join(miss)))
            if dry:
                continue
            line = '/* cc900-module: %s */   /* staged module names, repair_module_lines.py */\n' % ' '.join(miss)
            # after the header comment: before the first line that is not inside the leading /* ... */
            end = text.find('*/') + 2 if text.startswith('/*') else 0
            nl = text.find('\n', end) + 1 if end else 0
            text = text[:nl] + line + text[nl:]
            open(path, 'w', encoding='latin-1', newline='').write(text)


if __name__ == '__main__':
    main()
