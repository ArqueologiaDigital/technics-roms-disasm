/* lane_sub round 43, helper AU, form b (KN5000 sub-CPU payload v1.42, core/14_dsp_control_routines.s): floating point.
   Each function is form a with these changes:
   - DSP_FilterLUT_Fetch: every table float read as `fr = (float)(double)T[k];` -- does V4.23 fold the round trip
     into one float-to-float conversion (`._fld_ff` = FP_SP_Raw4Copy, the ROM's call) the way a K&R-style
     float-promoting compiler would?  (If it does not fold, expect ftod + dtof and an 8-byte temporary.)
   - DSP_BiquadCoeff_Compute: the write status s a plain `int` (no `register`): does chip or s get IZ then?
   cc900-options: -Xr */

extern double __cdecl pow(double x, double y);
extern double __cdecl tan(double x);
extern float DSP_EQ_FreqHz_Table[];
extern float DSP_EQ_Q_Table[];
extern int DSP_WriteOscParam(unsigned int a, long v, register int chip, int base);
extern int DSP_WriteCoeffData_5B_Direct(long v, int chip, int f0);
extern int DSP_WriteParamWord(long v, int chip);
unsigned char *DSP_FilterLUT_Fetch(unsigned int i, float *fo, float *qo, float *go, int *mo, int *tbl,
                                   unsigned char *p);
unsigned char *DSP_BiquadCoeff_Compute(int chip, unsigned int slot, unsigned int v, unsigned char *p,
                                       unsigned int a, int *rec, int f0, int *st);

