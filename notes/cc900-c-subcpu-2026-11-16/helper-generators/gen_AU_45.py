#!/usr/bin/env python3
"""Helper AU, lane_sub round 45: writes scripts/analysis/cc900/corpus/firmware/sub_AU_45{a,b,c}.c with four functions
of core/14_dsp_control_routines.s (KN5000 sub-CPU payload v1.42): DSP_FilterLUT_Fetch, DSP_BiquadCoeff_Compute,
DSP_SOS_LUT_Fetch, DSP_SOS_Coeff_Compute.

QUESTION each form asks: see FORMS below and the head comment written into each file.  Inputs: helper AU's
sub_AU_44a.c (the BiquadCoeff body and its cc900-data lines) and helper AV's sub_AV_44b.c (the SOS_Coeff body and
its cc900-data lines), both in the corpus directory.  Run from the csub worktree root:

    python3 -B ~/compartilhado/tmp/cc900-tab/lane_sub/AU/gen_AU_45.py
"""
import os, re

OUT = os.path.join(os.getcwd(), 'scripts', 'analysis', 'cc900', 'corpus', 'firmware')
assert os.path.isdir(OUT), OUT
AU44 = open(os.path.join(OUT, 'sub_AU_44a.c'), encoding='latin-1').read()
AV44 = open(os.path.join(OUT, 'sub_AV_44b.c'), encoding='latin-1').read()


def block(text, start, end_line='}\n'):
    i = text.index(start)
    j = text.index('\n' + end_line, i) + len(end_line) + 1
    return text[i:j]


BIQ = block(AU44, '/* cc900-data: DSP_BiquadCoeff_Compute 1 ')
SOSC = block(AV44, '/* cc900-data: DSP_SOS_Coeff_Compute 1 ')
assert BIQ.rstrip().endswith('}') and SOSC.rstrip().endswith('}')
assert '(void)&chip;\n' in BIQ
BIQ = BIQ.replace('    (void)&chip;\n', '    (void)&chip;\n    (void)&f0;\n')
KK2_A = '        kk2 = +(+(k * 7.123792865e-05) * k) * 7.123792865e-05;\n'
assert KK2_A in BIQ

FORMS = {
    'a': dict(table='byte', shift=False, sos_sw=True, kk2='+(k * +(k * 7.123792865e-05)) * 7.123792865e-05',
              sos_long=False,
              what="""   - DSP_FilterLUT_Fetch / DSP_SOS_LUT_Fetch: round 44's volatile table called `._fld_ff` (FP_SP_Raw4Copy) as the ROM
     does, but an int index (also `(unsigned int)` or an unsigned table) is scaled in 32 bits (extz/exts, sll, add
     into XIZ), which spills i; only an index whose range V4.23 knows (AV's `*p++ & 0x1f`) got the ROM's 16-bit
     `sla 0x2,WA` / `lda XBC,T` / `lda XBC,XBC+WA`.  A byte table indexed by an int needs no scaling, so the ROM's
     shape may be a byte-offset read: tables declared `unsigned char`, each float read
     `*(volatile float *)&T[tbl[k] * 4]`.  SOS's type-2 test as a one-case switch (ROM `ld wa,(m)` / `cp wa,2`;
     `if (m == 2)` gave `cp (m),2`).
   - DSP_BiquadCoeff_Compute: round 44 matched shape and slots but for (1) f0 promoted into IZ (s then in QIZ):
     `(void)&f0;` added beside `(void)&chip;`; (2) Algo2's square evaluated its right operand k first, so the
     product k*c sat in the shared double temporary the ROM gives (double)k: now `+(k * +(k * c)) * c`.  The ROM's
     remaining frame difference (one pool double at +26 for +78) may follow from (2).
   - DSP_SOS_Coeff_Compute: helper AV's sub_AV_44b.c unchanged (same shape as the ROM; only the pool temporaries'
     frame slots differ)."""),
    'b': dict(table='float', shift=False, sos_sw=False, kk2='+(k * (k * 7.123792865e-05)) * 7.123792865e-05',
              sos_long=True,
              what="""   Form a with these changes:
   - the fetches: tables `volatile float`, each read through a byte pointer,
     `*(volatile float *)((unsigned char *)T + tbl[k] * 4)`; SOS's type-2 test kept as `if (m == 2)`.
   - DSP_BiquadCoeff_Compute: Algo2's square without the inner plus, `+(k * (k * c)) * c`.
   - DSP_SOS_Coeff_Compute: the writers' arguments cast `(long)(x * K)` (AV dropped the casts in round 44; casts
     moved the pool temporaries in round 43, and the ROM's pool slots sit higher than ours)."""),
    'c': dict(table='byte', shift=True, sos_sw=True, kk2='+(k * +(k * 7.123792865e-05)) * 7.123792865e-05',
              sos_long=False, sos_int=True,
              what="""   Form a with these changes:
   - the fetches: the byte offset written `tbl[k] << 2`.
   - DSP_SOS_Coeff_Compute: `gain / 20.0F` written `gain / 20` (an int constant converted by the compiler: the
     same code, one tree node fewer; does it move the pool temporaries?)."""),
}


