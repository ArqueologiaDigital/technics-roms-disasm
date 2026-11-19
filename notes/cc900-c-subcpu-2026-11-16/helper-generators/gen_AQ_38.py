#!/usr/bin/env python3
"""Write sub_AQ_38a/b/c.c from sub_AQ_36a.c (helper AQ, round 38): one spelling of the request block's channel
index per form.  a: pointer arithmetic; b / c: the block as a struct whose channel array is a member at +10."""
import os

D = '/home/fsanches/compartilhado/disasm-lanes/csub/scripts/analysis/cc900/corpus/firmware'
src = open(os.path.join(D, 'sub_AQ_36a.c'), 'rb').read().decode('ascii')

OLD_HEAD = src[src.index('   form a (from 35c)'):src.index('   Voice_Build_Four_Partials (682 B)')]
NEW_HEAD = """   Round 36 (run 2026-11-19-69-sub-r36q): 36a (940 B) has the multiply right (`(int)ch * 0x47`) and ch / i in
   QIZH / QIZL; what is left is that V4.23 folds the +10 of `buf[(int)i + 10]` into the frame address
   (`lda xbc,xsp+12`, no add), where the ROM extends i, adds 10 in WA and keeps the base at `xsp+2`.
   Round 37 (run 2026-11-19-71-sub-r37q): `buf[+((int)i + 10)]` and `buf[(0, (int)i + 10)]` folded the same way
   (940 B); `buf[(int)(i + 10)]` added in 8 bits again, as round 35 (961 B), and swapped ch / i to QIZL / QIZH.

   form a (from 36a): `*(buf + (int)i + 10)` (pointer arithmetic instead of indexing).
   form b (from 36a): the block is `struct req r;` (the int word at +0 that Voice_Build_Four_Partials stores, then
           the per-partial selector bytes at +2 and flag bytes at +6 that Voice_Build_Partial_Descriptor writes as
           req[tgt + 2] / req[tgt + 6], then the four channels at +10), passed as `&r`, the channel read as
           `r.ch[i]`: the member offset may be added to the index (`extz wa; add wa,10`) with the base at `xsp+2`.
   form c: as b, with `r.ch[(int)i]`.

"""
assert src.count(OLD_HEAD) == 1
src = src.replace(OLD_HEAD, NEW_HEAD)
STRUCT = ('struct req { unsigned int key; unsigned char sel[4]; unsigned char flag[4]; unsigned char ch[4]; };\n'
          'void Voice_Build_Four_Partials(')

for form in 'abc':
    t = src.replace('sub_AQ_36a.c -- lane_sub helper AQ, round 36, form a',
                    'sub_AQ_38%s.c -- lane_sub helper AQ, round 38, form %s' % (form, form))
    body_at = t.index('void Voice_SetVelocity(')
    head, body = t[:body_at], t[body_at:]
    n = body.count('buf[(int)i + 10]')
    assert n == 7, n
    if form == 'a':
        body = body.replace('buf[(int)i + 10]', '*(buf + (int)i + 10)')
    else:
        assert head.count('void Voice_Build_Four_Partials(') == 1
        head = head.replace('void Voice_Build_Four_Partials(', STRUCT)
        for f in ('Voice_Build_Four_Partials', 'Voice_NoteOn_Type1', 'Voice_NoteOn_Type2'):
            old = 'void %s(unsigned char *p,' % f
            assert head.count(old) == 1, f
            head = head.replace(old, 'void %s(struct req *p,' % f)
        assert body.count('unsigned char buf[14];') == 1 and body.count('&buf[0]') == 3
        body = body.replace('unsigned char buf[14];', 'struct req r;').replace('&buf[0]', '&r')
        body = body.replace('buf[(int)i + 10]', 'r.ch[i]' if form == 'b' else 'r.ch[(int)i]')
        assert 'buf' not in body
    out = os.path.join(D, 'sub_AQ_38%s.c' % form)
    open(out, 'wb').write((head + body).encode('ascii'))
    print(out, n)
