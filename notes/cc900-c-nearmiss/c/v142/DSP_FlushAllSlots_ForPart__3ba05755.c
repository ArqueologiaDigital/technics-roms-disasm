/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_2b.c (2026-11-16-47-sub-r2)
   sha256 3ba05755c2798de91f6133ff8f8917993908146ceb144365284b065fc249c7a9 (name+funcs); compiled at -Xr */
extern unsigned char ram_41381[];
extern unsigned char ram_41382[];
extern void DSP_FlushAllSlots(int, int);
void DSP_FlushAllSlots_ForPart(unsigned char part)
{
    DSP_FlushAllSlots(ram_41381[part * 0x11f], ram_41382[part * 0x11f]);
}
