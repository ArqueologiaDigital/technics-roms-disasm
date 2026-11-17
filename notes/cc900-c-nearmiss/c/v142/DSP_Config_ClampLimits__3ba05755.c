/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_2b.c (2026-11-16-47-sub-r2)
   sha256 3ba05755c2798de91f6133ff8f8917993908146ceb144365284b065fc249c7a9 (name+funcs); compiled at -Xr */
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
