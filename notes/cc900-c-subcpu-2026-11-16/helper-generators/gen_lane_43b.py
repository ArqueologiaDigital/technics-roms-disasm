#!/usr/bin/env python3
"""gen_lane_43b.py: three more spellings of Audio_Process_DSP's v1.40 write path (lane_sub, round 43, 2026-11-20).

QUESTION ANSWERED: run 2026-11-20-5-2026-11-20-6-sub-r43a's sub_lane_43b (gen_lane_43.py) fixed sub-command 0x24
(`(int)i * 2 + 0x27` gives the ROM's `extz wa; add wa,wa; add wa,0x27`; hi through `((struct pair *)&t[..])->hi`).
Its only remaining difference is the 0x2b write path's registers: v1.41's text gives channel IZ / field QIZ, the
v1.40 ROM has channel QIZ / field IZ.  Where the field `v` is declared did not change that (forms a-c).  These forms
change which variable carries the channel or the field (ch is also the channel of the 0x7f, 0x2c and 0x2d paths):
  d: the channel in k itself (`k = sel; k &= 0xf;`), not in ch;
  e: the channel in a new function-scope `int w` declared last (`k = sel; w = k; w &= 0xf;`);
  f: v1.41's channel ch, the field in the type word c (`c = Extract_14Bit_VoiceParam(..)`; the ROM keeps c in IZ).
Writes scripts/analysis/cc900/corpus/firmware/sub_lane_43{d,e,f}.c from sub_lane_43b.c.
    python3 -B notes/cc900-c-subcpu-2026-11-16/helper-generators/gen_lane_43b.py      (repository root)
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
NEW = {
    'd': ('                    k = sel;\n'
          '                    k &= 0xf;\n'
          '                    v = Extract_14Bit_VoiceParam(ram_4368);\n'
          '                    n = DSP_WriteVoiceParam(k, v, Extract_14Bit_PayloadSize(ram_4368), ram_4370);\n'),
    'e': ('                    k = sel;\n'
          '                    w = k;\n'
          '                    w &= 0xf;\n'
          '                    v = Extract_14Bit_VoiceParam(ram_4368);\n'
          '                    n = DSP_WriteVoiceParam(w, v, Extract_14Bit_PayloadSize(ram_4368), ram_4370);\n'),
    'f': ('                    k = sel;\n'
          '                    ch = k;\n'
          '                    ch &= 0xf;\n'
          '                    c = Extract_14Bit_VoiceParam(ram_4368);\n'
          '                    n = DSP_WriteVoiceParam(ch, c, Extract_14Bit_PayloadSize(ram_4368), ram_4370);\n'),
}
LAST = '    unsigned char *q;\n'
HEAD_OLD = '/* lane_sub, round 43, form b:'

for f in 'def':
    t = base
    assert t.count(OLD) == 1 and t.count(LAST) == 1 and t.count(HEAD_OLD) == 1
    t = t.replace(OLD, NEW[f]).replace(HEAD_OLD, '/* lane_sub, round 43, form %s (gen_lane_43b.py, from form b):' % f)
    if f == 'e':
        t = t.replace(LAST, LAST + '    int w;\n')
    out = os.path.join(D, 'sub_lane_43%s.c' % f)
    open(out, 'w').write(t)
    print('wrote', os.path.relpath(out, R))
