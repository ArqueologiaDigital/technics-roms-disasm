/* Functions of core/14_dsp_control_routines.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern double __cdecl pow(double x, double y);
long DSP_ReverbCurve_FP(unsigned char **pp, long x);
long DSP_VolumeCurve_FP(unsigned char **pp, long x);

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
/* cc900-data: DSP_ReverbCurve_FP 1 = FPConst_DSP_ReverbCurve_FP_1 */
/* cc900-data: DSP_ReverbCurve_FP 2 = FPConst_DSP_ReverbCurve_FP_441 */
/* cc900-data: DSP_ReverbCurve_FP 3 = FPConst_DSP_ReverbCurve_FP_10 */
/* cc900-data: DSP_ReverbCurve_FP 4 = FPConst_DSP_ReverbCurve_FP_0p4270422 */
/* cc900-data: DSP_ReverbCurve_FP 5 = FPConst_DSP_ReverbCurve_FP_1_2 */
/* cc900-data: DSP_ReverbCurve_FP 6 = FPConst_DSP_ReverbCurve_FP_HighRange_SampleRate */
/* cc900-data: DSP_ReverbCurve_FP 7 = FPConst_DSP_ReverbCurve_FP_HighRange_3924900 */
/* cc900-data: DSP_ReverbCurve_FP 8 = FPConst_DSP_ReverbCurve_FP_HighRange_10 */
/* cc900-data: DSP_ReverbCurve_FP 9 = FPConst_DSP_ReverbCurve_FP_HighRange_0p4270422 */
/* cc900-data: DSP_ReverbCurve_FP 10 = FPConst_DSP_ReverbCurve_FP_HighRange_1 */
/* cc900-data: DSP_ReverbCurve_FP 11 = FPConst_DSP_ReverbCurve_FP_Finalize_Q23One */
long DSP_ReverbCurve_FP(unsigned char **pp, long x)
{
    float y;
    long r;

    if (x <= 89) {
        y = (float)(1.0 - pow(0.4270422, 10.0 / (((float)x + 1.0F) * 441.0)));
    } else {
        y = (float)(1.0 - pow(0.4270422, 10.0F / ((float)x * 44100.0F - 3924900.0F)));
    }
    r = y * 8388608.0F;
    return r;
}

long DSP_VolumeCurve_FP(unsigned char **pp, long x)
{
    float y;
    long r;

    if (x <= 75) {
        y = pow(2.0, 1800.0F / (75.0F - (+((float)x * 30.0F) * 44100.0F + 3307500.0F)));
    } else {
        y = pow(2.0, 576.0F / (24.0F - (+((float)x * 30.0F) * 44100.0F - 65091600.0F)));
    }
    r = y * 8388608.0F;
    return r;
}