def rd(f, T, ix):
    off = '(%s) << 2' % ix if f['shift'] else '(%s) * 4' % ix
    if f['table'] == 'byte':
        return '*(volatile float *)&%s[%s]' % (T, off)
    return '*(volatile float *)((unsigned char *)%s + %s)' % (T, off)


def filterlut(f):
    F = lambda ix: rd(f, 'DSP_EQ_FreqHz_Table', ix)
    Q = lambda ix: rd(f, 'DSP_EQ_Q_Table', ix)
    return '''/* cc900-data: DSP_FilterLUT_Fetch 1 = FPConst_DSP_FilterLUT_Fetch_0p5 */
/* cc900-data: DSP_FilterLUT_Fetch 2 = FPConst_DSP_FilterLUT_Fetch_Neg12 */
/* cc900-data: DSP_FilterLUT_Fetch 3 = FPConst_DSP_FilterLUT_Mode0x10_0p5 */
/* cc900-data: DSP_FilterLUT_Fetch 4 = FPConst_DSP_FilterLUT_Mode0x10_Neg12 */
/* cc900-data: DSP_FilterLUT_Fetch 5 = FPConst_DSP_FilterLUT_Mode0x20_0p5 */
/* cc900-data: DSP_FilterLUT_Fetch 6 = FPConst_DSP_FilterLUT_Mode0x20_Neg12 */
/* cc900-data: DSP_FilterLUT_Fetch 7 = FPConst_DSP_FilterLUT_ModeType2_0p5 */
/* cc900-data: DSP_FilterLUT_Fetch 8 = FPConst_DSP_FilterLUT_ModeType2_Neg12 */
/* cc900-data: DSP_FilterLUT_Fetch 9 = FPConst_DSP_FilterLUT_ModeType2_SubMode_0p5 */
/* cc900-data: DSP_FilterLUT_Fetch 10 = FPConst_DSP_FilterLUT_ModeType2_SubMode_Neg12 */
unsigned char *DSP_FilterLUT_Fetch(register unsigned int i, float *fo, float *qo, float *go, int *mo, int *tbl,
                                   unsigned char *p)
{
    float fr;
    float q;
    float g;
    int m;
    unsigned int c;

    m = *p & 0xf;
    c = *p++ & 0xf0;
    switch (m) {
    case 0:
        switch (c) {
        case 0:
            fr = %s;
            q = %s;
            g = tbl[i + 2] * 0.5 + -12.0;
            break;
        case 0x10:
            fr = %s;
            q = %s;
            g = tbl[i + 1] * 0.5 + -12.0;
            break;
        case 0x20:
        default:
            fr = %s;
            q = %s;
            g = tbl[i] * 0.5 + -12.0;
            break;
        }
        break;
    case 1:
        q = 0.1F;
        fr = %s;
        break;
    case 2:
        q = 2.0F;
        switch (c) {
        case 0:
            fr = %s;
            g = tbl[i + 1] * 0.5 + -12.0;
            break;
        case 0x20:
        default:
            fr = %s;
            g = tbl[i] * 0.5 + -12.0;
            break;
        }
        break;
    }
    *mo = m;
    *fo = fr;
    *qo = q;
    *go = g;
    return p;
}
''' % (F('tbl[i]'), Q('tbl[i + 1]'), F('tbl[i - 1]'), Q('tbl[i]'), F('tbl[i - 2]'), Q('tbl[i - 1]'),
       F('tbl[i]'), F('tbl[i]'), F('tbl[i - 1]'))


