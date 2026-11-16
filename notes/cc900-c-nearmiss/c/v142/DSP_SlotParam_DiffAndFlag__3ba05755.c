/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_2b.c (2026-11-16-47-sub-r2)
   sha256 3ba05755c2798de91f6133ff8f8917993908146ceb144365284b065fc249c7a9 (name+funcs); compiled at -Xr */
struct slot { unsigned int type; int f2; int param[25]; int on; };
struct cfg { unsigned int f0, f2, f4, f6; struct slot s[5]; };
struct e50 { unsigned int f0; int pad[7]; unsigned int m[17]; };
extern struct slot __near ram_45d2[];
extern struct e50 __near ram_4940[];
void DSP_SlotParam_DiffAndFlag(struct cfg *p)
{
    unsigned int i;

    for (i = 0; i < 5; i++) {
        if (ram_45d2[i].type != p->s[i].type)
            ram_4940[i].f0 = 1;
        else
            ram_4940[i].f0 = 0;
    }
}
