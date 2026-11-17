/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_J_14b.c (2026-11-16-101-sub-r14)
   sha256 bc4c451bbb9fb863ec20e0cf12e808971bf6d9c87b958c7ad339bfeaa5661dac (name+funcs); compiled at -Xr */
extern unsigned char *DSP_StreamDecode_3ByteWord(unsigned char *p, void *out);
long DSP_ParamInterp_Div0xC6(unsigned char **pp, long b)
{
    long v0;
    long v1;
    long r;
    unsigned char *p;
    long t;
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
