/* Functions of core/14_dsp_control_routines.s (callers that declare DSP_StreamDecode_3ByteWord
   with a void * output, as they matched; dsp_control_routines.c defines it with long *).
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
   Held back from subcpu/cc900/ (2026-11-16): these call the C runtime (C9H_mulls / C9H_divls ...), whose
   names the build does not map to the payload's Math_Multiply32 / Long_SignedDiv yet.
*/

extern unsigned char *DSP_StreamDecode_3ByteWord(unsigned char *p, void *out);

long DSP_FreqCurve_FP(unsigned char **pp, long x)
{
    if (x <= 0x14)
        return (x << 23) / (0xfa0 - x * 2);
    else if (x <= 0x32)
        return ((x - 0xa) << 23) / (0x7ba - (x * 2 - 0x2a));
    else
        return ((x * 0xb - 0x186) << 15) / (0x1dea - (x * 0x16 - 0x462)) << 8;
}

long DSP_FreqInterp_2Point(unsigned char **pp, long b)
{
    long v0;
    long v1;
    unsigned char *p;
    long r;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    r = (v0 >> 8) + ((v1 - v0) >> 8) * b / 0x63;
    *pp = p;
    return r;
}

long DSP_PanScale_Simple(unsigned char **pp, long x)
{
    return x * 0xac44 / 0x3e8;
}

long DSP_ParamInterp_2Point(unsigned char **pp, long b)
{
    long v0;
    long v1;
    unsigned char *p;
    long r;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    r = (v0 >> 8) + ((v1 - v0) >> 8) * b / 0x63;
    *pp = p;
    return r;
}

long DSP_ParamInterp_2Point_B(unsigned char **pp, long b)
{
    long v0;
    long v1;
    unsigned char *p;
    long r;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    r = (v0 >> 8) + ((v1 - v0) >> 8) * b / 0x63;
    *pp = p;
    return r;
}
