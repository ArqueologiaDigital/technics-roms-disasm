#!/usr/bin/env python3
"""gen_lane_23m.py: writes lane_sub's round-23 frame probes of DSP_MixerCoeff_Compute,
scripts/analysis/cc900/corpus/firmware/sub_lane_23m<N>.c, one spelling per file.

QUESTION: which C gives the ROM's 20-byte frame (an untouched 4-byte slot at xsp+4, v at +8, f at +12, w at +16)?
Every earlier attempt (sub_fp_20*, sub_AJ_21*) gave a 16-byte frame with the same code.  The ROM computes the float
conversion's source address &DSP2_MixerGain_Curve[a] in XIZ (pushed), so these forms try a pointer register local
for it (a register candidate may keep a spill slot), in several declaration orders, and two other extra locals.
Run from the repository root: python3 -B notes/cc900-c-subcpu-2026-11-16/helper-generators/gen_lane_23m.py
"""
import os

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..'))
OUT = os.path.join(REPO, 'scripts', 'analysis', 'cc900', 'corpus', 'firmware')

HEAD = '''/* lane_sub, round 23, DSP_MixerCoeff_Compute frame probe m%d (written by
   notes/cc900-c-subcpu-2026-11-16/helper-generators/gen_lane_23m.py): %s
   cc900-options: -Xr */

extern unsigned long DSP_MixerGain_Curve[];
extern long __near DSP2_MixerGain_Curve[];
extern int DSP_DispatchCommand(int d, int chip);
extern int DSP_DispatchData(int d, int chip);
extern void DSP2_SPI_BusIdle(void);
extern void DSP_Bytecode_NotifyStateChange(void);

void DSP_MixerCoeff_Compute(unsigned int a, unsigned int b, unsigned int c)
{
'''

TAIL = '''    DSP_DispatchCommand(0x30, 1);
    DSP_DispatchData(0, 1);
    DSP_DispatchData(0xd0, 1);
    DSP_DispatchData(v >> 24, 1);
    DSP_DispatchData(v >> 16, 1);
    DSP2_SPI_BusIdle();
    DSP_Bytecode_NotifyStateChange();
    DSP_DispatchCommand(0x30, 1);
    DSP_DispatchData(0, 1);
    DSP_DispatchData(0xd3, 1);
    DSP_DispatchData((unsigned long)w >> 25, 1);
    DSP_DispatchData((unsigned long)w >> 17, 1);
    DSP2_SPI_BusIdle();
    DSP_Bytecode_NotifyStateChange();
}
'''

V = '    v = (DSP2_MixerGain_Curve[c] >> 15) * (((DSP2_MixerGain_Curve[a] >> 16) * (DSP_MixerGain_Curve[b] >> 15)) >> 16);\n'

FORMS = [
    ('w, f, v, then a pointer local p = &curve[a]; f = *p',
     '    long w;\n    float f;\n    unsigned long v;\n    long *p;\n\n' + V +
     '    p = &DSP2_MixerGain_Curve[a];\n    f = *p;\n    w = f;\n'),
    ('w, f, p, v (the pointer declared before v)',
     '    long w;\n    float f;\n    long *p;\n    unsigned long v;\n\n' + V +
     '    p = &DSP2_MixerGain_Curve[a];\n    f = *p;\n    w = f;\n'),
    ('w, f, v, register long *p',
     '    long w;\n    float f;\n    unsigned long v;\n    register long *p;\n\n' + V +
     '    p = &DSP2_MixerGain_Curve[a];\n    f = *p;\n    w = f;\n'),
    ('p declared first, then w, f, v',
     '    long *p;\n    long w;\n    float f;\n    unsigned long v;\n\n' + V +
     '    p = &DSP2_MixerGain_Curve[a];\n    f = *p;\n    w = f;\n'),
    ('w, f, v, a long temporary t for the inner product (a second spilled register candidate)',
     '    long w;\n    float f;\n    unsigned long v;\n    unsigned long t;\n\n'
     '    t = ((DSP2_MixerGain_Curve[a] >> 16) * (DSP_MixerGain_Curve[b] >> 15)) >> 16;\n'
     '    v = (DSP2_MixerGain_Curve[c] >> 15) * t;\n'
     '    f = DSP2_MixerGain_Curve[a];\n    w = f;\n'),
    ('w, f, v, an unsigned long copy u of v kept across the calls (v = u)',
     '    long w;\n    float f;\n    unsigned long v;\n    unsigned long u;\n\n'
     '    u = (DSP2_MixerGain_Curve[c] >> 15) * (((DSP2_MixerGain_Curve[a] >> 16) * (DSP_MixerGain_Curve[b] >> 15)) >> 16);\n'
     '    v = u;\n    f = DSP2_MixerGain_Curve[a];\n    w = f;\n'),
    ('w, f, v, the float read through a (long *) cast of the element address (a compiler temporary for it)',
     '    long w;\n    float f;\n    unsigned long v;\n\n' + V +
     '    f = *(long *)&DSP2_MixerGain_Curve[a];\n    w = f;\n'),
    ('w, f, v, p; p = DSP2_MixerGain_Curve + a',
     '    long w;\n    float f;\n    unsigned long v;\n    long *p;\n\n' + V +
     '    p = DSP2_MixerGain_Curve + a;\n    f = *p;\n    w = f;\n'),
    # round 23 second batch (run -3 showed: a pointer local takes XIZ and v moves into it, frame 12; t / u / the
    # cast keep the 16-byte frame): the untouched slot as half of an 8-byte object
    ('w, f, then v as the second half of a two-long array (v[1] at +8, v[0] the untouched slot at +4)',
     '    long w;\n    float f;\n    unsigned long v[2];\n\n'
     '    v[1] = (DSP2_MixerGain_Curve[c] >> 15) * (((DSP2_MixerGain_Curve[a] >> 16) * (DSP_MixerGain_Curve[b] >> 15)) >> 16);\n'
     '    f = DSP2_MixerGain_Curve[a];\n    w = f;\n'
     '#define v v[1]\n'),
    ('w, f, then a struct of two longs whose second member holds v',
     '    long w;\n    float f;\n    struct { unsigned long lo; unsigned long v; } s;\n\n'
     '    s.v = (DSP2_MixerGain_Curve[c] >> 15) * (((DSP2_MixerGain_Curve[a] >> 16) * (DSP_MixerGain_Curve[b] >> 15)) >> 16);\n'
     '    f = DSP2_MixerGain_Curve[a];\n    w = f;\n'
     '#define v s.v\n'),
]


def main():
    for n, (why, body) in enumerate(FORMS, 1):
        path = os.path.join(OUT, 'sub_lane_23m%d.c' % n)
        with open(path, 'w') as f:
            f.write(HEAD % (n, why) + body + TAIL)
        print(path)


if __name__ == '__main__':
    main()
