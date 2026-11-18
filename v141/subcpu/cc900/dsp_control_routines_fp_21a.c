/* Functions of core/14_dsp_control_routines.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern long DSP_FreqParamCurve_Algo2[];

/* cc900-data: DSP_AlgoParam_Decode 1 = FPConst_DSP_AlgoParam_Decode_0p552 */
/* cc900-data: DSP_AlgoParam_Decode 2 = FP_Const_0p552_Add */
long DSP_AlgoParam_Decode(unsigned char **pp, long x)
{
    long r;
    long t;
    double d;
    float f;
    unsigned char *p;
    unsigned char *q;
    unsigned char c;

    q = *pp;
    p = q;
    c = *q;
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
