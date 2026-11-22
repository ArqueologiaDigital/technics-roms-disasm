#!/usr/bin/env python3
"""Helper AV, lane_sub round 43: writes scripts/analysis/cc900/corpus/firmware/sub_AV_43{a,b,c}.c
(DSP_SOS_LUT_Fetch and DSP_SOS_Coeff_Compute, KN5000 sub-CPU payload v1.42, core/14_dsp_control_routines.s).

The cc900-data lines are read from notes/cc900-c-subcpu-2026-11-16/helper-generators/fpconst.txt (address order =
V4.23's code order of the constants).  Run from the worktree root:

    python3 -B ~/compartilhado/tmp/cc900-tab/lane_sub/AV/gen_AV_43.py
"""
import os

ROOT = os.getcwd()
OUT = os.path.join(ROOT, 'scripts', 'analysis', 'cc900', 'corpus', 'firmware')
FPC = os.path.join(ROOT, 'notes', 'cc900-c-subcpu-2026-11-16', 'helper-generators', 'fpconst.txt')
assert os.path.isdir(OUT), OUT


def consts(prefixes):
    out = []
    for ln in open(FPC, encoding='latin-1'):
        f = ln.split()
        if len(f) >= 2 and any(f[1].startswith(p) for p in prefixes):
            out.append((int(f[0], 16), f[1]))
    return [n for _, n in sorted(out)]


LUT_C = consts(['FPConst_DSP_SOS_LUT_'])
SOS_C = consts(['FPConst_DSP_SOS_Coeff_Compute_', 'FPConst_DSP_SOS_Algo'])
assert len(LUT_C) == 4 and len(SOS_C) == 63, (len(LUT_C), len(SOS_C))

FORMS = {
    'a': dict(
        what="""   - DSP_SOS_LUT_Fetch: each table float read as `fr = +T[k];` with i a `register` parameter (helper AU tries
     the unary plus with a plain i on DSP_FilterLUT_Fetch).  The ROM copies each table float with FP_SP_Raw4Copy
     (`._fld_ff` by library order: between `._fld_fd` and `._fld_fl`) from the FP operand address `sla wa,2` /
     `lda xbc,T` / `lda xbc,(xbc+wa)`; a plain copy (sub_fp_21*) is inline, so i is never live across a call and
     m takes IZ.  p and tbl are not address-taken (ROM: `ld xwa,(p)` / `ld c,(xwa+)` / `ld (p),xwa`).
   - DSP_SOS_Coeff_Compute: chip and the status s plain (ROM: chip in IZ, s in QIZ, `ld QIZ,HL` after each write);
     the double quotient narrowed with an explicit `(float)(...)` (DSP_ReverbCurve_FP needed that cast for the ROM's
     temporary order; the ROM builds sin - 1.0 and the quotient in the shared double temporary at +72).""",
        tbl_decl='extern float DSP_EQ_FreqHz_Table[];',
        rd=lambda k: '+DSP_EQ_FreqHz_Table[%s]' % k,
        chip='int chip', s='int s;', cast=True),
    'b': dict(
        what="""   Form a with these changes:
   - DSP_SOS_LUT_Fetch: the table an array of one-float structs, read `fr = T[k].f;` (V4.23 addresses 4-byte
     struct elements with the 16-bit `sla 0x2,WA` / `lda XBC,_t` / `lda r,XBC+WA`, the ROM's shape; does the member
     copy then go through `._fld_ff`?).
   - DSP_SOS_Coeff_Compute: chip declared `register` (does it keep IZ and leave QIZ to s?).""",
        tbl_decl='struct eqf { float f; };\nextern struct eqf DSP_EQ_FreqHz_Table[];',
        rd=lambda k: 'DSP_EQ_FreqHz_Table[%s].f' % k,
        chip='register int chip', s='int s;', cast=True),
    'c': dict(
        what="""   Form a with these changes:
   - DSP_SOS_LUT_Fetch: the table declared `volatile float` and read plainly (does a volatile source leave V4.23's
     inline float copy for the library copy `._fld_ff`?).
   - DSP_SOS_Coeff_Compute: the double quotient assigned to the float without the `(float)` cast.""",
        tbl_decl='extern volatile float DSP_EQ_FreqHz_Table[];',
        rd=lambda k: 'DSP_EQ_FreqHz_Table[%s]' % k,
        chip='int chip', s='int s;', cast=False),
}

