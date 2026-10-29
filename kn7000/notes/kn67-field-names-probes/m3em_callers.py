#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""List every call of the parameter get/set entry points with a literal id, and the routine it is in.

Question answered: which named routine (GUI proc, FN_ handler, MIDI path) reads or writes a given
parameter id, so that the id's panel-record byte (m3em_param_map.py) can be named after it.
A call counts when one of the 8 preceding lines loads d0 with an immediate (`mov 0x..., d0`);
the id is that immediate's low 24 bits (the top byte is a part / source index).

usage: m3em_callers.py SRC_DIR [ID_HEX ...]     (SRC_DIR = kn7000/src/program)
"""
import pathlib, re, sys
CALLS = ('PutM3Em', 'PutM3EmDelay', 'GetM3EmVal', 'GetM3Em', 'PutM3Sqf', 'GetM3SqfVal', 'GetM3Sqf',
         'GetM3InitVal', 'GetM3Init')
call_re = re.compile(r'^\s+call\s+(%s)(?:_entry)?\b' % '|'.join(CALLS))
mov_re = re.compile(r'^\s+mov\s+(0x[0-9a-fA-F]+|\d+),\s*d0\b')
lab_re = re.compile(r'^([A-Za-z_][\w]*):')

def main():
    want = {int(x, 16) for x in sys.argv[2:]}
    out = []
    for f in sorted(pathlib.Path(sys.argv[1]).glob('*.s')):
        lines = f.read_bytes().decode('latin-1').splitlines()
        func = '?'
        for i, l in enumerate(lines):
            m = lab_re.match(l)
            if m and not m.group(1).startswith('loc_') and not m.group(1).endswith('_entry'):
                func = m.group(1)
            m = call_re.match(l)
            if not m:
                continue
            for j in range(i - 1, max(i - 9, -1), -1):
                mm = mov_re.match(lines[j])
                if mm:
                    v = int(mm.group(1), 0)
                    if not want or (v & 0xffffff) in want:
                        out.append((v & 0xffffff, v >> 24, m.group(1), func, f.name, i + 1))
                    break
                if call_re.match(lines[j]) or lab_re.match(lines[j]):
                    break
    for r in sorted(out):
        print('%06x idx=%02x %-12s %-40s %s:%d' % r)

main()
