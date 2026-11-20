/* lane_sub round 43, helper AV, form b (KN5000 sub-CPU payload v1.42, core/14_dsp_control_routines.s): floating point.
   - DSP_SOS_Coeff_Compute (2,593 B, never compiled; span_refs.py: all 9 inner labels, Algo0..2 and the epilogue,
     inner-only): one switch on the type DSP_SOS_LUT_Fetch returns (ROM tests 2, 1, 0; others fall to the epilogue
     with no write, s uninitialised as in the ROM).  Locals declared top-down by the ROM's frame slots: freq 210,
     gain 206, k1 202, k2 198, nrm 194, c1 190, c2 186, r 182, amp 178, type 176 (the call results and the
     conversions below are V4.23's temporaries).  `if (gain >= 0.0F)`: V4.23 tests the negated relation, `<`
     (BC = 1 to `._fcmp_zf` = FP_SP_CmpZero32) and jumps to the else arm, as the ROM.  Each quotient written in
     the operand order the ROM computes (right operand first on a tie, the needier operand first otherwise).
     The three writers return the status (`ld QIZ,HL`), so DSP_WriteParamWord / DSP_WriteCoeffData_5B_Direct are
     declared `int` here (the built definitions are `void`), the latter with its third argument f0 (ROM: DE).
   Form a with these changes:
   - DSP_SOS_LUT_Fetch: the table an array of one-float structs, read `fr = T[k].f;` (V4.23 addresses 4-byte
     struct elements with the 16-bit `sla 0x2,WA` / `lda XBC,_t` / `lda r,XBC+WA`, the ROM's shape; does the member
     copy then go through `._fld_ff`?).
   - DSP_SOS_Coeff_Compute: chip declared `register` (does it keep IZ and leave QIZ to s?).
   cc900-options: -Xr */

extern double __cdecl pow(double x, double y);
extern double __cdecl sin(double x);
extern double __cdecl cos(double x);
struct eqf { float f; };
extern struct eqf DSP_EQ_FreqHz_Table[];
extern int DSP_WriteOscParam(unsigned int a, long v, register int chip, int base);
extern int DSP_WriteParamWord(long v, int chip);
extern int DSP_WriteCoeffData_5B_Direct(long v, int chip, int f0);
unsigned char *DSP_SOS_LUT_Fetch(register unsigned int i, float *fo, float *go, int *mo, int *tbl,
                                 unsigned char *p);
unsigned char *DSP_SOS_Coeff_Compute(register int chip, unsigned int slot, unsigned int v, unsigned char *p,
                                     unsigned int a, int *rec, int *st, int f0);

/* cc900-module: DSP_SOS_LUT_Fetch DSP_SOS_Coeff_Compute */
/* cc900-data: DSP_SOS_LUT_Fetch 1 = FPConst_DSP_SOS_LUT_Fetch_0p5 */
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
    if (c != 0x10) {
        fr = DSP_EQ_FreqHz_Table[tbl[i]].f;
        g = tbl[i + 1] * 0.5 + -12.0;
    } else {
        fr = DSP_EQ_FreqHz_Table[tbl[i - 1]].f;
        g = tbl[i] * 0.5 + -12.0;
    }
    if (m == 2) {
        fr = DSP_EQ_FreqHz_Table[*p++ & 0x1f].f;
    }
    *mo = m;
    *fo = fr;
    *go = g;
    return p;
}

