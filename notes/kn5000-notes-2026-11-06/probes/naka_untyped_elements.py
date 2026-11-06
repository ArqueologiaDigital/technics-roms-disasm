#!/usr/bin/env python3
"""naka_untyped_elements.py -- which registered NAKA Viewable elements still have no typed record?

QUESTION ANSWERED
  Register item N-2f640c1d counts the Viewable elements (every element of every Viewable table the class
  registry names, read from the v10 ROM by nakarest_objtab_map) that have neither a naka_cls_<Class>_t member in
  the C sources (naka_gui_model.Graph.rec) nor a NAKA_REC_<Class> macro call at their assembly label.  This lists
  them, by where they live: inside a NAKA C blob, in the asm, or in DRAM (WorkRamInit_Image's work-RAM view).
RUN (repository root, built v10 tree)
  python3 notes/kn5000-notes-2026-11-06/probes/naka_untyped_elements.py [--list]
"""
import collections, glob, os, re, sys
ROOT = os.getcwd()
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'analysis'))
import naka_gui_model as G  # noqa: E402

g = G.Graph('v10')
m = g.m
asm_rec = set()
for p in glob.glob('v10/maincpu/**/*.s', recursive=True):
    t = open(p, 'rb').read().decode('latin-1')
    # the macro call may follow its label after comment or blank lines (lane kn5000-naka, 2026-11-06:
    # the older pattern allowed one line break only, and counted 8 such records as untyped)
    for mm in re.finditer(r'^([A-Za-z_]\w*):[ \t]*\n?(?:[ \t]*(?:;[^\n]*)?\n)*[ \t]*NAKA_REC_\w+', t, re.M):
        asm_rec.add(mm.group(1))
blobs = []
for p in G.tree_files('v10'):
    t = G.read(p)
    mb = re.search(r'^#define BASE\s+0x([0-9A-Fa-f]+)u', t, re.M)
    sz = re.search(r'_Static_assert\(sizeof\(\w+\) == (\d+)', t)
    if mb and sz:
        blobs.append((int(mb.group(1), 16), int(sz.group(1)), os.path.basename(p)))
where = collections.Counter()
rows = []
for key, (addr, links) in sorted(g.rom.items()):
    if key in g.rec:
        continue
    lab = m.name_of(addr)
    name = lab[1] if lab and lab[0] == addr else None
    if name in asm_rec:
        continue
    c = m.record_class(addr)
    b = [x for x in blobs if x[0] <= addr < x[0] + x[1]]
    w = ('C blob ' + b[0][2]) if b else ('DRAM' if not m.inrom(addr) or addr < 0xE00000 else 'asm')
    where[w.split(' ')[0] + (' blob' if b else '')] += 1
    rows.append((w, hex(key[0]), key[1], c['name'] if c else '?', name or '0x%06X' % addr))
print('untyped Viewable elements (v10): %d' % len(rows))
for k, v in sorted(where.items()):
    print('  %-8s %d' % (k, v))
if '--list' in sys.argv:
    for r in rows:
        print('  %-36s slot %-6s elem %-4d %-18s %s' % r)
