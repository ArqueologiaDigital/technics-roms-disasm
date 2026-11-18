/* Functions of core/14_dsp_control_routines.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char *DSP_StreamDecode_3ByteWord(unsigned char *p, void *out);
extern double __cdecl pow(double x, double y);

/* cc900-data: DSP_ParamInterp_FPComplex 1 = FPConst_DSP_ParamInterp_FPComplex_32768 */
/* cc900-data: DSP_ParamInterp_FPComplex 2 = FPConst_DSP_ParamInterp_FPComplex_65536 */
/* cc900-data: DSP_ParamInterp_FPComplex 3 = FPConst_DSP_ParamInterp_FPComplex_99 */
/* cc900-data: DSP_ParamInterp_FPComplex 4 = FPConst_DSP_ParamInterp_FPComplex_44100 */
/* cc900-data: DSP_ParamInterp_FPComplex 5 = FPConst_DSP_ParamInterp_FPComplex_99_2 */
/* cc900-data: DSP_ParamInterp_FPComplex 6 = FPConst_DSP_ParamInterp_FPComplex_2376 */
/* cc900-data: DSP_ParamInterp_FPComplex 7 = FPConst_DSP_ParamInterp_FPComplex_2 */
/* cc900-data: DSP_ParamInterp_FPComplex 8 = FPConst_DSP_ParamInterp_FPComplex_Q23One */
long DSP_ParamInterp_FPComplex(unsigned char **pp, long x)
{
    float y;
    long a;
    long b;
    long r;
    float c;
    register unsigned char *p;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &a);
    c = (float)a / 32768 / 65536.0F;
    p = DSP_StreamDecode_3ByteWord(p, &b);
    b = (b >> 8) & 0xffffff;
    y = pow(2.0, 2376.0F / (99.0F - (c * 99.0F + ((float)b - c) * x) * 44100.0F));
    *pp = p;
    r = y * 8388608.0F;
    return r;
}
