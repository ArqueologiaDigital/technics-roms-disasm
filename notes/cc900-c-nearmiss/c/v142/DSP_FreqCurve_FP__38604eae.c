/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_5a.c (2026-11-16-86-sub-r9)
   sha256 38604eaef711c8975f39133271ddd4a463dd44abf935b4ade97a469216c12a20 (name+funcs); compiled at -O2 -Xr */
long DSP_FreqCurve_FP(unsigned char **pp, long x)
{
    if (x <= 0x14)
        return (x << 23) / (0xfa0 - x * 2);
    else if (x <= 0x32)
        return ((x - 0xa) << 23) / (0x7ba - (x * 2 - 0x2a));
    else
        return ((x * 0xb - 0x186) << 15) / (0x1dea - (x * 0x16 - 0x462)) << 8;
}
