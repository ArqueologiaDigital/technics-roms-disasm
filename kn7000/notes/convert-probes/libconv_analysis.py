"""Classify LIB_CONVERT entries: named in a symbol file at the same address? Does
their end equal the next symbol-file boundary? Run from kn7000/."""
import re
import sys
sys.path.insert(0, 'tools')
import gen_program_s as G

d = open(G.ROM, 'rb').read()
sym = {BASE + off: nm for off, nm in G.load_syms(d)} if (BASE := G.BASE) else {}
man = G.load_manual_syms()
lo, hi = G.LIB_CPU_BASE, G.LIB_DELTA + G.IMAGE_END
symstarts = {}
for a, nm in list(sym.items()) + list(man):
    if lo <= a < hi and not nm.endswith('_entry'):
        symstarts.setdefault(a, set()).add(nm)
byname = {}
for a, ns in symstarts.items():
    for n in ns:
        byname[n] = a
allstarts = sorted(set(symstarts) | {cs for cs, _ in G.LIB_CONVERT.values()})
not_named, other_name, end_diff, same = [], [], [], []
for nm, (cs, ce) in sorted(G.LIB_CONVERT.items(), key=lambda kv: kv[1][0]):
    nxt = next((a for a in allstarts if a > cs), hi)
    if nm not in byname:
        if cs in symstarts:
            other_name.append((nm, cs, symstarts[cs]))
        else:
            not_named.append((nm, cs))
    elif byname[nm] != cs:
        other_name.append((nm, cs, f'sym file has it at {byname[nm]:#x}'))
    if ce != nxt:
        end_diff.append((nm, cs, ce, nxt))
    else:
        same.append(nm)
print('LIB_CONVERT entries', len(G.LIB_CONVERT))
print('named only in LIB_CONVERT:', len(not_named))
for x in not_named[:20]:
    print('  ', x[0], hex(x[1]))
print('start named differently in a symbol file:', len(other_name))
for x in other_name[:20]:
    print('  ', x)
print('end differs from next boundary:', len(end_diff))
for nm, cs, ce, nxt in end_diff:
    print(f'   {nm} {cs:#x}..{ce:#x}, next boundary {nxt:#x} (+{nxt - ce:#x})')
print('end == next boundary:', len(same))
