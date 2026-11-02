#!/usr/bin/env python3
"""apply_sed_renames.py -- check a set of label-rename sed files against the source trees, then apply them.

QUESTION IT ANSWERS
    Before a batch of `s/\bOLD\b/NEW/g` rename files is applied: does every OLD occur in the trees (ZERO-HIT
    otherwise), and is any NEW already a word there (COLLISION: two labels would merge)?  A file that only fixes
    comments quoting old names next to labels already renamed will report COLLISION by design; apply those with
    plain `sed -i -f` on the files that quote them instead.

RUN (repository root)
    python3 scripts/renaming/apply_sed_renames.py v10/maincpu v9/maincpu v7/maincpu v6/maincpu v5/maincpu -- A.sed B.sed
    python3 scripts/renaming/apply_sed_renames.py --apply <same arguments>     # only if no problem was reported
    Scans .s .c .h .ld .inc under the roots (generated/ and build/ skipped); applies with `LC_ALL=C sed -i -f`.
    Lane open6/kn5000-d (2026-11-02) applied rename_accomp / rename_subcmd / rename_panel this way.
"""
import re, sys, os, subprocess
args = sys.argv[1:]; do = '--apply' in args; args = [a for a in args if a != '--apply']
i = args.index('--'); roots, seds = args[:i], args[i+1:]
files = []
for r in roots:
    for dp, dn, fn in os.walk(r):
        dn[:] = [d for d in dn if d not in ('.git', 'generated', 'build')]
        files += [os.path.join(dp, f) for f in fn if f.endswith(('.s', '.c', '.h', '.ld', '.inc'))]
data = {f: open(f, 'rb').read() for f in files}
words = {}
for b in data.values():
    for w in set(re.findall(rb'[A-Za-z_][A-Za-z0-9_]*', b)): words[w] = words.get(w, 0) + 1
bad = 0
for s in seds:
    for l in open(s):
        l = l.strip()
        if not l or l.startswith('#'): continue
        m = re.match(r's/\\b(\w+)\\b/(\w+)/g$', l)
        if not m: print('UNPARSED', s, l); bad += 1; continue
        o, n = (x.encode() for x in m.groups())
        if n in words: print('COLLISION', n.decode(), 'already in', words[n], 'files'); bad += 1
        if o not in words: print('ZERO-HIT', o.decode(), '(', s, ')')
print(len(files), 'files;', 'problems:', bad)
if do and not bad:
    hit = [f for f in files]
    for s in seds:
        for k in range(0, len(hit), 400):
            subprocess.run(['sed', '-i', '-f', s] + hit[k:k+400], check=True, env=dict(os.environ, LC_ALL='C'))
    print('applied')
