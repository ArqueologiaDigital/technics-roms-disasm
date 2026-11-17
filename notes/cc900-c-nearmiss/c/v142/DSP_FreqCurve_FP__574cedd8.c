/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/dsp_control_routines_c_runtime.c (2026-11-16-80-sub-staged2)
   sha256 574cedd82836d0c0f2825f6ef9b875a60910f3d343fc09bfa687f9991a90a71c (name+funcs); compiled at -Xr
   cc900-options: -Xr */
long DSP_FreqCurve_FP(unsigned char **pp, long x)
{
    if (x <= 0x14)
        return (x << 23) / (0xfa0 - x * 2);
    else if (x <= 0x32)
        return ((x - 0xa) << 23) / (0x7ba - (x * 2 - 0x2a));
    else
        return ((x * 0xb - 0x186) << 15) / (0x1dea - (x * 0x16 - 0x462)) << 8;
}
