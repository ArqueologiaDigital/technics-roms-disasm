/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_2a.c (2026-11-16-47-sub-r2)
   sha256 a5f7743e23bc8f55cc179cb7f13b9bea660c20e46906cee3cecdd47bc3068a8c (name+funcs); compiled at -Xr */
extern unsigned int __near ram_45b2;
extern unsigned int __near ram_45b4;
extern unsigned int __near ram_45b6;
extern int DSP_MixerCoeff_Compute(unsigned int, unsigned int, unsigned int);
int DSP_Set_MixParam_45B2(unsigned char v)
{
    ram_45b2 = v;
    return DSP_MixerCoeff_Compute(v, ram_45b4, ram_45b6);
    return ram_45b2;
}
