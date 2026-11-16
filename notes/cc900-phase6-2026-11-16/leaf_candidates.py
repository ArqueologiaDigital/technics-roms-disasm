#!/usr/bin/env python3
"""Small leaf routines of a KN5000 tree: a label whose body (to the next label) is at most N instructions, ends in
ret, has no call / jump / branch, is not entered by fall-through (the line before is ret / jp / jr / jrl / retd /
reti), and is the target of a call / calr somewhere.  usage: leaf_candidates.py TREE [N]"""
import os, re, sys, collections
tree = sys.argv[1]; N = int(sys.argv[2]) if len(sys.argv) > 2 else 6
LAB = re.compile(r'^([A-Za-z_.$][\w.$]*):(.*)$')
files = {}
for dp, dn, fn in os.walk(tree):
    dn[:] = [d for d in dn if d != 'generated']
    for f in fn:
        if f.endswith('.s'):
            files[os.path.join(dp, f)] = open(os.path.join(dp, f), encoding='latin-1').read().split('\n')
called = collections.Counter()
for p, L in files.items():
    for l in L:
        c = l.split(';')[0].strip()
        m = re.match(r'^(?:call|calr)\s+(?:\w+\s*,\s*)?([A-Za-z_][\w]*)\s*$', c)
        if m: called[m.group(1)] += 1
def code(l):
    return l.split(';')[0].strip()
out = []
for p, L in files.items():
    prev_ins = None
    i = 0
    while i < len(L):
        c = code(L[i]); m = LAB.match(c)
        if m and not m.group(1).startswith('.'):
            name = m.group(1); body = []
            rest = m.group(2).strip()
            if rest: body.append(rest)
            j = i + 1
            while j < len(L):
                cj = code(L[j])
                if LAB.match(cj): break
                if cj: body.append(cj)
                j += 1
            ok = (body and body[-1].split()[0] == 'ret' and len(body) <= N and
                  not any(b.split()[0] in ('call', 'calr', 'jp', 'jr', 'jrl', 'djnz', 'retd', 'reti') or b.startswith('.')
                          for b in body[:-1]) and
                  prev_ins is not None and prev_ins.split()[0] in ('ret', 'jp', 'jr', 'jrl', 'retd', 'reti') and
                  called[name] > 0 and not body[-1].split()[1:])
            if ok: out.append((len(body), name, p, ' / '.join(body), called[name]))
        if c and not LAB.match(c): prev_ins = c
        elif c and LAB.match(c) and LAB.match(c).group(2).strip(): prev_ins = LAB.match(c).group(2).strip()
        i += 1
for n, name, p, b, k in sorted(out):
    print('%d\t%-40s %-40s calls %3d  %s' % (n, name, os.path.relpath(p, tree), k, b))
print(len(out), 'candidates', file=sys.stderr)
