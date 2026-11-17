/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_2b.c (2026-11-16-47-sub-r2)
   sha256 3ba05755c2798de91f6133ff8f8917993908146ceb144365284b065fc249c7a9 (name+funcs); compiled at -Xr */
extern unsigned char ram_41377;
extern unsigned char ram_4137a;
unsigned int DSP_GetEffectRouting(void)
{
    unsigned int r;

    r = 0;
    if (ram_41377 != 0)
        r = r | (ram_41377 << 8);
    if (ram_4137a != 0)
        r |= ram_41377;
    return r;
}
