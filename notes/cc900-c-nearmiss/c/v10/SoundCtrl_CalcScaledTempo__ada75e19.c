/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_6b.c (2026-11-16-45-p6-r9)
   sha256 ada75e19fdf402b5b82177e3cb8547c743609cbbf0e8654f7b07609e1ab4a282 (tar-sha256); compiled at -Xr */
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
    if (r >= 100)
        r = 99;
    ram_39ab = (unsigned char)r;
}
