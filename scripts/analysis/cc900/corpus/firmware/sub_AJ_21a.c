/* lane_sub round 21, helper AJ, form a (KN5000 sub-CPU payload v1.42, core/14_dsp_control_routines.s): floating point.
   - DSP_BiquadWarp_FP: the stream pointer through a second local t (idiom (a): ROM stores p at +2 and keeps using
     XWA), the class byte c read before p = t is stored back; z plain; DSP_WriteCoeffData_5B_Direct called with three
     arguments (the ROM loads BC = chip and DE = f0), so it is declared with three here.
   - DSP_FilterLUT_Fetch: p and tbl address-taken (ROM reads both from the stack, i in IZ); each table float read as
     `*(float *)&T[k * 4]` on a byte table (ROM: `sla wa,2` then the 16-bit indexed `lda xbc,(xbc+wa)`, the shape
     V4.23 gives a byte array + int index); plain assignment (ROM copies through FP_SP_Raw4Copy).
   - DSP_ParamEQ_Curve_FP: FPComplex's prologue; the range test `v >= -7.0` (V4.23 compiles `<` as DE = 1; the ROM
     jumps to the scaled arm when v < -7); `c * w` (V4.23 evaluated the right operand first in BiquadWarp's ROM).
   - DSP_MixerCoeff_Compute: no float local; the conversion `w = (float)curve[a]` leaves a compiler temporary (ROM: w
     +16, float +12, v +8 and one untouched 4-byte slot at +4; DSP_ReverbCurve_FP's matched frame has an untouched
     temporary area the size of its used one).
   cc900-options: -Xr */

extern double __cdecl pow(double x, double y);
extern int DSP_WriteOscParam(unsigned int a, long v, register int chip, int base);
extern void DSP_WriteCoeffData_5B_Direct(long v, int chip, int f0);
extern unsigned char *DSP_StreamDecode_3ByteWord(unsigned char *p, void *out);
extern unsigned char DSP_EQ_FreqHz_Table[];
extern unsigned char DSP_EQ_Q_Table[];
extern unsigned long DSP_MixerGain_Curve[];
extern long __near DSP2_MixerGain_Curve[];
extern int DSP_DispatchCommand(int d, int chip);
extern int DSP_DispatchData(int d, int chip);
extern void DSP2_SPI_BusIdle(void);
extern void DSP_Bytecode_NotifyStateChange(void);

