/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_2b.c (2026-11-16-47-sub-r2)
   sha256 3ba05755c2798de91f6133ff8f8917993908146ceb144365284b065fc249c7a9 (name+funcs); compiled at -Xr */
extern unsigned long __near ram_1040;
extern void Kernel_YieldRotate(int);
void DSP_WaitForDelay(unsigned int t)
{
    unsigned long target;

    target = ram_1040 + (((unsigned long)t + 1) >> 1);
    while (ram_1040 < target)
        Kernel_YieldRotate(3);
}
