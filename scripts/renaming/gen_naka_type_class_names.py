#!/usr/bin/env python3
"""gen_naka_type_class_names.py -- write rename_naka_type_class_names.sed and the NAKA_TYPE_* block of shared/macros.s.

QUESTION IT ANSWERS: which firmware class name belongs to each NAKA_TYPE_<index> constant.  It reads v10's class
table through scripts/analysis/nakarest_objtab_map.py (InitializeRoot, slot 0x160: 109 classes, the same in every
tree), counts the uses in v10/v9/v7/v6/v5 and prints the unused / classless old names.
RUN (repository root, once, before the rename): python3 scripts/renaming/gen_naka_type_class_names.py BLOCK.txt
  then replace the "Widget type bytes" block of each shared/macros.s with BLOCK.txt and run the sed.
"""
import re, sys, os, collections
sys.path.insert(0, 'scripts/analysis')
import nakarest_objtab_map as n
m = n.Map('v10')
cls = {}
for tt in range(0x6d):
    k = m.klass(0x01600000 + tt)
    cls[tt] = k.get('name') if isinstance(k, dict) else k
src = open('v10/maincpu/shared/macros.s', 'rb').read().decode('latin-1')
defs = re.findall(r'^\.equ (NAKA_TYPE_\w+),\s*(0x[0-9a-fA-F]+)', src, re.M)
cnt = collections.Counter()
tok = re.compile(r'\bNAKA_TYPE_\w+')
for t in 'v10 v9 v7 v6 v5'.split():
    for dp, dn, fn in os.walk(t + '/maincpu'):
        for f in fn:
            if f.endswith(('.s', '.c', '.h')) and not (f == 'macros.s' and dp.endswith('shared')):
                cnt.update(tok.findall(open(os.path.join(dp, f), 'rb').read().decode('latin-1')))
rmap = {}
for nm, v in defs:
    v = int(v, 16)
    if v in cls:
        rmap[nm] = 'NAKA_TYPE_' + cls[v]
print('unused:', [nm for nm, v in defs if not cnt[nm]])
print('no class:', [nm for nm, v in defs if int(v, 16) not in cls], [cnt[nm] for nm, v in defs if int(v, 16) not in cls])
print('used but undefined:', [k for k in cnt if k not in dict(defs)])
assert len(set(rmap.values())) == len(rmap)
with open('scripts/renaming/rename_naka_type_class_names.sed', 'w') as f:
    f.write("# NAKA_TYPE_* are the class indices TT of class ids 0x016000TT (InitializeRoot's class table, registry\n"
            "# slot 0x160); they take the firmware's own class names (scripts/analysis/nakarest_objtab_map.py\n"
            "# --classes).  The event-code catalog (notes/event-codes-2026-10-02) found 8 of the 11 invented names\n"
            "# contradicted by the class names (open item N-b6dceb67).\n")
    for o, nn in sorted(rmap.items(), key=lambda x: -len(x[0])):
        f.write("s/\\b%s\\b/%s/g\n" % (o, nn))
keep = [(tt, 'NAKA_TYPE_' + nm) for tt, nm in cls.items()]
keep.sort()
col = (max(len(".equ %s," % nn) for _, nn in keep) // 8 + 1) * 8
lines = ["; NAKA class indices.  A widget record's first word is its class id 0x016000TT (the bytes",
         "; TT, 0x00, 0x60, 0x01 that naka_header emits).  TT is the entry of InitializeRoot's class table",
         "; (registry slot 0x160, read by ClassProc) and each name is that class's own name string, the same",
         "; in v10/v9/v7/v6/v5 (scripts/analysis/nakarest_objtab_map.py --classes): all 109 root classes."]
for v, nn in keep:
    s = ".equ %s," % nn
    lines.append(s + "\t" * ((col - len(s) + 7) // 8) + "0x%02x" % v)
open(sys.argv[1], 'w').write("\n".join(lines) + "\n")
print(len(rmap), len(keep))
