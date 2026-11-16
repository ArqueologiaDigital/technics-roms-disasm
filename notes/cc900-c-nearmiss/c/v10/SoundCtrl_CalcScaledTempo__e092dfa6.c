/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_5b.c (2026-11-16-40-p6-r8)
   sha256 e092dfa680c8d9ce8506cdb5b8df148f8e610a6d1a4b2818f2b7087e306f1a75 (tar-sha256); compiled at -Xr */
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
    ram_39ab = (unsigned char)r;
}
