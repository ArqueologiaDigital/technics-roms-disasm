#!/usr/bin/env python3
"""widget_keys.py -- every naka widget instance field (pman_adr / pman_ad / lsw / key-like) in the HEAD snapshot's
ui_widgets/*.c, with the instance name, its caption/strings, and whether the value is one of the unnamed keys."""
import os, glob, re
SNAP = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'snap') + '/'
unnamed = set()
for l in open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'sndparam_unnamed_v10.txt')):
    if l.startswith('0x'):
        unnamed.add(int(l.split()[0], 16))
for p in sorted(glob.glob(SNAP + 'v10/maincpu/ui_widgets/*.c')):
    L = open(p, 'rb').read().decode('latin-1').split('\n')
    inst = None; start = 0
    for i, l in enumerate(L):
        m = re.match(r'\s{4}\.(\w+) = \{', l)
        if m:
            inst = m.group(1); start = i
        m = re.match(r'\s+\.(pman_adr|pman_ad|pman|lswadr|lsw_adr|address|key|param)\s*=\s*(0x[0-9A-Fa-f]+)', l)
        if m:
            v = int(m.group(2), 16)
            tag = 'UNNAMED' if v in unnamed else ''
            print('%-8s %-9s 0x%05X  %-45s %s:%d' % (tag, m.group(1), v, inst, p.replace(SNAP, ''), i + 1))
