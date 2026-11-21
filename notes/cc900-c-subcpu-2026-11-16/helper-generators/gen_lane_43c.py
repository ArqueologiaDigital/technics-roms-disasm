#!/usr/bin/env python3
"""gen_lane_43c.py: Audio_Process_DSP's v1.40 write path, round 43 forms g-i (lane_sub, 2026-11-20).

QUESTION ANSWERED: run 2026-11-20-7-sub-r43b (forms d-f, gen_lane_43b.py): whichever variable holds the channel
gets IZ while a field variable `v` exists (d: k, e: a function-scope w, f: the field in c), and the ROM has the
channel in QIZ, the field in IZ.  helper AN's sub_AN_30c (field nested in the call, no variable) had the field in IZ
and the channel in QIZ, but ANDed in WA before the move (block-local w merged with k).  Form e's function-scope w
gave the ROM's in-place `and` on its register.  So these forms combine e's channel with 30c's nested field:
  g: function-scope `int w` declared last, `k = sel; w = k; w &= 0xf;`, the field nested in the call;
  h: as g without k: `w = sel; w &= 0xf;`;
  i: as g with w declared first of all locals.
Writes scripts/analysis/cc900/corpus/firmware/sub_lane_43{g,h,i}.c from sub_lane_43b.c.
    python3 -B notes/cc900-c-subcpu-2026-11-16/helper-generators/gen_lane_43c.py      (repository root)
"""
import os

R = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..'))
D = os.path.join(R, 'scripts/analysis/cc900/corpus/firmware')
base = open(os.path.join(D, 'sub_lane_43b.c')).read()

OLD = ('                    k = sel;\n'
       '                    ch = k;\n'
       '                    ch &= 0xf;\n'
       '                    v = Extract_14Bit_VoiceParam(ram_4368);\n'
       '                    n = DSP_WriteVoiceParam(ch, v, Extract_14Bit_PayloadSize(ram_4368), ram_4370);\n')
CALL = ('                    n = DSP_WriteVoiceParam(w, Extract_14Bit_VoiceParam(ram_4368),\n'
        '                                            Extract_14Bit_PayloadSize(ram_4368), ram_4370);\n')
NEW = {
    'g': '                    k = sel;\n                    w = k;\n                    w &= 0xf;\n' + CALL,
    'h': '                    w = sel;\n                    w &= 0xf;\n' + CALL,
    'i': '                    k = sel;\n                    w = k;\n                    w &= 0xf;\n' + CALL,
}
VDECL = '    unsigned int v;\n'           # form b's function-scope field, not used any more
LAST = '    unsigned char *q;\n'
FIRST = '    unsigned char *r;\n'
HEAD_OLD = '/* lane_sub, round 43, form b:'

for f in 'ghi':
    t = base
    for s in (OLD, VDECL, LAST, FIRST, HEAD_OLD):
        assert t.count(s) == 1, (f, s)
    t = t.replace(OLD, NEW[f]).replace(VDECL, '')
    t = t.replace(HEAD_OLD, '/* lane_sub, round 43, form %s (gen_lane_43c.py, from form b):' % f)
    if f == 'i':
        t = t.replace(FIRST, '    int w;\n' + FIRST)
    else:
        t = t.replace(LAST, LAST + '    int w;\n')
    out = os.path.join(D, 'sub_lane_43%s.c' % f)
    open(out, 'w').write(t)
    print('wrote', os.path.relpath(out, R))