/* cc900-data: DSP_SOS_Coeff_Compute 1 = FPConst_DSP_SOS_Coeff_Compute_20 */
/* cc900-data: DSP_SOS_Coeff_Compute 2 = FPConst_DSP_SOS_Coeff_Compute_10 */
/* cc900-data: DSP_SOS_Coeff_Compute 3 = FPConst_DSP_SOS_Coeff_Compute_0p00014247586 */
/* cc900-data: DSP_SOS_Coeff_Compute 4 = FPConst_DSP_SOS_Coeff_Compute_0p00014247586_2 */
/* cc900-data: DSP_SOS_Coeff_Compute 5 = FPConst_DSP_SOS_Coeff_Compute_1 */
/* cc900-data: DSP_SOS_Coeff_Compute 6 = FPConst_DSP_SOS_Coeff_Compute_1_2 */
/* cc900-data: DSP_SOS_Coeff_Compute 7 = FPConst_DSP_SOS_Coeff_Compute_1_3 */
/* cc900-data: DSP_SOS_Coeff_Compute 8 = FPConst_DSP_SOS_Coeff_Compute_1_4 */
/* cc900-data: DSP_SOS_Coeff_Compute 9 = FPConst_DSP_SOS_Coeff_Compute_1_5 */
/* cc900-data: DSP_SOS_Coeff_Compute 10 = FPConst_DSP_SOS_Algo0_NonzeroCoeff_0p00014247586 */
/* cc900-data: DSP_SOS_Coeff_Compute 11 = FPConst_DSP_SOS_Algo0_NonzeroCoeff_0p00014247586_2 */
/* cc900-data: DSP_SOS_Coeff_Compute 12 = FPConst_DSP_SOS_Algo0_NonzeroCoeff_1 */
/* cc900-data: DSP_SOS_Coeff_Compute 13 = FPConst_DSP_SOS_Algo0_NonzeroCoeff_1_2 */
/* cc900-data: DSP_SOS_Coeff_Compute 14 = FPConst_DSP_SOS_Algo0_NonzeroCoeff_1_3 */
/* cc900-data: DSP_SOS_Coeff_Compute 15 = FPConst_DSP_SOS_Algo0_NonzeroCoeff_1_4 */
/* cc900-data: DSP_SOS_Coeff_Compute 16 = FPConst_DSP_SOS_Algo0_NonzeroCoeff_1_5 */
/* cc900-data: DSP_SOS_Coeff_Compute 17 = FPConst_DSP_SOS_Algo0_FinalChain_1 */
/* cc900-data: DSP_SOS_Coeff_Compute 18 = FPConst_DSP_SOS_Algo0_FinalChain_1_2 */
/* cc900-data: DSP_SOS_Coeff_Compute 19 = FPConst_DSP_SOS_Algo0_FinalChain_Q22One */
/* cc900-data: DSP_SOS_Coeff_Compute 20 = FPConst_DSP_SOS_Algo0_FinalChain_Q22One_2 */
/* cc900-data: DSP_SOS_Coeff_Compute 21 = FPConst_DSP_SOS_Algo0_FinalChain_Q22One_3 */
/* cc900-data: DSP_SOS_Coeff_Compute 22 = FPConst_DSP_SOS_Algo1_20 */
/* cc900-data: DSP_SOS_Coeff_Compute 23 = FPConst_DSP_SOS_Algo1_10 */
/* cc900-data: DSP_SOS_Coeff_Compute 24 = FPConst_DSP_SOS_Algo1_0p00014247586 */
/* cc900-data: DSP_SOS_Coeff_Compute 25 = FPConst_DSP_SOS_Algo1_0p00014247586_2 */
/* cc900-data: DSP_SOS_Coeff_Compute 26 = FPConst_DSP_SOS_Algo1_1 */
/* cc900-data: DSP_SOS_Coeff_Compute 27 = FPConst_DSP_SOS_Algo1_1_2 */
/* cc900-data: DSP_SOS_Coeff_Compute 28 = FPConst_DSP_SOS_Algo1_1_3 */
/* cc900-data: DSP_SOS_Coeff_Compute 29 = FPConst_DSP_SOS_Algo1_1_4 */
/* cc900-data: DSP_SOS_Coeff_Compute 30 = FPConst_DSP_SOS_Algo1_1_5 */
/* cc900-data: DSP_SOS_Coeff_Compute 31 = FPConst_DSP_SOS_Algo1_NonzeroCoeff_0p00014247586 */
/* cc900-data: DSP_SOS_Coeff_Compute 32 = FPConst_DSP_SOS_Algo1_NonzeroCoeff_0p00014247586_2 */
/* cc900-data: DSP_SOS_Coeff_Compute 33 = FPConst_DSP_SOS_Algo1_NonzeroCoeff_1 */
/* cc900-data: DSP_SOS_Coeff_Compute 34 = FPConst_DSP_SOS_Algo1_NonzeroCoeff_1_2 */
/* cc900-data: DSP_SOS_Coeff_Compute 35 = FPConst_DSP_SOS_Algo1_NonzeroCoeff_1_3 */
/* cc900-data: DSP_SOS_Coeff_Compute 36 = FPConst_DSP_SOS_Algo1_NonzeroCoeff_1_4 */
/* cc900-data: DSP_SOS_Coeff_Compute 37 = FPConst_DSP_SOS_Algo1_NonzeroCoeff_1_5 */
/* cc900-data: DSP_SOS_Coeff_Compute 38 = FPConst_DSP_SOS_Algo1_FinalChain_1 */
/* cc900-data: DSP_SOS_Coeff_Compute 39 = FPConst_DSP_SOS_Algo1_FinalChain_1_2 */
/* cc900-data: DSP_SOS_Coeff_Compute 40 = FPConst_DSP_SOS_Algo1_FinalChain_Q21One */
/* cc900-data: DSP_SOS_Coeff_Compute 41 = FPConst_DSP_SOS_Algo1_FinalChain_Q22One */
/* cc900-data: DSP_SOS_Coeff_Compute 42 = FPConst_DSP_SOS_Algo1_FinalChain_Q21One_2 */
/* cc900-data: DSP_SOS_Coeff_Compute 43 = FPConst_DSP_SOS_Algo2_20 */
/* cc900-data: DSP_SOS_Coeff_Compute 44 = FPConst_DSP_SOS_Algo2_10 */
/* cc900-data: DSP_SOS_Coeff_Compute 45 = FPConst_DSP_SOS_Algo2_0p00014247586 */
/* cc900-data: DSP_SOS_Coeff_Compute 46 = FPConst_DSP_SOS_Algo2_0p00014247586_2 */
/* cc900-data: DSP_SOS_Coeff_Compute 47 = FPConst_DSP_SOS_Algo2_1 */
/* cc900-data: DSP_SOS_Coeff_Compute 48 = FPConst_DSP_SOS_Algo2_1_2 */
/* cc900-data: DSP_SOS_Coeff_Compute 49 = FPConst_DSP_SOS_Algo2_1_3 */
/* cc900-data: DSP_SOS_Coeff_Compute 50 = FPConst_DSP_SOS_Algo2_1_4 */
/* cc900-data: DSP_SOS_Coeff_Compute 51 = FPConst_DSP_SOS_Algo2_1_5 */
/* cc900-data: DSP_SOS_Coeff_Compute 52 = FPConst_DSP_SOS_Algo2_NonzeroCoeff_0p00014247586 */
/* cc900-data: DSP_SOS_Coeff_Compute 53 = FPConst_DSP_SOS_Algo2_NonzeroCoeff_0p00014247586_2 */
/* cc900-data: DSP_SOS_Coeff_Compute 54 = FPConst_DSP_SOS_Algo2_NonzeroCoeff_1 */
/* cc900-data: DSP_SOS_Coeff_Compute 55 = FPConst_DSP_SOS_Algo2_NonzeroCoeff_1_2 */
/* cc900-data: DSP_SOS_Coeff_Compute 56 = FPConst_DSP_SOS_Algo2_NonzeroCoeff_1_3 */
/* cc900-data: DSP_SOS_Coeff_Compute 57 = FPConst_DSP_SOS_Algo2_NonzeroCoeff_1_4 */
/* cc900-data: DSP_SOS_Coeff_Compute 58 = FPConst_DSP_SOS_Algo2_NonzeroCoeff_1_5 */
/* cc900-data: DSP_SOS_Coeff_Compute 59 = FPConst_DSP_SOS_Algo2_FinalChain_1 */
/* cc900-data: DSP_SOS_Coeff_Compute 60 = FPConst_DSP_SOS_Algo2_FinalChain_1_2 */
/* cc900-data: DSP_SOS_Coeff_Compute 61 = FPConst_DSP_SOS_Algo2_FinalChain_Q22One */
/* cc900-data: DSP_SOS_Coeff_Compute 62 = FPConst_DSP_SOS_Algo2_FinalChain_Q22One_2 */
/* cc900-data: DSP_SOS_Coeff_Compute 63 = FPConst_DSP_SOS_Algo2_FinalChain_Q22One_3 */
unsigned char *DSP_SOS_Coeff_Compute(register int chip, unsigned int slot, unsigned int v, unsigned char *p,
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
    int s;

    p = DSP_SOS_LUT_Fetch(v, &freq, &gain, &type, rec, p);
    switch (type) {
    case 0:
        amp = pow(10.0, gain / 20.0F);
        if (gain >= 0.0F) {
            k1 = (float)((sin(freq * 0.0001424758573) - 1.0) / cos(freq * 0.0001424758573));
            r = (k1 + 1.0F) / (1.0F - k1);
            k2 = (1.0F - amp / r) / (amp / r + 1.0F);
        } else {
            k2 = (float)((sin(freq * 0.0001424758573) - 1.0) / cos(freq * 0.0001424758573));
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
            k1 = (float)((sin(freq * 0.0001424758573) - 1.0) / cos(freq * 0.0001424758573));
            r = (1.0F - k1) / (k1 + 1.0F);
            k2 = (amp / r - 1.0F) / (amp / r + 1.0F);
        } else {
            k2 = (float)((sin(freq * 0.0001424758573) - 1.0) / cos(freq * 0.0001424758573));
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
            k1 = (float)((sin(freq * 0.0001424758573) - 1.0) / cos(freq * 0.0001424758573));
            r = (1.0F - k1) / (k1 + 1.0F);
            k2 = (amp / r - 1.0F) / (amp / r + 1.0F);
        } else {
            k2 = (float)((sin(freq * 0.0001424758573) - 1.0) / cos(freq * 0.0001424758573));
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
