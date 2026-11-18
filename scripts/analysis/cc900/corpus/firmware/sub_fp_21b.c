/* lane_sub round 21, floating point (KN5000 sub-CPU payload v1.42), form b: DSP_SOS_LUT_Fetch, the mode byte as a switch (default first).
   Parameters read from the ROM: i in WA (kept in IZ), the two float outputs in XBC / XDE, then three stack
   arguments (the last parameter has the lowest offset: p at +40, tbl at +44, the mode output at +48).
   cc900-options: -Xr */

extern float DSP_EQ_FreqHz_Table[];

/* cc900-data: DSP_SOS_LUT_Fetch 1 = FPConst_DSP_SOS_LUT_Fetch_0p5 */
/* cc900-data: DSP_SOS_LUT_Fetch 2 = FPConst_DSP_SOS_LUT_Fetch_Neg12 */
/* cc900-data: DSP_SOS_LUT_Fetch 3 = FPConst_DSP_SOS_LUT_Mode0x10_0p5 */
/* cc900-data: DSP_SOS_LUT_Fetch 4 = FPConst_DSP_SOS_LUT_Mode0x10_Neg12 */
unsigned char *DSP_SOS_LUT_Fetch(unsigned int i, float *fo, float *go, int *mo, int *tbl, unsigned char *p)
{
    float fr;
    float g;
    int m;

    m = *p & 0xf;
    switch ((unsigned char)(*p++ & 0xf0)) {
    default:
        fr = DSP_EQ_FreqHz_Table[tbl[i]];
        g = tbl[i + 1] * 0.5 + -12.0;
        break;
    case 0x10:
        fr = DSP_EQ_FreqHz_Table[tbl[i - 1]];
        g = tbl[i] * 0.5 + -12.0;
        break;
    }
    if (m == 2) {
        fr = DSP_EQ_FreqHz_Table[*p++ & 0x1f];
    }
    *mo = m;
    *fo = fr;
    *go = g;
    return p;
}

extern long DSP_FreqParamCurve_Algo2[];

/* DSP_AlgoParam_Decode: the type byte read in the assignment that stores p (`c = *(p = *pp)`). */
/* cc900-data: DSP_AlgoParam_Decode 1 = FPConst_DSP_AlgoParam_Decode_0p552 */
/* cc900-data: DSP_AlgoParam_Decode 2 = FP_Const_0p552_Add */
long DSP_AlgoParam_Decode(unsigned char **pp, long x)
{
    long r;
    long t;
    double d;
    float f;
    unsigned char *p;
    unsigned char c;

    c = *(p = *pp);
    if (c != 1) {
        t = -DSP_FreqParamCurve_Algo2[x];
        f = t;
        d = f;
        d = d * 0.552;
        r = d;
    } else {
        f = DSP_FreqParamCurve_Algo2[x];
        d = f;
        d = d * 0.552;
        r = d;
    }
    p++;
    *pp = p;
    return r;
}
