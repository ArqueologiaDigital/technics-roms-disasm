#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# (Written by the reader of range 0x48400000 in lane open14/kn7000-subsystems; the source of the
# "same code as IC18 <name> (normalized-instruction match R)" evidence of the FdcPrg* / FdcStrap3* rows
# of kn7000_manual.sym.  It ran on the sources of 92b5cc4a7, where those routines were still func_<ADDR>;
# on a later tree it reports only the routines still func_<ADDR>; check out 92b5cc4a7 to reproduce.)
# Align program-941 routines in a range with IC18 boot-ROM routines by normalized
# instruction sequence (difflib ratio).  Question: which IC18 Fdc*/other routine is
# each func_ in 0x48400000-0x48404D10 the same code as?
# usage: python3 -I match_ic18.py LO HI   (cwd = worktree root)
import re, sys, difflib
def parse(paths):
    rs = {}; order = []; cur = None
    for p in paths:
        for raw in open(p, 'rb').read().decode('latin-1').splitlines():
            if not raw or raw.startswith('#'): continue
            m = re.match(r'^([A-Za-z_][A-Za-z0-9_]*):', raw)
            if m:
                n = m.group(1)
                if n.startswith('loc_') or n.endswith('_entry') or n.startswith('.'):
                    continue
                cur = n; rs[cur] = []; order.append(cur); continue
            if cur and raw.startswith((' ', '\t')):
                rs[cur].append(raw.strip())
    return rs, order
def norm(ins):
    ins = re.sub(r'\b(loc|func)_[0-9A-Fa-f]+\w*', 'L', ins)
    ins = re.sub(r'\b[A-Z][A-Za-z0-9_]*\b', 'S', ins)
    ins = re.sub(r'0x[0-9a-fA-F]{5,}', 'S', ins); ins = re.sub(r'L\+\d+|L\+0x[0-9a-f]+', 'S', ins); ins = ins.replace('(L)', '(S)')
    return ins
def toks(b): return [norm(i) for i in b if not i.startswith('.')]
lo, hi = int(sys.argv[1], 16), int(sys.argv[2], 16)
P, po = parse(['kn7000/src/program/region1_00.s'])
I, io = parse(['kn7000/src/ic18/boot.s'])
it = {n: toks(b) for n, b in I.items() if len(b) > 0}
for n in po:
    m = re.match(r'func_([0-9A-F]{8})$', n)
    a = int(m.group(1), 16) if m else None
    if a is None or not (lo <= a < hi): continue
    t = toks(P[n])
    best = []
    for k, v in it.items():
        if abs(len(v) - len(t)) > max(6, len(t)//2): continue
        r = difflib.SequenceMatcher(None, t, v, autojunk=False).ratio()
        best.append((r, k, len(v)))
    best.sort(reverse=True)
    print(n, len(t), ' '.join('%s(%d)=%.2f' % (k, l, r) for r, k, l in best[:3]))
