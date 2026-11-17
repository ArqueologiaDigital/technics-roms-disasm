/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_2b.c (2026-11-16-47-sub-r2)
   sha256 3ba05755c2798de91f6133ff8f8917993908146ceb144365284b065fc249c7a9 (name+funcs); compiled at -O3 -Xr */
extern unsigned char *ram_4531c;
extern unsigned char *ram_45320;
extern unsigned char ram_7800[];
void DSP_ResetWriteBufferPtr(void)
{
    ram_45320 = ram_7800;
    ram_4531c = ram_7800;
}
