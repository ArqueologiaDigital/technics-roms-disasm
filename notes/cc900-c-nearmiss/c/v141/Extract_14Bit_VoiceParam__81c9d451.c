/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v141/dsp2_init.c (2026-11-16-62-sub-r4)
   sha256 81c9d451e6a64a2ab8ea02577e3516875f47ec8ee643bbad95591f37d72814f9 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
unsigned int Extract_14Bit_VoiceParam(unsigned char *p)
{
    return (((unsigned int)p[2] & 0x7f) << 7) | ((unsigned int)p[3] & 0x7f);
}
