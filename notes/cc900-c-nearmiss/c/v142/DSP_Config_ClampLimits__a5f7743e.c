/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_2a.c (2026-11-16-47-sub-r2)
   sha256 a5f7743e23bc8f55cc179cb7f13b9bea660c20e46906cee3cecdd47bc3068a8c (name+funcs); compiled at -Xr */
struct slot { unsigned int type; int f2; int param[25]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
void DSP_Config_ClampLimits(struct cfg *p)
{
    unsigned int i;

    if (p->f6 > 1)
        p->f6 = 0;
    for (i = 0; i < 5; i++)
        if (p->s[i].type > 0x63)
            p->s[i].type = 0x63;
}
