/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v141/dsp_control_routines_c_runtime.c (2026-11-16-80-sub-staged2)
   sha256 574cedd82836d0c0f2825f6ef9b875a60910f3d343fc09bfa687f9991a90a71c (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char *DSP_StreamDecode_3ByteWord(unsigned char *p, void *out);
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