def soslut(f):
    T = 'DSP_EQ_FreqHz_Table'
    t2 = rd(f, T, '*p++ & 0x1f')
    if f['sos_sw']:
        tail = '    switch (m) {\n    case 2:\n        fr = %s;\n        break;\n    }\n' % t2
    else:
        tail = '    if (m == 2) {\n        fr = %s;\n    }\n' % t2
    return '''/* cc900-data: DSP_SOS_LUT_Fetch 1 = FPConst_DSP_SOS_LUT_Fetch_0p5 */
/* cc900-data: DSP_SOS_LUT_Fetch 2 = FPConst_DSP_SOS_LUT_Fetch_Neg12 */
/* cc900-data: DSP_SOS_LUT_Fetch 3 = FPConst_DSP_SOS_LUT_Mode0x10_0p5 */
/* cc900-data: DSP_SOS_LUT_Fetch 4 = FPConst_DSP_SOS_LUT_Mode0x10_Neg12 */
unsigned char *DSP_SOS_LUT_Fetch(register unsigned int i, float *fo, float *go, int *mo, int *tbl, unsigned char *p)
{
    float fr;
    float g;
    int m;
    unsigned char c;

    m = *p & 0xf;
    c = *p++ & 0xf0;
    switch (c) {
    default:
        fr = %s;
        g = tbl[i + 1] * 0.5 + -12.0;
        break;
    case 0x10:
        fr = %s;
        g = tbl[i] * 0.5 + -12.0;
        break;
    }
%s    *mo = m;
    *fo = fr;
    *go = g;
    return p;
}
''' % (rd(f, T, 'tbl[i]'), rd(f, T, 'tbl[i - 1]'), tail)


def main():
    for k, f in FORMS.items():
        if f['table'] == 'byte':
            tabs = 'extern unsigned char DSP_EQ_FreqHz_Table[];\nextern unsigned char DSP_EQ_Q_Table[];\n'
        else:
            tabs = 'extern volatile float DSP_EQ_FreqHz_Table[];\nextern volatile float DSP_EQ_Q_Table[];\n'
        biq = BIQ.replace(KK2_A, '        kk2 = %s;\n' % f['kk2'])
        sosc = SOSC
        if f['sos_long']:
            sosc = re.sub(r'(DSP_Write\w+\((?:a, )?)(\w+ \* \d+\.0F)', r'\1(long)(\2)', sosc)
            assert sosc.count('(long)(') == 9, sosc.count('(long)(')
        if f.get('sos_int'):
            assert sosc.count('gain / 20.0F') == 3
            sosc = sosc.replace('gain / 20.0F', 'gain / 20')
        head = ('/* lane_sub round 45, helper AU, form %s (KN5000 sub-CPU payload v1.42, '
                'core/14_dsp_control_routines.s): floating point.\n%s\n'
                '   Generated by ~/compartilhado/tmp/cc900-tab/lane_sub/AU/gen_AU_45.py.\n'
                '   cc900-options: -Xr */\n\n') % (k, f['what'])
        decl = ('extern double __cdecl pow(double x, double y);\n'
                'extern double __cdecl tan(double x);\n'
                'extern double __cdecl sin(double x);\n'
                'extern double __cdecl cos(double x);\n' + tabs +
                'extern int DSP_WriteOscParam(unsigned int a, long v, register int chip, int base);\n'
                'extern int DSP_WriteCoeffData_5B_Direct(long v, int chip, int f0);\n'
                'extern int DSP_WriteParamWord(long v, int chip);\n'
                'unsigned char *DSP_FilterLUT_Fetch(unsigned int i, float *fo, float *qo, float *go, int *mo, '
                'int *tbl,\n                                   unsigned char *p);\n'
                'unsigned char *DSP_BiquadCoeff_Compute(int chip, unsigned int slot, unsigned int v, unsigned char *p,\n'
                '                                       unsigned int a, int *rec, int f0, int *st);\n'
                'unsigned char *DSP_SOS_LUT_Fetch(unsigned int i, float *fo, float *go, int *mo, int *tbl, '
                'unsigned char *p);\n'
                'unsigned char *DSP_SOS_Coeff_Compute(int chip, unsigned int slot, unsigned int v, unsigned char *p,\n'
                '                                     unsigned int a, int *rec, int *st, int f0);\n\n'
                '/* cc900-module: DSP_FilterLUT_Fetch DSP_BiquadCoeff_Compute DSP_SOS_LUT_Fetch '
                'DSP_SOS_Coeff_Compute */\n')
        text = head + decl + filterlut(f) + '\n' + biq + '\n' + soslut(f) + '\n' + sosc
        path = os.path.join(OUT, 'sub_AU_45%s.c' % k)
        with open(path, 'w', encoding='latin-1') as fh:
            fh.write(text)
        print(path)


main()
