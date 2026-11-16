/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_2a.c (2026-11-16-47-sub-r2)
   sha256 a5f7743e23bc8f55cc179cb7f13b9bea660c20e46906cee3cecdd47bc3068a8c (name+funcs); compiled at -O3 -Xr */
extern unsigned char *ram_4531c;
extern unsigned char *ram_45320;
extern unsigned char ram_7800[];
void DSP_ResetWriteBufferPtr(void)
{
    ram_45320 = ram_7800;
    ram_4531c = ram_7800;
}
