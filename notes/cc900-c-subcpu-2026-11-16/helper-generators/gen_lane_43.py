#!/usr/bin/env python3
"""gen_lane_43.py: three spellings of Audio_Process_DSP's v1.40 form (lane_sub, round 43, 2026-11-20).

QUESTION ANSWERED: which C gives v1.40's two remaining spots (helper AN's best, sub_AN_30c, run
2026-11-19-42-sub-r30n-v140, DIFF at +24, every other instruction the ROM's)?
  1. sub-command 0x24's reference pair: the ROM builds the index in 16 bits, `extz wa; add wa,wa; add wa,0x27`,
     reads lo as (xhl+wa) and hi as `exts xwa; add xwa,xhl; (xwa+1)`; 30c computed `i * 2 + 0x27` in 8 bits and
     folded hi's +1 into the index.
  2. the 0x2b write path: the ROM moves the channel into QIZ and ANDs it there (`ld QIZ,WA; and QIZ,0xf`) and keeps
     the 14-bit field in IZ; 30c ANDed in WA before the move.  v1.41's matching C (v142/subcpu/cc900-staged/
     audio_process_dsp_and_effects_an_26c.c) has the same statements with the registers swapped (channel IZ, field
     QIZ); the forms keep its text and change where the field `v` is declared (V4.23 hands the XIZ family out in
     declaration order).
Forms (spot 1 / spot 2):
  a: lo `((unsigned char *)((unsigned int *)t + i))[0x27]` (a 2-byte element scaled by add), hi through
     `struct pair *` on that address + 0x27 / v declared at function scope just before ch;
  b: `(int)i * 2 + 0x27` as the index, hi `((struct pair *)&t[...])->hi` / v declared at function scope after c;
  c: as a, both halves through the struct pointer / v declared first of all locals.
Writes scripts/analysis/cc900/corpus/firmware/sub_lane_43{a,b,c}.c from sub_AN_30c.c.
    python3 -B notes/cc900-c-subcpu-2026-11-16/helper-generators/gen_lane_43.py      (repository root)
"""
import os

R = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..'))
D = os.path.join(R, 'scripts/analysis/cc900/corpus/firmware')
base = open(os.path.join(D, 'sub_AN_30c.c')).read()

OLD_CALL = '                        n = DSP_SetVoiceCoefficients(t[ram_4370[1] * 2 + 0x27], (&t[ram_4370[1] * 2 + 0x27])[1], p);\n'
OLD_WRITE = ('                    int w;\n'
             '                    k = sel;\n'
             '                    w = k;\n'
             '                    w = w & 0xf;\n'
             '                    n = DSP_WriteVoiceParam(w, Extract_14Bit_VoiceParam(ram_4368),\n'
             '                                            Extract_14Bit_PayloadSize(ram_4368), ram_4370);\n')
NEW_WRITE = ('                    k = sel;\n'
             '                    ch = k;\n'
             '                    ch &= 0xf;\n'
             '                    v = Extract_14Bit_VoiceParam(ram_4368);\n'
             '                    n = DSP_WriteVoiceParam(ch, v, Extract_14Bit_PayloadSize(ram_4368), ram_4370);\n')
DECL = ('    unsigned char *r;\n    unsigned char part;\n    unsigned char *p;\n    int c;\n    unsigned char sel;\n'
        '    int ch;\n')
PAIR = 'struct pair { unsigned char lo; unsigned char hi; };\n'
ANCHOR = 'void Audio_Process_DSP(void)\n'

A = '(unsigned char *)((unsigned int *)t + ram_4370[1])'
CALLS = {
    'a': '                        n = DSP_SetVoiceCoefficients((%s)[0x27], ((struct pair *)(%s + 0x27))->hi, p);\n'
         % (A, A),
    'b': '                        n = DSP_SetVoiceCoefficients(t[(int)ram_4370[1] * 2 + 0x27], '
         '((struct pair *)&t[(int)ram_4370[1] * 2 + 0x27])->hi, p);\n',
    'c': '                        n = DSP_SetVoiceCoefficients(((struct pair *)(%s + 0x27))->lo, '
         '((struct pair *)(%s + 0x27))->hi, p);\n' % (A, A),
}
DECLS = {
    'a': DECL.replace('    int ch;\n', '    unsigned int v;\n    int ch;\n'),
    'b': DECL.replace('    int c;\n', '    int c;\n    unsigned int v;\n'),
    'c': '    unsigned int v;\n' + DECL,
}
HEAD = ('/* lane_sub, round 43, form %s: Audio_Process_DSP, v1.40 form (KN5000 sub-CPU payload v1.40; check with\n'
        '   sub_v423.py one LISTING --tree v140/subcpu).  Written by\n'
        '   notes/cc900-c-subcpu-2026-11-16/helper-generators/gen_lane_43.py from sub_AN_30c.c (its docstring says what\n'
        '   each form changes).  Helper AN\'s notes follow.\n*/\n')

for f in 'abc':
    t = base
    for old, new in ((OLD_CALL, CALLS[f]), (OLD_WRITE, NEW_WRITE), (DECL, DECLS[f]), (ANCHOR, PAIR + ANCHOR)):
        assert t.count(old) == 1, (f, old[:60])
        t = t.replace(old, new)
    out = os.path.join(D, 'sub_lane_43%s.c' % f)
    open(out, 'w').write(HEAD % f + t)
    print('wrote', os.path.relpath(out, R))
