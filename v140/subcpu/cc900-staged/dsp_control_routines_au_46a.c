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
unsigned char *DSP_SOS_LUT_Fetch(unsigned int i, float *fo, float *go, int *mo, int *tbl, unsigned char *p);

/* cc900-module: DSP_SOS_LUT_Fetch */
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
    switch (c) {
    default:
        fr = *(volatile float *)&DSP_EQ_FreqHz_Table[tbl[i] * 4];
        g = tbl[i + 1] * 0.5 + -12.0;
        break;
    case 0x10:
        fr = *(volatile float *)&DSP_EQ_FreqHz_Table[tbl[i - 1] * 4];
        g = tbl[i] * 0.5 + -12.0;
        break;
    }
    switch (m) {
    case 2:
        fr = *(volatile float *)&DSP_EQ_FreqHz_Table[(int)(*p++ & 0x1f) * 4];
        break;
    }
    *mo = m;
    *fo = fr;
    *go = g;
    return p;
}
