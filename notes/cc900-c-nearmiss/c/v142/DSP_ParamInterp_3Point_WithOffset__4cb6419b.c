/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_X_18b.c (2026-11-17-7-sub-r18)
   sha256 4cb6419b219c04611a2f0cd41db9021edc090635685d23af8b08ee039d16493c (name+funcs); compiled at -Xr */
extern unsigned char *DSP_StreamDecode_3ByteWord(unsigned char *p, void *out);
long DSP_ParamInterp_3Point_WithOffset(unsigned char **pp, long b, long c)
{
    long v0;
    long v1;
    unsigned char *p;
    unsigned long r;
    long u;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    v0 = (v0 >> 8) & 0xffffff;
    u = (v1 >> 8) & 0xffffff;
    v1 = u;
    r = (unsigned long)((c + v0 + (u - v0) * b / 0x63) << 8);
    *pp = p;
    return (long)r;
}
