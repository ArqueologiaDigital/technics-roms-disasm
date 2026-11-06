#!/usr/bin/env python3
"""unreached_openers.py -- how is the code that opens a title with no menu path itself reached?

QUESTION ANSWERED
  docs/gui/kn5000-menu-map.md lists titles with no path whose opener routine is known ("Opened by code
  in").  For each such opener this walks the call graph upwards (scripts/converters/name_title_index_operands.py
  `callees`: call / calr / jp to a routine entry) and prints the nearest callers that are (a) a title's
  function (RegTitle), with or without a path of its own, (b) a function-object entry (menu box / ApFunction),
  or (c) a routine that tests a panel-switch event (`EVT_SW_IN*` operand in its body), with the chain.
RUN (repository root, built v10 tree)
  python3 notes/kn5000-naka2-2026-11-06/probes/unreached_openers.py [--depth 8]
"""
import collections, os, re, sys, glob
ROOT = os.getcwd()
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'analysis'))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'converters'))
import naka_gui_model as G  # noqa: E402
import name_title_index_operands as N  # noqa: E402

depth = int(sys.argv[sys.argv.index('--depth') + 1]) if '--depth' in sys.argv else 8
g = G.Graph('v10')
G.add_code_edges(g)
paths = g.menu_paths()
extra = set()
for r in g.m.regs:
    if r['cls'] in G.FUNC_CLASSES and g.m.inrom(r['table']):
        for a in g.m.entries(r):
            lab = g.m.name_of(a)
            if lab[0] == a:
                extra.add(lab[1])
calls = N.callees('v10', extra)
callers = collections.defaultdict(set)
for a, bs in calls.items():
    for b in bs:
        callers[b].add(a)
func_of = {}
for tid, t in g.titles.items():
    lab = G.func_label(g.m, t['func'])
    if lab:
        func_of.setdefault(lab, []).append(tid)
# routines whose body names a panel-switch event
swin = set()
files = [N.File(p) for p in sorted(glob.glob(os.path.join(ROOT, 'v10', 'maincpu', '**', '*.s'), recursive=True))]
ent = N.routine_entries(files, extra)
for f in files:
    cur = None
    for pos, (i, code) in enumerate(f.ins):
        for lab in f.labels_of.get(pos, []):
            if lab in ent:
                cur = lab
        if cur and re.search(r'\bEVT_SW_IN\w*\b', code):
            swin.add(cur)
opener = collections.defaultdict(set)
for rout, ns in g.routine_opens.items():
    for n in ns:
        if rout:
            opener[n].add(rout)
unreached = []
for tid in sorted(g.titles):
    if tid in paths:
        continue
    n = g.title_name(tid)
    if n.startswith('TITLE_') and opener.get('TT_' + n[6:]):
        unreached.append((n, sorted(opener['TT_' + n[6:]])))
kinds = collections.Counter()
for n, ops in unreached:
    print(n)
    for o in ops:
        seen, q, hits = {o: [o]}, collections.deque([o]), []
        while q:
            x = q.popleft()
            ch = seen[x]
            tag = []
            if x in func_of:
                tag.append('title func of ' + ', '.join('%s%s' % (g.title_name(t), '' if t in paths else ' (no path)') for t in func_of[x]))
            if x in extra and x not in func_of:
                tag.append('function object')
            if x in swin:
                tag.append('tests EVT_SW_IN*')
            if tag and x != o:
                hits.append((len(ch), ' < '.join(ch), '; '.join(tag)))
                continue
            if len(ch) > depth:
                continue
            for c in sorted(callers.get(x, ())):
                if c not in seen:
                    seen[c] = ch + [c]
                    q.append(c)
        if o in swin:
            hits.insert(0, (0, o, 'itself tests EVT_SW_IN*'))
        print('  %s: %d callers%s' % (o, len(callers.get(o, ())), '' if hits else ', no root within depth %d' % depth))
        for h in hits[:4]:
            print('    [%s] %s' % (h[2], h[1]))
        kinds['with root' if hits else 'none'] += 1
print(dict(kinds))
