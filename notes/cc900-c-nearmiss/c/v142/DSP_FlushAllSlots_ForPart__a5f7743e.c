/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_D_2a.c (2026-11-16-47-sub-r2)
   sha256 a5f7743e23bc8f55cc179cb7f13b9bea660c20e46906cee3cecdd47bc3068a8c (name+funcs); compiled at -Xr */
extern unsigned char ram_41381[];
extern unsigned char ram_41382[];
extern void DSP_FlushAllSlots(int, int);
void DSP_FlushAllSlots_ForPart(unsigned char part)
{
    DSP_FlushAllSlots(ram_41381[part * 0x11f], ram_41382[part * 0x11f]);
}
