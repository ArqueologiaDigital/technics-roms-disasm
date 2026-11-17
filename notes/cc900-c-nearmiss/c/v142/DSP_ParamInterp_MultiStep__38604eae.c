/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_5a.c (2026-11-16-86-sub-r9)
   sha256 38604eaef711c8975f39133271ddd4a463dd44abf935b4ade97a469216c12a20 (name+funcs); compiled at -Xr */
extern unsigned char *DSP_StreamDecode_3ByteWord(unsigned char *p, void *out);
long DSP_ParamInterp_MultiStep(unsigned char **pp, long b, int *tbl, int unused, unsigned int n)
{
    long junk;
    long v0;
    long v1;
    unsigned char *p;
    int k;
    long r;

    p = *pp;
    switch (*p++ & 0xf0) {
    case 0x10:
        k = tbl[n - 1];
        break;
    case 0x20:
        k = tbl[n - 2];
        break;
    default:
        k = (int)b;
        break;
    }
    switch (k) {
    case 1:
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &v0);
        p = DSP_StreamDecode_3ByteWord(p, &v1);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        break;
    case 2:
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &v0);
        p = DSP_StreamDecode_3ByteWord(p, &v1);
        break;
    default:
        p = DSP_StreamDecode_3ByteWord(p, &v0);
        p = DSP_StreamDecode_3ByteWord(p, &v1);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        p = DSP_StreamDecode_3ByteWord(p, &junk);
        break;
    }
    r = (v0 >> 8) + ((v1 - v0) >> 8) * b / 0x63;
    *pp = p;
    return r;
}
