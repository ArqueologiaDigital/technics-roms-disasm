/* lane_sub round 20, floating point (KN5000 sub-CPU payload v1.42), form a: user locals for every value the ROM
   keeps on the stack, declared in the order of their frame offsets (lowest first).
   cc900-options: -Xr */

extern long DSP_FreqParamCurve_Algo2[];
extern unsigned long DSP_MixerGain_Curve[];
extern long __near DSP2_MixerGain_Curve[];
extern int DSP_DispatchCommand(int d, int chip);
extern int DSP_DispatchData(int d, int chip);
extern void DSP2_SPI_BusIdle(void);
extern void DSP_Bytecode_NotifyStateChange(void);
extern double __cdecl pow(double x, double y);

/* cc900-data: DSP_AlgoParam_Decode 1 = FPConst_DSP_AlgoParam_Decode_0p552 */
/* cc900-data: DSP_AlgoParam_Decode 2 = FP_Const_0p552_Add */
long DSP_AlgoParam_Decode(unsigned char **pp, long x)
{
    unsigned char *p;
    float f;
    long r;

    p = *pp;
    if (*p != 1) {
        f = -DSP_FreqParamCurve_Algo2[x];
        r = f * 0.552;
    } else {
        f = DSP_FreqParamCurve_Algo2[x];
        r = f * 0.552;
    }
    p++;
    *pp = p;
    return r;
}

/* cc900-data: DSP_VolumeCurve_FP 1 = FPConst_DSP_VolumeCurve_FP_30 */
/* cc900-data: DSP_VolumeCurve_FP 2 = FPConst_DSP_VolumeCurve_FP_SampleRate */
/* cc900-data: DSP_VolumeCurve_FP 3 = FPConst_DSP_VolumeCurve_FP_3307500 */
/* cc900-data: DSP_VolumeCurve_FP 4 = FPConst_DSP_VolumeCurve_FP_75 */
/* cc900-data: DSP_VolumeCurve_FP 5 = FPConst_DSP_VolumeCurve_FP_1800 */
/* cc900-data: DSP_VolumeCurve_FP 6 = FPConst_DSP_VolumeCurve_FP_2 */
/* cc900-data: DSP_VolumeCurve_FP 7 = FPConst_DSP_VolumeCurve_FP_HighRange_30 */
/* cc900-data: DSP_VolumeCurve_FP 8 = FPConst_DSP_VolumeCurve_FP_HighRange_SampleRate */
/* cc900-data: DSP_VolumeCurve_FP 9 = FPConst_DSP_VolumeCurve_FP_HighRange_65091600 */
/* cc900-data: DSP_VolumeCurve_FP 10 = FPConst_DSP_VolumeCurve_FP_HighRange_24 */
/* cc900-data: DSP_VolumeCurve_FP 11 = FPConst_DSP_VolumeCurve_FP_HighRange_576 */
/* cc900-data: DSP_VolumeCurve_FP 12 = FPConst_DSP_VolumeCurve_FP_HighRange_2 */
/* cc900-data: DSP_VolumeCurve_FP 13 = FPConst_DSP_VolumeCurve_FP_Finalize_Q23One */
long DSP_VolumeCurve_FP(unsigned char **pp, long x)
{
    long r;
    float y;

    if (x <= 75) {
        y = pow(2.0, 1800.0F / (75.0F - ((float)x * 30.0F * 44100.0F + 3307500.0F)));
    } else {
        y = pow(2.0, 576.0F / (24.0F - ((float)x * 30.0F * 44100.0F - 65091600.0F)));
    }
    r = y * 8388608.0F;
    return r;
}

void DSP_MixerCoeff_Compute(unsigned int a, unsigned int b, unsigned int c)
{
    unsigned long v;
    float f;
    long w;

    v = (DSP2_MixerGain_Curve[c] >> 15) * (((DSP2_MixerGain_Curve[a] >> 16) * (DSP_MixerGain_Curve[b] >> 15)) >> 16);
    f = DSP2_MixerGain_Curve[a];
    w = f;
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
    DSP_DispatchData(w >> 25, 1);
    DSP_DispatchData(w >> 17, 1);
    DSP2_SPI_BusIdle();
    DSP_Bytecode_NotifyStateChange();
}