HEAD = """/* lane_sub round 43, helper AV, form %s (KN5000 sub-CPU payload v1.42, core/14_dsp_control_routines.s): floating point.
   - DSP_SOS_Coeff_Compute (2,593 B, never compiled; span_refs.py: all 9 inner labels, Algo0..2 and the epilogue,
     inner-only): one switch on the type DSP_SOS_LUT_Fetch returns (ROM tests 2, 1, 0; others fall to the epilogue
     with no write, s uninitialised as in the ROM).  Locals declared top-down by the ROM's frame slots: freq 210,
     gain 206, k1 202, k2 198, nrm 194, c1 190, c2 186, r 182, amp 178, type 176 (the call results and the
     conversions below are V4.23's temporaries).  `if (gain >= 0.0F)`: V4.23 tests the negated relation, `<`
     (BC = 1 to `._fcmp_zf` = FP_SP_CmpZero32) and jumps to the else arm, as the ROM.  Each quotient written in
     the operand order the ROM computes (right operand first on a tie, the needier operand first otherwise).
     The three writers return the status (`ld QIZ,HL`), so DSP_WriteParamWord / DSP_WriteCoeffData_5B_Direct are
     declared `int` here (the built definitions are `void`), the latter with its third argument f0 (ROM: DE).
%s
   cc900-options: -Xr */
"""

LUT = """
/* cc900-module: DSP_SOS_LUT_Fetch DSP_SOS_Coeff_Compute */
%(data)s
unsigned char *DSP_SOS_LUT_Fetch(register unsigned int i, float *fo, float *go, int *mo, int *tbl, unsigned char *p)
{
    float fr;
    float g;
    int m;
    unsigned char c;

    m = *p & 0xf;
    c = *p++ & 0xf0;
    if (c != 0x10) {
        fr = %(r1)s;
        g = tbl[i + 1] * 0.5 + -12.0;
    } else {
        fr = %(r2)s;
        g = tbl[i] * 0.5 + -12.0;
    }
    if (m == 2) {
        fr = %(r3)s;
    }
    *mo = m;
    *fo = fr;
    *go = g;
    return p;
}
"""

K = '0.0001424758573'
SINCOS = '(sin(freq * %s) - 1.0) / cos(freq * %s)' % (K, K)

