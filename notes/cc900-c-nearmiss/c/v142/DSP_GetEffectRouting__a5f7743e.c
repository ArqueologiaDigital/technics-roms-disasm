/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_2a.c (2026-11-16-47-sub-r2)
   sha256 a5f7743e23bc8f55cc179cb7f13b9bea660c20e46906cee3cecdd47bc3068a8c (name+funcs); compiled at -Xr */
extern unsigned char ram_41377;
extern unsigned char ram_4137a;
unsigned int DSP_GetEffectRouting(void)
{
    unsigned int r;

    r = 0;
    if (ram_41377 != 0)
        r |= ram_41377 << 8;
    if (ram_4137a != 0)
        r |= ram_41377;
    return r;
}
