/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_2a.c (2026-11-16-47-sub-r2)
   sha256 a5f7743e23bc8f55cc179cb7f13b9bea660c20e46906cee3cecdd47bc3068a8c (name+funcs); compiled at -Xr */
extern unsigned long __near ram_1040;
extern void Kernel_YieldRotate(int);
void DSP_WaitForDelay(unsigned int t)
{
    unsigned long target;

    target = (((unsigned long)t + 1) >> 1) + ram_1040;
    while (ram_1040 < target)
        Kernel_YieldRotate(3);
}
