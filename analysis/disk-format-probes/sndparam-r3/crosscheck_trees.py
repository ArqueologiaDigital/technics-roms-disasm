#!/usr/bin/env python3
"""crosscheck_trees.py -- do the keys proposed in proposals.json/inferred.json have the same descriptor shape
(record, byte, mask, clamp range) and the same alias in v9 and v7 as in v10?  Prints mismatches, then a summary."""
import json, os, subprocess
REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
NM = os.path.expanduser('~/compartilhado/llvm-project/build/bin/llvm-nm')
def descs(tree):
    rom = open(os.path.join(REPO, 'original_ROMs/kn5000_%s_program.rom' % tree), 'rb').read()
    out = subprocess.run([NM, '--defined-only', os.path.join(REPO, 'rebuilt_ROMs/kn5000_%s_program.llvm.elf' % tree)],
                         capture_output=True, text=True, check=True).stdout
    syms, byaddr = {}, {}
    for l in out.splitlines():
        f = l.split()
        if len(f) == 3:
            syms[f[2]] = int(f[0], 16); byaddr.setdefault(int(f[0], 16), []).append(f[2])
    reg = syms.get('SndParam_RegisterLoop_Data', syms.get('SndParam_Registry')) - 0xE00000
    D = {}
    for i in range(972):
        p = int.from_bytes(rom[reg + 4*i:reg + 4*i + 4], 'little')
        b = rom[p - 0xE00000:p - 0xE00000 + 18]
        names = sorted(n for n in byaddr.get(p, []) if n.split('_')[0] in ('ExtPartParam', 'SeqMixParam', 'MidiChParam',
                                                                             'VoiceCtrlR1', 'PartParam', 'VoiceParamEx'))
        D[int.from_bytes(b[0:4], 'little')] = (b[4], b[5], b[6], b[7], b[8], names[0] if names else None)
    return D
T = {t: descs(t) for t in ('v10', 'v9', 'v7')}
keys = []
for fn in ('proposals.json', 'inferred.json'):
    for e in json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), fn)))[1:]:
        if e['kind'] == 'part':
            n = int(e['number'], 16)
            for k in T['v10']:
                if (0x8000 <= k <= 0x17FFF and k & 0x3FF == n) or (0x18000 <= k <= 0x27FFF and (k & 0x3FF) + 0x400 == n):
                    keys.append(k)
        else:
            keys.append(int(e['key'], 16))
bad = 0
for k in keys:
    a = T['v10'][k]
    for t in ('v9', 'v7'):
        b = T[t].get(k)
        if b != a:
            bad += 1
            print('MISMATCH %s key 0x%05X v10=%s %s=%s' % (t, k, a, t, b))
print('%d keys checked against v9 and v7: %d mismatches' % (len(keys), bad))
