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
long DSP_DetuneCurve_SignedFP(unsigned char **pp, long v);

/* cc900-data: DSP_DetuneCurve_SignedFP 1 = FPConst_DSP_DetuneCurve_Range1_Compute_2 */
/* cc900-data: DSP_DetuneCurve_SignedFP 2 = FPConst_DSP_DetuneCurve_Range2_Compute_20 */
/* cc900-data: DSP_DetuneCurve_SignedFP 3 = FPConst_DSP_DetuneCurve_Range2_Compute_180 */
/* cc900-data: DSP_DetuneCurve_SignedFP 4 = FPConst_DSP_DetuneCurve_Range3_Compute_100 */
/* cc900-data: DSP_DetuneCurve_SignedFP 5 = FPConst_DSP_DetuneCurve_Range3_Compute_1700 */
/* cc900-data: DSP_DetuneCurve_SignedFP 6 = FPConst_DSP_DetuneCurve_Range4_Compute_200 */
/* cc900-data: DSP_DetuneCurve_SignedFP 7 = FPConst_DSP_DetuneCurve_Range4_Compute_4800 */
/* cc900-data: DSP_DetuneCurve_SignedFP 8 = FPConst_DSP_DetuneCurve_Finalize_2400 */
/* cc900-data: DSP_DetuneCurve_SignedFP 9 = FPConst_DSP_DetuneCurve_Finalize_2 */
/* cc900-data: DSP_DetuneCurve_SignedFP 10 = FPConst_DSP_DetuneCurve_Finalize_1 */
/* cc900-data: DSP_DetuneCurve_SignedFP 11 = FPConst_DSP_DetuneCurve_Finalize_2400_2 */
/* cc900-data: DSP_DetuneCurve_SignedFP 12 = FPConst_DSP_DetuneCurve_Finalize_Q23One */
long DSP_DetuneCurve_SignedFP(unsigned char **pp, long v)
{
    float y;
    float f;
    long r;
    register long x;
    x = v;
    if (((x) >= 0 ? (x) : -(x)) <= 10) {
        f = ((x) >= 0 ? (x) : -(x)) * 2.0F;
    } else if (((x) >= 0 ? (x) : -(x)) <= 19) {
        f = ((x) >= 0 ? (x) : -(x)) * 20.0F - 180.0F;
    } else if (((x) >= 0 ? (x) : -(x)) <= 31) {
        f = ((x) >= 0 ? (x) : -(x)) * 100.0F - 1700.0F;
    } else {
        f = ((x) >= 0 ? (x) : -(x)) * 200.0F - 4800.0F;
    }
    if (x < 0) {
        f = -f;
    }
    y = (1.0 - pow(2.0, f / 2400.0F)) / 2400.0;
    r = y * 8388608.0F;
    return r;
}
