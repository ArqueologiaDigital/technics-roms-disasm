/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_9a.c (2026-11-16-86-sub-r9)
   sha256 50278d32d579b37dffe2a8c4368d5dcef6c6061274f0ddf727a7b480425c0cab (name+funcs); compiled at -Xr */
extern unsigned char *DSP_StreamDecode_3ByteWord(unsigned char *p, void *out);
long DSP_ParamInterp_Div0xC6(unsigned char **pp, long b)
{
    long v0;
    long v1;
    unsigned char *p;
    long t;
    long r;
    long q;

    p = *pp;
    p = DSP_StreamDecode_3ByteWord(p, &v0);
    p = DSP_StreamDecode_3ByteWord(p, &v1);
    t = b;
    t += 0x63;
    q = ((v1 - v0) >> 8) / 0xc6;
    r = (v0 >> 8) + q * t;
    *pp = p;
    return r;
}