/* cc900-data: DSP_BiquadWarp_FP 1 = FPConst_DSP_BiquadWarp_ComputeCoeffs_Neg0p0697 */
/* cc900-data: DSP_BiquadWarp_FP 2 = FPConst_DSP_BiquadWarp_ComputeCoeffs_10 */
/* cc900-data: DSP_BiquadWarp_FP 3 = FPConst_DSP_BiquadWarp_ComputeCoeffs_0p9999 */
/* cc900-data: DSP_BiquadWarp_FP 4 = FPConst_DSP_BiquadWarp_ComputeCoeffs_Neg0p0697_2 */
/* cc900-data: DSP_BiquadWarp_FP 5 = FPConst_DSP_BiquadWarp_ComputeCoeffs_10_2 */
/* cc900-data: DSP_BiquadWarp_FP 6 = FPConst_DSP_BiquadWarp_ComputeCoeffs_0p9999_2 */
/* cc900-data: DSP_BiquadWarp_FP 7 = FPConst_DSP_BiquadWarp_ComputeCoeffs_2 */
/* cc900-data: DSP_BiquadWarp_FP 8 = FPConst_DSP_BiquadWarp_ComputeCoeffs_2_2 */
/* cc900-data: DSP_BiquadWarp_FP 9 = FPConst_DSP_BiquadWarp_ComputeCoeffs_1 */
/* cc900-data: DSP_BiquadWarp_FP 10 = FPConst_DSP_BiquadWarp_ComputeCoeffs_3 */
/* cc900-data: DSP_BiquadWarp_FP 11 = FPConst_DSP_BiquadWarp_ComputeCoeffs_Q21One */
/* cc900-data: DSP_BiquadWarp_FP 12 = FPConst_DSP_BiquadWarp_ComputeCoeffs_Q23One */
/* cc900-data: DSP_BiquadWarp_FP 13 = FPConst_DSP_BiquadWarp_ComputeCoeffs_Q22One */
/* cc900-data: DSP_BiquadWarp_FP 14 = FPConst_DSP_BiquadWarp_ComputeCoeffs_Q21One_2 */
/* cc900-data: DSP_BiquadWarp_FP 15 = FPConst_DSP_BiquadWarp_ComputeCoeffs_Q21One_3 */
int DSP_BiquadWarp_FP(unsigned char **pp, int *rec, unsigned int slot, unsigned int v, unsigned int a,
                      int chip, int f0)
{
    float g1;
    float k;
    float g2;
    float q;
    float s;
    unsigned char *p;
    unsigned char *t;
    unsigned char c;
    int h;
    int z;

    t = *pp;
    p = t;
    c = *t++;
    p = t;
    if ((c & 0xf0) == 0) {
        h = rec[v];
        v++;
        z = rec[v];
    } else {
        h = rec[v - 1];
        z = rec[v];
    }
    if (h > 89)
        h = 89;
    if (z > 88)
        z = 88;
    g1 = pow(10.0, (99 - h) * -0.0697) * 0.9999;
    g2 = pow(10.0, (99 - z) * -0.0697) * 0.9999;
    k = 3.0F;
    q = (k - g2) / ((g1 - 2.0F) * (g1 - 2.0F) - 1.0F);
    s = q * 3.0F + g2;
    DSP_WriteOscParam(a, (long)(k * 2097152.0F), chip, f0);
    DSP_WriteCoeffData_5B_Direct((long)(g1 * 8388608.0F), chip, f0);
    DSP_WriteCoeffData_5B_Direct((long)(-q * 4194304.0F), chip, f0);
    DSP_WriteCoeffData_5B_Direct((long)(q * 2097152.0F), chip, f0);
    DSP_WriteCoeffData_5B_Direct((long)(s * 2097152.0F), chip, f0);
    *pp = p;
}

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

    (void)&p;
    (void)&tbl;
    m = *p & 0xf;
    c = *p++ & 0xf0;
    switch (m) {
    case 0:
        switch (c) {
        case 0:
            fr = *(float *)&DSP_EQ_FreqHz_Table[tbl[i] * 4];
            q = *(float *)&DSP_EQ_Q_Table[tbl[i + 1] * 4];
            g = tbl[i + 2] * 0.5 + -12.0;
            break;
        case 0x10:
            fr = *(float *)&DSP_EQ_FreqHz_Table[tbl[i - 1] * 4];
            q = *(float *)&DSP_EQ_Q_Table[tbl[i] * 4];
            g = tbl[i + 1] * 0.5 + -12.0;
            break;
        case 0x20:
        default:
            fr = *(float *)&DSP_EQ_FreqHz_Table[tbl[i - 2] * 4];
            q = *(float *)&DSP_EQ_Q_Table[tbl[i - 1] * 4];
            g = tbl[i] * 0.5 + -12.0;
            break;
        }
        break;
    case 1:
        q = 0.1F;
        fr = *(float *)&DSP_EQ_FreqHz_Table[tbl[i] * 4];
        break;
    case 2:
        q = 2.0F;
        switch (c) {
        case 0:
            fr = *(float *)&DSP_EQ_FreqHz_Table[tbl[i] * 4];
            g = tbl[i + 1] * 0.5 + -12.0;
            break;
        case 0x20:
        default:
            fr = *(float *)&DSP_EQ_FreqHz_Table[tbl[i - 1] * 4];
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

/* cc900-data: DSP_ParamEQ_Curve_FP 1 = FPConst_DSP_ParamEQ_Curve_FP_32768 */
/* cc900-data: DSP_ParamEQ_Curve_FP 2 = FPConst_DSP_ParamEQ_Curve_FP_65536 */
/* cc900-data: DSP_ParamEQ_Curve_FP 3 = FPConst_DSP_ParamEQ_Curve_FP_0p02 */
/* cc900-data: DSP_ParamEQ_Curve_FP 4 = FPConst_DSP_ParamEQ_Curve_FP_0p1 */
/* cc900-data: DSP_ParamEQ_Curve_FP 5 = FPConst_DSP_ParamEQ_Curve_FP_1 */
/* cc900-data: DSP_ParamEQ_Curve_FP 6 = FPConst_DSP_ParamEQ_Curve_FP_Neg4p816 */
/* cc900-data: DSP_ParamEQ_Curve_FP 7 = FPConst_DSP_ParamEQ_Curve_FP_Neg7 */
/* cc900-data: DSP_ParamEQ_Curve_FP 8 = FPConst_DSP_ParamEQ_Curve_FP_10 */
/* cc900-data: DSP_ParamEQ_Curve_FP 9 = FPConst_DSP_ParamEQ_Curve_FP_2 */
/* cc900-data: DSP_ParamEQ_Curve_FP 10 = FPConst_DSP_ParamEQ_Range1_NonzeroCoeff_7 */
/* cc900-data: DSP_ParamEQ_Curve_FP 11 = FPConst_DSP_ParamEQ_Range1_NonzeroCoeff_10 */
/* cc900-data: DSP_ParamEQ_Curve_FP 12 = FPConst_DSP_ParamEQ_Range1_NonzeroCoeff_1em7 */
/* cc900-data: DSP_ParamEQ_Curve_FP 13 = FPConst_DSP_ParamEQ_Range1_NonzeroCoeff_2 */
/* cc900-data: DSP_ParamEQ_Curve_FP 14 = FPConst_DSP_ParamEQ_Range2_16 */
/* cc900-data: DSP_ParamEQ_Curve_FP 15 = FPConst_DSP_ParamEQ_Range2_0p05 */
/* cc900-data: DSP_ParamEQ_Curve_FP 16 = FPConst_DSP_ParamEQ_Range2_0p45 */
/* cc900-data: DSP_ParamEQ_Curve_FP 17 = FPConst_DSP_ParamEQ_Range2_Neg4p816 */
/* cc900-data: DSP_ParamEQ_Curve_FP 18 = FPConst_DSP_ParamEQ_Range2_10 */
/* cc900-data: DSP_ParamEQ_Curve_FP 19 = FPConst_DSP_ParamEQ_Range2_2 */
/* cc900-data: DSP_ParamEQ_Curve_FP 20 = FPConst_DSP_ParamEQ_Range3_24 */
/* cc900-data: DSP_ParamEQ_Curve_FP 21 = FPConst_DSP_ParamEQ_Range3_0p1 */
/* cc900-data: DSP_ParamEQ_Curve_FP 22 = FPConst_DSP_ParamEQ_Range3_0p9 */
/* cc900-data: DSP_ParamEQ_Curve_FP 23 = FPConst_DSP_ParamEQ_Range3_Neg4p816 */
/* cc900-data: DSP_ParamEQ_Curve_FP 24 = FPConst_DSP_ParamEQ_Range3_10 */
/* cc900-data: DSP_ParamEQ_Curve_FP 25 = FPConst_DSP_ParamEQ_Range3_2 */
/* cc900-data: DSP_ParamEQ_Curve_FP 26 = FPConst_DSP_ParamEQ_Range4_56 */
/* cc900-data: DSP_ParamEQ_Curve_FP 27 = FPConst_DSP_ParamEQ_Range4_0p2 */
/* cc900-data: DSP_ParamEQ_Curve_FP 28 = FPConst_DSP_ParamEQ_Range4_4p2 */
/* cc900-data: DSP_ParamEQ_Curve_FP 29 = FPConst_DSP_ParamEQ_Range4_Neg4p816 */
/* cc900-data: DSP_ParamEQ_Curve_FP 30 = FPConst_DSP_ParamEQ_Range4_10 */
/* cc900-data: DSP_ParamEQ_Curve_FP 31 = FPConst_DSP_ParamEQ_Range4_2 */
/* cc900-data: DSP_ParamEQ_Curve_FP 32 = FPConst_DSP_ParamEQ_Range5_67 */
/* cc900-data: DSP_ParamEQ_Curve_FP 33 = FPConst_DSP_ParamEQ_Range5_Neg4p816 */
/* cc900-data: DSP_ParamEQ_Curve_FP 34 = FPConst_DSP_ParamEQ_Range5_10 */
/* cc900-data: DSP_ParamEQ_Curve_FP 35 = FPConst_DSP_ParamEQ_Range5_2 */
/* cc900-data: DSP_ParamEQ_Curve_FP 36 = FPConst_DSP_ParamEQ_Finalize_Q23One */
long DSP_ParamEQ_Curve_FP(unsigned char **pp, long x)
{
    float y;
    long a;
    long r;
    float c;
    float w;
    float v;
    register unsigned char *p;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &a);
    c = (float)a / 32768 / 65536.0F;
    if (x <= 15) {
        w = 1.0 / ((float)x * 0.02 + 0.1);
        v = c * w * -4.816;
        if (v >= -7.0) {
            y = -pow(10.0, v) / 2.0;
        } else {
            y = -pow(10.0, v + 7.0F) * 1e-7 / 2.0;
        }
    } else if (x <= 23) {
        y = -pow(10.0, c * -4.816 / (((float)x - 16.0F) * 0.05 + 0.45)) / 2.0;
    } else if (x <= 55) {
        y = -pow(10.0, c * -4.816 / (((float)x - 24.0F) * 0.1 + 0.9)) / 2.0;
    } else if (x <= 75) {
        y = -pow(10.0, c * -4.816 / (((float)x - 56.0F) * 0.2 + 4.2)) / 2.0;
    } else {
        y = -pow(10.0, c * -4.816 / ((float)x - 67.0F)) / 2.0;
    }
    *pp = p;
    r = y * 8388608.0F;
    return r;
}

void DSP_MixerCoeff_Compute(unsigned int a, unsigned int b, unsigned int c)
{
    long w;
    unsigned long v;

    v = (DSP2_MixerGain_Curve[c] >> 15) * (((DSP2_MixerGain_Curve[a] >> 16) * (DSP_MixerGain_Curve[b] >> 15)) >> 16);
    w = (float)DSP2_MixerGain_Curve[a];
    DSP_DispatchCommand(0x30, 1);
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
