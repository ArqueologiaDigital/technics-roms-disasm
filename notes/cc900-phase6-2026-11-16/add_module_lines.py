#!/usr/bin/env python3
"""Give each v10 staging file the `cc900-module:` line its functions need.

QUESTION ANSWERED / WHY: a staged function that reaches a same-module callee with calr / jr / jrl in the ROM only
compiles to those bytes when its C file names the callee in a `cc900-module:` comment (lane_vmb's call relaxation:
membership comes only from that comment).  scripts/analysis/cc900/module_calls.py reads the ROM's own encodings for
a file's functions; this runs it on every v10/maincpu/cc900-staged/*.c and writes its line into the file, replacing
an older one (no line when the file's functions make no relative call).  port_staged.py then carries it to the other
trees with the file's text.

usage: python3 -B notes/cc900-phase6-2026-11-16/add_module_lines.py      (from the repository root; needs `make`'s ELF)
"""
import os, re, subprocess, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
SDIR = os.path.join(REPO, 'v10', 'maincpu', 'cc900-staged')
LINE_RE = re.compile(r'^/\* cc900-module:[^\n]*\*/[^\n]*\n', re.M)


def main():
    for fn in sorted(os.listdir(SDIR)):
        if not fn.endswith('.c'):
            continue
        p = os.path.join(SDIR, fn)
        r = subprocess.run([sys.executable, '-B', os.path.join(REPO, 'scripts', 'analysis', 'cc900', 'module_calls.py'),
                            'v10', os.path.relpath(p, REPO)], capture_output=True, text=True, cwd=REPO)
        m = re.search(r'^/\* cc900-module: [^\n]*\*/$', r.stdout, re.M)
        text = open(p, encoding='latin-1').read()
        new = LINE_RE.sub('', text)
        if m:
            i = new.index('*/\n') + 3
            new = new[:i] + m.group(0) + '   /* scripts/analysis/cc900/module_calls.py v10 */\n' + new[i:]
        if new != text:
            open(p, 'w', encoding='latin-1').write(new)
            print('%s: %s' % (fn, m.group(0) if m else 'module line removed'))


if __name__ == '__main__':
    main()
