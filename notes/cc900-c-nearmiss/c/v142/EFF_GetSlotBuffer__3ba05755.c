/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_2b.c (2026-11-16-47-sub-r2)
   sha256 3ba05755c2798de91f6133ff8f8917993908146ceb144365284b065fc249c7a9 (name+funcs); compiled at -Xr */
struct slot { unsigned int type; int f2; int param[25]; int on; };
extern struct slot __near ram_4496[];
struct slot *EFF_GetSlotBuffer(unsigned int i)
{
    struct slot *r;

    switch (i) {
    case 0: case 1: case 2: case 3: case 4:
        r = &ram_4496[i];
        break;
    default:
        r = (struct slot *)0xffffffff;
        break;
    }
    return r;
}