/* cc900-module: DSP_FilterLUT_Fetch DSP_BiquadCoeff_Compute */
/* cc900-data: DSP_FilterLUT_Fetch 1 = FPConst_DSP_FilterLUT_Fetch_0p5 */
/* cc900-data: DSP_FilterLUT_Fetch 2 = FPConst_DSP_FilterLUT_Fetch_Neg12 */
/* cc900-data: DSP_FilterLUT_Fetch 3 = FPConst_DSP_FilterLUT_Mode0x10_0p5 */
/* cc900-data: DSP_FilterLUT_Fetch 4 = FPConst_DSP_FilterLUT_Mode0x10_Neg12 */
/* cc900-data: DSP_FilterLUT_Fetch 5 = FPConst_DSP_FilterLUT_Mode0x20_0p5 */
/* cc900-data: DSP_FilterLUT_Fetch 6 = FPConst_DSP_FilterLUT_Mode0x20_Neg12 */
/* cc900-data: DSP_FilterLUT_Fetch 7 = FPConst_DSP_FilterLUT_ModeType2_0p5 */
/* cc900-data: DSP_FilterLUT_Fetch 8 = FPConst_DSP_FilterLUT_ModeType2_Neg12 */
/* cc900-data: DSP_FilterLUT_Fetch 9 = FPConst_DSP_FilterLUT_ModeType2_SubMode_0p5 */
/* cc900-data: DSP_FilterLUT_Fetch 10 = FPConst_DSP_FilterLUT_ModeType2_SubMode_Neg12 */
unsigned char *DSP_FilterLUT_Fetch(unsigned int i, float *fo, float *qo, float *go, int *mo, int *tbl,
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
            fr = (float)(double)DSP_EQ_FreqHz_Table[tbl[i]];
            q = (float)(double)DSP_EQ_Q_Table[tbl[i + 1]];
            g = tbl[i + 2] * 0.5 + -12.0;
            break;
        case 0x10:
            fr = (float)(double)DSP_EQ_FreqHz_Table[tbl[i - 1]];
            q = (float)(double)DSP_EQ_Q_Table[tbl[i]];
            g = tbl[i + 1] * 0.5 + -12.0;
            break;
        case 0x20:
        default:
            fr = (float)(double)DSP_EQ_FreqHz_Table[tbl[i - 2]];
            q = (float)(double)DSP_EQ_Q_Table[tbl[i - 1]];
            g = tbl[i] * 0.5 + -12.0;
            break;
        }
        break;
    case 1:
        q = 0.1F;
        fr = (float)(double)DSP_EQ_FreqHz_Table[tbl[i]];
        break;
    case 2:
        q = 2.0F;
        switch (c) {
        case 0:
            fr = (float)(double)DSP_EQ_FreqHz_Table[tbl[i]];
            g = tbl[i + 1] * 0.5 + -12.0;
            break;
        case 0x20:
        default:
            fr = (float)(double)DSP_EQ_FreqHz_Table[tbl[i - 1]];
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

/* cc900-data: DSP_BiquadCoeff_Compute 1 = FPConst_DSP_BiquadCoeff_Compute_7p1237929em5 */
/* cc900-data: DSP_BiquadCoeff_Compute 2 = FPConst_DSP_BiquadCoeff_Compute_1 */
/* cc900-data: DSP_BiquadCoeff_Compute 3 = FPConst_DSP_BiquadCoeff_Compute_1_2 */
/* cc900-data: DSP_BiquadCoeff_Compute 4 = FPConst_DSP_BiquadCoeff_Compute_Neg2 */
/* cc900-data: DSP_BiquadCoeff_Compute 5 = FPConst_DSP_BiquadCoeff_Compute_1_3 */
/* cc900-data: DSP_BiquadCoeff_Compute 6 = FPConst_DSP_BiquadCoeff_Algo0_AfterSign_20 */
/* cc900-data: DSP_BiquadCoeff_Compute 7 = FPConst_DSP_BiquadCoeff_Algo0_AfterSign_10 */
/* cc900-data: DSP_BiquadCoeff_Compute 8 = FPConst_DSP_BiquadCoeff_Algo0_AfterSign_1 */
/* cc900-data: DSP_BiquadCoeff_Compute 9 = FPConst_DSP_BiquadCoeff_Algo0_AfterSign2_20 */
/* cc900-data: DSP_BiquadCoeff_Compute 10 = FPConst_DSP_BiquadCoeff_Algo0_AfterSign2_10 */
/* cc900-data: DSP_BiquadCoeff_Compute 11 = FPConst_DSP_BiquadCoeff_Algo0_AfterSign2_1 */
/* cc900-data: DSP_BiquadCoeff_Compute 12 = FPConst_DSP_BiquadCoeff_Algo0_Assembly_1 */
/* cc900-data: DSP_BiquadCoeff_Compute 13 = FPConst_DSP_BiquadCoeff_Algo0_Assembly_1_2 */
/* cc900-data: DSP_BiquadCoeff_Compute 14 = FPConst_DSP_BiquadCoeff_Algo0_Fixup_2 */
/* cc900-data: DSP_BiquadCoeff_Compute 15 = FPConst_DSP_BiquadCoeff_Algo0_Fixup_2_2 */
/* cc900-data: DSP_BiquadCoeff_Compute 16 = FPConst_DSP_BiquadCoeff_Algo0_Fixup_2_3 */
/* cc900-data: DSP_BiquadCoeff_Compute 17 = FPConst_DSP_BiquadCoeff_Algo0_Fixup_Q22One */
/* cc900-data: DSP_BiquadCoeff_Compute 18 = FPConst_DSP_BiquadCoeff_Algo0_Fixup_Q22One_2 */
/* cc900-data: DSP_BiquadCoeff_Compute 19 = FPConst_DSP_BiquadCoeff_Algo0_Fixup_Q22One_3 */
/* cc900-data: DSP_BiquadCoeff_Compute 20 = FPConst_DSP_BiquadCoeff_Algo0_Fixup_Q22One_4 */
/* cc900-data: DSP_BiquadCoeff_Compute 21 = FPConst_DSP_BiquadCoeff_Algo0_Fixup_Q23One */
/* cc900-data: DSP_BiquadCoeff_Compute 22 = FPConst_DSP_BiquadCoeff_Algo1_7p1237929em5 */
/* cc900-data: DSP_BiquadCoeff_Compute 23 = FPConst_DSP_BiquadCoeff_Algo1_1 */
/* cc900-data: DSP_BiquadCoeff_Compute 24 = FPConst_DSP_BiquadCoeff_Algo1_1_2 */
/* cc900-data: DSP_BiquadCoeff_Compute 25 = FPConst_DSP_BiquadCoeff_Algo1_Neg2 */
/* cc900-data: DSP_BiquadCoeff_Compute 26 = FPConst_DSP_BiquadCoeff_Algo1_1_3 */
/* cc900-data: DSP_BiquadCoeff_Compute 27 = FPConst_DSP_BiquadCoeff_Algo1_Q22One */
/* cc900-data: DSP_BiquadCoeff_Compute 28 = FPConst_DSP_BiquadCoeff_Algo1_Q22One_2 */
/* cc900-data: DSP_BiquadCoeff_Compute 29 = FPConst_DSP_BiquadCoeff_Algo1_Q22One_3 */
/* cc900-data: DSP_BiquadCoeff_Compute 30 = FPConst_DSP_BiquadCoeff_Algo1_Q22One_4 */
/* cc900-data: DSP_BiquadCoeff_Compute 31 = FPConst_DSP_BiquadCoeff_Algo1_Q23One */
/* cc900-data: DSP_BiquadCoeff_Compute 32 = FPConst_DSP_BiquadCoeff_Algo2_7p1237929em5 */
/* cc900-data: DSP_BiquadCoeff_Compute 33 = FPConst_DSP_BiquadCoeff_Algo2_7p1237929em5_2 */
/* cc900-data: DSP_BiquadCoeff_Compute 34 = FPConst_DSP_BiquadCoeff_Algo2_7p1237929em5_3 */
/* cc900-data: DSP_BiquadCoeff_Compute 35 = FPConst_DSP_BiquadCoeff_Algo2_7p1237929em5_4 */
/* cc900-data: DSP_BiquadCoeff_Compute 36 = FPConst_DSP_BiquadCoeff_Algo2_7p1237929em5_5 */
/* cc900-data: DSP_BiquadCoeff_Compute 37 = FPConst_DSP_BiquadCoeff_Algo2_1 */
/* cc900-data: DSP_BiquadCoeff_Compute 38 = FPConst_DSP_BiquadCoeff_Algo2_1_2 */
/* cc900-data: DSP_BiquadCoeff_Compute 39 = FPConst_DSP_BiquadCoeff_Algo2_Neg2 */
/* cc900-data: DSP_BiquadCoeff_Compute 40 = FPConst_DSP_BiquadCoeff_Algo2_1_3 */
/* cc900-data: DSP_BiquadCoeff_Compute 41 = FPConst_DSP_BiquadCoeff_Algo2_AfterSign1_20 */
/* cc900-data: DSP_BiquadCoeff_Compute 42 = FPConst_DSP_BiquadCoeff_Algo2_AfterSign1_10 */
/* cc900-data: DSP_BiquadCoeff_Compute 43 = FPConst_DSP_BiquadCoeff_Algo2_AfterSign1_1 */
/* cc900-data: DSP_BiquadCoeff_Compute 44 = FPConst_DSP_BiquadCoeff_Algo2_AfterSign2_20 */
/* cc900-data: DSP_BiquadCoeff_Compute 45 = FPConst_DSP_BiquadCoeff_Algo2_AfterSign2_10 */
/* cc900-data: DSP_BiquadCoeff_Compute 46 = FPConst_DSP_BiquadCoeff_Algo2_AfterSign2_1 */
/* cc900-data: DSP_BiquadCoeff_Compute 47 = FPConst_DSP_BiquadCoeff_Algo2_WriteParams_Q22One */
/* cc900-data: DSP_BiquadCoeff_Compute 48 = FPConst_DSP_BiquadCoeff_Algo2_WriteParams_Q22One_2 */
/* cc900-data: DSP_BiquadCoeff_Compute 49 = FPConst_DSP_BiquadCoeff_Algo2_WriteParams_Q23One */
/* cc900-data: DSP_BiquadCoeff_Compute 50 = FPConst_DSP_BiquadCoeff_Algo2_WriteParams_Q22One_3 */
/* cc900-data: DSP_BiquadCoeff_Compute 51 = FPConst_DSP_BiquadCoeff_Algo2_WriteParams_Q22One_4 */
unsigned char *DSP_BiquadCoeff_Compute(int chip, unsigned int slot, unsigned int v, unsigned char *p,
                                       unsigned int a, int *rec, int f0, int *st)
{
    int m;
    float fr;
    float q;
    float g;
    float k;
    float a0;
    float a1;
    float a2;
    float b0;
    float b1;
    float b2;
    float c0;
    float c1;
    float c2;
    float c3;
    float c4;
    float kq;
    float kk;
    float kk2;
    float n;
    int s;

    p = DSP_FilterLUT_Fetch(v, &fr, &q, &g, &m, rec, p);
    switch (m) {
    case 0:
        k = tan(fr * 7.123792865e-05);
        kq = k / q;
        kk = k * k;
        a0 = kq + kk + 1.0F;
        a1 = (1.0F - kk) * -2.0F;
        a2 = kk - kq + 1.0F;
        b0 = kq * pow(10.0, (g >= 0 ? g : -g) / 20.0F) + 1.0 + kk;
        b1 = a1;
        b2 = 1.0 - kq * pow(10.0, (g >= 0 ? g : -g) / 20.0F) + kk;
        if (g >= 0) {
            c0 = b0 / a0;
            c1 = b1 / a0;
            c2 = b2 / a0;
            c3 = -a1 / a0;
            c4 = -a2 / a0;
        } else {
            c0 = a0 / b0;
            c1 = a1 / b0;
            c2 = a2 / b0;
            c3 = -b1 / b0;
            c4 = -b2 / b0;
        }
        n = (1.0F - c3 - c4) / (c0 + c1 + c2);
        if (n > 1.0F)
            n = 1.0F;
        c0 = n * c0 / 2.0F;
        c1 = n * c1 / 2.0F;
        c2 = n * c2 / 2.0F;
        s = DSP_WriteOscParam(a, (long)(c1 * 4194304.0F), chip, f0);
        s = DSP_WriteCoeffData_5B_Direct((long)(c0 * 4194304.0F), chip, f0);
        s = DSP_WriteCoeffData_5B_Direct((long)(c2 * 4194304.0F), chip, f0);
        s = DSP_WriteCoeffData_5B_Direct((long)(c3 * 4194304.0F), chip, f0);
        s = DSP_WriteCoeffData_5B_Direct((long)(c4 * 8388608.0F), chip, f0);
        break;
    case 1:
        k = tan(fr * 7.123792865e-05);
        kq = k / q;
        kk = k * k;
        a0 = kq + kk + 1.0F;
        a1 = (1.0F - kk) * -2.0F;
        a2 = kk - kq + 1.0F;
        c0 = kq / a0;
        c1 = 0.0F;
        c2 = -c0;
        c3 = -a1 / a0;
        c4 = -a2 / a0;
        s = DSP_WriteOscParam(a, (long)(c1 * 4194304.0F), chip, f0);
        s = DSP_WriteCoeffData_5B_Direct((long)(c0 * 4194304.0F), chip, f0);
        s = DSP_WriteCoeffData_5B_Direct((long)(c2 * 4194304.0F), chip, f0);
        s = DSP_WriteCoeffData_5B_Direct((long)(c3 * 4194304.0F), chip, f0);
        s = DSP_WriteCoeffData_5B_Direct((long)(c4 * 8388608.0F), chip, f0);
        break;
    case 2:
        k = tan(fr * 7.123792865e-05) / 7.123792865e-05;
        kq = k / q * 7.123792865e-05;
        kk2 = k * 7.123792865e-05 * k * 7.123792865e-05;
        a0 = kq + kk2 + 1.0F;
        a1 = (1.0F - kk2) * -2.0F;
        a2 = kk2 - kq + 1.0F;
        b0 = kq * pow(10.0, (g >= 0 ? g : -g) / 20.0F) + 1.0 + kk2;
        b1 = a1;
        b2 = 1.0 - kq * pow(10.0, (g >= 0 ? g : -g) / 20.0F) + kk2;
        if (g >= 0) {
            c3 = -a1 / a0;
            c4 = -a2 / a0;
            c0 = b0 / a0;
            c1 = b1 / a0;
            c2 = b2 / a0;
        } else {
            c3 = -b1 / b0;
            c4 = -b2 / b0;
            c0 = a0 / b0;
            c1 = a1 / b0;
            c2 = a2 / b0;
        }
        s = DSP_WriteOscParam(a, (long)(c1 * 4194304.0F), chip, f0);
        s = DSP_WriteParamWord((long)(c2 * 4194304.0F), chip);
        s = DSP_WriteParamWord((long)(c4 * 8388608.0F), chip);
        s = DSP_WriteParamWord((long)(c0 * 4194304.0F), chip);
        s = DSP_WriteParamWord((long)(c3 * 4194304.0F), chip);
        break;
    }
    *st = s;
    return p;
}
