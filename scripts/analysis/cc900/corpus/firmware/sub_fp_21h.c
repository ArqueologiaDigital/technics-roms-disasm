/* lane_sub round 21, floating point (KN5000 sub-CPU payload v1.42), form h: DSP_DetuneCurve_SignedFP, the final quotient cast to float.
   The ROM tests |x| (the conditional `x < 0 ? -x : x`, kept in XIZ) against 10, 19 and 31, stores each |x| it
   converts in a temporary of its own (+60, +56, +52, +48), and negates the float when x < 0.
   cc900-options: -Xr */

#define ABS(v) ((v) < 0 ? -(v) : (v))

extern double __cdecl pow(double x, double y);

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
long DSP_DetuneCurve_SignedFP(unsigned char **pp, long x)
{
    float y;
    float f;
    long r;

    if (ABS(x) <= 10) {
        f = ABS(x) * 2.0F;
    } else if (ABS(x) <= 19) {
        f = ABS(x) * 20.0F - 180.0F;
    } else if (ABS(x) <= 31) {
        f = ABS(x) * 100.0F - 1700.0F;
    } else {
        f = ABS(x) * 200.0F - 4800.0F;
    }
    if (x < 0) {
        f = -f;
    }
    y = (float)((1.0 - pow(2.0, f / 2400.0F)) / 2400.0);
    r = y * 8388608.0F;
    return r;
}
