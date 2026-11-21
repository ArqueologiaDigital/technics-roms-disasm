#!/usr/bin/env python3
"""gen_lane_43d.py: Audio_Process_DSP's v1.40 write path, round 43 forms j-l (lane_sub, 2026-11-21).

QUESTION ANSWERED: run 2026-11-21-1-sub-r43c's forms g / h (gen_lane_43c.py: the channel in a function-scope w,
the field nested in the call) differ from the v1.40 ROM in ONE instruction: the channel's `and 0xf` happens in WA
before `ld QIZ,WA` instead of on QIZ after it.  V4.23 merges w with the int temporary it is copied from when w has
no other definition (v1.41's ch, defined on four paths, keeps the ROM's `ld IZ,WA; and IZ,0xf`).  These forms give
the channel variable more than one definition or a register class:
  j: as g, `register int w`;
  k: as g, w also defined on the 0x2b `sel == 0x40` path (`w = 0;` there; a probe of the merge, not a firmware guess);
  l: the channel in n, the result variable (`n = k; n &= 0xf; n = DSP_WriteVoiceParam(n, ...)`).
Writes scripts/analysis/cc900/corpus/firmware/sub_lane_43{j,k,l}.c from sub_lane_43g.c.
    python3 -B notes/cc900-c-subcpu-2026-11-16/helper-generators/gen_lane_43d.py      (repository root)
"""
import os

R = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..'))
D = os.path.join(R, 'scripts/analysis/cc900/corpus/firmware')
base = open(os.path.join(D, 'sub_lane_43g.c')).read()

WDECL = '    unsigned char *q;\n    int w;\n'
WRITE = ('                    k = sel;\n                    w = k;\n                    w &= 0xf;\n'
         '                    n = DSP_WriteVoiceParam(w, Extract_14Bit_VoiceParam(ram_4368),\n')
SEL40 = ('            } else if (sel == 0x40) {\n'
         '                DSP_RingBuf_Skip(r);\n')
HEAD_OLD = '/* lane_sub, round 43, form g (gen_lane_43c.py, from form b):'

for f in 'jkl':
    t = base
    for s in (WDECL, WRITE, HEAD_OLD):
        assert t.count(s) == 1, (f, s)
    assert t.count(SEL40) >= 1, f
    t = t.replace(HEAD_OLD, '/* lane_sub, round 43, form %s (gen_lane_43d.py, from form g):' % f)
    if f == 'j':
        t = t.replace(WDECL, '    unsigned char *q;\n    register int w;\n')
    elif f == 'k':
        t = t.replace(SEL40, SEL40.replace('{\n', '{\n                w = 0;\n'), 1)
    else:
        t = t.replace(WDECL, '    unsigned char *q;\n')
        t = t.replace(WRITE, WRITE.replace('w = k;', 'n = k;').replace('w &= 0xf;', 'n &= 0xf;')
                      .replace('DSP_WriteVoiceParam(w,', 'DSP_WriteVoiceParam(n,'))
    out = os.path.join(D, 'sub_lane_43%s.c' % f)
    open(out, 'w').write(t)
    print('wrote', os.path.relpath(out, R))
