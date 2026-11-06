#!/usr/bin/env python3
"""menu_map_summary.py -- the figures of the website's KN5000 Menu Map summary, from the same model
scripts/generators/gen_naka_menu_map.py writes docs/gui/kn5000-menu-map.md with.

QUESTION ANSWERED
  "What should the summary tables of technics-docs kn5000-menu-map.md say now?"  Prints, as aligned
  Markdown: the counts table (titles, titles with a path, depth below a home title, widget records,
  menu entries, code transitions, EXIT links), the per-mode "titles below" column, and the titles with no
  path, split into those opened by code that no traced path reaches (with the routines) and the rest.
RUN (repository root, built v10 tree: rebuilt_ROMs/kn5000_v10_program.llvm.elf)
  python3 notes/kn5000-naka-2026-11-06/probes/menu_map_summary.py
"""
import collections
import os
import sys

ROOT = os.getcwd()
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'analysis'))
import naka_gui_model as G  # noqa: E402


def table(rows, head):
    w = [max(len(str(r[i])) for r in rows + [head]) for i in range(len(head))]
    f = lambda r: '| ' + ' | '.join(str(c).ljust(w[i]) for i, c in enumerate(r)) + ' |'
    return [f(head), '|' + '|'.join('-' * (x + 2) for x in w) + '|'] + [f(r) for r in rows]


g = G.Graph('v10')
G.add_code_edges(g)
paths = g.menu_paths()
depth = collections.Counter(len(p) - 1 for p in paths.values())
below = collections.Counter()
for t, p in paths.items():
    below[p[0][1]] += 1 if len(p) > 1 else 0
rows = [('titles', len(g.titles)), ('titles with a path', len(paths)), ('modes (each with a home title)', len(g.modes))]
for d in sorted(k for k in depth if k > 0):
    rows.append(('titles %s below a home' % {1: 'one step', 2: 'two steps', 3: 'three steps'}.get(d, '%d steps' % d),
                 depth[d]))
rows += [('widget records, in %d C files' % len(g.files), '{:,}'.format(len(g.rec))),
         ('menu entries', sum(1 for e in g.edges if e[3] == 'menu')),
         ('code transitions', len(g.code_edges)), ('EXIT links', sum(1 for e in g.edges if e[3] == 'exit'))]
print('\n'.join(table(rows, ('what', 'count'))))
print()
print('\n'.join(table([('`%s`' % m['name'], below[m['name']]) for _, m in sorted(g.modes.items())],
                      ('mode', 'titles below'))))
print()
opener = collections.defaultdict(set)
for r, ns in g.routine_opens.items():
    for n in ns:
        if r:
            opener[n].add(r)
by_code, none = [], []
for tid in sorted(g.titles):
    if tid in paths:
        continue
    n = g.title_name(tid)
    o = sorted(opener.get('TT_' + n[6:], ())) if n.startswith('TITLE_') else []
    (by_code if o else none).append((n, o))
print('titles with no path: %d (%d opened by code no traced path reaches, %d by nothing found)'
      % (len(by_code) + len(none), len(by_code), len(none)))
print('\n'.join(table([('`%s`' % n, ', '.join('`%s`' % x for x in o)) for n, o in by_code],
                      ('title', 'opened by code in'))))
print()
print('no opener found: ' + ', '.join('`%s`' % n for n, o in none))
