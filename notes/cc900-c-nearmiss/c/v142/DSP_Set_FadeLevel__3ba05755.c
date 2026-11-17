/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_2b.c (2026-11-16-47-sub-r2)
   sha256 3ba05755c2798de91f6133ff8f8917993908146ceb144365284b065fc249c7a9 (name+funcs); compiled at -Xr */
extern unsigned int __near ram_45b2;
extern unsigned int __near ram_45b4;
extern unsigned int __near ram_45b6;
extern int DSP_MixerCoeff_Compute(unsigned int, unsigned int, unsigned int);
int DSP_Set_FadeLevel(unsigned char v)
{
    ram_45b6 = v;
    DSP_MixerCoeff_Compute(ram_45b2, ram_45b4, ram_45b6);
    return ram_45b6;
}
