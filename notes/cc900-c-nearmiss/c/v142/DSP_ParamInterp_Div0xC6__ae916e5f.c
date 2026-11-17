/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_L_16a.c (2026-11-16-112-sub-r16)
   sha256 ae916e5f062d07a6c64e1f94e1e43f04c18314a3a2cacf0567a454e58ef8b3a4 (name+funcs); compiled at -Xr */
extern unsigned char *DSP_StreamDecode_3ByteWord(unsigned char *p, void *out);
long DSP_ParamInterp_Div0xC6(unsigned char **pp, long b)
{
    long v0;
    long v1;
    unsigned char *p;
    long t;
    long q;
    long r;
    long m;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    t = b;
    t += 0x63;
    q = ((v1 - v0) >> 8) / 0xc6;
    m = q * t;
    r = (v0 >> 8) + m;
    *pp = p;
    return r;
}
