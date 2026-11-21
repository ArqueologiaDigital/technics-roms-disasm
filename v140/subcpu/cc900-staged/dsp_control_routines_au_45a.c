/* Functions of core/14_dsp_control_routines.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char DSP_EQ_FreqHz_Table[];
extern unsigned char DSP_EQ_Q_Table[];
unsigned char *DSP_FilterLUT_Fetch(unsigned int i, float *fo, float *qo, float *go, int *mo, int *tbl,
                                   unsigned char *p);

/* cc900-module: DSP_FilterLUT_Fetch */
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
            fr = *(volatile float *)&DSP_EQ_FreqHz_Table[(tbl[i]) * 4];
            q = *(volatile float *)&DSP_EQ_Q_Table[(tbl[i + 1]) * 4];
            g = tbl[i + 2] * 0.5 + -12.0;
            break;
        case 0x10:
            fr = *(volatile float *)&DSP_EQ_FreqHz_Table[(tbl[i - 1]) * 4];
            q = *(volatile float *)&DSP_EQ_Q_Table[(tbl[i]) * 4];
            g = tbl[i + 1] * 0.5 + -12.0;
            break;
        case 0x20:
        default:
            fr = *(volatile float *)&DSP_EQ_FreqHz_Table[(tbl[i - 2]) * 4];
            q = *(volatile float *)&DSP_EQ_Q_Table[(tbl[i - 1]) * 4];
            g = tbl[i] * 0.5 + -12.0;
            break;
        }
        break;
    case 1:
        q = 0.1F;
        fr = *(volatile float *)&DSP_EQ_FreqHz_Table[(tbl[i]) * 4];
        break;
    case 2:
        q = 2.0F;
        switch (c) {
        case 0:
            fr = *(volatile float *)&DSP_EQ_FreqHz_Table[(tbl[i]) * 4];
            g = tbl[i + 1] * 0.5 + -12.0;
            break;
        case 0x20:
        default:
            fr = *(volatile float *)&DSP_EQ_FreqHz_Table[(tbl[i - 1]) * 4];
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
