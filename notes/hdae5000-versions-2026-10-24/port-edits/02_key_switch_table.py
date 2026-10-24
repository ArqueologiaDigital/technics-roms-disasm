"""HDAE5000_FDFileSelectProc's key switch: one 16-entry u16 table in v2.01i (v2.06i: a
byte map into a 4-entry table); the new case for keys 1 / 0x81 is .Lsc_07_btn_k1.

A record of a one-off hand edit of hdae5000_v2_01i/ (see README.md here); it matches
exact text of the tree as it was then and will not apply again.
"""
import os
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
import sys, struct, re
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'tools'))
import port_hdae5000_version as P
T = os.path.join(ROOT, 'hdae5000_v2_01i') + '/'
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


def load(f):
    return open(T + f, 'rb').read().split(b'\n')


def save(f, L):
    open(T + f, 'wb').write(b'\n'.join(L))


# ---- 2. FDFileSelectProc's key switch: one 16-entry u16 table in v2.01i
L = load('hdae5000_data_tables.s')
k0 = next(i for i, l in enumerate(L) if l.startswith(b'; HDAE5000_FDFileSelectProc_KeyCaseMap (0x2E5D38'))
k0 -= 1                                   # the ';' line above
k1 = next(i for i, l in enumerate(L) if l.startswith(b'HDAE5000_FDFileSelectProc_KeyCaseTable:'))
k1 += 4                                   # its 4 .short rows
assert L[k1].lstrip().startswith(b'.short\t.Lsc_07_btn_down - .Lsc_07_btn_down'), L[k1]
kbase = bld.symaddr['HDAE5000_FDFileSelectProc_Skip3']
ktab = 0x2e5226     # v2.01i address of the table (status hunk: B side)
names = {}
rows = []
for k in range(16):
    off = struct.unpack_from('<h', B, ktab - 0x280000 + 2 * k)[0]
    n = '.Lsc_07_btn_k1' if off == 0 else lab(kbase + off, ['.Lsc_'])
    code = k if k < 8 else 0x80 + k - 8
    rows.append(b'\t.short\t%s - .Lsc_07_btn_k1\t; key code 0x%02x' % (n.encode(), code))
hdr = [b';',
       b'; HDAE5000_FDFileSelectProc_KeyCaseTable (16 x u16): the switch of',
       b'; HDAE5000_FDFileSelectProc\'s event 0x01C00007.  A key code k = 0..7, or',
       b'; 0x80..0x87 folded to 8..15 by `sub xwa,0x78`, doubled, indexes this table',
       b'; (`add xwa,<table>`, `ld wa,(xwa)`), whose entries are offsets from',
       b'; .Lsc_07_btn_k1 (`lda xix,(.Lsc_07_btn_k1)`, `jp T,XIX+WA`).  v2.06i folds',
       b'; the keys through a byte map into 4 cases first; v2.01i indexes directly, and',
       b'; differs in two keys: 1 / 0x81 have their own case (.Lsc_07_btn_k1, where',
       b'; v2.06i returns 0) and 7 / 0x87 return 0 (where v2.06i takes the enter case).',
       b';',
       b'HDAE5000_FDFileSelectProc_KeyCaseTable:']
L[k0:k1 + 1] = hdr + rows
save('hdae5000_data_tables.s', L)

L = load('hdae5000_ui_display.s')
s = b'\n'.join(L)
old = (b'\tjr\tule, HDAE5000_FDFileSelectProc_Skip4\n')
assert s.count(old) == 1
s = s.replace(old, b'\tjr\tule, .Lsc_07_inrange\n')
old = (b'HDAE5000_FDFileSelectProc_Skip4:\n\tadd\txwa, xwa\n\n.Lsc_07_inrange:\n'
       b'\tadd xwa, HDAE5000_FDFileSelectProc_KeyCaseMap\t\t; byte lookup table\n')
assert s.count(old) == 1, 'inrange'
s = s.replace(old, b'.Lsc_07_inrange:\n\tadd\txwa, xwa\t\t\t; word index\n'
                   b'\tadd\txwa, HDAE5000_FDFileSelectProc_KeyCaseTable\n')
old = b'\tlda xix, (HDAE5000_FDFileSelectProc_Skip3:24); base = .Lsc_07_btn_down\n\tjp\tt, (xix+wa)\nHDAE5000_FDFileSelectProc_Skip3:\n'
assert s.count(old) == 1, 'skip3'
s = s.replace(old, b'\tlda\txix, (.Lsc_07_btn_k1:24)\n\tjp\tt, (xix+wa)\n\n'
                   b'\t; --- keys 1 / 0x81 (v2.01i only): events 0x01EA000E and 0x01CA000C,\n'
                   b'\t; then EVT_PARA_DRAW, to this object ---\n'
                   b'.Lsc_07_btn_k1:\n')
open(T + 'hdae5000_ui_display.s', 'wb').write(s)
print('ok')
