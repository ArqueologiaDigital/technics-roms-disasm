/* lane_sub round 21, floating point (KN5000 sub-CPU payload v1.42), form d: DSP_SOS_LUT_Fetch.
   Forms a-c (run 2026-11-18-8-sub-r20b-staged) put p in XIZ and tbl in XDE and spilled i; the ROM keeps i in IZ
   and reads p and tbl from the stack.  Here: i declared `register`, p and tbl made address-taken.
   cc900-options: -Xr */

extern float DSP_EQ_FreqHz_Table[];

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

    (void)&p;
    (void)&tbl;
    m = *p & 0xf;
    c = *p++ & 0xf0;
    if (c != 0x10) {
        fr = DSP_EQ_FreqHz_Table[tbl[i]];
        g = tbl[i + 1] * 0.5 + -12.0;
    } else {
        fr = DSP_EQ_FreqHz_Table[tbl[i - 1]];
        g = tbl[i] * 0.5 + -12.0;
    }
    if (m == 2) {
        fr = DSP_EQ_FreqHz_Table[*p++ & 0x1f];
    }
    *mo = m;
    *fo = fr;
    *go = g;
    return p;
}
