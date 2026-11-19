#!/usr/bin/env python3
"""Write sub_AQ_37a/b/c.c from sub_AQ_36a.c: one spelling of the block index per form (helper AQ, round 37)."""
import os

D = '/home/fsanches/compartilhado/disasm-lanes/csub/scripts/analysis/cc900/corpus/firmware'
src = open(os.path.join(D, 'sub_AQ_36a.c'), 'rb').read().decode('ascii')

OLD_HEAD = src[src.index('   form a (from 35c)'):src.index('   Voice_Build_Four_Partials (682 B)')]
NEW_HEAD = """   Round 36 (run 2026-11-19-69-sub-r36q), idiff_full.py:
   - 36a (940 B): `(int)ch * 0x47` fixed the multiply (`extz wa; muls wa,0x47`), and ch / i are in QIZH / QIZL.
     The one difference left: V4.23 folds the +10 of `buf[(int)i + 10]` into the frame address (`lda xbc,xsp+12`,
     no add) where the ROM adds 10 to the extended index in WA and keeps the base at `xsp+2`; -4 B per index.
   - 36b (978 B): `(unsigned int)i + 10` is extended to 32 bits and added to the pointer (`extz xwa; add xbc,xwa;
     ld a,(xbc)`), and the registers swapped (ch in QIZL).
   - 36c (940 B): as 36a with ch in QIZL / i in QIZH: declaring ch first is right.
   So the index must be a signed int sum that V4.23 neither narrows to 8 bits (round 35) nor folds into the base.

   form a (from 36a): `buf[+((int)i + 10)]` (a unary plus stopped constant folding in the FP functions, ROUND21 (ac)).
   form b: as 36a, with `buf[(0, (int)i + 10)]` (a comma expression, ROUND18 (w)).
   form c: as 36a, with `buf[(int)(i + 10)]` (cast of the whole sum).

"""
assert src.count(OLD_HEAD) == 1
src = src.replace(OLD_HEAD, NEW_HEAD)
for form, idx in (('a', '+((int)i + 10)'), ('b', '(0, (int)i + 10)'), ('c', '(int)(i + 10)')):
    t = src.replace('sub_AQ_36a.c -- lane_sub helper AQ, round 36, form a',
                    'sub_AQ_37%s.c -- lane_sub helper AQ, round 37, form %s' % (form, form))
    body_at = t.index('void Voice_SetVelocity(')
    head, body = t[:body_at], t[body_at:]
    n = body.count('buf[(int)i + 10]')
    assert n == 7, n
    body = body.replace('buf[(int)i + 10]', 'buf[%s]' % idx)
    out = os.path.join(D, 'sub_AQ_37%s.c' % form)
    open(out, 'wb').write((head + body).encode('ascii'))
    print(out, n)