SOS = """
%(data)s
unsigned char *DSP_SOS_Coeff_Compute(%(chip)s, unsigned int slot, unsigned int v, unsigned char *p,
                                     unsigned int a, int *rec, int *st, int f0)
{
    float freq;
    float gain;
    float k1;
    float k2;
    float nrm;
    float c1;
    float c2;
    float r;
    float amp;
    int type;
    %(s)s

    p = DSP_SOS_LUT_Fetch(v, &freq, &gain, &type, rec, p);
    switch (type) {
    case 0:
        amp = pow(10.0, gain / 20.0F);
        if (gain >= 0.0F) {
            k1 = %(sc)s;
            r = (k1 + 1.0F) / (1.0F - k1);
            k2 = (1.0F - amp / r) / (amp / r + 1.0F);
        } else {
            k2 = %(sc)s;
            r = (1.0F - k2) / (k2 + 1.0F);
            k1 = (amp / r - 1.0F) / (amp / r + 1.0F);
        }
        nrm = (1.0F - k2) / (1.0F - k1);
        c1 = k1 * nrm;
        c2 = -k2;
        s = DSP_WriteOscParam(a, (long)(c1 * 4194304.0F), chip, f0);
        s = DSP_WriteParamWord((long)(c2 * 4194304.0F), chip);
        s = DSP_WriteParamWord((long)(nrm * 4194304.0F), chip);
        break;
    case 1:
        amp = pow(10.0, gain / 20.0F);
        if (gain >= 0.0F) {
            k1 = %(sc)s;
            r = (1.0F - k1) / (k1 + 1.0F);
            k2 = (amp / r - 1.0F) / (amp / r + 1.0F);
        } else {
            k2 = %(sc)s;
            r = (k2 + 1.0F) / (1.0F - k2);
            k1 = (1.0F - amp / r) / (amp / r + 1.0F);
        }
        nrm = (k2 + 1.0F) / (k1 + 1.0F);
        c1 = k1 * nrm;
        c2 = -k2;
        s = DSP_WriteOscParam(a, (long)(c1 * 2097152.0F), chip, f0);
        s = DSP_WriteParamWord((long)(c2 * 4194304.0F), chip);
        s = DSP_WriteParamWord((long)(nrm * 2097152.0F), chip);
        break;
    case 2:
        amp = pow(10.0, gain / 20.0F);
        if (gain >= 0.0F) {
            k1 = %(sc)s;
            r = (1.0F - k1) / (k1 + 1.0F);
            k2 = (amp / r - 1.0F) / (amp / r + 1.0F);
        } else {
            k2 = %(sc)s;
            r = (k2 + 1.0F) / (1.0F - k2);
            k1 = (1.0F - amp / r) / (amp / r + 1.0F);
        }
        nrm = (k2 + 1.0F) / (k1 + 1.0F);
        c1 = k1;
        c2 = -k2;
        s = DSP_WriteOscParam(a, (long)(c2 * 4194304.0F), chip, f0);
        s = DSP_WriteCoeffData_5B_Direct((long)(nrm * 4194304.0F), chip, f0);
        s = DSP_WriteCoeffData_5B_Direct((long)(c1 * 4194304.0F), chip, f0);
        break;
    }
    *st = s;
    return p;
}
"""


def data(func, names):
    return '\n'.join('/* cc900-data: %s %d = %s */' % (func, i + 1, n) for i, n in enumerate(names))


for form, d in FORMS.items():
    txt = HEAD % (form, d['what']) + '\n'
    txt += '\n'.join([
        'extern double __cdecl pow(double x, double y);',
        'extern double __cdecl sin(double x);',
        'extern double __cdecl cos(double x);',
        d['tbl_decl'],
        'extern int DSP_WriteOscParam(unsigned int a, long v, register int chip, int base);',
        'extern int DSP_WriteParamWord(long v, int chip);',
        'extern int DSP_WriteCoeffData_5B_Direct(long v, int chip, int f0);',
        'unsigned char *DSP_SOS_LUT_Fetch(register unsigned int i, float *fo, float *go, int *mo, int *tbl,',
        '                                 unsigned char *p);',
        'unsigned char *DSP_SOS_Coeff_Compute(%s, unsigned int slot, unsigned int v, unsigned char *p,' % d['chip'],
        '                                     unsigned int a, int *rec, int *st, int f0);',
    ]) + '\n'
    txt += LUT % dict(data=data('DSP_SOS_LUT_Fetch', LUT_C), r1=d['rd']('tbl[i]'), r2=d['rd']('tbl[i - 1]'),
                      r3=d['rd']('*p++ & 0x1f'))
    txt += SOS % dict(data=data('DSP_SOS_Coeff_Compute', SOS_C), chip=d['chip'], s=d['s'],
                      sc='(float)(%s)' % SINCOS if d['cast'] else SINCOS)
    path = os.path.join(OUT, 'sub_AV_43%s.c' % form)
    with open(path, 'w', encoding='latin-1') as fh:
        fh.write(txt)
    print('wrote', path)
