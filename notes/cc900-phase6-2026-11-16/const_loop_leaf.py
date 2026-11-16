#!/usr/bin/env python3
"""Leaf routines (no call) with a loop and a 32-bit constant load of 8..0xffff (ld xR, N or lda xR, (N:8|16))."""
import os, re, sys, collections
sys.path.insert(0, 'notes/cc900-phase6-2026-11-16')
import loop_shapes as L
tree = sys.argv[1]
called = set()
files = {}
for dp, dn, fn in os.walk(tree):
    dn[:] = [d for d in dn if d != 'generated']
    for f in fn:
        if f.endswith('.s'):
            p = os.path.join(dp, f); files[p] = L.items(p)
            for _, _, ins in files[p]:
                m = re.match(r'^(call|calr)\s+([A-Za-z_]\w*)$', ins)
                if m: called.add(m.group(2).lower())
CONST = re.compile(r'^ld x(wa|bc|de|hl|ix|iy|iz), (0x[0-9a-f]+|\d+)$')
LDA = re.compile(r'^lda x(wa|bc|de|hl|ix|iy|iz), \((0x[0-9a-f]+|\d+):(8|16)\)$')
for p, it in files.items():
    starts = [k for k, (_, labs, _) in enumerate(it) if any(l.lower() in called for l in labs)
              and (k == 0 or it[k-1][2].split()[0] in ('ret', 'jp', 'jr', 'jrl', 'retd', 'reti'))]
    for a, b in zip(starts, starts[1:] + [len(it)]):
        body = it[a:b]
        if len(body) > 40 or any(x[2].split()[0] in ('call', 'calr', 'calln') for x in body): continue
        if not any(x[2].split()[0] == 'ret' for x in body): continue
        at = {l.lower(): k for k, (_, labs, _) in enumerate(body) for l in labs}
        loop = any((m := L.COND.match(x[2])) and m.group(2) != 't' and m.group(3).lower() in at and at[m.group(3).lower()] <= k
                   or ((d := L.DJNZ.match(x[2])) and d.group(1).lower() in at) for k, x in enumerate(body))
        consts = [x[2] for x in body if (m := CONST.match(x[2])) and 8 <= int(m.group(2), 0) <= 0xffff]
        ldas = [x[2] for x in body if LDA.match(x[2])]
        if loop and (consts or ldas):
            print('%3d  %-40s %s:%d  %s' % (len(body), body[0][1][0], os.path.relpath(p, tree), body[0][0], ' | '.join(consts + ldas)))
