/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_2b.c (2026-11-16-47-sub-r2)
   sha256 3ba05755c2798de91f6133ff8f8917993908146ceb144365284b065fc249c7a9 (name+funcs); compiled at -Xr */
struct slot { unsigned int type; int f2; int param[25]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
extern unsigned int __near ram_45d0;
extern unsigned int __near ram_493e;
void DSP_AlgoChange_CheckAndFlag(struct cfg *p)
{
    if (ram_45d0 != p->f6 || p->f2 == 1 || p->f4 == 1)
        ram_493e = 1;
    else
        ram_493e = 0;
}
