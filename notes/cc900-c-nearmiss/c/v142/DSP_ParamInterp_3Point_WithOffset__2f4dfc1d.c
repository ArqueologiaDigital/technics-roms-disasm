/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_X_18a.c (2026-11-17-7-sub-r18)
   sha256 2f4dfc1d8ac8c3544bcd465502dc201e2b0fa76d164bd67b38a298482bf828df (name+funcs); compiled at -Xr */
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
    r = (c + v0 + (u - v0) * b / 0x63) << 8;
    *pp = p;
    return r;
}
