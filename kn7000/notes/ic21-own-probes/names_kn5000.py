# names_kn5000.py -- every name in the CUSTOM area of Felipe's KN7000 IC21: which are KN5000 program
# names (v10), KN7000 firmware/table names (program 893, table 80), names in the nine factory KN7000
# custom sets, and which are none of those.  Adapted 2026-10-31 from the private ic21-analysis/names_kn5000.py.
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _paths
d = _paths.chip()[0x20000:0xF8F17]
k5 = _paths.rd(_paths.KN5000_V10)
k7 = _paths.table80() + _paths.program('893')
sets = b''.join(_paths.factory_sets().values())
# names are space-padded fixed fields (16 chars for presets, 13 for style names): split runs of text on 2+ spaces
fields = re.findall(rb'[ -~]{5,}', d)
names = sorted({w.strip() for f in fields for w in re.split(rb'  +|(?<=.{16})', f) if len(w.strip()) >= 4 and re.search(rb'[A-Za-z]{3}', w)})
cat = {'KN5000 program': [], 'KN7000 firmware/table only': [], 'known KN7000 sets only': [], 'none of these': []}
for w in names:
    if w in k5: cat['KN5000 program'].append(w)
    elif w in k7: cat['KN7000 firmware/table only'].append(w)
    elif w in sets: cat['known KN7000 sets only'].append(w)
    else: cat['none of these'].append(w)
for k, v in cat.items(): print(f'{k}: {len(v)}')
print('none of these:', [w.decode() for w in cat['none of these']])
print('KN7000 firmware/table only:', [w.decode() for w in cat['KN7000 firmware/table only']])
print('KN5000 program:', [w.decode() for w in cat['KN5000 program']])
