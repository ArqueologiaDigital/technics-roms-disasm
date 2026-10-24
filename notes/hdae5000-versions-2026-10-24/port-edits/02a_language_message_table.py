"""The language-message switch of HDAE5000_AcLanguageText1Proc: 77 entries in v2.01i.

Run once, before 02_key_switch_table.py, on the byte-exact-but-for-this tree.  The case
names it wrote were the ones the porting tool had left at each address; 05_relabel_language_cases.py
corrects them afterwards.
"""
import os, sys, struct
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'tools'))
import port_hdae5000_version as P
T = P.tree_of('v2_01i') + '/'
bld = P.do_build('v2_01i')
assert bld.ok
B = P.ref_image('v2_01i')
by = {}
for a, n in bld.syms:
    if not n.startswith('__PM_'):
        by.setdefault(a, []).append(n)


def lab(a, prefer):
    ns = by.get(a, [])
    for p in prefer:
        for n in ns:
            if n.startswith(p):
                return n
    assert ns, hex(a)
    return ns[0]


L = open(T + 'hdae5000_data_tables.s', 'rb').read().split(b'\n')
base = bld.symaddr['HDAE5000_AcLanguageText1Proc_Msg001']
tab = bld.symaddr['HDAE5000_LangText_CaseTable']
a0 = next(i for i, l in enumerate(L) if l.startswith(b'; HDAE5000_LangText_CaseTable (0x2E5AE0'))
a1 = next(i for i, l in enumerate(L) if l.startswith(b'HDAE5000_LangText_CaseTable:'))
e1 = a1 + 1
while L[e1].lstrip().startswith(b'.short\tHDAE5000_AcLanguageText1Proc_'):
    e1 += 1
assert e1 - a1 - 1 == 80
rows = []
for i in range(77):
    off = struct.unpack_from('<h', B, tab - 0x280000 + 2 * i)[0]
    msg = i + 1 if i <= 0x3f else i + 0x88
    n = lab(base + off, ['HDAE5000_AcLanguageText1Proc_Msg', 'HDAE5000_AcLanguageText1Proc_NoMessage'])
    rows.append(b'\t.short\t%s - HDAE5000_AcLanguageText1Proc_Msg001\t; message %d' % (n.encode(), msg))
hdr = [b'; HDAE5000_LangText_CaseTable (77 x u16): the message switch of',
       b'; HDAE5000_AcLanguageText1Proc.  Entry i serves message i+1 (i <= 0x3f) or',
       b'; i+0x88 (0x40 <= i <= 0x4c, the `sub wa,0x87` range); each value is an offset',
       b'; from HDAE5000_AcLanguageText1Proc_Msg001, the first case, and the reader',
       b'; jumps there (`jp T,XIX+WA`).  Messages 63, 204 and 205, and every number',
       b'; out of range, share the _NoMessage case.  v2.01i has no messages 65-67',
       b'; (v2.06i\'s table has 80 entries: 1-67 and 200-212).',
       b';']
L[a0:e1] = hdr + [b'HDAE5000_LangText_CaseTable:'] + rows
open(T + 'hdae5000_data_tables.s', 'wb').write(b'\n'.join(L))
