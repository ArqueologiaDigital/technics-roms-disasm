/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_2b.c (2026-11-16-47-sub-r2)
   sha256 3ba05755c2798de91f6133ff8f8917993908146ceb144365284b065fc249c7a9 (name+funcs); compiled at -Xr */
struct ring2k { unsigned int w, r, n; unsigned char buf[2048]; };
extern struct ring2k __near ram_3b60;
void DSP2_Init(void)
{
    ram_3b60.n = 0;
    ram_3b60.w = ram_3b60.r = 0;
}
