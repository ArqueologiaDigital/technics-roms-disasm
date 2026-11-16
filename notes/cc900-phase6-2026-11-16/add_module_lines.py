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

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
SDIR = os.path.join(REPO, 'v10', 'maincpu', 'cc900-staged')
PROBES = os.path.join(REPO, 'scripts', 'analysis', 'cc900', 'corpus', 'firmware')
sys.path.insert(0, HERE)
import stage_probe as sp                                     # noqa: E402
LINE_RE = re.compile(r'^/\* cc900-module:[^\n]*\*/[^\n]*\n', re.M)


def main():
    matched = {}
    for l in open(os.path.join(HERE, 'probe_matches.tsv')):
        c = l.rstrip('\n').split('\t')
        if len(c) == 4 and c[0] != 'function':
            matched.setdefault(c[0], []).extend(x.split('@')[0] for x in c[3].split())
    for fn in sorted(os.listdir(SDIR)):
        if not fn.endswith('.c'):
            continue
        p = os.path.join(SDIR, fn)
        r = subprocess.run([sys.executable, '-B', os.path.join(REPO, 'scripts', 'analysis', 'cc900', 'module_calls.py'),
                            'v10', os.path.relpath(p, REPO)], capture_output=True, text=True, cwd=REPO)
        m = re.search(r'^/\* cc900-module: ([^\n]*)\*/$', r.stdout, re.M)
        text = open(p, encoding='latin-1').read()
        # module_calls.py cannot read old-style definitions (helper C, run 87): add the cc900-module names of the
        # probes these functions matched in (probe_matches.tsv), which their authors wrote by hand where needed
        names = set(m.group(1).split()) if m else set()
        fns = {sp.fn_name(d) for k, d in sp.items(text) if k == 'fn'}
        for stem in sorted({s for f in fns for s in matched.get(f, [])}):
            pp = os.path.join(PROBES, stem + '.c')
            if os.path.exists(pp):
                for mm in re.finditer(r'cc900-module:([^*\n]*)', open(pp, encoding='latin-1').read()):
                    names |= set(re.split(r'[\s,]+', mm.group(1).strip())) - {''}
        m = re.match(r'(.*)', '/* cc900-module: %s */' % ' '.join(sorted(names))) if names else None
        new = LINE_RE.sub('', text)
        if m:
            i = new.index('*/\n') + 3
            new = new[:i] + m.group(0) + '   /* scripts/analysis/cc900/module_calls.py v10 */\n' + new[i:]
        if new != text:
            open(p, 'w', encoding='latin-1').write(new)
            print('%s: %s' % (fn, m.group(0) if m else 'module line removed'))


if __name__ == '__main__':
    main()
