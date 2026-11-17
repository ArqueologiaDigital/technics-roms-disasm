/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_X_18c.c (2026-11-17-7-sub-r18)
   sha256 765d137710de7b401c4427e3d7f5a9fdcc18d6307c73bba0f901ebcfe5e4efee (name+funcs); compiled at -Xr */
extern unsigned char *DSP_StreamDecode_3ByteWord(unsigned char *p, void *out);
long DSP_ParamInterp_3Point_WithOffset(unsigned char **pp, long b, long c)
{
    long v0;
    long v1;
    unsigned char *p;
    long r;
    long u;
    long s;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    v0 = (v0 >> 8) & 0xffffff;
    u = (v1 >> 8) & 0xffffff;
    v1 = u;
    s = (c + v0 + (u - v0) * b / 0x63) << 8;
    *pp = p;
    r = s;
    return r;
}
