#!/usr/bin/env python3
"""gen_lane_48.py: VoiceParam_Set_Tone_Option, three spellings of its first store (lane_sub, round 48, 2026-11-22).

QUESTION ANSWERED: helper AW's sub_AW_47c (run 2026-11-21-23-sub-r47a) differs from the ROM only in registers at +12:
V4.23 builds the offset `o` in HL and the base in XDE (`ld (XDE+HL),A`); the ROM has the offset in DE and the base
in XHL (`ld (XHL+DE),A`).  The forms change the local o:
  a: `int o;` declared before `unsigned char *r;`;
  b: as a, o computed without the casts (`o = idx; o += 472;`);
  c: `register int o;` in 47c's order.
Writes scripts/analysis/cc900/corpus/firmware/sub_lane_48{a,b,c}.c from sub_AW_47c.c.
    python3 -B notes/cc900-c-subcpu-2026-11-16/helper-generators/gen_lane_48.py      (repository root)
"""
import os

R = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..'))
D = os.path.join(R, 'scripts/analysis/cc900/corpus/firmware')
base = open(os.path.join(D, 'sub_AW_47c.c')).read()
DECL = '    unsigned char *r;\n    int o;\n\n    o = (int)(unsigned int)idx;\n'
NEW = {
    'a': '    int o;\n    unsigned char *r;\n\n    o = (int)(unsigned int)idx;\n',
    'b': '    int o;\n    unsigned char *r;\n\n    o = idx;\n',
    'c': '    unsigned char *r;\n    register int o;\n\n    o = (int)(unsigned int)idx;\n',
}
for f in 'abc':
    assert base.count(DECL) == 1
    t = '/* lane_sub round 48 form %s (gen_lane_48.py, from sub_AW_47c.c) */\n' % f + base.replace(DECL, NEW[f])
    out = os.path.join(D, 'sub_lane_48%s.c' % f)
    open(out, 'w').write(t)
    print('wrote', os.path.relpath(out, R))
