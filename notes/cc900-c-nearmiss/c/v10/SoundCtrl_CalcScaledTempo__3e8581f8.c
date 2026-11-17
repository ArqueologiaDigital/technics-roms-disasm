/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_6a.c (2026-11-16-45-p6-r9)
   sha256 3e8581f89f18a4e64d479008e9062b32ff0f8bd6db6483f31bfaeab22f82d159 (tar-sha256); compiled at -Xr */
extern unsigned int __near STYLE_FREE_BLOCKS;
extern unsigned char __near ram_39ab;
extern unsigned long Math_Multiply32(unsigned long, unsigned long);
extern unsigned long Math_DivideU32(unsigned long, unsigned long);
void SoundCtrl_CalcScaledTempo(void)
{
    unsigned long r;
    r = 100;
    r = Math_Multiply32(r, (unsigned long)STYLE_FREE_BLOCKS);
    r = Math_DivideU32(r, 190L);
    if (r > 99)
        r = 99;
    ram_39ab = r;
}
