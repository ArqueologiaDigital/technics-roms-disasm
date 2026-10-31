#!/usr/bin/env python3
"""Which writer of P[+0x12] / P[+0x14] runs last: the static detune or the GROUP dispatcher?  (N-88076f49)

P is the part element sub-record 0x5D23 + 187*part + 0x13 + 42*e (both writers address it through
(0x00E084)).  Writer 1, Pack104_UnpackWaveSelRec_ToSubRecord, is reached only through
Pack104_LoadElementWaveSelRec and writes P[+0x12] = (p26 << 8) + p27 only when p25 bit 7 is set
(0xFC48F4..0xFC4926), P[+0x14] likewise from p37/p38/p39 (0xFC492C..0xFC495E).  Writer 2,
Pack104_DispatchByResoMode_ForPart, always runs one arm (or one pair of arms) covering all four
elements, and EVERY arm writes both fields: 0 in sub_FC6CA8 / _FC6CEA / _FC6D2C, the solver's
result in sub_FC6D6E / _FC6FFD / _FC723F.

Asserted (exit 0 = PASS):
  * the six arms each store both P[+0x12] and P[+0x14];
  * every routine that calls BOTH writers calls the dispatcher AFTER every one of its
    Pack104_LoadElementWaveSelRec calls (7 routines);
  * the routines that call the loader and never the dispatcher are exactly LOADER_ONLY.
Run: python3 notes/open4-a-probes/detune_writer_order.py
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import prom_c_callgraph as g

LOADER_ONLY = {   # routine -> what it is
    'VoiceParams_Compute_C': 'drum-kit note-on (part mode 0x80), 4 sites',
    'VoiceParams_Compute_D': 'drawbar note tail, MidiNote_OnTail / _OffTail, 2 sites',
    'sub_FB289A': 'orphan twin of Compute_C (no caller)',
    'sub_FB2F74': 'orphan twin of Compute_D (no caller)',
    'sub_FAFBEC': 'controller 94 (MidiCtrl_Dispatch 0xFAFF4C) and sub_FBB793: reloads the 4 elements of a MELODIC part',
    'ToneDB_DrumSourceNameList_SelectEntry': 'tone edit, drum source',
    'ToneDB_PercSourceNameList1_SelectEntry': 'tone edit, percussion source 1',
    'ToneDB_PercSourceNameList2_SelectEntry': 'tone edit, percussion source 2',
    'sub_FB9414': 'tone edit, drum instrument index (0x00D735)',
    'sub_FBCBA7': 'ToneMsg write arm, percussion instrument',
    'sub_FBD0A2': 'ToneMsg write arm, percussion wave-select from the catalogue',
    'sub_FBD46B': 'ToneMsg write arm, drum instrument record',
    'sub_FBD6FC': 'ToneMsg write arm, percussion wave-select tail preset',
}
ADDR = re.compile(rb';\s*([0-9A-F]{6})\b')
seq, body, cur = {}, {}, None
for raw, code in g.lines():
    m = g.LABEL.match(code)
    if m and not g.is_local(m.group(1)):
        cur = m.group(1).decode()
    c = (code[m.end():] if m else code).strip()
    body.setdefault(cur, []).append(c.decode('latin1'))
    for t, k in ((b'Pack104_LoadElementWaveSelRec', 'L'), (b'Pack104_DispatchByResoMode_ForPart', 'D')):
        if re.match(rb'(call|calr)\s+' + t + rb'\b', c):
            seq.setdefault(cur, []).append((k, int(ADDR.search(raw).group(1), 16)))
fail = 0
for arm in ('sub_FC6CA8', 'sub_FC6CEA', 'sub_FC6D2C', 'sub_FC6D6E', 'sub_FC6FFD', 'sub_FC723F'):
    txt = '\n'.join(body[arm])
    ok = bool(re.search(r'ldw?\t\(x\w\w\+18\), (0x0000|\w\w)\b', txt)) and bool(re.search(r'ldw?\t\(x\w\w\+20\), (0x0000|\w\w)\b', txt))
    fail += not ok
    print('%-12s writes P[+0x12] and P[+0x14]: %s' % (arm, ok))
both = {r: s for r, s in seq.items() if {'L', 'D'} <= {k for k, _ in s}}
for r, s in sorted(both.items()):
    lastL = max(a for k, a in s if k == 'L')
    lastD = max(a for k, a in s if k == 'D')
    ok = all(any(k2 == 'D' and a2 > a for k2, a2 in s) for k, a in s if k == 'L')
    fail += not ok
    print('both  %-46s last loader 0x%06X, last dispatcher 0x%06X  %s' % (r, lastL, lastD, 'dispatcher last' if ok else 'FAIL'))
lonly = {r for r, s in seq.items() if {k for k, _ in s} == {'L'}}
for r in sorted(lonly):
    print('loader-only  %-40s %s' % (r, LOADER_ONLY.get(r, 'FAIL: unexpected')))
if lonly != set(LOADER_ONLY) or len(both) != 7:
    fail += 1
    print('FAIL: loader-only set or both-count moved', sorted(lonly ^ set(LOADER_ONLY)), len(both))
print('FAILURES:', fail)
sys.exit(1 if fail else 0)
