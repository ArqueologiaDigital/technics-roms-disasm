#!/usr/bin/env python3
"""flag_byte_uses.py -- how many numeric memory operands still spell the flag bytes of register item N-51b2e19c?

QUESTION ANSWERED
  notes/ram-naming-2026-10-24/README.md (Follow-ups 1) lists the flag bytes with the most numeric uses.  For each
  address this counts, per tree, the memory operands `(0xADDR)` / `(0xADDR:16)` / `(0xADDR:24)` / the decimal
  form that still spell it as a number, and the operands that spell it by a name (any RAM .equ of that value,
  read from the tree's shared/ram_variables*.s).  Run before and after a naming pass.
RUN (repository root)
  python3 notes/kn5000-notes-2026-11-06/probes/flag_byte_uses.py [--tree v10]
"""
import glob, re, sys
ADDRS = [0xC1FE, 0xC594, 0xC596, 0xC598, 0xC59C, 0x28B2, 0x28B3, 0x32F4, 0x332C, 0x3283, 0x34CD, 0x35B0,
         0x3312, 0x3313, 0x3314, 0x3315, 0x3316, 0x3317, 0x3318, 0xE3E2]
tree = sys.argv[sys.argv.index('--tree') + 1] if '--tree' in sys.argv else 'v10'
names = {}
for p in glob.glob('%s/maincpu/shared/ram_variables*.s' % tree):
    for m in re.finditer(r'\.equ\s+(\w+),\s*(0x[0-9a-fA-F]+)', open(p, 'rb').read().decode('latin-1')):
        names.setdefault(int(m.group(2), 16), []).append(m.group(1))
text = [open(p, 'rb').read().decode('latin-1') for p in glob.glob('%s/maincpu/**/*.s' % tree, recursive=True)
        if '/shared/ram_variables' not in p]
code = [re.sub(r';[^\n]*', '', t) for t in text]
tn, tm = 0, 0
print('| address | name                     | numeric | named |')
print('|---------|--------------------------|---------|-------|')
for a in ADDRS:
    num = sum(len(re.findall(r'\((?:0x0*%x|%d)(?::8|:16|:24)?\)' % (a, a), c, re.I)) for c in code)
    nm = names.get(a, [])
    nmd = sum(len(re.findall(r'\((?:%s)(?::8|:16|:24)?\)' % '|'.join(nm), c)) for c in code) if nm else 0
    tn += num; tm += nmd
    print('| 0x%04x  | %-24s | %7d | %5d |' % (a, (nm[0] if nm else '-'), num, nmd))
print('| total   | %-24s | %7d | %5d |' % ('', tn, tm))
